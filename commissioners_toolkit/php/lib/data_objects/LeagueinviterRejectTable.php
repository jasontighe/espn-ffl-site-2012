<?
class LeagueinviterRejectTable{

	var $DB;
	var $result_array;
	
	function LeagueinviterRejectTable(){
		$this->DB = new DB;
		$this->result_array[0] = "leagueinviter_reject_id";
		$this->result_array[1] = "league_id";
		$this->result_array[2] = "league_name";
		$this->result_array[3] = "league_manager_name";
		$this->result_array[4] = "thumb_filename";
		$this->result_array[5] = "s3_url";
		$this->count_result_array[0] = "rejected_count";
	}

	function statsVideosRejected(){
		$query = 
			"SELECT COUNT(leagueinviter_reject_id) AS video_created_count FROM leagueinviter_reject";
		$this->DB->query($query);
		$result_array = $this->DB->getResultArray(array("video_created_count"));
		return $result_array[0]['video_created_count'];
	}
	
	function getChunk($page){
		$max = 'limit ' . ($page - 1) * MODERATION_PER_PAGE .',' . MODERATION_PER_PAGE;
		$query = 
			"SELECT * FROM leagueinviter_reject " . $max;
		$this->DB->query($query);
		return $this->DB->getResultArray($this->result_array);
	}
	
	function getTotal(){
		$query = "SELECT COUNT(*) AS rejected_count FROM leagueinviter_reject";
		$this->DB->query($query);
	    $results = $this->DB->getResultArray($this->count_result_array);
	    $count = $results[0]['rejected_count'];
	    if(!$count){
	    	$count = "0";
	    }
	    return $count;
	}
	
	function insert($league_id, $league_name, $league_manager_name, $thumb_filename, $s3_url){
		$query = 
			"INSERT INTO leagueinviter_reject (league_id, league_name, league_manager_name, thumb_filename, s3_url) VALUES ('$league_id', '$league_name', '$league_manager_name', '$thumb_filename', '$s3_url')";
	    $this->DB->query($query);
	    return $this->DB->last_id();
	}
	
}

?>