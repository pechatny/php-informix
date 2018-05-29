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
 * int8add.ec
 *  The following program obtains the sum of two INT8 type values.
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

EXEC SQL include "int8.h";

char string1[] = "6";
char string2[] = "99,999,999,999,999,999";
char string3[] = "9,199,999,999,999,999,999";
char result[41];

main()
{
    mint x;
    ifx_int8_t num1, num2, num3, sum;

    printf("INT8 Sample ESQL Program running.\n\n");

    if (x = ifx_int8cvasc(string1, strlen(string1), &num1))
    {
        printf("Error %d in converting string1 to INT8\n\n", x);
        exit(1);
    }
    else {
        printf("1. ifx_int8cvasc() successfully converted string \"%s\" into int8\n\n", string1);
    }

    if (x = ifx_int8cvasc(string2, strlen(string2), &num2))
    {
        printf("Error %d in converting string2 to INT8\n\n", x);
        exit(1);
    }
    else {
 printf("2. ifx_int8cvasc() successfully converted string \"%s\" into int8 type number\n\n", string2);
    }

    /* adding the first two INT8s */
    if (x = ifx_int8add(&num1, &num2, &sum))
    {
        printf("Error %d in adding INT8s\n", x);
        exit(1);
    }
    else {
        printf("3. ifx_int8add() successfull in adding \"%s\" and \"%s\" \n\n" , string1, string2);
    }
    if (x = ifx_int8toasc(&sum, result, sizeof(result)))
    {
        printf("Error %d in converting INT8 result to string\n", x);
        exit(1);
    }
    else {
        printf("4. ifx_int8toasc() successfully converted int8 structure to string : %s\n\n",result);
    }

    result[40] = '\0';
    printf("5. Long integer operations performed, addition of two long\n"); 
    printf("    integers in string format converted to int8 and result back\n");   
    printf("    to string :\n\t%s + %s = %s\n\n", string1, string2, result);

    /* attempt to convert to INT8 value that is too large*/
    printf("6. Demo error condition, add \"%s\" and \"%s\" to show error result\n", string2, string3); /* display result */
    if (x = ifx_int8cvasc(string3, strlen(string3), &num3))
    {
        printf("\tError %d in converting string3 to INT8\n", x);
    }

    if (x = ifx_int8add(&num2, &num3, &sum))
    {
        printf("\t(Expected) ifx_int8add() returned Error %d in adding illegal INT8 numbers \n\n", x);
    }

    printf("\nINT8 Sample Program over.\n\n");
    exit(0);
}

