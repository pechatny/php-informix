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
   * dectolong.ec *

   The following program converts two DECIMAL numbers to longs and displays
   the return value and the result for each conversion.
*/

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

EXEC SQL include decimal;

char string1[] = "2147483647";
char string2[] = "2147483648";

main()
{
    mint x;
    int4 n = 0;
    dec_t num;

    printf("DECTOLONG Sample ESQL Program running.\n\n");

    printf("String 1 = %s\n", string1);
    if (x = deccvasc(string1, strlen(string1), &num))
	{
	printf("  Error %d in converting string1 to DECIMAL\n", x);
	exit(1);
	}
    if (x = dectolong(&num, &n))
	printf("  Error %d in converting DECIMAL1 to long\n", x);
    else
        printf("  Result = %d\n", n);

    printf("\nString 2 = %s\n", string2);
    if (x = deccvasc(string2, strlen(string2), &num))
	{
	printf(" Error %d in converting string2 to DECIMAL\n", x);
	exit(1);
	}
    if (x = dectolong(&num, &n))
	printf(" (Expected) Error %d in converting DECIMAL2 to long\n", x);
    else
        printf("  Result = %d\n", n);

    printf("\nDECTOLONG Sample Program over.\n\n");
    exit(0);
}
