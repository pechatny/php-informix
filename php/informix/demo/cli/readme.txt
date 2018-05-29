/***************************************************************************
*	Licensed Materials - Property of IBM
*
*
*	"Restricted Materials of IBM"
*
*
*
*	IBM Informix Client SDK
*
*
*	(C) Copyright IBM Corporation 2010 All rights reserved.
*
*
*
*
*
*  Title:          readme.txt
*
*  Description:    readme file describing the ODBC 3.81 demo programs and 
*                  containing instructions on setting up and running the
*                  demos
*
*
***************************************************************************
*/


The ODBC 3.81 demo programs
--------------------------

This release of the Client-SDK contains a number of ODBC demo programs.
This release also includes unicode enabled versions of all ODBC demo
programs.
These demo programs are located in -
    %INFORMIXDIR%/demo/odbcdemo for NT, and
    $INFORMIXDIR/demo/cli for Unix



The following files are included -


(I) Files for creating and dropping the sample database (3 files)
-----------------------------------------------------------------
1. dbcreate.h
2. dbcreate.c 
   -- Creates and populates the demo database - 'odbc_demodb'. The actual 
      database created depends on the version of the Informix server being 
      connected to. If the database version is greater then 9, the demo 
      database created is UDO-enabled, otherwise not.
                 
      This example must be run before running any of the other examples.

3. dbdrop.c - Drops the sample database created using db_create.c. 



(II) General ODBC examples (7 files)
------------------------------------
1. blkinsrt.c
   -- Inserts multiple rows of data into a database table using 
      SQLBulkOperations.

2. catalog.c
   -- Shows the use of catalog functions. Displays a list of tables in 
      the current database, and for each table, lists its columns and 
      identifies the primary key columns.

3. desc.c 
   -- Uses a single descriptor as an ARD for a select statement and 
      an APD for an insert statement.

4. rsetinfo.c 
   -- Uses SQLNumResultCols & SQLDescribeCol to obtain information about 
      the result set returned by the query & display additional information
      about the data returned (number of columns in the result set, and 
      the name, datatype and nullability of each column)

5. posupdt.c
   -- Uses SQLSetPos for making positional updates to a result set
      
6. proc.c 
   -- Demonstrates calling a stored procedure from an ODBC program and 
      returning multiple values from the procedure to the ODBC application

7. transact.c 
   -- Uses SQLEndTran to commit or rollback operations on the connection

	
(III) Informix specific examples -- for UDO-enabled databases only (8 files)
----------------------------------------------------------------------------
1. locreate.c 
   --  Creates a large object on the client (from a local file) and inserts
       it into the database table.

2. loselect.c 
   -- Retrieves CLOB data from the database and displays it

3. loinfo.c 
   -- Gets information about a smart large object stored in the database 
      (it's size and the name of the sbspace where it is stored)

4. rccreate.c
   -- Create a row & list, populate them & insert them into the database table

5. rcselect.c 
   -- Demonstrates retrieving data from a row and a collection. 
      2 queries are executed in this example - the first to retrieve a row and 
      the second to retrieve a collection. A common function is used to do the 
      actual retrieval & display of the data, with the appropriate handle 
      (row or collection) passed in as an argument.

6. rcupdate.c
   -- Updates row and collection columns.
      To update the row, we update one of the elements of the row and then 
      update the entire row on the database.
      To update the list, we add an element to the list and then update the
      list on the database

7. distsel.c 
   -- Retrieves rows containing a distinct type. Distinct types are retrieved
      as their underlying base type


8. OutInOutParamBlob.c
   -- Demonstrates Out, In and InOut Parameters in BLOB data.


(IV) ODBC XA Examples (1 file)
------------------------------
1. OnePhaseCommitRollback.c
   -- exhibits the XA support in ODBC through a simple One Phase Commit-Rollback
      example


(V) Miscellaneous files (8 files)
----------------------------------
1. readme.txt 
   -- this file containing an explanation of what each demo 
      does and how to set up & run the demmos

2. makefile (for NT) or makefile.<platform> (for other platforms)
   -- to compile the demo programs and create the executables

3. advert.txt
   -- File containing CLOB data. Used for inserting the new row containing 
      CLOB data in locreate.c

4. item_1.txt
5. item_2.txt
6. item_3.txt
7. item_4 txt
   -- files conatining CLOB data to be inserted as the 'advert' column in 
      the 'item' table. Used by debcreate.c

8. insert.txt
   -- File containing data. Used for inserting the new row containing
      CLOB data in OutInOutParamBlob.c

Setting up and running the demos
---------------------------------


1. Running the makefile
-----------------------

    You can use the makefile to compile each demo program individually 
    or compile them all at one time. To compile only a single demo, pass
    its name as a command-line argument to make. Not passing any 
    command-line argument will cause all the demo programs to be 
    compiled.

    To compile each unicode demo program individually
    pass its name as a command-line argument to make.
    Unicode demo programs carry the same name as their ASCII
    counterparts but with a W suffix.
    To compile all unicode demo programs at one time  pass UnicodeDemo
    as a command line argument.

    To compile the ODBC XA demo just use the following command at the
    command prompt - 
    $make unixxa (for any unix platform)/
    nmake ntxa (for NT platforms)

    To successfully run the makefile, you have the INFORMIXDIR 
    environment variable set to the directory where the Client-SDK
    is installed.


2. DSN and Environment settings
-------------------------------

    The demo programs are designed to run with a default DSN called 
    'odbc_demo', which should be setup for connecting to the 
    demonstration database 'odbc_demodb' created using the program 
    'dbcreate'. 
    
    If the user chooses, they can use another DSN in 2 ways -
    (i)  Pass the name of the DSN as a command-line argument to the 
         demo. (RECOMMENDED) 
         For e.g. you would run the catalog example using a DSN called
         'myDSN' as 
            >> catalog myDSN
    (ii) Change the value of the 'defDsn' variable in the source code and 
         re-compile the demo

   To run the ODBC XA Demo using your DSN just use the following command -
   OnePhaseCommitRollback.exe DSN_NAME

NOTE
----

1.    In order to run dbcreate.c, the 'DELIMIDENT' environment variable
      must be set to 'n'. This is the default setting for this variable.
      If the value of the 'DELIMIDENT' variable is not set to 'n', then 
      you will get an error message saying "Syntax Error" when running 
      dbcreate.c

2.   In order to run unicode enabled demo programs ,
     UNICODE must be set to UCS-4 in data source configuration information
     file.This is done by adding following line  in [ODBC] section of 
     configuration file.

     UNICODE=UCS-4
     This is applicable only on UNIX platforms .

3.   Prior running the "catalog" demo against 8.40 servers, ensure that the
     server ONCONFIG file has the following settings:

     PHYSFILE 8000
     PHYSBUFF 64
     LOGBUFF  64
     SHMVIRTSIZE 32768
     SHMADD      32768
     DS_MAX_QUERIES    10
     DS_TOTAL_MEMORY    16000

     Without these settings, the demo might fail with the following error:
        ERROR: -959:  HY000 : [Informix][Informix ODBC Driver][Informix]The
        current transaction has been rolled back due to an internal error.
