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
   * upcd_me.ec *

   The following program allows the user to update the description for a row
   in the catalog table.
*/

#include <stdio.h>
#include <ctype.h>
#include <stdlib.h>
#include <string.h>

EXEC SQL include sqltypes;
EXEC SQL include locator;

#define WARNNOTIFY        1
#define NOWARNNOTIFY      0

#define LCASE(c) (isupper(c) ? tolower(c) : c)
#define BUFFSZ 256

EXEC SQL BEGIN DECLARE SECTION;
    mlong cat_num;
    loc_t cat_descr;
EXEC SQL END DECLARE SECTION;

main(mint argc,char *argv[])
{
    char ans[BUFFSZ];
    char db_msg[ BUFFSZ + 1 ];
    int4 ret, exp_chk2();

    EXEC SQL BEGIN DECLARE SECTION;
        char db_name[30];
    EXEC SQL END DECLARE SECTION;

    printf("UPDCD_ME Sample ESQL Program running.\n\n");

    if(argc > 2)				/* correct no. of args? */
	{
	printf("\nUsage: %s [database]\nIncorrect no. of argument(s)\n",
	    argv[0]);
	printf("\nUPDCD_ME Sample Program over.\n\n");
	exit(1);
	}
    strcpy(db_name, "stores_demo");
    if(argc == 2)
	strcpy(db_name, argv[1]);

    EXEC SQL connect to :db_name;
    sprintf(db_msg,"CONNECT TO %s",db_name);
    if(exp_chk2(db_msg, NOWARNNOTIFY) < 0)
	{
	printf("\nUPDCD_ME Sample Program over.\n\n");
        exit(1);
	}

    if(sqlca.sqlwarn.sqlwarn3 != 'W')
	{
	printf("\nThis program works only with the OnLine database server.\n");
        EXEC SQL disconnect current;
	printf("\nUPDCD_ME Sample Program over.\n\n");
        exit(1);
	}

    printf("Connected to %s\n", db_name);
    ++argv;

    while(1)
	{
	printf("\nThis program displays the cat_descr column of the");
	printf(" the catalog table for a\n");
        printf("specified catalog number.  For example: '10001'.  It");
        printf(" then displays the\n");
        printf("content of the cat_descr column for that catalog row.");
        printf(" The cat_descr value\n");
        printf("is stored in memory.\n");
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
	if((ret = exp_chk2("SELECT", WARNNOTIFY)) == 100)  /* if not found */
	    {
	    printf("** Catalog number %ld not found in catalog table\n", 
                cat_num);
	    if(!more_to_do())				/* More to do? */
		break;				/* no, terminate loop */
	    else
		continue;			/* yes */
	    }
	if(ret < 0)
	    {
            EXEC SQL disconnect current;
	    printf("\nUPDCD_ME Sample Program over.\n\n");
	    exit(1);
	    }
	prdesc();				/* if found, print cat_descr */

	/* Update? */
        ans[0] = ' ';
	while((ans[0] = LCASE(ans[0])) != 'y' && ans[0] != 'n')
	    {
            /* update description? */
	    printf("\nUpdate this description? (y/n) ... ");  
	    getans(ans, 1);
	    }
	if(ans[0] == 'y')			/* if yes */
	    {
	    /* Enter description */
	    printf("\nEnter description (max of %d chars) and press RETURN:\n", 
                BUFFSZ - 1);
	    getans(ans, BUFFSZ - 1);
	    cat_descr.loc_loctype = LOCMEMORY;	/* set loctype for in memory */
	    cat_descr.loc_buffer = ans;		/* set buffer addr */
	    cat_descr.loc_bufsize = BUFFSZ;	/* set buffer size */
	    /* set size of data */
	    cat_descr.loc_size = strlen(ans) + 1;
	    /* Update */
	    EXEC SQL update catalog 
                set cat_descr = :cat_descr
		where catalog_num = :cat_num;
	    if(exp_chk2("UPDATE", WARNNOTIFY) < 0)
		{
                EXEC SQL disconnect current;
	        printf("\nUPDCD_ME Sample Program over.\n\n");
		exit(1);
		}
	    printf("Update complete.\n");
	    }
	if(!more_to_do())			/* More to do? */
	    break;				/* no, terminate loop */
	}

    EXEC SQL disconnect current;
    printf("\nUPDCD_ME Sample Program over.\n\n");
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

