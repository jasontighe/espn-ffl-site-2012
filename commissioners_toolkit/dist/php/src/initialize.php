<?
/**
 * Called by Flash when a user begins the LI creation process, INITIALIZE sets up a record for this league id
 */

include "../includes.inc.php";

//required arguments
if((!isset($_REQUEST['league_id'])) || ($_REQUEST['league_id'] == "") || (!isset($_REQUEST['league_name'])) || ($_REQUEST['league_name'] == "") || (!isset($_REQUEST['league_manager_name'])) || ($_REQUEST['league_manager_name'] == "")){
	$response = array("status"=>"error", "error_type"=>"missing_variables");
} else {
	
	//logic
	$LeagueInviterManager = new LeagueInviterManager;
	if($LeagueInviterManager->createNewLeagueRecord($_REQUEST['league_id'], $_REQUEST['league_name'], $_REQUEST['league_manager_name'])){
		$response = array("status"=>"success");
	} else {
		$response = array("status"=>"error", "error_type"=>$LeagueInviterManager->error_type);
	}

}

echo json_encode($response);

?>