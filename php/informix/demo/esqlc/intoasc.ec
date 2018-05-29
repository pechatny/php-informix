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
   * intoasc.ec *

   The following program illustrates the conversion of an interval (intvl_t)
   into an ASCII string.
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

EXEC SQL include datetime;

main()
{
    mint x;
    char out_str[10];

    EXEC SQL BEGIN DECLARE SECTION;
        interval day(3) to day in1;
    EXEC SQL END DECLARE SECTION;

    printf("INTOASC Sample ESQL Program running.\n\n");

    printf("Interval (day(3) to day) string is '3'\n");
    if(x = incvasc("3", &in1))
	printf("Initial conversion failed with error: %d\n",x);
    else
	{
	/* Convert the internal format to ascii for displaying */
	intoasc(&in1, out_str);
	printf("Interval value after conversion is '%s'\n", out_str);
	}

    printf("\nINTOASC Sample Program over.\n\n");
    exit(0);
}
