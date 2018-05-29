
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
#include <stdlib.h>
#include <string.h>

    EXEC SQL include sqltypes;
    EXEC SQL define BUFSZ 10;

    extern char statement[80];

main()
{
    int error, isize;
    char format[] = "<<<,<<<.&&";
    char decdsply[20], buf[50000], *end;

EXEC SQL BEGIN DECLARE SECTION;
        dec_t price;
        fixed binary 'clob' ifx_lo_t descr;
        smallint stockno;
        char srvr_name[256], mancd[4], unit[5];
        ifx_lo_stat_t *stats;
        ifx_int8_t size, offset, pos;
        int lofd, ic_num;
EXEC SQL END DECLARE SECTION;

void nullterm(char *);
void handle_lo_error(int);

isize = 0;

    EXEC SQL whenever sqlerror call whenexp_chk;
    EXEC SQL whenever sqlwarning call whenexp_chk;

printf("UPD_LO_DESCR Sample ESQL program running.\n\n");
strcpy(statement, "CONNECT stmt");
printf("Connecting to database  \"superstores_demo\"...\n\n");
    EXEC SQL connect to 'superstores_demo';
    EXEC SQL get diagnostics exception 1
        :srvr_name = server_name;
        nullterm(srvr_name);

/* Selects each row where the advert.picure column is not null and displays
* status information for the smart large object.
*/

    EXEC SQL declare ifxcursor cursor for
        select catalog_num, stock_num, manu_code, unit, advert_descr
        into :ic_num, :stockno, :mancd, :unit, :descr
        from catalog
        where advert_descr is not null;

    EXEC SQL open ifxcursor;

while(1)
{
    EXEC SQL fetch ifxcursor;
    if (strncmp(SQLSTATE, "00", 2) != 0)
        {
        if(strncmp(SQLSTATE, "02", 2) != 0)
        printf("SQLSTATE after fetch is %s\n", SQLSTATE);
        break;
        }

    EXEC SQL select unit_price into :price
        from stock
        where stock_num = :stockno
        and manu_code = :mancd
        and unit = :unit;

    if (strncmp(SQLSTATE, "00", 2) != 0)
        {
        printf("SQLSTATE after select on stock: %s\n", SQLSTATE);
        break;
        }

    if(risnull(CDECIMALTYPE, (char *) &price)) /* NULL? */
        continue; /* skip to next row */

rfmtdec(&price, format, decdsply); /* format unit_price */

/* Use the returned LO-pointer structure to open a smart
* large object and get an LO file descriptor.
*/
        lofd = ifx_lo_open(&descr, LO_RDWR, &error);

    if (error < 0)
        {
        strcpy(statement, "ifx_lo_open()");
        handle_lo_error(error);
        }

    ifx_int8cvint(0, &offset);

    if(ifx_lo_seek(lofd, &offset, LO_SEEK_SET, &pos) < 0)
        {
        printf("\nifx_lo_seek() < 0\n");
        break;
        }

    if(ifx_lo_stat(lofd, &stats) < 0)
        {
        printf("\nifx_lo_stat() < 0");
        break;
        }

    if((ifx_lo_stat_size(stats, &size)) < 0)
        {
        printf("\nCan't get size, isize = 0");
        isize = 0;
        }
        else
        if(ifx_int8toint(&size, &isize) != 0)
        {
        printf("\nFailed to convert size");
        isize = 0;
        }

    if(ifx_lo_read(lofd, buf, isize, &error) < 0)
        {
        printf("Read operation failed\n");
        break;
        }

    end = buf + isize;
    strcpy(end++, "(");
    strcat(end, decdsply);
    end += strlen(decdsply);
    strcat(end++, ")");

    if(ifx_lo_writewithseek(lofd, buf, (end - buf), &offset,
        LO_SEEK_SET, &error) < 0)
        {
        printf("Write error on LO: %d", error);
        continue;
        }

printf("\nNew description for catalog_num %d is: \n%s\n", ic_num, buf);
}

/* Close smart large object */
    ifx_lo_close(lofd);
    ifx_lo_stat_free(stats);
/* Free LO-specification structure */
    EXEC SQL close ifxcursor;
    EXEC SQL free ifxcursor;
}

void handle_lo_error(int error_num)
    {
        printf("%s generated error %d\n", statement, error_num);
        exit(1);
    }

void nullterm(char *str)
    {
        char *end;
        end = str + 256;
        while(*str != ' ' && *str != '\0' && str < end)
        {
        ++str;
        }
        if(str >= end)
        printf("Error: end of str reached\n");
        if(*str == ' ')
        *str = '\0';
        }

/* Include source code for whenexp_chk() exception-checking
* routine
*/

    EXEC SQL include exp_chk.ec;
