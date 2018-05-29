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
   * stcopy.ec *

   This program displays the result of copying a string using stcopy().
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

main()
{
    static char string[] = "abcdefghijklmnopqrstuvwxyz";

    printf("STCOPY Sample ESQL Program running.\n\n");

    printf("Initial string:\n  [%s]\n", string);	/* display dest */
    stcopy("John Doe", &string[15]);			/* copy */
    printf("After copy of 'John Doe' to position 15:\n  [%s]\n", 
        string);

    printf("\nSTCOPY Sample Program over.\n\n");
    exit(0);
}
