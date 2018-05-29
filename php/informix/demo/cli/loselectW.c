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
*  Title:          loselectW.c (Unicode counterpart of loselect.c)
*
*  Description:    To retrieve a smart large object stored in the database
*                  --  the column retrieved is the 'advert' column of the
*                      table 'item' (datatype - CLOB)
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

#define BUFFER_LENW 120
#define ERRMSG_LEN  200

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
          char*        argv[])
{
    /* Declare variables
    */

    /* Handles */
    SQLHDBC		    hdbc;
    SQLHENV		    henv;
    SQLHSTMT        hstmt;

    /* Smart large object file descriptor */
    SQLINTEGER		lofd;
    SQLLEN    		lofd_valsize = 0;

    /* Smart large object pointer structure */
    SQLWCHAR*		loptr_bufferW;
    SQLSMALLINT		loptr_size;
    SQLLEN    		loptr_valsize = 0;

    /* Smart large object status structure */
    SQLWCHAR*		lostat_bufferW;
    SQLSMALLINT		lostat_size;
    SQLLEN    		lostat_valsize = 0;

    /* Smart large object data */
    SQLCHAR*		lo_data;
    SQLLEN    		lo_data_valsize = 0;

    /* Miscellaneous variables */
    SQLWCHAR		    *dsnW; /*name of the DSN used for connecting to the database*/
    SQLRETURN	    rc = 0;
    SQLINTEGER		in;

    SQLWCHAR         verInfoBufferW[BUFFER_LENW];
    SQLSMALLINT		verInfoLen;

    SQLWCHAR*        selectStmtW = (SQLWCHAR *) L"SELECT advert FROM item WHERE item_num = 1004";
    SQLINTEGER		mode = LO_RDONLY;
    SQLINTEGER		lo_size;
    SQLLEN    		cbMode = 0, cbLoSize = 0;
    int            lenArgv1;





    /*  STEP 1. Get data source name from command line (or use default)
    **          Allocate the environment handle and set ODBC version
    **          Allocate the connection handle
    **          Establish the database connection
    **          Get version information from the database server
    **          -- if version < 9.x (not UDO enabled), exit with error message
    **          Allocate the statement handle
    */


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
    if (checkError (rc, SQL_HANDLE_DBC, hdbc, (SQLCHAR *) "Error in Step 1 -- SQLConnect failed\nExiting!!\n"))
        return (1);


    /* Get version information from the database server
       If version < 9.x (not UDO enabled), exit with error message */

    rc = SQLGetInfoW (hdbc, SQL_DBMS_VER, verInfoBufferW, BUFFER_LENW, &verInfoLen);
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




    /* STEP 2.  Select a smart-large object from the database
    **          -- the select  statement executed is -
    **          "SELECT advert FROM item WHERE item_num = 1004"
    */

    /* Execute the select statement */
    rc = SQLExecDirectW (hstmt, selectStmtW, SQL_NTS);
    if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 2 -- SQLExecDirect failed\n"))
        goto Exit;



    fprintf (stdout, "STEP 2 done...select statement executed...smart large object retrieved from the databse\n");




    /* STEP 3.  Get the size of the smart large object pointer structure
    **          Allocate a buffer to hold the structure.
    **          Get the smart large object pointer structure from the database
    **          Close the result set cursor
    */

    /* Get the size of the smart large object pointer structure */
    rc = SQLGetInfo (hdbc, SQL_INFX_LO_PTR_LENGTH, &loptr_size, sizeof(loptr_size), NULL);
    if (checkError (rc, SQL_HANDLE_DBC, hdbc, (SQLCHAR *) "Error in Step 3 -- SQLGetInfo failed\n"))
        goto Exit;


    /* Allocate a buffer to hold the smart large object pointer structure */
    loptr_bufferW = malloc (loptr_size);


    /* Bind the smart large object pointer structure buffer allocated to the column
       in the result set & fetch it from the database */
    rc = SQLBindCol (hstmt, 1, SQL_C_BINARY, loptr_bufferW, loptr_size, &loptr_valsize);
    if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 3 -- SQLBindCol failed\n"))
        goto Exit;

    rc = SQLFetch (hstmt);
    if (rc == SQL_NO_DATA_FOUND)
    {
        fprintf (stdout, "No Data Found\nExiting!!\n");
        goto Exit;
    }
    if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 3 -- SQLFetch failed\n"))
        goto Exit;

    /* Close the result set cursor */
    rc = SQLCloseCursor (hstmt);
    if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 3 -- SQLCloseCursor failed\n"))
        goto Exit;


    fprintf (stdout, "STEP 3 done...smart large object pointer structure fetched from the database\n");



    /* STEP 4.  Use the smart large object's pointer structure to open it
    **          and obtain the smart large object file descriptor.
    **          Reset the statement parameters
    */

    rc = SQLBindParameter (hstmt, 1, SQL_PARAM_OUTPUT, SQL_C_LONG,
                           SQL_INTEGER, (UDWORD)0, 0, &lofd, sizeof(lofd), &lofd_valsize);
    if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 4 -- SQLBindParameter failed (param 1)\n"))
        goto Exit;

    rc = SQLBindParameter (hstmt, 2, SQL_PARAM_INPUT, SQL_C_BINARY,
                           SQL_INFX_UDT_FIXED, (UDWORD)loptr_size, 0, loptr_bufferW,
                           loptr_size, &loptr_valsize);
    if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 4 -- SQLBindParameter failed (param 2)\n"))
        goto Exit;

    rc = SQLBindParameter (hstmt, 3, SQL_PARAM_INPUT, SQL_C_LONG,
                           SQL_INTEGER, (UDWORD)0, 0, &mode, sizeof(mode), &cbMode);
    if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 4 -- SQLBindParameter failed (param 3)\n"))
        goto Exit;

    rc = SQLExecDirectW (hstmt, (SQLWCHAR *) L"{? = call  ifx_lo_open(?, ?)}", SQL_NTS);
    if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 4 -- SQLExecDirect failed\n"))
        goto Exit;

    /* Reset the statement parameters */
    rc = SQLFreeStmt (hstmt, SQL_RESET_PARAMS);
    if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 4 -- SQLFreeStmt failed\n"))
        goto Exit;



    fprintf (stdout, "STEP 4 done...smart large object opened... file descriptor obtained\n");



    /* STEP 5.  Get the size of the smart large object status structure
    **          Allocate a buffer to hold the structure.
    **          Get the smart large object status structure from the database
    **          Reset the statement parameters
    */

    /* Get the size of the smart large object status structure */
    rc = SQLGetInfo (hdbc, SQL_INFX_LO_STAT_LENGTH, &lostat_size,
                     sizeof(lostat_size), NULL);
    if (checkError (rc, SQL_HANDLE_DBC, hdbc, (SQLCHAR *) "Error in Step 5 -- SQLGetInfo failed\n"))
        goto Exit;

    /* Allocate a buffer to hold the smart large object status structure. */
    lostat_bufferW = malloc(lostat_size);


    /* Get the smart large object status structure from the database. */
    rc = SQLBindParameter (hstmt, 1, SQL_PARAM_INPUT, SQL_C_LONG,
                           SQL_INTEGER, (UDWORD)0, 0, &lofd, sizeof(lofd), &lofd_valsize);
    if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 5 -- SQLBindParameter failed (param 1)\n"))
        goto Exit;

    rc = SQLBindParameter (hstmt, 2, SQL_PARAM_INPUT_OUTPUT,
                           SQL_C_BINARY, SQL_INFX_UDT_FIXED, (UDWORD)lostat_size, 0,
                           lostat_bufferW, lostat_size, &lostat_valsize);
    if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 5 -- SQLBindParameter failed (param 2)\n"))
        goto Exit;

    rc = SQLExecDirectW (hstmt, (SQLWCHAR *) L"{call ifx_lo_stat(?, ?)}",
                         SQL_NTS);
    if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 5 -- SQLExecDirect failed\n"))
        goto Exit;

    /* Reset the statement parameters */
    rc = SQLFreeStmt (hstmt, SQL_RESET_PARAMS);
    if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 5 -- SQLFreeStmt failed\n"))
        goto Exit;



    fprintf (stdout, "STEP 5 done...smart large object status structure fetched from the database\n");




    /* STEP 6.  Use the smart large object's status structure to get the size
    **          of the smart large object
    **          Reset the statement parameters
    */

    /* Use the smart large object status structure to get the size
       of the smart large object. */
    rc = SQLBindParameter (hstmt, 1, SQL_PARAM_INPUT, SQL_C_BINARY,
                           SQL_INFX_UDT_FIXED, (UDWORD)lostat_size, 0, lostat_bufferW,
                           lostat_size, &lostat_valsize);
    if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 6 -- SQLBindParameter failed (param 1)\n"))
        goto Exit;

    rc = SQLBindParameter (hstmt, 2, SQL_PARAM_OUTPUT, SQL_C_LONG,
                           SQL_BIGINT, (UDWORD)0, 0, &lo_size, sizeof(lo_size), &cbLoSize);
    if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 6 -- SQLBindParameter failed (param 1)\n"))
        goto Exit;

    rc = SQLExecDirectW (hstmt, (SQLWCHAR *) L"{call ifx_lo_stat_size(?, ?)}",
                         SQL_NTS);
    if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 6 -- SQLExecDirect failed\n"))
        goto Exit;

    /* Reset the statement parameters */
    rc = SQLFreeStmt (hstmt, SQL_RESET_PARAMS);
    if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 6 -- SQLFreeStmt failed\n"))
        goto Exit;



    fprintf (stdout, "STEP 6 done...smart large object size = %ld bytes\n", lo_size);



    /* STEP 7.  Allocate a buffer to hold the smart large object's data
    **          Read the smart large object's data using its file descriptor
    **          Null-terminate the last byte of the smart large-object's data
    **          Print out the contents of the smart large object
    **          Reset the statement parameters
    */

    /* Allocate a buffer to hold the smart large object's data chunks */
    lo_data = malloc (lo_size + 1);

    /* Read the smart large object's data */
    rc = SQLBindParameter (hstmt, 1, SQL_PARAM_INPUT, SQL_C_LONG,
                           SQL_INTEGER, (UDWORD)0, 0, &lofd, sizeof(lofd), &lofd_valsize);
    if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 7 -- SQLBindParameter failed (param 1)\n"))
        goto Exit;

    rc = SQLBindParameter (hstmt, 2, SQL_PARAM_OUTPUT, SQL_C_CHAR,
                           SQL_CHAR, lo_size, 0, lo_data, lo_size, &lo_data_valsize);
    if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 7 -- SQLBindParameter failed (param 2)\n"))
        goto Exit;

    rc = SQLExecDirectW (hstmt, (SQLWCHAR *) L"{call ifx_lo_read(?, ?)}", SQL_NTS);
    if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 7 -- SQLExecDirect failed\n"))
        goto Exit;

    /* Null-terminate the last byte of the smart large objects data */
    lo_data[lo_size] = '\0';

    /* Print the contents of the smart large object */
    /*
        lo_data = (SQLCHAR *) malloc (wcslen(lo_dataW) + sizeof(char));
        wcstombs( (char *) lo_data, lo_dataW, wcslen(lo_dataW)
                                                    + sizeof(char));
    */
    fprintf (stdout, "Smart large object contents are.....\n\n\n%s\n\n\n", lo_data);


    /* Reset the statement parameters */
    rc = SQLFreeStmt (hstmt, SQL_RESET_PARAMS);
    if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 7 -- SQLFreeStmt failed\n"))
        goto Exit;


    fprintf (stdout, "STEP 7 done...smart large object read completely\n");



    /* STEP 8.  Close the smart large object.
    */

    rc = SQLBindParameter (hstmt, 1, SQL_PARAM_INPUT, SQL_C_LONG,
                           SQL_INTEGER, (UDWORD)0, 0, &lofd, sizeof(lofd), &lofd_valsize);
    if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 8 -- SQLBindParameter failed\n"))
        goto Exit;

    rc = SQLExecDirectW (hstmt, (SQLWCHAR *) L"{call ifx_lo_close(?)}",
                         SQL_NTS);
    if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 8 -- SQLExecDirect failed\n"))
        goto Exit;


    fprintf (stdout, "STEP 8 done...smart large object closed\n");




    /* STEP 9. Free the allocated buffers */

    free (loptr_bufferW);
    free (lostat_bufferW);
    free (lo_data);


    fprintf (stdout, "STEP 9 done...smart large object buffers freed\n");



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

