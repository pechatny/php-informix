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
*  Title:          rcupdateW.c (Unicode counterpart of rcupdate.c)
*
*  Description:    To update a row and collection column
*                  To update the row, we update one of the elements of
*                  the row and then update the entire row on the database
*                  To update the list, we add an element to the list and
*                  then update the list on the database
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

#define BUFFER_SIZEW    120
#define ERRMSG_LEN      200

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


int main (long         argc,
          char*        argv[] )
{
    /* Declare variables
    */

    /* Handles */
    SQLHDBC		    hdbc;
    SQLHENV		    henv;
    SQLHSTMT        hstmt;

    HINFX_RC        hrow;
    HINFX_RC        hlist;

    /* Miscellaneous variables */
    SQLWCHAR         *dsnW;   /*name of the DSN used for connecting to the database*/
    SQLRETURN       rc = 0;
    SQLINTEGER      in;

    SQLWCHAR         verInfoBufferW[BUFFER_SIZEW];
    SQLSMALLINT		verInfoLen;

    SQLLEN    		data_size = SQL_NTS;
    SQLSMALLINT		position, jump;
    SQLLEN          cbHrow = 0, cbHlist = 0, cbPosition = 0, cbJump = 0;

    SQLWCHAR         new_addressW[BUFFER_SIZEW] = L"295 Holly Street";
    SQLLEN          new_address_size = SQL_NTS;

    SQLWCHAR         new_dateW[BUFFER_SIZEW] = L"1995-11-26";
    SQLLEN          new_date_size = SQL_NTS;

    SQLWCHAR*		selectStmtW = (SQLWCHAR *) L"SELECT address, contact_dates FROM customer WHERE cust_num = 109";
    SQLWCHAR*		updateStmtW = (SQLWCHAR *) L"UPDATE customer SET address = ?, contact_dates = ? WHERE cust_num = 109";
    int lenArgv1;



    /*  STEP 1. Get data source name from command line (or use default)
    **          Allocate environment handle and set ODBC version
    **          Allocate connection handle
    **          Establish the database connection
    **          Get version information from the database server
    **          -- if version < 9.x (not UDO enabled), exit with error message
    **          Allocate the statement handle
    */


    /* If(dsnW is not explicitly passed in as arg) */
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

    rc = SQLGetInfoW (hdbc, SQL_DBMS_VER, verInfoBufferW, BUFFER_SIZEW, &verInfoLen);
    if (checkError (rc, SQL_HANDLE_DBC, hdbc, (SQLCHAR *) "Error in Step 1 -- SQLGetInfo failed\n"))
        return 1;

    if ((wcsncmp ((SQLWCHAR *) verInfoBufferW, L"09", 2)) < 0)
    {
        fprintf (stdout, "\n** This test can only be run against UDO-enabled database server -- version 9 or higher **\n");
        return 1;
    }

    /* Allocate the statement handle */
    rc = SQLAllocHandle (SQL_HANDLE_STMT, hdbc, &hstmt );
    if (checkError (rc, SQL_HANDLE_DBC, hdbc, (SQLCHAR *) "Error in Step 1 -- Statement Handle Allocation failed\nExiting!!\n"))
        return (1);



    fprintf (stdout, "STEP 1 done...connected to database\n");




    /* STEP 2.  Allocate an unfixed row handle
    **          Allocate an unfixed collection (list) handle
    **          Reset the statement parameters
    */

    /* Allocate an unfixed row handle */
    rc = SQLBindParameter (hstmt, 1, SQL_PARAM_OUTPUT, SQL_C_BINARY,
                           SQL_INFX_RC_ROW, sizeof(HINFX_RC), 0,
                           &hrow, sizeof(HINFX_RC), &cbHrow);
    if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 2 -- SQLBindParameter (param 1) failed\n"))
        goto Exit;

    rc = SQLBindParameter (hstmt, 2, SQL_PARAM_INPUT, SQL_C_CHAR,
                           SQL_CHAR, 0, 0, "row", 0, &data_size);
    if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 2 -- SQLBindParameter (param 2) failed\n"))
        goto Exit;

    rc = SQLExecDirectW (hstmt, (SQLWCHAR *) L"{? = call ifx_rc_create(?)}", SQL_NTS);
    if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 2 -- SQLExecDirect failed\n"))
        goto Exit;


    /* Reset the statement parameters */
    rc = SQLFreeStmt (hstmt, SQL_RESET_PARAMS);
    if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 2 -- SQLFreeStmt failed\n"))
        goto Exit;


    /* Allocate an unfixed list handle */
    rc = SQLBindParameter (hstmt, 1, SQL_PARAM_OUTPUT, SQL_C_BINARY,
                           SQL_INFX_RC_LIST, sizeof(HINFX_RC), 0,
                           &hlist, sizeof(HINFX_RC), &cbHlist);
    if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 2 -- SQLBindParameter (param 1) failed\n"))
        goto Exit;

    rc = SQLBindParameter (hstmt, 2, SQL_PARAM_INPUT, SQL_C_CHAR,
                           SQL_CHAR, 0, 0, "list", 0, &data_size);
    if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 2 -- SQLBindParameter (param 2) failed\n"))
        goto Exit;

    rc = SQLExecDirectW (hstmt, (SQLWCHAR *) L"{? = call ifx_rc_create(?)}", SQL_NTS);
    if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 2 -- SQLExecDirect failed\n"))
        goto Exit;

    /* Reset the statement parameters */
    rc = SQLFreeStmt (hstmt, SQL_RESET_PARAMS);
    if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 2 -- SQLFreeStmt failed\n"))
        goto Exit;


    fprintf (stdout, "STEP 2 done...unfixed row and list handles allocated\n");




    /* STEP 3.  Bind the result set columns for the row and list handle
    **          Retrieve the row data from the database into the buffer allocated
    **          Reset the statement parameters
    */

    /* Bind result set columns for the row and list handle */
    rc = SQLBindCol (hstmt, 1, SQL_C_BINARY, hrow, sizeof(HINFX_RC), NULL);
    if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 3 -- SQLBindCol failed\n"))
        goto Exit;

    rc = SQLBindCol (hstmt, 2, SQL_C_BINARY, hlist, sizeof(HINFX_RC), NULL);
    if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 3 -- SQLBindCol failed\n"))
        goto Exit;

    /* Retrieve the row data from the database into the buffer allocated */
    rc = SQLExecDirectW (hstmt, selectStmtW, SQL_NTS);
    if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 3 -- SQLExecDirect failed\n"))
        goto Exit;

    rc = SQLFetch (hstmt);
    if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 3 -- SQLFetch failed\n"))
        goto Exit;

    /* Close the result set cursor */
    rc = SQLCloseCursor (hstmt);
    if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 3 -- SQLCloseCursor failed\n"))
        goto Exit;



    fprintf (stdout, "STEP 3 done...data retrieved from database into row buffer\n");




    /*  STEP 4. Update the elements of the row buffer allocated
    **          --  the element of the row being updated is element
    **              no. 1 - 'address1'
    **          Reset the statement parameters
    */


    position = SQL_INFX_RC_ABSOLUTE;
    jump = 1;

    rc = SQLBindParameter(hstmt, 1, SQL_PARAM_INPUT, SQL_C_BINARY,
                          SQL_INFX_RC_ROW, sizeof(HINFX_RC), 0, hrow,
                          sizeof(HINFX_RC), &cbHrow);
    if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 4 -- SQLBindParameter failed (param 1)\n"))
        goto Exit;

    rc = SQLBindParameter(hstmt, 2, SQL_PARAM_INPUT, SQL_C_WCHAR,
                          SQL_CHAR, BUFFER_SIZEW, 0, new_addressW, 0, &new_address_size);
    if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 4 -- SQLBindParameter failed (param 1)\n"))
        goto Exit;

    rc = SQLBindParameter(hstmt, 3, SQL_PARAM_INPUT, SQL_C_SHORT,
                          SQL_SMALLINT, 0, 0, &position, 0, &cbPosition);
    if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 4 -- SQLBindParameter failed (param 1)\n"))
        goto Exit;

    rc = SQLBindParameter(hstmt, 4, SQL_PARAM_INPUT, SQL_C_SHORT,
                          SQL_SMALLINT, 0, 0, &jump, 0, &cbJump);
    if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 4 -- SQLBindParameter failed (param 1)\n"))
        goto Exit;

    rc = SQLExecDirectW (hstmt, (SQLWCHAR *) L"{call ifx_rc_update(?, ?, ?, ?)}", SQL_NTS);
    if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 4 -- SQLExecDirect failed\n"))
        goto Exit;


    fprintf (stdout, "STEP 4 done...row element updated\n");




    /*  STEP 5. Insert a new element into the list buffer allocated
    **          Reset the statement parameters
    */


    position = SQL_INFX_RC_LAST;
    jump = 0;

    rc = SQLBindParameter(hstmt, 1, SQL_PARAM_INPUT, SQL_C_BINARY,
                          SQL_INFX_RC_LIST, sizeof(HINFX_RC), 0, hlist,
                          sizeof(HINFX_RC), &cbHlist);
    if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 5 -- SQLBindParameter failed (param 1)\n"))
        goto Exit;

    rc = SQLBindParameter(hstmt, 2, SQL_PARAM_INPUT, SQL_C_WCHAR,
                          SQL_CHAR, BUFFER_SIZEW, 0, new_dateW, 0, &new_date_size);
    if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 5 -- SQLBindParameter failed (param 1)\n"))
        goto Exit;

    rc = SQLBindParameter(hstmt, 3, SQL_PARAM_INPUT, SQL_C_SHORT,
                          SQL_SMALLINT, 0, 0, &position, 0, &cbPosition);
    if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 5 -- SQLBindParameter failed (param 1)\n"))
        goto Exit;

    rc = SQLBindParameter(hstmt, 4, SQL_PARAM_INPUT, SQL_C_SHORT,
                          SQL_SMALLINT, 0, 0, &jump, 0, &cbJump);
    if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 5 -- SQLBindParameter failed (param 1)\n"))
        goto Exit;

    rc = SQLExecDirectW (hstmt, (SQLWCHAR *) L"{call ifx_rc_insert(?, ?, ?, ?)}", SQL_NTS);
    if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 5 -- SQLExecDirect failed\n"))
        goto Exit;


    fprintf (stdout, "STEP 5 done...list element updated\n");




    /* STEP 6.  Update the database with the new row data
    */

    /* Update the database with the new row and list data */
    rc = SQLBindParameter (hstmt, 1, SQL_PARAM_INPUT, SQL_C_BINARY,
                           SQL_INFX_RC_ROW, sizeof(HINFX_RC), 0, hrow,
                           sizeof(HINFX_RC), &cbHrow);
    if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 6 -- SQLBindParameter failed\n"))
        goto Exit;

    rc = SQLBindParameter (hstmt, 2, SQL_PARAM_INPUT, SQL_C_BINARY,
                           SQL_INFX_RC_LIST, sizeof(HINFX_RC), 0, hlist,
                           sizeof(HINFX_RC), &cbHlist);
    if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 6 -- SQLBindParameter failed\n"))
        goto Exit;


    rc = SQLExecDirectW (hstmt, updateStmtW, SQL_NTS);
    if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 6 -- SQLExecDirect failed\n"))
        goto Exit;



    fprintf (stdout, "STEP 6 done...database row updated\n");



    /*  STEP 7. Free the row and list handles
    */

    /* Free the row handle */
    rc = SQLBindParameter(hstmt, 1, SQL_PARAM_INPUT, SQL_C_BINARY,
                          SQL_INFX_RC_ROW, sizeof(HINFX_RC), 0, hrow,
                          sizeof(HINFX_RC), &cbHrow);

    rc = SQLExecDirectW (hstmt, (SQLWCHAR *) L"{call ifx_rc_free(?)}", SQL_NTS);

    /* Free the list handle */
    rc = SQLBindParameter(hstmt, 1, SQL_PARAM_INPUT, SQL_C_BINARY,
                          SQL_INFX_RC_LIST, sizeof(HINFX_RC), 0, hlist,
                          sizeof(HINFX_RC), &cbHlist);

    rc = SQLExecDirectW (hstmt, (SQLWCHAR *) L"{call ifx_rc_free(?)}", SQL_NTS);


    fprintf (stdout, "STEP 7 done...row and list handles freed\n");




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
