<?
class LeagueinviterTable{

	var $DB;
	var $result_array;
	
	function LeagueinviterTable(){
		$this->DB = new DB;
		$this->result_array[0] = "leagueinviter_id";
		$this->result_array[1] = "league_id";
		$this->result_array[2] = "user_profile_id";
		$this->result_array[3] = "league_name";
		$this->result_array[4] = "league_manager_name";
		$this->result_array[5] = "webcam_count";
		$this->result_array[6] = "youtube_url";
		$this->result_array[7] = "youtube_id";
		$this->result_array[8] = "s3_url";
		$this->result_array[9] = "status";
		$this->result_array[10] = "moderation_status";
		$this->result_array[11] = "youtube_public";
		$this->result_array[12] = "youtube_bucket_id";		
		$this->result_array[13] = "video_type";
		$this->result_array[14] = "date_created";
		$this->result_array[15] = "date_video_created";
		$this->unmoderated_result_array[0] = "unmoderated_count";
		$this->ignored_result_array[0] = "ignored_count";
	}

	function statsVisitors(){
		$query = 
			"SELECT COUNT(leagueinviter_id) AS video_created_count FROM leagueinviter";
		$this->DB->query($query);
		$result_array = $this->DB->getResultArray(array("video_created_count"));
		return $result_array[0]['video_created_count'];
	}
	
	function statsVideosCreated(){
		$query = 
			"SELECT COUNT(leagueinviter_id) AS video_created_count FROM leagueinviter WHERE youtube_url IS NOT NULL";
		$this->DB->query($query);
		$result_array = $this->DB->getResultArray(array("video_created_count"));
		return $result_array[0]['video_created_count'];
	}

	function statsPersonalizedVideos(){
		$query = 
			"SELECT COUNT(leagueinviter_id) AS video_created_count FROM leagueinviter WHERE youtube_url IS NOT NULL AND video_type = 1";
		$this->DB->query($query);
		$result_array = $this->DB->getResultArray(array("video_created_count"));
		return $result_array[0]['video_created_count'];
	}

	function statsPremadeVideos(){
		$query = 
			"SELECT COUNT(leagueinviter_id) AS video_created_count FROM leagueinviter WHERE youtube_url IS NOT NULL AND video_type = 2";
		$this->DB->query($query);
		$result_array = $this->DB->getResultArray(array("video_created_count"));
		return $result_array[0]['video_created_count'];
	}

	function statsVideosApproved(){
		$query = 
			"SELECT COUNT(leagueinviter_id) AS video_created_count FROM leagueinviter WHERE youtube_url IS NOT NULL AND youtube_public = 1";
		$this->DB->query($query);
		$result_array = $this->DB->getResultArray(array("video_created_count"));
		return $result_array[0]['video_created_count'];
	}

	function statsVideosIgnored(){
		$query = 
			"SELECT COUNT(leagueinviter_id) AS video_created_count FROM leagueinviter WHERE youtube_url IS NOT NULL AND moderation_status = 1 AND youtube_public = 0";
		$this->DB->query($query);
		$result_array = $this->DB->getResultArray(array("video_created_count"));
		return $result_array[0]['video_created_count'];
	}
	
	function getUnmoderatedChunk($sort_by, $dir, $page){
		$max = 'limit ' . ($page - 1) * MODERATION_PER_PAGE .',' . MODERATION_PER_PAGE;
		$query = 
			"SELECT * FROM leagueinviter WHERE moderation_status IS NULL AND youtube_url IS NOT NULL ORDER BY $sort_by $dir " . $max;
		$this->DB->query($query);
		return $this->DB->getResultArray($this->result_array);
	}
	
	function getUnmoderatedTotal(){
		$query = "SELECT COUNT(*) AS unmoderated_count FROM leagueinviter WHERE moderation_status IS NULL AND youtube_url IS NOT NULL";
		$this->DB->query($query);
	    $results = $this->DB->getResultArray($this->unmoderated_result_array);
	    $count = $results[0]['unmoderated_count'];
	    if(!$count){
	    	$count = "0";
	    }
	    return $count;
	}

	function getApprovedChunk($sort_by, $dir, $page){
		$max = 'limit ' . ($page - 1) * MODERATION_PER_PAGE .',' . MODERATION_PER_PAGE;
		$query = 
			"SELECT * FROM leagueinviter WHERE moderation_status = '1' ORDER BY $sort_by $dir " . $max;
		$this->DB->query($query);
		return $this->DB->getResultArray($this->result_array);
	}
	
	function getApprovedTotal(){
		$query = "SELECT COUNT(*) AS ignored_count FROM leagueinviter WHERE moderation_status = '1'";
		$this->DB->query($query);
	    $results = $this->DB->getResultArray($this->ignored_result_array);
	    $count = $results[0]['ignored_count'];
	    if(!$count){
	    	$count = "0";
	    }
	    return $count;
	}


	function getIgnoredChunk($sort_by, $dir, $page){
		$max = 'limit ' . ($page - 1) * MODERATION_PER_PAGE .',' . MODERATION_PER_PAGE;
		$query = 
			"SELECT * FROM leagueinviter WHERE youtube_url IS NOT NULL and moderation_status = '1' AND youtube_public = 0 ORDER BY $sort_by $dir " . $max;
		$this->DB->query($query);
		return $this->DB->getResultArray($this->result_array);
	}
	
	function getignoredTotal(){
		$query = "SELECT COUNT(*) AS ignored_count FROM leagueinviter WHERE youtube_url IS NOT NULL and moderation_status = '1' AND youtube_public = 0";
		$this->DB->query($query);
	    $results = $this->DB->getResultArray($this->ignored_result_array);
	    $count = $results[0]['ignored_count'];
	    if(!$count){
	    	$count = "0";
	    }
	    return $count;
	}
		
	function getByLeagueId($league_id){
		$query = 
			"SELECT * FROM leagueinviter WHERE league_id = '$league_id'";
		$this->DB->query($query);
	    $results = $this->DB->getResultArray($this->result_array);
	    return $results[0];
	}
	
	function insert($league_id, $user_profile_id, $league_name, $league_manager_name, $video_type){
		$league_name = addslashes($league_name);
		$league_manager_name = addslashes($league_manager_name);
		$query = 
			"INSERT INTO leagueinviter (league_id, user_profile_id, league_name, league_manager_name, video_type) VALUES ('$league_id', '$user_profile_id', '$league_name', '$league_manager_name', '$video_type')";
	    $this->DB->query($query);
	    return $this->DB->last_id();
	}
	
	function incrementWebcamCountAndStatus($league_id){
		//increment count
		$query = 
			"UPDATE leagueinviter SET webcam_count = webcam_count+1, status='WAITING' WHERE league_id = '$league_id'";
		$this->DB->query($query);
		//get new count
		$query = 
			"SELECT * FROM leagueinviter WHERE league_id = '$league_id'";
		$this->DB->query($query);
	    $results = $this->DB->getResultArray($this->result_array);
		return $results[0]['webcam_count'];
	}
	
	function approve($league_id){
		$query = 
			"UPDATE leagueinviter SET moderation_status = '1', youtube_public = '1' WHERE league_id = '$league_id'";
		return $this->DB->query($query);
	}

	function ignore($league_id){
		$query = 
			"UPDATE leagueinviter SET moderation_status = '1', youtube_public = '0' WHERE league_id = '$league_id'";
		return $this->DB->query($query);
	}
	
	function reject($league_id){
		$query = 
			"UPDATE leagueinviter SET status = 'DELETED', youtube_url = NULL, moderation_status = NULL, youtube_public = NULL, youtube_bucket_id = NULL, youtube_id = NULL, s3_url = NULL, date_video_created = NULL WHERE league_id = '$league_id'";
		return $this->DB->query($query);
	}
	
	function updateYoutubeURL($league_id, $youtube_url, $youtube_id){
		$query = 
			"UPDATE leagueinviter SET youtube_url = '$youtube_url', youtube_id = '$youtube_id' WHERE league_id = '$league_id'";
		return $this->DB->query($query);
	}
	
	function updateYoutubeBucketId($league_id, $youtube_bucket_id){
		$query = 
			"UPDATE leagueinviter SET youtube_bucket_id = '$youtube_bucket_id' WHERE league_id = '$league_id'";
		return $this->DB->query($query);
	}
	
	function updateWithFinalmerge($league_id, $youtube_url, $youtube_id, $s3_url){
		$date = date("Y-m-d H:i:s");
		$query = 
			"UPDATE leagueinviter SET youtube_url = '$youtube_url', youtube_id = '$youtube_id', s3_url = '$s3_url', status = 'CREATED', date_video_created = '$date' WHERE league_id = '$league_id'";
		return $this->DB->query($query);
	}

	function updateWithFinalpremade($league_id, $youtube_url, $youtube_id, $s3_url){
		$date = date("Y-m-d H:i:s");
		$query = 
			"UPDATE leagueinviter SET youtube_url = '$youtube_url', youtube_id = '$youtube_id', s3_url = '$s3_url', status = 'CREATED', date_video_created = '$date' WHERE league_id = '$league_id'";
		return $this->DB->query($query);
	}
	
	function updateStatus($league_id, $status){
		$query = 
			"UPDATE leagueinviter SET status = '$status' WHERE league_id = '$league_id'";
		return $this->DB->query($query);
	}

	function delete($league_id){
		$query = 
			"DELETE FROM leagueinviter WHERE league_id = '$league_id'";
		return $this->DB->query($query);
	}
}

?>