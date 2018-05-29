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
   * rgetlmsg.ec *

   The following program demonstrates the usage of rgetlmsg() function.
   It displays an error message after trying to create a table that 
   already exists.
*/

/* This include is optional because the sqlca.h file is automatically
 * included in an ESQL/C program.
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

EXEC SQL include sqlca;

main()
{
    mint msg_len;
    char errmsg[400];

    printf("RGETLMSG Sample ESQL Program running.\n\n");
    EXEC SQL connect to 'stores_demo';	

    EXEC SQL create table customer (name char(20));
    if(SQLCODE != 0)
	{
	rgetlmsg(SQLCODE, errmsg, sizeof(errmsg), &msg_len);
	printf("\nError %d: ", SQLCODE);
	printf(errmsg, sqlca.sqlerrm);
	}
    EXEC SQL disconnect current;
    printf("\nRGETLMSG Sample Program over.\n\n");
    exit(0);
}
