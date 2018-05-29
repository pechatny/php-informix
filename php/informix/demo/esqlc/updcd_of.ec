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
   * updcd_of.ec *

   This program reads a file containing catalog numbers and
   description text. It looks up each catalog number from the file
   in the catalog table. If it is found, the program sets up a locator 
   structure for the cat_descr column and updates the column from the 
   description text in the file. The program prompts you for the name of 
   the input file. 
*/

#include <stdio.h>
#include <fcntl.h>
#include <errno.h>
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
    int4 length, ret, exp_chk2();
    mlong flpos;
    char line[81], ans[BUFFSZ], descfl[15];
    char db_msg[ BUFFSZ + 1 ];
    mint fd;

    EXEC SQL BEGIN DECLARE SECTION;
        char db_name[30];
    EXEC SQL END DECLARE SECTION;

    printf("UPDCD_OF Sample ESQL Program running.\n\n");

    if(argc > 2)               /* correct no. of args? */
	{
        printf("\nUsage: %s [database]\nIncorrect no. of argument(s)\n",
            argv[0]);
        printf("\nUPDCD_OF Sample Program over.\n\n");
        exit(1);
	}

    strcpy(db_name, "stores_demo");
    if(argc == 2)
	strcpy(db_name, argv[1]);

    EXEC SQL connect to :db_name;
    sprintf(db_msg,"CONNECT TO %s",db_name);
    if(exp_chk2(db_msg, NOWARNNOTIFY) < 0)
	{
	printf("\nUPDCD_OF Sample Program over.\n\n");
        exit(1);
	}

    if(sqlca.sqlwarn.sqlwarn3 != 'W')
	{
	printf("\nThis program works only with the OnLine database server.\n");
        EXEC SQL disconnect current;
	printf("\nUPDCD_OF Sample Program over.\n\n");
        exit(1);
	}

    printf("Connected to %s\n", db_name);
    ++argv;

    printf("\nThis program requires you to enter the name of a ");
    printf("file that contains\n");
    printf("catalog_num values and corresponding descriptions for ");
    printf("items in the catalog\n");
    printf("table.  For each catalog_num value in the file, the ");
    printf("program queries the\n");
    printf("catalog table for it.  If it finds the catalog_num, the ");
    printf("program updates the\n");
    printf("description from the file to the cat_descr column for ");
    printf("that row.  If the\n");
    printf("catalog_num is not found, the program gives you ");
    printf("the option to insert\n");
    printf("a new row in the catalog table.\n");
    printf("\nFormat of input file is:\n");
    printf("\\10004\\\nJackie Robinson signature ball. Highest \n");
    printf("professional quality, used by National League.\n");
    printf("\\10002\\\nBabe Ruth signature glove. Black leather.\n"); 
    printf("Infield/outfield style. Specify right- or left-handed.\n");
    while(1)
	{
	printf("\nEnter the name of the file containing the descriptions: ");
	if(!getans(ans, 15))
	    continue;
        break;
	}
    strcpy(descfl, ans);
    if ((fd = open(descfl, O_RDONLY)) < 0) /* open input file */
	{
	printf("** Cannot open specified file: %s\n", descfl);
        EXEC SQL disconnect current;
        printf("\nUPDCD_OF Sample Program over.\n\n");
	exit(1);
	}
    while(getcat_num(fd, line, sizeof(line)))  /* get cat_num line from file */
	{
	line[6] = '\0';				/* replace \ with null */
	if(rstol(&line[1], &cat_num))		/* cat_num string to long */
	    {
            printf("** Cannot convert catalog number in input file: %s\n", 
                &line[1]);
	    continue;
	    }
        printf("\nReading catalog number %ld from file...\n", cat_num);
	flpos = lseek(fd, 0L, 1);
	length = getdesc_len(fd);
	flpos = lseek(fd, flpos, 0);

	/* lookup cat_num in catalog table */
	EXEC SQL select catalog_num into :cat_num from catalog
	    where catalog_num = :cat_num;
	if((ret = exp_chk2("SELECT", WARNNOTIFY)) == 100)  /* if not found */
	    {
	    printf("** Catalog number %ld not found in catalog table.\n", 
                cat_num);

	    /* Insert new item? */
	    while((ans[0] = LCASE(ans[0])) != 'y' && ans[0]!= 'n')
		{
	        printf("Insert new item to catalog table? ");
		if(!getans(ans, 1))
		    continue;
	        if(ans[0] == 'y')		/* If yes */
	    	    if(insert(fd))		/* insert it */
			{
                        printf("Insert complete.\n");
			break;
			}
		}
	    continue;
	    }
	if(ret < 0)
	    {
            EXEC SQL disconnect current;
            printf("\nUPDCD_OF Sample Program over.\n\n");
	    exit(1);
	    }

	/* if found */
	cat_descr.loc_loctype = LOCFILE;	/* update from open file */
	cat_descr.loc_fd = fd;			/* load file descriptor */
	cat_descr.loc_oflags = LOC_RONLY;	/* set file-open mode (read) */
	cat_descr.loc_size = length;		/* set size of blob */

	/* update cat_descr column of catalog table */
        printf("Updating catalog row for catalog number %ld\n",
            cat_num);
	EXEC SQL update catalog set cat_descr = :cat_descr
	    where catalog_num = :cat_num;
	if(exp_chk2("UPDATE", WARNNOTIFY) < 0)
	    {
            EXEC SQL disconnect current;
            printf("\nUPDCD_OF Sample Program over.\n\n");
	    exit(1);
	    }
	printf("Update complete.\n");
	}

    EXEC SQL disconnect current;
    printf("\nUPDCD_OF Sample Program over.\n\n");
    exit(0);
}

/*
 *  getcat_num() reads file fd, looking for a line in the format:
 *
 *  	\cat_num\
 *
 *  where
 *	cat_num is the catalog number of a row to be updated
 *	length is the length of TEXT blob which follows
 */

getcat_num(mint fd,char *line,mint max)
{
    char *p;
    mint n, count = 0;

    p = line - 1;
    while((n = read(fd, ++p, 1)) > 0)
	{
	if(*p != '\\' && count == 0)		
	    {
		p = line - 1;
		continue;
	    }
	++count;		/* start counting with 1st \ */
	if(count == 7)			
	    {
	    if(*p == '\\')
		break;
	    count = 0;
	    p = line - 1;
	    }
	}
    return(n);
}

/*
 *  Calculate the length of the description
 */
getdesc_len(mint fd)
{
    mint n, count = 0;
    char p;

    while(((n = read(fd, &p, 1)) > 0) && p != '\\')
	++count;
    return count;
}

/*
 *    The insert() allows the user to insert a new item into the catalog table.
 */

insert(mint fd)
{
    char input[BUFFSZ], descr[BUFFSZ];
    mint length, fldno = 1, snum;
    int4 ret, exp_chk2();

    EXEC SQL BEGIN DECLARE SECTION;
        short stock_num;
        char manu_code[4];
        loc_t cat_picture;
        varchar cat_advert[256];
    EXEC SQL END DECLARE SECTION;

    while(fldno)
	{
	switch(fldno)				/* fldno = current input */
	    {
	    case 1:				/* fldno 1 is stock_num */
		/* set length of input */
		length = rtypwidth(SQLSMINT, 0);
		/* prompt for stock_num */
		printf("\nEnter stock_num (%d chars): ", length);
		if(!getans(input, length))      /* input stock_num */
		    continue;
		if(rstoi(input, &snum)) 	/* string to int */
		    continue;
		stock_num = snum;		/* int to short */
		fldno = 2;			/* set to next field */
		break;
	    case 2:				/* fldno 2 is manu_code */
		/* prompt for manufacturer code */
		printf("Enter manu_code (%d chars): ", sizeof(manu_code)-1);
		if(!getans(input, sizeof(manu_code)))
		    continue;
		rupshift(input);		/* force upper case */
		strncpy(manu_code, input, 3);   /* copy to host var */
		/*
		 *  stock_num, manu_code must be in stock so look it up
		 */
		EXEC SQL select stock_num, manu_code
		    into :stock_num, :manu_code from stock
		    where stock_num = :stock_num and manu_code = :manu_code;

                /* if not found */
		if((ret = exp_chk2("SELECT", WARNNOTIFY)) == 100)  
		    {
		    printf("\n\tRow not found in stock table for stock_num");
		    printf("=%d, manu_code=%s\n", stock_num, manu_code);
		    return 0;
		    }
		if(ret < 0)
		    {
                    EXEC SQL disconnect current;
                    printf("UPDCD_OF Sample Program over.\n\n");
		    exit(1);
		    }
		fldno = 3;			/* set to next field */
		break;
	    case 3:				/* fldno 3 is cat_advert */
		/* Prompt for advertisement */
		printf("Enter advertisement(%d chars):\n\t", BUFFSZ - 1);
		if(!getans(cat_advert, BUFFSZ - 1))  /* input advertisement */
		    continue;
		fldno = 0;			/* terminate input loop */
		break;
	    default:
		printf("insert(): fldno variable corrupt - %d", fldno);
                EXEC SQL disconnect current;
                printf("\nUPDCD_OF Sample Program over.\n\n");
		exit(1);
	    }
	}
    /*
     * Set locator structure for cat_picture
     */
    cat_picture.loc_loctype = LOCMEMORY;
    cat_picture.loc_indicator = -1;		/* set blob to NULL */
    cat_descr.loc_oflags = 0;		/* clear loc_oflags */
    /*
     * Set locator structure for cat_descr
     */
    cat_descr.loc_loctype = LOCFILE;	        /* update from open file */
    cat_descr.loc_fd = fd;			/* load file descriptor */
    cat_descr.loc_oflags = LOC_RONLY;		/* set file-open mode (read) */
    cat_descr.loc_size = length;		/* set size of blob */
    /*
     * Insert
     */
    EXEC SQL insert into catalog values (:cat_num, :stock_num, :manu_code, 
        :cat_descr, :cat_picture, :cat_advert);
    if(exp_chk2("INSERT", WARNNOTIFY) < 0)
	{
        EXEC SQL disconnect current;
        printf("UPDCD_OF Sample Program over.\n\n");
	exit(1);
	}
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
