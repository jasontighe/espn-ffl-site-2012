<?
class LeagueinviteTable{

	var $DB;
	var $result_array;
	
	function LeagueinviteTable(){
		$this->DB = new DB;
		$this->result_array[1] = "league_id";
		$this->result_array[2] = "media_id";
		$this->result_array[3] = "status";
		$this->result_array[4] = "youtube_url";
	}

	function getByLeagueId($league_id){
		$query = 
			"SELECT * FROM leagueinvite WHERE league_id = '$league_id'";
		$this->DB->query($query);
	    $results = $this->DB->getResultArray($this->result_array);
	    return $results[0];
	}
	
	function getByMediaID($media_id){
		$query = 
			"SELECT * FROM leagueinvite WHERE media_id = '$media_id'";
		$this->DB->query($query);
	    $results = $this->DB->getResultArray($this->result_array);
	    return $results[0];
	}
	
	function insert($league_id){
		$query = 
			"INSERT INTO leagueinvite (league_id) VALUES ('$league_id')";
		return $this->DB->query($query);
	}
	
	function updateMediaId($league_id, $media_id){
		$query = 
			"UPDATE leagueinvite SET media_id = '$media_id' WHERE league_id = '$league_id'";	
		return $this->DB->query($query);	
	}
	
	function updateStatusFromUs($league_id, $status){
		$query = 
			"UPDATE leagueinvite SET status = '$status' WHERE league_id = '$league_id'";	
		return $this->DB->query($query);
	}
	
	function updateStatusFromEncoding($media_id, $status, $youtube_url=false){
		if($youtube_url){
			$query = 
				"UPDATE leagueinvite SET status = '$status' WHERE media_id = '$media_id'";
		} else {
			$query = 
				"UPDATE leagueinvite SET status = '$status' AND youtube_url = '$youtube_url' WHERE media_id = '$media_id'";
		}
		return $this->DB->query($query);
	}


}

?>