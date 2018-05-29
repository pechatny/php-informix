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

/* ===========================================================================
	SQL communications area, and definition of the blob locator (loc_t)
 ============================================================================*/
EXEC SQL include sqlca;
EXEC SQL include locator;

/* ===========================================================================
	Assorted global variables.
 ============================================================================*/
#define MAXKEYS 8

unsigned short mode;	/* either "i" or "u" */
unsigned short verbose; /* was -v given? */
unsigned short logging; /* does database use transactions? */
char *blobfile;		/* ->the filename to read */
char *dbname;		/* ->the database name */
char *tabname;		/* ->the table name */
char *blobcol;		/* ->the blob column name */
mint  num_keys;		/* how many -k pair were given */
char *keycols[MAXKEYS];	/* up to eight ->name of keycolumn */

EXEC SQL BEGIN DECLARE SECTION;
    char str_spec[250];	/* place to build statements */
    char *keyvals[MAXKEYS];/* up to eight ->key values */
EXEC SQL END DECLARE SECTION;

/* ==========================================================================
	Display the usage message on stdout and exit
 =========================================================================== */
void usage_n_quit()
{
    printf("\n"); /* blank line after error message */

#define anitem(x,y) printf("%26s\t-- %s\n",x,y);

    anitem("Usage: blobload  {-i | -u}","choose insert or update")
    anitem("-f filename","file containing the blob data")
    anitem("-d database_name","database to open")
    anitem("-t table_name","table to modify")
    anitem("-b blob_column","name of target column")
    anitem("-k key_column key_value","name of key column and a value")
    anitem("-v","verbose documentary output")
    printf("\nAll parameters except -v are required.\n");
    printf("Parameters may be given in any order.\n");
    printf("As many as %d -k parameter pairs may be specified.\n",MAXKEYS);
    exit (0);
}

/* =========================================================================
	Examine all the many parameters, make sure they all were specified,
	and save their values.  If any error, usage_n_quit.
============================================================================ */
void all_params(mint argc, char *argv[])
{
    mode = ' ';
    verbose = 0;
    logging = 0;
    blobfile = dbname = tabname = blobcol = NULL;
    num_keys = 0;

    while (argc > 1)
	{
    	if (argv[1][0] == '-' && argv[1][1])
	    {
  	    switch(argv[1][1])
		{
               	case 'u': 
		case 'i':
		    mode = argv[1][1];
		    break;
		case 'v':
		    verbose = 1;
		    break;
                case 'd':       
        	    argc--;
        	    argv++;
		    dbname = argv[1];
                    break;
                case 't':
        	    argc--;
        	    argv++;
		    tabname = argv[1];
                    break;
                case 'b':
        	    argc--;
        	    argv++;
		    blobcol = argv[1];
		    break;
		case 'f':
        	    argc--;
        	    argv++;
		    blobfile = argv[1];
                    break;
                case 'k':
		    if (num_keys == MAXKEYS)
			{
                        printf("Sorry, at most %d key columns (-k) ");
                        printf("can be given\n", MAXKEYS);
			usage_n_quit();
			}
        	    argc--;
        	    argv++;
		    keycols[num_keys] = argv[1];
        	    argc--;
        	    argv++;
		    keyvals[num_keys] = argv[1];
		    num_keys++;
                    break;
		default:
	            printf("Sorry, I do not recognize the ");
                    printf("parameter %s.\n",argv[1]);
		    usage_n_quit();
		} /* end switch */
	    }
	else /* parameter not "-x" */
	    {
	    printf("Sorry, I do not recognize the parameter %s.\n",argv[1]);
	    usage_n_quit();
	    }
        argc--;
        argv++;
	} /* end while */
    if (	(num_keys == 0)||(mode == ' ')||(dbname == NULL)||
		(tabname == NULL)||(blobfile == NULL)||(blobcol == NULL) )
	{
	printf("Sorry, you left out a required parameter.\n");
	usage_n_quit();
	}
}
/* =========================================================================
	After an SQL operation, check the return code.  If there was
	no error, do nothing but return.  If there was an error, issue
	a set of diagnostic messages and end the program.
 =========================================================================== */
void error_check(char *doing_what)
{

#define MSG_LEN 80

    char message[MSG_LEN];
    mint sql_num, isam_num, msg_num;

    if ((sql_num = sqlca.sqlcode) >= 0) return;

    isam_num = sqlca.sqlerrd[1];
    /*
     *	If the database has logging, do a rollback. If we have not yet
     * 	done the BEGIN WORK, this has no effect except to set SQLCODE.
     */
    if (logging)
        EXEC SQL rollback work;

    /*
     *	Get the message text for the sql error code, and display
     *	the gory details.  Then quit.
     */
    msg_num = rgetmsg(sql_num,message,MSG_LEN);

    printf("An error occurred during %s.\n",doing_what);
    if (msg_num == 0) /* either 0 or -1232 */
        printf("%s\n",message);
    else
	printf("(Unknown error message)\n");
    printf("SQL error code = %d, ISAM error code = %d\n",sql_num,isam_num);
    fflush(stdout);
    exit(sql_num);
}

/* =========================================================================
	Construct an INSERT statement from the parameters.  Because we
	allow for composite keys (multiple -k pairs) we don't know how
	many key columns will have to be included.  So we don't know
	how many host variables to list in the execute statement.  So we
	can't use host variables for inserted values for key columns;
	we have to build the values right into the statement string.
	Since the engine will auto-convert numeric strings to numbers, but
	can't handle unquoted character literals, we quote all key values.
	In other words we are building a statement of this form:

	INSERT INTO <tabname>(<blobcol>, <keycol1>, <keycol2>,...)
		VALUES(?, "key1val", "key2val",...)

	The only "?" represents the locater variable for the blob file.
	If a given keyvalue happens to be numeric and its column is numeric
	the engine will automatically convert for us.
 =========================================================================== */
void build_ins()
{
    mint n;

    sprintf(str_spec,"INSERT INTO %s( %s",tabname,blobcol);
    for (n = 0; n < num_keys; ++n)
	{
	strcat(str_spec,", ");
	strcat(str_spec,keycols[n]);
	}

    strcat(str_spec,") VALUES( ?");

    for (n = 0; n < num_keys; ++n)
	{
	strcat(str_spec,", \"");
	strcat(str_spec,keyvals[n]);
	strcat(str_spec,"\"");
	}
    strcat(str_spec,");");
    if (verbose)
	{
	printf("\nprepared stmt =\n%s\n\n",str_spec);
	fflush(stdout);
	}
}

/* =========================================================================
	As for INSERT, so for UPDATE.  Here the key columns and values
	are not updated but rather tested in a WHERE clause. Since we
	don't know how many there will be, we can't use host variables
	or prepare, but have to build the full statement like this:

	UPDATE <tabname> SET <blobcol> = ?
	WHERE <keycol1> = "key1val" AND <keycol2> = "key2val" AND...

	Again, numeric keyvals will be autoconverted for comparison when
	the corresponding column is numeric.
 =========================================================================== */
void build_upd()
{
    mint n;

    sprintf(str_spec,
        "UPDATE %s SET %s = ? WHERE %s = \"%s\""
        ,tabname,blobcol,   keycols[0],keyvals[0]  );
    for (n = 1; n < num_keys; ++n)
	{
	strcat(str_spec," AND ");
	strcat(str_spec,keycols[n]);
	strcat(str_spec," = \"");
	strcat(str_spec,keyvals[n]);
	strcat(str_spec,"\"");
	}
    strcat(str_spec,";");
    if (verbose)
	{
	printf("\nprepared stmt =\n%s\n\n",str_spec);
	fflush(stdout);
	}
}

/* =========================================================================
	The program itself...
 =========================================================================== */
main(mint argc,char *argv[])
{

EXEC SQL BEGIN DECLARE SECTION;
    loc_t images;		/* the locator structure */
EXEC SQL END DECLARE SECTION;

    /*
     *	Examine the command-line parameters, validate and store.
     */
    all_params(argc,argv);

    /*
     *	Connect to the database specified by command line
     *  option -d and check for error.
     */
    strcpy(str_spec, dbname);
    EXEC SQL connect to :str_spec;
    error_check("connect statement");
    /*
     *	Note if transactions are used in this database.  This is set in
     *	SQLAWARN (4gl terminology) after a db open.
     */
    logging = 0;
    if (sqlca.sqlwarn.sqlwarn1 == 'W') 
        logging = 1;

    /*	
     * 	Set up the locator structure to load the contents of
     *	a file by name.
     */
    images.loc_loctype = LOCFNAME;	/* blob is named file */
    images.loc_fname = blobfile;	/* here is its name */
    images.loc_oflags = LOC_RONLY;	/* contents are to be read by engine */
    images.loc_size = -1;		/* read to end of file */
    images.loc_indicator = 0;	/* not a null blob */

    /*
     *	Prepare and execute either an INSERT or an UPDATE depending on mode.
     *	Use BEGIN/COMMIT if the database has transaction logging. (If there
     *	is an error, the ROLLBACK is done in error_check() above.)
     *	Note that more than one row can be affected if the keys given
     *	are not unique in the database.  Hence we display the count
     *	of affected rows afterward.
     */
    if (logging)
        EXEC SQL execute immediate 'BEGIN WORK';

    if (mode == 'i')
	{
        build_ins();
        EXEC SQL prepare the_insert from :str_spec;
	error_check("prepare of insert");
        EXEC SQL execute the_insert using :images;
	error_check("insert statement");
	if (verbose)
	    printf("%d row(s) inserted.\n",sqlca.sqlerrd[2]);
	}
    else
	{
	build_upd();
        EXEC SQL prepare the_update from :str_spec;
	error_check("prepare of update");
        EXEC SQL execute the_update using :images;
	error_check("update statement");
	if (verbose)
	    printf("%d row(s) updated.\n",sqlca.sqlerrd[2]);
	}

    if (logging)
        EXEC SQL execute immediate 'COMMIT WORK';
    fflush(stdout);
    exit(0);
}
