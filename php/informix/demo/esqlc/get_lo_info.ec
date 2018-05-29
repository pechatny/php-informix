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
#include <time.h>
#include <stdlib.h>
#include <string.h>

EXEC SQL define BUFSZ 10;
extern char statement[80];

main()
{
    int error, ic_num, oflags, cflags, extsz, imsize, isize, iebytes;
    time_t time;
    struct tm *date_time;
    char col_name[300], sbspc[129];

EXEC SQL BEGIN DECLARE SECTION;
        fixed binary 'blob' ifx_lo_t picture;
        char srvr_name[256];
        ifx_lo_create_spec_t *cspec;
        ifx_lo_stat_t *stats;
        ifx_int8_t size, c_num, estbytes, maxsize;
        int lofd;
        long atime, ctime, mtime, refcnt;
EXEC SQL END DECLARE SECTION;

void nullterm(char *);
void handle_lo_error(int);
imsize = isize = iebytes = 0;

    EXEC SQL whenever sqlerror call whenexp_chk;
    EXEC SQL whenever sqlwarning call whenexp_chk;

printf("GET_LO_INFO Sample ESQL program running.\n\n");
strcpy(statement, "CONNECT stmt");

    printf("Connecting to database \"superstores_demo\"...\n");
    EXEC SQL connect to 'superstores_demo';
    EXEC SQL get diagnostics exception 1
        :srvr_name = server_name;

nullterm(srvr_name);
    EXEC SQL declare ifxcursor cursor for
        select catalog_num, advert.picture
        into :c_num, :picture
        from catalog
        where advert.picture is not null;

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

/* Use the returned LO-pointer structure to open a smart
* large object and get an LO file descriptor.
*/

        lofd = ifx_lo_open(&picture, LO_RDONLY, &error);
        if (error < 0)
        {
        strcpy(statement, "ifx_lo_open()");
        handle_lo_error(error);
        }

        if(ifx_lo_stat(lofd, &stats) < 0)
        {
        printf("\nifx_lo_stat() < 0");
        break;
        }

if(ifx_int8toint(&c_num, &ic_num) != 0)
ic_num = 99999;

        if((ifx_lo_stat_size(stats, &size)) < 0)
        isize = 0;
        else
        if(ifx_int8toint(&size, &isize) != 0)
        {
        printf("\nFailed to convert size");
        isize = 0;
        }
        if((refcnt = ifx_lo_stat_refcnt(stats)) < 0)
        refcnt = 0;
        printf("\n\nCatalog number %d", ic_num);
        printf("\nSize is %d, reference count is %d", isize, refcnt);

        if((atime = ifx_lo_stat_atime(stats)) < 0)
        printf("\nNo atime available");
        else
        {
        time = (time_t)atime;
        date_time = localtime(&time);
        printf("\nTime of last access: %s", asctime(date_time));
        }

        if((ctime = ifx_lo_stat_ctime(stats)) < 0)
        printf("\nNo ctime available");
        else
        {
        time = (time_t)ctime;
        date_time = localtime(&time);
        printf("Time of last change: %s", asctime(date_time));
        }

        if((mtime = ifx_lo_stat_mtime_sec(stats)) < 0)
        printf("\nNo mtime available");
        else
        {
        time = (time_t)mtime;
        date_time = localtime(&time);
        printf("Time to the second of last modification: %s",
        asctime(date_time));
        }

        if((cspec = ifx_lo_stat_cspec(stats)) == NULL)
        {
        printf("\nUnable to access ifx_lo_create_spec_t structure");
        break;
        }

oflags = ifx_lo_specget_def_open_flags(cspec);
printf("\nDefault open flags are: %d", oflags);

        if(ifx_lo_specget_estbytes(cspec, &estbytes) == -1)
        {
        printf("\nifx_lo_specget_estbytes() failed");
        break;
        }

        if(ifx_int8toint(&estbytes, &iebytes) != 0)
        {
        printf("\nFailed to convert estimated bytes");
        }
        printf("\nEstimated size of smart LO is: %d", iebytes);
        if((extsz = ifx_lo_specget_extsz(cspec)) == -1)
        {
        printf("\nifx_lo_specget_extsz() failed");
        break;
        }

printf("\nAllocation extent size of smart LO is: %d", extsz);

        if((cflags = ifx_lo_specget_flags(cspec)) == -1)
        {
        printf("\nifx_lo_specget_flags() failed");
        break;
        }
printf("\nCreate-time flags of smart LO are: %d", cflags);

        if(ifx_lo_specget_maxbytes(cspec, &maxsize) == -1)
        {
        printf("\nifx_lo_specget_maxsize() failed");
        break;
        }

        if(ifx_int8toint(&maxsize, &imsize) != 0)
        {
        printf("\nFailed to convert maximum size");
        break;
        }

        if(imsize == -1)
        printf("\nMaximum size of smart LO is: No limit");
        else
        printf("\nMaximum size of smart LO is: %d\n", imsize);

        if(ifx_lo_specget_sbspace(cspec, sbspc, sizeof(sbspc)) == -1)
        printf("\nFailed to obtain sbspace name");
        else
        printf("\nSbspace name is %s\n", sbspc);

}

/* Close smart large object */

ifx_lo_close(lofd);
ifx_lo_stat_free(stats);
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

