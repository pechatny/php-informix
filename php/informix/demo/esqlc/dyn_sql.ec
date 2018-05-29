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
   This program prompts the user to enter a SELECT statement
   for the stores_demo database. It processes the statement using dynamic sql
   and system descriptor areas and displays the rows returned by the 
   database server. 
*/

#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>

EXEC SQL include sqltypes;
EXEC SQL include locator;
EXEC SQL include datetime;
EXEC SQL include decimal;

#define WARNNOTIFY        1
#define NOWARNNOTIFY      0

#define LCASE(c) (isupper(c) ? tolower(c) : (c))
#define BUFFSZ 256

extern char statement[80];

EXEC SQL BEGIN DECLARE SECTION;
    loc_t lcat_descr;
    loc_t lcat_picture; 
EXEC SQL END DECLARE SECTION; 

mint whenexp_chk();

main(mint argc,char *argv[])
{
    int4 ret, getrow();
    short data_found = 0;

    EXEC SQL BEGIN DECLARE SECTION;
        char ans[BUFFSZ], db_name[30];
        char name[40];
        mint sel_cnt, i;
        short type;
    EXEC SQL END DECLARE SECTION;

    printf("DYN_SQL Sample ESQL Program running.\n\n");

    EXEC SQL whenever sqlerror call whenexp_chk;

    if (argc > 2)		/* correct no. of args? */
	{
	printf("\nUsage: %s [database]\nIncorrect no. of argument(s)\n",
	    argv[0]);
        printf("\nDYN_SQL Sample Program over.\n\n");
	exit(1);
	}
    strcpy(db_name, "stores_demo");
    if(argc == 2)
	strcpy(db_name, argv[1]);

    sprintf(statement,"CONNECT TO %s",db_name);
    EXEC SQL connect to :db_name;

    printf("Connected to %s\n", db_name);
    ++argv;

    while(1)
	{
	/* prompt for SELECT statement */ 

	printf("\nEnter a SELECT statement for the %s database",
		     db_name);
	printf("\n\t(e.g.  select * from customer;)\n");
	printf("\tOR a ';' to terminate program:\n>> ");
	if(!getans(ans, BUFFSZ))
	    continue;
	if(*ans == ';')
	    {
            strcpy(statement, "DISCONNECT");
            EXEC SQL disconnect current;
            printf("\nDYN_SQL Sample Program over.\n\n");
	    exit(1);
	    }

	/* prepare statement id */
        printf("\nPreparing statement (%s)...\n", ans);
        strcpy(statement, "PREPARE sel_id");
	EXEC SQL prepare sel_id from :ans;   

	/* declare cursor */
        printf("Declaring cursor 'sel_curs' for SELECT...\n");
        strcpy(statement, "DECLARE sel_curs");
	EXEC SQL declare sel_curs cursor for sel_id;  

	/* allocate descriptor area */
        printf("Allocating system-descriptor area...\n");
        strcpy(statement, "ALLOCATE DESCRIPTOR selcat");
	EXEC SQL allocate descriptor 'selcat';    

	/* Ask the database server to describe the statement */
        printf("Describing prepared SELECT...\n");
        strcpy(statement, 
            "DESCRIBE sel_id USING SQL DESCRIPTOR selcat");
	EXEC SQL describe sel_id using sql descriptor 'selcat';
	if(SQLCODE != 0)
	    {
	    printf("** Statement is not a SELECT.\n");
	    free_stuff();
            strcpy(statement, "DISCONNECT");
            EXEC SQL disconnect current;
            printf("\nDYN_SQL Sample Program over.\n\n");
	    exit(1);
	    }

	/* Determine the number of columns in the select list */
        printf("Getting number of described values from ");
        printf("system-descriptor area...\n");
        strcpy(statement, "GET DESCRIPTOR selcat: COUNT field");
	EXEC SQL get descriptor 'selcat' :sel_cnt = COUNT;

        /* open cursor; process select statement */
        printf("Opening cursor 'sel_curs'...\n");
        strcpy(statement, "OPEN sel_curs");
	EXEC SQL open sel_curs;    

	/*
	 * The following loop checks whether the cat_picture or
	 * cat_descr columns are described in the system descriptor area.
	 * If so, it initializes a locator structure to read the blob 
 	 * data into memory and sets the address of the locator structure
	 * in the system descriptor area.
	 */	

        for(i = 1; i <= sel_cnt; i++) 
	    {
            strcpy(statement, 
                "GET DESCRIPTOR selcat: TYPE, NAME fields");
	    EXEC SQL get descriptor 'selcat' VALUE :i
		    :type = TYPE,
		    :name = NAME;
	    if(type == SQLTEXT && !strncmp(name, "cat_descr",
		 strlen("cat_descr")))
		{
		lcat_descr.loc_loctype = LOCMEMORY;
		lcat_descr.loc_bufsize = -1;
		lcat_descr.loc_oflags = 0;   
                strcpy(statement, "SET DESCRIPTOR selcat: DATA field");
		EXEC SQL set descriptor 'selcat' VALUE :i
		    DATA = :lcat_descr;
		}
	    if(type == SQLBYTES && !strncmp(name, "cat_picture",
		     strlen("cat_picture")))
		{
	        lcat_picture.loc_loctype = LOCMEMORY;
	        lcat_picture.loc_bufsize = -1;
	        lcat_picture.loc_oflags = 0;   
                strcpy(statement, "SET DESCRIPTOR selcat: DATA field");
	        EXEC SQL set descriptor 'selcat' VALUE :i
		    DATA = :lcat_picture;   
		}
	    } 
	while(ret = getrow("selcat"))		/* fetch a row */ 
	    {
            data_found = 1;
	    if(ret < 0)
		{
                strcpy(statement, "DISCONNECT");
                EXEC SQL disconnect current;
                printf("\nDYN_SQL Sample Program over.\n\n");
		exit(1);
		}
	    disp_data(sel_cnt, "selcat"); /* display the data */
	    }
        if(!data_found)
            printf("** No matching rows found.\n");
	free_stuff();
	if(!more_to_do())		/* More to do? */
	    break;			/* no, terminate loop */
	}
    exit(0);
}

/* fetch the next row for selected items */

int4 getrow(sysdesc)
EXEC SQL BEGIN DECLARE SECTION;
    PARAMETER char *sysdesc;
EXEC SQL END DECLARE SECTION;
{
    int4 exp_chk();

    sprintf(statement, "FETCH %s", sysdesc);
    EXEC SQL fetch sel_curs using sql descriptor :sysdesc;
    return((exp_chk(statement)) == 100 ? 0 : 1);
}

/* 
 * This function loads a column into a host variable of the correct 
 * type and displays the name of the column and the value, unless the 
 * value is NULL.
 */

disp_data(col_cnt, sysdesc)
mint col_cnt;
EXEC SQL BEGIN DECLARE SECTION;
    PARAMETER char * sysdesc;
EXEC SQL END DECLARE SECTION;
{
    EXEC SQL BEGIN DECLARE SECTION;
        mint int_data, i;
        char *char_data;
        int4 date_data;
        datetime dt_data;
        interval intvl_data;
        decimal dec_data;
        short short_data;
        char name[40];
        short char_len, type, ind;
    EXEC SQL END DECLARE SECTION;

    int4 size;
    unsigned amount;
    mint x;
    char shdesc[81], str[40], *p;

    printf("\n\n");
    /* For each column described in the system descriptor area, 
     * determine its data type. Then retrieve the column name and its 
     * value, storing the value in a host variable defined for the 
     * particular data type. If the column is not NULL, display the 
     * name and value.
     */	
    for(i = 1; i <= col_cnt; i++)
	{
        strcpy(statement, "GET DESCRIPTOR: TYPE field");
        EXEC SQL get descriptor :sysdesc VALUE :i 
	    :type = TYPE; 
	switch(type)
	    {
	    case SQLSERIAL:
	    case SQLINT:
                strcpy(statement, 
                    "GET DESCRIPTOR: NAME, INDICATOR, DATA fields");
	        EXEC SQL get descriptor :sysdesc VALUE :i
		    :name = NAME,
		    :ind = INDICATOR,
		    :int_data = DATA;
		if(ind == -1)
		    printf("\n%.20s: NULL", name);
		else
		    printf("\n%.20s: %d", name, int_data);
		break;
	    case SQLSMINT:
                strcpy(statement, 
                    "GET DESCRIPTOR: NAME, INDICATOR, DATA fields");
		EXEC SQL get descriptor :sysdesc VALUE :i
		    :name = NAME,
		    :ind = INDICATOR,
		    :short_data = DATA;
		if(ind == -1)
		    printf("\n%.20s: NULL", name);
		else
		    printf("\n%.20s: %d", name, short_data);
		break;
	    case SQLDECIMAL:
	    case SQLMONEY:
                strcpy(statement, 
                    "GET DESCRIPTOR: NAME, INDICATOR, DATA fields");
		EXEC SQL get descriptor :sysdesc VALUE :i
		    :name = NAME,
		    :ind = INDICATOR,
		    :dec_data = DATA;
		if(ind == -1)
		    printf("\n%.20s: NULL", name);
		else
		    {
		    if(type == SQLDECIMAL)
		        rfmtdec(&dec_data, "###,###,###.##", str);
		    else
		        rfmtdec(&dec_data, "$$$,$$$,$$$.$$", str);
		    printf("\n%.20s: %s", name, str);
		    }
		break;
	    case SQLDATE:
                strcpy(statement, 
                    "GET DESCRIPTOR: NAME, INDICATOR, DATA fields");
		EXEC SQL get descriptor :sysdesc VALUE :i
		     :name = NAME,
		     :ind = INDICATOR,
		     :date_data = DATA;
		if(ind == -1)
		    printf("\n%.20s: NULL", name);
		else
		    {
		    if((x = rfmtdate(date_data, "mmm. dd, yyyy",
			    str)) < 0)
		        printf("\ndisp_data() - DATE - fmt error");
		    else
    		        printf("\n%.20s: %s", name, str);
		    }
		break;
	    case SQLDTIME:
                strcpy(statement, 
                    "GET DESCRIPTOR: NAME, INDICATOR, DATA fields");
		EXEC SQL get descriptor :sysdesc VALUE :i
		    :name = NAME,
		    :ind = INDICATOR,
		    :dt_data = DATA;
		if(ind == -1)
		    printf("\n%.20s: NULL", name);
		else
		    {
		    x = dttofmtasc(&dt_data, str, sizeof(str), 0);
		    printf("\n%.20s: %s", name, str);
		    }
		break;
	    case SQLINTERVAL:
                strcpy(statement, 
                    "GET DESCRIPTOR: NAME, INDICATOR, DATA fields");
		EXEC SQL get descriptor :sysdesc VALUE :i
		    :name = NAME,
		    :ind = INDICATOR,
		    :intvl_data = DATA;
		if(ind == -1)
		    printf("\n%.20s: NULL", name);
		else
		    {
		    if((x = intofmtasc(&intvl_data, str,
			    sizeof(str),
		            "%3d days, %2H hours, %2M minutes"))
			     < 0)
			printf("\nINTRVL - fmt error %d", x);
		    else
			printf("\n%.20s: %s", name, str);
		    }
		break;
	    case SQLVCHAR:
	    case SQLCHAR:
                strcpy(statement, 
                    "GET DESCRIPTOR: LENGTH, NAME fields");
		EXEC SQL get descriptor :sysdesc VALUE :i
		    :char_len = LENGTH,
   		    :name = NAME;
		amount = char_len;
		if(char_data = (char *)(malloc(amount + 1)))
		    {
                    strcpy(statement,
                        "GET DESCRIPTOR: NAME, INDICATOR, DATA fields");
		    EXEC SQL get descriptor :sysdesc VALUE :i
			:char_data = DATA,
			:ind =  INDICATOR;
		    if(ind == -1)
		    	printf("\n%.20s: NULL", name);
		    else
			printf("\n%.20s: %s", name, char_data);	
		    }
		else
		    {	
		    printf("\n%.20s: ", name);
		    printf("Can't display: out of memory");
		    }
		free(char_data);
		break;
	    case SQLTEXT:
                strcpy (statement, 
                    "GET DESCRIPTOR: NAME, INDICATOR, DATA fields");
		EXEC SQL get descriptor :sysdesc VALUE :i
			:name = NAME,
			:ind = INDICATOR,
			:lcat_descr = DATA;
		size = lcat_descr.loc_size;	/* get size of data */
		printf("\n%.20s: ", name);
		if(ind == -1)
		    {
		    printf("NULL");
		    break;
		    }
		p = lcat_descr.loc_buffer;	/* set p to buf addr */

		/* print buffer 80 characters at a time */
		while(size >= 80)
		    {
		    /* mv from buffer to shdesc */
		    ldchar(p, 80, shdesc);	
		    printf("\n%80s", shdesc);    /* display it */
		    size -= 80;		/* decrement length */
		    p += 80;		/* bump p by 80 */
		    }
		strncpy(shdesc, p, size);
		shdesc[size] = '\0';
		printf("%-s\n", shdesc);	/* dsply last segment */
		break;
	    case SQLBYTES:
                strcpy (statement, 
                    "GET DESCRIPTOR: NAME, INDICATOR fields");
		 EXEC SQL get descriptor :sysdesc VALUE :i
		    :name = NAME,
		    :ind = INDICATOR;
		if(ind == -1)
		    printf("%.20s: NULL", name);
		 else
		    {
		    printf("%.20s: ", name);
		    printf("Can't display BYTE type value");
		    }
		 break;
	    default:
		printf("\nUnexpected data type: %d", type);
                EXEC SQL disconnect current;
                printf("\nDYN_SQL Sample Program over.\n\n");
		exit(1);
	    }
	}
    printf("\n");
} 

free_stuff()
{

    EXEC SQL free sel_id;	/* free resources for statement */
    EXEC SQL free sel_curs;	/* free resources for cursor */

    /* free system descriptor area */
    EXEC SQL deallocate descriptor 'selcat'; 
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
 * occurred, exp_chk() executes the GET DIAGNOSTICS statement and 
 * displays the detail for each exception that is returned.
 */
EXEC SQL include exp_chk.ec;
