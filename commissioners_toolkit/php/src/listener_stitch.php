<?
/**
 * Called by encoding.com when a stitch request has completed, successfully or not.
 * Write appropriate DB records.
 */

include "../includes.inc.php";
 
if((!isset($_REQUEST['xml'])) || ($_REQUEST['xml'] == "")){
	$Logger->criticalLog("Webcam stitch listener received empty XML POST request: " . print_r($_REQUEST, true));
	die;
} else {
	//we have a response from encoding. 
	$EncodingResponseManager = new EncodingResponseManager(stripslashes($_REQUEST['xml']));
	if($EncodingResponseManager->stitchResponse()){
		//get league_id based on this media_id
		$LeagueInviterManager = new LeagueInviterManager;
		$league_id = $LeagueInviterManager->getLeagueIdFromMediaId($EncodingResponseManager->media_id);
		//successful encoding response - update stitched webcam URL inside leagueinviter_media and increment counter
		if($stitched_webcam_count = $LeagueInviterManager->addStitchedWebcamVideo($league_id, $EncodingResponseManager->media_id, $EncodingResponseManager->stitched_webcam_url)){
			//do we have 6 webcam videos stitched and ready to be merged?
			if($stitched_webcam_count == "6"){
				//yes -- get all UGC assets and initiate the merge request.
				if($ugc_assets_array = $LeagueInviterManager->getUGCAssets($league_id)){
					$EncodingManager = new EncodingManager;
					if($media_id = $EncodingManager->sendFinalmerge($league_id, $ugc_assets_array)){
						if(!$LeagueInviterManager->addFinalmergePlaceholder($league_id, $media_id)){
							$CriticalErrorManager->handleError($league_id, $Logger->criticalLog("Webcam stitch listener is unable to write finalmerge placeholder record for league_id " . $league_id));
						} else {
							$Logger->serviceLog("listener_stitch", "Sent successful finalmerge request and wrote placeholder record for league_id " . $league_id . ", media_id " . $media_id);
						}
					} else {
						$CriticalErrorManager->handleError($league_id, $Logger->criticalLog("Webcam stitch listener is unable to send finalmerge request to encoding.com for league_id " . $league_id));
					}
				} else {
					$CriticalErrorManager->handleError($league_id, $Logger->criticalLog("Webcam stitch listener is unable to get UGC video assets for league_id " . $league_id));
				}
			} else {
				$Logger->serviceLog("listener_stitch", "Added stitched webcam video " . $stitched_webcam_count . " at " . $EncodingResponseManager->stitched_webcam_url . " for league_id " . $league_id . ", media_id " . $EncodingResponseManager->media_id);
			}
		} else {
			//db or other backend failure
			$CriticalErrorManager->handleError($league_id, $Logger->criticalLog("Webcam stitch listener is unable to store stitched webcam video at " . $EncodingResponseManager->stitched_webcam_url . " with media_id " . $EncodingResponseManager->media_id . "for league_id " . $league_id));
		}
	} else {
		//failed encoding response - note the failure in the main league record
		$CriticalErrorManager->handleError(false, $Logger->criticalLog("Webcam stitch listener received error inside encoding.com XML POST request"));
	}
}

?>