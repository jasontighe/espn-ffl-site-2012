<?

class CriticalErrorTable{

	function CriticalErrorTable(){
		$this->DB = new DB;
	}
	
	function insert($league_id, $msg){
		if(!$league_id){
			$league_id = 'null';
		}
		$query = 
			"INSERT INTO critical_error (league_id, message) VALUES ($league_id, '$msg')";
		return $this->DB->query($query);		
	}

}

?>