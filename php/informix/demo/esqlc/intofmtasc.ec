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
   *intofmtasc.ec*
   The following program illustrates the conversion of interval values
   to ASCII strings with the specified formats.
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

EXEC SQL include datetime;

main()
{
    char out_str[60];
    char out_str2[60];
    char out_str3[60];
    mint x;

    EXEC SQL BEGIN DECLARE SECTION;
        interval day to minute short_time;
        interval minute(5) to second  moment;
    EXEC SQL END DECLARE SECTION;

    printf("INTOFMTASC Sample ESQL Program running.\n\n");

    /* Initialize short_time (day to minute) interval value */
    printf("Interval string #1: '20 days, 3 hours, 40 minutes'\n");
    x = incvfmtasc("20 days, 3 hours, 40 minutes",
     "%d days, %H hours, %M minutes", &short_time);

    /* Turn the interval into ascii string of a certain format. */
    x = intofmtasc(&short_time, out_str, sizeof(out_str),
                "%d days, %H hours, %M minutes to go!");
    printf("\tFormatted value: %s\n", out_str);

    /* Initialize moment (minute(5) to second) interval value */
    printf("\nInterval string #2: '428 minutes, 30 seconds'\n");
    x = incvfmtasc("428 minutes, 30 seconds",
     "%M minutes, %S seconds", &moment);

    /* Turn each interval into ascii string of a certain format. Note
     * that both calls to intofmtasc() both use moment as the input 
     * variable, but the output strings have different formats.
     */
    x = intofmtasc(&moment, out_str2, sizeof(out_str2),
                "%M minutes and %S seconds left.");
    x = intofmtasc(&moment, out_str3, sizeof(out_str3),
                 "%H hours, %M minutes, and %S seconds still left.");

    /* Print each resulting string */
    printf("\tFormatted value: %s\n", out_str2);
    printf("\tFormatted value: %s\n", out_str3);

    printf("\nINTOFMTASC Sample Program over.\n\n");
    exit(0);
}

