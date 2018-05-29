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
   * bycmpr.ec *

   The following program performs four different byte comparisons with
   bycmpr() and displays the results.
*/

#include <stdio.h>

main()
{
    mint x;

    static char string1[] = "abcdef";
    static char string2[] = "abcdeg";

    static mint number1 = 12345;
    static mint number2 = 12367;

    static char string3[] = {0x00, 0x07, 0x45, 0x32, 0x00};
    static char string4[] = {0x00, 0x07, 0x45, 0x31, 0x00};

    printf("BYCMPR Sample ESQL Program running.\n\n");

						/* strings */
    printf("Comparing strings: String 1=%s\tString 2=%s\n", string1, string2);
    printf("  Executing: bycmpr(string1, string2, sizeof(string1))\n");
    x = bycmpr(string1, string2, sizeof(string1));
    printf("  Result = %d\n", x);

						/* ints */
    printf("Comparing numbers: Number 1=%d\tNumber 2=%d\n", number1, number2);
    printf("  Executing: bycmpr( (char *) &number1, (char *) &number2, ");
    printf("sizeof(number1))\n");
    x = bycmpr( (char *) &number1, (char *) &number2, sizeof(number1));
    printf("  Result = %d\n", x);

						/* non printable */
    printf("Comparing strings with non-printable characters:\n");
    printf("Octal string3[0]=%o\tOctal string4[0]=%o\n", string3[0],string4[0]);
    printf("Octal string3[1]=%o\tOctal string4[1]=%o\n", string3[1],string4[1]);
    printf("Octal string3[2]=%o\tOctal string4[2]=%o\n", string3[2],string4[2]);
    printf("Octal string3[3]=%o\tOctal string4[3]=%o\n", string3[3],string4[3]);
    printf("Octal string3[4]=%o\tOctal string4[4]=%o\n", string3[4],string4[4]);
    printf("  Executing: bycmpr(string3, string4, sizeof(string3))\n");
    x = bycmpr(string3, string4, sizeof(string3));
    printf("  Result = %d\n", x);

                                                /* bytes */
    printf("Comparing bytes: Byte string 1=%c%c\tByte string 2=%c%c\n",
	string1[2], string1[3], string2[2], string2[3]);
    printf("  Executing: bycmpr(&string1[2], &string2[2], 2)\n");
    x = bycmpr(&string1[2], &string2[2], 2);	
    printf("  Result = %d\n", x);

    printf("\nBYCMPR Sample Program over.\n\n");

    return 0;
}
