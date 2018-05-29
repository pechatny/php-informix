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
   * rgetmsg.ec *

   The following program demonstrates the usage of the rgetmsg() function.
   It displays an error message after trying to create a table that
   already exists.
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* This include is optional because the sqlca.h file is automatically
 * included in an ESQL/C program.
 */
EXEC SQL include sqlca;

main()
{
    char errmsg[400];

    printf("RGETMSG Sample ESQL Program running.\n\n");
    EXEC SQL connect to 'stores_demo';	

    EXEC SQL create table customer (name char(20));
    if(SQLCODE != 0)
	{
	rgetmsg((short)SQLCODE, errmsg, sizeof(errmsg));
	printf("\nError %d: ",SQLCODE);
	printf(errmsg, sqlca.sqlerrm);
	}
    EXEC SQL disconnect current;
    printf("\nRGETMSG Sample Program over.\n\n");
    exit(0);
}
