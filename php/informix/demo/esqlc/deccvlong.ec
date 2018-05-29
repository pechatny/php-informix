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
   * deccvlong.ec *

   The following program converts two longs to DECIMAL numbers and displays
   the results.
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
    int4 n;

    printf("DECCVLONG Sample ESQL Program running.\n\n");

    printf("Long Integer 1 = 129449233\n");
    if (x = deccvlong(129449233L, &num))
	{
	printf("Error %d in converting long to DECIMAL\n", x);
	exit(1);
	}
    if (x = dectoasc(&num, result, sizeof(result), -1))
	{
	printf("Error %d in converting DECIMAL to string\n", x);
	exit(1);
	}
    result[40] = '\0';
    printf("  String for Decimal Value = %s\n", result);

    n = 2147483646;					/* set n */
    printf("Long Integer 2 = %d\n", n);
    if (x = deccvlong(n, &num))
	{
	printf("Error %d in converting long to DECIMAL\n", x);
	exit(1);
	}
    if (x = dectoasc(&num, result, sizeof(result), -1))
	{
	printf("Error %d in converting DECIMAL to string\n", x);
	exit(1);
	}
    result[40] = '\0';
    printf("  String for Decimal Value = %s\n", result);

    printf("\nDECCVLONG Sample Program over.\n\n");
    exit(0);
}

