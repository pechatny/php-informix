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
*  Title:          descW.c (Unicode counterpart of desc.c)
*
*  Description:    To allocate a single descriptor and use it as the ARD
*                  for a SELECT statement and as the APD for an INSERT 
*                  statement.
*                  The data will be selected from the 'customer' table
*                  and inserted into a new table called 'new_cust'
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


#define BUFFER_LEN   10
#define BUFFER_LENW  BUFFER_LEN * sizeof(SQLWCHAR)
#define ERRMSG_LEN   200

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
    SQLHDBC     hdbc;
    SQLHENV     henv;
    SQLHSTMT    hTableStmt;
    SQLHSTMT    hSelectStmt;
    SQLHSTMT    hInsertStmt;
    SQLHDESC    hdesc;        


    /* Miscellaneous variables */

    SQLWCHAR    *dsnW;   /*name of the DSN used for connecting to the database*/
    SQLRETURN   rc = 0;
    SQLINTEGER  i, in;


    SQLWCHAR*    createTableStmtW = (SQLWCHAR *) L"CREATE TABLE new_cust( \
                                              cust_num      INTEGER,\
                                              fname         VARCHAR(10),\
                                              lname         VARCHAR(10))";

    SQLWCHAR*   selectStmtW = (SQLWCHAR *) L"SELECT cust_num, fname, lname \
                                          from customer where cust_num < 110";
    SQLWCHAR*   insertStmtW = (SQLWCHAR *) L"INSERT INTO new_cust (cust_num, \
                                          fname, lname) VALUES (?, ?, ?)";

    SQLINTEGER  custnumArray[9];           /*array to hold values of 'cust_num' from table 'customer'*/
    SQLCHAR     *fnameArray[9];
    SQLWCHAR    fnameArrayW[9][BUFFER_LEN]; /*array to hold values of 'fname' from table 'customer'*/
    SQLCHAR     *lnameArray[9];
    SQLWCHAR    lnameArrayW[9][BUFFER_LEN]; /*array to hold values of 'lname' from table 'customer'*/

    SQLINTEGER  newCustnum;                /*value of 'cust_num' from table 'new_cust'*/
    SQLCHAR     *newFname;
    SQLWCHAR    newFnameW[BUFFER_LEN];      /*value of 'fname' from table 'new_cust'*/
    SQLCHAR     *newLname;
    SQLWCHAR    newLnameW[BUFFER_LEN];      /*value of 'lname' from table 'new_cust'*/

    SQLLEN      cbCustnum = 0, cbFname = SQL_NTS, cbLname = SQL_NTS;
    int lenArgv1;
    
    
    /*  STEP 1. Get data source name from command line (or use default)
    **          Allocate the environment handle and set ODBC version
    **          Allocate the connection handle 
    **          Establish the database connection 
    **          Allocate the statement handles
    **          Allocate the descriptor handle
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
    rc = SQLConnectW (hdbc, dsnW, SQL_NTS, (SQLWCHAR *) L"", SQL_NTS, (SQLWCHAR *) L"", SQL_NTS);
	if (checkError (rc, SQL_HANDLE_DBC, hdbc, (SQLCHAR *) "Error in Step 1 -- SQLConnect failed\nExiting!!"))
		return (1);

    /* Allocate the statement handle for the CREATE TABLE statement */
    rc = SQLAllocHandle (SQL_HANDLE_STMT, hdbc, &hTableStmt);
    if (checkError (rc, SQL_HANDLE_DBC, hdbc, (SQLCHAR *) "Error in Step 1 -- Create Table Statement Handle Allocation failed\nExiting!!"))
		return (1);

    /* Allocate the statement handle for the SELECT statement */
    rc = SQLAllocHandle (SQL_HANDLE_STMT, hdbc, &hSelectStmt);
    if (checkError (rc, SQL_HANDLE_DBC, hdbc, (SQLCHAR *) "Error in Step 1 -- Select Statement Handle Allocation failed\nExiting!!"))
		return (1);
    
    /* Allocate the statement handle for the INSERT statement */
    rc = SQLAllocHandle (SQL_HANDLE_STMT, hdbc, &hInsertStmt);
    if (checkError (rc, SQL_HANDLE_DBC, hdbc, (SQLCHAR *) "Error in Step 1 -- Insert Statement Handle Allocation failed\nExiting!!"))
		return (1);
    
    /* Allocate the descriptor handle */
    rc = SQLAllocHandle (SQL_HANDLE_DESC, hdbc, &hdesc);
    if (checkError (rc, SQL_HANDLE_DBC, hdbc, (SQLCHAR *) "Error in Step 1 -- Insert Statement Handle Allocation failed\nExiting!!"))
		return (1);


	fprintf (stdout, "STEP 1 done...connected to database\n");



    /* STEP 2.  Create the database table 'new_cust' where the data is to be inserted
    */

    /* Execute the SQL statement to create the table 'new_cust' */
    rc = SQLExecDirectW (hTableStmt, createTableStmtW, SQL_NTS);
    if (checkError (rc, SQL_HANDLE_STMT, hTableStmt, (SQLCHAR *) "Error in Step 2 -- SQLExecDirect failed\n" ))
		goto Exit;

   	
	fprintf (stdout, "STEP 2 done...table new_cust created in the datbase\n");



    /* STEP 3.  For each column, set the following descriptor fields to appropriate values
    **          -- column 'cust_num' : descriptor fields - SQL_DESC_TYPE
    **          -- column 'fname'    : descriptor fields - SQL_DESC_TYPE, SQL_DESC_LENGTH, 
    **                                                     SQL_DESC_OCTET_LENGTH
    **          -- column 'lname'    : descriptor fields - SQL_DESC_TYPE, SQL_DESC_LENGTH, 
    **                                                     SQL_DESC_OCTET_LENGTH
    */

    /* Setting descriptor fields for column - cust_num */
    rc = SQLSetDescField (hdesc, 1, SQL_DESC_TYPE, (SQLPOINTER) SQL_C_SLONG, 0);
    if (checkError (rc, SQL_HANDLE_DESC, hdesc, (SQLCHAR *) "Error in Step 3 -- SQLSetDescField (SQL_DESC_DATA_TYPE) failed for column cust_num\n"))
        goto Exit;


    /* Setting descriptor fields for column - fname */
    rc = SQLSetDescFieldW (hdesc, 2, SQL_DESC_TYPE, (SQLPOINTER) SQL_C_WCHAR, 0);
    if (checkError (rc, SQL_HANDLE_DESC, hdesc, (SQLCHAR *) "Error in Step 3 -- SQLSetDescField (SQL_DESC_DATA_TYPE) failed for column fname\n"))
        goto Exit;

    rc = SQLSetDescField (hdesc, 2, SQL_DESC_LENGTH, (SQLPOINTER) BUFFER_LEN, 0);
    if (checkError (rc, SQL_HANDLE_DESC, hdesc, (SQLCHAR *) "Error in Step 3 -- SQLSetDescField (SQL_DESC_LENGTH) failed for column fname\n"))
        goto Exit;

    rc = SQLSetDescField (hdesc, 2, SQL_DESC_OCTET_LENGTH, (SQLPOINTER)(BUFFER_LENW), 0);
    if (checkError (rc, SQL_HANDLE_DESC, hdesc, (SQLCHAR *) "Error in Step 3 -- SQLSetDescField (SQL_DESC_OCTET_LENGTH) failed for column fname\n"))
        goto Exit;


    /* Setting descriptor fields for column - lname */
    rc = SQLSetDescFieldW (hdesc, 3, SQL_DESC_TYPE, (SQLPOINTER) SQL_C_WCHAR, 0);
    if (checkError (rc, SQL_HANDLE_DESC, hdesc, (SQLCHAR *) "Error in Step 3 -- SQLSetDescField (SQL_DESC_DATA_TYPE) failed for column lname\n"))
        goto Exit;

    rc = SQLSetDescField (hdesc, 3, SQL_DESC_LENGTH, (SQLPOINTER) BUFFER_LEN, 0);
    if (checkError (rc, SQL_HANDLE_DESC, hdesc, (SQLCHAR *) "Error in Step 3 -- SQLSetDescField (SQL_DESC_LENGTH) failed for column lname\n"))
        goto Exit;

    rc = SQLSetDescField (hdesc, 3, SQL_DESC_OCTET_LENGTH, (SQLPOINTER) (BUFFER_LENW), 0);
    if (checkError (rc, SQL_HANDLE_DESC, hdesc, (SQLCHAR *) "Error in Step 3 -- SQLSetDescField (SQL_DESC_OCTET_LENGTH) failed for column lname\n"))
        goto Exit;


	fprintf (stdout, "STEP 3 done...descriptor fields set for all columns\nRetrieving data from table 'customer'\n\n");




    /* STEP 4.  Set the explicitly allocated descriptor handle as the ARD for the select 
    **          statement's handle 
    **          Execute the SELECT statement
    **          Set the descriptor fields with the values returned by the SELECT statement
    **          Fetch the results
    **          Close the result set cursor
    */

    /* Set the explicitly allocated descriptor handle as the ARD for the select statement */
    rc = SQLSetStmtAttr (hSelectStmt, SQL_ATTR_APP_ROW_DESC, (SQLPOINTER) hdesc, 0);
    if (checkError (rc, SQL_HANDLE_STMT, hSelectStmt, (SQLCHAR *) "Error in Step 4 -- SQLSetStmtAttr failed\n"))
		goto Exit;

    /* Execute the SELECT statement */
    rc = SQLExecDirectW (hSelectStmt, selectStmtW, SQL_NTS);
    if (checkError (rc, SQL_HANDLE_STMT, hSelectStmt, (SQLCHAR *) "Error in Step 4 -- SQLExecDirect failed\n"))
    	goto Exit;


    for (i = 0; i < 9; i++)
    {
        /* Set the descriptor fields for the values being returned */
        rc = SQLSetDescField (hdesc, 1, SQL_DESC_DATA_PTR, &(custnumArray[i]), sizeof(custnumArray[i])/*SQL_IS_INTEGER*/);
        if (checkError (rc, SQL_HANDLE_DESC, hdesc, (SQLCHAR *) "Error in Step 4 -- SQLSetDescField failed for column cust_num\n"))
            goto Exit;

        rc = SQLSetDescFieldW (hdesc, 2, SQL_DESC_DATA_PTR, fnameArrayW[i], BUFFER_LEN);
        if (checkError (rc, SQL_HANDLE_DESC, hdesc, (SQLCHAR *) "Error in Step 4 -- SQLSetDescField failed for column fname\n"))
            goto Exit;
        
        rc = SQLSetDescFieldW (hdesc, 3, SQL_DESC_DATA_PTR, lnameArrayW[i], BUFFER_LEN);
        if (checkError (rc, SQL_HANDLE_DESC, hdesc, (SQLCHAR *) "Error in Step 4 -- SQLSetDescField failed for column lname\n"))
            goto Exit;

        /* Fetch the results */
        rc = SQLFetch (hSelectStmt);
       	if (rc == SQL_NO_DATA_FOUND)
	        break;
        else if (checkError (rc, SQL_HANDLE_STMT, hSelectStmt, (SQLCHAR *) "Error in Step 4 -- SQLFetch failed\n"))
	    	goto Exit;


        /* Display the results */
        fnameArray[i] = (SQLCHAR *) malloc (wcslen(fnameArrayW[i]) + sizeof(char));
        wcstombs( (char *) fnameArray[i], fnameArrayW[i], wcslen(fnameArrayW[i])
                                                    + sizeof(char));
        lnameArray[i] = (SQLCHAR *) malloc (wcslen(lnameArrayW[i]) + sizeof(char));
        wcstombs( (char *) lnameArray[i], lnameArrayW[i], wcslen(lnameArrayW[i])
                                                    + sizeof(char));
        fprintf (stdout, "Row retrieved from table 'customer' is - cust_num=%d, fname=%s, lname=%s\n", 
                 custnumArray[i], fnameArray[i], lnameArray[i]);
   }


    /* Close the result set cursor */
    rc = SQLCloseCursor (hSelectStmt);
    if (checkError (rc, SQL_HANDLE_STMT, hSelectStmt, (SQLCHAR *) "Error in Step 4 -- SQLCloseCursor failed\n"))
		goto Exit;


	fprintf (stdout, "\n\nSTEP 4 done...SELECT statement executed...descriptor fields set with data retrieved\n");



   	/* STEP 5.  Set the explicitly allocated descriptor handle as the APD for the INSERT 
    **          statement's handle 
    **          Bind the input parameters for the INSERT statement
    **          For each row, set the SQL_DESC_DATA_PTR field to the value in the allocated
    **          arrays and execute the INSERT statement
    */

    /* Set the explicitly allocated descriptor handle as the APD for the INSERT statement */
    rc = SQLSetStmtAttr (hInsertStmt, SQL_ATTR_APP_PARAM_DESC, (SQLPOINTER) hdesc, 0);
    if (checkError (rc, SQL_HANDLE_STMT, hInsertStmt, (SQLCHAR *) "Error in Step 5 -- SQLSetStmtAttr failed\n"))
		goto Exit;

    /* Bind the input parameters for the INSERT statement */
    rc = SQLBindParameter (hInsertStmt, 1, SQL_PARAM_INPUT, SQL_C_SLONG, SQL_INTEGER, 
                           0, 0, &(custnumArray[i]), sizeof(custnumArray[i]), &cbCustnum);
    if (checkError (rc, SQL_HANDLE_STMT, hInsertStmt, (SQLCHAR *) "Error in Step 5 -- SQLBindParameter failed (param 1)\n"))
		goto Exit;

    rc = SQLBindParameter (hInsertStmt, 2, SQL_PARAM_INPUT, SQL_C_WCHAR, SQL_VARCHAR, BUFFER_LEN, 
                           0, fnameArrayW[i], BUFFER_LENW, &cbFname);
    if (checkError (rc, SQL_HANDLE_STMT, hInsertStmt, (SQLCHAR *) "Error in Step 5 -- SQLBindParameter failed (param 2)\n"))
		goto Exit;

    rc = SQLBindParameter (hInsertStmt, 3, SQL_PARAM_INPUT, SQL_C_WCHAR, SQL_VARCHAR, BUFFER_LEN, 
                           0, lnameArrayW[i], BUFFER_LENW,  &cbLname);
    if (checkError (rc, SQL_HANDLE_STMT, hInsertStmt, (SQLCHAR *) "Error in Step 5 -- SQLBindParameter failed (param 3)\n"))
		goto Exit;
    
    /* For each row, set the SQL_DESC_DATA_PTR field and execute the INSERT statement */
    for (i = 0; i < 9; i++)
    {
        rc = SQLSetDescField (hdesc, 1, SQL_DESC_DATA_PTR, &(custnumArray[i]), sizeof(custnumArray[i]));
        if (checkError (rc, SQL_HANDLE_DESC, hdesc, (SQLCHAR *) "Error in Step 5 -- SQLSetDescField failed for column cust_num\n"))
            goto Exit;

        rc = SQLSetDescFieldW (hdesc, 2, SQL_DESC_DATA_PTR, fnameArrayW[i], BUFFER_LEN);
        if (checkError (rc, SQL_HANDLE_DESC, hdesc, (SQLCHAR *) "Error in Step 5 -- SQLSetDescField failed for column fname\n"))
            goto Exit;
       
        rc = SQLSetDescFieldW (hdesc, 3, SQL_DESC_DATA_PTR, lnameArrayW[i], BUFFER_LEN);
        if (checkError (rc, SQL_HANDLE_DESC, hdesc, (SQLCHAR *) "Error in Step 5 -- SQLSetDescField failed for column lname\n"))
            goto Exit;

        /* Execute the INSERT statement */
        rc = SQLExecDirectW (hInsertStmt, insertStmtW, SQL_NTS);
        if (checkError (rc, SQL_HANDLE_STMT, hInsertStmt, (SQLCHAR *) "Error in Step 5 -- SQLExecDirect failed\n"))
	    	goto Exit;
    }


	fprintf (stdout, "STEP 5 done...data inserted into table new_cust\n");
    fprintf (stdout, "\nRetrieving data from table 'new_cust'...\nHit <Enter> to continue...\n");
    in = getchar ();
   	
    
    
    /* STEP 6.  Execute the SELECT statement to retrieve data from 
    **          table 'new_cust'
    **          Bind the result set columns
    **          Fetch and display the data
    */


    /* Execute the SELECT statement */
    rc = SQLExecDirectW (hSelectStmt, (SQLWCHAR *) L"SELECT * FROM new_cust", SQL_NTS);
    if (checkError (rc, SQL_HANDLE_STMT, hSelectStmt, (SQLCHAR *) "Error in Step 6 -- SQLExecDirect failed\n"))
    	goto Exit;

    /* Bind the result set columns */
    rc = SQLBindCol (hSelectStmt, 1, SQL_C_LONG, &newCustnum, sizeof(newCustnum), &cbCustnum);
    if (checkError (rc, SQL_HANDLE_STMT, hSelectStmt, (SQLCHAR *) "Error in Step 6 -- SQLBindCol failed (column 1)\n"))
    	goto Exit;
    
    rc = SQLBindCol (hSelectStmt, 2, SQL_C_WCHAR, newFnameW, BUFFER_LENW, &cbFname);
    if (checkError (rc, SQL_HANDLE_STMT, hSelectStmt, (SQLCHAR *) "Error in Step 6 -- SQLBindCol failed (column 2)\n"))
    	goto Exit;
    
    rc = SQLBindCol (hSelectStmt, 3, SQL_C_WCHAR, newLnameW, BUFFER_LENW, &cbLname);
    if (checkError (rc, SQL_HANDLE_STMT, hSelectStmt, (SQLCHAR *) "Error in Step 6 -- SQLBindCol failed (column 3)\n"))
    	goto Exit;
    
    /* Fetch and display the data retrieved */
    while (1)
    {
        /* Fetch the results */
        rc = SQLFetch (hSelectStmt);
       	if (rc == SQL_NO_DATA_FOUND)
	        break;
        else if (checkError (rc, SQL_HANDLE_STMT, hSelectStmt, (SQLCHAR *) "Error in Step 6 -- SQLFetch failed\n"))
	    	goto Exit;

        /* Display the results */
        newFname = (SQLCHAR *) malloc (wcslen(newFnameW) + sizeof(char));
        wcstombs( (char *) newFname, newFnameW, wcslen(newFnameW)
                                                    + sizeof(char));
        newLname = (SQLCHAR *) malloc (wcslen(newLnameW) + sizeof(char));
        wcstombs( (char *) newLname, newLnameW, wcslen(newLnameW)
                                                    + sizeof(char));
        fprintf (stdout, "Row retrieved from table 'new_cust' is - cust_num=%d, fname=%s, lname=%s\n", newCustnum, newFname, newLname);
   }


    /* Close the result set cursor */
    rc = SQLCloseCursor (hSelectStmt);
    if (checkError (rc, SQL_HANDLE_STMT, hSelectStmt, (SQLCHAR *) "Error in Step 6 -- SQLCloseCursor failed\n"))
		goto Exit;


	fprintf (stdout, "\n\nSTEP 6 done...SELECT statement executed...data retrieved from table 'new_cust'\n");



    Exit:

    /* CLEANUP: Drop table 'new_cust' from the database
    **          Close the statement handle
    **          Free the statement handle
    **          Disconnect from the datasource
    **          Free the connection and environment handles
    **          Exit
    */

    SQLExecDirectW (hTableStmt, (SQLWCHAR *) L"DROP TABLE new_cust", SQL_NTS);

    /* Close all the statement handles */
    SQLFreeStmt (hTableStmt, SQL_CLOSE);
    SQLFreeStmt (hSelectStmt, SQL_CLOSE);
    SQLFreeStmt (hInsertStmt, SQL_CLOSE);

    /* Free all the statement handles */
    SQLFreeHandle (SQL_HANDLE_STMT, hTableStmt);
    SQLFreeHandle (SQL_HANDLE_STMT, hSelectStmt);
    SQLFreeHandle (SQL_HANDLE_STMT, hInsertStmt);

    /* Free the descriptor handle */
    SQLFreeHandle (SQL_HANDLE_DESC, hdesc);

	/* Disconnect from the data source */
    SQLDisconnect (hdbc);

    /* Free the environment handle and the database connection handle */
    SQLFreeHandle (SQL_HANDLE_DBC, hdbc);
    SQLFreeHandle (SQL_HANDLE_ENV, henv);

    fprintf (stdout,"\n\nHit <Enter> to terminate the program...\n\n");
    in = getchar ();
    return (rc);
}
