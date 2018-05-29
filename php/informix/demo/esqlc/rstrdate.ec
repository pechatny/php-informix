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
   * rstrdate.ec *
   The following program converts a character string
   in "mmddyyyy" format to an internal date format.
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

main()
{
    int4 i_date;
    mint errnum;
    char str_date[15];

    printf("RSTRDATE Sample ESQL Program running.\n\n");


    /* Convert Sept. 6th, 1994  into i_date */
    if ((errnum = rstrdate("9.6.1994", &i_date)) == 0)
	{
        rfmtdate(i_date, "mmm dd yyyy", str_date);
        printf("Date '%s' converted to internal format\n", str_date);
	}
    else
	printf("rstrdate() call failed with error %d\n", errnum);

    printf("\nRSTRDATE Sample Program over.\n\n");
    exit(0);
}
