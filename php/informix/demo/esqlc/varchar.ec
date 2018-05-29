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
   * varchar.ec *

   The following program illustrates the use of VARCHAR macros to
   obtain size information.
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

EXEC SQL include varchar;

char errmsg[512];

main()
{
    mint vc_code;
    mint max, min;
    mint hv_length;

    EXEC SQL BEGIN DECLARE SECTION;
	mint vc_size;
    EXEC SQL END DECLARE SECTION;

    printf("VARCHAR Sample ESQL Program running.\n\n");

    EXEC SQL connect to 'stores_demo';
    chk_sqlcode("database");

    printf("VARCHAR field 'cat_advert':\n");

    EXEC SQL select collength into :vc_size from syscolumns
	where colname = "cat_advert";
    chk_sqlcode("select");
    printf("\tEncoded size of VARCHAR (from syscolumns.collength) = %d\n", 
       vc_size);

    max = VCMAX(vc_size);
    printf("\tMaximum number of characters = %d\n", max);

    min = VCMIN(vc_size);
    printf("\tMinimum number of characters = %d\n", min);

    hv_length = VCLENGTH(vc_size);
    printf("\tLength to declare host variable = char(%d)\n", hv_length);

    vc_code = VCSIZ(max, min);
    printf("\tEncoded size of VARCHAR (from VCSIZ macro) = %d\n", vc_code);

    EXEC SQL disconnect current;
    printf("\nVARCHAR Sample Program over.\n\n");
    exit(0);
}

/*
 * chk_sqlcode() checks sqlca.sqlcode and if an error has occurred, it uses
 * rgetmsg() to display the message for the error number in sqlca.sqlcode.
 */

chk_sqlcode(char *name)
{
    if(sqlca.sqlcode < 0)
	{
	rgetmsg((short)sqlca.sqlcode, errmsg, sizeof(errmsg));
	printf("\n\tError %d during %s: %s\n",sqlca.sqlcode, name, errmsg);
	exit(1);
	}
    return((sqlca.sqlcode == SQLNOTFOUND) ? 0 : 1);
}
