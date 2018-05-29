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
   * stcmpr.ec *

   The following program displays the results of three string
   comparisons using stcmpr().
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

main()
{
    printf("STCMPR Sample ESQL Program running.\n\n");

    printf("Executing: stcmpr(\"aaa\", \"aaa\")\n");
    printf("  Result = %d", stcmpr("aaa", "aaa"));  /* equal */
    printf("\nExecuting: stcmpr(\"aaa\", \"aaaa\")\n");
    printf("  Result = %d", stcmpr("aaa", "aaaa")); /* less */
    printf("\nExecuting: stcmpr(\"bbb\", \"aaaa\")\n");
    printf("  Result = %d\n", stcmpr("bbb", "aaaa")); /* greater */

    printf("\nSTCMPR Sample Program over.\n\n");
    exit(0);
}
