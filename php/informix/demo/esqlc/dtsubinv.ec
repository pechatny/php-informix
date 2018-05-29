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
   * dtsubinv.ec *

   The following program subtracts an INTERVAL value from a DATETIME value and
   displays the result.
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

    printf("DTSUBINV Sample ESQL Program running.\n\n");

    printf("Datetime (year to month) value = 1994-11-28\n");
    dtcvasc("1994-11-28 11:40", &dt_var);
    printf("Interval (day to minute) value =            50 10:20 \n");
    incvasc("50 10:20", &intvl);

    printf("----------------------------------------------------\n");
    dtsubinv(&dt_var, &intvl, &result);

    /* Convert to ASCII for displaying */
    dttoasc(&result, out_str);
    printf("Difference (year to hour)      = %s\n", out_str);

    printf("\nDTSUBINV Sample Program over.\n\n");
    exit(0);
}
