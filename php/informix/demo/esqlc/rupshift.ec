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
   * rupshift.ec *

   The following program displays the result of rupshift() on a string
   of numbers, letters and punctuation.
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

main()
{
    static char string[] = "123abcdefghijkl;.";

    printf("RUPSHIFT Sample ESQL Program running.\n\n");

    printf("\tInput  string: %s\n", string);
    rupshift(string);
    printf("\tAfter upshift: %s\n", string);    /* Result */

    printf("\nRUPSHIFT Sample Program over.\n\n");
    exit(0);
}
