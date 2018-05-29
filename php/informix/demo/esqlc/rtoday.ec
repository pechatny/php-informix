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
   * rtoday.ec *

   The following program obtains today's date from the system,
   converts it to ASCII using rdatestr(), and displays the result.
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

main()
{
    mint errnum;
    char today_date[20];
    int4 i_date;

    printf("RTODAY Sample ESQL Program running.\n\n");

    /* Get today's date in the internal format */
    rtoday(&i_date);

    /* Convert date from internal format into a mm/dd/yyyy string */
    if ((errnum = rdatestr(i_date, today_date)) == 0)
	printf("\n\tToday's date is %s.\n", today_date);
    else
	printf("\n\tError %d in converting date to mm/dd/yyyy\n", errnum);

    printf("\nRTODAY Sample Program over.\n\n");
    exit(0);
}
