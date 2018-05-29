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
   * rstod.ec *

   The following program tries to convert three strings to doubles.
   It displays the result of each attempt.
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

main()
{
    mint errnum;
    char *string1 = "1234567887654321";
    char *string2 = "12345678.87654321";
    char *string3 = "zzzzzzzzzzzzzzzz";
    double d;

    printf("RSTOD Sample ESQL Program running.\n\n");

    printf("Converting String 1: %s\n", string1);
    if ((errnum = rstod(string1, &d)) == 0)
	printf("\tResult = %f\n\n", d);
    else
	printf("\tError %d in conversion of string #1\n\n", errnum);

    printf("Converting String 2: %s\n", string2);
    if ((errnum = rstod(string2, &d)) == 0)
	printf("\tResult = %.8f\n\n", d);
    else
	printf("\tError %d in conversion of string #2\n\n", errnum);

    printf("Converting String 3: %s\n", string3);
    if ((errnum = rstod(string3, &d)) == 0)
	printf("\tResult = %.8f\n\n", d);
    else
	printf("\t(Expected) Error %d in conversion of string #3\n\n", errnum);

    printf("\nRSTOD Sample Program over.\n\n");
    exit(0);
}

