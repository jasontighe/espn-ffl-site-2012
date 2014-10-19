<?
/**
 * Manages all moderation tasks -- showing items in the moderation queue, ignoring/rejecting items, etc.
 */
class ModerationManager{

	var $LeagueinviterTable;

	/**
	 * Constructor
	 */
	function ModerationManager(){
		$this->LeagueinviterTable = new LeagueinviterTable;
		$this->LeagueinviterRejectTable = new LeagueinviterRejectTable;
		$this->YoutubeManager = new YoutubeManager;

	}

	/** 
	 * Get all totals 
	 */
	function getAllTotals(){
		$arr['unmoderated'] = $this->getUnmoderatedTotal();
		$arr['approved'] = $this->getApprovedTotal();
		$arr['rejected'] = $this->getRejectedTotal();
		$arr['ignored'] = $this->getIgnoredTotal();
		return $arr;
	}

	/**
	 * Get videos that haven't been ignored or rejected
	 */
	function getUnmoderated($sort, $dir, $page){
		switch($sort){
			case "date":
				$order_by = "date_video_created";
				break;
			case "leaguename":
				$order_by = "league_name";
				break;
			}
		return $this->LeagueinviterTable->getUnmoderatedChunk($order_by, $dir, $page);
	}
	
	/**
	 * Get total count of unmoderated videos
	 */
	function getUnmoderatedTotal(){
		return $this->LeagueinviterTable->getUnmoderatedTotal();
	}

	/**
	 * Get videos that have been approved
	 */
	function getApproved($sort, $dir, $page){
		switch($sort){
			case "date":
				$order_by = "date_video_created";
				break;
			case "leaguename":
				$order_by = "league_name";
				break;
			}
		return $this->LeagueinviterTable->getApprovedChunk($order_by, $dir, $page);
	}

	/**
	 * Get total count of approved videos
	 */
	function getApprovedTotal(){
		return $this->LeagueinviterTable->getApprovedTotal();
	}

	/**
	 * Get videos that have been ignored
	 */
	function getIgnored($sort, $dir, $page){
		switch($sort){
			case "date":
				$order_by = "date_video_created";
				break;
			case "leaguename":
				$order_by = "league_name";
				break;
			}
		return $this->LeagueinviterTable->getIgnoredChunk($order_by, $dir, $page);
	}

	/**
	 * Get total count of ignored videos
	 */
	function getIgnoredTotal(){
		return $this->LeagueinviterTable->getIgnoredTotal();
	}

	/**
	 * Get videos that have been rejected
	 */
	function getRejected($page){
		return $this->LeagueinviterRejectTable->getChunk($page);
	}

	
	/**
	 * Get total count of unmoderated videos
	 */
	function getRejectedTotal(){
		return $this->LeagueinviterRejectTable->getTotal();
	}

	/**
	 * Mark video as approved.
	 */
	function approve($league_id){
		$league_array = $this->LeagueinviterTable->getByLeagueId($league_id);
		if($league_array['video_type'] == "1"){
		
			if($this->YoutubeManager->makeVideoPublic($league_id, $league_array['youtube_bucket_id'], $league_array['youtube_id'])){
				if($this->LeagueinviterTable->approve($league_id)){
					return true;
				} else {
					$this->error_type = "db_failure";
					return false;
				}
			} else {
				$this->error_type = "youtube_failure";
				return false;
			}
		} else {
			if($this->LeagueinviterTable->approve($league_id)){
				return true;
			} else {
				$this->error_type = "db_failure";
				return false;
			}
		}
	}

	/**
	 * Mark video as ignored.
	 */
	function ignore($league_id){
		if($this->LeagueinviterTable->ignore($league_id)){
			return true;
		} else {
			$this->error_type = "db_failure";
			return false;
		}
	}
	
	/**
	 * Mark video as rejected, send email, delete from youtube. etc.
	 */
	function reject($league_id){
		$league_id = trim($league_id);
		$league_array = $this->LeagueinviterTable->getByLeagueId($league_id);
		$thumb_filename = $league_array['leagueinviter_id'] . "_" . $league_array['league_id'] . ".jpg";
				
		//get and save thumbnail, renaming with league id
		if(file_put_contents(REJECTED_THUMB_LOC . $thumb_filename, file_get_contents("http://img.youtube.com/vi/" . $league_array['youtube_id'] . "/0.jpg"))){
			//remove from YT
			if($this->YoutubeManager->deleteVideo($league_id, $league_array['youtube_bucket_id'], $league_array['youtube_id'])){
				//mark as rejected in LI record
				if($this->LeagueinviterTable->reject($league_id)){
					//copy data into rejected table
					if($this->LeagueinviterRejectTable->insert($league_id, $league_array['league_name'], $league_array['league_manager_name'], $thumb_filename, $league_array['s3_url'])){
						//trigger espn email
						$ESPNEmail = new ESPNEmail;
						if($ESPNEmail->sendVideoDeleted($league_id, $league_array['user_profile_id'], $league_array['league_manager_name'])){
							return true;
						} else {
							$this->error_type = "espnemail_failure";
							return false;
						}
					} else {
						$this->error_type = "db_failure";
						return false;
					}
				} else {
					$this->error_type = "db_failure";
					return false;
				}
			} else {
				$this->error_type = "youtube_failure";
				return false;
			}
		}
		
	}

	/**
	 * Parse YT URLs and create a value for the YT ID
	 */
	function _getYoutubeIds($arr){
		if(is_array($arr)){
			foreach($arr as $key => $subarray){
				parse_str($subarray['youtube_url'], $parsed);
				$arr[$key]['youtube_id'] = $parsed['http://www_youtube_com/watch?v'];
			}
		}
		return $arr;
	}


	/**
	 * Parse single YT URL and create a value for the YT ID
	 */
	function _getYoutubeId($str){
		parse_str($str, $parsed);
		return $parsed['http://www_youtube_com/watch?v'];
	}

	/**
	 * Embarrasingly enough, I'm not sure. Could be deprecated but I don't have time to check.
	 */
	function getQueueCount(){
		return $this->LeagueinviterTable->getFinishedCount();
	}

}
?>