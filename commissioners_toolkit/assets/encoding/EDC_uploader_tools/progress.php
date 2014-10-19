<?php
require_once("config.php");

header("Cache-Control: no-store, no-cache, must-revalidate");
header("Cache-Control: post-check=0, pre-check=0", false);
header("Pragma: no-cache");

$sid = $_GET['X-Progress-ID'];

if(empty($_GET['action'])){
    $result =  file_get_contents(UPLOADING_SERVER . "/progress?X-Progress-ID=" . $sid); 
} elseif($_GET['action'] == 's3uploading'){
    $result =  file_get_contents(UPLOADING_SERVER . "/s3info.php?sid=".$sid);
} elseif($_GET['action'] == 'filename'){
    $result =  file_get_contents(UPLOADING_SERVER . "/fileinfo.php?sid=".$sid);
}

print_r($result);
?>