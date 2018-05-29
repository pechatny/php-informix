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
   * sqgetdbs.ec *

   This program lists the available databases in the database server
   of the current connection.
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define BUFFSZ          256
#define NUM_DBNAMES      10

main()
{
    char db_buffer[BUFFSZ];
    char *dbnames[NUM_DBNAMES];
    mint num_returned;
    mint ret, i;

    printf("SQGETDBS Sample ESQL Program running.\n\n");

    ret = sqgetdbs(&num_returned, dbnames, NUM_DBNAMES,
        db_buffer, BUFFSZ);

    printf("Return value of sqgetdbs(): %d\n", ret);
    printf("Number of database names returned: %d\n", num_returned);

    printf("\nDatabases open on current server:\n");
    for (i = 0; i < num_returned; i++)
        printf("\t%s\n", dbnames[i]);

    printf("\nSQGETDBS Sample Program over.\n\n");
    exit(0);
}
