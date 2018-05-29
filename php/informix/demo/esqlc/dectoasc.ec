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
   * dectoasc.ec *

   The following program converts DECIMAL numbers to strings of varying sizes.
*/

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

EXEC SQL include decimal;

#define  END  sizeof(result)

char string1[] = "-12345.038782";
char string2[] = "480";
char result[40];

main()
{
    mint x;
    dec_t num1, num2;

    printf("DECTOASC Sample ESQL Program running.\n\n");

    printf("String Decimal Value 1 = %s\n", string1);
    if (x = deccvasc(string1, strlen(string1), &num1))
	{
	printf("Error %d in converting string1 to DECIMAL\n", x);
	exit(1);
	}
    printf("String Decimal Value 2 = %s\n", string2);
    if (x = deccvasc(string2, strlen(string2), &num2))
	{
	printf("Error %d in converting string2 to DECIMAL\n", x);
	exit(1);
	}

    printf("\nConverting Decimal back to ASCII\n");
    printf("  Executing: dectoasc(&num1, result, 5, -1)\n");
    if (x = dectoasc(&num1, result, 5, -1))
	printf("\t(Expected) Error %d in converting DECIMAL1 to string\n", x);
    else
	{
	result[5] = '\0';				/* null terminate */
	printf("\tResult = '%s'\n", result);
	}

    printf("  Executing: dectoasc(&num1, result, 10, -1)\n");
    if (x = dectoasc(&num1, result, 10, -1))
	printf("\tError %d in converting DECIMAL1 to string\n", x);
    else
	{
	result[10] = '\0';				/* null terminate */
	printf("\tResult = '%s'\n", result);
	}

    printf("  Executing: dectoasc(&num2, result, END, 3)\n");
    if (x = dectoasc(&num2, result, END, 3))
	printf("\tError %d in converting DECIMAL2 to string\n", x);
    else
	{
	result[END-1] = '\0';				/* null terminate */
	printf("\tResult = '%s'\n", result);
	}

    printf("\nDECTOASC Sample Program over.\n\n");

    return 0;
}
