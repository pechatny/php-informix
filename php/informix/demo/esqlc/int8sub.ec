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
   *int8sub.ec *

	The following program obtains the difference of two INT8
	type values.
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

EXEC SQL include "int8.h";

char string1[] = "6";	
char string2[] = "9,223,372,036,854,775";
char string3[] = "999,999,999,999,999.5";
char result[41];

main()
{
    mint x;
    ifx_int8_t num1, num2, num3, sum;

    printf("IFX_INT8SUB Sample ESQL Program running.\n\n");

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

	/* subtract num2 from num1 */

   if (x = ifx_int8sub(&num1, &num2, &sum))    
        {
        printf("Error %d in subtracting INT8s\n", x);
        exit(1);
        }
    if (x = ifx_int8toasc(&sum, result, sizeof(result)))
        {
        printf("Error %d in converting INT8 result to string\n", x);
        exit(1);
        }
	result[40] = '\0';
	printf("\t%s - %s = %s\n", string1, string2, result); /* display result */
    
    if (x = ifx_int8cvasc(string3, strlen(string3), &num3))  
		{
		printf("Error %d in converting string3 to INT8\n", x);
		exit(1);
		}

	/* notice that digits right of the decimal are truncated. */

    if (x = ifx_int8sub(&num2, &num3, &sum))
        { 
        printf("Error %d in subtracting INT8s\n", x); 
        exit (1);
        }
    if (x = ifx_int8toasc(&sum, result, sizeof(result)))
        {
        printf("Error %d in converting INT8 result to string\n", x);
        exit(1);
        } 
    result[40] = '\0';
    printf("\t%s - %s = %s\n", string2, string3, result); /* display result */

    printf("\nIFX_INT8SUB Sample Program over.\n\n");
    exit(0);
}
