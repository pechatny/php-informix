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
   * dispcat_pic.ec *

   The following program prompts the user for a catalog number and 
   displays the cat_picture column, if it is not null, for that row of 
   the catalog table.

   WARNING: This program displays a Sun standard raster file using the
   screenload program provided by Sun. It will display properly only
   on a Sun display.
*/

#include <stdio.h>
#include <ctype.h>
#include <string.h>
#include <stdlib.h>

EXEC SQL include sqltypes;
EXEC SQL include locator;

#define WARNNOTIFY        1
#define NOWARNNOTIFY      0

#define LCASE(c) (isupper(c) ? tolower(c) : (c))
#define BUFFSZ 256

extern errno;

EXEC SQL BEGIN DECLARE SECTION;
    mlong cat_num;
    loc_t cat_descr;
    loc_t cat_picture;
EXEC SQL END DECLARE SECTION;

char cpfl[18];

main(mint argc,char *argv[])
{
    char ans[BUFFSZ];
    int4 ret, exp_chk2();
    char db_msg[ BUFFSZ + 1 ];

    EXEC SQL BEGIN DECLARE SECTION;
        char db_name[20];
        char description[16];
    EXEC SQL END DECLARE SECTION;

    printf("DISPCAT_PIC Sample ESQL Program running.\n\n");
    if (argc > 2)			/* correct no. of args? */
	{
	printf("\nUsage: %s [database]\nIncorrect no. of argument(s)\n",
	    argv[0]);
        printf("DISPCAT_PIC Sample Program over.\n\n");
	exit(1);
	}
    strcpy(db_name, "stores_demo");
    if(argc == 2)
	strcpy(db_name, argv[1]);

    EXEC SQL connect to :db_name;
    sprintf(db_msg,"CONNECT TO %s",db_name);
    if(exp_chk2(db_msg, NOWARNNOTIFY) < 0)
	{
	printf("DISPCAT_PIC Sample Program over.\n\n");
        exit(1);
	}

    if(sqlca.sqlwarn.sqlwarn3 != 'W')
	{
	printf("\nThis program works only with the INFORMIX-Universal ");
	printf("Server\n");
	printf("or the INFORMIX-OnLine Dynamic Server.\n");
        EXEC SQL disconnect current;
        printf("\nDISPCAT_PIC Sample Program over.\n\n");
        exit(1);
	}

    printf("Connected to %s\n", db_name);
    ++argv;

    while(1)
	{
	strcpy(cpfl, "./cpfl.XXXXXX");
	if(!mkstemp(cpfl))
	    {
            
	    printf("** Cannot create temporary file for catalog picture.\n");
            EXEC SQL disconnect current;
            printf("\nDISPCAT_PIC Sample Program over.\n\n");
	    exit(1);
	    }
	printf("\nEnter catalog number: ");	/* prompt for cat. number */
	if(!getans(ans, 6))
	    continue;
        printf("\n");
	if(rstol(ans, &cat_num)) 	/* cat_num string to long */
	    {
            printf("** Cannot convert catalog number '%s' to integer\n", 
                 ans);
            EXEC SQL disconnect current;
            printf("\nDISPCAT_PIC Sample Program over.\n\n");
	    exit(1);
	    }
	/*
	 *  Prepare locator structure for select of cat_descr
         */
	cat_descr.loc_loctype = LOCMEMORY;  /* set for 'in memory' */
	cat_descr.loc_bufsize = -1;         /* let db get buffer */
	cat_descr.loc_mflags = 0;   /* clear memory-deallocation feature */
	cat_descr.loc_oflags = 0;           /* clear loc_oflags */
	/*
	 *  Prepare locator structure for select of cat_picture
         */
	cat_picture.loc_loctype = LOCFNAME;   /* type = named file */
	cat_picture.loc_fname = cpfl;		/* supply file name */
	cat_picture.loc_oflags = LOC_WONLY; /* file-open mode = write */
	cat_picture.loc_size = -1;	/* size = size of file */

	/* Look up catalog number */
	EXEC SQL select description, catalog_num, cat_descr, cat_picture
	    into :description, :cat_num, :cat_descr, :cat_picture
	    from stock, catalog
	    where catalog_num = :cat_num and
		catalog.stock_num = stock.stock_num and
		catalog.manu_code = stock.manu_code;
	if((ret = exp_chk2("SELECT", WARNNOTIFY)) == 100) /* if not found */
	    {
	    printf("** Catalog number %ld not found in ", cat_num);
	    printf("catalog table.\n");
            printf("\t OR item not found in stock table.\n");
	    if(!more_to_do())
		break;
	    continue;
	    }
	if(ret < 0)
	    {
            EXEC SQL disconnect current;
            printf("\nDISPCAT_PIC Sample Program over.\n\n");
	    exit(1); 
	    }
        printf("Displaying catalog picture for %ld...\n", cat_num);
	if(cat_picture.loc_indicator == -1)
	    printf("\tNo picture available for catalog number %ld\n\n", 
                cat_num);
	else
	    display_picture();
	/*
    	 *  Display catalog_num and description from catalog table
	 */
	printf("Stock Item for %ld: %s\n", cat_num, description);
	prdesc();		/* display catalog.cat_descr */
 	unlink(cpfl);  		/* remove temp file for cat_picture */
	if(!more_to_do())	/* More to do? */
	    break;		/* no, terminate loop */

        /* If user chooses to display more catalog rows, enable the
         * memory-deallocation feature so that ESQL/C deallocates old 
         * cat_desc buffer before it allocates a new one.
         */
	cat_descr.loc_mflags = 0;   /* clear memory-deallocation feature */
	}

    EXEC SQL disconnect current;
    printf("\nDISPCAT_PIC Sample Program over.\n\n");

   exit(0);

} /* end main */

/*
 * Display the sunview raster file.  Note that this function works only
 * on SUN platforms.
 */

display_picture()
{

#ifdef SUNVIEW
    mint child, childstat, w;
    static char path[] = "/bin/screenload";
    static char *slargs[] =		/* arguments for screenload */
        {
	"-w",
	"-x260",
	"-y300",
	"-X400",
	"-Y350",
	cpfl,
	(char *) 0,
        };

    if((child = fork()) == 0)		/* child displays cat_picture */
	{
	execv(path, slargs);		/* execute screenload */
	fprintf(stderr, "\tCouldn't execute %s, errno %d\n", path, errno);
	exit(1);
	}
    /*
     * Parent waits for child to finish
     */
    if((w = wait(&childstat)) != child && w != -1)
	{
	printf("Error or orphaned child %d", w);
	exit(-1);
	}
#endif /* SUNVIEW */
#ifndef SUNVIEW
    printf("** Cannot print catalog picture.\n");
#endif /* not SUNVIEW */
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
