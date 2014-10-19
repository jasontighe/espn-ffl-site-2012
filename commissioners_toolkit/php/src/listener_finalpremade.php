<?
/**
 * Called by encoding.com when the finalpremade request has completed, successfully or not.
 * Write appropriate DB records.
 */

include "../includes.inc.php";
 
if((!isset($_REQUEST['xml'])) || ($_REQUEST['xml'] == "")){
	$Logger->criticalLog("Finalpremade listener received empty XML POST request: " . print_r($_REQUEST, true));
	die;
} else {
	$LeagueInviterManager = new LeagueInviterManager;
	//we have a response from encoding. 
	$EncodingResponseManager = new EncodingResponseManager(stripslashes($_REQUEST['xml']));
	if($EncodingResponseManager->finalpremadeResponse()){
		//get league_id based on this media_id
		$LeagueInviterManager = new LeagueInviterManager;
		$league_id = $LeagueInviterManager->getLeagueIdFromMediaId($EncodingResponseManager->media_id);
		//successful encoding response - update final URLs, remove media records, update status
		if(!$LeagueInviterManager->storeAndProcessFinalpremadeVideo($league_id, $EncodingResponseManager->media_id, $EncodingResponseManager->finalmerge_urls)){
			//db or other backend failure
			$CriticalErrorManager->handleError($league_id, $Logger->criticalLog("Finalpremade listener unable to store and process finalpremade video, media_id " . $EncodingResponseManager->media_id . " for league_id " . $league_id . " " . print_r($EncodingResponseManager->finalmerge_urls, true)));
		} else {
			$Logger->serviceLog("listener_finalpremade", "Received finalpremade video for league_id " . $league_id);
		}
	} else {
		//failed encoding response - note the failure in the main league record
		$CriticalErrorManager->handleError(false, $Logger->criticalLog("Finalpremade listener received error inside encoding.com XML POST request"));
	}
}

?>