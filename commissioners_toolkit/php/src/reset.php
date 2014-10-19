<?
/**
 * Called by Flash before a repeat user begins the LI video creation process.
*/

include "../includes.inc.php";

//required arguments
if((!isset($_REQUEST['league_id'])) || ($_REQUEST['league_id'] == "")){
	$Logger->criticalLog("Unable to reset, missing variables: " . print_r($_REQUEST, true));
	$response = array("status"=>"error", "error_type"=>"missing_variables");
} else {

	//logic
	$LeagueInviterManager = new LeagueInviterManager;
	if($LeagueInviterManager->resetLeague($_REQUEST['league_id'])){
		$Logger->serviceLog("reset", "Reset league_id " . $_REQUEST['league_id']);
		$response = array("status"=>"success");
	} else {
		$response = array("status"=>"error", "error_type"=>"db_failure");
		$Logger->criticalLog("Unable to reset league_id " . $_REQUEST['league_id'] . ", db_failure");
	}

}

echo json_encode($response);

?>