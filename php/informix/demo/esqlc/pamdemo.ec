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

/* The purpose of the demo is to provide the information on the usage of the
 * callback function to register and unregister the callback function for the
 * PAM enabled authentication server. In order to see the complete
 * functionality of this demo, make sure that you have a server that is PAM
 * enabled and the OS supports the PAM call.
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define PAM_PROMPT_ECHO_OFF 1
#define PAM_PROMPT_ECHO_ON 2
#define PAM_ERROR_MSG 3
#define PAM_TEXT_INFO 4
#define PAM_MAX_MSG_SIZE        512

EXEC SQL define FNAME_LEN       15;
EXEC SQL define LNAME_LEN       15;

int callback(char *challenge, char *response, int msg_style);

int main()
{
EXEC SQL BEGIN DECLARE SECTION;
    char fname[ FNAME_LEN + 1 ];
    char lname[ LNAME_LEN + 1 ];
EXEC SQL END DECLARE SECTION;

int retval = 0;

/* First register the callback. This needs to be done before establishing the
 * connection as done here.
 */

  printf("Starting PAM demo \n");
  EXEC SQL WHENEVER ERROR STOP;

  retval = ifx_pam_callback(callback);

  if (retval == -1)
        {
        printf("Error in registering callback\n");
        return (-1);
        }
  else
        {
        printf( "Callback function registered.\n");
        EXEC SQL database stores_demo;
        printf ("SQLCODE ON CONNECT = %d\n", SQLCODE);

        EXEC SQL declare pamcursor cursor for
            select fname, lname
               into :fname, :lname
               from customer
               where lname < "C";

        EXEC SQL open pamcursor;
        for (;;)
            {
            EXEC SQL fetch pamcursor;
            if (strncmp(SQLSTATE, "00", 2) != 0)
            break;

            printf("%s %s\n",fname, lname);
            }

        if (strncmp(SQLSTATE, "02", 2) != 0)
            printf("SQLSTATE after fetch is %s\n", SQLSTATE);

        EXEC SQL close pamcursor;
        EXEC SQL free pamcursor;

        EXEC SQL disconnect current;
        printf("\nPAM DEMO run completed successfully\n");
        exit (0);
        }

    return 0;
}

/* The callback function which will provide responses to the challenges. */

int callback(char *challenge, char *response, int msg_style)
{

        switch (msg_style){
           case PAM_PROMPT_ECHO_OFF:
           case PAM_PROMPT_ECHO_ON :
                printf("%s: %d:",challenge, msg_style);
                scanf("%s:",response);
                break;

           case PAM_ERROR_MSG:
           case PAM_TEXT_INFO:
           default:
                printf("%s: %d\n",challenge, msg_style);
                  }
return 0;
}

