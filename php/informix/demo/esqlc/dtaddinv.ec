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
   * dtaddinv.ec *

   The following program adds an INTERVAL value to a DATETIME value and displays
   the result.
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

EXEC SQL include datetime;

main()
{
    char out_str[16];

    EXEC SQL BEGIN DECLARE SECTION;    
        datetime year to minute dt_var, result;
        interval day to minute intvl;
    EXEC SQL END DECLARE SECTION;

    printf("DTADDINV Sample ESQL Program running.\n\n");

    printf("datetime year to minute value=1994-11-28 11:40\n");
    dtcvasc("1994-11-28 11:40", &dt_var);
    printf("interval day to minute value =        50 10:20\n");
    incvasc("50 10:20", &intvl);

    dtaddinv(&dt_var, &intvl, &result);

    /* Convert to ASCII for displaying */
    dttoasc(&result, out_str);
    printf("----------------------------------------------\n");
    printf("                          Sum=%s\n", out_str);

    printf("\nDTADDINV Sample Program over.\n\n");
    exit(0);
}
