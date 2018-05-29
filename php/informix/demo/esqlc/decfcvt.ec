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
    * decfcvt.ec *

    The following program converts a series of DECIMAL numbers to strings of
    ASCII digits with 3 digits to the right of the decimal point.  For each
    conversion it displays the resulting string, the position of the decimal
    point from the beginning of the string and the sign value. 
*/

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

EXEC SQL include decimal;

char *strings[] =
    {
    "210203.204",
    "4894",
    "443.334899312",
    "-12344455",
    0
    };

char result[40];

main()
{
    mint x;
    dec_t num;
    mint i = 0, f, sign;
    char *dp, *decfcvt();

    printf("DECFCVT Sample ESQL Program running.\n\n");

    while(strings[i])
	{
        if (x = deccvasc(strings[i], strlen(strings[i]), &num))
	    {
	    printf("Error %d in converting string [%s] to DECIMAL\n",
		    x, strings[i]);
	    break;
	    }

	dp = decfcvt(&num, 3, &f, &sign);		/* to ASCII string */

	/* display result */
	printf("Input string[%d]: %s\n", i, strings[i]);
	printf("  Output of decfcvt: %c%*.*s.%s  decpt: %d  sign: %d\n\n",
			(sign ? '-' : '+'), f, f, dp, dp+f, f, sign);
	++i;						/* next string */
	}

    printf("\nDECFCVT Sample Program over.\n\n");

    return 0;
}
