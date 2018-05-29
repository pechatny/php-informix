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
   * dtcvasc.ec *

   The following program converts ASCII datetime strings in ANSI SQL format
   into datetime (dtime_t) structure.
*/

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

EXEC SQL include datetime;

main()
{
    mint x;

    EXEC SQL BEGIN DECLARE SECTION;
        datetime year to second dt1;
    EXEC SQL END DECLARE SECTION;

    printf("DTCVASC Sample ESQL Program running.\n\n");

    printf("Datetime string #1 = 1994-02-11 3:10:35\n");
    if (x = dtcvasc("1994-02-11 3:10:35", &dt1))
	printf("Result = failed with conversion error: %d\n", x);
    else
	printf("Result = successful conversion\n");

    /*
     * Note that the following literal string has a 26 in the hours place
     */
    printf("\nDatetime string #2 = 1994-02-04 26:10:35\n");
    if (x = dtcvasc("1994-02-04 26:10:35", &dt1))
	printf("Result = (Expected) failed with conversion error: %d\n", x);
    else
	printf("Result = successful conversion\n");

    printf("\nDTCVASC Sample Program over.\n\n");

   exit(0);
}
