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
*  Title:          dbcreateW.c (Unicode counterpart of dbcreate.c)
*
*  Description:  To create & populate the sample database. The schema
*                  for the sample database is as follows -
*
*  For servers supporting UDO (version no. > 9)
*
*	Database - odbc_demodb (with log)
*
*      Table - CUSTOMER
*          cust_num	      INTEGER, PRIMARY KEY
*          fname   		  VARCHAR(10)
*          lname	      VARCHAR(10)
*          address		  ROW (address1	VARCHAR(20),
*			                   city		VARCHAR(15),
*			                   state	VARCHAR(5),
*			                   zip		VARCHAR(6)
*                             )
*          contact_dates  LIST (DATETIME YEAR TO DAY NOT NULL)
*
*
*      Table - ITEM
*	       item_num	      INTEGER, PRIMARY KEY
*          description	  VARCHAR(20)
*	       stock		  SMALLINT
*	       ship_unit	  VARCHAR(10)
*	       advert		  CLOB
*	       unit_price	  DISTINCT TYPE dollar
*
*
*      Table - ORDERS
*	       order_num	  INTEGER, PRIMARY KEY
*	       cust_num	      INTEGER, FOREIGN KEY, REFERENCES customer(customer_num)
*          item_num	      INTEGER, FOREIGN KEY, REFERENCES item(item_num)
*          order_date	  DATE
*          quantity		  INTEGER
*
*
*
*  For servers not supporting UDO (version no. < 9)
*
*	Database - odbc_demodb (with log)
*
*      Table - CUSTOMER
*          cust_num	      INTEGER, PRIMARY KEY
*          fname		  VARCHAR(10)
*          lname		  VARCHAR(10)
*          address1       VARCHAR(20)
*          city           VARCHAR(15)
*          state          VARCHAR(5)
*          zip            VARCHAR(6)
*          first_contact  DATETIME YEAR TO DAY
*          last_contact   DATETIME YEAR TO DAY
*
*
*      Table - ITEM
*          item_num	      INTEGER, PRIMARY KEY
*      	   description	  VARCHAR(20)
*          stock		  SMALLINT
*      	   ship_unit	  VARCHAR(10)
*          advert         VARCHAR(100)
*      	   unit_price	  DECIMAL
*
*
*      Table - ORDERS
*      	   order_num	  INTEGER, PRIMARY KEY
*      	   cust_num	      INTEGER, FOREIGN KEY, REFERENCES customer(customer_num)
*          item_num	      INTEGER, FOREIGN KEY, REFERENCES item(item_num)
*          order_date	  DATE
*          quantity		  INTEGER
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
#include "dbcreateW.h"

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
    SQLWCHAR		 sqlStateW[6];
    SQLCHAR		    *sqlState;
    SQLINTEGER     nativeError;
    SQLWCHAR		 errMsgW[ERRMSG_LEN];
    SQLCHAR		    *errMsg;
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
                sqlState = (SQLCHAR *) malloc (wcslen(sqlStateW) + sizeof(char));
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

    SQLCHAR        *dsn;   /*name of the DSN used for connecting to the database*/
    SQLWCHAR        *dsnW;   /*name of the DSN used for connecting to the database*/
    SQLRETURN       rc = 0;
    SQLINTEGER		  i, in;


    SQLWCHAR        connStrInW[BUFFER_LEN];
    SQLWCHAR        connStrOutW[BUFFER_LEN];
    SQLSMALLINT     connStrOutLen;


    SQLCHAR         *verInfoBuffer;
    SQLWCHAR        verInfoBufferW[BUFFER_LEN];
    SQLSMALLINT	  verInfoLen;
    SQLWCHAR        majorVerW[3];
    SQLINTEGER      isUdoEnabled;

    SQLWCHAR        insertStmtW[BUFFER_LEN];
    int             lenArgv1;



    /*  STEP 1. Get data source name from command line (or use default)
    **          Allocate the environment handle and set ODBC version
    **          Allocate the connection handle
    **          Establish the database connection
    **          Allocate the statement handle
    **          Drop demo database if it already exists
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
    if (checkError (rc, SQL_HANDLE_ENV, henv, (SQLCHAR *) "Error in Step 1 -- SQLSetEnvAttr failed\nExiting!!"))
        return (1);


    /* Allocate the connection handle */
    rc = SQLAllocHandle (SQL_HANDLE_DBC, henv, &hdbc);
    if (checkError (rc, SQL_HANDLE_ENV, henv, (SQLCHAR *) "Error in Step 1 -- Connection Handle Allocation failed\nExiting!!"))
        return (1);


    /* Establish the database connection */
#ifndef _WINNT
    wsprintf((SQLWCHAR *) connStrInW, "DSN=%s;connectdatabase=NO", dsn);
#else
    swprintf((SQLWCHAR *) connStrInW, L"DSN=%s;connectdatabase=NO", dsnW);
#endif

    rc = SQLDriverConnectW (hdbc, NULL, connStrInW, SQL_NTS, connStrOutW, BUFFER_LEN, &connStrOutLen, SQL_DRIVER_NOPROMPT);
    if (checkError (rc, SQL_HANDLE_DBC, hdbc, (SQLCHAR *) "Error in Step 1 -- SQLDriverConnect failed\nExiting!!"))
        return (1);


    /* Allocate the statement handle */
    rc = SQLAllocHandle (SQL_HANDLE_STMT, hdbc, &hstmt );
    if (checkError (rc, SQL_HANDLE_DBC, hdbc, (SQLCHAR *) "Error in Step 1 -- Statement Handle Allocation failed\nExiting!!"))
        return (1);


    /* Drop demo database if it already exists */
    rc = SQLExecDirectW (hstmt, (SQLWCHAR*) L"DROP DATABASE odbc_demodb", SQL_NTS);


    fprintf (stdout, "STEP 1 done...connected to database server\n");




    /* STEP 2.  Get version information from the database server
    **          Set the value of isUdoEnabled depending on the database version returned
    */

    /* Get version information from the database server */
    rc = SQLGetInfoW (hdbc, SQL_DBMS_VER, verInfoBufferW, BUFFER_LEN, &verInfoLen);
    if (checkError (rc, SQL_HANDLE_DBC, hdbc, (SQLCHAR *) "Error in Step 2 -- SQLGetInfo failed\n"))
        goto Exit;

    /* Set the value of isUDOEnabled */
    wcsncpy ((SQLWCHAR *) majorVerW, (SQLWCHAR *) verInfoBufferW, 2);
    if (wcsncmp(majorVerW, L"09", 2) >= 0 )
        isUdoEnabled = 1;
    else
        isUdoEnabled = 0;


    verInfoBuffer = (SQLCHAR *) malloc (wcslen(verInfoBufferW) + sizeof(char));
    wcstombs( (char *) verInfoBuffer, verInfoBufferW, wcslen(verInfoBufferW)
              + sizeof(char));
    fprintf (stdout, "STEP 2 done...Database Version -- %s\n", verInfoBuffer);




    /* STEP 3.  Execute the SQL statements to create the database
    **          (depending on the version of the database server)
    */

    if (isUdoEnabled)
    {
        fprintf (stdout, "Creating UDO database\n");

        for (i = 0; i < NUM_DBCREATE_STMTS; i++)
        {
            fprintf (stdout, "Executing stmt %d of %d\n", i+1, NUM_DBCREATE_STMTS);

            rc = SQLExecDirectW (hstmt, createUdoDbStmtsW[i], SQL_NTS);
            if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 3 -- SQLExecDirect failed\n"))
                goto Exit;
        }
    }
    else
    {
        fprintf (stdout, "Creating non-UDO database\n");

        for (i = 0; i < NUM_DBCREATE_STMTS -1; i++)
        {
            fprintf (stdout, "Executing stmt %d\n", i+1, NUM_DBCREATE_STMTS -1);

            rc = SQLExecDirectW (hstmt, createNonUdoDbStmtsW[i], SQL_NTS);
            if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 3 -- SQLExecDirect failed\n"))
                goto Exit;
        }
    }


    fprintf (stdout, "STEP 3 done...Sample Database Created\n");




    /* STEP 4.  Construct the INSERT statement for table 'customer'
    **          Insert data into the table 'customer'. The data inserted depends on
    **          whether the database created is UDO or non-UDO enabled
    */

    fprintf (stdout, "Populating table 'customer'\n");

    for (i = 0; i < NUM_CUSTOMERS; i++)
    {
        fprintf (stdout, "Inserting row # %d\n", i+1);

        /* Construct the INSERT statement for table 'customer' */
        wcscpy ((SQLWCHAR *) insertStmtW, (SQLWCHAR *) insertDBStmtsW[0]);

        if (isUdoEnabled)
            wcscat ((SQLWCHAR *) insertStmtW, (SQLWCHAR *) udoCustW[i]);
        else
            wcscat ((SQLWCHAR *) insertStmtW, (SQLWCHAR *) nonUdoCustW[i]);

        /* Execute the INSERT statement */
        rc = SQLExecDirectW (hstmt, insertStmtW, SQL_NTS);
        if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 4 -- SQLExecDirect failed\n"))
            goto Exit;
    }


    fprintf (stdout, "STEP 4 done...Data inserted into the 'customer' table\n");




    /* STEP 5.  Construct the INSERT statement for table 'item'
    **          Insert data into the table 'item'. The data inserted depends on
    **          whether the database created is UDO or non-UDO enabled
    */

    fprintf (stdout, "Populating table 'item'\n");

    for (i = 0; i < NUM_ITEMS; i++)
    {
        fprintf (stdout, "Inserting row # %d\n", i+1);

        /* Construct the INSERT statement for table 'item' */
        wcscpy ((SQLWCHAR *) insertStmtW, (SQLWCHAR *) insertDBStmtsW[1]);

        if (isUdoEnabled)
            wcscat ((SQLWCHAR *) insertStmtW, (SQLWCHAR *) udoItemW[i]);
        else
            wcscat ((SQLWCHAR *) insertStmtW, (SQLWCHAR *) nonUdoItemW[i]);

        /* Execute the INSERT statement */
        rc = SQLExecDirectW (hstmt, insertStmtW, SQL_NTS);
        if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 5 -- SQLExecDirect failed\n"))
            goto Exit;
    }


    fprintf (stdout, "STEP 5 done...Data inserted into the 'item' table\n");




    /* STEP 6.  Construct the INSERT statement for table 'orders'
    **          Insert data into the table 'orders'.
    */

    fprintf (stdout, "Populating table 'orders'\n");

    for (i = 0; i < NUM_ORDERS; i++)
    {
        fprintf (stdout, "Inserting row # %d\n", i+1);

        /* Construct the INSERT statement for table 'orders' */
        wcscpy ((SQLWCHAR *) insertStmtW, (SQLWCHAR *) insertDBStmtsW[2]);
        wcscat ((SQLWCHAR *) insertStmtW, (SQLWCHAR *) ordersW[i]);

        /* Execute the INSERT statement */
        rc = SQLExecDirectW (hstmt, insertStmtW, SQL_NTS);
        if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 6 -- SQLExecDirect failed\n"))
            goto Exit;
    }


    fprintf (stdout, "STEP 6 done...Data inserted into the 'orders' table\n");



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
