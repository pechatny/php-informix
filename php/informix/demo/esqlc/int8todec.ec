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
   * ifx_int8todec.ec *

   The following program converts three strings to INT8 types and 
   converts the INT8 type values to decimal type values.  
   Then the values are displayed. 

*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

EXEC SQL include "int8.h";
#define END sizeof(result)

char string1[] = "-12,555,444,333,786,456";
char string2[] = "480";
char string3[] = "5.2";
char result [40];

main()
{
    mint x;
    dec_t d;
    ifx_int8_t num1, num2, num3;

    printf("IFX_INT8TODEC Sample ESQL Program running.\n\n");

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

    printf("\n***Converting INT8 to decimal\n");
    printf("\nString 1= %s\n", string1);
    printf(" \nExecuting: ifx_int8todec(&num1,&d)");
    if (x= ifx_int8todec(&num1, &d))
    	{
    	printf("\tError %d in converting INT8 to decimal\n", x);
    	exit(1);
    	}
    else
		{
		printf("\nConverting Decimal to ASCII for display\n");
        printf("Executing: dectoasc(&d, result, END, -1)\n");
    	if (x = dectoasc(&d, result, END, -1))
			printf("\tError %d in converting DECIMAL1 to string\n", x);
    	else
			{
			result[END - 1] = '\0';				/* null terminate */
			printf("Result = %s\n", result);
			}
        }
    printf("\n***Converting second INT8 to decimal\n");
    printf("\nString2 = %s\n", string2);
    printf(" \nExecuting: ifx_int8todec(&num2, &d)");
    if (x= ifx_int8todec(&num2, &d))
    	{
    	printf("\tError %d in converting INT8 to decimal\n", x);
    	exit(1);
    	}
    else
		{
      	printf("\nConverting Decimal to ASCII for display\n");
        printf("Executing: dectoasc(&d, result, END, -1)\n");
        if (x = dectoasc(&d, result, END, -1))
			printf("\tError %d in converting DECIMAL2 to string\n", x);
    	else
			{
			result[END - 1] = '\0';				/* null terminate */
			printf("Result = %s\n", result);
			}
		}
    printf("\n***Converting third INT8 to decimal\n");
    printf("\nString3 = %s\n", string3);
    printf(" \nExecuting: ifx_int8todec(&num3, &d)");
    if (x= ifx_int8todec(&num3, &d))
    	{
      	printf("\tError %d in converting INT8 to decimal\n", x);
      	exit(1);
    	}
    else
		{
        printf("\nConverting Decimal to ASCII for display\n");
        printf("Executing: dectoasc(&d, result, END, -1)\n");

		/* note that the decimal is truncated */

        if (x = dectoasc(&d, result, END, -1))
			printf("\tError %d in converting DECIMAL3 to string\n", x);
    	else
			{
			result[END - 1] = '\0';				/* null terminate */
			printf("Result = %s\n", result);
			}
		}      
    printf("\nIFX_INT8TODEC Sample Program over.\n\n");
    exit(0);
}

