<?

class FbmapManager{

	function FbmapManager(){
		$this->FbmapTable = new FbmapTable;
	}
	
	/**
	 * Return mapstring
	 */
	function getMapString($league_id, $facebook_id){
		if($results = $this->FbmapTable->getByLeagueIdAndFacebookId($league_id, $facebook_id)){
			return $results;
		} else {
			return false;
		}
	}
	
	/** 
	 * Set mapstring
	 */
	function setMapString($league_id, $facebook_id, $string){
		//insert or update?
		if($results = $this->FbmapTable->getByLeagueIdAndFacebookId($league_id, $facebook_id)){
			//update
			$this->FbmapTable->update($league_id, $facebook_id, $string);
		} else {
			//insert
			$this->FbmapTable->insert($league_id, $facebook_id, $string);
		}
		if($results = $this->FbmapTable->getByLeagueIdAndFacebookId($league_id, $facebook_id)){
			return $results;
		} else {
			return false;
		}
	}

}

?>