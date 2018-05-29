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
   * dtcurrent.ec *

   The following program obtains the current date from the system, converts it
   to ASCII and prints it.
*/

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

EXEC SQL include datetime;

main()
{
    mint x;
    char out_str[20];

    EXEC SQL BEGIN DECLARE SECTION;
        datetime year to minute dt1;
    EXEC SQL END DECLARE SECTION;

    printf("DTCURRENT Sample ESQL Program running.\n\n");

    /* Get today's date */
    dtcurrent(&dt1);

    /* Convert to ASCII for displaying */
    dttoasc(&dt1, out_str);
    printf("\tToday's datetime (year to minute) value is %s\n", out_str);

    printf("\nDTCURRENT Sample Program over.\n\n");

    exit(0);
}
