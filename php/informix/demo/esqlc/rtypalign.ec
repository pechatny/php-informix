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
   * rtypalign.ec *

   The following program prepares a select on all columns of the orders
   table and then calculates the proper alignment for each column in a buffer.
*/
#include <decimal.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

EXEC SQL include sqltypes;

#define WARNNOTIFY     1
#define NOWARNNOTIFY   0

main()
{
    mint i, pos;
    int4 ret, exp_chk();
    struct sqlda *sql_desc;
    struct sqlvar_struct *col;

    printf("RTYPALIGN Sample ESQL Program running.\n\n");

    EXEC SQL connect to 'stores_demo';	     /* open stores_demo database */
    exp_chk("connect to stores_demo", NOWARNNOTIFY);

    EXEC SQL prepare query_1 from 'select * from orders';  /* prepare select */
    if(exp_chk("Prepare", WARNNOTIFY) == 1)
	{
	EXEC SQL disconnect current;
	exit(1);
	}

    EXEC SQL describe query_1 into sql_desc;   	     /* initialize sqlda */
    if(exp_chk("Describe", WARNNOTIFY) == 1)
	{
	EXEC SQL disconnect current;
	exit(1);
	}

    col = sql_desc->sqlvar;
    printf("\n\ttype\t\tlen\tnext\taligned\n");     /* display column hdgs. */
    printf("\t\t\t\tposn\tposn\n\n");

    /*
     * For each column in the orders table
     */
    i = 0;
    pos = 0;
    while(i++ < sql_desc->sqld)
	{
        /* Modify sqllen if SQL type is DECIMAL or MONEY */
	if(col->sqltype == SQLDECIMAL || col->sqltype == SQLMONEY)
	    col->sqllen = sizeof(dec_t);
	/*
	 * display name of SQL type, length and un-aligned buffer position
	 */
	printf("\t%s\t\t%d\t%d", rtypname(col->sqltype), col->sqllen, pos);

	pos = rtypalign(pos, col->sqltype);  	     /* align pos. for type */
	printf("\t%d\n", pos);

	pos += col->sqllen;		 	     /* set next position */
	++col;                           	     /* bump to next column */
	}

    EXEC SQL disconnect current;
    printf("\nRTYPALIGN Sample Program over.\n\n");
    exit(0);
}

/*
 * The exp_chk() file contains the exception handling functions to
 * check the SQLSTATE status variable to see if an error has occurred 
 * following an SQL statement. If a warning or an error has
 * occurred, exp_chk() executes the GET DIAGNOSTICS statement and 
 * displays the detail for each exception that is returned.
 */
EXEC SQL include exp_chk.ec;

