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
   * ifx_in8cvasc.ec *

	The following program converts three strings to INT8 
	types and displays the values stored in each field of 
	the INT8 structures.
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

EXEC SQL include "int8.h";

char string1[] = "-12,555,444,333,786,456";
char string2[] = "480";
char string3[] = "5.2";
main()
{
	mint x;
	ifx_int8_t num1, num2, num3;
	void nullterm(char *, mint);

	printf("IFX_INT8CVASC Sample ESQL Program running.\n\n");

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
	if (x = ifx_int8cvasc(string3, strlen(string3), &num3))
		{
		printf("Error %d in converting string3 to INT8\n", x);
		exit(1);
		}

	/*  Display the exponent, sign value and number of digits in num1. */

	ifx_int8toasc(&num1, string1, sizeof(string1));
	nullterm(string1, sizeof(string1));
	printf("The value of the first INT8 is = %s\n", string1);
    
	/*  Display the exponent, sign value and number of digits in num2. */

	ifx_int8toasc(&num2, string2, sizeof(string2));
	nullterm(string2, sizeof(string2));
	printf("The value of the 2nd INT8 is = %s\n", string2);

	/*  Display the exponent, sign value and number of digits in num3. */ 
	/*  Note that the decimal is truncated */
	
	ifx_int8toasc(&num3, string3, sizeof(string3));
	nullterm(string3, sizeof(string3));
    printf("The value of the 3rd INT8 is = %s\n", string3);

	printf("\nIFX_INT8CVASC Sample Program over.\n\n");
	exit(0);
}
void nullterm(char *str, mint size)
{
	char *end;

	end = str + size;
	while(*str && *str > ' ' && str <= end)
		++str;
	*str = '\0';
}

