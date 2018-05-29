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
 * This demo program is a version of demo3.ec that uses a
 * system-descriptor area and the X/Open GET/SET DESCRIPTOR
 * statements.
 */
#include <stdio.h>
EXEC SQL define NAME_LEN        15;

main()
{
EXEC SQL BEGIN DECLARE SECTION;
    mint i;
    mint desc_count;
    char demoquery[80];
    char colname[19];
    char result[ NAME_LEN + 1 ];
EXEC SQL END DECLARE SECTION;

    printf("DEMO4 Sample ESQL Program running.\n\n");
    EXEC SQL WHENEVER ERROR STOP;
    EXEC SQL connect to 'stores_demo';

    /* These next three lines have hard-wired both the query and
     * the value for the parameter. This information could have
     * been entered from the terminal and placed into the strings
     * demoquery and a query value string (queryvalue), respectively.
     */  
    sprintf(demoquery, "%s %s",
               "select fname, lname from customer",
               "where lname < 'C' ");

    EXEC SQL prepare demo4id from :demoquery;
    EXEC SQL declare demo4cursor cursor for demo4id;
    EXEC SQL allocate descriptor 'demo4desc' with max 4;

    EXEC SQL open demo4cursor;
    EXEC SQL describe demo4id using sql descriptor 'demo4desc';
    EXEC SQL get descriptor 'demo4desc' :desc_count = COUNT;

    printf("There are %d returned columns:\n", desc_count);
    /* Print out what DESCRIBE returns */
    for (i = 1; i <= desc_count; i++)
        prsysdesc(i);
    printf("\n\n");

    for (;;)
         {  
         EXEC SQL fetch demo4cursor using sql descriptor 'demo4desc';

         if (strncmp(SQLSTATE, "00", 2) != 0)
             break;

         /* Print out the returned values */
         for (i = 1; i <= desc_count; i++)
              {  
             EXEC SQL get descriptor 'demo4desc' VALUE :i
                :colname = NAME, :result = DATA;
             printf("Column: %s\tValue: %s\n", colname, result);
              }  
         printf("\n");
         }
 
    if (strncmp(SQLSTATE, "02", 2) != 0)
        printf("SQLSTATE after fetch is %s\n", SQLSTATE);
 
    EXEC SQL close demo4cursor;
 
    /* free resources for prepared statement and cursor */
    EXEC SQL free demo4id;
    EXEC SQL free demo4cursor;
 
    /* free system-descriptor area */
    EXEC SQL deallocate descriptor 'demo4desc';
 
    EXEC SQL disconnect current;
    printf("\nDEMO4 Sample Program over.\n\n");

    exit(0);
}

prsysdesc(index)
EXEC SQL BEGIN DECLARE SECTION;
    PARAMETER mint index;
EXEC SQL END DECLARE SECTION;
{
    EXEC SQL BEGIN DECLARE SECTION;
        mint type;
        mint len;
        mint nullable;
        char name[40];
    EXEC SQL END DECLARE SECTION;

    EXEC SQL get descriptor 'demo4desc' VALUE :index
            :type = TYPE,
            :len = LENGTH,
            :nullable = NULLABLE,
            :name = NAME;
    printf("    Column %d: type = %d, len = %d, nullable = %d, name = %s\n",
                        index, type, len, nullable, name);
}

