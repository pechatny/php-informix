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
    * dececvt.ec *

    The following program converts a series of DECIMAL numbers to fixed
    strings of 20 ASCII digits.  For each conversion it displays the resulting
    string, the decimal position from the beginning of the string and the
    sign value. 
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
    "12345.67",
    ".001234",
    0
    };

char result[40];

main()
{
    mint x;
    mint i = 0, f, sign;
    dec_t num;
    char *dp, *dececvt();

    printf("DECECVT Sample ESQL Program running.\n\n");

    while(strings[i])
	{
	if (x = deccvasc(strings[i], strlen(strings[i]), &num))
	    {
	    printf("Error %d in converting string [%s] to DECIMAL\n",
		    x, strings[i]);
	    break;
	    }
	printf("\nInput string[%d]: %s\n", i, strings[i]);

	dp = dececvt(&num, 20, &f, &sign);	/* to 20-char ASCII string */
	printf(" Output of dececvt(&num, 20, ...): %c%s  decpt: %d  sign: %d\n",
			(sign ? '-' : '+'), dp, f, sign);

	dp = dececvt(&num, 10, &f, &sign);	/* to 10-char ASCII string */
	/* display result */
	printf(" Output of dececvt(&num, 10, ...): %c%s  decpt: %d  sign: %d\n",
			(sign ? '-' : '+'), dp, f, sign);

	dp = dececvt(&num, 4, &f, &sign);	/* to 4-char ASCII string */
	/* display result */
	printf(" Output of dececvt(&num, 4, ...): %c%s  decpt: %d  sign: %d\n",
			(sign ? '-' : '+'), dp, f, sign);

	dp = dececvt(&num, 3, &f, &sign);	/* to 3-char ASCII string */
	/* display result */
	printf(" Output of dececvt(&num, 3, ...): %c%s  decpt: %d  sign: %d\n",
			(sign ? '-' : '+'), dp, f, sign);

	dp = dececvt(&num, 1, &f, &sign);	/* to 1-char ASCII string */
	/* display result */
	printf(" Output of dececvt(&num, 1, ...): %c%s  decpt: %d  sign: %d\n",
			(sign ? '-' : '+'), dp, f, sign);

	++i;					/* get next string */
	}

    printf("\nDECECVT Sample Program over.\n\n");
   
    exit(0);
}
