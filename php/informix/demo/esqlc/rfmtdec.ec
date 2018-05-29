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
   * rfmtdec.ec *

   The following program applies a series of format specifications to each of
   a series of DECIMAL numbers and displays each result.
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

EXEC SQL include decimal;

char *strings[] =
    {
    "210203.204",
    "4894",
    "443.334899312",
    "-12344455",
    0
    };

char *formats[] =
    {
    "**###########",
    "$$$$$$$$$$.##",
    "(&&,&&&,&&&.)",
    "<,<<<,<<<,<<<",
    "$*********.**",
    0
    };

char result[41];

main()
{
    mint x;
    mint s = 0, f;
    dec_t num;

    printf("RFMTDEC Sample ESQL Program running.\n\n");

    while(strings[s])
	{
	/*
	 *  Convert each string to DECIMAL
	 */
        printf("String = %s\n", strings[s]);
	if (x = deccvasc(strings[s], strlen(strings[s]), &num))
	    {
	    printf("Error %d in converting string [%s] to decimal\n",
			x, strings[s]);
	    break;
	    }
	f = 0;
	while(formats[f])
	    {
	    /*
	     * Format DECIMAL num for each of formats[f]
	     */
	    rfmtdec(&num, formats[f], result);
	    /*
	     * Display result and bump to next format (f++)
	     */
	    result[40] = '\0';
	    printf("  Format String = '%s'\t", formats[f++]);
            printf("\tResult = '%s'\n", result);
	    }
	++s;   				    /* bump to next string */
	printf("\n");			    /* separate result groups */
	}

    printf("\nRFMTDEC Sample Program over.\n\n");
    exit(0);
}
