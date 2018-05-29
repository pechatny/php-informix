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
   * invmuldbl.ec *

   The following program multiplies an INTERVAL type variable by a numeric value
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
        interval hour to minute hrtomin1;
        interval hour to minute hrtomin2;
        interval day to second daytosec;
    EXEC SQL END DECLARE SECTION; 
    
    printf("INVMULDBL Sample ESQL Program running.\n\n");

    /* input is 25 hours, 49 minutes */
    printf("Interval (hour to minute)    =      25:49\n");
    incvasc("25:49", &hrtomin1);
    printf("Multiplier (double)          =        3.0\n");
    printf("---------------------------------------------\n");

    /* Convert the internal format to ascii for displaying */
    invmuldbl(&hrtomin1, (double) 3.0, &hrtomin2);
    intoasc(&hrtomin2, out_str);
    printf("Product #1 (hour to minute)  =    '%s'\n", out_str); 

    /* Convert the internal format to ascii for displaying */
    invmuldbl(&hrtomin1, (double) 3.0, &daytosec);
    intoasc(&daytosec, out_str);
    printf("Product #2 (day to second)   = '%s'\n", out_str);

    printf("\nINVMULDBL Sample Program over.\n\n");
    exit(0);
}
