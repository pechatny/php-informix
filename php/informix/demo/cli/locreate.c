/***************************************************************************
*                                IBM CORP.
*
*                            PROPRIETARY DATA
*
* Licensed Material - Property Of IBM
*
* "Restricted Materials of IBM"
*
* Copyright IBM Corporation 1997, 2013. All rights reserved.
*
* *************************************************************************
*
*  Title:          locreate.c
*
*  Description:    To create a smart large object and insert it into the
*                  database
*                  --  the column created is the 'advert' column of the
*                      table 'item' (datatype - CLOB)
*
***************************************************************************
*/


#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <errno.h>

#ifndef NO_WIN32
#include <io.h>
#include <windows.h>
#include <conio.h>
#endif /*NO_WIN32*/

#include <fcntl.h>
#include "infxcli.h"

#define BUFFER_LEN      25
#define ERRMSG_LEN      200

SQLCHAR   defDsn[] = "odbc_demo";


SQLINTEGER checkError (SQLRETURN       rc,
                       SQLSMALLINT     handleType,
                       SQLHANDLE       handle,
                       SQLCHAR*        errmsg)
{
    SQLRETURN       retcode = SQL_SUCCESS;

    SQLSMALLINT     errNum = 1;
    SQLCHAR         sqlState[6];
    SQLINTEGER      nativeError;
    SQLCHAR         errMsg[ERRMSG_LEN];
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
        return 0;   /* no errors to report */
}




int main (long         argc,
          char*        argv[])
{
    /* Declare variables */

    /* Handles */
    SQLHDBC         hdbc;
    SQLHENV         henv;
    SQLHSTMT        hstmt;

    /* Smart large object file descriptor */
    SQLLEN          lofd;
    SQLLEN          lofd_valsize = 0;

    /* Smart large object pointer structure */
    SQLCHAR*        loptr_buffer;
    SQLSMALLINT     loptr_size;
    SQLLEN          loptr_valsize = 0;

    /* Smart large object specification structure */
    SQLCHAR*        lospec_buffer;
    SQLSMALLINT     lospec_size;
    SQLLEN          lospec_valsize = 0;

    /* Write buffer */
    SQLCHAR*        write_buffer;
    SQLSMALLINT     write_size;
    SQLLEN          write_valsize = 0;
    size_t          status;
    struct stat     statbuf;
    int             fd;

    /* Miscellaneous variables */
    SQLCHAR         dsn[20];   /*name of the DSN used for connecting to the database*/
    SQLRETURN       rc = 0;
    SQLLEN          in;

    SQLCHAR         verInfoBuffer[BUFFER_LEN];
    SQLSMALLINT     verInfoLen;

    SQLCHAR*        lo_file_name = (SQLCHAR *) "advert.txt";

    SQLCHAR         colname[BUFFER_LEN] = "item.advert";
    SQLLEN          colname_size = SQL_NTS;

    SQLINTEGER      mode = LO_RDWR;
    SQLLEN          cbMode = 0;

    SQLCHAR*        insertStmt = (SQLCHAR *) "INSERT INTO item VALUES (1005, 'Helmet', 235, 'Each', '39.95', ?)";




    /*  STEP 1. Get data source name from command line (or use default)
    **          Allocate environment handle and set ODBC version
    **          Allocate connection handle
    **          Establish the database connection
    **          Get version information from the database server
    **          -- if version < 9.x (not UDO enabled), exit with error message
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
    rc = SQLConnect (hdbc, dsn, SQL_NTS, (SQLCHAR *) "", SQL_NTS, (SQLCHAR *) "", SQL_NTS);
    if (checkError (rc, SQL_HANDLE_DBC, hdbc, (SQLCHAR *) "Error in Step 1 -- SQLConnect failed\n"))
        return (1);


    /* Get version information from the database server
       If version < 9.x (not UDO enabled), exit with error message */

    rc = SQLGetInfo (hdbc, SQL_DBMS_VER, verInfoBuffer, BUFFER_LEN, &verInfoLen);
    if (checkError (rc, SQL_HANDLE_DBC, hdbc, (SQLCHAR *) "Error in Step 1 -- SQLGetInfo failed\n"))
        return 1;

    if ((strncmp ((char *) verInfoBuffer, "09", 2)) < 0 )
    {
        fprintf (stdout, "\n** This test can only be run against database server -- version 9 or higher **\n");
        return 1;
    }


    /* Allocate the statement handle */
    rc = SQLAllocHandle (SQL_HANDLE_STMT, hdbc, &hstmt );
    if (checkError (rc, SQL_HANDLE_DBC, hdbc, (SQLCHAR *) "Error in Step 1 -- Statement Handle Allocation failed\nExiting!!\n"))
        return (1);



    fprintf (stdout, "STEP 1 done...connected to database\n");




    /* STEP 2.  Get the size of the smart large object specification structure
    **          Allocate a buffer to hold the structure
    **          Create a default smart large object specification structure
    **          Reset the statement parameters
    */


    /* Get the size of a smart large object specification structure */
    rc = SQLGetInfo (hdbc, SQL_INFX_LO_SPEC_LENGTH, &lospec_size,
                     sizeof(lospec_size), NULL);
    if (checkError (rc, SQL_HANDLE_DBC, hdbc, (SQLCHAR *) "Error in Step 2 -- SQLGetInfo failed\n"))
        goto Exit;

    /* Allocate a buffer to hold the smart large object specification
       structure*/
    lospec_buffer = malloc (lospec_size);
    if (lospec_buffer == NULL)
    {
        fprintf(stdout, "Failed to allocate memory for the largeobject specification buffer \n");
        goto Exit;
    }

    /* Create a default smart large object specification structure */
    rc = SQLBindParameter (hstmt, 1, SQL_PARAM_INPUT_OUTPUT, SQL_C_BINARY,
                           SQL_INFX_UDT_FIXED, (UDWORD)lospec_size, 0,
                           lospec_buffer, lospec_size, &lospec_valsize);
    if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 2 -- SQLBindParameter failed\n"))
        goto Exit;

    rc = SQLExecDirect (hstmt, (SQLCHAR *) "{call ifx_lo_def_create_spec(?)}", SQL_NTS);
    if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 2 -- SQLExecDirect failed\n"))
        goto Exit;

    /* Reset the statement parameters */
    rc = SQLFreeStmt (hstmt, SQL_RESET_PARAMS);
    if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 2 -- SQLFreeStmt failed\n"))
        goto Exit;


    fprintf (stdout, "STEP 2 done...default smart large object specification structure created\n");




    /* STEP 3.  Initialise the smart large object specification structure with
    **          values for the database column where the smart large object is
    **          being inserted
    **          Reset the statement parameters
    */

    /* Initialise the smart large object specification structure */
    rc = SQLBindParameter (hstmt, 1, SQL_PARAM_INPUT, SQL_C_CHAR, SQL_CHAR,
                           BUFFER_LEN, 0, colname, BUFFER_LEN, &colname_size);
    if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 3 -- SQLBindParameter failed (param 1)\n"))
        goto Exit;

    lospec_valsize = lospec_size;

    rc = SQLBindParameter (hstmt, 2, SQL_PARAM_INPUT_OUTPUT, SQL_C_BINARY,
                           SQL_INFX_UDT_FIXED, (UDWORD)lospec_size, 0, lospec_buffer,
                           lospec_size, &lospec_valsize);
    if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 3 -- SQLBindParameter failed (param 2)\n"))
        goto Exit;

    rc = SQLExecDirect (hstmt, (SQLCHAR *) "{call ifx_lo_col_info(?, ?)}", SQL_NTS);
    if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 3 -- SQLExecDirect failed\n"))
        goto Exit;


    /* Reset the statement parameters */
    rc = SQLFreeStmt (hstmt, SQL_RESET_PARAMS);
    if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 3 -- SQLFreeStmt failed\n"))
        goto Exit;



    fprintf(stdout, "STEP 3 done...smart large object specification structure initialised\n");

    /* STEP 4.  Get the size of the smart large object pointer structure
    **          Allocate a buffer to hold the structure.
    */

    /* Get the size of the smart large object pointer structure */
    rc = SQLGetInfo (hdbc, SQL_INFX_LO_PTR_LENGTH, &loptr_size, sizeof(loptr_size), NULL);
    if (checkError (rc, SQL_HANDLE_DBC, hdbc, (SQLCHAR *) "Error in Step 4 -- SQLGetInfo failed\n"))
        goto Exit;

    /* Allocate a buffer to hold the smart large object pointer structure */
    loptr_buffer = malloc (loptr_size);
    if (loptr_buffer == NULL)
    {
        fprintf(stdout, "Failed to allocate memory for the smart large object pointer structure buffer \n");
        goto Exit;
    }


    fprintf (stdout, "STEP 4 done...smart large object pointer structure allocated\n");



    /* STEP 5.  Create a new smart large object.
    **          Reset the statement parameters
    */

    /* Create a new smart large object */
    rc = SQLBindParameter (hstmt, 1, SQL_PARAM_INPUT, SQL_C_BINARY, SQL_INFX_UDT_FIXED,
                           (UDWORD)lospec_size, 0, lospec_buffer, lospec_size, &lospec_valsize);
    if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 5 -- SQLBindParameter failed (param 1)\n"))
        goto Exit;

    rc = SQLBindParameter (hstmt, 2, SQL_PARAM_INPUT, SQL_C_SLONG, SQL_INTEGER,
                           (UDWORD)0, 0, &mode, sizeof(mode), &cbMode);
    if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 5 -- SQLBindParameter failed (param 2)\n"))
        goto Exit;

    loptr_valsize = loptr_size;

    rc = SQLBindParameter (hstmt, 3, SQL_PARAM_INPUT_OUTPUT, SQL_C_BINARY, SQL_INFX_UDT_FIXED,
                           (UDWORD)loptr_size, 0, loptr_buffer, loptr_size, &loptr_valsize);
    if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 5 -- SQLBindParameter failed (param 3)\n"))
        goto Exit;

    rc = SQLBindParameter (hstmt, 4, SQL_PARAM_OUTPUT, SQL_C_SLONG, SQL_INTEGER,
                           (UDWORD)0, 0, &lofd, sizeof(lofd), &lofd_valsize);
    if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 5 -- SQLBindParameter failed (param 4)\n"))
        goto Exit;

    rc = SQLExecDirect (hstmt, (SQLCHAR *) "{call ifx_lo_create(?, ?, ?, ?)}", SQL_NTS);
    if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 5 -- SQLExecDirect failed\n"))
        goto Exit;

    /* Reset the statement parameters */
    rc = SQLFreeStmt (hstmt, SQL_RESET_PARAMS);
    if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 5 -- SQLFreeStmt failed\n"))
        goto Exit;



    fprintf (stdout, "STEP 5 done...smart large object created\n");



    /* STEP 6.  Open the file containing data for the new smart large object
    **          Allocate a buffer to hold the smart large object data
    **          Read data from the input file into the smart large object data buffer
    **          Write data from the data buffer into the new smart large object.
    **          Reset the statement parameters
    */

    /* Get the size of the file containing data for the new smart large object */
    if (stat( (char *)lo_file_name,&statbuf) == -1)
    {
        fprintf (stdout, "Error %d reading %s\n", errno, lo_file_name);
        exit(1);
    }
    write_size = statbuf.st_size;

    /* Allocate a buffer to hold the smart large object data */
    write_buffer = malloc (write_size + 1);
    if (write_buffer == NULL)
    {
        fprintf(stdout, "Failed to allocate memory for the smart large object data buffer \n");
        goto Exit;
    }

    /* Read smart large object data from file */
    fd = open ((char *) lo_file_name, O_RDONLY);
    if (fd == -1)
    {
        fprintf (stdout, "Error %d creating file descriptor for %s\n", errno, lo_file_name);
        exit(1);
    }
    status = read (fd, write_buffer, write_size);
    if (status < 0)
    {
        fprintf (stdout, "Error %d reading %s\n", errno, lo_file_name);
    }
    if (close(fd) < 0)
    {
        fprintf (stdout, "Error %d closing the file %s\n", errno, lo_file_name);
        exit(1);
    }

    write_buffer[write_size] = '\0';
    write_valsize = write_size;


    /* Write data from the data buffer into the new smart large object */
    rc = SQLBindParameter (hstmt, 1, SQL_PARAM_INPUT, SQL_C_SLONG, SQL_INTEGER,
                           (UDWORD)0, 0, &lofd, sizeof(lofd), &lofd_valsize);
    if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 6 -- SQLBindParameter failed (param 1)\n"))
        goto Exit;

    rc = SQLBindParameter (hstmt, 2, SQL_PARAM_INPUT, SQL_C_CHAR, SQL_CHAR,
                           (UDWORD)write_size, 0, write_buffer, write_size, &write_valsize);
    if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 6 -- SQLBindParameter failed (param 2)\n"))
        goto Exit;

    rc = SQLExecDirect (hstmt, (SQLCHAR *) "{call ifx_lo_write(?, ?)}", SQL_NTS);
    if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 6 -- SQLExecDirect failed\n"))
        goto Exit;


    /* Reset the statement parameters */
    rc = SQLFreeStmt (hstmt, SQL_RESET_PARAMS);
    if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 6 -- SQLFreeStmt failed\n"))
        goto Exit;



    fprintf (stdout, "STEP 6 done...data written to new smart large object\n");



    /* STEP 7.  Insert the new smart large object into the database.
    **          Reset the statement parameters
    */

    /* Insert the new smart large object into the database */
    loptr_valsize = loptr_size;

    rc = SQLBindParameter (hstmt, 1, SQL_PARAM_INPUT, SQL_C_BINARY, SQL_INFX_UDT_FIXED,
                           (UDWORD)loptr_size, 0, loptr_buffer, loptr_size, &loptr_valsize);
    if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 7 -- SQLBindParameter failed\n"))
        goto Exit;

    rc = SQLExecDirect (hstmt, insertStmt, SQL_NTS);
    if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 7 -- SQLExecDirect failed\n"))
        goto Exit;

    /* Reset the statement parameters */
    rc = SQLFreeStmt (hstmt, SQL_RESET_PARAMS);
    if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 7 -- SQLFreeStmt failed\n"))
        goto Exit;



    fprintf (stdout, "STEP 7 done...smart large object inserted into the database\n");




    /* STEP 8.  Close the smart large object. */

    rc = SQLBindParameter (hstmt, 1, SQL_PARAM_INPUT, SQL_C_LONG, SQL_INTEGER,
                           (UDWORD)0, 0, &lofd, sizeof(lofd), &lofd_valsize);
    if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 8 -- SQLBindParameter failed\n"))
        goto Exit;

    rc = SQLExecDirect (hstmt, (SQLCHAR *) "{call ifx_lo_close(?)}", SQL_NTS);
    if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "Error in Step 8 -- SQLExecDirect failed\n"))
        goto Exit;



    fprintf (stdout, "STEP 8 done...smart large object closed\n");




    /* STEP 9. Free the allocated buffers */
    if (lospec_buffer)
        free (lospec_buffer);
    if (loptr_buffer)
        free (loptr_buffer);
    if (write_buffer)
        free (write_buffer);


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
