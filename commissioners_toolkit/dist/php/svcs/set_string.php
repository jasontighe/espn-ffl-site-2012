<?
/**
 * Set fbmapping string based on league id and facebook id
 */

include "./includes.inc.php";

if((!isset($_REQUEST['league_id'])) || ($_REQUEST['league_id'] == "") || (!isset($_REQUEST['facebook_id'])) || ($_REQUEST['facebook_id'] == "") || (!isset($_REQUEST['str'])) || ($_REQUEST['str'] == "")){
	$result_array = array("status"=>"error", "message"=>"Missing league id, facebook id, or map string");
} else {
	$FbmapManager = new FbmapManager;
	$result_array = $FbmapManager->setMapString($_REQUEST['league_id'], $_REQUEST['facebook_id'], $_REQUEST['str']);
	if(!$result_array){
		$result_array = array("status"=>"error", "message"=>"League id and/or facebook id not found");	
	} else {
		$result_array = array("status"=>"success");	
	
	}
}

echo json_encode($result_array);
 
?>