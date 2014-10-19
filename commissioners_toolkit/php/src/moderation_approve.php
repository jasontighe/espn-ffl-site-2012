<?
/**
 * Process an approve request from the moderation tool -- mark video as approved, make YT video public
 */

include "../includes.inc.php";

//required arguments
if((!isset($_REQUEST['league_id'])) || ($_REQUEST['league_id'] == "")){
	$Logger->criticalLog("Unable to approve video, missing variables: " . print_r($_REQUEST, true));
	$response = array("status"=>"error", "error_type"=>"missing_variables");
} else {
	//logic
	$ModerationManager = new ModerationManager;
	if($ModerationManager->approve($_REQUEST['league_id'])){
		$Logger->serviceLog("moderation_approve", "Approved video for league_id " . $_REQUEST['league_id']);
		$response = array("status"=>"success");
	} else {
		$CriticalErrorManager->handleError($_REQUEST['league_id'], $Logger->criticalLog("Unable to approve video for league_id " . $_REQUEST['league_id'] . ", " . $ModerationManager->error_type));
		$response = array("status"=>"error", "error_type"=>$ModerationManager->error_type);
	}
}

echo "callbackApprove(" . json_encode($response) . ")";
 
?>