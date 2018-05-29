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
   * rstol.ec *

   The following program tries to convert three strings to longs.  It
   displays the result of each attempt.
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

EXEC SQL include sqltypes;

main()
{
    mint err;
    mlong l;

    printf("RSTOL Sample ESQL Program running.\n\n");

    l = 0;
    printf("Converting String 'abc':\n");
    if((err = rstol("abc", &l)) == 0)
	printf("\tResult = %ld\n\n", l);
    else
	printf("\t(Expected) Error %d in conversion of string #1\n\n", err);

    l = 0;
    printf("Converting String '2147483646':\n");
    if((err = rstol("2147483646", &l)) == 0)
	printf("\tResult = %ld\n\n", l);
    else
	printf("\tError %d in conversion of string #2\n\n", err);

    l = 0;
    printf("Converting String '':\n");
    if((err = rstol("", &l)) == 0)
	{
	if(risnull(CLONGTYPE, (char *) &l))
	    printf("\tResult = NULL\n\n", l);
	else
	    printf("\tResult = %ld\n\n", l);
	}
    else
	printf("\tError %d in conversion of string #3\n\n", err);

    printf("\nRSTOL Sample Program over.\n\n");
    exit(0);
}
