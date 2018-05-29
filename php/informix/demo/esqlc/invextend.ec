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
   * invextend.ec *

   The following program illustrates INTERVAL extension. It extends an INTERVAL 
   value to another INTERVAL value with a different qualifier. Note that in the
   second example, the output contains zeros in the seconds field and the 
   days field has been set to 3. 
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

EXEC SQL include datetime;

main()
{
    mint x;
    char out_str[16];

    EXEC SQL BEGIN DECLARE SECTION;
        interval hour to minute hrtomin;
        interval hour to hour hrtohr;
        interval day to second daytosec;
    EXEC SQL END DECLARE SECTION;

    printf("INVEXTEND Sample ESQL Program running.\n\n");

    printf("Interval (hour to minute) value  =     75:27\n");
    incvasc("75:27", &hrtomin);

    /* Extend to hour-to-hour and convert the internal format to 
     * ascii for displaying 
     */
    invextend(&hrtomin, &hrtohr);
    intoasc(&hrtohr, out_str);
    printf("Extended (hour to hour) value    =    %s\n", out_str);

    /* Extend to day-to-second and convert the internal format to 
     * ascii for displaying 
     */
    invextend(&hrtomin, &daytosec);
    intoasc(&daytosec, out_str);
    printf("Extended (day to second) value   = %s\n", out_str);

    printf("\nINVEXTEND Sample Program over.\n\n");
    exit(0);
}
