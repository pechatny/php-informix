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
*  Title:          rccreate.c
*
*  Description:    To create a row and a list on the client, add items
*                  to them and insert them into the database
*                  The columns created are
*                  -- column 'address' of table 'customer' (datatype - ROW)
*                  -- column 'contact_dates' of table 'customer'
*                     (datatype - LIST)
*
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

#define BUFFER_LEN     25
#define ERRMSG_LEN     200

SQLCHAR   defDsn[] = "odbc_demo";


SQLINTEGER checkError (SQLRETURN       rc,
                       SQLSMALLINT     handleType,
                       SQLHANDLE       handle,
                       SQLCHAR*            errmsg)
{
    SQLRETURN         retcode = SQL_SUCCESS;

    SQLSMALLINT     errNum = 1;
    SQLCHAR		    sqlState[6];
    SQLINTEGER      nativeError;
    SQLCHAR		    errMsg[ERRMSG_LEN];
    SQLSMALLINT     textLengthPtr;


    if ((rc != SQL_SUCCESS) && (rc != SQL_SUCCESS_WITH_INFO))
    {
        while (retcode != SQL_NO_DATA)
        {
            retcode = SQLGetDiagRec (handleType, handle, errNum, sqlState, &nativeError, errMsg, ERRMSG_LEN, &textLengthPtr);

            if (retcode == SQL_INVALID_HANDLE)
            {
                fprintf (stderr, "checkError function was called with an invalid handle!!\n");
                return 1;
            }

            if ((retcode == SQL_SUCCESS) || (retcode == SQL_SUCCESS_WITH_INFO))
                fprintf (stderr, "ERROR: %d:  %s : %s \n", nativeError, sqlState, errMsg);

            errNum++;
        }

        fprintf (stderr, "%s\n", errmsg);
        return 1;   /* all errors on this handle have been reported */
    }
    else
        return 0;	/* no errors to report */
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
    HINFX_RC	    hlist;

    /* Miscellaneous variables */
    SQLCHAR         dsn[20];   /*name of the DSN used for connecting to the database*/
    SQLRETURN       rc = 0;
    SQLINTEGER      i, in;

    SQLCHAR         verInfoBuffer[BUFFER_LEN];
    SQLSMALLINT		verInfoLen;

    SQLLEN		data_size = SQL_NTS;
    SQLSMALLINT		position = SQL_INFX_RC_ABSOLUTE;
    SQLSMALLINT     jump;

    SQLCHAR         row_data[4][BUFFER_LEN] = {"520 Topaz Way", "Redwood City", "CA", "94062"};
    SQLLEN      row_data_size = SQL_NTS;

    SQLCHAR		    list_data[2][BUFFER_LEN] = {"1991-06-20", "1993-07-17"};
    SQLLEN		list_data_size = SQL_NTS;

    SQLCHAR*		insertStmt = (SQLCHAR *) "INSERT INTO customer VALUES (110, 'Roy', 'Jaeger', ?, ?)";
    SQLLEN	    cbHrow = 0, cbHlist = 0, cbPosition = 0, cbJump = 0;



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
        /* Use default dsn - odbc_demo */
        fprintf (stdout, "\nUsing default DSN : %s\n", defDsn);
        strcpy ((char *)dsn, (char *)defDsn);
    }
    else
    {
        /* Use specified dsn */
        strcpy ((char *)dsn, (char *)argv[1]);
        fprintf (stdout, "\nUsing specified DSN : %s\n", dsn);
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
    rc = SQLConnect (hdbc, dsn, SQL_NTS, (SQLCHAR *) "", SQL_NTS, (SQLCHAR *) "", SQL_NTS);
    if (checkError (rc, SQL_HANDLE_DBC, hdbc, (SQLCHAR *) "Error in Step 1 -- SQLConnect failed\n"))
        return (1);


    /* Get version information from the database server
       If version < 9.x (not UDO enabled), exit with error message */

    rc = SQLGetInfo (hdbc, SQL_DBMS_VER, verInfoBuffer, BUFFER_LEN, &verInfoLen);
    if (checkError (rc, SQL_HANDLE_DBC, hdbc, (SQLCHAR *) "Error in Step 1 -- SQLGetInfo failed\n"))
        return 1;

    if ((strncmp ((char *) verInfoBuffer, "09", 2)) < 0 )
    {
        fprintf (stdout, "\n** This test can only be run against UDO-enabled database server -- version 9 or higher **\n");
        return 1;
    }


    /* Allocate the statement handle */
    rc = SQLAllocHandle (SQL_HANDLE_STMT, hdbc, &hstmt );
    if (checkError (rc, SQL_HANDLE_DBC, hdbc, (SQLCHAR *) "Error in Step 1 -- Statement Handle Allocation failed\nExiting!!\n"))
        return (1);



    fprintf (stdout, "STEP 1 done...connected to database\n");




    /*  STEP 2. Allocate fixed-type row handle -- this creates a non-null row
    **          buffer, each of whose values is null, and can be updated.
    **          Allocate a fixed-type list handle -- this creates a non-null
    **          but empty list buffer into which values can be inserted.
    **          Reset the statement parameters
    */


    /* Allocate a fixed-type row handle -- this creates a row with each value empty */
    rc = SQLBindParameter (hstmt, 1, SQL_PARAM_OUTPUT, SQL_C_BINARY,
                           SQL_INFX_RC_ROW, sizeof(HINFX_RC), 0,
                           &hrow, sizeof(HINFX_RC), &cbHrow);
    if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 2 -- SQLBindParameter (param 1) failed for row handle\n"))
        goto Exit;

    rc = SQLBindParameter (hstmt, 2, SQL_PARAM_INPUT, SQL_C_CHAR,
                           SQL_CHAR, 0, 0, (SQLCHAR *) "ROW(address1 VARCHAR(25), city VARCHAR(15),\
                                             state    VARCHAR(15), zip  VARCHAR(5))", 0, &data_size);
    if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 2 -- SQLBindParameter (param 2) failed for row handle\n"))
        goto Exit;

    rc = SQLExecDirect (hstmt, (SQLCHAR *) "{? = call ifx_rc_create(?)}", SQL_NTS);
    if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 2 -- SQLExecDirect failed for row handle\n"))
        goto Exit;


    /* Allocate a fixed-type list handle */
    rc = SQLBindParameter (hstmt, 1, SQL_PARAM_OUTPUT, SQL_C_BINARY,
                           SQL_INFX_RC_LIST, sizeof(HINFX_RC), 0,
                           &hlist, sizeof(HINFX_RC), &cbHlist);
    if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 2 -- SQLBindParameter (param 1) failed for list handle\n"))
        goto Exit;

    data_size = SQL_NTS;
    rc = SQLBindParameter (hstmt, 2, SQL_PARAM_INPUT, SQL_C_CHAR,
                           SQL_CHAR, 0, 0, (SQLCHAR *) "LIST (DATETIME YEAR TO DAY NOT NULL)", 0, &data_size);
    if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 2 -- SQLBindParameter (param 2) failed for list handle\n"))
        goto Exit;

    rc = SQLExecDirect (hstmt, (SQLCHAR *) "{? = call ifx_rc_create(?)}", SQL_NTS);
    if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 2 -- SQLExecDirect failed for list handle\n"))
        goto Exit;

    /* Reset the statement parameters */
    rc = SQLFreeStmt (hstmt, SQL_RESET_PARAMS);
    if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 2 -- SQLFreeStmt failed\n"))
        goto Exit;



    fprintf (stdout, "STEP 2 done...fixed-type row and collection handles allocated\n");



    /*  STEP 3. Update the elements of the fixed-type row buffer allocated
    **          Insert elements into the fixed-type list buffer allocated
    **          Reset the statement parameters
    */


    /* Update elements of the row buffer */
    for (i=0; i<4; i++)
    {
        rc = SQLBindParameter (hstmt, 1, SQL_PARAM_INPUT, SQL_C_BINARY,
                               SQL_INFX_RC_ROW, sizeof(HINFX_RC), 0, hrow,
                               sizeof(HINFX_RC), &cbHrow);
        if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 3 -- SQLBindParameter (param 1) failed for row handle\n"))
            goto Exit;

        rc = SQLBindParameter (hstmt, 2, SQL_PARAM_INPUT, SQL_C_CHAR,
                               SQL_CHAR, BUFFER_LEN, 0, row_data[i], 0, &row_data_size);
        if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 3 -- SQLBindParameter (param 2) failed for row handle\n"))
            goto Exit;

        rc = SQLBindParameter (hstmt, 3, SQL_PARAM_INPUT, SQL_C_SHORT,
                               SQL_SMALLINT, 0, 0, &position, 0, &cbPosition);
        if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 3 -- SQLBindParameter (param 3) failed for row handle\n"))
            goto Exit;

        jump = i + 1;
        rc = SQLBindParameter (hstmt, 4, SQL_PARAM_INPUT, SQL_C_SHORT,
                               SQL_SMALLINT, 0, 0, &jump, 0, &cbJump);
        if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 3 -- SQLBindParameter (param 4) failed for row handle\n"))
            goto Exit;

        rc = SQLExecDirect (hstmt, (SQLCHAR *)"{call ifx_rc_update(?, ?, ?, ?)}", SQL_NTS);
        if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 3 -- SQLExecDirect failed for row handle\n"))
            goto Exit;
    }


    /* Insert elements into the list buffer */
    for (i=0; i<2; i++)
    {
        rc = SQLBindParameter (hstmt, 1, SQL_PARAM_INPUT, SQL_C_BINARY,
                               SQL_INFX_RC_LIST, sizeof(HINFX_RC), 0, hlist,
                               sizeof(HINFX_RC), &cbHlist);
        if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 3 -- SQLBindParameter (param 1) failed for list handle\n"))
            goto Exit;

        rc = SQLBindParameter (hstmt, 2, SQL_PARAM_INPUT, SQL_C_CHAR,
                               SQL_DATE, 25, 0, list_data[i], 0, &list_data_size);
        if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 3 -- SQLBindParameter (param 2) failed for list handle\n"))
            goto Exit;

        rc = SQLBindParameter (hstmt, 3, SQL_PARAM_INPUT, SQL_C_SHORT,
                               SQL_SMALLINT, 0, 0, &position, 0, &cbPosition);
        if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 3 -- SQLBindParameter (param 3) failed for list handle\n"))
            goto Exit;

        jump = i + 1;
        rc = SQLBindParameter (hstmt, 4, SQL_PARAM_INPUT, SQL_C_SHORT,
                               SQL_SMALLINT, 0, 0, &jump, 0, &cbJump);
        if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 3 -- SQLBindParameter (param 4) failed for list handle\n"))
            goto Exit;

        rc = SQLExecDirect (hstmt, (SQLCHAR *)"{call ifx_rc_insert( ?, ?, ?, ? )}", SQL_NTS);
        if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 3 -- SQLExecDirect failed for list handle\n"))
            goto Exit;
    }


    /* Reset the statement parameters */
    rc = SQLFreeStmt (hstmt, SQL_RESET_PARAMS);
    if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 3 -- SQLFreeStmt failed\n"))
        goto Exit;



    fprintf (stdout, "STEP 3 done...row and list buffers populated\n");




    /* STEP 4.  Bind paramters for the row and list handles
    **          Execute the insert statement to insert the new row
    **          into table 'customer'
    */

    rc = SQLBindParameter (hstmt, 1, SQL_PARAM_INPUT, SQL_C_BINARY,
                           SQL_INFX_RC_COLLECTION, sizeof(HINFX_RC), 0, hrow,
                           sizeof(HINFX_RC), &cbHrow);
    if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 4 -- SQLBindParameter failed (param 1)\n"))
        goto Exit;

    rc = SQLBindParameter (hstmt, 2, SQL_PARAM_INPUT, SQL_C_BINARY,
                           SQL_INFX_RC_COLLECTION, sizeof(HINFX_RC), 0, hlist,
                           sizeof(HINFX_RC), &cbHlist);
    if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 4 -- SQLBindParameter failed (param 2)\n"))
        goto Exit;

    rc = SQLExecDirect (hstmt, insertStmt, SQL_NTS);
    if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 4 -- SQLExecDirect failed\n"))
        goto Exit;


    fprintf (stdout, "STEP 4 done...new row inserted into table 'customer'\n");




    /*  STEP 5. Free the row and list handles
    */

    /* Free the row handle */
    rc = SQLBindParameter (hstmt, 1, SQL_PARAM_INPUT, SQL_C_BINARY,
                           SQL_INFX_RC_ROW, sizeof(HINFX_RC), 0, hrow,
                           sizeof(HINFX_RC), &cbHrow);

    rc = SQLExecDirect(hstmt, (SQLCHAR *)"{call ifx_rc_free(?)}", SQL_NTS);

    /* Free the list handle */
    rc = SQLBindParameter (hstmt, 1, SQL_PARAM_INPUT, SQL_C_BINARY,
                           SQL_INFX_RC_LIST, sizeof(HINFX_RC), 0, hlist,
                           sizeof(HINFX_RC), &cbHlist);

    rc = SQLExecDirect(hstmt, (SQLCHAR *)"{call ifx_rc_free(?)}", SQL_NTS);


    fprintf (stdout, "STEP 5 done...row and list handles freed\n");




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
