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
   * byfill.ec *

   The following program shows the results of three byfill() operations on an
   area that is initialized to x's.
*/

#include <stdio.h>

main()
{
    static char area[20] = "xxxxxxxxxxxxxxxxxxx";

    printf("BYFILL Sample ESQL Program running.\n\n");

    printf("String = %s\n", area);

    printf("\nFilling string with five 's' characters:\n");
    byfill(area, 5, 's');
    printf("Result = %s\n", area);

    printf("\nFilling string with two 's' characters starting at ");
    printf("position 16:\n");
    byfill(&area[16], 2, 's');
    printf("Result = %s\n", area);

    printf("\nFilling entire string with 'b' characters:\n");
    byfill(area, sizeof(area)-1, 'b');
    printf("Result = %s\n", area);

    printf("\nBYFILL Sample Program over.\n\n");

    return 0;
}

