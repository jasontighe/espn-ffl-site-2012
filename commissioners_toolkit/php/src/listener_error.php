<?
/**
 * Called by encoding.com when a stitch request has exploded.
 */

include "../includes.inc.php";
 
if((!isset($_REQUEST['xml'])) || ($_REQUEST['xml'] == "")){
	$Logger->criticalLog("Encoding.com error listener received empty XML POST request: " . print_r($_REQUEST, true));
	die;
} else {	
	//encoding.com has failed in some way.
	$EncodingResponseManager = new EncodingResponseManager(stripslashes($_REQUEST['xml']));
	$EncodingResponseManager->errorResponse();

	//get league_id based on this media_id
	$LeagueInviterManager = new LeagueInviterManager;
	$league_id = $LeagueInviterManager->getLeagueIdFromMediaId($EncodingResponseManager->media_id);

	//error out
	$CriticalErrorManager->handleError($league_id, $Logger->criticalLog("Encoding.com error listener received error message in a XML POST request from encoding.com for league_id " . $league_id));

}

?>