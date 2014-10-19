<?

include "../../includes.inc.php";

$YoutubeBucketTable = new YoutubeBucketTable;


echo "before add: ";
print_r($YoutubeBucketTable->getByYoutubeBucketId("1"));

$YoutubeBucketTable->subtract("1");
$YoutubeBucketTable->subtract("1");
$YoutubeBucketTable->add("1");
$YoutubeBucketTable->subtract("1");


echo "after add: ";
print_r($YoutubeBucketTable->getByYoutubeBucketId("1"));



?>