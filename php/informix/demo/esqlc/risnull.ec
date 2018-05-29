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
   * risnull.ec *

   This program checks the paid_date column of the orders table for NULL
   to determine whether an order has been paid.
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

EXEC SQL include sqltypes;

#define WARNNOTIFY     1
#define NOWARNNOTIFY   0

main()
{
    char ans;
    int4 ret, exp_chk();

    EXEC SQL BEGIN DECLARE SECTION;
        int4 order_num;
        mint  order_date, ship_date, paid_date;
    EXEC SQL END DECLARE SECTION;

    printf("RISNULL Sample ESQL Program running.\n\n");
    EXEC SQL connect to 'stores_demo';                 /* open stores_demo database */
    exp_chk("CONNECT TO stores_demo", NOWARNNOTIFY);

    EXEC SQL declare c cursor for
        select order_num, order_date, ship_date, paid_date from orders;
    EXEC SQL open c;
    if(exp_chk("OPEN c", WARNNOTIFY) == 1)  /* Found warnings */
	{
	EXEC SQL disconnect current;
	exit(1);
	}
    printf("\n Order#\tPaid?\n");     /* print column hdgs */
    while(1)
	{
	EXEC SQL fetch c into :order_num, :order_date, :ship_date, :paid_date;
	if ((ret = exp_chk("FETCH c", WARNNOTIFY)) == 100) /* if end of rows */
	    break;				      /* terminate loop */
	if(ret < 0)
	    exit(1);
	printf("%5d\t", order_num);
	if (risnull(CDATETYPE, (char *)&paid_date)) /* is price NULL ? */
	    printf("NO\n");
	else
	    printf("Yes\n");
	}

    EXEC SQL disconnect current;
    printf("\nRISNULL Sample Program over.\n\n");
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

