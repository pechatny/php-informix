--TEST--
pdo_informix: Testing the lastInsertID function.
--SKIPIF--
<?php require_once('skipif.inc'); ?>
--FILE--
<?php
	require_once('fvt.inc');
	class Test extends FVTTest
	{
		public function runTest()
		{
			$this->connect();
			try {
				/* Drop the test table, in case it exists */
				$drop = 'DROP TABLE animals';
				$result = $this->db->exec( $drop );
			} catch( Exception $e ){}
			try {
				/* Drop the test table, in case it exists */
				$drop = 'DROP TABLE owner';
				$result = $this->db->exec( $drop );
			} catch( Exception $e ){}

			print "Last Insert Id: " . $this->db->lastInsertId() . "\n" ;

			/* Create the test table */
			$create = 'CREATE TABLE animals (id INTEGER, name varchar(20))';
			$result = $this->db->exec( $create );
			$stmt = $this->db->query( "INSERT INTO animals ( id, name ) VALUES ( 1, 'dog' )" );
			print "Last Insert Id: " . $this->db->lastInsertId() . "\n" ;

			$drop = 'DROP TABLE animals';
			$result = $this->db->exec( $drop );

			/* Create the test table */
			$create = 'CREATE TABLE animals (id SERIAL, name varchar(20))';

			$result = $this->db->exec( $create );
			$stmt = $this->db->exec( "INSERT INTO animals (name) VALUES ( 'dog' )" );
			print "Last Insert Id: " . $this->db->lastInsertId() . "\n" ;

			$sql = "select id from animals ";
			$stmt = $this->db->query($sql);
			$res = $stmt->fetch();
			print_r($res);
			print "Last Insert Id: " . $this->db->lastInsertId() . "\n";

			$stmt = $this->db->query( "INSERT INTO animals (id, name) VALUES ( 1147483647, 'dog' )" );
			print "Last Insert Id: " . $this->db->lastInsertId() . "\n";

			$stmt = $this->db->query( "INSERT INTO animals (name) VALUES ( 'dog' )" );
			print "Last Insert Id: " . $this->db->lastInsertId() . "\n";

			/* Create the test table */
			$create = 'CREATE TABLE owner (id SERIAL8, name varchar(20))';
			$result = $this->db->exec( $create );
			$stmt = $this->db->query( "INSERT INTO owner (name) VALUES ( 'tom' )" );
			print "Last Insert Id: " . $this->db->lastInsertId() . "\n" ;

			$drop = 'DROP TABLE animals';
			$result = $this->db->exec( $drop );

			/* Create the test table */
			$create = 'CREATE TABLE animals (id INTEGER, name varchar(20))';
			$result = $this->db->exec( $create );
			$stmt = $this->db->query( "INSERT INTO animals ( id, name ) VALUES ( 1, 'dog' )" );
			print "Last Insert Id: " . $this->db->lastInsertId() . "\n" ;

			$drop = 'DROP TABLE animals';
			$result = $this->db->exec( $drop );

			/* Create the test table */
			 $create = 'CREATE TABLE animals (id SERIAL, name varchar(20))';
			$result = $this->db->exec( $create );
			$stmt = $this->db->prepare( "INSERT INTO animals ( id, name ) VALUES ( 1, 'dog' )" );
			print "Last Insert Id: " . $this->db->lastInsertId() . "\n" ;
			$stmt->execute();
			print "Last Insert Id: " . $this->db->lastInsertId() . "\n" ;

			print "Last Insert Id: " . $this->db->lastInsertId() . "\n" ;
			print "Last Insert Id: " . $this->db->lastInsertId( "INSERT INTO animals ( id, name ) 
											VALUES ( 2, 'dog' )" ) . "\n" ;
			$stmt->closeCursor();
			print "Last Insert Id: " . $this->db->lastInsertId() . "\n" ;
			$stmt = $this->db->prepare( "INSERT INTO animals ( id, name ) VALUES ( 2, 'dog' )" );
			$stmt->closeCursor();
			print "Last Insert Id: " . $this->db->lastInsertId() . "\n" ;
			print "Last Insert Id: " . $this->db->lastInsertId( null );

		}
	}
	$testcase = new Test();
	$testcase->runTest();
?>
--EXPECTF--
Last Insert Id: 0
Last Insert Id: 0
Last Insert Id: 1
Array
(
    [ID] => 1
    [0] => 1
)
Last Insert Id: 1
Last Insert Id: 1147483647
Last Insert Id: 1147483648
Last Insert Id: 0
Last Insert Id: 0
Last Insert Id: 0
Last Insert Id: 1
Last Insert Id: 1
Last Insert Id: 1
Last Insert Id: 1
Last Insert Id: 1
Last Insert Id: 1
