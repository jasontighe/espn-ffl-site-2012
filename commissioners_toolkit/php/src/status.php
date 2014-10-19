<?
/**
 * Called by Flash whenever it needs a status of this league's video.
*/

include "../includes.inc.php";

//required arguments
if((!isset($_REQUEST['league_id'])) || ($_REQUEST['league_id'] == "")){
	$CriticalErrorManager->handleError(false, $Logger->criticalLog("Unable to get status, missing_variables: " . print_r($_REQUEST, true)));
	$response = array("status"=>"error", "error_type"=>"missing_variables");
} else {

	//logic
	$LeagueInviterManager = new LeagueInviterManager;
	if($status = $LeagueInviterManager->getStatus($_REQUEST['league_id'])){
		$Logger->serviceLog("status", "Got status for league_id " . $_REQUEST['league_id'] . " - " . $status['status']);
		$response = array("status"=>"success", "details"=>$status);
	} else {
		$CriticalErrorManager->handleError($_REQUEST['league_id'], $Logger->criticalLog("Unable to get status for league_id " . $_REQUEST['league_id'] . ", db_failure"));
		$response = array("status"=>"error", "error_type"=>"db_failure");	
	}

}

echo json_encode($response);

?>