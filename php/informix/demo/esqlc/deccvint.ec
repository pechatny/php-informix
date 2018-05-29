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
   * deccvint.ec *

   The following program converts two integers to DECIMAL numbers and displays
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

    printf("DECCVINT Sample ESQL Program running.\n\n");

    printf("Integer 1 = 129449233\n");
    if (x = deccvint(129449233, &num))
	{
	printf("Error %d in converting int1 to DECIMAL\n", x);
	exit(1);
	}
    if (x = dectoasc(&num, result, sizeof(result), -1))
	{
	printf("Error %d in converting DECIMAL to string\n", x);
	exit(1);
	}
    result[40] = '\0';
    printf("  String for Decimal Value = %s\n", result);

    printf("Integer 2 = 33\n");
    if (x = deccvint(33, &num))
	{
	printf("Error %d in converting int2 to DECIMAL\n", x);
	exit(1);
	}
    if (x = dectoasc(&num, result, sizeof(result), -1))
	{
	printf("Error %d in converting DECIMAL to string\n", x);
	exit(1);
	}
    result[40] = '\0';
    printf("  String for Decimal Value = %s\n", result);

    printf("\nDECCVINT Sample Program over.\n\n");
    exit(0);
}

