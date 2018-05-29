/****************************************************************************
 * Licensed Material - Property Of IBM
 *
 * "Restricted Materials of IBM"
 *
 * IBM Informix Client SDK
 *
 * (c)  Copyright IBM Corporation 1997, 2013. All rights reserved.
 *
 ****************************************************************************
 */
/*
   * timeout.ec *
 *
 * The following program shows the use of the sqlbreak(), sqldone(),
 * and sqlbreakcallback() functions to create a callback function and
 * a time-out interval. This program uses sqlbreakcallback() to:
 *	 o  register the on_timeout() function as a callback function 
 *		  for a database query
 *	 o  establish a time-out interval of DB_TIMEOUT milliseconds
 *		  (set to 200)
 *
 * To provide a query will execute long enough to be interruptable,
 * the program:
 *	 o  creates a table called 'canceltst' and populates it with 
 *		 MAX_ROWS number (initially 10,000) of rows. 
 *	 o  performs a query on the canceltst table that uses extensive
 *		 string matching (using MATCHES)
 *
 * When the callback function executes due to an expired time-out
 * interval (status = 2), the callback function uses the sqldone() 
 * function to verify that the database server is busy and the 
 * sqlbreak() function to send an interrupt request to the server.
 */

#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <decimal.h>
#include <errno.h>
#include <stdlib.h>

EXEC SQL include sqltypes;

#define LCASE(c) (isupper(c) ? tolower(c) : (c))

/* Defines for callback mechanism */
#define DB_TIMEOUT	 200		/* number of milliseconds in time-out */
#define SQL_INTERRUPT -213		/* SQLCODE value for interrupted stmt */

/* These constants are used for the canceltst table, created by
 * this program.
 */
#define MAX_ROWS	   10000		/* number of rows added to table */
EXEC SQL define CHARFLDSIZE	20;  /* size of character columns in table */

/* Define for sqldone() return values */
#define SERVER_BUSY   -439 

/* These constants used by the exp_chk2() function to determine 
 * whether to display warnings.
 */
#define WARNNOTIFY		1
#define NOWARNNOTIFY	  0

int4 dspquery();
extern int4 exp_chk2();
void on_timeout();

main()
{
	char ques[80], prompt_ans();
	int4 ret;
	mint create_tbl(), drop_tbl();

	printf("TIMEOUT Sample ESQL Program running.\n\n");

	/*
	 * Establish an explicit connection to the stores_demo database
	 * on the default database server.
	 */
	EXEC SQL connect to 'stores_demo';

	if (exp_chk2("CONNECT to stores_demo", NOWARNNOTIFY) < 0)
		exit(1);
	printf("Connected to 'stores_demo' on default server\n");

	/*
	 * Create the canceltst table to hold MAX_ROWS (10,000) rows.
	 */
	if (!create_tbl())
		{
		printf("\nTIMEOUT Sample Program over.\n\n");
		exit(1);
		}

	while(1)
		{

	/*
	 * Establish on_timeout() as callback function. The callback
	 * function is called with an argument value of 2 when the 
	 * database server has executed a single SQL request for number 
	 * of milliseconds specified by the DB_TIMEOUT constant 
	 * (0.00333333 minutes by default). Call to  sqlbreakcallback() 
	 * must come after server connection is established and before
	 * the first SQL statement that can be interrupted.
	 */
		if (sqlbreakcallback(DB_TIMEOUT, on_timeout))
			{
			printf("\nUnable to establish callback function.\n");
			printf("TIMEOUT Sample Program over.\n\n");
			exit(1);
			}

	/*
	 * Notify end user of time-out interval.
	 */
		printf("Time-out interval for SQL requests is: ");
		printf("%0.8f minutes\n", DB_TIMEOUT/60000.00);

		stcopy("Are you ready to begin execution of the query?",
			ques);
		if (prompt_ans(ques) == 'n')
			{
		/*
		 * Unregister callback function so table cleanup will not
		 * be interrupted.
		 */
			sqlbreakcallback(-1L, (void(*)(int))NULL);
			break;
			}

	/* 
	 * Start display of query output
	 */
		printf("\nBeginning execution of query...\n\n");
		if ((ret = dspquery()) == 0)
			{
			if (prompt_ans("Try another run?") == 'y')
				continue;
			else
				break;
			}
		else  /* dspquery() encountered an error */
			exit(1);

		} /* end while */ 

	/*
	 * Drop the table created for this program 
	 */
	drop_tbl();

	EXEC SQL disconnect current;
	if (exp_chk2("DISCONNECT for stores_demo", WARNNOTIFY) != 0)
		exit(1);
	printf("\nDisconnected stores_demo connection\n");
	printf("\nTIMEOUT Sample Program over.\n\n");
    exit(0);
}

/* This function performs the query on the canceltst table. */
int4 dspquery()
{
	mint cnt = 0;
	int4 ret = 0;
	int4 sqlcode = 0;
	int4 sqlerr_code, sqlstate_err();
	void disp_exception(), disp_error(), disp_warning();

	EXEC SQL BEGIN DECLARE SECTION;
		char fld1_val[ CHARFLDSIZE + 1 ];
		char fld2_val[ CHARFLDSIZE + 1 ];
		int4 int_val;
	EXEC SQL END DECLARE SECTION;

	/* This query contains an artifically complex WHERE clause to
	 * keep the database server busy long enough for an interrupt
	 * to occur.
	 */
	EXEC SQL declare cancel_curs cursor for 
		select sum(int_fld), char_fld1, char_fld2
		from canceltst
		where char_fld1 matches "*f*"
			or char_fld1 matches "*h*"
			or char_fld2 matches "*w*"
			or char_fld2 matches "*l*"
			group by char_fld1, char_fld2 order by 1 desc;

	EXEC SQL open cancel_curs;

	sqlcode = SQLCODE;
	sqlerr_code = sqlstate_err(); /* check SQLSTATE for exception */
	if (sqlerr_code != 0)		 /* if exception found */
		{
		if (sqlerr_code == -1)	 /* runtime error encountered */
			{
			if (sqlcode == SQL_INTERRUPT)  /* user interrupt */
				{
				/* This is where you would clean up resources */
				printf("\n	   TIMEOUT INTERRUPT PROCESSED\n\n");
				sqlcode = 0;
				}
			else						 /* serious runtime error */
				disp_error("OPEN cancel_curs");
 
			EXEC SQL close cancel_curs;
			EXEC SQL free cancel_curs;
			return(sqlcode);
			}
		else if (sqlerr_code == 1) /* warning encountered */
			disp_warning("OPEN cancel_curs");
		}

	printf("Displaying data...\n");
	while(1)
	{
		EXEC SQL fetch cancel_curs into :int_val, :fld1_val, :fld2_val;
	if ((ret = exp_chk2("FETCH from cancel_curs", NOWARNNOTIFY)) == 0)
		{
		printf("   sum(int_fld) = %d\n", int_val);
		printf("   char_fld1 = %s\n", fld1_val);
		printf("   char_fld2 = %s\n\n", fld2_val);
		}

	/*
	 * Will display warning messages (WARNNOTIFY) but continue
	 * execution when they occur (exp_chk2() == 1)
	 */
	else
		{
		if (ret==100)			/* NOT FOUND condition */
			{
			printf("\nNumber of rows found: %d\n\n", cnt);
			break;
			}
		if (ret < 0)			 /* Run-time error */
			{
			EXEC SQL close cancel_curs;
			EXEC SQL free cancel_curs;
			return(ret);
			}
		}

		cnt++;

	} /* end while */
	
	EXEC SQL close cancel_curs;
	EXEC SQL free cancel_curs;
	return(0);
}


/*
 *  The on_timeout() function is the callback function. If the user 
 *  confirms the cancellation, this function uses sqlbreak() to 
 *  send an interrupt request to the database server.
 */
void on_timeout(mint when_called)
{
mint ret;
static intr_sent;

	/* Determine when callback function has been called.  */
	switch(when_called)
		{
		case 0: /* Request to server completed */
			printf("+------SQL Request ends");
			printf("-------------------------------+\n\n");

		/*
		 * Unregister callback function so no further SQL statements
		 * can be interrupted.
		 */
			if (intr_sent)
				sqlbreakcallback(-1L, (void(*)(int))NULL);
			break;

		case 1: /* Request to server begins */
			printf("+------SQL Request begins");
			printf("-----------------------------+\n");
			printf("|						");
			printf("							 |\n");
			intr_sent = 0;
			break;

		case 2: /* Time-out interval has expired */
		/*
		 * Is the database server still processing the request? 
		 */
			if (sqldone() == SERVER_BUSY)
				if (!intr_sent)   /* has interrupt already been sent? */
					{
					printf("|   An interrupt has been received ");
					printf("by the application.|\n");
					printf("|						");
					printf("							 |\n");

			/* 
			 * Ask user to confirm interrupt 
			 */
					if (cancel_request())
						{
						printf("|	  TIMEOUT INTERRUPT ");
						printf("REQUESTED					|\n");

			/* 
			 * Call sqlbreak() to issue an interrupt request 
			 * for current SQL request to be cancelled.
			 */
						sqlbreak();

						}
					intr_sent = 1;
					}
			break;
		default:
			printf("Invalid status value in callback: %d\n", when_called);
			break;
		}
}

/* This function prompts the user to confirm the sending of an
 * interrupt request for the current SQL request.
 */
mint cancel_request()
{
	char prompt_ans();

	if (prompt_ans("Do you want to confirm this interrupt?") == 'n')
		return(0);	/* don't interrupt SQL request */
	else
		return(1);	/* interrupt SQL request */
}


/* This function creates a new table in the current database. It
 * populates this table with MAX_ROWS rows of data. 
 */
mint create_tbl()
{
	char st_msg[15];
	mint ret = 1;

	EXEC SQL BEGIN DECLARE SECTION;
		mint cnt;
		mint pa;
		mint i;
		char fld1[ CHARFLDSIZE + 1 ], fld2[ CHARFLDSIZE + 1 ];
	EXEC SQL END DECLARE SECTION;

	/* 
	 * Create canceltst table in current database 
	 */
	EXEC SQL create table canceltst (char_fld1 char(20),
		char_fld2 char(20), int_fld integer);
	if (exp_chk2("CREATE TABLE", WARNNOTIFY) < 0)
		return(0);
	printf("Created table 'canceltst'\n");

	/* 
	 * Insert MAX_ROWS of data into canceltst
	 */
	printf("Inserting rows into 'canceltst'...\n");
	for (i = 0; i < MAX_ROWS; i++)
		{
		if (i%2 == 1)  /* odd-numbered rows */
			{
			stcopy("4100 Bohannan Dr", fld1);
			stcopy("Menlo Park, CA", fld2);
			}
		else		   /* even-numbered rows */
			{
			stcopy("Informix", fld1);
			stcopy("Software", fld2);
			}
		EXEC SQL insert into canceltst 
			values (:fld1, :fld2, :i);
		if ( (i+1)%1000 == 0 ) /* every 1000 rows */
			printf("   Inserted %d rows\n", i+1);
		sprintf(st_msg, "INSERT #%d", i);
		if (exp_chk2(st_msg, WARNNOTIFY) < 0)
			{
			ret = 0;
			break;
			}
		}
	printf("Inserted %d rows into 'canceltst'.\n", MAX_ROWS);

	/*
	 * Verify that MAX_ROWS rows have added to canceltst
	 */
	printf("Counting number of rows in 'canceltst' table...\n");
	EXEC SQL select count(*) into :cnt from canceltst;
	if (exp_chk2("SELECT count(*)", WARNNOTIFY) < 0)
		return(0);
	printf("Number of rows = %d\n\n", cnt);

	return (ret);
}

/* This function drops the 'canceltst' table */
mint drop_tbl()
{
	printf("\nCleaning up...\n");

	EXEC SQL drop table canceltst;
	if (exp_chk2("DROP TABLE", WARNNOTIFY) < 0)
		return(0);
	printf("Dropped table 'canceltst'\n");

	return(1);
}

/*
 * The inpfuncs.c file contains the following functions used in this
 * program:
 *	getans(ans, len) - accepts user input, up to 'len' number of
 *			   characters and puts it in 'ans'
 */
#include "inpfuncs.c"

char prompt_ans(char *question)
{
	char ans = ' ';

	while(ans != 'y' && ans != 'n')
		{
		printf("\n*** %s (y/n): ", question);
		getans(&ans,1);
		}
	return ans;
}

/*
 * The exp_chk() file contains the exception handling functions to
 * check the SQLSTATE status variable to see if an error has occurred 
 * following an SQL statement. If a warning or an error has
 * occurred, exp_chk2() executes the GET DIAGNOSTICS statement and 
 * displays the detail for each exception that is returned.
 */
EXEC SQL include exp_chk.ec;

