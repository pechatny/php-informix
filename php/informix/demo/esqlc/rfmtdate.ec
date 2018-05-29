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
   * rfmtdate.ec *

   The following program converts a date from internal format to
   a specified format using rfmtdate().
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

main()
{
    char the_date[15];
    int4 i_date;
    mint x;
    int errnum;
    static  short mdy_array[3] = { 12, 10, 1994 };

    printf("RFMTDATE Sample ESQL program running.\n\n");

    if ((errnum = rmdyjul(mdy_array, &i_date)) == 0)
	{

        /*
         * Convert date to "mm-dd-yyyy" format
         */
        if (x = rfmtdate(i_date, "mm-dd-yyyy", the_date))
	    printf("First rfmtdate() call failed with error %d\n", x);
        else
	    printf("\tConverted date (mm-dd-yyyy): %s\n", the_date);

        /*
         * Convert date to "mm.dd.yy" format
         */
        if (x = rfmtdate(i_date, "mm.dd.yy", the_date))
    	    printf("Second rfmtdate() call failed with error %d\n",x);
        else
    	    printf("\tConverted date (mm.dd.yy): %s\n", the_date);
    
        /*
         * Convert date to "mmm ddth, yyyy" format
         */
        if (x = rfmtdate(i_date, "mmm ddth, yyyy", the_date))
    	    printf("Third rfmtdate() call failed with error %d\n", x);
        else
    	    printf("\tConverted date (mmm ddth, yyyy): %s\n", the_date);
	}

    printf("\nRFMTDATE Sample Program Over.\n\n");
    exit(0);
}
