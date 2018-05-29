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
*  Title:          rsetinfo.c
*
*  Description:    To obtain information about the result set returned by 
*                  a query and display additional information about the 
*                  data returned. The information displayed is -
*                  1. Number of columns in the result set
*                  2. Name, datatype, size and nullability of each column
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


#define BUFFER_LEN      20
#define ERRMSG_LEN      200

SQLCHAR   defDsn[] = "odbc_demo";


SQLINTEGER checkError (SQLRETURN       rc,
                SQLSMALLINT     handleType,
				SQLHANDLE       handle,
				SQLCHAR*            errmsg)
{
    SQLRETURN       retcode = SQL_SUCCESS;

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
          char*        argv[])
{
	/* Declare variables
    */

    /* Handles */            
	SQLHDBC         hdbc;
    SQLHENV         henv;
    SQLHSTMT        hstmt;

    /* Miscellaneous variables */

    SQLCHAR           dsn[20];   /*name of the DSN used for connecting to the database*/
    SQLRETURN       rc = 0;
	SQLUINTEGER     in;

    SQLSMALLINT     colCount;
    SQLSMALLINT     colNum;
    SQLCHAR         colName[BUFFER_LEN];
    SQLSMALLINT     colNameLength = 0;
    SQLSMALLINT     colDataType;
    SQLULEN         colSize;
    SQLSMALLINT     colDecimalDigits;
    SQLSMALLINT     colNullable;

    SQLCHAR*           selectStmt = (SQLCHAR *) "select * from orders";


    /*  STEP 1. Get data source name from command line (or use default)
    **          Allocate the environment handle and set ODBC version
    **          Allocate the connection handle 
    **          Establish the database connection 
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
        fprintf (stdout, "Environment Handle Allocation failed\nExiting!!");
        return (1);
    }


    /* Set the ODBC version to 3.0 */
    rc = SQLSetEnvAttr (henv, SQL_ATTR_ODBC_VERSION, (SQLPOINTER) SQL_OV_ODBC3, 0);
    if (checkError (rc, SQL_HANDLE_ENV, henv, (SQLCHAR *) "Error in Step 1 -- SQLSetEnvAttr failed\nExiting!!"))
		return (1);


    /* Allocate the connection handle */
    rc = SQLAllocHandle (SQL_HANDLE_DBC, henv, &hdbc);
    if (checkError (rc, SQL_HANDLE_ENV, henv, (SQLCHAR *) "Error in Step 1 -- Connection Handle Allocation failed\nExiting!!"))
		return (1);


    /* Establish the database connection */
    rc = SQLConnect (hdbc, dsn, SQL_NTS, (SQLCHAR *) "", SQL_NTS, (SQLCHAR *) "", SQL_NTS);
	if (checkError (rc, SQL_HANDLE_DBC, hdbc, (SQLCHAR *) "Error in Step 1 -- SQLConnect failed\nExiting!!"))
		return (1);


    /* Allocate the statement handle */
    rc = SQLAllocHandle (SQL_HANDLE_STMT, hdbc, &hstmt );
    if (checkError (rc, SQL_HANDLE_DBC, hdbc, (SQLCHAR *) "Error in Step 1 -- Statement Handle Allocation failed\nExiting!!"))
		return (1);
    
    

	fprintf (stdout, "STEP 1 done...connected to database\n");




	/* STEP 2.  Execute the query
    **          Retrieve the results
    */

    /* Execute the query */
    rc = SQLExecDirect (hstmt, selectStmt, SQL_NTS);
    if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 2 -- SQLExecDirect failed\n"))
		goto Exit;


    /* Get the result set */
    rc = SQLFetch (hstmt);
    if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 2 -- SQLFetch failed\n"))
		goto Exit;


   	
	fprintf (stdout, "STEP 2 done...query executed and results retrieved\n");



    /* STEP 3.  Get the following information about the result set
    **          -- Number of columns
    **          -- For each column, get its name, datatype, size 
    **             and nullability
    */


    rc = SQLNumResultCols (hstmt, &colCount);
    if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 3 -- SQLNumResultColumns failed\n"))
		goto Exit;

    fprintf (stdout, "Number of columns in the result set = %d\nResult Set columns are...\n\n", colCount);


    for (colNum = 1; colNum <= colCount; colNum++)
    {
        rc = SQLDescribeCol (hstmt, colNum, colName, BUFFER_LEN, &colNameLength, &colDataType, &colSize, &colDecimalDigits, &colNullable);
        if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 3 -- SQLDescribeCol failed\n"))
	    	goto Exit;


        fprintf (stdout, "Column Name: %s;\t", colName);

        /* Find the columns datatype and print it */
        switch (colDataType)
        {
            case SQL_CHAR:
                fprintf (stdout, "Data type: SQL_CHAR;\t");
                break;
            case SQL_NUMERIC:
                fprintf (stdout, "Data type: SQL_NUMERIC;\t");
                break;
            case SQL_DECIMAL:
                fprintf (stdout, "Data type: SQL_DECIMAL;\t");
                break;
            case SQL_INTEGER:
                fprintf (stdout, "Data type: SQL_INTEGER;  \t");
                break;
            case SQL_SMALLINT:
                fprintf (stdout, "Data type: SQL_SMALLINT;\t");
                break;
            case SQL_FLOAT:
                fprintf (stdout, "Data type: SQL_FLOAT;\t");
                break;
            case SQL_REAL:
                fprintf (stdout, "Data type: SQL_REAL;\t");
                break;
            case SQL_DOUBLE:
                fprintf (stdout, "Data type: SQL_DOUBLE;\t");
                break;
            case SQL_DATETIME:
                fprintf (stdout, "Data type: SQL_DATETIME;\t");
                break;
            case SQL_VARCHAR:
                fprintf (stdout, "Data type: SQL_VARCHAR;\t");
                break;
            case SQL_TYPE_DATE:
                fprintf (stdout, "Data type: SQL_TYPE_DATE;\t");
                break;
            case SQL_TYPE_TIME:
                fprintf (stdout, "Data type: SQL_TYPE_TIME;\t");
                break;
            case SQL_TYPE_TIMESTAMP:
                fprintf (stdout, "Data type: SQL_TYPE_TIMESTAMP;\t");
                break;
            case SQL_INTERVAL:
                fprintf (stdout, "Data type: SQL_INTERVAL;\t");
                break;
            case SQL_TIMESTAMP:
                fprintf (stdout, "Data type: SQL_TIMESTAMP;\t");
                break;
            case SQL_LONGVARCHAR:
                fprintf (stdout, "Data type: SQL_LONGVARCHAR;\t");
                break;
            case SQL_BINARY:
                fprintf (stdout, "Data type: SQL_BINARY;\t");
                break;
            case SQL_VARBINARY:
                fprintf (stdout, "Data type: SQL_VARBINARY;\t");
                break;
            case SQL_LONGVARBINARY:
                fprintf (stdout, "Data type: SQL_LONGVARBINARY;\t");
                break;
            case SQL_BIGINT:
                fprintf (stdout, "Data type: SQL_BIGINT;\t");
                break;
            case SQL_TINYINT:
                fprintf (stdout, "Data type: SQL_TINYINT;\t");
                break;
            case SQL_BIT:
                fprintf (stdout, "Data type: SQL_BIT;\t");
                break;
            case SQL_UNKNOWN_TYPE:
            default:
                fprintf (stdout, "Data type: UNKNOWN;\t");
        }

        /* format the rest of the columns information */
        fprintf (stdout, "Column Size: %d;\t", colSize);

        switch (colNullable)
        {
            case SQL_NO_NULLS:
                fprintf (stdout, "Allows NULLS: NO\n");
                break;
            case SQL_NULLABLE:
                fprintf (stdout, "Allows NULLS: YES\n");
                break;
            case SQL_NULLABLE_UNKNOWN:
                fprintf (stdout, "Allows NULLS: UNKNOWN\n");
                break;
        }
    }


	fprintf (stdout, "\n\nSTEP 3 done...result set information displayed\n");




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
