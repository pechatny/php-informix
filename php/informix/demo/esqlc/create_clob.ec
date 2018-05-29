/****************************************************************************
 * Licensed Material - Property Of IBM
 *
 * "Restricted Materials of IBM"
 *
 * IBM Informix Client SDK
 *
 * (c)  Copyright IBM Corporation 1997, 2013. All rights reserved.
 *
 *
 ****************************************************************************
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

    EXEC SQL include int8;
    EXEC SQL include locator;
    EXEC SQL define BUFSZ 10;
    extern char statement[80];

main()
{
    EXEC SQL BEGIN DECLARE SECTION;
        int8 catalog_num, estbytes, offset;
        int error, numbytes, lofd, ic_num;
        int buflen = 256;
        char buf[256], srvr_name[256], col_name[300];
        ifx_lo_create_spec_t *create_spec;
        fixed binary 'clob' ifx_lo_t descr;
    EXEC SQL END DECLARE SECTION;

    void nullterm(char *);
    void handle_lo_error(int);
    EXEC SQL whenever sqlerror call whenexp_chk;
    EXEC SQL whenever sqlwarning call whenexp_chk;

    printf("CREATE_CLOB Sample ESQL program running.\n\n");
    strcpy(statement, "CONNECT stmt");
    EXEC SQL connect to 'stores_demo';
    EXEC SQL get diagnostics exception 1
        :srvr_name = server_name;

    printf("the name is = %s\n", srvr_name);
    nullterm(srvr_name);

    /* Allocate and initialize the LO-specification structure */
    error = ifx_lo_def_create_spec(&create_spec);
    if (error < 0)
    {
        strcpy(statement, "ifx_lo_def_create_spec()");
        handle_lo_error(error);
    }

    /* Get the column-level storage characteristics for the
     * CLOB column, advert_descr.
     */
     sprintf(col_name, "stores_demo@%s:catalog.advert_descr", srvr_name);
     error = ifx_lo_col_info(col_name, create_spec);
     if (error < 0)
     {
        strcpy(statement, "ifx_lo_col_info()");
        handle_lo_error(error);
     }

     /* 
      * Override column-level storage characteristics for
      * advert_desc with the following user-defined storage
      * characteristics:
      * no logging
      * extent size = 10 kilobytes
      */
      ifx_lo_specset_flags(create_spec,LO_LOG);
      ifx_int8cvint(BUFSZ, &estbytes);
      ifx_lo_specset_estbytes(create_spec, &estbytes);

      /* Create an LO-specification structure for the smart large object */
      if ((lofd = ifx_lo_create(create_spec, LO_RDWR, &descr, &error)) == -1)
      {
        strcpy(statement, "ifx_lo_create()");
        handle_lo_error(error);
      }

      /* Copy data into the character buffer 'buf' */
      sprintf(buf, "%s", "Pro model infielder's glove. Highest quality leat her and stitching. Long-fingered, deep pocket, generous web.");

      /* 
       * Write contents of character buffer to the open smart
       * large object that lofd points to.
       */
      ifx_int8cvint(0, &offset);
      numbytes = ifx_lo_writewithseek(lofd, buf, buflen, &offset, LO_SEEK_SET, &error);
      if ( numbytes < buflen )
      {
        strcpy(statement, "ifx_lo_writewithseek()");
        handle_lo_error(error);
      }

      /* Insert the smart large object into the table */
      strcpy(statement, "INSERT INTO catalog");
      EXEC SQL insert into catalog values (0, 1, 'HSK', 'case', ROW(NULL, NULL), :descr);

      /* Need code to find out what the catalog_num value was assigned to new row */
      /* Close the LO file descriptor */
      ifx_lo_close(lofd);

      /* Select back the newly inserted value. The SELECT
       * returns an LO-pointer structure, which you then use to
       * open a smart large object to get an LO file descriptor.
       */
      ifx_getserial8(&catalog_num);
      strcpy(statement, "SELECT FROM catalog");
      EXEC SQL select advert_descr into :descr from catalog
        where catalog_num = :catalog_num;

/* Use the returned LO-pointer structure to open a smart
* large object and get an LO file descriptor.
*/
  lofd = ifx_lo_open(&descr, LO_RDONLY, &error);
        if (error < 0)
        {
        strcpy(statement, "ifx_lo_open()");
        handle_lo_error(error);
        }

/* Use the LO file descriptor to read the data in the
* smart large object.
*/
  ifx_int8cvint(0, &offset);
  strcpy(buf, "");
  numbytes = ifx_lo_readwithseek(lofd, buf, buflen, &offset, LO_SEEK_CUR, &error);
        if (error || numbytes == 0)
        {
        strcpy(statement, "ifx_lo_readwithseek()");
        handle_lo_error(error);
        }

        if(ifx_int8toint(&catalog_num, &ic_num) != 0)
        printf("\nifx_int8toint failed to convert catalog_num to int");
        printf("\nContents of column \'descr\' for catalog_num: %d \n\t%s\n",
ic_num, buf);

/* Close open smart large object */
  ifx_lo_close(lofd);

/* Free LO-specification structure */
  ifx_lo_spec_free(create_spec);
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
