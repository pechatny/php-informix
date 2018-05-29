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

main()
{
    EXEC SQL BEGIN DECLARE SECTION;
        mint pa;
    EXEC SQL END DECLARE SECTION;

    printf("SQLDETACH Sample ESQL Program running.\n\n");

    printf("Beginning execution of parent process.\n\n");
    printf("Connecting to default server...\n");
    EXEC SQL connect to default;
    chk("CONNECT");
    printf("\n");

    printf("Creating database 'aa'...\n");
    EXEC SQL create database aa;
    chk("CREATE DATABASE");
    printf("\n");

    printf("Creating table 'tab1'...\n");
    EXEC SQL create table tab1 (a integer);
    chk("CREATE TABLE");
    printf("\n");

    printf("Inserting 4 rows into 'tab1'...\n");
    EXEC SQL insert into tab1 values (1);
    chk("INSERT #1");
    EXEC SQL insert into tab1 values (2);
    chk("INSERT #2");
    EXEC SQL insert into tab1 values (3);
    chk("INSERT #3");
    EXEC SQL insert into tab1 values (4);
    chk("INSERT #4");
    printf("\n");

    printf("Selecting rows from 'tab1' table...\n");
    EXEC SQL declare c cursor for select * from tab1;
    chk("DECLARE");
    EXEC SQL open c;
    chk("OPEN");

    printf("\nForking child process...\n");
    fork_child();

    printf("\nFetching row from cursor 'c'...\n"); 
    EXEC SQL fetch c into $pa;
    chk("Parent FETCH");
    if (sqlca.sqlcode == 0)
        printf("Value selected from 'c' = %d.\n", pa);      
    printf("\n");

    printf("Cleaning up...\n");
    EXEC SQL close database;
    chk("CLOSE DATABASE");
    EXEC SQL drop database aa;
    chk("DROP DATABASE");
    EXEC SQL disconnect all;
    chk("DISCONNECT");

    printf("\nEnding execution of parent process.\n");
    printf("\nSQLDETACH Sample Program over.\n\n");
    exit(0);
}

fork_child()
{
    mint rc, status, pid;

    EXEC SQL BEGIN DECLARE SECTION;
        mint cnt, ca;
    EXEC SQL END DECLARE SECTION;

    pid = fork();
    if (pid < 0)
        printf("can't fork child.\n");

    else if (pid == 0)
	{
        printf("\n**********************************************\n");
        printf("* Beginning execution of child process.\n");
        rc = sqldetach();
        printf("* sqldetach() call returns %d.\n", rc);

        /* Verify that the child is not longer using the parent's
         * connection and has not inherited the parent's connection
         * environment.
         */
        printf("* Trying to fetch row from cursor 'c'...\n"); 
        EXEC SQL fetch c into $ca;
        chk("* Child FETCH");
        if (sqlca.sqlcode == 0)
            printf("* Value from 'c' = %d.\n", ca); 

        /* startup a connection for the child, since
         * it doesn't have one.
         */
        printf("\n* Establish a connection, since child doesn't have one\n");
        printf("* Connecting to database 'aa'...\n");
        EXEC SQL connect to 'aa';
        chk("* CONNECT");
        printf("* \n");

        printf("* Determining number of rows in 'tab1'...\n");
        EXEC SQL select count(*) into $cnt from tab1;
        chk("* SELECT");
        if (sqlca.sqlcode == 0)
            printf("* Number of entries in 'tab1' =  %d.\n", cnt);
        printf("* \n");

        printf("* Disconnecting from 'aa' database...\n");
        EXEC SQL disconnect current;
        chk("* DISCONNECT");
        printf("* \n");
        printf("* Ending execution of child process.\n");
        printf("**********************************************\n");
        
        exit(0);
	}

    /* wait for child process to finish */
    while ((rc = wait(&status)) != pid && rc != -1);

}

chk(char *s)
{
    mint msglen;
    char buf1[200], buf2[200];

    if (SQLCODE == 0)
	{
        printf("%s was successful\n", s);
        return;
	}
    printf("\n%s:\n", s);
    if (SQLCODE)
	{
        printf("\tSQLCODE =  %6d: ", SQLCODE);
        rgetlmsg(SQLCODE, buf1, sizeof(buf1), &msglen);
        sprintf(buf2, buf1, sqlca.sqlerrm);
        printf(buf2);
        if (sqlca.sqlerrd[1])
	    {
            printf("\tISAM Error =  %6hd: ", sqlca.sqlerrd[1]);
            rgetlmsg(sqlca.sqlerrd[1], buf1, sizeof(buf1), &msglen);
            sprintf(buf2, buf1, sqlca.sqlerrm);
            printf(buf2);
	    }
	}
}


