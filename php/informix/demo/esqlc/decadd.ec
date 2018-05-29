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
   * decadd.ec *

   The following program obtains the sum of two DECIMAL numbers.
*/

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

EXEC SQL include decimal;

char string1[] = "  1000.6789";	/* leading spaces will be ignored */
char string2[] = "80";
char result[41];

main()
{
    mint x;
    dec_t num1, num2, sum;

    printf("DECADD Sample ESQL Program running.\n\n");

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
    if (x = decadd(&num1, &num2, &sum))
	{
	printf("Error %d in adding DECIMALs\n", x);
	exit(1);
	}
    if (x = dectoasc(&sum, result, sizeof(result), -1))
	{
	printf("Error %d in converting DECIMAL result to string\n", x);
	exit(1);
	}
    result[40] = '\0';
    printf("\t%s + %s = %s\n", string1, string2, result); /* display result */

    printf("\nDECADD Sample Program over.\n\n");

    return 0;
}
