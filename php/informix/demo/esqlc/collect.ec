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
** @(#)$Id: collect1.ec,v 1.1 1998/11/06 01:17:44 jleffler Exp $
**
** Sample use of collections in ESQL/C.
**
** Statically determined collection types.
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static void print_collection(
const char *tag,
EXEC SQL BEGIN DECLARE SECTION;
parameter client collection c
EXEC SQL END DECLARE SECTION;
)
{
	EXEC SQL BEGIN DECLARE SECTION;
	int4	value;
	EXEC SQL END DECLARE SECTION;
	mint		item = 0;

	EXEC SQL WHENEVER ERROR STOP;
	printf("COLLECTION: %s\n", tag);
	EXEC SQL DECLARE c_collection CURSOR FOR
		SELECT * FROM TABLE(:c);
	EXEC SQL OPEN c_collection;
	while (sqlca.sqlcode == 0)
	{
		EXEC SQL FETCH c_collection INTO :value;
		if (sqlca.sqlcode != 0)
			break;
		printf("\tItem %d, value = %d\n", ++item, value);
	}
	EXEC SQL CLOSE c_collection;
	EXEC SQL FREE c_collection;
}

mint main(int argc, char **argv)
{
	EXEC SQL BEGIN DECLARE SECTION;
	client collection list     (integer not null) lc1;
	client collection set      (integer not null) sc1;
	client collection multiset (integer not null) mc1;
	char *dbase = "stores_demo";
	mint seq;
	char *stmt1 = 
		"INSERT INTO t_collections VALUES(0, "
		"'LIST{-1,0,-2,3,0,0,32767,249}', 'SET{-1,0,-2,3}', "
		"'MULTISET{-1,0,0,-2,3,0}') ";
	EXEC SQL END DECLARE SECTION;

	if (argc > 1)
		dbase = argv[1];
	EXEC SQL WHENEVER ERROR STOP;
	printf("Connect to %s\n", dbase);
	EXEC SQL connect to :dbase;

	EXEC SQL CREATE TEMP TABLE t_collections
	(
		seq	serial not null,
		l1 list    (integer  not null),
		s1 set     (integer  not null),
		m1 multiset(integer  not null)
	);


	EXEC SQL EXECUTE IMMEDIATE :stmt1;

	EXEC SQL ALLOCATE COLLECTION :lc1;
	EXEC SQL ALLOCATE COLLECTION :mc1;
	EXEC SQL ALLOCATE COLLECTION :sc1;

	EXEC SQL DECLARE c_collect CURSOR FOR
		SELECT seq, l1, s1, m1 FROM t_collections;
	EXEC SQL OPEN c_collect;

	EXEC SQL FETCH c_collect INTO :seq, :lc1, :sc1, :mc1;
	EXEC SQL CLOSE c_collect;
	EXEC SQL FREE c_collect;

	print_collection("list/integer", lc1);
	print_collection("set/integer", sc1);
	print_collection("multiset/integer", mc1);

	EXEC SQL DEALLOCATE COLLECTION :lc1;
	EXEC SQL DEALLOCATE COLLECTION :mc1;
	EXEC SQL DEALLOCATE COLLECTION :sc1;

	puts("OK");
	return 0;
}

