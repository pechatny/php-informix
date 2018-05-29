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
   * invdivinv.ec *

   The following program divides one interval value by another and displays
   the resulting numeric value.
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

EXEC SQL include datetime;

main()
{
    mint x;
    char out_str[16];

    EXEC SQL BEGIN DECLARE SECTION;
        interval hour to minute hrtomin1, hrtomin2;
        double res;
    EXEC SQL END DECLARE SECTION;
    
    printf("INVDIVINV Sample ESQL Program running.\n\n");

    printf("Interval #1 (hour to minute) = 75:27\n");
    incvasc("75:27", &hrtomin1);
    printf("Interval #2 (hour to minute) = 19:10\n");
    incvasc("19:10", &hrtomin2);

    printf("------------------------------------\n");
    invdivinv(&hrtomin1, &hrtomin2, &res);
    printf("Quotient (double)            =  %.1f\n", res);

    printf("\nINVDIVINV Sample Program over.\n\n");
    exit(0);
}
