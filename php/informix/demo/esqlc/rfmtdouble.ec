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
   * rfmtdouble.ec *

   The following program applies a series of format specifications to a series
   of doubles and displays the result of each format.
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

double dbls[] =
    {
    210203.204,
    4894,
    443.334899312,
    -12344455,
    0
    };

char *formats[] =
    {
    "#############",
    "<,<<<,<<<,<<<",
    "$$$$$$$$$$.##",
    "(&&,&&&,&&&.)",
    "$*********.**",
    0
    };

char result[41];

main()
{
    mint x;
    mint i = 0, f;

    printf("RFMTDOUBLE Sample ESQL Program running.\n\n");

    while(dbls[i])    			/* for each number in dbls */
	{
        printf("Double Number = %g\n", dbls[i]);
	f = 0;
	while(formats[f])  		/* format with each of formats[] */
	    {
	    if (x = rfmtdouble(dbls[i], formats[f], result))
		{
		printf("Error %d in formating %g using %s\n",
			x, dbls[i], formats[f]);
		break;
		}
	    /*
	     * Display each result and bump to next format (f++)
	     */
	    result[40] = '\0';
	    printf("  Format String = '%s'\t", formats[f++]);
            printf("\tResult = '%s'\n", result);
	    }
	++i;				/* bump to next double */
	printf("\n");			/* separate result groups */
	}

    printf("\nRFMTDOUBLE Sample Program over.\n\n");
    exit(0);
}
