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
   * deccopy.ec *

   The following program copies one DECIMAL number to another.
*/

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

EXEC SQL include decimal;

char string1[] = "12345.6789";
char result[41];

main()
{
    mint x;
    dec_t num1, num2;

    printf("DECCOPY Sample ESQL Program running.\n\n");

    printf("String = %s\n", string1);
    if (x = deccvasc(string1, strlen(string1), &num1))
	{
	printf("Error %d in converting string1 to DECIMAL\n", x);
	exit(1);
	}
    printf("Executing: deccopy(&num1, &num2)\n");
    deccopy(&num1, &num2);
    if (x = dectoasc(&num2, result, sizeof(result), -1))
	{
	printf("Error %d in converting num2 to string\n", x);
	exit(1);
	}
    result[40] = '\0';
    printf("Destination = %s\n", result);

    printf("\nDECCOPY Sample Program over.\n\n");
    exit(0);
}
