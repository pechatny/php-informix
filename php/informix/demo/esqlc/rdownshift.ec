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
    * rdownshift.ec *

    The following program uses rdownshift() on a string containing alpha,
    numeric and punctuation characters.
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

main() 
{
    static char string[] = "123ABCDEFGHIJK'.;";

    printf("RDOWNSHIFT Sample ESQL Program running.\n\n");

    printf("\tInput string...: [%s]\n", string);
    rdownshift(string);
    printf("\tAfter downshift: [%s]\n", string);

    printf("\nRDOWNSHIFT Sample Program over.\n\n");
    exit(0);
}
