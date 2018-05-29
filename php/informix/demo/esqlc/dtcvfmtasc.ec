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

/* *dtcvfmtasc.ec*
   The following program illustrates the conversion of several ascii strings
   into datetime values.
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

EXEC SQL include datetime;

main()
{
    char out_str[17], out_str2[17], out_str3[17];
    mint x;

    EXEC SQL BEGIN DECLARE SECTION;
         datetime month to minute birthday;
         datetime year to minute birthday2;
         datetime year to minute birthday3;
    EXEC SQL END DECLARE SECTION;

    printf("DTCVFMTASC Sample ESQL Program running.\n\n");

    /* Initialize birthday to "09-06 13:30" */
    printf("Birthday #1 = September 6 at 01:30 pm\n");
    x = dtcvfmtasc("September 6 at 01:30 pm", "%B %d at %I:%M %p", &birthday);

    /*Convert the internal format to ascii in ANSI format, for displaying. */
    x = dttoasc(&birthday, out_str);
    printf("Datetime (month to minute) value = %s\n\n", out_str);

    /* Initialize birthday2 to "07-14-88 09:15" */
    printf("Birthday #2 = July 14, 1988 Time: 9:15 am\n");
    x = dtcvfmtasc("July 14, 1988. Time: 9:15 am", 
        "%B %d, %Y. Time: %I:%M %p", &birthday2);

    /*Convert the internal format to ascii in ANSI format, for displaying. */
    x = dttoasc(&birthday2, out_str2);
    printf("Datetime (year to minute) value = %s\n\n", out_str2);

    /* Initialize birthday3 to "07-14-XX 09:15" where XX is current year.
     * Note that birthday3 is year to minute but this initialization only
     * provides month to minute. dtcvfmtasc provides current information 
     * for the missing year.
     */
    printf("Birthday #3 = July 14. Time: 9:15 am\n");
    x = dtcvfmtasc("July 14. Time: 9:15 am", "%B %d. Time: %I:%M %p",
                 &birthday3);

    /*Convert the internal format to ascii in ANSI format, for displaying. */
    x = dttoasc(&birthday3, out_str3);
    printf("Datetime (year to minute) value with current year = %s\n", 
        out_str3);

    printf("\nDTCVFMTASC Sample Program over.\n\n");
    exit(0);
}

