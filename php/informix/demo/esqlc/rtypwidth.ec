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
   * rtypwidth.ec *

   This program displays the name of each column in the 'orders' table and
   the number of characters required to store the column when the  
   data type is converted to characters.
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define WARNNOTIFY     1
#define NOWARNNOTIFY   0

main(mint argc,char *argv[])
{
    mint i, numchars;
    int4 exp_chk();
    char db_stmnt[50];
    struct sqlda *sql_desc;
    struct sqlvar_struct *col;

    EXEC SQL BEGIN DECLARE SECTION;
        char db_name[20];
    EXEC SQL END DECLARE SECTION;

    printf("RTYPWIDTH Sample ESQL Program running.\n\n");

    if (argc > 2)				/* correct no. of args? */
	{
	printf("\nUsage: %s [database]\nIncorrect no. of argument(s)\n",
	    argv[0]);
	exit(1);
	}
    strcpy(db_name, "stores_demo");
    if(argc == 2)
	strcpy(db_name, argv[1]);

    EXEC SQL connect to :db_name;
    sprintf(db_stmnt,"CONNECT TO %s",db_name);
    exp_chk(db_stmnt, NOWARNNOTIFY);

    printf("Connected to %s\n", db_name);

    EXEC SQL prepare query_1 from 'select * from orders';  /* prepare select */
    if(exp_chk("Prepare", WARNNOTIFY) == 1)
	{
	EXEC SQL disconnect current;
	exit(1);
	}
    EXEC SQL describe query_1 into sql_desc;	            /* setup sqlda */
    if(exp_chk("Describe", WARNNOTIFY) == 1)
	{
	EXEC SQL disconnect current;
	exit(1);
	}
    /*
     * For each column in orders print the column name and the minimum
     * number of characters required to convert the SQL type to a character
     * data type
     */
    printf("\n\tColumn Name    \t# chars\n");
    for (i = 0, col = sql_desc->sqlvar; i < sql_desc->sqld; i++, col++)
	{
	numchars = rtypwidth(col->sqltype, col->sqllen);
	printf("\t%-15s\t%d\n", col->sqlname, numchars);
	}

    EXEC SQL disconnect current;
    printf("\nRTYPWIDTH Sample Program Over.\n\n");
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

