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
   * getcd_me.ec *

   This program selects the cat_descr column for a specified catalog_num value
   and displays it.
*/

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

EXEC SQL include sqltypes;
EXEC SQL include locator;

#define WARNNOTIFY        1
#define NOWARNNOTIFY      0

#define BUFFSZ 256

EXEC SQL BEGIN DECLARE SECTION;
    mlong cat_num;
    loc_t cat_descr;
EXEC SQL END DECLARE SECTION; 

main(mint argc,char *argv[])
{
    mint length;
    char ans[BUFFSZ];
    int4 ret, exp_chk2();
    char db_msg[ BUFFSZ + 1 ];

    EXEC SQL BEGIN DECLARE SECTION;
        char db_name[30];
    EXEC SQL END DECLARE SECTION;

    printf("GETCD_ME Sample ESQL Program running.\n\n");

    if (argc > 2)		/* correct no. of args? */
	{
	printf("\nUsage: %s [database]\nIncorrect no. of argument(s)\n",
	    argv[0]);
	printf("\nGETCD_ME Sample Program over.\n\n");
	exit(1);
	}

    strcpy(db_name, "stores_demo");
    if(argc == 2)
	strcpy(db_name, argv[1]);

    EXEC SQL connect to :db_name;
    sprintf(db_msg,"CONNECT TO %s",db_name);
    if(exp_chk2(db_msg, NOWARNNOTIFY) < 0)
	{
	printf("\nGETCD_ME Sample Program over.\n\n");
        exit(1);
	}

    if(sqlca.sqlwarn.sqlwarn3 != 'W')
	{
	printf("\nThis program works only with the OnLine database server.\n");
        EXEC SQL disconnect current;
	printf("\nGETCD_ME Sample Program over.\n\n");
        exit(1);
	}

    printf("Connected to %s\n", db_name);
    ++argv;

    while(1)
	{
	printf("\nThis program requires you to enter a catalog number");
	printf(" from the catalog\n");
        printf("table. For example: '10001'.  It then displays the ");
        printf("content of the\n");
        printf("cat_descr column for that catalog row. The cat_descr ");
        printf("value is stored\n");
        printf("in memory.\n");
	printf("\nEnter a catalog number: ");	/* prompt for catalog number */
	if(!getans(ans, 6))
	    continue;
	if(rstol(ans, &cat_num))  		/* cat_num string to long */
	    {
            printf("** Cannot convert catalog number '%s' to integer\n", 
                 ans);
	    continue;
	    }

	/* Prepare locator structure for select of cat_descr */
	cat_descr.loc_loctype = LOCMEMORY;	/* set loctype for in memory */
	cat_descr.loc_bufsize = -1;		/* let db get buffer */
	cat_descr.loc_oflags = 0;		/* clear loc_oflags */
	EXEC SQL select catalog_num, cat_descr	/* look up catalog number */
	    into :cat_num, :cat_descr from catalog
	    where catalog_num = :cat_num;
	if((ret = exp_chk2("SELECT", WARNNOTIFY)) == 100) /* if not found */
	    {
	    printf("** Catalog number %ld not found in catalog table\n", 
                cat_num);
	    if(!more_to_do())			/* More to do? */
		break;				/* no, terminate loop */
	    else
		continue;			/* yes */
	    }
	if(ret < 0)
	    {
            printf("\n** Select for catalog number %ld failed\n", cat_num);
            EXEC SQL disconnect current;
	    printf("\nGETCD_ME Sample Program over.\n\n");
	    exit(1);
	    }
	prdesc();				/* if found, print cat_descr */
	if(!more_to_do())				/* More to do? */
	    break;				/* no, terminate loop */
	}

    /* Terminate current database connection */
    EXEC SQL disconnect current;
    printf("\nGETCD_ME Sample Program over.\n\n");
    exit(0);
}


/* prdesc() prints cat_desc for a row in the catalog table */
#include "prdesc.c"

/*
 * The inpfuncs.c file contains the following functions used in this
 * program:
 *    more_to_do() - asks the user to enter 'y' or 'n' to indicate 
 *                  whether to run the main program loop again.
 *
 *    getans(ans, len) - accepts user input, up to 'len' number of
 *               characters and puts it in 'ans'
 */
#include "inpfuncs.c"

/*
 * The exp_chk.ec file contains the exception handling functions to
 * check the SQLSTATE status variable to see if an error has occurred 
 * following an SQL statement. If a warning or an error has
 * occurred, exp_chk2() executes the GET DIAGNOSTICS statement and 
 * displays the detail for each exception that is returned.
 */
EXEC SQL include exp_chk.ec;
