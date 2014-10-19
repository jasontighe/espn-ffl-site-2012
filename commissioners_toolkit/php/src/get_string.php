<?
/**
 * Get fbmapping string based on league id and facebook id
 */

include "../includes.inc.php";

if((!isset($_REQUEST['league_id'])) || ($_REQUEST['league_id'] == "") || (!isset($_REQUEST['facebook_id'])) || ($_REQUEST['facebook_id'] == "")){
	$result_array = array("status"=>"error", "message"=>"Missing league id, facebook id, or map string");
	echo json_encode($result_array);
} else {
	$FbmapManager = new FbmapManager;
	$result_array = $FbmapManager->getMapString($_REQUEST['league_id'], $_REQUEST['facebook_id']);
	if(!$result_array){
		$result_array = array("status"=>"error", "message"=>"String not found for that league id and facebook id");	
	}
	echo $result_array['string'];

}

 
?>