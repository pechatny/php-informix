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
   * decdiv.ec *

   The following program divides two DECIMAL numbers and displays the result.
*/

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

EXEC SQL include decimal;

char string1[] = "480";
char string2[] = "80";
char result[41];

main()
{
    mint x;
    dec_t num1, num2, dvd;

    printf("DECDIV Sample ESQL Program running.\n\n");

    if (x = deccvasc(string1, strlen(string1), &num1))
	{
	printf("Error %d in converting string1 to DECIMAL\n", x);
	exit(1);
	}
    if (x = deccvasc(string2, strlen(string2), &num2))
	{
	printf("Error %d in converting string2 to DECIMAL\n", x);
	exit(1);
	}
    if (x = decdiv(&num1, &num2, &dvd))
	{
	printf("Error %d in converting divide num1 by num2\n", x);
	exit(1);
	}
    if (x = dectoasc(&dvd, result, sizeof(result), -1))
	{
	printf("Error %d in converting dividend to string\n", x);
	exit(1);
	}
    result[40] = '\0';
    printf("\t%s / %s = %s\n", string1, string2, result);

    printf("\nDECDIV Sample Program over.\n\n");
    exit(0);
}
