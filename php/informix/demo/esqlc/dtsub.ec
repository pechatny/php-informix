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
   * dtsub.ec *

   The following program subtracts one DATETIME value from another and displays
   the resulting INTERVAL value or an error message.
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
        datetime year to month dt_var1, dt_var2;
        interval year to month i_ytm;
        interval month to month i_mtm;
        interval day to hour i_dth;
    EXEC SQL END DECLARE SECTION;
    
    printf("DTSUB Sample ESQL Program running.\n\n");

    printf("Datetime (year to month) value #1 = 1994-10\n");
    dtcvasc("1994-10", &dt_var1);
    printf("Datetime (year to month) value #2 = 1991-08\n");
    dtcvasc("1991-08", &dt_var2);

    printf("-------------------------------------------\n");

    /* Determine year-to-month difference */
    printf("Difference (year to month)        = ");
    if(x = dtsub(&dt_var1, &dt_var2, &i_ytm))
	printf("Error from dtsub(): %d\n", x);
    else
	{
        /* Convert to ASCII for displaying */
        intoasc(&i_ytm, out_str);
        printf("%s\n", out_str);
	}

    /* Determine month-to-month difference */
    printf("Difference (month to month)       = ");
    if(x = dtsub(&dt_var1, &dt_var2, &i_mtm))
	printf("Error from dtsub(): %d\n", x);
    else
	{
        /* Convert to ASCII for displaying */
        intoasc(&i_mtm, out_str);
        printf("%s\n", out_str);
	}

    /* Determine day-to-hour difference: Error - Can't convert 
     * year-to-month to day-to-hour 
     */
    printf("Difference (day to hour)          = ");
    if(x = dtsub(&dt_var1, &dt_var2, &i_dth))  
	printf("(Expected) Error from dtsub(): %d\n", x);
    else
	{
        /* Convert to ASCII for displaying */
        intoasc(&i_dth, out_str);
	printf("%s\n", out_str);
	}

    printf("\nDTSUB Sample Program over.\n\n");
    exit(0);
}
