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
   * rmdyjul.ec *

   This program converts an array of short integers containing values
   for month, day and year into an integer that stores the date in 
   internal format. 
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

main()
{
    int4 i_date;
    mint errnum;
    static  short mdy_array[3] = { 12, 21, 1994 };
    char str_date[15];

    printf("RMDYJUL Sample ESQL Program running.\n\n");

    /* Convert MDY array into internal format */
    if ((errnum = rmdyjul(mdy_array, &i_date)) == 0)
	{
        rfmtdate(i_date, "mmm dd yyyy", str_date);
        printf("Date '%s' converted to internal format\n", str_date);
	}
    else
	printf("rmdyjul() call failed with errnum = %d\n", errnum);

    printf("\nRMDYJUL Sample Program over.\n\n");
    exit(0);
}
