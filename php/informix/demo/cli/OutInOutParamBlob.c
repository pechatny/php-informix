/***************************************************************************
*    Licensed Materials - Property of IBM
*
*    "Restricted Materials of IBM"
*
*    IBM Informix Client SDK
*
*    (C) Copyright IBM Corporation 2010 All rights reserved.
*
*  Title:          OutInOutParamBlob.c
*
*  Description:    OUT/INOUT parameters demo with BLOB, INTEGER and VARCHAR data types.
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

SQLCHAR  defDsn[] = "odbc_demo";

SQLINTEGER checkError (SQLRETURN      rc,
                SQLSMALLINT    handleType,
                SQLHANDLE      handle,
                SQLCHAR*            errmsg)
{
    SQLRETURN      retcode = SQL_SUCCESS;

    SQLSMALLINT    errNum = 1;
    SQLCHAR            sqlState[6];
    SQLINTEGER      nativeError;
    SQLCHAR            errMsg[ERRMSG_LEN];
    SQLSMALLINT    textLengthPtr;


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
        return 1;  /* all errors on this handle have been reported */
    }
    else
        return 0;    /* no errors to report */
}

int main(int argc, char *argv[])
{
    /* Declare variables
    */

    /* Handles */
    HENV              henv = NULL;
    HDBC              hdbc = NULL;
    HSTMT            hstmt = NULL;
    SQLHDESC          hdesc = NULL;

    /* Miscellaneous variables */

    SQLCHAR      dsn[20];  /*name of the DSN used for connecting to the database*/
    SQLRETURN    rc = 0;
    SQLINTEGER    in;

    int sParm1 = 123;
    int sParm2 = 456;
    int sParm3 = 789, cmpParm3 = 789;
    int len=0;
    SQLLEN cbParm1 = SQL_NTS;
    SQLLEN cbParm2 = SQL_NTS;
    SQLLEN cbParm3 = SQL_NULL_DATA;
    SQLLEN cbParm4 = SQL_NTS;
    SQLLEN cbParm5 = SQL_NULL_DATA;
    SQLLEN cbParm6 = SQL_NTS;
    SQLCHAR schar[20] = {0};
    SQLCHAR blob_buffer[BUFFER_LEN] = {0};

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


    /* Establish the database connection */
    rc = SQLConnect (hdbc, dsn, SQL_NTS, (SQLCHAR *) "", SQL_NTS, (SQLCHAR *) "", SQL_NTS);
    if (checkError (rc, SQL_HANDLE_DBC, hdbc, (SQLCHAR *) "Error in Step 1 -- SQLConnect failed\nExiting!!"))
        return (1);

    /* Allocate the statement handles */
    rc = SQLAllocHandle( SQL_HANDLE_STMT, hdbc, &hstmt );
    if (checkError (rc, SQL_HANDLE_DBC, hdbc, (SQLCHAR *) "Error in Step 1 -- Statement Handle Allocation failed\nExiting!!"))
        return (1);

    fprintf (stdout, "STEP 1 done...connected to database\n");

    /*********************************************************************/
    /* tests involving procedures that has OUT/INOUT params and also returns single value */
    /*********************************************************************/
    /* Drop procedure */
    SQLExecDirect(hstmt, (UCHAR *)"drop procedure spl_out_param_blob;", SQL_NTS);
    SQLExecDirect(hstmt, (UCHAR *)"drop table tab_blob;", SQL_NTS);

    /* Create table with BLOB column */
    rc = SQLExecDirect(hstmt, (UCHAR *)"create table tab_blob(c_blob BLOB, c_int INTEGER, c_char varchar(20));", SQL_NTS);
    if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 2 -- SQLExecDirect failed\n"))
        goto Exit;

    /* Insert one row into the table */
    rc = SQLExecDirect(hstmt, (UCHAR *)"insert into tab_blob values(filetoblob('insert.txt', 'c'), 10, 'blob_test');", SQL_NTS);
    if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 2 -- SQLExecDirect failed\n"))
        goto Exit;

    /* Create procedure */
    rc = SQLExecDirect(hstmt, "CREATE PROCEDURE spl_out_param_blob(inParam int, OUT blobparam BLOB, OUT intparam int, OUT charparam varchar(20)) \n"
                              "returning integer; \n"
                              "select c_blob, c_int, c_char into blobparam, intparam, charparam from tab_blob; \n"
                              "return inParam; \n"
                              "end procedure; ",
                              SQL_NTS);
    if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 2 -- SQLExecDirect failed\n"))
        goto Exit;

    /* Prepare stored procedure to be executed */
    rc = SQLPrepare(hstmt, (UCHAR *)"{? = call spl_out_param_blob(?, ?, ?, ?)}", SQL_NTS);
    if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 2 -- SQLPrepare failed\n"))
        goto Exit;

    /* Bind the required parameters */
    rc = SQLBindParameter(hstmt, 1, SQL_PARAM_OUTPUT, SQL_C_LONG, SQL_INTEGER, 3, 0, &sParm1, 0, &cbParm1);
    if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 2 -- SQLBindParameter 1 failed\n"))
        goto Exit;

    rc = SQLBindParameter(hstmt, 2, SQL_PARAM_INPUT, SQL_C_LONG, SQL_INTEGER, 10, 0, &sParm2, 0, &cbParm2);
    if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 2 -- SQLBindParameter 2 failed\n"))
        goto Exit;

    rc = SQLBindParameter(hstmt, 3, SQL_PARAM_OUTPUT, SQL_C_BINARY, SQL_LONGVARBINARY, sizeof(blob_buffer), 0, blob_buffer, sizeof(blob_buffer), &cbParm3);
    if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 2 -- SQLBindParameter 3 failed\n"))
        goto Exit;

    rc = SQLBindParameter(hstmt, 4, SQL_PARAM_OUTPUT, SQL_C_LONG, SQL_INTEGER, 10, 0, &sParm3, 0, &cbParm4);
    if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 2 -- SQLBindParameter 4 failed\n"))
        goto Exit;

    rc = SQLBindParameter (hstmt, 5, SQL_PARAM_OUTPUT, SQL_C_CHAR, SQL_VARCHAR, sizeof(schar), 0, schar, sizeof(schar), &cbParm6);
    if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 2 -- SQLBindParameter 5 failed\n"))
        goto Exit;

    /* Exeute the prepared stored procedure */
    rc = SQLExecute(hstmt);
    if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 2 -- SQLExecute failed\n"))
        goto Exit;

    len = strlen("123456789abcdefghijklmnopqrstuvwxyz1234567890123456789012345678901234567890 ");

    if( (sParm2 != sParm1) || (10 != sParm3) || (strcmp("blob_test", schar)) || (cbParm3 != len) )
    {
        fprintf(stdout, "\n 1st Data compare failed!");
        goto Exit;
    }
    else
    {
        fprintf(stdout, "\n 1st Data compare successful");
    }

    /* Reset the parameters */
    rc = SQLFreeStmt(hstmt, SQL_RESET_PARAMS);
    if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 3 -- SQLFreeStmt failed\n"))
        goto Exit;

    /* Reset variables */
    sParm1 = 0;
    cbParm6 = cbParm1 = SQL_NTS;
    cbParm3 = SQL_NULL_DATA;
    schar[0]=0;
    blob_buffer[0]=0;

    /*********************************************************************/
    /* tests involving procedures that has OUT/INOUT params no RETURN values */
    /*********************************************************************/

    SQLExecDirect(hstmt, (UCHAR *)"drop procedure out_param_blob;", SQL_NTS);
    SQLExecDirect(hstmt, (UCHAR *)"drop table tab_blob1;", SQL_NTS);

    rc = SQLExecDirect(hstmt, (UCHAR *)"create table tab_blob1(c_blob BLOB, c_int INTEGER, c_char varchar(20));", SQL_NTS);
    if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 3 -- SQLExecDirect failed\n"))
        goto Exit;

    rc = SQLExecDirect(hstmt, (UCHAR *)"insert into tab_blob1 values(filetoblob('insert.txt', 'c'), 10, 'blob_test1');", SQL_NTS);
    if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 3 -- SQLExecDirect failed\n"))
        goto Exit;

    rc = SQLExecDirect(hstmt, "CREATE PROCEDURE out_param_blob(OUT blobparam BLOB, OUT intparam int, OUT charparam varchar(20)) \n"
                              "select c_blob, c_int, c_char into blobparam, intparam, charparam from tab_blob1; \n"
                              "end procedure; ",
                              SQL_NTS);
    if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 3 -- SQLExecDirect failed\n"))
        goto Exit;

    rc = SQLPrepare(hstmt, (UCHAR *)"{call out_param_blob(?, ?, ?)}", SQL_NTS);
    if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 3 -- SQLExecDirect failed\n"))
        goto Exit;

    /* Bind the parameters */
    rc = SQLBindParameter(hstmt, 1, SQL_PARAM_OUTPUT, SQL_C_BINARY, SQL_LONGVARBINARY, sizeof(blob_buffer), 0, blob_buffer, sizeof(blob_buffer), &cbParm3);
    if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 3 -- SQLBindParameter 1 failed\n"))
        goto Exit;

    rc = SQLBindParameter(hstmt, 2, SQL_PARAM_OUTPUT, SQL_C_LONG, SQL_INTEGER, 3, 0, &sParm1, 0, &cbParm1);
    if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 3 -- SQLBindParameter 2 failed\n"))
        goto Exit;

    rc = SQLBindParameter (hstmt, 3, SQL_PARAM_OUTPUT, SQL_C_CHAR, SQL_VARCHAR, sizeof(schar), 0, schar, sizeof(schar), &cbParm6);
    if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 3 -- SQLBindParameter 3 failed\n"))
        goto Exit;

    rc = SQLExecute(hstmt);
    if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 3 -- SQLExecute failed\n"))
        goto Exit;

    /* The below data has been inserted (from insert.txt file), hence verify(lenth) the OUT value against the same */
    len = strlen("123456789abcdefghijklmnopqrstuvwxyz1234567890123456789012345678901234567890 ");

    if( (10 != sParm1) || (strcmp("blob_test1", schar)) || (cbParm3 != len) )
    {
        fprintf(stdout, "\n 2nd Data compare failed!");
        goto Exit;
    }
    else
    {
        fprintf(stdout, "\n 2nd Data compare successful");
    }

    rc = SQLFreeStmt(hstmt, SQL_RESET_PARAMS);
    if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 3 -- SQLFreeStmt failed\n"))
        goto Exit;

    /* Reset variables */
    sParm1 = 0;
    cbParm6 = cbParm1 = SQL_NTS;
    cbParm3 = SQL_NULL_DATA;
    schar[0]=0;
    blob_buffer[0]=0;

    /*********************************************************************/
    /* tests involving procedures that has OUT/INOUT params no RETURN value and with NULL data for BLOB */
    /*********************************************************************/

    SQLExecDirect(hstmt, (UCHAR *)"drop procedure out_param_blob1;", SQL_NTS);
    SQLExecDirect(hstmt, (UCHAR *)"drop table tab_blob2;", SQL_NTS);

    rc = SQLExecDirect(hstmt, (UCHAR *)"create table tab_blob2(c_blob BLOB, c_int INTEGER, c_char varchar(20));", SQL_NTS);
    if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 4 -- SQLExecDirect failed\n"))
        goto Exit;

    rc = SQLExecDirect(hstmt, (UCHAR *)"insert into tab_blob2 values(filetoblob('insert.txt', 'c'), 10, 'blob_test2');", SQL_NTS);
    if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 4 -- SQLExecDirect failed\n"))
        goto Exit;

    rc = SQLExecDirect(hstmt, "CREATE PROCEDURE out_param_blob1(OUT blobparam BLOB, OUT intparam int, OUT charparam varchar(20)) \n"
                              "select c_int, c_char into intparam, charparam from tab_blob2; \n"
                              "let blobparam = null; \n"
                              "end procedure; ",
                              SQL_NTS);
    if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 4 -- SQLExecDirect failed\n"))
        goto Exit;

    rc = SQLPrepare(hstmt, (UCHAR *)"{call out_param_blob1(?, ?, ?)}", SQL_NTS);
    if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 4 -- SQLPrepare failed\n"))
        goto Exit;

    rc = SQLBindParameter(hstmt, 1, SQL_PARAM_OUTPUT, SQL_C_BINARY, SQL_LONGVARBINARY, sizeof(blob_buffer), 0, blob_buffer, sizeof(blob_buffer), &cbParm3);
    if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 4 -- SQLBindParameter 1 failed\n"))
        goto Exit;

    rc = SQLBindParameter(hstmt, 2, SQL_PARAM_OUTPUT, SQL_C_LONG, SQL_INTEGER, 3, 0, &sParm1, 0, &cbParm1);
    if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 4 -- SQLBindParameter 2 failed\n"))
        goto Exit;

    rc = SQLBindParameter (hstmt, 3, SQL_PARAM_OUTPUT, SQL_C_CHAR, SQL_VARCHAR, sizeof(schar), 0, schar, sizeof(schar), &cbParm6);
    if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 4 -- SQLBindParameter 3 failed\n"))
        goto Exit;

    rc = SQLExecute(hstmt);
    if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 4 -- SQLExecute failed\n"))
        goto Exit;

    if( (10 != sParm1) || (strcmp("blob_test2", schar)) || (cbParm3 != SQL_NULL_DATA) )
    {
        fprintf(stdout, "\n 3rd Data compare failed!");
        goto Exit;
    }
    else
    {
        fprintf(stdout, "\n 3rd Data compare successful");
    }

Exit:
    /* CLEANUP: Close the statement handles
    **          Free the statement handles
    **          Disconnect from the datasource
    **          Free the connection and environment handles
    **          Exit
    */
    SQLFreeHandle(SQL_HANDLE_STMT, hstmt);
    SQLDisconnect(hdbc);
    SQLFreeHandle(SQL_HANDLE_DBC, hdbc);
    SQLFreeHandle(SQL_HANDLE_ENV, henv);

    fprintf (stdout,"\n\nHit <Enter> to terminate the program...\n\n");
    in = getchar ();
    return (rc);
}

