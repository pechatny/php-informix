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
   * byleng.ec *

   The following program uses byleng() to count the significant characters in
   an area.
*/

#include <stdio.h>

main()
{
    mint x;
    static char area[20] = "xxxxxxxxxx         ";

    printf("BYLENG Sample ESQL Program running.\n\n");


				/* initial length */
    printf("Initial string:\n");
    x = byleng(area, 15);
    printf("  Length = %d, String = '%s'\n", x, area);

				/* after copy */
    printf("\nAfter copying two 's' characters starting ");
    printf("at position 16:\n");
    bycopy("ss", &area[16], 2);
    x = byleng(area, 19);
    printf("  Length = %d, String = '%s'\n", x, area);

    printf("\nBYLENG Sample Program over.\n\n");

    return 0;
}

