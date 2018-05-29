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
   * dectodbl.ec *

   The following program converts two DECIMAL numbers to doubles and displays
   the results.
*/

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

EXEC SQL include decimal;

char string1[] = "2949.3829398204382";
char string2[] = "3238299493";
char result[40];

main()
{
    mint x;
    double d = 0;
    dec_t num;

    printf("DECTODBL Sample ESQL Program running.\n\n");

    if (x = deccvasc(string1, strlen(string1), &num))
	{
	printf("Error %d in converting string1 to DECIMAL\n", x);
	exit(1);
	}
    if (x = dectodbl(&num, &d))
	{
	printf("Error %d in converting DECIMAL1 to double\n", x);
	exit(1);
	}
    printf("String 1 = %s\n", string1);
    printf("Double value = %.15f\n\n", d);

    if (x = deccvasc(string2, strlen(string2), &num))
	{
	printf("Error %d in converting string2 to DECIMAL\n", x);
	exit(1);
	}
    if (x = dectodbl(&num, &d))
	{
	printf("Error %d in converting DECIMAL2 to double\n", x);
	exit(1);
	}
    printf("String 2 = %s\n", string2);
    printf("Double value = %f\n", d);

    printf("\nDECTODBL Sample Program over.\n\n");
    exit(0);
}
