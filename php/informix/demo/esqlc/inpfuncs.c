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
/* The inpfuncs.c file contains functions useful in character-based
   input for a C program.
 */
#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#ifndef LCASE
#define LCASE(c) (isupper(c) ? tolower(c) : c)
#endif 

/* 
    Accepts user input, up to 'len' number of characters and returns 
    it in 'ans'
 */
#define BUFSIZE 512
getans(char *ans, mint len)
{
    char buf[BUFSIZE + 1];
    mint c, n = 0;

    while((c = getchar()) != '\n' && n < BUFSIZE)
        buf[n++] = c;
    buf[n] = '\0';
    if(n > 1 && n >= len)
        {
	printf("** Input exceeds maximum length\n");
	 return 0;
	}
    if(len <= 1)
        *ans = buf[0];
    else
	strncpy(ans, buf, len);
    return 1;
}

/*
 *  Ask user if there is more to do
 */
more_to_do()
{
    char ans;

    do
	{
	printf("\n**** More? (y/n) ... ");
	getans(&ans, 1);
	} while((ans = LCASE(ans)) != 'y' && ans != 'n');
    return (ans == 'n') ? 0 : 1;
}

