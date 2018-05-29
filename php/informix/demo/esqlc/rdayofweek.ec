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
   * rdayofweek.ec *

   The following program obtains today's date from the system
   and determines what day of the week it is.
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

main()
{
    mint errnum;
    int4 i_date;
    char *day_name;
    char date[20];
    mint x;

    static  char fmtstr[9] = "mmddyyyy";

    printf("RDAYOFWEEK Sample ESQL Program running.\n\n");

    /* Allow user to enter a date */
    printf("Enter a date as a single string, month.day.year\n");
    scanf("%[^\n]s",date);

    printf("\nThe date string is %s.\n", date);

    /* Put entered date in internal format */
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
        printf("This date is a %s.\n", day_name);
	}

    printf("\nRDAYOFWEEK Sample Program over.\n\n");
    exit(0);
}
