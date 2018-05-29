--TEST--
pdo_informix: Test error conditions
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
				$stmt1 = $this->db->prepare("SELECT id FROM animals WHERE colnotexist = 1 " ) ;
				print("Error Code: ".$this->db->errorCode()."\n");
				print_r($this->db->errorInfo());
				print("\n");
				$stmt2 = $this->db->prepare("SELECT id FROM animals WHERE id = 1 " ) ;
				print("Error Code: ".$this->db->errorCode()."\n");
				print_r($this->db->errorInfo());
				print("\n");
			} catch (PDOException $pe) {
				print("Error Code: ".$this->db->errorCode()."\n");
				print_r($this->db->errorInfo());
				print("\n");
				$stmt2 = $this->db->prepare("SELECT id FROM animals WHERE id = 1 " ) ;
				print("Error Code: ".$this->db->errorCode()."\n");
				print_r($this->db->errorInfo());
				print("\n");
			}
		}
	}

	$testcase = new Test();
	$testcase->runTest();
?>
--EXPECTF--
Error Code: 42S22
Array
(
    [0] => 42S22
    [1] => -217
    [2] => [Informix][Informix ODBC Driver][Informix]Column (colnotexist) not found in any table in the query (or SLV is undefined). (%s
)

Error Code: 00000
Array
(
    [0] => 00000
    [1] => 0
    [2] =>  ((null)[0] at (null):0)
)

