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
*	Copyright IBM Corporation 1997, 2010 All rights reserved.
*
*
*
*
*
*  Title:          blkinsrt.c
*
*  Description:    To insert multiple rows into a database table using  
*                  SQLBulkOperations
*                  -- the rows are inserted into the 'orders' table
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

#define BUFFER_LEN      15
#define ERRMSG_LEN      200
#define NUM_OLD_ORDERS  9
#define NUM_NEW_ORDERS  9
#define NUM_ORDERS      18

SQLCHAR   defDsn[] = "odbc_demo";

typedef struct 
{
    /* data values */
    SQLINTEGER  order_num;
    SQLLEN  cbOrderNum;
    SQLINTEGER  cust_num;
    SQLLEN  cbCustNum;
    SQLINTEGER  item_num;
    SQLLEN  cbItemNum;
    SQLCHAR	order_date[BUFFER_LEN];
    SQLLEN  cbOrderDate;
    SQLINTEGER  quantity;
    SQLLEN  cbQuantity;
} orderStruct;



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
	SQLINTEGER			i, in;

    
    SQLCHAR *   selectStmt = (UCHAR *) "SELECT order_num, cust_num, item_num, order_date, quantity FROM orders";

    orderStruct orders[NUM_ORDERS]; /*has elements for the current rowset,and
                                      for the new rows being inserted*/
    SQLLEN  bindOffset = 0; 


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
    rc = SQLSetEnvAttr (henv, SQL_ATTR_ODBC_VERSION, (SQLPOINTER)SQL_OV_ODBC3, 0);
    if (checkError (rc, SQL_HANDLE_ENV, henv, (SQLCHAR *) "Error in Step 1 -- SQLSetEnvAttr failed\nExiting!!"))
		return (1);


    /* Allocate the connection handle */
    rc = SQLAllocHandle (SQL_HANDLE_DBC, henv, &hdbc);
    if (checkError (rc, SQL_HANDLE_ENV, henv, (SQLCHAR *) "Error in Step 1 -- Connection Handle Allocation failed\nExiting!!"))
		return (1);

    /* Connect to the database */
    rc = SQLConnect (hdbc, dsn, SQL_NTS, (SQLCHAR *) "", SQL_NTS, (SQLCHAR *) "", SQL_NTS);
	if (checkError (rc, SQL_HANDLE_DBC, hdbc, (SQLCHAR *) "Error in Step 1 -- SQLDriverConnect failed\nExiting!!"))
		return (1);

    rc = SQLSetConnectAttr(hdbc, SQL_INFX_ATTR_LENGTHINCHARFORDIAGRECW, (void *)SQL_TRUE, SQL_IS_UINTEGER);
	if (checkError (rc, SQL_HANDLE_DBC, hdbc, (SQLCHAR *) "Error in Step 1 -- Setting LENGTH IN CHAR FOR DIAG RECW \nExiting!!"))
		return (1);

	/* Allocate the statement handle */
    rc = SQLAllocHandle (SQL_HANDLE_STMT, hdbc, &hstmt );
    if (checkError (rc, SQL_HANDLE_DBC, hdbc, (SQLCHAR *) "Error in Step 1 -- Statement Handle Allocation failed\nExiting!!"))
		return (1);



	fprintf (stdout, "STEP 1 done...connected to database\n");



    /* STEP 2   Set the following statement attributes
    **          -- SQL_ATTR_ROW_BIND_TYPE to the size of the structure 
    **                 'orderStruct', so that the binding orientation of SQLFetch
    **                 is set to row-wise binding
    **             SQL_ATTR_ROW_ARRAY_SIZE to the number of rows to be bound
    **             SQL_ATTR_ROW_BIND_OFFSET_PTR to the address of an integer  
    **                 that contains the offset added to pointers to change 
    **                 binding of column data
    **             SQL_ATTR_CONCURRENCY to SQL_CONCUR_LOCK
    **             
    */

    /* Set the statement attribute SQL_ATTR_ROW_BIND_TYPE */
    rc = SQLSetStmtAttr (hstmt, SQL_ATTR_ROW_BIND_TYPE, (SQLPOINTER) sizeof(orderStruct), 0);
    if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 2 -- SQLSetStmtAttr failed for SQL_ATTR_ROW_BIND_TYPE\n"))
		goto Exit;

    /* Set the statement attribute SQL_ATTR_ROW_ARRAY_SIZE to the number of rows to be bound */
    rc = SQLSetStmtAttr (hstmt, SQL_ATTR_ROW_ARRAY_SIZE, (SQLPOINTER) NUM_OLD_ORDERS, 0);
    if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 2 -- SQLSetStmtAttr failed for SQL_ATTR_ROW_ARRAY_SIZE\n"))
		goto Exit;

    /* Set the statement attribute SQL_ATTR_ROW_BIND_OFFSET_PTR to the binding offset */
    rc = SQLSetStmtAttr (hstmt, SQL_ATTR_ROW_BIND_OFFSET_PTR, (SQLPOINTER) &bindOffset, 0);
    if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 2 -- SQLSetStmtAttr failed for SQL_ATTR_ROW_BIND_OFFSET_PTR\n"))
		goto Exit;

    /* Set the statement attribute SQL_ATTR_CONCURRENCY to SQL_CONCUR_LOCK */
    rc = SQLSetStmtAttr (hstmt, SQL_ATTR_CONCURRENCY, (SQLPOINTER) SQL_CONCUR_LOCK, 0);
    if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 2 -- SQLSetStmtAttr failed for SQL_ATTR_CONCURRENCY\n"))
		goto Exit;


	fprintf (stdout, "STEP 2 done...Statement attributes set\n");




	/* STEP 3.  Retrieve existing data in table 'orders'
    **          Bind the result set columns
    **          Display the results
    */

    /* Bind the result set columns */
    rc = SQLBindCol (hstmt, 1, SQL_C_LONG, &orders[0].order_num, 0, &orders[0].cbOrderNum);
    if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 3 -- SQLBindCol failed (column 1)\n"))
		goto Exit;

    rc = SQLBindCol (hstmt, 2, SQL_C_LONG, &orders[0].cust_num, 0, &orders[0].cbCustNum);
    if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 3 -- SQLBindCol failed (column 2)\n"))
		goto Exit;

    rc = SQLBindCol (hstmt, 3, SQL_C_LONG, &orders[0].item_num, 0, &orders[0].cbItemNum);
    if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 3 -- SQLBindCol failed (column 3)\n"))
		goto Exit;

    rc = SQLBindCol (hstmt, 4, SQL_C_CHAR, &orders[0].order_date, BUFFER_LEN, &orders[0].cbOrderDate);
    if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 3 -- SQLBindCol failed (column 4)\n"))
		goto Exit;

    rc = SQLBindCol (hstmt, 5, SQL_C_LONG, &orders[0].quantity, 0, &orders[0].cbQuantity);
    if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 3 -- SQLBindCol failed (column 5)\n"))
		goto Exit;


    /* Execute the SELECT statement */
    rc = SQLExecDirect (hstmt, selectStmt, SQL_NTS);
    if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 3 -- SQLExecDirect failed\n"))
    	goto Exit;


    /* Fetch and display the results */
    rc = SQLFetch (hstmt);
    if (rc == SQL_NO_DATA_FOUND)
    {
        fprintf (stdout, "NO DATA FOUND!!\n Exiting!!");
        goto Exit;
    }
    else if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 3 -- SQLFetch failed\n"))
	  	goto Exit;


    fprintf(stdout, "Retrieved rows from 'orders' table\n\n\n");

    for (i=0; i<NUM_OLD_ORDERS; i++) 
    {
        /* Display the results */
        fprintf (stdout, "Order Num: %d Cust Num: %d Item Num: %d Order Date %s Quantity: %d\n", 
                 orders[i].order_num, orders[i].cust_num, orders[i].item_num, orders[i].order_date, orders[i].quantity);
    }


	fprintf (stdout, "STEP 3 done...Existing data retrieved from table 'orders'\n");


    
    
    /* STEP 4.  Set the values of the orders array for the new rows to be inserted
	*/

    fprintf(stdout, "New values for data in the 'orders' table\n\n\n");

    for (i=0; i<NUM_NEW_ORDERS; i++)
    {
        orders[NUM_OLD_ORDERS+i].order_num = NUM_OLD_ORDERS+i+1;
        orders[NUM_OLD_ORDERS+i].cust_num = 101+(i%100);
        orders[NUM_OLD_ORDERS+i].item_num = 1001+(i%4);
        strcpy ((char *) orders[NUM_OLD_ORDERS+i].order_date, "1999-03-05");
        orders[NUM_OLD_ORDERS+i].quantity = i;


        orders[NUM_OLD_ORDERS+i].cbOrderNum = 0;
        orders[NUM_OLD_ORDERS+i].cbCustNum = 0;
        orders[NUM_OLD_ORDERS+i].cbItemNum = 0;
        orders[NUM_OLD_ORDERS+i].cbOrderDate = SQL_NTS;
        orders[NUM_OLD_ORDERS+i].cbQuantity = 0;
    }

    for (i=0; i<NUM_NEW_ORDERS; i++) 
    {
        /* Display the values */
        fprintf (stdout, "Order Num: %d Cust Num: %d Item Num: %d Order Date %s Quantity: %d\n", 
                 orders[NUM_OLD_ORDERS+i].order_num, orders[NUM_OLD_ORDERS+i].cust_num, orders[NUM_OLD_ORDERS+i].item_num, orders[NUM_OLD_ORDERS+i].order_date, orders[NUM_OLD_ORDERS+i].quantity);
    }



    fprintf (stdout, "STEP 4 done...Values of new rows set in orders array\n");



    /* STEP 5.  Change the bind offset
    **          Call SQLBulkOperations to insert the new rows
	*/
    
    /* Change the bid offset */
    bindOffset = NUM_OLD_ORDERS*sizeof(orderStruct);

    /* Call SQLBulkOperations */
    rc = SQLBulkOperations (hstmt, SQL_ADD);
    if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 5 -- SQLBulkOperations\n"))
		goto Exit;


    fprintf (stdout, "STEP 5 done...New rows inserted in table 'orders'\n");



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
