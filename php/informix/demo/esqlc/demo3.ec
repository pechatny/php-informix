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


#include <stdio.h>
EXEC SQL include sqlda;
EXEC SQL include sqltypes;

main()
{
struct sqlda *demo3_ptr;
struct sqlvar_struct *col_ptr;
static char data_buff[1024];
mint pos, cnt, size;

EXEC SQL BEGIN DECLARE SECTION;
    int i;
    int2  desc_count;
    char demoquery[80];
EXEC SQL END DECLARE SECTION;

    printf("DEMO3 Sample ESQL Program running.\n\n");
    EXEC SQL WHENEVER ERROR STOP;
    EXEC SQL connect to 'stores_demo';

    /* These next four lines have hard-wired both the query and
     * the value for the parameter. This information could have
     * been entered from the terminal and placed into the strings
     * demoquery and a query value string (queryvalue), respectively.
     */

    sprintf(demoquery, "%s %s",
	   "select fname, lname from customer",
           "where lname < 'C' ");

    EXEC SQL prepare demo3id from :demoquery;
    EXEC SQL declare demo3cursor cursor for demo3id;

    EXEC SQL describe demo3id into demo3_ptr;

    desc_count = demo3_ptr->sqld;
    printf("There are %d returned columns:\n", desc_count);

    /* Print out what DESCRIBE returns */
    for (i = 1; i <= desc_count; i++)
	prsqlda(i, &(demo3_ptr->sqlvar[i-1]));
    printf("\n\n");

    for(col_ptr=demo3_ptr->sqlvar, cnt=pos=0; cnt < desc_count;
        cnt++, col_ptr++)
	{
        /* Allow for the trailing null character in C
           character arrays */
        if (col_ptr->sqltype==SQLCHAR)
            col_ptr->sqllen += 1;

        /* Get next word boundary for column data and
           assign buffer position to sqldata */
        pos = rtypalign(pos, col_ptr->sqltype);
        col_ptr->sqldata = &data_buff[pos];

        /* Determine size used by column data and increment
           buffer position */
        size = rtypmsize(col_ptr->sqltype, col_ptr->sqllen);
        pos += size;
	}

    EXEC SQL open demo3cursor;

    for (;;)
	{
        EXEC SQL fetch demo3cursor using descriptor demo3_ptr;

        if (strncmp(SQLSTATE, "00", 2) != 0)
            break;

	/* Print out the returned values */
        for (i=0; i<desc_count; i++)
            printf("Column: %s\tValue: %s\n", demo3_ptr->sqlvar[i].sqlname, 
                demo3_ptr->sqlvar[i].sqldata);
        printf("\n");
	}

    if (strncmp(SQLSTATE, "02", 2) != 0)
        printf("SQLSTATE after fetch is %s\n", SQLSTATE);

    EXEC SQL close demo3cursor;

    EXEC SQL free demo3id;
    EXEC SQL free demo3cursor;

    /* No need to explicitly free data buffer in this case because
     * it wasn't allocated with malloc(). Instead, it is a static char
     * buffer.
     */

    /* Free memory assigned to sqlda pointer. */
    free(demo3_ptr);

    EXEC SQL disconnect current;
    printf("\nDEMO3 Sample Program over.\n\n");

    exit(0);
}

prsqlda(int index,register struct sqlvar_struct *sp)
{
    printf("    Column %d: type = %d, len = %d, name = %s\n",
			index, sp->sqltype, sp->sqllen, sp->sqlname);
}
