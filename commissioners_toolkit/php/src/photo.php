<?
/**
 * Called by Flash on UGC photo upload, this service stores the image URL for later use with encoding.com.
*/

include "../includes.inc.php";

//required arguments
if((!isset($_REQUEST['league_id'])) || ($_REQUEST['league_id'] == "") || (!isset($_REQUEST['photo_url'])) || ($_REQUEST['photo_url'] == "")){
	$CriticalErrorManager->handleError(false, $Logger->criticalLog("Unable to store and process user-uploaded photo, missing_variables: " . print_r($_REQUEST, true)));
	$response = array("status"=>"error", "error_type"=>"missing_variables");
} else {

	//logic
	$LeagueInviterManager = new LeagueInviterManager;
	if($LeagueInviterManager->storeAndProcessPhoto($_REQUEST['league_id'], $_REQUEST['photo_url'])){
		$Logger->serviceLog("photo", "Stored and processed user-uploaded photo at " . $_REQUEST['photo_url'] . " for league_id " . $_REQUEST['league_id']);
		$response = array("status"=>"success");
	} else {
		$CriticalErrorManager->handleError($_REQUEST['league_id'], $Logger->criticalLog("Unable to store and process user-uploaded photo for league_id " . $_REQUEST['league_id'] . ", " . $LeagueInviterManager->error_type));
		$response = array("status"=>"error", "error_type"=>$LeagueInviterManager->error_type);
	}

}

echo json_encode($response);

?>