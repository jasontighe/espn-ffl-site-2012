<?php
require_once("config.php");

header("Cache-Control: no-store, no-cache, must-revalidate");
header("Cache-Control: post-check=0, pre-check=0", false);
header("Pragma: no-cache");

date_default_timezone_set('Europe/London');

	$retval = array();
	
	$retval['timestamp'] = date("Y-m-d H:i:s O");
	$retval['sid'] = md5(uniqid($_SERVER['HTTP_HOST'] . USER_KEY,true));
	$retval['signature'] = hash("sha256", $retval['timestamp'] . $retval['sid'] . USER_KEY);
	$retval['uid'] = USER_ID;
	
exit(json_encode($retval));
?>