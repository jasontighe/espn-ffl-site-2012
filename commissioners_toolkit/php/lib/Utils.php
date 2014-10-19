<?

	function UTIL_parseYoutubeId($youtube_url){
		$sVideoID = preg_replace('%.*(v=|/v/)(.+?)(/|&|\\?).*%', '$2', $youtube_url);
		return $sVideoID;
	}
	
	
?>