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
   * ifx_int8toasc.ec *

	The following program converts three string
	constants to INT8 types and then uses ifx_int8toasc()
	to convert the INT8 values to C char type values.  
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define END sizeof(result)

EXEC SQL include "int8.h";

char string1[] = "-12,555,444,333,786,456";
char string2[] = "480";
char string3[] = "5.2";
char result[40];

main()
{
	mint x;
	ifx_int8_t num1, num2, num3;

	printf("IFX_INT8TOASC Sample ESQL Program running.\n\n");

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
	printf("\nConverting INT8 back to ASCII\n");
	printf(" Executing: ifx_int8toasc(&num1, result, END - 1)");
	if (x = ifx_int8toasc(&num1, result, END - 1))
    	printf("\tError %d in converting INT8 to string\n", x);
	else
		{
		result[END - 1] = '\0';				/* null terminate */
		printf("\n The value of the first INT8 is = %s\n", result);
		}
	printf("\nConverting second INT8 back to ASCII\n");
	printf(" Executing: ifx_int8toasc(&num2, result, END - 1)");
	if (x= ifx_int8toasc(&num2, result, END - 1))
		printf("\tError %d in converting INT8 to string\n", x);
	else
		{
		result[END - 1] = '\0';				/* null terminate */
		printf("\n The value of the 2nd INT8 is = %s\n", result);
		}

	printf("\nConverting third INT8 back to ASCII\n");
	printf(" Executing: ifx_int8toasc(&num3, result, END - 1)");

	/* note that the decimal is truncated */
	
	if (x= ifx_int8toasc(&num3, result, END - 1))

    	printf("\tError %d in converting INT8 to string\n", x);
	else
		{
		result[END - 1] = '\0';					/* null terminate */
		printf("\n The value of the 3rd INT8 is = %s\n", result);
		}
	printf("\nIFX_INT8TOASC Sample Program over.\n\n");
	exit(0);
}

