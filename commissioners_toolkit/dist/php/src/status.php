<?
/**
 * Called by Flash whenever it needs a status of this league's video.
*/

include "../includes.inc.php";

//required arguments
if((!isset($_REQUEST['league_id'])) || ($_REQUEST['league_id'] == "")){
	$response = array("status"=>"error", "error_type"=>"missing_variables");
} else {

	//logic
	$LeagueInviterManager = new LeagueInviterManager;
	if($status = $LeagueInviterManager->getStatus($_REQUEST['league_id'])){
		$response = array("status"=>"success", "details"=>$status);
	} else {
		$response = array("status"=>"error", "error_type"=>"db_failure");	
	}

}

echo json_encode($response);

?>