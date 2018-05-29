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
   * dectrunc.ec *

   The following program truncates a DECIMAL number six times and displays each
   result.
*/

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

EXEC SQL include decimal;

char string[] = "-12345.038572";
char result[41];

main()
{
    mint x;
    mint i = 6;		/* number of decimal places to start with */
    dec_t num1;

    printf("DECTRUNC Sample ESQL Program running.\n\n");

    printf("String = %s\n", string);
    while(i)
	{
	if (x = deccvasc(string, strlen(string), &num1))
	    {
	    printf("Error %d in converting string to DECIMAL\n", x);
	    break;
	    }
	dectrunc(&num1, i);
	if (x = dectoasc(&num1, result, sizeof(result), -1))
	    {
	    printf("Error %d in converting result to string\n", x);
	    break;
	    }
	result[40] = '\0';
	printf("  Truncated to %d Fractional Digits: %s\n", i--, result);
	}

    printf("\nDECTRUNC Sample Program over.\n\n");

    exit(0);
}
