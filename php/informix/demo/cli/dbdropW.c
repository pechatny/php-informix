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
*	(C) Copyright IBM Corporation 1997, 2004 All rights reserved.
*
*
*
*
*
*  Title:          dbdropW.c (Unicode counterpart of dbdrop.c)
*
*  Description:    To drop the sample database (created by dbCreate.c)
*                  Before running this program, make sure that all 
*                  connections to the sample database have been closed.
*                  To successfully drop the sample database, you must 
*                  have DBA permissions or be running this as user 
*                  'informix'
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

#define BUFFER_LEN      70
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

                fprintf (stderr, "ERROR: %d:  %s : %s \n", nativeError, sqlState, errMsg);
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
    SQLHDBC     hdbc;
    SQLHENV     henv;
    SQLHSTMT    hstmt;

    /* Miscellaneous variables */

    SQLCHAR     *dsn;   /*name of the DSN used for connecting to the database */
    SQLWCHAR    *dsnW;   /*name of the DSN used for connecting to the database*/

    SQLRETURN   rc = 0;
    SQLINTEGER  in;

    
    SQLWCHAR    connStrInW[BUFFER_LEN];
    SQLWCHAR    connStrOutW[BUFFER_LEN];
    SQLSMALLINT connStrOutLen;

    SQLWCHAR*   dropDBStmtW = (SQLWCHAR *) L"DROP DATABASE odbc_demodb";
    int             lenArgv1;


    /*  STEP 1. Get data source name from command line (or use default)
    **          Allocate the environment handle and set ODBC version
    **          Allocate the connection handle 
    **          Establish the database connection 
    **          Allocate the statement handle 
    */


    /* If(dsnW is not explicitly passed in as arg) */
    if (argc != 2)
    {
        /* Use default dsnW - odbc_demo */
        fprintf (stdout, "\nUsing default DSN : %s\n", defDsn);
        dsn = (SQLCHAR *) malloc (sizeof(defDsn) + sizeof(char));
        strcpy( (char *)dsn,  (char *)defDsn);
        dsnW = (SQLWCHAR *) malloc( wcslen(defDsnW) * sizeof(SQLWCHAR)
                                             + sizeof(SQLWCHAR));
        wcscpy ((SQLWCHAR *)dsnW, (SQLWCHAR *)defDsnW);
    }
    else
    {
        /* Use specified dsnW */
        lenArgv1 = strlen((char *)argv[1]);
        dsn = (SQLCHAR *) malloc (lenArgv1 + sizeof(char));
        strcpy((char *)dsn, (char *)argv[1]);
        dsnW = (SQLWCHAR *) malloc (lenArgv1 * sizeof(SQLWCHAR)
                                    + sizeof(SQLWCHAR));
        mbstowcs (dsnW, (char *)argv[1], lenArgv1 + sizeof(char));
        fprintf (stdout, "\nUsing specified DSN : %s\n", argv[1]);
    }

    
    /* Allocate the Environment handle */
    rc = SQLAllocHandle (SQL_HANDLE_ENV, SQL_NULL_HANDLE, &henv);
    if (rc != SQL_SUCCESS)
    {
        fprintf (stdout, "Environment Handle Allocation failed\nExiting!!");
        return (1);
    }


    /* Set the ODBC version to 3.0 */
    rc = SQLSetEnvAttr (henv, SQL_ATTR_ODBC_VERSION, (SQLPOINTER) SQL_OV_ODBC3, 0);
    if (checkError (rc, SQL_HANDLE_ENV, henv, (SQLCHAR * ) "Error in Step 1 -- SQLSetEnvAttr failed\nExiting!!"))
		return (1);


    /* Allocate the connection handle */
    rc = SQLAllocHandle (SQL_HANDLE_DBC, henv, &hdbc);
    if (checkError (rc, SQL_HANDLE_ENV, henv, (SQLCHAR * ) "Error in Step 1 -- Connection Handle Allocation failed\nExiting!!"))
		return (1);


    /* Establish the database connection */
#ifndef _WINNT
    wsprintf((SQLWCHAR *) connStrInW, "DSN=%s;connectdatabase=NO", dsn);
#else
    swprintf((SQLWCHAR *) connStrInW, L"DSN=%s;connectdatabase=NO", dsnW);
#endif
    
    rc = SQLDriverConnectW (hdbc, NULL, connStrInW, SQL_NTS, connStrOutW, BUFFER_LEN, &connStrOutLen, SQL_DRIVER_NOPROMPT);
    if (checkError (rc, SQL_HANDLE_DBC, hdbc, (SQLCHAR * ) "Error in Step 1 -- SQLDriverConnect failed\nExiting!!"))
		return (1);


	/* Allocate the statement handle */
    rc = SQLAllocHandle (SQL_HANDLE_STMT, hdbc, &hstmt );
    if (checkError (rc, SQL_HANDLE_DBC, hdbc, (SQLCHAR * ) "Error in Step 1 -- Statement Handle Allocation failed\nExiting!!"))
		return (1);



	fprintf (stdout, "STEP 1 done...connected to database\n");




	/* STEP 2.  Drop the sample database -- odbc_demodb */


    rc = SQLExecDirectW (hstmt, dropDBStmtW, SQL_NTS);
    if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR * ) "Error in Step 2 -- SQLExecDirect failed\n"))
        goto Exit;
   
    
    
    fprintf(stdout, "STEP 2 done...Sample Database Dropped\n");



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
