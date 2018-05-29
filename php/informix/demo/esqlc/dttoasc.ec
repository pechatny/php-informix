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
   * dttoasc.ec *

   The following program illustates the conversion of a datetime value
   into an ASCII string in ANSI SQL format
*/

#include <stdio.h>
#include <string.h>
#include <stdlib.h>


EXEC SQL include datetime;
    
main()
{
    char out_str[16];

    EXEC SQL BEGIN DECLARE SECTION;
        datetime year to hour dt1;
    EXEC SQL END DECLARE SECTION;

    printf("DTTOASC Sample ESQL Program running.\n\n");

    /* Initialize dt1 */
    dtcurrent(&dt1);

    /* Convert the internal format to ascii for displaying */
    dttoasc(&dt1, out_str);

    /* Print it out*/
    printf("\tToday's datetime (year to hour) value is %s\n", out_str);

    printf("\nDTTOASC Sample Program over.\n\n");
    exit(0);
}
