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
*  Title:          transact.c
*
*  Description:    To use explicit transactions using SQLEndTran
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
	SQLHDBC     hdbc;
    SQLHENV     henv;
    SQLHSTMT    hstmt;

    /* Miscellaneous variables */

    SQLCHAR       dsn[20];   /*name of the DSN used for connecting to the database*/
    SQLRETURN   rc = 0;
	SQLINTEGER         in;


    SQLCHAR*       selectStmt = (SQLCHAR *) "SELECT order_num, quantity FROM orders";
    SQLCHAR*       updateStmt = (SQLCHAR *) "UPDATE orders SET quantity = quantity*2";

    SQLLEN  order_num, quantity, cbOrderNum = 0, cbQuantity = 0;


    
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




	/* STEP 2.  Set the connection attribute SQL_ATTR_AUTOCOMMIT to 
    **          SQL_AUTOCOMMIT_OFF to disable auto=commit
    **          Retrieve data from the 'orders' table and display the results
    **          Close the result set cursor
    */

    /* Set the connection attribute SQL_ATTR_AUTOCOMMIT to SQL_AUTOCOMMIT_OFF */
    rc = SQLSetConnectAttr (hdbc, SQL_ATTR_AUTOCOMMIT, SQL_AUTOCOMMIT_OFF, (SQLINTEGER) NULL);
    if (checkError (rc, SQL_HANDLE_DBC, hdbc, (SQLCHAR *) "Error in Step 2 -- SQLSetConnectAttr failed\n"))
		goto Exit;

    /* Retrieve data from the 'orders' table */

    fprintf (stdout, "Retrieving data from 'orders' table\n\n");

    rc = SQLExecDirect (hstmt, selectStmt, SQL_NTS);
    if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 2 -- SQLExecDirect failed\n"))
		goto Exit;

    /* Bind the result set columns */
    rc = SQLBindCol (hstmt, 1, SQL_C_LONG, &order_num, 0, &cbOrderNum);
    if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 2 -- SQLBindCol failed (column 1)\n"))
		goto Exit;

    rc = SQLBindCol (hstmt, 2, SQL_C_LONG, &quantity, 5, &cbQuantity);
    if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 2 -- SQLBindCol failed (column 2)\n"))
		goto Exit;

    /* Fetch the data */
    while (1)
    {
	    rc = SQLFetch (hstmt);
       	if (rc == SQL_NO_DATA_FOUND)
	        break;
        else if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 2 -- SQLFetch failed\n"))
	    	goto Exit;

        /* Display the results */
        fprintf (stdout, "Order Num: %d, Quantity: %d\n", order_num, quantity);

   	}

    /* Close the result set cursor */
    rc = SQLCloseCursor(hstmt);
    if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 2 -- SQLCloseCursor failed\n"))
		goto Exit;



	fprintf (stdout, "\nSTEP 2 done...auto commit turned off & original data retrieved from the database\n");


	/* STEP 3.  Update the quantity field of the 'orders' table 
    **          (set quantity = quantity*2)
    **          Rollback the transaction
    **          Retrieve data from the 'orders' table and display the results
    **          -- data should be the same as in step 2
    **          Close the result set cursor
    */

    /* Execute the UPDATE statement */
    rc = SQLExecDirect (hstmt, updateStmt, SQL_NTS);
    if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 3 -- SQLExecDirect failed for update stmt\n"))
		goto Exit;

    /* Call SQLEndTran with SQL_ROLLBACK to rollback the transaction */
    rc = SQLEndTran (SQL_HANDLE_DBC, hdbc, SQL_ROLLBACK);
    if (checkError (rc, SQL_HANDLE_DBC, hdbc, (SQLCHAR *) "Error in Step 3 -- SQLEndTran failed\n"))
		goto Exit;


    /* Retrieve data from the 'orders' table */
    fprintf (stdout, "Retrieving data from 'orders' table after rollback\n\n");

    rc = SQLExecDirect (hstmt, selectStmt, SQL_NTS);
    if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 3 -- SQLExecDirect failed for select stmt\n"))
		goto Exit;

    /* Bind the result set columns */
    rc = SQLBindCol (hstmt, 1, SQL_C_LONG, &order_num, 0, &cbOrderNum);
    if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 3 -- SQLBindCol failed (column 1)\n"))
		goto Exit;

    rc = SQLBindCol (hstmt, 2, SQL_C_LONG, &quantity, 5, &cbQuantity);
    if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 3 -- SQLBindCol failed (column 2)\n"))
		goto Exit;

    /* Fetch the data */
    while (1)
    {
	    rc = SQLFetch (hstmt);
       	if (rc == SQL_NO_DATA_FOUND)
	        break;
        else if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 3 -- SQLFetch failed\n"))
	    	goto Exit;

        /* Display the results */
        fprintf (stdout, "Order Num: %d, Quantity: %d\n", order_num, quantity);

   	}

    /* Close the result set cursor */
    rc = SQLCloseCursor(hstmt);
    if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 3 -- SQLCloseCursor failed\n"))
		goto Exit;



	fprintf (stdout, "\nSTEP 3 done...transaction successfully rolled back...\n\t...data retrieved should be same as in step 2\n");
    fprintf (stdout,"\n\nHit <Enter> to continue...\n\n");
    in = getchar ();



	/* STEP 4.  Update the quantity field of the 'orders' table 
    **          (set quantity = quantity*2)
    **          Commit the transaction
    **          Retrieve data from the 'orders' table and display the results
    **          -- data should be updated
    **          Close the result set cursor
    */

    /* Execute the UPDATE statement */
    rc = SQLExecDirect (hstmt, updateStmt, SQL_NTS);
    if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 4 -- SQLExecDirect failed for update stmt\n"))
		goto Exit;

    /* Call SQLEndTran with SQL_COMMIT to commit the transaction */
    rc = SQLEndTran (SQL_HANDLE_DBC, hdbc, SQL_COMMIT);
    if (checkError (rc, SQL_HANDLE_DBC, hdbc, (SQLCHAR *) "Error in Step 4 -- SQLEndTran failed\n"))
		goto Exit;


    /* Retrieve data from the 'orders' table */
    fprintf (stdout, "Retrieving data from 'orders' table after commit\n\n");

    rc = SQLExecDirect (hstmt, selectStmt, SQL_NTS);
    if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 4 -- SQLExecDirect failed for select stmt\n"))
		goto Exit;

    /* Bind the result set columns */
    rc = SQLBindCol (hstmt, 1, SQL_C_LONG, &order_num, 0, &cbOrderNum);
    if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 4 -- SQLBindCol failed (column 1)\n"))
		goto Exit;

    rc = SQLBindCol (hstmt, 2, SQL_C_LONG, &quantity, 5, &cbQuantity);
    if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 4 -- SQLBindCol failed (column 2)\n"))
		goto Exit;

    /* Fetch the data */
    while (1)
    {
	    rc = SQLFetch (hstmt);
       	if (rc == SQL_NO_DATA_FOUND)
	        break;
        else if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 4 -- SQLFetch failed\n"))
	    	goto Exit;

        /* Display the results */
        fprintf (stdout, "Order Num: %d, Quantity: %d\n", order_num, quantity);

   	}

    /* Close the result set cursor */
    rc = SQLCloseCursor(hstmt);
    if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 4 -- SQLCloseCursor failed\n"))
		goto Exit;



	fprintf (stdout, "\n\nSTEP 4 done...transaction successfully committed...\n\t...data retrieved should be updated data\n");




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
