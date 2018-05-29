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
   * deccvasc.ec *

   The following program converts two strings to DECIMAL numbers and displays
   the values stored in each field of the decimal structures.
*/

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

EXEC SQL include decimal;

char string1[] = "-12345.6789";
char string2[] = "480";

main()
{
    mint x;
    dec_t num1, num2;

    printf("DECCVASC Sample ESQL Program running.\n\n");

    if (x = deccvasc(string1, strlen(string1), &num1))
	{
	printf("Error %d in converting string1 to DECIMAL\n", x);
	exit(1);
	}
    if (x = deccvasc(string2, strlen(string2), &num2))
	{
	printf("Error %d in converting string2 to DECIMAL\n", x);
	exit(1);
	}
    /*
     *  Display the exponent, sign value and number of digits in num1.
     */
    printf("string1 = %s\n", string1);
    disp_dec("num1", &num1);

    /*
     *  Display the exponent, sign value and number of digits in num2.
     */
    printf("string2 = %s\n", string2);
    disp_dec("num2", &num2);

    printf("\nDECCVASC Sample Program over.\n\n");
    exit(0);
}

disp_dec(char *s,dec_t *num)
{
    mint n;

    printf("%s dec_t structure:\n", s);
    printf("\tdec_exp = %d, dec_pos = %d, dec_ndgts = %d, dec_dgts: ",
	num->dec_exp, num->dec_pos, num->dec_ndgts);
    n = 0;
    while(n < num->dec_ndgts)
	printf("%02d ", num->dec_dgts[n++]);
    printf("\n\n");
}
