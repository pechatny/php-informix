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
#include <stdlib.h>
#include <string.h>

EXEC SQL define FNAME_LEN 15;
EXEC SQL define LNAME_LEN 15;

int4 sqlstate_err();

extern char statement[80];

main()
{
EXEC SQL BEGIN DECLARE SECTION;
    char fname[ FNAME_LEN + 1 ];
    char lname[ LNAME_LEN + 1 ];
EXEC SQL END DECLARE SECTION;

    EXEC SQL whenever sqlerror CALL whenexp_chk;
    EXEC SQL whenever sqlwarning CALL whenexp_chk;

    printf("GETDIAG Sample ESQL Program running.\n\n");
    strcpy (statement, "CONNECT stmt");
    EXEC SQL connect to 'stores_demo';

    strcpy (statement, "DECLARE stmt");
    EXEC SQL declare democursor cursor for
        select fname, lname
          into :fname, :lname
          from customer
          where lname < 'C';

    strcpy (statement, "OPEN stmt");
    EXEC SQL open democursor;

    strcpy (statement, "FETCH stmt");
    for (;;)
	{
        EXEC SQL fetch democursor;
        if(sqlstate_err() == 100)
            break;

        printf("%s %s\n", fname, lname);
	}

    strcpy (statement, "CLOSE stmt");
    EXEC SQL close democursor;

    strcpy (statement, "FREE stmt");
    EXEC SQL free democursor;

    strcpy (statement, "DISCONNECT stmt");
    EXEC SQL disconnect current; 

    printf("\nGETDIAG Sample Program over.\n");
    exit(0);
}        /* End of main routine */


EXEC SQL include exp_chk.ec;
