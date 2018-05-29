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
   * rtypname.ec *

   This program displays the name and the data type of each column
   in the 'orders' table.
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

EXEC SQL include sqltypes;

#define WARNNOTIFY     1
#define NOWARNNOTIFY   0

main(mint argc, char *argv[])
{
    mint i;
    int4 exp_chk();
    char db_stmnt[50];
    char *rtypname();
    struct sqlda *sql_desc;
    struct sqlvar_struct *col;

    EXEC SQL BEGIN DECLARE SECTION;
        char db_name[20];
    EXEC SQL END DECLARE SECTION;

    printf("RTYPNAME Sample ESQL Program running.\n\n");

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
    EXEC SQL describe query_1 into sql_desc;	    /* initialize sqlda */
    if(exp_chk("Describe", WARNNOTIFY) == 1)
	{
	EXEC SQL disconnect current;
	exit(1);
	}

    /*
     * For each column in the orders table display the column name and
     * the name of the SQL data type
     */
    printf("\n\tColumn Name    \t\tSQL type\n\n");
    for (i = 0, col = sql_desc->sqlvar; i < sql_desc->sqld; i++, col++)
        printf("\t%-15s\t\t%s\n", col->sqlname, rtypname(col->sqltype));

    EXEC SQL disconnect current;
    printf("\nRTYPNAME Sample Program over.\n\n");
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

