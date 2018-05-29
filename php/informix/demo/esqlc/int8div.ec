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
   * ifx_int8div.ec *

   The following program divides two INT8 numbers and displays the result.
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

EXEC SQL include "int8.h";

char string1[] = "480,999,777,666,345,567";
char string2[] = "80,765,456,765,456,654";
char result[41];

main()
{
    mint x;
    ifx_int8_t num1, num2, dvd;

    printf("IFX_INT8DIV Sample ESQL Program running.\n\n");

    if (x = ifx_int8cvasc(string1, strlen(string1), &num1))
		{
		printf("Error %d in converting string1 to INT8\n", x);
		exit(1);
		}
    if (x = ifx_int8cvasc(string2, strlen(string2), &num2))
		{
		printf("Error %d in converting string2 to INT8\n", x);
		exit(1);
		}
    if (x = ifx_int8div(&num1, &num2, &dvd))
		{
		printf("Error %d in dividing num1 by num2\n", x);
		exit(1);
		}
    if (x = ifx_int8toasc(&dvd, result, sizeof(result)))
		{
		printf("Error %d in converting dividend to string\n", x);
		exit(1);
		}
    result[40] = '\0';
    printf("\t%s / %s = %s\n", string1, string2, result);

    printf("\nIFX_INT8DIV Sample Program over.\n\n");
    exit(0);
}
