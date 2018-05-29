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
   * rjulmdy.ec *

   The following program converts today's date, represented as an
   integer in internal format, to an array of three short integers that 
   contain the month, day and year. 
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

main()
{
    int4 i_date;
    short mdy_array[3];
    mint errnum;
    char date[20];
    mint x;

    static  char fmtstr[9] = "mmddyyyy";

    printf("RJULMDY Sample ESQL program running.\n\n");

    /* Allow user to enter a date */
    printf("Enter a date as a single string, month.day.year\n");
    scanf("%[^\n]s",date);

    printf("\nThe date string is %s.\n", date);

    /* Put entered date in internal format */
    if (x = rdefmtdate(&i_date, fmtstr, date))
	printf("Error %d on rdefmtdate conversion\n", x);
    else
	{

        /* Convert from internal format to MDY array */
        if ((errnum = rjulmdy(i_date, mdy_array)) == 0)
	    {
	    printf("The month component is: %d\n", mdy_array[0]);
            printf("The  day  component is: %d\n", mdy_array[1]);
            printf("The year  component is: %d\n", mdy_array[2]);
	    }
        else
	    printf("rjulmdy call failed with error %d", errnum);
	}

    printf("\nRJULMDY Sample Program Over.\n\n");
    exit(0);
}
