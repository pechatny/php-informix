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
   * stleng.ec *

   This  program uses stleng to find strings that are greater than 35
   characters in length.
*/

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

char *strings[] =
    {
    "Your First Season's Baseball Glove",
    "ProCycle Stem with Pearl Finish",
    "Athletic Watch w/4-Lap Memory, Olympic model",
    "High-Quality Kickboard",
    "Team Logo Silicone Swim Cap - fits all head sizes",
    0
    };

main(mint argc,char *argv[])
{
    mint length, i;

    printf("STLENG Sample ESQL Program running.\n\n");

    printf("Strings with lengths greater than 35:\n");
    i = 0;
    while(strings[i])
	{
        if((length = stleng(strings[i])) > 35)
	    {
            printf("  String[%d]: %s\n", i, strings[i]);
            printf("  Length: %d\n\n", length);
	    }
	++i;
	}
    printf("\nSTLENG Sample Program over.\n\n");
    exit(0);
}

