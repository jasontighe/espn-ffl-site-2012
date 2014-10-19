<?

class LeagueInviterManager{

	var $LeagueinviterTable;
	var $leagueinviterMediaTable;
	var $error_type;

	function LeagueInviterManager(){
		$this->LeagueinviterTable = new LeagueinviterTable;
		$this->LeagueinviterMediaTable = new LeagueinviterMediaTable;
		$this->EncodingManager = new EncodingManager;
	}

	/**
	 * Send status of leagueinviter record
	 */
	function getStatus($league_id){
		return $this->LeagueinviterTable->getByLeagueId($league_id);
	}

	/**
	 * Create a new leagueinviter record
	 */
	function createNewLeagueRecord($league_id, $league_name, $league_manager_name){
		//check for dupe
		if($this->LeagueinviterTable->getByLeagueId($league_id)){
			$this->error_type = "duplicate_league_id";
			return false;
		}
		if($leagueinviter_id = $this->LeagueinviterTable->insert($league_id, $league_name, $league_manager_name)){
			return true;
		} else {
			$this->error_type = "db_failure";
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
		 		if($this->LeagueinviterMediaTable->insert($league_id, null, "stitched_webcam_4", $webcam_url)){
		 			//increment counter
		 			$this->LeagueinviterTable->incrementWebcamCountAndStatus($league_id);
		 			return true;
		 		} else {
		 			//unable to write to db
		 			$this->error_type = "db_failure";
		 			return false;
		 		}		 		
		 	} else {
				//everything but #4 gets stitched
			 	if($new_media_id = $this->EncodingManager->sendWebcam($webcam_num, $webcam_url)){
			 		//write to db
			 		if($this->LeagueinviterMediaTable->insert($league_id, $new_media_id, "stitched_webcam_" . $webcam_num, false)){
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