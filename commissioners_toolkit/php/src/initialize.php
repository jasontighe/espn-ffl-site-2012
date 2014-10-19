<?
/**
 * Called by Flash when a user begins the LI creation process, INITIALIZE sets up a record for this league id
 */

include "../includes.inc.php";

//required arguments
if((!isset($_REQUEST['league_id'])) || ($_REQUEST['league_id'] == "") || (!isset($_REQUEST['league_name'])) || ($_REQUEST['league_name'] == "") || (!isset($_REQUEST['league_manager_name'])) || ($_REQUEST['league_manager_name'] == "") || (!isset($_REQUEST['user_profile_id'])) || ($_REQUEST['user_profile_id'] == "") || (!isset($_REQUEST['video_type'])) || ($_REQUEST['video_type'] == "")){
	$Logger->criticalLog("Unable to initialize new leagueinviter record, missing variables: " . print_r($_REQUEST, true));
	$response = array("status"=>"error", "error_type"=>"missing_variables");
} else {
	
	//logic
	$LeagueInviterManager = new LeagueInviterManager;
	if($LeagueInviterManager->createNewLeagueRecord($_REQUEST['league_id'], $_REQUEST['user_profile_id'], $_REQUEST['league_name'], $_REQUEST['league_manager_name'], $_REQUEST['video_type'])){
		if($status = $LeagueInviterManager->getStatus($_REQUEST['league_id'])){
			$Logger->serviceLog("initialize", "Inserted new leagueinviter record for league_id " . $_REQUEST['league_id']);
			$response = array("status"=>"success", "details"=>$status);
		} else {
			//$Logger->criticalLog("Unable to initialize new leagueinviter record due to no status response, db failure: " . print_r($_REQUEST, true));
			$response = array("status"=>"error", "error_type"=>"db_failure");	
		}
			
	} else {
		if($LeagueInviterManager->error_type != "duplicate_league_id"){
			//$Logger->criticalLog("Unable to initialize new leagueinviter record due to dupe, $LeagueInviterManager->error_type " . print_r($_REQUEST, true));
		}
		$response = array("status"=>"error", "error_type"=>$LeagueInviterManager->error_type);
	}

}

echo json_encode($response);

?>