<?
class FbmapTable{

	var $DB;
	var $result_array;
	
	function FbmapTable(){
		$this->DB = new DB;
		$this->result_array[1] = "league_id";
		$this->result_array[2] = "facebook_id";
		$this->result_array[3] = "string";
	}

	function getByLeagueId($league_id){
		$query = 
			"SELECT * FROM fbmap WHERE league_id = '$league_id'";
		$this->DB->query($query);
	    $results = $this->DB->getResultArray($this->result_array);
	    return $results[0];
	}

	function getByLeagueIdAndFacebookId($league_id, $facebook_id){
		$query = 
			"SELECT * FROM fbmap WHERE league_id = '$league_id' AND facebook_id = '$facebook_id'";
		$this->DB->query($query);
	    $results = $this->DB->getResultArray($this->result_array);
	    return $results[0];
	}	
	
	function insert($league_id, $facebook_id, $string){
		$query = 
			"INSERT INTO fbmap (league_id, facebook_id, string) VALUES ('$league_id', '$facebook_id', '$string')";
		return $this->DB->query($query);		
	}
	
	function update($league_id, $facebook_id, $string){
		$query = 
			"UPDATE fbmap SET string = '$string' WHERE league_id = '$league_id' AND facebook_id = '$facebook_id'";	
		return $this->DB->query($query);	
	}

}

?>