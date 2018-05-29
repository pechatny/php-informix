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
   * bycopy.ec *

   The following program shows the results of bycopy() for three copy
   operations.
*/

#include <stdio.h>
#include <string.h>

char dest[20];

main()
{
    mint number1 = 12345;
    mint number2 = 0;
    static char string1[] = "abcdef";
    static char string2[] = "abcdefghijklmn";

    printf("BYCOPY Sample ESQL Program running.\n\n");

    printf("String 1=%s\tString 2=%s\n", string1, string2);
    printf("  Copying String 1 to destination string:\n");
    bycopy(string1, dest, strlen(string1));
    printf("  Result = %s\n\n", dest);

    printf("  Copying String 2 to destination string:\n");
    bycopy(string2, dest, strlen(string2));
    printf("  Result = %s\n\n", dest);

    printf("Number 1=%d\tNumber 2=%d\n", number1, number2);
    printf("  Copying Number 1 to Number 2:\n");
    bycopy( (char *) &number1, (char *) &number2, sizeof(int));
    printf("  Result = number1(hex) %08x, number2(hex) %08x\n",
	    number1, number2);

    printf("\nBYCOPY Sample Program over.\n\n");

    return 0;
}
