<?
/**
 * Called by Flash each time a user records a webcam video, this service logs the encoded 
 * webcam video and runs additional services for ECOM communication as necessary.
*/

include "../includes.inc.php";

//required arguments
if((!isset($_REQUEST['league_id'])) || ($_REQUEST['league_id'] == "") || (!isset($_REQUEST['webcam_num'])) || ($_REQUEST['webcam_num'] == "") || (!isset($_REQUEST['length'])) || ($_REQUEST['length'] == "")){
	$response = array("status"=>"error", "error_type"=>"missing_variables");
} else {

	//logic
	$LeagueInviterManager = new LeagueInviterManager;
	if($LeagueInviterManager->storeAndProcessWebcamVideo($_REQUEST['league_id'], null, $_REQUEST['webcam_num'], $_REQUEST['length'], $_REQUEST['webcam_url'])){
		$response = array("status"=>"success");
	} else {
		$response = array("status"=>"error", "error_type"=>$LeagueInviterManager->error_type);	
	}

}

echo json_encode($response);

?>