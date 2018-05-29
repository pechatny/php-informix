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
   * deccmp.ec *

   The following program compares DECIMAL numbers and displays the results.
*/

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

EXEC SQL include decimal;

char string1[] = "-12345.6789";	/* leading spaces will be ignored */
char string2[] = "12345.6789";
char string3[] = "-12345.6789";
char string4[] = "-12345.6780";

main()
{
    mint x;
    dec_t num1, num2, num3, num4;

    printf("DECCMP Sample ESQL Program running.\n\n");

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
    if (x = deccvasc(string3, strlen(string3), &num3))
	{
	printf("Error %d in converting string3 to DECIMAL\n", x);
	exit(1);
	}
    if (x = deccvasc(string4, strlen(string4), &num4))
	{
	printf("Error %d in converting string4 to DECIMAL\n", x);
	exit(1);
	}

    printf("Number 1 = %s\tNumber 2 = %s\n", string1, string2);
    printf("Number 3 = %s\tNumber 4 = %s\n", string3, string4);
    printf("\nExecuting: deccmp(&num1, &num2)\n");
    printf("  Result = %d\n", deccmp(&num1, &num2));
    printf("Executing: deccmp(&num2, &num3)\n");
    printf("  Result = %d\n", deccmp(&num2, &num3));
    printf("Executing: deccmp(&num1, &num3)\n");
    printf("  Result = %d\n", deccmp(&num1, &num3));
    printf("Executing: deccmp(&num3, &num4)\n");
    printf("  Result = %d\n", deccmp(&num3, &num4));

    printf("\nDECCMP Sample Program over.\n\n");
    exit(0);
}
