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
/* prdesc() prints cat_desc for a row in the catalog table */

prdesc()
{
    int4 size;
    char shdesc[81], *p;

    size = cat_descr.loc_size;			/* get size of data */
    printf("Description for %ld:\n", cat_num);
    p = cat_descr.loc_buffer;			/* set p to buffer addr */

    /* print buffer 80 characters at a time */
    while(size >= 80)
	{
	ldchar(p, 80, shdesc);			/* mv from buffer to shdesc */
	printf("\n%80s", shdesc);		/* display it  */
	size -= 80;				/* decrement length */
	p += 80; 				/* bump p by 80 */
	}
    strncpy(shdesc, p, size);
    shdesc[size] = '\0';
    printf("%-s\n", shdesc);			/* display last segment */
}

