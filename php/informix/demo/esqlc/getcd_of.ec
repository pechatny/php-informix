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
   * getcd_of.ec *

    This program selects the cat_descr column from a specified row of the 
    catalog table and loads it into an open file. The program prompts the   
    user to enter 1) a catalog_num value from the catalog table and 2) the
    name of the file that the program will open and write the description to.
*/

#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <errno.h>
#include <string.h>

EXEC SQL include sqltypes;
EXEC SQL include locator;

#define WARNNOTIFY        1
#define NOWARNNOTIFY      0

#define BUFFSZ 256
#define LCASE(c) (isupper(c) ? tolower(c) : c)

main(mint argc,char *argv[])
{
    char descfl[15], ans[BUFFSZ];
    char db_msg[ BUFFSZ + 1 ];
    mint fd;
    int4 ret, exp_chk2();

    EXEC SQL BEGIN DECLARE SECTION;
        char db_name[30];
        mlong cat_num;
        loc_t cat_descr;
    EXEC SQL END DECLARE SECTION;

    printf("GETCD_OF Sample ESQL Program running.\n\n");

    if(argc > 2)               /* correct no. of args? */
	{
        printf("\nUsage: %s [database]\nIncorrect no. of argument(s)\n",
            argv[0]);
	printf("\nGETCD_OF Sample Program over.\n\n");
        exit(1);
	}

    strcpy(db_name, "stores_demo");
    if(argc == 2)
	strcpy(db_name, argv[1]);

    EXEC SQL connect to :db_name;
    sprintf(db_msg,"CONNECT TO %s",db_name);
    if(exp_chk2(db_msg, NOWARNNOTIFY) < 0)
	{
	printf("\nGETCD_OF Sample Program over.\n\n");
        exit(1);
	}

    if(sqlca.sqlwarn.sqlwarn3 != 'W')
	{
	printf("\nThis program works only with the OnLine database server.\n");
        EXEC SQL disconnect current;
	printf("\nGETCD_OF Sample Program over.\n\n");
        exit(1);
	}

    printf("Connected to %s\n", db_name);
    ++argv;

    printf("\nThis program requires you to enter a catalog number");
    printf(" from the catalog\n");
    printf("table. For example: '10001'.  It then displays the ");
    printf("content of the\n");
    printf("cat_descr column for that catalog row. The cat_descr ");
    printf("value is stored\n");
    printf("in an opened (existing) file.\n");

    while(1)
	{
	do
	    {
	    printf("\nThis program requires an EXISTING file for "); 
	    printf(" storing the cat_descr value.\n");
	    printf("Does an empty file exist in the current ");
	    printf("directory? (y/n) ... ");
	    if(!getans(ans, 1))
		continue;
	    } while((ans[0] = LCASE(ans[0])) != 'y' && ans[0] != 'n');
	if(ans[0] == 'n')
	    {
	    EXEC SQL disconnect current;
	    printf("\nGETCD_OF Sample Program over.\n\n");
	    exit(0);
	    }

	printf("\nEnter the name of the file to receive the description: ");
	if(!getans(ans, 15))
	    continue;
	break;
	}
    strcpy(descfl, ans);

    while(1)
	{
	printf("\nEnter a catalog number: ");	/* prompt for catalog number */
	if(!getans(ans, 6))
	    continue;
        if(rstol(ans, &cat_num))                /* cat_num string to long */
	    {
            printf("** Cannot convert catalog number '%s' to integer\n", ans);
            continue;
	    }
	break;
	}

    /*
     * Open specified file to obtain file descriptor
     */
    if((fd = open(descfl, O_WRONLY)) < 0)
	{
	printf("** Cannot open file: %s, errno: %d\n", descfl, errno);
        EXEC SQL disconnect current;
	printf("\nGETCD_OF Sample Program over.\n\n");
	exit(1);
	}

    /*
     * Prepare locator structure for select of cat_descr
     */
    cat_descr.loc_loctype = LOCFILE;	/* set loctype for open file */
    cat_descr.loc_fd = fd;		/* load the file descriptor */
    cat_descr.loc_oflags = LOC_APPEND;	/* set loc_oflags to append */
    EXEC SQL select catalog_num, cat_descr	/* verify catalog number */
	into :cat_num, :cat_descr from catalog
	where catalog_num = :cat_num;
    if((ret = exp_chk2("SELECT", WARNNOTIFY)) == 100)	/* if not found */
	printf("\n** Catalog number %ld not found in catalog table\n", 
                cat_num);
    else
	{
        if(ret < 0)
	    {
	    printf("\n** Select for catalog number %ld failed\n", cat_num);
            close(fd);
            EXEC SQL disconnect current;
            printf("\nGETCD_OF Sample Program over.\n\n");
            exit(1);
	    }
        printf("\n** Select was successful. Check contents of file '%s'.\n",
            descfl); 
	}

/* 
 *  Deallocate file resources and terminate database connection
 */
    close(fd);
    EXEC SQL disconnect current;
    printf("\nGETCD_OF Sample Program over.\n\n");
    exit(0);
}

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
