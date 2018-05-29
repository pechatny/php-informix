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


#include <stdio.h>

EXEC SQL define FNAME_LEN       15;
EXEC SQL define LNAME_LEN       15;

main()
{
EXEC SQL BEGIN DECLARE SECTION;
    char demoquery[80];
    char queryvalue[2];
    char fname[ FNAME_LEN + 1 ];
    char lname[ LNAME_LEN + 1 ];
EXEC SQL END DECLARE SECTION;

    printf("DEMO2 Sample ESQL Program running.\n\n");
    EXEC SQL WHENEVER ERROR STOP;
    EXEC SQL connect to 'stores_demo';

    /* These next three lines have hard-wired the query. This
     * information could have been entered from the terminal
     * and placed into the demoquery string.
     */  
    sprintf(demoquery, "%s %s",
               "select fname, lname from customer",
           "where lname < ? ");

    EXEC SQL prepare demo2id from :demoquery;
    EXEC SQL declare demo2cursor cursor for demo2id;

    /* This next line has hard-wired the value for the parameter.
     * This information could also have been entered from the
     * terminal and placed into the queryvalue string.
     */  
    sprintf(queryvalue, "C");
    EXEC SQL open demo2cursor using :queryvalue;

    for (;;)
        {
        EXEC SQL fetch demo2cursor into :fname, :lname;
        if (strncmp(SQLSTATE, "00", 2) != 0)
            break;

        /* Print out the returned values */
        printf("Column: fname\tValue: %s\n", fname);
        printf("Column: lname\tValue: %s\n", lname);
        printf("\n");
        }

    if (strncmp(SQLSTATE, "02", 2) != 0)
        printf("SQLSTATE after fetch is %s\n", SQLSTATE);

    EXEC SQL close demo2cursor;

    EXEC SQL free demo2id;
    EXEC SQL free demo2cursor;

    EXEC SQL disconnect current;
    printf("\nDEMO2 Sample Program over.\n\n");
 
    exit(0);
}
