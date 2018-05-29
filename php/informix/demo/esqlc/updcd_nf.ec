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
   * updcd_nf.ec *

   This program allows the user to update the description for a row in the 
   catalog table. It selects the cat_descr column of the catalog table for
   a specified catalog_num value and updates it from text in a named 
   file. The program prompts you for a  catalog_num value and the name of
   the file that contains the description.  
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
    char ans[BUFFSZ], descfl[15];
    char db_msg[ BUFFSZ + 1 ];
    int4 size, ret, exp_chk2();

    EXEC SQL BEGIN DECLARE SECTION;
        char db_name[30];
    EXEC SQL END DECLARE SECTION;

    printf("UPDCD_NF Sample ESQL Program running.\n\n");

    if(argc > 2)               /* correct no. of args? */
	{
        printf("\nUsage: %s [database]\nIncorrect no. of argument(s)\n",
            argv[0]);
        printf("\nUPDCD_NF Sample Program over.\n\n");
        exit(1);
	}

    strcpy(db_name, "stores_demo");
    if(argc == 2)
	strcpy(db_name, argv[1]);

    EXEC SQL connect to :db_name;
    sprintf(db_msg,"CONNECT TO %s",db_name);
    if(exp_chk2(db_msg, NOWARNNOTIFY) < 0)
	{
	printf("\nUPDCD_NF Sample Program over.\n\n");
        exit(1);
	}

    if(sqlca.sqlwarn.sqlwarn3 != 'W')
	{
	printf("\nThis program works only with the OnLine database server.\n");
        EXEC SQL disconnect current;
	printf("\nUPDCD_NF Sample Program over.\n\n");
        exit(1);
	}

    printf("Connected to %s\n", db_name);
    ++argv;

    while(1)
	{
        printf("\nThis program requires you to enter a catalog number");
        printf(" from the catalog\n");
        printf("table.  For example, '10001'. It then prompts you ");
	printf("for the name of a\n");
        printf("file that contains a description to update to the ");
        printf("cat_descr column of\n");
        printf("that row.\n");
	printf("\nFormat of input file is:\n");
	printf("Jackie Robinson signature ball. Highest ");
	printf("professional quality, used by National League.\n");

        /* prompt for catalog number */
        printf("\nEnter the catalog number: ");    
	if(!getans(ans, 6))
	    continue;
        if(rstol(ans, &cat_num))                /* cat_num string to long */
	    {
            printf("** Cannot convert catalog number '%s' to integer\n", 
                 ans);
            continue;
	    }
        while(1)
	    {
            printf("Enter the name of the file containing the description: ");
	    if(!getans(ans, 15))
		continue;
	    break;
	    }
	strcpy(descfl, ans);
	break;
	}

    /*
     * Prepare locator structure for select of cat_descr
     */
    cat_descr.loc_loctype = LOCMEMORY;		/* set loctype for in memory */
    cat_descr.loc_bufsize = -1;			/* let engine get memory */
    EXEC SQL select catalog_num, cat_descr	/* verify catalog number */
	into :cat_num, :cat_descr from catalog
	where catalog_num = :cat_num;

    /* if error, display and quit */
    if((ret = exp_chk2("SELECT", WARNNOTIFY)) == 100) 
	{
	printf("** Catalog number %ld not found in catalog table.\n", 
            cat_num);
        EXEC SQL disconnect current;
        printf("\nUPDCD_NF Sample Program over.\n\n");
	exit(1);
	}
    if(ret < 0)
	{
        EXEC SQL disconnect current;
        printf("\nUPDCD_NF Sample Program over.\n\n");
	exit(1);
	}
    prdesc();					/* print current cat_descr */

    /* Update? */
    ans[0] = ' ';
    while((ans[0] = LCASE(ans[0])) != 'y' && ans[0] != 'n')
	{
        printf("Update this description? (y/n) ... ");
	scanf("%1s", ans);
	}
    if(ans[0] == 'y')
	{
	cat_descr.loc_loctype = LOCFNAME;	/* set type to named file */
	cat_descr.loc_fname = descfl;		/* supply file name */
	cat_descr.loc_oflags = LOC_RONLY;	/* set file-open mode (read) */
	cat_descr.loc_size = -1;		/* set size to size of file */
	EXEC SQL update catalog
	   set cat_descr = :cat_descr  		/* update cat_descr column */
	   where catalog_num = :cat_num;
	if(exp_chk2("UPDATE", WARNNOTIFY) < 0)	/* check status */
	    {
            EXEC SQL disconnect current;
            printf("\nUPDCD_NF Sample Program over.\n\n");
	    exit(1);
	    }
	printf("Update complete.\n");
	}

    printf("\nUPDCD_NF Sample Program over.\n\n");
    EXEC SQL disconnect current;
    exit(0);
}

/* 
 * prdesc() prints cat_desc for a row in the catalog table 
 */
#include "prdesc.c"

/*
 * The inpfuncs.c file contains the following functions used in this
 * program:
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
