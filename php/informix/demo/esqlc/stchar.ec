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
   * stchar.ec *

   The following program shows the blank padded result produced by
   stchar() function.
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

main()
{
    static char src[] = "start";
    static char dst[25] = "123abcdefghijkl;.";

    printf("STCHAR Sample ESQL Program running.\n\n");

    printf("Source string: [%s]\n", src);
    printf("Destination string before stchar: [%s]\n", dst);

    stchar(src, dst, sizeof(dst) - 1);

    printf("Destination string  after stchar: [%s]\n", dst);

    printf("\nSTCHAR Sample Program over.\n\n");
    exit(0);
}
