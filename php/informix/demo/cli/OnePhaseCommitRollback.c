/***************************************************************************
*  Licensed Materials - Property of IBM
*
*
*  "Restricted Materials of IBM"
*
*
*
*  IBM Informix Client SDK
*
*
*  (C) Copyright IBM Corporation 1997, 2004 All rights reserved.
*
*
*
*
*
*  Title:          OnePhaseCommitRollback.c
*
*  Description:    Make X/Open XA calls to perform one-phase commit or
*                  one-phase rollback
*
*
***************************************************************************
*/


#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>

#ifndef NO_WIN32
#include <io.h>
#include <windows.h>
#include <conio.h>
#endif

#include "xa.h"
#include "infxcli.h"

#define MAXPROCS 500
#define MAX_ERR_MSG 255
#define ERRMSG_LEN  200

int   error_flag = 0;
struct xa_switch_t *OdbcXaSwitch;

#define xa_open(info, rmid, flags)      \
        ((*OdbcXaSwitch->xa_open_entry)(info,rmid,flags))
#define xa_close(info, rmid, flags)     \
        ((*OdbcXaSwitch->xa_close_entry)(info,rmid,flags))
#define xa_start(gtrid,rmid, flags)     \
        ((*OdbcXaSwitch->xa_start_entry)(gtrid,rmid,flags))
#define xa_end(gtrid,rmid, flags)       \
        ((*OdbcXaSwitch->xa_end_entry)(gtrid,rmid,flags))
#define xa_rollback(gtrid,rmid, flags)     \
        ((*OdbcXaSwitch->xa_rollback_entry)(gtrid,rmid,flags))
#define xa_prepare(gtrid, rmid, flags)   \
        ((*OdbcXaSwitch->xa_prepare_entry)(gtrid,rmid,flags))
#define xa_commit(gtrid, rmid, flags)   \
        ((*OdbcXaSwitch->xa_commit_entry)(gtrid,rmid,flags))
#define xa_recover(gtrid,count,rmid, flags)     \
        ((*OdbcXaSwitch->xa_recover_entry)(gtrid,count,rmid,flags))
#define xa_forget(gtrid,rmid, flags)    \
        ((*OdbcXaSwitch->xa_forget_entry)(gtrid,rmid,flags))
#define xa_complete(handle, retval, rmid, flags)        \
        ((*OdbcXaSwitch->xa_complete_entry)(handle,retval,rmid,flags))

int XAOpen(char *xa_info, int rmid, long flags)
{
    int RCopen;

   OdbcXaSwitch = _fninfx_xa_switch();
    printf("XAOpen: Calling xa_open ...");
    if ((RCopen = xa_open(xa_info, rmid, flags)) != XA_OK)
        {
        printf("\n\tXAOpen: xa_open() returned %d\n", RCopen);
        }
    else
        {
        printf("Success %d.\n", RCopen);
        }

   return(RCopen);
}

int XAClose(char *xa_info, int rmid, long flags)
{
    int RCclose;
   OdbcXaSwitch = _fninfx_xa_switch();
    printf("XAClose: Calling xa_close ...");
    if ((RCclose  = xa_close(xa_info, rmid, flags)) != XA_OK)
    {
        printf("\n\tXAClose: xa_close() returned %d\n", RCclose);
    }
    else
    {
        printf("Success %d.\n", RCclose);
    }
    return(RCclose);
}

int XAStart(XID *var_xid, int rmid, long flags)
{
    int RCstart;

   OdbcXaSwitch = _fninfx_xa_switch();
    printf("XAStart: Calling xa_start ...");
    if ((RCstart = xa_start(var_xid, rmid, flags)) != XA_OK)
    {
        printf("\n\tXAStart: xa_start() returned %d\n", RCstart);
    }
    else
    {
        printf("Success %d.\n", RCstart);
    }
    return(RCstart);
}

int XAEnd(XID *var_xid, int rmid, long flags)
{
    int RCend;
   OdbcXaSwitch = _fninfx_xa_switch();
    printf("XAEnd: Calling xa_end ...");
    if ((RCend = xa_end(var_xid, rmid, flags)) != XA_OK)
    {
        printf("\n\tXAEnd: xa_end() returned %d\n",RCend);
    }
    else
    {
        printf("Success %d.\n", RCend);
    }
    return(RCend);
}

int XAPrepare(XID *var_xid, int rmid, long flags)
{
    int RCPrepare;
   OdbcXaSwitch = _fninfx_xa_switch();
    printf("XAPrepare: Calling xa_prepare ...");
    if ((RCPrepare = xa_prepare(var_xid, rmid, flags)) != XA_OK)
    {
        printf("\n\tXAPrepare: xa_prepare() returned %d\n",RCPrepare);
    }
    else
    {
        printf("Success %d.\n", RCPrepare);
    }
    return(RCPrepare);
}

XACommit(XID *var_xid, int rmid, long flags)
{
    int RCCommit;
   OdbcXaSwitch = _fninfx_xa_switch();
    printf("XACommit: Calling xa_commit...");
    if ((RCCommit = xa_commit(var_xid, rmid, flags)) != XA_OK)
    {
        printf("\n\tXACommit: xa_commit() returned %d\n", RCCommit);
    }
   else
    {
        printf("Success %d.\n", RCCommit);
    }
    return(RCCommit);
}

XARollback(XID *var_xid, int rmid, long flags)
{
    int RCRollback;
   OdbcXaSwitch = _fninfx_xa_switch();
    printf("XARollback: Calling xa_rollback...");
    if ((RCRollback = xa_rollback(var_xid, rmid, flags)) != XA_OK)
    {
        printf("\n\tXARollback: xa_rollback() returned %d\n", RCRollback);
    }
    else
    {
        printf("Success %d.\n", RCRollback);
    }
    return(RCRollback);
}

XARecover(XID *var_xid, long count, int rmid, long flags)
{
    int RCRecover;
   OdbcXaSwitch = _fninfx_xa_switch();
    printf("XARecover: Calling xa_recover...");
    if ((RCRecover = xa_recover(var_xid, count, rmid, flags)) != XA_OK)
    {
        printf("\n\tXARecover: xa_recover() returned %d\n", RCRecover);
    }
    else
    {
        printf("Success %d.\n", RCRecover);
    }
    return(RCRecover);
}

XAForget(XID *var_xid, int rmid, long flags)
{
    int RCForget;
   OdbcXaSwitch = _fninfx_xa_switch();
    printf("XAForget: Calling xa_forget...");
    if ((RCForget = xa_forget(var_xid, rmid, flags)) != XA_OK)
    {
        printf("\n\tXAForget: xa_forget() returned %d\n", RCForget);
    }
    else
    {
        printf("Success %d.\n", RCForget);
    }
    return(RCForget);
}

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



main(int argc, char *argv[])
{
	SQLCHAR defDsn[] = "odbc_demo";
	char applTokenStr[] = "123";
	char openInfo[60];
	SQLCHAR	dsn[40]; /*name of the DSN used for connecting to the database*/
	XID var_xid1, var_xid2;
	RETCODE rc;
	HANDLE hdbc, hstmt;
	HENV henv;
	int rmid =0;
	int applToken;

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
    applToken = atoi(applTokenStr);
	strcpy(openInfo, applTokenStr);
	strcat(openInfo, (char *)"|");
	strcat(openInfo, (char *)dsn);

	fprintf (stdout, "\nUsing specified openInfo : %s\n", openInfo);

    var_xid1.formatID = 100;
    var_xid1.gtrid_length = 3;
    var_xid1.bqual_length = 3;
    var_xid1.data[0] = 'A';
    var_xid1.data[1] = 'B';
    var_xid1.data[2] = 'A';
    var_xid1.data[3] = 'B';
    var_xid1.data[4] = 'A';
    var_xid1.data[5] = 'B';

    var_xid2.formatID = 102;
    var_xid2.gtrid_length = 3;
    var_xid2.bqual_length = 3;
    var_xid2.data[0] = 'C';
    var_xid2.data[1] = 'D';
    var_xid2.data[2] = 'C';
    var_xid2.data[3] = 'D';
    var_xid2.data[4] = 'C';
    var_xid2.data[5] = 'D';

    if ((rc = XAOpen(openInfo, rmid, TMNOFLAGS)) == XA_OK) 
	{
    	printf("\nXAOpen done ...");
    	printf("\nRmid set: [%i]\n",rmid);
	}
		else
	{
		printf("\n XAOpen Failed ... Aborting ...");
		exit(1);
	}

    rc = IFMX_SQLGetXaHenv(applToken, &henv);
	if (rc)
	{
		printf("\nIFMX_SQLGetXaHenv Failed ... Aborting ...");
		exit(1);
	}

    rc = IFMX_SQLGetXaHdbc(applToken, &hdbc);
	if (rc)
	{
		printf("\nIFMX_SQLGetXaHdbc Failed ... Aborting ...");
		exit(1);
	}

    rc = XAStart(&var_xid1, rmid, TMNOFLAGS);
	if (rc)
	{
		printf("\nXAStart Failed ... Aborting ...");
		exit(1);
	}

    rc = SQLAllocHandle(SQL_HANDLE_STMT, hdbc, &hstmt);
    if (checkError (rc, SQL_HANDLE_DBC, hdbc, (SQLCHAR *) "SQLAllocHandle failed\nExiting!!\n"))
		return (1);

    printf("\n Inserting Values ...");

	rc = SQLExecDirect(hstmt, (SQLCHAR *)"INSERT INTO xa_tab1 VALUES(1)", SQL_NTS);
    if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "SQLExecDirect failed\nExiting!!\n"))
		return (1);

    printf ("\n Calling XAEnd on first transaction ...");

    rc = XAEnd(&var_xid1, rmid, TMSUCCESS);
    if (rc)
	{
		printf("\nXAEnd Failed ... Aborting ...Error Code: %d", rc);
		exit(1);
	}

    rc = XACommit(&var_xid1, rmid, TMONEPHASE);
    if (rc)
	{
		printf("\nXACommit Failed ... Aborting ...Error Code: %d", rc);
		exit(1);
	}
    printf("\nCalling XAStart on second transaction...");

    rc = XAStart(&var_xid2, rmid, TMNOFLAGS);
    if (rc)
	{
		printf("\nXAStart Failed ... Aborting ...Error Code: %d", rc);
		exit(1);
	}
    rc = SQLExecDirect(hstmt, (SQLCHAR *)"INSERT INTO xa_tab1 VALUES(2)", SQL_NTS);
    if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "SQLExecDirect failed\nExiting!!\n"))
		return (1);

    rc = XAEnd(&var_xid2, rmid, TMSUCCESS);
    if (rc)
	{
		printf("\nXAEnd Failed ... Aborting ...Error Code: %d", rc);
		exit(1);
	}
    rc = XARollback(&var_xid2, rmid, TMNOFLAGS);
    if (rc)
	{
		printf("\nXARollback Failed ... Aborting ...Error Code: %d", rc);
		exit(1);
	}
    rc = SQLFreeStmt(hstmt, SQL_CLOSE);
    if (checkError (rc, SQL_HANDLE_STMT, hstmt, (SQLCHAR *) "SQLFreeStmt failed\nExiting!!\n"))
		return (1);

    rc = SQLFreeHandle(SQL_HANDLE_STMT, hstmt);
    if (checkError (rc, SQL_HANDLE_DBC, hdbc, (SQLCHAR *) "SQLFreeHandle failed\nExiting!!\n"))
		return (1);

    rc = XAClose(openInfo, rmid, TMNOFLAGS);
    if (rc)
      {
	printf("\nXARollback Failed ... Aborting ...Error Code: %d", rc);
	exit(1);
      }
	exit(0);
}

