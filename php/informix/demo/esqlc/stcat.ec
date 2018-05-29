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
   * stcat.ec *

   This program uses stcat() to append user input to a SELECT statement. 
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/*
 * Declare a variable large enough to hold
 * the select statement + the value for customer_num entered from the terminal.
 */
char selstmt[80] = "select fname, lname from customer where customer_num = ";

main()
{
    char custno[11];

    printf("STCAT Sample ESQL Program running.\n\n");

    printf("Initial SELECT string:\n  '%s'\n", selstmt);

    printf("\nEnter Customer #: ");
    scanf("%[^\n]s",custno);

    /*
     * Add custno to "select statement"
     */
    printf("\nCalling stcat(custno, selstmt)\n"); 
    stcat(custno, selstmt);
    printf("SELECT string is:\n  '%s'\n", selstmt);

    printf("\nSTCAT Sample Program over.\n\n");
    exit(0);
}
