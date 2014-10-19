<?

class AdminManager{

	function AdminManager(){
		$this->LeagueinviterTable = new LeagueinviterTable;
		$this->LeagueinviterRejectTable = new LeagueinviterRejectTable;
		$this->FbmapTable = new FbmapTable;
	}
	
	function getStats(){
		$stats['visitors'] = $this->LeagueinviterTable->statsVisitors();
		$stats['videos_created'] = $this->LeagueinviterTable->statsVideosCreated();
		$stats['personalized_videos'] = $this->LeagueinviterTable->statsPersonalizedVideos();
		$stats['premade_videos'] = $this->LeagueinviterTable->statsPremadeVideos();
		$stats['videos_approved'] = $this->LeagueinviterTable->statsVideosApproved();
		$stats['videos_rejected'] = $this->LeagueinviterRejectTable->statsVideosRejected();
		return $stats;
	}

}

?>