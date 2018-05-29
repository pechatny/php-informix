--TEST--
pdo_informix: Check error condition when given null connection parameters
--SKIPIF--
<?php require_once('skipif.inc'); ?>
--FILE--
<?php
	require_once('fvt.inc');
	class Test extends FVTTest
	{
		public function runTest()
		{
			try {
				$my_null = NULL;
				$new_conn = new PDO($my_null, $this->user, $this->pass);
			} catch(Exception $e) {
				echo "Connection Failed\n";
				echo $e->getMessage() . "\n\n";
			}

			try {
				$my_null = NULL;
				$new_conn = new PDO($this->dsn, $my_null, $this->pass);
			} catch(Exception $e) {
				echo "Connection Failed\n";
				echo $e->getMessage() . "\n";
			}

			try {
				$my_null = NULL;
				$new_conn = new PDO($this->dsn, $this->user, $my_null);
			} catch(Exception $e) {
				echo "Connection Failed\n";
				echo $e->getMessage();
			}
		}
	}

	$testcase = new Test();
	$testcase->runTest();
?>
--EXPECTF--
Connection Failed
invalid data source name

Connection Failed
SQLSTATE=28000, SQL%sonnect: -951 [%s][%s][Informix]Incorrect password or user %s is not known on the database server.
Connection Failed
SQLSTATE=28000, SQL%sonnect: -951 [%s][%s][Informix]Incorrect password or user %s is not known on the database server.

