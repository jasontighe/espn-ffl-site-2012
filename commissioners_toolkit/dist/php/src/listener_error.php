<?
/**
 * Called by encoding.com when a stitch request has exploded.
 */

include "../includes.inc.php";
 
if((!isset($_REQUEST['xml'])) || ($_REQUEST['xml'] == "")){
	die;
} else {	
	//encoding.com has failed in some way.
	$EncodingResponseManager = new EncodingResponseManager(stripslashes($_REQUEST['xml']));
	$EncodingResponseManager->errorResponse();

	//get league_id based on this media_id
	$LeagueInviterManager = new LeagueInviterManager;
	$league_id = $LeagueInviterManager->getLeagueIdFromMediaId($EncodingResponseManager->media_id);

	//error out
	$LeagueInviterManager->indicateError($league_id);

}

?>