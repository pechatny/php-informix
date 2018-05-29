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
   * rfmtlong.ec *

   The following program applies a series of format specifications to a series
   of longs and displays the result of each format.
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int4 lngs[] =
    {
    21020304,
    334899312,
    -334899312,
    -12344455,
    0
    };

char *formats[] =
    {
    "################",
    "$$$$$$$$$$$$$.##",
    "(&,&&&,&&&,&&&.)",
    "<<<<,<<<,<<<,<<<",
    "$************.**",
    0
    };

char result[41];

main()
{
    mint x;
    mint s = 0, f;

    printf("RFMTLONG Sample ESQL Program running.\n\n");

    while(lngs[s])    			/* for each long in lngs[] */
	{
        printf("Long Number = %d\n", lngs[s]);
	f = 0;
	while(formats[f]) 		/* format with each of formats[] */
	    {
	    if (x = rfmtlong(lngs[s], formats[f], result))
		{
		printf("Error %d in formatting %d using %s.\n",
			x, lngs[s], formats[f]);
		break;
		}
	    /*
	     * Display result and bump to next format (f++)
	     */
	    result[40] = '\0';
	    printf("  Format String = '%s'\t", formats[f++]);
            printf("\tResult = '%s'\n", result);
	    }
	++s;				/* bump to next long */
	printf("\n");			/* separate display groups */
	}

    printf("\nRFMTLONG Sample Program over.\n\n");
    exit(0);
}
