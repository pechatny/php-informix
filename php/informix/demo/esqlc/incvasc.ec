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
   * incvasc.ec *

   The following program converts ASCII strings into interval (intvl_t)
   structure. It also illustrates error conditions involving invalid
   qualifiers for interval values.
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

EXEC SQL include datetime;

main()
{
    mint x;

    EXEC SQL BEGIN DECLARE SECTION; 
        interval day to second in1;
    EXEC SQL END DECLARE SECTION; 

    printf("INCVASC Sample ESQL program running.\n\n");

    printf("Interval string #1 = 20 3:10:35\n");
    if(x = incvasc("20 3:10:35", &in1))
	printf("Result = failed with conversion error: %d\n", x);
    else
	printf("Result = successful conversion\n");

    /*
     * Note that the following literal string has a 26 in the hours field
     */
    printf("\nInterval string (invalid hour)  #2 = 20 26:10:35\n");
    if(x = incvasc("20 26:10:35", &in1))
	printf("Result = (Expected) failed with conversion error: %d\n", x);

    /*
     * Try to convert using an invalid qualifier (YEAR to SECOND)
     */
    printf("\nInterval string (invalid qualifier)  #3 = 1994-02-11 3:10:35\n");
    in1.in_qual = TU_IENCODE(4, TU_YEAR, TU_SECOND);
    if(x = incvasc("1994-02-11 3:10:35", &in1))
	printf("Result = (Expected) failed with conversion error: %d\n", x);

    printf("\nINCVASC Sample Program over.\n\n");
    exit(0);
}
