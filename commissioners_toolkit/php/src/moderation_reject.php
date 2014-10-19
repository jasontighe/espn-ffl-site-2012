<?
/**
 * Process an reject request from the moderation tool -- remove from youtube, email user, etc.
 */

include "../includes.inc.php";

//required arguments
if((!isset($_REQUEST['league_id'])) || ($_REQUEST['league_id'] == "")){
	$Logger->criticalLog("Unable to reject video, missing variables: " . print_r($_REQUEST, true));
	$response = array("status"=>"error", "error_type"=>"missing_variables");
} else {
	//logic
	$ModerationManager = new ModerationManager;
	if($ModerationManager->reject($_REQUEST['league_id'])){
		$Logger->serviceLog("moderation_approve", "Rejected video for league_id " . $_REQUEST['league_id']);
		$response = array("status"=>"success");
	} else {
		$CriticalErrorManager->handleError($_REQUEST['league_id'], $Logger->criticalLog("Unable to reject video for league_id " . $_REQUEST['league_id'] . ", " . $ModerationManager->error_type));
		$response = array("status"=>"error", "error_type"=>$ModerationManager->error_type);
	}
}

echo "callbackReject(" . json_encode($response) . ")";
 
?>