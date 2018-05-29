/****************************************************************************
 *
 *                               IBM INC.
 *
 *                           PROPRIETARY DATA
 *
 * Licensed Material - Property Of IBM
 *
 * "Restricted Materials of IBM"
 *
 * IBM Informix Client SDK
 *
 * (c)  Copyright IBM Corporation 1997, 2006. All rights reserved.
 *
 ****************************************************************************
 */


//  Title: queryex.cpp
//
//  Description:
//	Insert a user name into the informixfans table
//
//  Parameter:
//	nd - (no drop) Doesn't drop the table
//

#include <iostream>
#include <it.h>
#include <string>
using namespace std;

int main(int argc, char *argv[])
{
    if ( 3 < argc 
         || 2 == argc 
         || (3 == argc) && (strcmp (argv[1],"-nd") != 0))
        {
        cerr << "Usage: " << argv[0] << " [-nd newfan]" << endl;
        return 1;
        }

    // Make a connection using defaults
    ITConnection conn;
    conn.Open();

    // Create a query object
    ITQuery q(conn);

    if (argc == 1)
        {
        // Drop the table first; ignore errors if it didn't exist
        q.ExecForStatus("drop table informixfans;");
        }

    // Does the table exist? If not, then create it.                // 1 begin
    ITRow *r1 = q.ExecOneRow(
        "select owner from systables where tabname = 'informixfans';");
    if ( !r1
         && (!q.ExecForStatus(
             "create table informixfans (name varchar(128));")))
        {
        cerr << "Could not create table `informixfans'!" << endl;
        return 1;
        }                                                            // 1 end

    if (r1) 
        r1->Release();

    // Begin the transaction
    conn.SetTransaction(ITConnection::Begin);
    
    // Insert the new user into the table
    ITString query;
    if( 1 == argc )
        query = "insert into informixfans values ('Bob');";
    else
        {
        query = "insert into informixfans values ('";
        query.Append( argv[2] );
        query.Append( "');" );
        }
    q.ExecForStatus(query);

    // Show the contents of the table                              // 2 begin
    cout << "These are the members of the Informix fan club, version ";
    ITValue *rel = q.ExecOneRow                                     
        ( "select owner from systables where tabname = ' VERSION';" );
    cout << rel->Printable() << " ALWAYS_DIFFERENT" << endl;
    rel->Release();                                                 

    ITSet *set = q.ExecToSet
        ("select * from informixfans order by 1;"); 
    if( !set )
    {
	    cout << "Query failed!" << endl;
	    conn.SetTransaction(ITConnection::Abort);
	    conn.Close();
	    return -1;
    }
    ITValue *v;
    while ((v = set->Fetch()) != NULL)
    {
        cout << v->Printable() << endl;
        v->Release();
    }                                                           
    set->Release();                                                 // 2 end

    cout << endl;
    conn.SetTransaction(ITConnection::Commit);

    if (argc == 1)
    {
      // Drop the table now that we're done with it
      q.ExecForStatus("drop table informixfans;");
    }

    conn.Close();

    return 0;
}

