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
   * rstoi.ec *

   The following program tries to convert three strings to integers.
   It displays the result of each conversion.
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

EXEC SQL include sqltypes;

main()
{
    mint err;
    mint i;
    short s;

    printf("RSTOI Sample ESQL Program running.\n\n");

    i = 0;
    printf("Converting String 'abc':\n");
    if((err = rstoi("abc", &i)) == 0)
	printf("\tResult = %d\n\n", i);
    else
	printf("\t(Expected) Error %d in conversion of string #1\n\n", err);

    i = 0;
    printf("Converting String '32766':\n");
    if((err = rstoi("32766", &i)) == 0)
	printf("\tResult = %d\n\n", i);
    else
	printf("\tError %d in conversion of string #2\n\n", err);

    i = 0;
    printf("Converting String '':\n");
    if((err = rstoi("", &i)) == 0)
	{
	s = i;					/* assign to a SHORT variable */
	if (risnull(CSHORTTYPE, (char *) &s))	/* and then test for NULL */
	    printf("\tResult = NULL\n\n");
	else
	    printf("\tResult = %d\n\n", i);
	}
    else
	printf("\tError %d in conversion of string #3\n\n", err);

    printf("\nRSTOI Sample Program over.\n\n");
    exit(0);
}

