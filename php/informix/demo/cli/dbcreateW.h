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
*	(C) Copyright IBM Corporation 2002 All rights reserved.
*
*
*
*
*
*  Title:          dbcreateW.h (Unicode counterpart of dbcreate.h)
*
*  Description:    Header file for dbcreateW.c 
*                  Contains the arrays containg the SQL statements to 
*                  create the sample database and arrays of the data to 
*                  be loaded
*
***************************************************************************
*/


#define NUM_DBCREATE_STMTS	9
#define NUM_INSERT_STMTS	3

#define NUM_CUSTOMERS		9
#define NUM_ITEMS			4
#define NUM_ORDERS			9

#define BUFFER_LEN     1000




/*********************************************************************************
**
**  SQL STATEMENT BUFFERS
**
**********************************************************************************
*/

/*  SQL Statements for creating the sample database for UDO enabled
**  database servers (version number > 9)
*/

SQLWCHAR createUdoDbStmtsW[NUM_DBCREATE_STMTS][BUFFER_LEN] = 
     {L"CREATE DATABASE odbc_demodb WITH LOG;",
      L"GRANT connect TO public;",
	  L"GRANT dba TO public;",
      L"DATABASE odbc_demodb;",
      L"CREATE DISTINCT TYPE dollar AS decimal(5,2);",
	  L"CREATE TABLE xa_tab1(a int)",
      L"CREATE TABLE customer (cust_num      INTEGER PRIMARY KEY,\
                              fname         VARCHAR(10),\
                              lname         VARCHAR(10),\
                              address       ROW (address1 VARCHAR(20),\
                                                 city     VARCHAR(15),\
                                                 state    VARCHAR(5),\
                                                 zip      VARCHAR(6)),\
                              contact_dates LIST (DATETIME YEAR TO DAY NOT NULL));",
      L"CREATE TABLE item (item_num    INTEGER PRIMARY KEY,\
                          description VARCHAR(20),\
                          stock       SMALLINT,\
                          ship_unit   VARCHAR(10),\
                          unit_price  dollar,\
                          advert      CLOB);",
      L"CREATE TABLE orders (order_num  INTEGER PRIMARY KEY,\
                            cust_num   INTEGER,\
                            item_num   INTEGER,\
                            order_date DATE,\
                            quantity   INTEGER,\
                            FOREIGN KEY (cust_num) REFERENCES customer (cust_num),\
                            FOREIGN KEY (item_num) REFERENCES item (item_num));"
     };



/*  SQL Statements for creating the sample database for non-UDO enabled
**  database servers (version number < 9)
*/

SQLWCHAR createNonUdoDbStmtsW[NUM_DBCREATE_STMTS - 1][BUFFER_LEN] = 
     {L"CREATE DATABASE odbc_demodb WITH LOG;",
      L"GRANT connect TO public;",
	  L"GRANT dba TO public;",
      L"DATABASE odbc_demodb;",
	  L"CREATE TABLE xa_tab1(a int)",
      L"CREATE TABLE customer (cust_num      INTEGER PRIMARY KEY,\
                              fname         VARCHAR(10),\
                              lname         VARCHAR(10),\
                              address1      VARCHAR(20),\
                              city          VARCHAR(15),\
                              state         VARCHAR(5),\
                              zip           VARCHAR(6),\
                              first_contact DATETIME YEAR TO DAY,\
                              last_contact  DATETIME YEAR TO DAY);",
      L"CREATE TABLE item (item_num    INTEGER PRIMARY KEY,\
                          description VARCHAR(20),\
                          stock       SMALLINT,\
                          ship_unit   VARCHAR(10),\
                          unit_price  DECIMAL(5,2),\
                          advert      VARCHAR(200));",
      L"CREATE TABLE orders (order_num  INTEGER PRIMARY KEY,\
                            cust_num   INTEGER,\
                            item_num   INTEGER,\
                            order_date DATE,\
                            quantity   INTEGER,\
                            FOREIGN KEY (cust_num) REFERENCES customer (cust_num),\
                            FOREIGN KEY (item_num) REFERENCES item (item_num));"
     };



/*  SQL Statements for inserting data into the sample database 
*/

SQLWCHAR insertDBStmtsW[NUM_INSERT_STMTS][BUFFER_LEN] = 
     {L"INSERT INTO customer VALUES ",
      L"INSERT INTO item VALUES ",
      L"INSERT INTO orders VALUES "};





/*********************************************************************************
**
**  DATA BUFFERS -- table 'CUSTOMER'
**
**********************************************************************************
*/

/*  Array containing values to be inserted into the 'customer' table for UDO 
**  enabled database servers (version number > 9)
*/


SQLWCHAR udoCustW[NUM_CUSTOMERS][BUFFER_LEN] = 
    {L"(101,'Ludwig','Pauli',ROW('213 Erstwild Court','Sunnyvale','CA','94086'),LIST{'1994-08-16'})",
     L"(102,'Carole','Sadler',ROW('785 Geary Street','San Francisco','CA','94117'),LIST{'1991-06-20','1993-07-17'})",
     L"(103,'Philip','Currie',ROW('P.O. Box 3498','Palo Alto','CA','94303'),LIST{'1993-08-02','1993-08-20'})",
     L"(104,'Anthony','Higgins',ROW('422 Bay Road','Redwood City','CA','94026'),LIST{'1994-02-08','1994-05-12'})",
     L"(105,'Raymond','Vector',ROW('1899 La Loma Drive','Los Altos','CA','94022'),LIST{'1992-10-30','1994-03-22'})",
     L"(106,'George','Watson',ROW('1143 Carver Place','Mountain View','CA','94063'),LIST{'1993-11-04'})",
     L"(107,'Charles','Ream',ROW('41 Jordan Avenue','Palo Alto','CA','94304'),LIST{'1991-03-18','1993-04-26'})",
     L"(108,'Donald','Quinn',ROW('587 Alvarado','Redwood City','CA','94063'),LIST{'1991-11-13','1994-01-06'})",
     L"(109,'Jane','Miller',ROW('735 Maude Avenue','Sunnyvale','CA','94086'),LIST{'1993-11-17','1994-05-08'})"};



/*  Array containing values to be inserted into the 'customer' table for non-UDO 
**  enabled database servers (version number < 9)
*/


SQLWCHAR nonUdoCustW[NUM_CUSTOMERS][BUFFER_LEN] = 
    {L"(101,'Ludwig','Pauli','213 Erstwild Court','Sunnyvale','CA','94086','1994-08-16','')",
     L"(102,'Carole','Sadler','785 Geary Street','San Francisco','CA','94117','1991-06-20','1993-07-17')",
     L"(103,'Philip','Currie','P.O. Box 3498','Palo Alto','CA','94303','1993-08-02','1993-08-20')",
     L"(104,'Anthony','Higgins','422 Bay Road','Redwood City','CA','94026','1994-02-08','1994-05-12')",
     L"(105,'Raymond','Vector','1899 La Loma Drive','Los Altos','CA','94022','1992-10-30','1994-03-22')",
     L"(106,'George','Watson','1143 Carver Place','Mountain View','CA','94063','1993-11-04', '')",
     L"(107,'Charles','Ream','41 Jordan Avenue','Palo Alto','CA','94304','1991-03-18','1993-04-26')",
     L"(108,'Donald','Quinn','587 Alvarado','Redwood City','CA','94063','1991-11-13','1994-01-06')",
     L"(109,'Jane','Miller','735 Maude Avenue','Sunnyvale','CA','94086','1993-11-17','1994-05-08')"};




/*********************************************************************************
**
**  DATA BUFFERS -- table 'ITEM'
**
**********************************************************************************
*/

/*  Array containing values to be inserted into the 'item' table for UDO 
**  enabled database servers (version number > 9)
*/


SQLWCHAR udoItemW[NUM_ITEMS][BUFFER_LEN] = 
    {L"(1001,'Running shoes',250,'Pair','170.00',FILETOCLOB('item_1.txt','client'))",
     L"(1002,'Bicycle chain',200,'Each','95.00',FILETOCLOB('item_2.txt','client'))",
     L"(1003,'Golf balls',500,'Box of 6','49.50',FILETOCLOB('item_3.txt','client'))",
     L"(1004,'Baseball glove',100,'Each','50.00',FILETOCLOB('item_4.txt','client'))"};



/*  Array containing values to be inserted into the 'item' table for non-UDO 
**  enabled database servers (version number < 9)
*/


SQLWCHAR nonUdoItemW[NUM_ITEMS][BUFFER_LEN] = 
    {L"(1001,'Running shoes',250,'Pair','170.00',\
        'Super shock-absorbing gel pads disperse vertical energy into a horizontal plane\
         for extraordinary cushioned comfort. Great motion control. Mens only. Specify size.')",
     L"(1002,'Bicycle chain',200,'Each','95.00',\
        'Double or triple crankset with choice of chainrings. For double crankset, chainrings\
         from 38-54 teeth. For triple crankset, chainrings from 24-48 teeth.')",
     L"(1003,'Golf balls',500,'Box of 6','49.50',\
        'Long drive. Fluorescent yellow.')",
     L"(1004,'Baseball glove',100,'Each','60.00',\
        'Brown leather. Specify baseman or infield/outfield style. Specify right- or left-handed.')"};



         
/*********************************************************************************
**
**  DATA BUFFERS -- table 'ORDERS'
**
**********************************************************************************
*/

/*  Array containing values to be inserted into the 'orders' table 
**  (same for UDO or non-UDO enabled databases)
*/


SQLWCHAR ordersW[NUM_ORDERS][BUFFER_LEN] = 
    {L"(1,104,1001,{d '1999-01-23'},3)",
     L"(2,105,1001,{d '1998-12-30'},5)",
     L"(3,101,1004,{d '1999-02-02'},11)",
     L"(4,101,1002,{d '1998-11-26'},1)",
     L"(5,102,1003,{d '1999-01-16'},12)",
     L"(6,107,1004,{d '1998-12-27'},12)",
     L"(7,107,1001,{d '1999-01-05'},2)",
     L"(8,108,1004,{d '1999-01-23'},5)",
     L"(9,106,1003,{d '1999-01-06'},8)"};

