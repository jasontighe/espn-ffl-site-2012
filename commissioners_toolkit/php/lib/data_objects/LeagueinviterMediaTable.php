<?

class LeagueinviterMediaTable{

	var $DB;
	var $result_array;
	
	function LeagueinviterMediaTable(){
		$this->DB = new DB;
		$this->result_array[0] = "leagueinviter_media_id";
		$this->result_array[1] = "league_id";
		$this->result_array[2] = "media_id";
		$this->result_array[3] = "media_type";
		$this->result_array[4] = "url";
		$this->duration_result_array[0] = "total_duration";
		$this->length_result_array[0] = "media_length";

	}
	
	/**
	 * Insert new media record
	 */
	function insert($league_id, $media_id, $media_type, $media_length=false, $url=false){
		if($url){
			$query = 
				"INSERT INTO leagueinviter_media (league_id, media_id, media_type, media_length, url) VALUES ('$league_id', '$media_id', '$media_type', '$media_length', '$url')";
		} else {
			$query = 
				"INSERT INTO leagueinviter_media (league_id, media_id, media_type) VALUES ('$league_id', '$media_id', '$media_type')";		
		}		
		return $this->DB->query($query);
	}
	
	/**
	 * Get LeagueID based on MediaID. Assumes there's at least one record that has both.
	 */
	function getLeagueIdByMediaId($media_id){
		$query = 
			"SELECT * FROM leagueinviter_media WHERE media_id = '$media_id' LIMIT 0, 1";
	    $this->DB->query($query);
	    $results = $this->DB->getResultArray($this->result_array);
	    return $results[0]['league_id'];
	}

	/**
	 * Get photo assets for merging.
	 */
	function getPhotoAssetsForMerge($league_id){
		$query = 
			"SELECT * FROM leagueinviter_media WHERE league_id = '$league_id' AND media_type = 'photo_1'";
	    $this->DB->query($query);
	    $results = $this->DB->getResultArray($this->result_array);
	    return $results[0];
	}
	
	/**
	 * Get all assets for merging.
	 */
	function getAssetsForMerge($league_id){
		$query = 
			"SELECT * FROM leagueinviter_media WHERE league_id = '$league_id'";
	    $this->DB->query($query);
	    return $this->DB->getResultArray($this->result_array);
	}
	
	/**
	 * Get sum of lengths
	 */
	function getRawDuration($league_id){
		$query = 
			"SELECT SUM(media_length) AS total_duration FROM leagueinviter_media WHERE league_id = '$league_id' AND media_length IS NOT NULL";
	    $this->DB->query($query);
	    $results = $this->DB->getResultArray($this->duration_result_array);
	    return $results[0]['total_duration'];
	}
	
	/**
	 * Get length of specific video based on mediatype
	 */
	function getMediaLengthByMediaType($league_id, $media_type){
		$query = 
			"SELECT media_length FROM leagueinviter_media WHERE league_id = '$league_id' AND media_type = 'raw_webcam_1'";
	    $this->DB->query($query);
	    $results = $this->DB->getResultArray($this->length_result_array);
	    return $results[0]['media_length'];
	}

	function updateURL($league_id, $media_id, $url){
		$query = 
			"UPDATE leagueinviter_media SET url = '$url' WHERE league_id = '$league_id' AND media_id = '$media_id'";
		return $this->DB->query($query);
	}
	
	function deleteByLeagueId($league_id){
		$query = 
			"DELETE FROM leagueinviter_media WHERE league_id = '$league_id'";
		return $this->DB->query($query);
	}

}

?>