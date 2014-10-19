<?
/**
 * Initiate creation of pre-made video process, with or without a user-uploaded photo. IF there is a photo, though,
 * it should be already in the DB before Flash hits this process
 */


include "../includes.inc.php";

//required arguments
if((!isset($_REQUEST['league_id'])) || ($_REQUEST['league_id'] == "") || (!isset($_REQUEST['video_id'])) || ($_REQUEST['video_id'] == "")){
	$CriticalErrorManager->handleError($_REQUEST['league_id'], $Logger->criticalLog("Unable to store and process premade video " . $_REQUEST['video_id'] . "for league_id " . $_REQUEST['league_id'] . ", missing variables: " . print_r($_REQUEST, true)));
	$response = array("status"=>"error", "error_type"=>"missing_variables");
} else {

	//logic
	$LeagueInviterManager = new LeagueInviterManager;
	if($LeagueInviterManager->storeAndProcessPremade($_REQUEST['league_id'], $_REQUEST['video_id'])){
		$Logger->serviceLog("premade", "Stored and processed premade video " . $_REQUEST['video_id'] . " for league_id " . $_REQUEST['league_id'] . ", media_id " . $LeagueInviterManager->new_media_id);
		$response = array("status"=>"success");
	} else {
		$CriticalErrorManager->handleError($_REQUEST['league_id'], $Logger->criticalLog("Unable to store and process webcam video " . $_REQUEST['video_id'] . " for league_id " . $_REQUEST['league_id'] . ", $LeagueInviterManager->error_type"));
		$response = array("status"=>"error", "error_type"=>$LeagueInviterManager->error_type);
	}

}

echo json_encode($response);

?>