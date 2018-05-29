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

/* *incvfmtasc.ec*
   The following program illustrates the conversion of two strings
   to three interval values.       
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

EXEC SQL include datetime;

main()
{
    char out_str[30];
    char out_str2[30];
    char out_str3[30];
    mint x;

    EXEC SQL BEGIN DECLARE SECTION;
        interval day to minute short_time;
        interval minute(5) to second  moment;
        interval hour to second  long_moment;
    EXEC SQL END DECLARE SECTION;

    printf("INVCFMTASC Sample ESQL Program running.\n\n");

    /* Initialize short_time  */
    printf("Interval string #1 = 20 days, 3 hours, 40 minutes\n");
    x = incvfmtasc("20 days, 3 hours, 40 minutes",
     "%d days, %H hours, %M minutes", &short_time);

    /*Convert the internal format to ascii in ANSI format, for displaying. */
    x = intoasc(&short_time, out_str);
    printf("Interval value (day to minute) = %s\n", out_str);

    /* Initialize moment */
    printf("\nInterval string #2 = 428 minutes, 30 seconds\n");
    x = incvfmtasc("428 minutes, 30 seconds",
     "%M minutes, %S seconds", &moment);

    /*Convert the internal format to ascii in ANSI format, for displaying. */
    x = intoasc(&moment, out_str2);
    printf("Interval value (minute to second) = %s\n", out_str2);

    /* Initialize long_moment */
    printf("\nInterval string #3 = 428 minutes, 30 seconds\n");
    x = incvfmtasc("428 minutes, 30 seconds",
     "%M minutes, %S seconds", &long_moment);

    /*Convert the internal format to ascii in ANSI format, for displaying. */
    x = intoasc(&long_moment, out_str3);
    printf("Interval value (hour to second) = %s\n", out_str3);

    printf("\nINCVASC Sample Program over.\n\n");
    exit(0);
}

