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

/* *dttofmtasc.ec*
   The following program illustrates the conversion of a datetime
   value into strings of different formats.
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

EXEC SQL include datetime;

main()
{
    char out_str1[25];
    char out_str2[25];
    char out_str3[30];
    mint x;

    EXEC SQL BEGIN DECLARE SECTION;
        datetime month to minute birthday;
    EXEC SQL END DECLARE SECTION;

    printf("DTTOFMTASC Sample ESQL Program running.\n\n");

    /* Initialize birthday to "09-06 13:30" */
    printf("Birthday datetime (month to minute) value = ");
    printf("September 6 at 01:30 pm\n");
    x = dtcvfmtasc("September 6 at 01:30 pm", "%B %d at %I:%M %p", 
        &birthday);

    /* Convert the internal format to ascii for 3 given display formats. 
     * Note that the second format does not include the minutes field and that
     * the last format includes a year field even though birthday was not
     * initialized as year to minute.
     */

    x = dttofmtasc(&birthday, out_str1, sizeof(out_str1), 
            "%d %B at %H:%M");
    x = dttofmtasc(&birthday, out_str2, sizeof(out_str2), 
            "%d %B at %H");
    x = dttofmtasc(&birthday, out_str3, sizeof(out_str3), 
            "%d %B, %Y at %H:%M");

    /* Print out the three forms of the same date */
    printf("\tFormatted value (%%d %%B at %%H:%%M) = %s\n", out_str1);
    printf("\tFormatted value (%%d %%B at %%H) = %s\n", out_str2);
    printf("\tFormatted value (%%d %%B, %%Y at %%H:%%M) = %s\n", out_str3);

    printf("\nDTTOFMTASC Sample Program over.\n\n");
    exit(0);
}

