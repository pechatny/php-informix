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
   * ifx_int8cvdec.ec *

   The following program converts two INT8s types to DECIMALS and displays
   the results.
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

EXEC SQL include decimal;
EXEC SQL include "int8.h";

char string1[] = "2949.3829398204382";
char string2[] = "3238299493";
char result[41];

main()
{
    mint x;
    ifx_int8_t n;
    dec_t num;

    printf("IFX_INT8CVDEC Sample ESQL Program running.\n\n");

    if (x = deccvasc(string1, strlen(string1), &num))
		{
		printf("Error %d in converting string1 to DECIMAL\n", x);
		exit(1);
		}
    if (x = ifx_int8cvdec(&num, &n))
		{
		printf("Error %d in converting DECIMAL1 to INT8\n", x);
		exit(1);
		}
     
/*  Convert the INT8 to ascii and display it. Note that the 
	digits to the right of the decimal are truncated in the 
	conversion. 
*/

	if (x = ifx_int8toasc(&n, result, sizeof(result)))
		{
		printf("Error %d in converting INT8 to string\n", x);
		exit(1);
		}
    result[40] = '\0';
    printf("String 1 Value = %s\n", string1);
    printf("  INT8 type value = %s\n", result);


    if (x = deccvasc(string2, strlen(string2), &num))
		{
		printf("Error %d in converting string2 to DECIMAL\n", x);
		exit(1);
		}
    if (x = ifx_int8cvdec(&num, &n))
		{
		printf("Error %d in converting DECIMAL2 to INT8\n", x);
		exit(1);
		}
    printf("String 2 = %s\n", string2);

/* Convert the INT8 to ascii to display value. */

     if (x = ifx_int8toasc(&n, result, sizeof(result)))
		{
		printf("Error %d in converting INT8 to string\n", x);
		exit(1);
		}
    result[40] = '\0';
    printf("  INT8 type value = %s\n", result);

    printf("\nIFX_INT8CVDEC Sample Program over.\n\n");
    exit(0);
}
