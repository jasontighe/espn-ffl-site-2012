<?

include "../../includes.inc.php";

$YoutubeManager = new YoutubeManager;
$YoutubeManager->authenticate($YoutubeManager->getBucketCreds("1"));


?>