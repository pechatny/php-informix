/****************************************************************************
 * Licensed Material - Property Of IBM
 *
 * "Restricted Materials of IBM"
 *
 * IBM Informix Client SDK
 *
 * (c)  Copyright IBM Corporation 1997, 2011. All rights reserved.
 *
 ****************************************************************************
 */
/*
   * rsetnull.ec *

   This program fetches rows from the stock table for a chosen manufacturer
   and allows the user to set the unit_price to NULL.
*/

#include <stdio.h>
#include <ctype.h>
#include <stdlib.h>
#include <string.h>

EXEC SQL include decimal;
EXEC SQL include sqltypes;

#define WARNNOTIFY     1
#define NOWARNNOTIFY   0

#define LCASE(c) (isupper(c) ? tolower(c) : (c))

char format[] =  "($$,$$$,$$$.&&)";

main()
{
    char decdsply[20];
    char ans;
    int4 ret, exp_chk();

    EXEC SQL BEGIN DECLARE SECTION;
        short stock_num;
        char description[16];
        dec_t unit_price;
        char manu_code[4];
    EXEC SQL END DECLARE SECTION;

    printf("RSETNULL Sample ESQL Program running.\n\n");
    EXEC SQL connect to 'stores_demo'; 		/* connect to stores_demo */
    exp_chk("Connect to stores_demo", NOWARNNOTIFY);

    printf("This program selects all rows for a given manufacturer\n");  
    printf("from the stock table and allows you to set the unit_price\n");
    printf("to NULL.\n");
    printf("\nTo begin, enter a manufacturer code - for example 'HSK'\n");
    printf("\nEnter Manufacturer code: ");    /* prompt for mfr. code */
    scanf("%[^\n]s",manu_code);                 /* get mfr. code */
    EXEC SQL declare upcurs cursor for 		/* declare cursor */
	    select stock_num, description, unit_price from stock
	    where manu_code = :manu_code
	    for update of unit_price;
    rupshift(manu_code);			/* Make mfr code upper case */
    EXEC SQL begin work;
    EXEC SQL open upcurs;			/* open select cursor */
    if(exp_chk("Open cursor", WARNNOTIFY) == 1)
	{
	EXEC SQL disconnect current;
	exit(1);
	}

    /*
     * Display Column Headings
     */
    printf("\nStock # \tDescription \t\tUnit Price");
    while(1)
	{
	/* get a row */
	EXEC SQL fetch upcurs into :stock_num, :description, :unit_price;
	if ((ret = exp_chk("fetch", WARNNOTIFY)) == 100) /* if end of rows */
	    break;
	if(ret == 1)
	    {
	    EXEC SQL disconnect current;
	    exit(1);
	    }
	if(risnull(CDECIMALTYPE, (char *) &unit_price))  /* unit_price NULL? */
	    continue;				/* skip to next row */
	rfmtdec(&unit_price, format, decdsply); /* format unit_price */

	/* display item */
	printf("\n\t%d\t%15s\t%s", stock_num, description, decdsply);
	ans = ' ';

	/* Set unit_price to NULL? y(es) or n(o) */
	while((ans = LCASE(ans)) != 'y' && ans != 'n')
	    {
	    printf("\n. . . Set unit_price to NULL ? (y/n) ");
	    scanf("%1s", &ans);
	    }
	if (ans == 'y')  			/* if yes, NULL to unit_price */
	    {
	    rsetnull(CDECIMALTYPE, (char *) &unit_price);
	    EXEC SQL update stock set unit_price = :unit_price
		where current of upcurs;	/* and update current row */
	    if(exp_chk("UPDATE", WARNNOTIFY) == 1)
		{
		EXEC SQL disconnect current;
		exit(1);
		}
	    }
	 }
    EXEC SQL commit work;	 
    EXEC SQL disconnect current;
    printf("\nRSETNULL Sample Program over.\n\n");
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

