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
   * dtextend.ec *

   The following program illustrates the results of datetime extension.
   The fields to the right are filled with zeros,
   and the fields to the left are filled in from current date and time.
*/

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

EXEC SQL include datetime;

main()
{
    mint x;
    char year_str[20];

    EXEC SQL BEGIN DECLARE SECTION;
	datetime month to day month_dt;
	datetime year to minute year_min;
    EXEC SQL END DECLARE SECTION;

    printf("DTEXTEND Sample ESQL Program running.\n\n");

    /* Assign value to month_dt and extend */
    printf("Datetime (month to day) value = 12-07\n");
    if(x = dtcvasc("12-07", &month_dt))
	printf("Result = Error %d in dtcvasc()\n", x);
    else
	{
	if (x = dtextend(&month_dt, &year_min))
	    printf("Result = Error %d in dtextend()\n", x);
	else
	    {
	    dttoasc(&year_min, year_str);
	    printf("Datetime (year to minute) extended value = %s\n", 
               year_str);
	    }
	}

    printf("\nDTEXTEND Sample Program over.\n\n");
    exit(0);
}
