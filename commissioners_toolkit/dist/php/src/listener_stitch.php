<?
/**
 * Called by encoding.com when a stitch request has completed, successfully or not.
 * Write appropriate DB records.
 */

include "../includes.inc.php";
 
if((!isset($_REQUEST['xml'])) || ($_REQUEST['xml'] == "")){
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
				//yes -- initiate that request.
				$EncodingManager = new EncodingManager;
				$EncodingManager->sendFinalmerge($league_id);
			}
		} else {
			//db or other backend failure
			$LeagueInviterManager->indicateError($league_id);
		}
	} else {
		//failed encoding response - note the failure in the main league record
		$LeagueInviterManager->indicateError($league_id);	
		//...and in the encoding-error logfile
		//FIXFIX
	}
}

?>