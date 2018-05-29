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
   * rleapyear.ec *

   The following program obtains the system date into a long integer,
   which stores this date in the internal format.
   It then converts the internal format into an array of three short integers
   that contain the month, day, and year portions of the date.
   It then tests the year value to see if the year is a leap year.
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

main()
{
    int4 i_date;
    mint errnum;
    short mdy_array[3];
    char date[20];
    mint x;

    static  char fmtstr[9] = "mmddyyyy";

    printf("RLEAPYEAR Sample ESQL program running.\n\n");

    /* Allow user to enter a date */
    printf("Enter a date as a single string, month.day.year\n");
    scanf("%[^\n]s",date);

    printf("\nThe date string is %s.\n", date);

    /* Put entered date in internal format */
    if (x = rdefmtdate(&i_date, fmtstr, date))
	printf("Error %d on rdefmtdate conversion\n", x);
    else
	{

        /* Convert internal format into a MDY array */
        if ((errnum = rjulmdy(i_date, mdy_array)) == 0)
	    {
    	    /* Check if it is a leap year */
	    if (rleapyear(mdy_array[2]))
	        printf("%d is a leap year\n", mdy_array[2]);
	    else
	        printf("%d is not a leap year\n", mdy_array[2]);
	    }
        else
	    printf("rjulmdy call failed with error %d", errnum);
	}

    printf("\nRLEAPYEAR Sample Program Over.\n\n");
    exit(0);
}
