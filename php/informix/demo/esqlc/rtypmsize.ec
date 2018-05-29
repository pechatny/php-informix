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
   * rtypmsize.ec *

   This program prepares a select statement on all columns of the
   catalog table. Then it displays the data type of each column and 
   the number of bytes needed to store it in memory.
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

EXEC SQL include sqltypes;

#define WARNNOTIFY     1
#define NOWARNNOTIFY   0

EXEC SQL BEGIN DECLARE SECTION;
    char db_name[20];
EXEC SQL END DECLARE SECTION;

main(mint argc,char  *argv[])
{
    mint i;
    char db_stmnt[50];
    int4 exp_chk();
    struct sqlda *sql_desc;
    struct sqlvar_struct *col;

    printf("RTYPMSIZE Sample ESQL Program running.\n\n");

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

    EXEC SQL prepare query_1 from 'select * from catalog'; /* prepare select */
    if(exp_chk("Prepare", WARNNOTIFY) == 1)
	{
	EXEC SQL disconnect current;
	exit(1);
	}
    EXEC SQL describe query_1 into sql_desc;	 	    /* setup sqlda */
    if(exp_chk("Describe", WARNNOTIFY) == 1)
	{
	EXEC SQL disconnect current;
	exit(1);
	}
    printf("\n\tColumn              Type    Size\n\n");	    /* column hdgs. */
    /*
     * For each column in the catalog table display the column name and
     * the number of bytes needed to store the column in memory.
     */
    for(i = 0, col = sql_desc->sqlvar; i < sql_desc->sqld; i++, col++)
	printf("\t%-20s%-8s%3d\n", col->sqlname, rtypname(col->sqltype),
		rtypmsize(col->sqltype, col->sqllen));

    EXEC SQL disconnect current;
    printf("\nRTYPMSIZE Sample Program over.\n\n");
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

