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
   * dectoint.ec *

   The following program converts two DECIMAL numbers to integers and
   displays the result of each conversion.
*/

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

EXEC SQL include decimal;

char string1 [] = "32767";
char string2 [] = "32768";

main()
{
    mint x;
    mint n = 0;
    dec_t num;

    printf("DECTOINT Sample ESQL Program running.\n\n");

    printf("String 1 = %s\n", string1);
    if (x = deccvasc(string1,strlen(string1), &num))
	{
	printf("  Error %d in converting string1 to decimal\n", x);
	exit(1);
	}
    if (x = dectoint(&num, &n))
	printf("  Error %d in converting decimal to int\n", x);
    else
        printf("  Result = %d\n", n);

    printf("\nString 2 = %s\n", string2);
    if (x = deccvasc(string2, strlen(string2), &num))
	{
	printf("  Error %d in converting string2 to decimal\n", x);
	exit(1);
	}
    if (x = dectoint(&num, &n))
	printf(" (Expected)  Error %d in converting decimal to int\n", x);
    else
        printf("  Result = %d\n", n);

    printf("\nDECTOINT Sample Program over.\n\n");
    exit(0);
}
