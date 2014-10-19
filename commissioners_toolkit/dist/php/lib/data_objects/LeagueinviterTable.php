<?
class LeagueinviterTable{

	var $DB;
	var $result_array;
	
	function LeagueinviterTable(){
		$this->DB = new DB;
		$this->result_array[0] = "leagueinviter_id";
		$this->result_array[1] = "league_id";
		$this->result_array[2] = "league_name";
		$this->result_array[3] = "league_manager_name";
		$this->result_array[4] = "webcam_count";
		$this->result_array[5] = "youtube_url";
		$this->result_array[6] = "s3_url";
		$this->result_array[7] = "status";
	}
	
	function getByLeagueId($league_id){
		$query = 
			"SELECT * FROM leagueinviter WHERE league_id = '$league_id'";
		$this->DB->query($query);
	    $results = $this->DB->getResultArray($this->result_array);
	    return $results[0];
	}
	
	function insert($league_id, $league_name, $league_manager_name){
		$query = 
			"INSERT INTO leagueinviter (league_id, league_name, league_manager_name) VALUES ('$league_id', '$league_name', '$league_manager_name')";
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
	
	function updateYoutubeURL($league_id, $youtube_url){
		$query = 
			"UPDATE leagueinviter SET youtube_url = '$youtube_url' WHERE league_id = '$league_id'";
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