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
   * ldchar.ec *
 
   The following program loads characters to specific locations in an array
   that is initialized to z's.  It displays the result of each ldchar()
   operation.
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

main()
{
    static char src1[] = "abcd   ";
    static char src2[] = "abcd  g  ";
    static char dest[40];

    printf("LDCHAR Sample ESQL Program running.\n\n");

    ldchar(src1, stleng(src1), dest);
    printf("\tSource: [%s]\n\tDestination: [%s]\n\n", src1, dest);

    ldchar(src2, stleng(src2), dest);
    printf("\tSource: [%s]\n\tDestination: [%s]\n", src2, dest);

    printf("\nLDCHAR Sample Program over.\n\n");
    exit(0);
}
