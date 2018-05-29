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
**
** Sample use of LVARCHAR to fetch collections in ESQL/C.
**
** Statically determined collection types.
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static void print_lvarchar_ptr(
const char *tag,
EXEC SQL BEGIN DECLARE SECTION;
parameter lvarchar **lv
EXEC SQL END DECLARE SECTION;
)
{
	char *data;

	data = ifx_var_getdata(lv);
	if (data == 0)
		data = "<<NO DATA>>";
	printf("%s: %s\n", tag, data);
}

static void process_stmt(char *stmt)
{
	EXEC SQL BEGIN DECLARE SECTION;
	lvarchar *lv1;
	lvarchar *lv2;
	lvarchar *lv3;
	mint seq;
	char *stmt1 = stmt;
	EXEC SQL END DECLARE SECTION;

	printf("SQL: %s\n", stmt);

	EXEC SQL WHENEVER ERROR STOP;
	EXEC SQL PREPARE p_collect FROM :stmt1;
	EXEC SQL DECLARE c_collect CURSOR FOR p_collect;
	EXEC SQL OPEN c_collect;

	ifx_var_flag(&lv1, 1);
	ifx_var_flag(&lv2, 1);
	ifx_var_flag(&lv3, 1);

	while (sqlca.sqlcode == 0)
	{
		EXEC SQL FETCH c_collect INTO :seq, :lv1, :lv2, :lv3;
		if (sqlca.sqlcode == 0)
		{
			printf("Sequence: %d\n", seq);
			print_lvarchar_ptr("LVARCHAR 1", &lv1);
			print_lvarchar_ptr("LVARCHAR 2", &lv2);
			print_lvarchar_ptr("LVARCHAR 3", &lv3);
			ifx_var_dealloc(&lv1);
			ifx_var_dealloc(&lv2);
			ifx_var_dealloc(&lv3);
		}
	}

	EXEC SQL CLOSE c_collect;
	EXEC SQL FREE c_collect;
	EXEC SQL FREE p_collect;
}

mint main(int argc, char **argv)
{
	EXEC SQL BEGIN DECLARE SECTION;
	char *dbase = "stores_demo";
	char *stmt1 = 
		"INSERT INTO t_collections VALUES(0, "
		"'LIST{-1,0,-2,3,0,0,32767,249}', 'SET{-1,0,-2,3}', "
		"'MULTISET{-1,0,0,-2,3,0}') ";
	char *data;
	EXEC SQL END DECLARE SECTION;

	if (argc > 1)
		dbase = argv[1];
	EXEC SQL WHENEVER ERROR STOP;
	printf("Connect to %s\n", dbase);
	EXEC SQL CONNECT TO :dbase;

	EXEC SQL CREATE TEMP TABLE t_collections
	(
		seq	serial not null,
		l1 list    (integer  not null),
		s1 set     (integer  not null),
		m1 multiset(integer  not null)
	);

	EXEC SQL EXECUTE IMMEDIATE :stmt1;
	EXEC SQL EXECUTE IMMEDIATE :stmt1;
	EXEC SQL EXECUTE IMMEDIATE :stmt1;

	process_stmt("SELECT seq, l1, s1, m1 FROM t_collections");

	puts("OK");
	return 0;
}


