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
   * rdefmtdate.ec *

   The following program accepts a date entered from the console,
   converts it into the internal date format using rdefmtdate().
   It checks the conversion by finding the day of the week.
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

main()
{
    mint x;
    char date[20];
    int4 i_date;
    char *day_name;

    static  char fmtstr[9] = "mmddyyyy";

    printf("RDEFMTDATE Sample ESQL Program running.\n\n");

    printf("Enter a date as a single string, month.day.year\n");
    scanf("%[^\n]s",date);

    printf("\nThe date string is %s.\n", date);

    if (x = rdefmtdate(&i_date, fmtstr, date))
	printf("Error %d on rdefmtdate conversion\n", x);
    else
	{
	/* Figure out what day of the week i_date is */
	switch (rdayofweek(i_date))
	    {
	    case 0: day_name = "Sunday"; 
                    break;
	    case 1: day_name = "Monday"; 
                    break;
	    case 2: day_name = "Tuesday"; 
                    break;
	    case 3: day_name = "Wednesday"; 
                    break;
	    case 4: day_name = "Thursday";
                    break;
	    case 5: day_name = "Friday";
                    break;
	    case 6: day_name = "Saturday";
                    break;
	    }
	printf("The day of the week is %s.\n", day_name);
	}

    printf("\nRDEFMTDATE Sample Program over.\n\n");
    exit(0);
}
