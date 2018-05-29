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
   * indivdbl.ec *

   The following program divides an INTERVAL type variable by a numeric value
   and stores the result in an INTERVAL variable. The operation is done twice,
   using INTERVALs with different qualifiers to store the result. 
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

EXEC SQL include datetime;

main()
{
    char out_str[16];

    EXEC SQL BEGIN DECLARE SECTION;
        interval day to second daytosec1;
        interval hour to minute hrtomin;
        interval day to second daytosec2;
    EXEC SQL END DECLARE SECTION;

    printf("INVDIVDBL Sample ESQL Program running.\n\n");

    /* Input is 3 days, 5 hours, 27 minutes, and 30 seconds */
    printf("Interval (day to second) string = '3 5:27:30'\n");
    incvasc("3 5:27:30", &daytosec1);

    /* Divide input value by 3.0, store in hour to min interval */
    invdivdbl(&daytosec1, (double) 3.0, &hrtomin);

    /* Convert the internal format to ascii for displaying */
    intoasc(&hrtomin, out_str);
    printf("Divisor (double)                =        3.0 \n");
    printf("---------------------------------------------\n");
    printf("Quotient #1 (hour to minute)    = '%s'\n", out_str);

    /* Divide input value by 3.0, store in day to sec interval */
    invdivdbl(&daytosec1, (double) 3.0, &daytosec2);

    /* Convert the internal format to ascii for displaying */
    intoasc(&daytosec2, out_str);
    printf("Quotient #2 (day to second)  = '%s'\n", out_str);

    printf("\nINVDIVDBL Sample Program over.\n\n");
    exit(0);
}
