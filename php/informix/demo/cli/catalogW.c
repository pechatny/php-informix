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
*	Copyright IBM Corporation 1997, 2007 All rights reserved.
*
*
*
*
*
*  Title:          catalogW.c (Unicode counterpart of catalog.c)
*
*  Description:    To use catalog functions to obtain information about 
*                  the database tables and columns
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

#define BUFFER_LEN      130
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
    SQLHSTMT    hTableStmt;
    SQLHSTMT    hColStmt;
    SQLHSTMT    hPriKeyStmt;

    /* Miscellaneous variables */

    SQLWCHAR     *dsnW;   /*name of the DSN used for connecting to the database*/
    SQLRETURN   rc = 0;
    SQLINTEGER  in;


    SQLCHAR     *tableName;
    SQLWCHAR    tableNameW[BUFFER_LEN];
    SQLLEN      cbTableName;
    SQLCHAR     *colName;
    SQLWCHAR    colNameW[BUFFER_LEN];
    SQLLEN      cbColName;

    SQLCHAR     *priKeyName;
    SQLWCHAR    priKeyNameW[BUFFER_LEN];
    SQLLEN      cbPriKeyName;
    int         lenArgv1;


    
    /*  STEP 1. Get data source name from command line (or use default)
    **          Allocate the environment handle and set ODBC version
    **          Allocate the connection handle 
    **          Establish the database connection 
    **          Allocate the statement handle
    */


    /* If(dsn is not explicitly passed in as arg) */
    if (argc != 2)
    {
        /* Use default dsnW - odbc_demo */
        fprintf (stdout, "\nUsing default DSN : %s\n", defDsn);
        dsnW = (SQLWCHAR *) malloc( wcslen(defDsnW) * sizeof(SQLWCHAR)
                                             + sizeof(SQLWCHAR));
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
        fprintf (stdout, "Environment Handle Allocation failed\nExiting!!");
        return (1);
    }


    /* Set the ODBC version to 3.0 */
    rc = SQLSetEnvAttr (henv, SQL_ATTR_ODBC_VERSION, (SQLPOINTER)SQL_OV_ODBC3, 0);
    if (checkError (rc, SQL_HANDLE_ENV, henv, (SQLCHAR *) "Error in Step 1 -- SQLSetEnvAttr failed\nExiting!!"))
		return (1);


    /* Allocate the connection handle */
    rc = SQLAllocHandle (SQL_HANDLE_DBC, henv, &hdbc);
    if (checkError (rc, SQL_HANDLE_ENV, henv, (SQLCHAR *) "Error in Step 1 -- Connection Handle Allocation failed\nExiting!!"))
		return (1);


    /* Establish the database connection */
    rc = SQLConnectW (hdbc, dsnW, SQL_NTS, (SQLWCHAR *) L"", SQL_NTS, (SQLWCHAR *) L"", SQL_NTS);
	if (checkError (rc, SQL_HANDLE_DBC, hdbc, (SQLCHAR *) "Error in Step 1 -- SQLConnect failed\nExiting!!"))
		return (1);


    /* Allocate the statement handles */
    rc = SQLAllocHandle (SQL_HANDLE_STMT, hdbc, &hTableStmt );
    if (checkError (rc, SQL_HANDLE_DBC, hdbc, (SQLCHAR *) "Error in Step 1 -- Statement Handle Allocation failed\nExiting!!"))
		return (1);
    
    rc = SQLAllocHandle (SQL_HANDLE_STMT, hdbc, &hColStmt );
    if (checkError (rc, SQL_HANDLE_DBC, hdbc, (SQLCHAR *) "Error in Step 1 -- Statement Handle Allocation failed\nExiting!!"))
		return (1);
    
    rc = SQLAllocHandle (SQL_HANDLE_STMT, hdbc, &hPriKeyStmt );
    if (checkError (rc, SQL_HANDLE_DBC, hdbc, (SQLCHAR *) "Error in Step 1 -- Statement Handle Allocation failed\nExiting!!"))
		return (1);
    

	fprintf (stdout, "STEP 1 done...connected to database\n");




	/* STEP 2.  Call SQLTables to get table names from the database
    **          For each table in the database, call SQLColumns to get its 
    **          columns and SQLPrimaryKeys to get the columns which comprise
    **          its primary key
    */

    /* Get the names of all the tables in the database */
    rc = SQLTablesW (hTableStmt, NULL, 0, NULL, 0, NULL, 0, (SQLWCHAR *) L"TABLE", SQL_NTS); 
    if (checkError (rc, SQL_HANDLE_STMT, hTableStmt, (SQLCHAR *) "Error in Step 2 -- SQLTables failed\n"))
		goto Exit;

    /* Bind the result set column # 3 - 'TABLE_NAME' */
    rc = SQLBindCol (hTableStmt, 3, SQL_C_WCHAR, tableNameW, BUFFER_LEN, &cbTableName);
    if (checkError (rc, SQL_HANDLE_STMT, hTableStmt, (SQLCHAR *) "Error in Step 2 -- SQLBindCol failed\n"))
		goto Exit;


    /* Fetch the data */
    while (1)
    {
	    rc = SQLFetch (hTableStmt);
       	if (rc == SQL_NO_DATA_FOUND)
	        break;
        else if (checkError (rc, SQL_HANDLE_STMT, hTableStmt, (SQLCHAR *) "Error in Step 2 -- SQLFetch failed for table\n"))
	    	goto Exit;

        /* Display the table name */
        tableName = (SQLCHAR *) malloc (wcslen(tableNameW) + sizeof(char));
        wcstombs( (char *) tableName, tableNameW, wcslen(tableNameW)
                                                   + sizeof(char));
        fprintf (stdout, "Table Name %s\n", tableName);


        /* For this table, get all its columns */
        rc = SQLColumnsW (hColStmt, NULL, 0, NULL, 0, tableNameW, SQL_NTS, NULL, SQL_NTS); 
        if (checkError (rc, SQL_HANDLE_STMT, hColStmt, (SQLCHAR *) "Error in Step 3 -- SQLColumns failed\n"))
	    	goto Exit;

        /* Bind the result set column #4 - 'COLUMN_NAME' */
        rc = SQLBindCol (hColStmt, 4, SQL_C_WCHAR, colNameW, BUFFER_LEN, &cbColName);
        if (checkError (rc, SQL_HANDLE_STMT, hColStmt, (SQLCHAR *) "Error in Step 3 -- SQLBindCol failed for column\n"))
	    	goto Exit;

        /* Fetch and display the column names */
        while (1)
        {
	        rc = SQLFetch (hColStmt);
       	    if (rc == SQL_NO_DATA_FOUND)
	            break;
            else if (checkError (rc, SQL_HANDLE_STMT, hColStmt, (SQLCHAR *) "Error in Step 3 -- SQLFetch failed for column\n"))
	        	goto Exit;

            /* Display the results */
            colName = (SQLCHAR *) malloc (wcslen(colNameW) + sizeof(char));
            wcstombs( (char *) colName, colNameW, wcslen(colNameW)
                                                   + sizeof(char));
            fprintf (stdout, "\tColumn: %s\n", colName);
        }


        /* For this table, get all its primary key columns */
        rc = SQLPrimaryKeysW (hPriKeyStmt, NULL, 0, NULL, 0, tableNameW, SQL_NTS); 
        if (checkError (rc, SQL_HANDLE_STMT, hPriKeyStmt, (SQLCHAR *) "Error in Step 3 -- SQLPrimaryKeys failed\n"))
	    	goto Exit;

        /* Bind the result set column #4 - 'COLUMN_NAME' */
        rc = SQLBindCol (hPriKeyStmt, 4, SQL_C_WCHAR, priKeyNameW, BUFFER_LEN, &cbPriKeyName);
        if (checkError (rc, SQL_HANDLE_STMT, hPriKeyStmt, (SQLCHAR *) "Error in Step 3 -- SQLBindCol failed for primary key\n"))
	    	goto Exit;

        /* Fetch and display the column names */
        while (1)
        {
	        rc = SQLFetch (hPriKeyStmt);
       	    if (rc == SQL_NO_DATA_FOUND)
	            break;
            else if (checkError (rc, SQL_HANDLE_STMT, hPriKeyStmt, (SQLCHAR *) "Error in Step 3 -- SQLFetch failed for column\n"))
	        	goto Exit;

            /* Display the results */
            priKeyName = (SQLCHAR *) malloc (wcslen(priKeyNameW) + sizeof(char));
            wcstombs( (char *) priKeyName, priKeyNameW, wcslen(priKeyNameW)
                                                   + sizeof(char));
            fprintf (stdout, "\t\t Primary Key Column: %s\n", priKeyName);
        }

        /* Close the result set cursors for columns and primary keys */
        rc = SQLCloseCursor (hColStmt);
        if (checkError (rc, SQL_HANDLE_STMT, hColStmt, (SQLCHAR *) "Error in Step 3 -- SQLCloseCursor failed for column\n"))
	    	goto Exit;

        rc = SQLCloseCursor (hPriKeyStmt);
        if (checkError (rc, SQL_HANDLE_STMT, hPriKeyStmt, (SQLCHAR *) "Error in Step 3 -- SQLCloseCursor failed for primary key\n"))
		    goto Exit;
    }

    /* Close the result set cursor for table */
    rc = SQLCloseCursor (hTableStmt);
    if (checkError (rc, SQL_HANDLE_STMT, hTableStmt, (SQLCHAR *) "Error in Step 3 -- SQLCloseCursor failed for table\n"))
		goto Exit;


   	
	fprintf (stdout, "STEP 2 done...catalog information obtained from the database\n");




    Exit:

    /* CLEANUP: Close the statement handles
    **          Free the statement handles
    **          Disconnect from the datasource
    **          Free the connection and environment handles
    **          Exit
    */

    /* Close the statement handle */
    SQLFreeStmt (hTableStmt, SQL_CLOSE);
    SQLFreeStmt (hColStmt, SQL_CLOSE);
    SQLFreeStmt (hPriKeyStmt, SQL_CLOSE);

    /* Free the statement handle */
    SQLFreeHandle (SQL_HANDLE_STMT, hTableStmt);
    SQLFreeHandle (SQL_HANDLE_STMT, hColStmt);
    SQLFreeHandle (SQL_HANDLE_STMT, hPriKeyStmt);

	/* Disconnect from the data source */
    SQLDisconnect (hdbc);

    /* Free the environment handle and the database connection handle */
    SQLFreeHandle (SQL_HANDLE_DBC, hdbc);
    SQLFreeHandle (SQL_HANDLE_ENV, henv);

    fprintf (stdout,"\n\nHit <Enter> to terminate the program...\n\n");
    in = getchar ();
    return (rc);
}
