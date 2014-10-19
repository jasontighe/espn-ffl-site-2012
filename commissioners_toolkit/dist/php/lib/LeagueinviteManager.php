<?
class LeagueinviteManager{

	function LeagueinviteManager(){
		$this->LeagueinviteTable = new LeagueinviteTable;
	}


	function getVideoStatus($league_id){
		//does this league id exist?
		$league_array = $this->LeagueinviteTable->getByLeagueId($league_id);
		if((is_array($league_array)) && ($league_array['league_id'] != "")){
			//yes -- return the status (and youtube url, if we have it)
			return $league_array;
		} else {
			//no -- create it and return status
			$this->LeagueinviteTable->insert($league_id);
			return $this->LeagueinviteTable->getByLeagueId($league_id);
		}
	}
	
	function setMediaId($league_id, $media_id){
		if($this->LeagueinviteTable->updateMediaId($league_id, $media_id)){
			return $this->LeagueinviteTable->getByLeagueId($league_id);
		} else {
			return false;
		}
	}
	
	function encodingCallback(){
		//TODO
	}
	
	function getYoutubeURL($league_id){
		return $this->LeagueinviteTable->getByLeagueId($league_id);		
	}


	function _translateStatusNum($status_num){
		switch($status_num){
			case "0":
				return "NONE";
				break;
			case "1":
				return "CREATED";
				break;
			case "2":
				return "ERROR";
				break;
			case "3":
				return "DELETED";
				break;
		}
	}

}

?>