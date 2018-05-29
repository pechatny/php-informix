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
   * deccvdbl.ec *

   The following program converts two double type numbers to DECIMAL numbers
   and displays the results.
*/

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

EXEC SQL include decimal;

char result[41];

main()
{
    mint x;
    dec_t num;
    double d = 2147483647;

    printf("DECCVDBL Sample ESQL Program running.\n\n");

    printf("Number 1 (double) = 1234.5678901234\n");
    if (x = deccvdbl((double)1234.5678901234, &num))
	{
	printf("Error %d in converting double1 to DECIMAL\n", x);
	exit(1);
	}
    if (x = dectoasc(&num, result, sizeof(result), -1))
	{
	printf("Error %d in converting DECIMAL1 to string\n", x);
	exit(1);
	}
    result[40] = '\0';
    printf("  String Value = %s\n", result);

    printf("Number 2 (double) = %.1f\n", d);
    if (x = deccvdbl(d, &num))
	{
	printf("Error %d in converting double2 to DECIMAL\n", x);
	exit(1);
	}
    if (x = dectoasc(&num, result, sizeof(result), -1))
	{
	printf("Error %d in converting DECIMAL2 to string\n", x);
	exit(1);
	}
    result[40] = '\0';
    printf("  String Value = %s\n", result);

    printf("\nDECCVDBL Sample Program over.\n\n");
    exit(0);
}
