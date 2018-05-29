/***************************************************************************
*	Licensed Materials - Property of IBM
*
*
*	"Restricted Materials of IBM"
*
*
*
*	IBM Informix Client SDK
*
*
*	Copyright IBM Corporation 1997, 2013 All rights reserved.
*
*
*
*
*
*  Title:          rcselectW.c (Unicode counterpart of rcselect.c)
*
*  Description:    To retrieve row and collection data from the database
*                  and display it. This example also illustrates the fact
*                  that the same client functions can use row and
*                  collection handles interchangeably
*
*                  The row/collection columns retrieved are
*                  -- column 'address' of table 'customer' (datatype - ROW)
*                  -- column 'contact_dates' of table 'customer'
*                     (datatype - LIST)
*
***************************************************************************
*/


#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#ifndef NO_WIN32
#include <io.h>
#include <windows.h>
#include <conio.h>
#endif /*NO_WIN32*/

#include "infxcli.h"

#define BUFFER_LENW    120
#define ERRMSG_LEN     200

SQLWCHAR   defDsnW[] = L"odbc_demo";
SQLCHAR   defDsn[] = "odbc_demo";


SQLINTEGER checkError (SQLRETURN       rc,
                       SQLSMALLINT     handleType,
                       SQLHANDLE       handle,
                       SQLCHAR*        errmsg)
{
    SQLRETURN      retcode = SQL_SUCCESS;
    SQLSMALLINT    errNum = 1;
    SQLWCHAR       sqlStateW[6];
    SQLCHAR        *sqlState;
    SQLINTEGER     nativeError;
    SQLWCHAR       errMsgW[ERRMSG_LEN];
    SQLCHAR        *errMsg;
    SQLSMALLINT    textLengthPtr;


    if ((rc != SQL_SUCCESS) && (rc != SQL_SUCCESS_WITH_INFO))
    {
        while (retcode != SQL_NO_DATA)
        {
            retcode = SQLGetDiagRecW (handleType, handle, errNum, sqlStateW, &nativeError, errMsgW, ERRMSG_LEN, &textLengthPtr);

            if (retcode == SQL_INVALID_HANDLE)
            {
                fprintf (stderr, "checkError function was called with an invalid handle!!\n");
                return 1;
            }

            if ((retcode == SQL_SUCCESS) || (retcode == SQL_SUCCESS_WITH_INFO))
            {
                sqlState = (SQLCHAR *) malloc (wcslen(sqlStateW) + sizeof(char))
                           ;
                wcstombs( (char *) sqlState, sqlStateW, wcslen(sqlStateW)
                          + sizeof(char));

                errMsg = (SQLCHAR *) malloc (wcslen(errMsgW) + sizeof(char));
                wcstombs( (char *) errMsg, errMsgW, wcslen(errMsgW)
                          + sizeof(char));

                fprintf (stderr, "ERROR: %d:  %s : %s \n", nativeError, sqlState , errMsg);
            }

            errNum++;
        }

        fprintf (stderr, "%s\n", errmsg);
        return 1;   /* all errors on this handle have been reported */
    }
    else
        return 0; /* no errors to report */
}




/*
**  Executes the given select statement and assumes the results will be
**  either rows or collections. The 'hrc' parameter may reference either
**  a row or a collection. Rows and collection handles may often be used
**  interchangeably.
**
**  Each row of the select statement will be fetched into the given row or
**  collection handle.  Then each field of the row or collection will be
**  individually converted into a character buffer and displayed.
**
**  This function returns 0 if an error occurs, else returns 1
**
*/
SQLINTEGER do_select (SQLHDBC   hdbc,
                      SQLWCHAR*     select_strW,
                      HINFX_RC  hrc)
{
    SQLHSTMT        hRCStmt;
    SQLHSTMT        hSelectStmt;
    SQLRETURN       rc = 0;

    SQLSMALLINT		index, rownum;
    SQLSMALLINT     position = SQL_INFX_RC_ABSOLUTE;
    SQLSMALLINT     jump;

    SQLCHAR         *fname;
    SQLWCHAR         fnameW[BUFFER_LENW];
    SQLCHAR         *lname;
    SQLWCHAR         lnameW[BUFFER_LENW];
    SQLCHAR         *rc_data;
    SQLWCHAR		    rc_dataW[BUFFER_LENW];

    SQLLEN          cbFname = 0, cbLname = 0, cbHrc = 0;
    SQLLEN          cbPosition = 0, cbJump = 0, cbRCData = 0;


    /*  STEP A. Allocate the statement handles for the select statement and
    **          the statement used to retrieve the row/collection data
    */

    /* Allocate the statement handle */
    rc = SQLAllocHandle (SQL_HANDLE_STMT, hdbc, &hRCStmt );
    if (checkError (rc, SQL_HANDLE_DBC, hdbc, (SQLCHAR *) "Error in Step A -- Statement Handle Allocation failed for row/collection statement\nExiting!!"))
        return 0;

    /* Allocate the statement handle */
    rc = SQLAllocHandle (SQL_HANDLE_STMT, hdbc, &hSelectStmt );
    if (checkError (rc, SQL_HANDLE_DBC, hdbc, (SQLCHAR *) "Error in Step A -- Statement Handle Allocation failed for select statement\nExiting!!"))
        return 0;


    fprintf (stdout, "STEP A done...statement handles allocated\n");



    /*  STEP B. Execut the select statement
    **          Bind the result set columns -
    **          --  col1 = fname
    **              col2 = lname
    **              col3 = row/collection data
    */

    /* Execute the select statement */
    rc = SQLExecDirectW (hSelectStmt, select_strW, SQL_NTS);
    if (checkError (rc, SQL_HANDLE_STMT, hSelectStmt, (SQLCHAR *) "Error in Step B -- SQLExecDirect failed\n"))
        return 0;


    /* Bind the result set columns */
    rc = SQLBindCol (hSelectStmt, 1, SQL_C_WCHAR, (SQLPOINTER) fnameW, BUFFER_LENW, &cbFname);
    if (checkError (rc, SQL_HANDLE_STMT, hSelectStmt, (SQLCHAR *) "Error in Step B -- SQLBindCol failed for column 'fname'\n"))
        return 0;


    rc = SQLBindCol (hSelectStmt, 2, SQL_C_WCHAR, (SQLPOINTER) lnameW, BUFFER_LENW, &cbLname);
    if (checkError (rc, SQL_HANDLE_STMT, hSelectStmt, (SQLCHAR *) "Error in Step B -- SQLBindCol failed for column 'lname'\n"))
        return 0;


    rc = SQLBindCol (hSelectStmt, 3, SQL_C_BINARY, (SQLPOINTER) hrc, sizeof(HINFX_RC), &cbHrc);
    if (checkError (rc, SQL_HANDLE_STMT, hSelectStmt, (SQLCHAR *) "Error in Step B -- SQLBindCol failed for row/collection column\n"))
        return 0;


    fprintf (stdout, "STEP B done...select statement executed and result set columns bound\n");




    /*  STEP C. Retrieve the results
    */


    for (rownum = 1;; rownum++)
    {
        rc = SQLFetch (hSelectStmt);
        if (rc == SQL_NO_DATA_FOUND)
        {
            fprintf (stdout, "No data found...\n");
            break;
        }
        else if (checkError (rc, SQL_HANDLE_STMT, hSelectStmt, (SQLCHAR *) "Error in Step C -- SQLFetch failed\n"))
            return 0;


        fname = (SQLCHAR *) malloc (wcslen(fnameW) +  sizeof(char));
        wcstombs( (char *) fname, fnameW, wcslen(fnameW)
                  + sizeof(char));
        lname = (SQLCHAR *) malloc (wcslen(lnameW) +  sizeof(char));
        wcstombs( (char *) lname, lnameW, wcslen(lnameW)
                  + sizeof(char));
        fprintf(stdout, "Retrieving row number %d:\n\tfname -- %s\n\tlname -- %s\n\tRow/Collection Data --\n", rownum, fname, lname);


        /*  For each row in the result set, display each field of the
            retrieved row/collection */
        for (index = 1;; index++)
        {
            wcscpy((SQLWCHAR *) rc_dataW, L"<null>");

            /* Each value in the local row/collection will be fetched into a
             * character buffer and displayed using fprintf().
             */
            rc = SQLBindParameter (hRCStmt, 1, SQL_PARAM_OUTPUT, SQL_C_WCHAR,
                                   SQL_CHAR, 0, 0, rc_dataW, BUFFER_LENW, &cbRCData);
            if (checkError (rc, SQL_HANDLE_STMT, hRCStmt, (SQLCHAR *) "Error in Step C -- SQLBindParameter failed (param 1)\n"))
                return 0;

            rc = SQLBindParameter (hRCStmt, 2, SQL_PARAM_INPUT, SQL_C_BINARY,
                                   SQL_INFX_RC_COLLECTION, sizeof(HINFX_RC), 0, hrc,
                                   sizeof(HINFX_RC), &cbHrc);
            if (checkError (rc, SQL_HANDLE_STMT, hRCStmt, (SQLCHAR *) "Error in Step C -- SQLBindParameter failed (param 2)\n"))
                return 0;

            rc = SQLBindParameter (hRCStmt, 3, SQL_PARAM_INPUT, SQL_C_SHORT,
                                   SQL_SMALLINT, 0, 0, &position, 0, &cbPosition);
            if (checkError (rc, SQL_HANDLE_STMT, hRCStmt, (SQLCHAR *) "Error in Step C -- SQLBindParameter failed (param 3)\n"))
                return 0;


            jump = index;
            rc = SQLBindParameter (hRCStmt, 4, SQL_PARAM_INPUT, SQL_C_SHORT,
                                   SQL_SMALLINT, 0, 0, &jump, 0, &cbJump);
            if (checkError (rc, SQL_HANDLE_STMT, hRCStmt, (SQLCHAR *) "Error in Step C -- SQLBindParameter failed (param 4)\n"))
                return 0;


            rc = SQLExecDirectW (hRCStmt, (SQLWCHAR *) L"{ ? = call ifx_rc_fetch( ?, ?, ? ) }", SQL_NTS);
            if (rc == SQL_NO_DATA_FOUND)
            {
                break;
            }
            else if (checkError (rc, SQL_HANDLE_STMT, hRCStmt, (SQLCHAR *) "Error in Step C -- SQLExecDirect failed\n"))
                return 0;

            /* Display retrieved row */
            rc_data = (SQLCHAR *) malloc (wcslen(rc_dataW) + sizeof(char));
            wcstombs( (char *) rc_data, rc_dataW, wcslen(rc_dataW)
                      + sizeof(char));
            fprintf(stdout, "\t\t%d: %s\n", index, rc_data);
        }
    }


    fprintf (stdout, "STEP C done...results retrieved\n");



    /* Free the statement handles */
    SQLFreeHandle (SQL_HANDLE_STMT, hSelectStmt);
    SQLFreeHandle (SQL_HANDLE_STMT, hRCStmt);

    return 1; /* no error */
}


/*
 * This function allocates the row and collection buffers, passes
 * them to the do_select() function, along with an appropriate select
 * statement and then frees all allocated handles.
 */
int main (long argc,
          char* argv[])
{
    /* Declare variables
    */

    /* Handles */
    SQLHDBC         hdbc;
    SQLHENV         henv;
    SQLHSTMT        hstmt;
    HINFX_RC	    hrow, hlist;

    /* Miscellaneous variables */

    SQLWCHAR         *dsnW;   /*name of the DSN used for connecting to the database*/
    SQLRETURN       rc = 0;
    SQLINTEGER      in;

    SQLWCHAR         verInfoBufferW[BUFFER_LENW];
    SQLSMALLINT		verInfoLen;

    SQLLEN    		data_size = SQL_NTS;
    SQLWCHAR*		listSelectStmtW = (SQLWCHAR *) L"SELECT fname, lname, contact_dates FROM customer";
    SQLWCHAR*		rowSelectStmtW = (SQLWCHAR *) L"SELECT fname, lname, address FROM customer";

    SQLLEN          cbHlist = 0, cbHrow = 0;
    int          lenArgv1;



    /*  STEP 1. Get data source name from command line (or use default)
    **          Allocate environment handle and set ODBC version
    **          Allocate connection handle
    **          Establish the database connection
    **          Get version information from the database server
    **          -- if version < 9.x (not UDO enabled), exit with error message
    **          Allocate the statement handle
    */


    /* If(dsn is not explicitly passed in as arg) */
    if (argc != 2)
    {
        /* Use default dsnW - odbc_demo */
        fprintf (stdout, "\nUsing default DSN : %s\n", defDsn);
        dsnW = (SQLWCHAR *) malloc( wcslen(defDsnW) * sizeof(SQLWCHAR)
                                    + sizeof(SQLWCHAR) );
        wcscpy ((SQLWCHAR *)dsnW, (SQLWCHAR *)defDsnW);
    }
    else
    {
        /* Use specified dsnW */
        lenArgv1 = strlen((char *)argv[1]);
        dsnW = (SQLWCHAR *) malloc (lenArgv1 * sizeof(SQLWCHAR)
                                    + sizeof(SQLWCHAR));
        mbstowcs (dsnW, (char *)argv[1], lenArgv1 + sizeof(char));
        fprintf (stdout, "\nUsing specified DSN : %s\n", argv[1]);
    }


    /* Allocate the Environment handle */
    rc = SQLAllocHandle (SQL_HANDLE_ENV, SQL_NULL_HANDLE, &henv);
    if (rc != SQL_SUCCESS)
    {
        fprintf (stdout, "Environment Handle Allocation failed\nExiting!!\n");
        return (1);
    }


    /* Set the ODBC version to 3.0 */
    rc = SQLSetEnvAttr (henv, SQL_ATTR_ODBC_VERSION, (SQLPOINTER) SQL_OV_ODBC3, 0);
    if (checkError (rc, SQL_HANDLE_ENV, henv, (SQLCHAR *) "Error in Step 1 -- SQLSetEnvAttr failed\nExiting!!\n"))
        return (1);


    /* Allocate the connection handle */
    rc = SQLAllocHandle (SQL_HANDLE_DBC, henv, &hdbc);
    if (checkError (rc, SQL_HANDLE_ENV, henv, (SQLCHAR *) "Error in Step 1 -- Connection Handle Allocation failed\nExiting!!\n"))
        return (1);


    /* Establish the database connection */
    rc = SQLConnectW (hdbc, dsnW, SQL_NTS, (SQLWCHAR *) L"", SQL_NTS, (SQLWCHAR *) L"", SQL_NTS);
    if (checkError (rc, SQL_HANDLE_DBC, hdbc, (SQLCHAR *) "Error in Step 1 -- SQLConnect failed\n"))
        return (1);


    /* Get version information from the database server
       If version < 9.x (not UDO enabled), exit with error message */

    rc = SQLGetInfoW (hdbc, SQL_DBMS_VER, verInfoBufferW, BUFFER_LENW, &verInfoLen);
    if (checkError (rc, SQL_HANDLE_DBC, hdbc, (SQLCHAR *) "Error in Step 1 -- SQLGetInfo failed\n"))
        return 1;

    if ((wcsncmp ((SQLWCHAR *) verInfoBufferW, L"09", 2)) < 0 )
    {
        fprintf (stdout, "\n** This test can only be run against UDO-enabled database server -- version 9 or higher **\n");
        return 1;
    }


    /* Allocate the statement handle */
    rc = SQLAllocHandle (SQL_HANDLE_STMT, hdbc, &hstmt );
    if (checkError (rc, SQL_HANDLE_DBC, hdbc, (SQLCHAR *) "Error in Step 1 -- Statement Handle Allocation failed\nExiting!!\n"))
        return (1);



    fprintf (stdout, "STEP 1 done...connected to database\n");




    /* STEP 2.  Allocate an unfixed collection handle
    **          Retrieve database rows containing a list
    **          Reset the statement parameters
    */

    /* Allocate an unfixed list handle */
    rc = SQLBindParameter (hstmt, 1, SQL_PARAM_OUTPUT, SQL_C_BINARY,
                           SQL_INFX_RC_LIST, sizeof(HINFX_RC), 0,
                           &hlist, sizeof(HINFX_RC), &cbHlist);
    if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 2 -- SQLBindParameter (param 1) failed\n"))
        goto Exit;

    rc = SQLBindParameter (hstmt, 2, SQL_PARAM_INPUT, SQL_C_CHAR,
                           SQL_CHAR, 0, 0, (char *) "list", 0, &data_size);
    if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 2 -- SQLBindParameter (param 2) failed\n"))
        goto Exit;


    rc = SQLExecDirectW (hstmt, (SQLWCHAR *) L"{? = call ifx_rc_create(?)}", SQL_NTS);
    if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 2 -- SQLExecDirect failed\n"))
        goto Exit;


    /* Retrieve databse rows containing a list */
    if (!do_select (hdbc, listSelectStmtW, hlist))
        goto Exit;


    /* Reset the statement parameters */
    rc = SQLFreeStmt (hstmt, SQL_RESET_PARAMS);
    if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 2 -- SQLFreeStmt failed\n"))
        goto Exit;


    fprintf (stdout, "STEP 2 done...list data retrieved\n");
    fprintf (stdout,"\nHit <Enter> to continue...");
    in = getchar ();




    /* STEP 3.  Allocate an unfixed row handle
    **          Retrieve database rows containing a row
    **          Reset the statement parameters
    */

    /* Allocate an unfixed row handle */
    rc = SQLBindParameter (hstmt, 1, SQL_PARAM_OUTPUT, SQL_C_BINARY,
                           SQL_INFX_RC_ROW, sizeof(HINFX_RC), 0,
                           &hrow, sizeof(HINFX_RC), &cbHrow);
    if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 3 -- SQLBindParameter (param 1) failed\n"))
        goto Exit;

    rc = SQLBindParameter (hstmt, 2, SQL_PARAM_INPUT, SQL_C_CHAR,
                           SQL_CHAR, 0, 0, (SQLCHAR *) "row", 0, &data_size);
    if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 3 -- SQLBindParameter (param 2) failed\n"))
        goto Exit;


    rc = SQLExecDirectW (hstmt, (SQLWCHAR *) L"{? = call ifx_rc_create(?)}", SQL_NTS);
    if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 3 -- SQLExecDirect failed\n"))
        goto Exit;


    /* Retrieve databse rows containing a row */
    if (!do_select (hdbc, rowSelectStmtW, hrow))
        goto Exit;


    /* Reset the statement parameters */
    rc = SQLFreeStmt (hstmt, SQL_RESET_PARAMS);
    if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 3 -- SQLFreeStmt failed\n"))
        goto Exit;


    fprintf (stdout, "STEP 3 done...row data retrieved\n");




    /* STEP 4.  Free the row and list handles
    */

    /* Free the row handle */
    rc = SQLBindParameter(hstmt, 1, SQL_PARAM_INPUT, SQL_C_BINARY,
                          SQL_INFX_RC_ROW, sizeof(HINFX_RC), 0, hrow,
                          sizeof(HINFX_RC), &cbHrow);

    rc = SQLExecDirectW (hstmt, (SQLWCHAR *)L"{call ifx_rc_free(?)}", SQL_NTS);

    /* Free the list handle */
    rc = SQLBindParameter(hstmt, 1, SQL_PARAM_INPUT, SQL_C_BINARY,
                          SQL_INFX_RC_LIST, sizeof(HINFX_RC), 0, hlist,
                          sizeof(HINFX_RC), &cbHlist);

    rc = SQLExecDirectW (hstmt, (SQLWCHAR *)L"{call ifx_rc_free(?)}", SQL_NTS);


    fprintf (stdout, "STEP 4 done...row and list handles freed\n");




Exit:

    /* CLEANUP: Close the statement handle
    **          Free the statement handle
    **          Disconnect from the datasource
    **          Free the connection and environment handles
    **          Exit
    */

    /* Close the statement handle */
    SQLFreeStmt (hstmt, SQL_CLOSE);

    /* Free the statement handle */
    SQLFreeHandle (SQL_HANDLE_STMT, hstmt);

    /* Disconnect from the data source */
    SQLDisconnect (hdbc);

    /* Free the environment handle and the database connection handle */
    SQLFreeHandle (SQL_HANDLE_DBC, hdbc);
    SQLFreeHandle (SQL_HANDLE_ENV, henv);

    fprintf (stdout,"\n\nHit <Enter> to terminate the program...\n\n");
    in = getchar ();
    return (rc);
}
