<?

class LeagueInviterManager{

	var $LeagueinviterTable;
	var $leagueinviterMediaTable;
	var $error_type;

	/**
	 * Constructor.
	 */
	function LeagueInviterManager(){
		$this->LeagueinviterTable = new LeagueinviterTable;
		$this->LeagueinviterMediaTable = new LeagueinviterMediaTable;
		$this->EncodingManager = new EncodingManager;
		$this->CriticalErrorManager = new CriticalErrorManager;
		$this->Logger = new Logger;
	}

	/**
	 * Send status of leagueinviter record.
	 */
	function getStatus($league_id){
		if($status_array = $this->LeagueinviterTable->getByLeagueId($league_id)){
			$status_array['status'] = strtolower($status_array['status']);
			return $status_array;
		} else {
			$this->error_type = "db_failure";
			return false;
		}
	}

	/**
	 * Create a new leagueinviter record
	 */
	function createNewLeagueRecord($league_id, $user_profile_id, $league_name, $league_manager_name, $video_type){
		//check for dupe
		if($league_array = $this->LeagueinviterTable->getByLeagueId($league_id)){
			//error_log(print_r($league_array, true));
			if($league_array['status'] == "WAITING"){
			
				//if this is a failed or cancelled process, wipe and return true. otherwise, return false.
				if($this->isProcessing($league_id)){
					return true;
				} else {
					//error_log("RESETTING " . $league_id);
					//if we get here, finalmerge doesn't exist -- wipe everything so this person starts over
					$this->resetLeague($league_id);
					//$this->error_type = "duplicate_league_id";
					//return false;
					return true;
				}
			} else {
				return true;
			}
		}
		if($leagueinviter_id = $this->LeagueinviterTable->insert($league_id, $user_profile_id, $league_name, $league_manager_name, $video_type)){
			return true;
		} else {
			$this->error_type = "db_failure";
			return false;
		}
	}
	
	/**
	 * Determine status of this record
	 */
	function isProcessing($league_id){

		if($assets_array = $this->LeagueinviterMediaTable->getAssetsForMerge($league_id)){
			//does finalmerge exist?
			if(is_array($assets_array)){
				foreach($assets_array as $asset){
					if(($asset['media_type'] == "finalmerge") || ($asset['media_type'] == "finalpremade")){
						//waiting for encoding.com, so don't do anything.
						return true;
					}
				}
			}
		} else {
			return false;
		}
	}
	
	/**
	 * Write photo URL to db.
	 */
	function storeAndProcessPhoto($league_id, $photo_url){
		//write to db
		if($this->LeagueinviterMediaTable->insert($league_id, null, "photo_1", null, $photo_url)){
			return true;
		} else {
			$this->error_type = "db_failure";
			return false;
		}
	}
	
	/**
	 * Create a premade request.
	 */
	function storeAndProcessPremade($league_id, $video_id){
		if($new_media_id = $this->EncodingManager->sendPremade($league_id, $video_id)){
			//write to db
			if($this->LeagueinviterMediaTable->insert($league_id, $new_media_id, "finalpremade", false, false)){
				if($this->LeagueinviterTable->updateStatus($league_id, "WAITING")){
					$this->new_media_id = $new_media_id;
					return true;
				} else {
					$this->error_type = "db_failure";
					return false;
				}
			} else {
				$this->error_type = "db_failure";
				return false;
			}
			return true;
		} else {
			$this->error_type = "encoding_failure";
			return false;
		}
	}
	
	/**
	 * Write webcam video URL to db, and depending on how many of them we have,
	 * start a specific ECOM process.
	 */
	function storeAndProcessWebcamVideo($league_id, $media_id, $webcam_num, $length, $webcam_url){
	 	//write to db
	 	if($this->LeagueinviterMediaTable->insert($league_id, null, "raw_webcam_" . $webcam_num, $length, $webcam_url)){
		 	//send to ECOM, write new media_id to db
		 	if($webcam_num == "4"){
		 		//the raw vid is considered already stitched -- add to DB as stitch.
		 		if($this->LeagueinviterMediaTable->insert($league_id, null, "stitched_webcam_4", $length, $webcam_url)){
		 			//increment counter
		 			if($stitched_webcam_count = $this->LeagueinviterTable->incrementWebcamCountAndStatus($league_id)){
		 			
		 				//if we now have 6 videos, we have to trigger the finalmerge request here.
						if($stitched_webcam_count == "6"){
							//yes -- get all UGC assets and initiate the merge request.
							if($ugc_assets_array = $this->getUGCAssets($league_id)){
								$EncodingManager = new EncodingManager;
								if($finalmerge_media_id = $EncodingManager->sendFinalmerge($league_id, $ugc_assets_array)){
									if(!$this->addFinalmergePlaceholder($league_id, $finalmerge_media_id)){
										$this->CriticalErrorManager->handleError($league_id, $Logger->criticalLog("Webcam stitch listener is unable to write finalmerge placeholder record for league_id " . $league_id));
									} else {
										$this->Logger->serviceLog("listener_stitch", "Sent successful finalmerge request and wrote placeholder record for league_id " . $league_id . ", media_id " . $finalmerge_media_id);
									}
								} else {
									$this->CriticalErrorManager->handleError($league_id, $Logger->criticalLog("Webcam stitch listener is unable to send finalmerge request to encoding.com for league_id " . $league_id));
								}
							} else {
								$this->CriticalErrorManager->handleError($league_id, $Logger->criticalLog("Webcam stitch listener is unable to get UGC video assets for league_id " . $league_id));
							}
						}



		 			
			 			$this->new_media_id = "N/A";
			 			return true;
			 		} else {
			 			//unable to write to db
			 			$this->error_type = "db_failure";
			 			return false;
			 		}
		 		} else {
		 			//unable to write to db
		 			$this->error_type = "db_failure";
		 			return false;
		 		}		 		
		 	} else {
				//everything but #4 gets stitched
			 	if($new_media_id = $this->EncodingManager->sendWebcam($league_id, $webcam_num, $webcam_url)){
			 		//write to db
			 		if($this->LeagueinviterMediaTable->insert($league_id, $new_media_id, "stitched_webcam_" . $webcam_num, false)){
						$this->new_media_id = $new_media_id;
			 			return true;
			 		} else {
			 			//unable to write to db
			 			$this->error_type = "db_failure";
			 			return false;
			 		}
			 	} else {
			 		//received error response from encoding.com
			 		$this->error_type = "encoding_failure";
			 		return false;
			 	}
		 	
		 	}
	 	} else {
	 		//unable to write to db
	 		$this->error_type = "db_failure";
	 		return false;
	 	}
	 	
	 }

	/**
	 * Get all UGC assets
	 */
	function getUGCAssets($league_id){
		if($ugc_assets_array = $this->LeagueinviterMediaTable->getAssetsForMerge($league_id)){
			return $ugc_assets_array;
		} else {
			//something went terribly wrong FIXFIX
			$this->error_type = "db_failure";
			return false;
		}
	}

	/**
	 * Get and return a league_id based on a media_id
	 */
	function getLeagueIdFromMediaId($media_id){
		return $this->LeagueinviterMediaTable->getLeagueIdByMediaId($media_id);
	}

	/**
	 * Add a successfully-stitched webcam video to the DB and increment counter.
	 */
	function addStitchedWebcamVideo($league_id, $media_id, $stitched_webcam_url){
		if($this->LeagueinviterMediaTable->updateURL($league_id, $media_id, $stitched_webcam_url)){
			//increment counter and return the new counter number
			if($new_count = $this->LeagueinviterTable->incrementWebcamCountAndStatus($league_id)){
				return $new_count;
			} else {
				//unable to write to db
				return false;
			}
		} else {
			//unable to write to db
			return false;
		}
	}
	
	/**
	 * Add a placeholder for the final merged video
	 */
	function addFinalmergePlaceholder($league_id, $media_id){
		if($this->LeagueinviterMediaTable->insert($league_id, $media_id, "finalmerge")){
			return true;
		} else {
			return false;
		}
	}
	
	/**
	 * Update DB with URL of final video, trigger auto emails, etc.
	 */
	function storeAndProcessFinalmergeVideo($league_id, $media_id, $finalmerge_urls){
		//update media record with S3 URL (just in case...)
		if($this->LeagueinviterMediaTable->updateURL($league_id, $media_id, $finalmerge_urls['s3_url'])){
			//update leagueinviter record with both S3 and youtube URLs, change status, trigger email
			if($this->LeagueinviterTable->updateWithFinalmerge($league_id, $finalmerge_urls['youtube_url'], UTIL_parseYoutubeId($finalmerge_urls['youtube_url']), $finalmerge_urls['s3_url'])){
				$league_array = $this->LeagueinviterTable->getByLeagueId($league_id);
				//increment bucket count
				$YoutubeManager = new YoutubeManager;
				$YoutubeManager->addToBucket($league_array['youtube_bucket_id']);
				//send email
				$ESPNEmail = new ESPNEmail;
				$ESPNEmail->sendVideoReady($league_id, $league_array['user_profile_id'], $league_array['league_manager_name'], $league_array['youtube_url']);
				//wipe all media records
				$this->LeagueinviterMediaTable->deleteByLeagueId($league_id);
				return true;
			} else {
				return false;
			}
		} else {
			return false;
		}		
	}
	
	
	/**
	 * Update DB with URL of final premade video, trigger auto emails, etc.
	 */
	function storeAndProcessFinalpremadeVideo($league_id, $media_id, $finalmerge_urls){
		//update media record with S3 URL (just in case...)
		if($this->LeagueinviterMediaTable->updateURL($league_id, $media_id, $finalmerge_urls['s3_url'])){
			//update leagueinviter record with both S3 and youtube URLs, change status, trigger email
			if($this->LeagueinviterTable->updateWithFinalpremade($league_id, $finalmerge_urls['youtube_url'], UTIL_parseYoutubeId($finalmerge_urls['youtube_url']), $finalmerge_urls['s3_url'])){
				$league_array = $this->LeagueinviterTable->getByLeagueId($league_id);
				//increment bucket count
				$YoutubeManager = new YoutubeManager;
				$YoutubeManager->addToBucket($league_array['youtube_bucket_id']);
				//SEND EMAIL				
				$ESPNEmail = new ESPNEmail;
				$ESPNEmail->sendVideoReady($league_id, $league_array['user_profile_id'], $league_array['league_manager_name'], $league_array['youtube_url']);
				//wipe all media records
				$this->LeagueinviterMediaTable->deleteByLeagueId($league_id);
				return true;
			} else {
				return false;
			}
		} else {
			return false;
		}		
	}	
	
	
	/**
	 * Something went wrong badly enough to completely fuck up this user's video -- change the league video status to error.
	 */
	function indicateError($league_id){
		$this->LeagueinviterTable->updateStatus($league_id, "ERROR");
	}
	
	/**
	 * Remove all league-specific records
	 */
	function resetLeague($league_id){
		if($this->LeagueinviterMediaTable->deleteByLeagueId($league_id)){
			//is there a youtube video already? if so, delete it from YT.
			$league_array = $this->LeagueinviterTable->getByLeagueId($league_id);
			if($league_array['youtube_id'] != ""){
				$YoutubeManager = new YoutubeManager;
				$YoutubeManager->deleteVideo($league_id, $league_array['youtube_bucket_id'], $league_array['youtube_id']);
			}
			if($this->LeagueinviterTable->delete($league_id)){
				return true;
			} else {
				return false;
			}
		} else {
			return false;
		}
	}



}

?>