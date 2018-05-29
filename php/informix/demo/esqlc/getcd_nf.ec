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
   * getcd_nf.ec *

   This program selects the cat_descr column from a specified row of the
   catalog table and loads it into a named file. The program prompts you 
   for a catalog_num value and the name of a file to receive the content 
   of the cat_descr column.  
*/

#include <stdio.h>
#include <ctype.h>
#include <string.h>
#include <stdlib.h>

EXEC SQL include sqltypes;
EXEC SQL include locator;

#define WARNNOTIFY        1
#define NOWARNNOTIFY      0

#define BUFFSZ 256

main(mint argc,char *argv[])
{
    char descfl[15], ans[BUFFSZ];
    char db_msg[ BUFFSZ + 1 ];
    int4 size, exp_chk2();

    EXEC SQL BEGIN DECLARE SECTION;
        char db_name[30];
        mlong cat_num;
        loc_t cat_descr;
    EXEC SQL END DECLARE SECTION;


    printf("GETCD_NF Sample ESQL Program running.\n\n");

    if(argc > 2)               /* correct no. of args? */
	{
        printf("\nUsage: %s [database]\nIncorrect no. of argument(s)\n",
            argv[0]);
        printf("\nGETCD_NF Sample Program over.\n\n");
        exit(1);
	}

    strcpy(db_name, "stores_demo");
    if(argc == 2)
	strcpy(db_name, argv[1]);

    EXEC SQL connect to :db_name;
    sprintf(db_msg,"CONNECT TO %s",db_name);
    if(exp_chk2(db_msg, NOWARNNOTIFY) < 0)
	{
	printf("\nGETCD_NF Sample Program over.\n\n");
        exit(1);
	}

    if(sqlca.sqlwarn.sqlwarn3 != 'W')
	{
	printf("\nThis program works only with the OnLine database server.\n");
        EXEC SQL disconnect current;
	printf("\nGETCD_NF Sample Program over.\n\n");
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
        printf("in a file that you name.\n");

        printf("\nEnter catalog number: ");    /* prompt for catalog number */
	if(!getans(ans, 6))
	    continue;
        if(rstol(ans, &cat_num))                /* cat_num string too long */
	    {
            printf("** Cannot convert catalog number '%s' to integer\n", ans);
            continue;
	    }
        while(1)
	    {
            printf("Enter the name of the file to receive the description: ");
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
    cat_descr.loc_loctype = LOCFNAME;	/* set loctype for in memory */
    cat_descr.loc_fname = descfl;	/* load the addr of file name */
    cat_descr.loc_oflags = LOC_APPEND;	/* set loc_oflags to append */
    EXEC SQL select catalog_num, cat_descr	/* verify catalog number */
	into :cat_num, :cat_descr from catalog
	where catalog_num = :cat_num;
    if(exp_chk2("SELECT", WARNNOTIFY) != 0)	/* if error, display and quit */
        printf("** Select for catalog number %ld failed\n", cat_num);
    else
        printf("\n** Select was successful. Check contents of file '%s'.\n",
            descfl); 

    EXEC SQL disconnect current;
    printf("\nGETCD_NF Sample Program over.\n\n");
    exit(0);
}

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
