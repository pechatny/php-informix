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
*  Title:          posupdt.c
*
*  Description:    To use SQLSetPos for positional updates to a result set
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

#define BUFFER_LEN      10
#define ERRMSG_LEN      200
#define NUM_ROWS        5

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
    SQLHSTMT        hNewStmt;

    /* Miscellaneous variables */

    SQLCHAR         dsn[20];   /*name of the DSN used for connecting to the database*/
    SQLRETURN       rc = 0;
	SQLINTEGER      in;


    SQLCHAR*        selectStmt = (SQLCHAR *) "SELECT cust_num, fname, lname FROM customer";
    SQLCHAR*        newLname = (SQLCHAR *) "Miller";

    SQLCHAR         fname[NUM_ROWS][BUFFER_LEN], lname[NUM_ROWS][BUFFER_LEN];
    SQLCHAR         newfname[NUM_ROWS][BUFFER_LEN], newlname[NUM_ROWS][BUFFER_LEN];
    SQLINTEGER  cust_num[NUM_ROWS];
    SQLLEN      cbCustNum[NUM_ROWS], cbFname[NUM_ROWS], cbLname[NUM_ROWS];
    SQLINTEGER  newcust_num[NUM_ROWS];
    SQLLEN      newcbCustNum[NUM_ROWS], newcbFname[NUM_ROWS], newcbLname[NUM_ROWS];
    
    SQLUSMALLINT    i, statusArray[NUM_ROWS];

    

    /*  STEP 1. Get data source name from command line (or use default)
    **          Allocate the environment handle and set ODBC version
    **          Allocate the connection handle 
    **          Establish the database connection 
    **          Set the connection attribute to enable scrollable cursors
    **          Allocate the statement handles
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


    /* Set the connection attribute to enable scrollable cursors */
    rc = SQLSetConnectAttr (hdbc, SQL_INFX_ATTR_ENABLE_SCROLL_CURSORS, (SQLPOINTER) SQL_TRUE, (SQLINTEGER) NULL);
    if (checkError (rc, SQL_HANDLE_DBC, hdbc, (SQLCHAR *) "Error in Step 1 -- Set Connection Attribute failed\nExiting!!"))
		return (1);

    /* Allocate the statement handles */
    rc = SQLAllocHandle (SQL_HANDLE_STMT, hdbc, &hstmt );
    if (checkError (rc, SQL_HANDLE_DBC, hdbc, (SQLCHAR *) "Error in Step 1 -- Statement Handle Allocation failed\nExiting!!"))
		return (1);
    
    

	fprintf (stdout, "STEP 1 done...connected to database\n");




    /* STEP 2   Set the following statement attributes
    **          -- SQL_ATTR_ROW_ARRAY_SIZE to the number of rows to be bound
    **             SQL_ATTR_CONCURRENCY to SQL_CONCUR_LOCK
    **             SQL_ATTR_CURSOR_TYPE to SQL_CURSOR_STATIC
    **             SQL_ATTR_ROW_STATUS_PTR tot he address of the status array
    */

    /* Set the statement attribute SQL_ATTR_ROW_ARRAY_SIZE to the number of rows to be bound */
    rc = SQLSetStmtAttr (hstmt, SQL_ATTR_ROW_ARRAY_SIZE, (SQLPOINTER) NUM_ROWS, 0);
    if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 2 -- SQLSetStmtAttr failed for SQL_ATTR_ROW_ARRAY_SIZE\n"))
		goto Exit;

    /* Set the statement attribute SQL_ATTR_CONCURRENCY to SQL_CONCUR_LOCK */
    rc = SQLSetStmtAttr (hstmt, SQL_ATTR_CONCURRENCY, (SQLPOINTER) SQL_CONCUR_LOCK, 0);
    if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 2 -- SQLSetStmtAttr failed for SQL_ATTR_CONCURRENCY\n"))
		goto Exit;

    /* Set the statement attribute SQL_ATTR_CURSOR_TYPE to SQL_CURSOR_STATIC */
    rc = SQLSetStmtAttr (hstmt, SQL_ATTR_CURSOR_TYPE, (SQLPOINTER) SQL_CURSOR_STATIC, 0);
    if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 2 -- SQLSetStmtAttr failed for SQL_ATTR_CURSOR_TYPE\n"))
		goto Exit;

    /* Set the statement attribute SQL_ATTR_ROW_STATUS_PTR to the status array */
    rc =     SQLSetStmtAttr (hstmt, SQL_ATTR_ROW_STATUS_PTR, statusArray, 0);
    if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 2 -- SQLSetStmtAttr failed for SQL_ATTR_ROW_STATUS_PTR\n"))
		goto Exit;


	
    fprintf (stdout, "STEP 2 done...Statement attributes set\n");

    

    /* STEP 3.  Retrieve data from the 'customer' table
    **          Display the results
    */

    /* Retrieve data from the 'customer' table */
    fprintf (stdout, "Retrieving data from 'customer' table\n\n");

    rc = SQLExecDirect (hstmt, selectStmt, SQL_NTS);
    if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 3 -- SQLExecDirect failed\n"))
		goto Exit;

    /* Bind the result set columns */
    rc = SQLBindCol (hstmt, 1, SQL_C_LONG, &cust_num[0], 0, &cbCustNum[0]);
    if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 3 -- SQLBindCol failed (column 1)\n"))
		goto Exit;

    rc = SQLBindCol (hstmt, 2, SQL_C_CHAR, fname[0], BUFFER_LEN, &cbFname[0]);
    if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 3 -- SQLBindCol failed (column 2)\n"))
		goto Exit;

    rc = SQLBindCol (hstmt, 3, SQL_C_CHAR, lname[0], BUFFER_LEN, &cbLname[0]);
    if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 3 -- SQLBindCol failed (column 3)\n"))
		goto Exit;

    /* Fetch the results */
	rc = SQLFetch (hstmt);
    if (rc == SQL_NO_DATA_FOUND)
	    fprintf (stdout, "NO DATA FOUND!!\n EXITING!!");
    else if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 3 -- SQLFetch failed\n"))
	  	goto Exit;

    for (i=0; i<NUM_ROWS; i++)
    {
        /* Display the results */
        fprintf (stdout, "Cust Num: %d, Fname: %s, Lname: %s\n", cust_num[i], fname[i], lname[i]);

   	}


	fprintf (stdout, "\nSTEP 3 done...original data retrieved from 'customer' table\n");



	/* STEP 4.  Update the 'lname' field of the 'customer' table for cust_num = 102
    **          Call SQLSetPos to update the data in the table
    **          Call SQLEndTran to commit the transaction
    */

    /* Update the value in the 'lname' array where cust_num = 102 to 'Miller' */
    for (i=0; i< NUM_ROWS; i++)
    {
        if (cust_num[i] == 102)
        {
            strcpy ((char*) lname[i], (char*) newLname);
            cbLname[i] = strlen((char *)newLname);
            
            /* Call SQLSetPos to update the data */
            rc = SQLSetPos (hstmt, (SQLUSMALLINT) (i+1), (SQLUSMALLINT) SQL_UPDATE, (SQLUSMALLINT) SQL_LOCK_NO_CHANGE);
            if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 4 -- SQLSetPos\n"))
		        goto Exit;
            break;
        }
    }

    /* Commit the transaction */
    rc = SQLEndTran (SQL_HANDLE_DBC, hdbc, SQL_COMMIT);
    if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 4 -- SQLEndtran\n"))
        goto Exit;


    fprintf (stdout, "STEP 4 done...row updated using SQLSetPos\n");




    /* STEP 5.  Retrieve updated data from the 'customer' table
    **          Display the results
    */

    /* Retrieve updated data from the 'customer' table */
    fprintf (stdout, "Retrieving data from 'customer' table\n\n");

    rc = SQLAllocHandle (SQL_HANDLE_STMT, hdbc, &hNewStmt );
    if (checkError (rc, SQL_HANDLE_DBC, hdbc, (SQLCHAR *) "Error in Step 1 -- Statement Handle Allocation failed\nExiting!!"))
		return (1);
    
    /* Set the statement attribute SQL_ATTR_ROW_ARRAY_SIZE to the number of rows to be bound */
    rc = SQLSetStmtAttr (hNewStmt, SQL_ATTR_ROW_ARRAY_SIZE, (SQLPOINTER) NUM_ROWS, 0);
    if (checkError (rc, SQL_HANDLE_STMT, hNewStmt, (SQLCHAR *) "Error in Step 2 -- SQLSetStmtAttr failed for SQL_ATTR_ROW_ARRAY_SIZE\n"))
		goto Exit;

    rc = SQLExecDirect (hNewStmt, selectStmt, SQL_NTS);
    if (checkError (rc, SQL_HANDLE_STMT, hNewStmt, (SQLCHAR *) "Error in Step 5 -- SQLExecDirect failed\n"))
		goto Exit;

    /* Bind the result set columns */
    rc = SQLBindCol (hNewStmt, 1, SQL_C_LONG, &newcust_num[0], 0, &newcbCustNum[0]);
    if (checkError (rc, SQL_HANDLE_STMT, hNewStmt, (SQLCHAR *) "Error in Step 5 -- SQLBindCol failed (column 1)\n"))
		goto Exit;

    rc = SQLBindCol (hNewStmt, 2, SQL_C_CHAR, newfname[0], BUFFER_LEN, &newcbFname[0]);
    if (checkError (rc, SQL_HANDLE_STMT, hNewStmt, (SQLCHAR *) "Error in Step 5 -- SQLBindCol failed (column 2)\n"))
		goto Exit;

    rc = SQLBindCol (hNewStmt, 3, SQL_C_CHAR, newlname[0], BUFFER_LEN, &newcbLname[0]);
    if (checkError (rc, SQL_HANDLE_STMT, hNewStmt, (SQLCHAR *) "Error in Step 5 -- SQLBindCol failed (column 3)\n"))
		goto Exit;

    /* Fetch the results */
	rc = SQLFetch (hNewStmt);
    if (rc == SQL_NO_DATA_FOUND)
	    fprintf (stdout, "NO DATA FOUND!!\n EXITING!!");
    else if (checkError (rc, SQL_HANDLE_STMT, hNewStmt, (SQLCHAR *) "Error in Step 5 -- SQLFetch failed\n"))
	  	goto Exit;

    for (i=0; i<NUM_ROWS; i++)
    {
        /* Display the results */
        fprintf (stdout, "Cust Num: %d, Fname: %s, Lname: %s\n", newcust_num[i], newfname[i], newlname[i]);

   	}


	fprintf (stdout, "\nSTEP 5 done...updated data retrieved from 'customer' table\n");



    Exit:

    /* CLEANUP: Close the statement handle
    **          Free the statement handle
    **          Disconnect from the datasource
    **          Free the connection and environment handles
    **          Exit
    */

    /* Close the statement handle */
    SQLFreeStmt (hstmt, SQL_CLOSE);
    SQLFreeStmt (hNewStmt, SQL_CLOSE);

    /* Free the statement handle */
    SQLFreeHandle (SQL_HANDLE_STMT, hstmt);
    SQLFreeHandle (SQL_HANDLE_STMT, hNewStmt);

	/* Disconnect from the data source */
    SQLDisconnect (hdbc);

    /* Free the environment handle and the database connection handle */
    SQLFreeHandle (SQL_HANDLE_DBC, hdbc);
    SQLFreeHandle (SQL_HANDLE_ENV, henv);

    fprintf (stdout,"\n\nHit <Enter> to terminate the program...\n\n");
    in = getchar ();
    return (rc);
}
