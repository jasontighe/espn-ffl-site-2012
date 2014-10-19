<?
/**
 * Manages CRUD for ffl.youtube_bucket
 */
class YoutubeBucketTable{

	var $DB;
	var $result_array;

	function YoutubeBucketTable(){
		$this->DB = new DB;
		$this->result_array[0] = "youtube_bucket_id";
		$this->result_array[1] = "num_videos";
	}
	
	function get(){
		$query = 
			"SELECT * FROM youtube_bucket";
		$this->DB->query($query);
	    return $this->DB->getResultArray($this->result_array);
	}
		
	function getFirstAvailableBucket(){
		$query = 
			"SELECT * FROM youtube_bucket WHERE num_videos < " . MAX_YOUTUBE_VIDEO_COUNT . " ORDER BY youtube_bucket_id LIMIT 0, 1";
		$this->DB->query($query);
	    $results = $this->DB->getResultArray($this->result_array);
	    return $results[0]['youtube_bucket_id'];		
	}
	
	function getByYoutubeBucketId($youtube_bucket_id){
		$query = 
			"SELECT * FROM youtube_bucket WHERE youtube_bucket_id = '$youtube_bucket_id'";
		$this->DB->query($query);
	    $results = $this->DB->getResultArray($this->result_array);
	    return $results[0];
	}
	
	function add($youtube_bucket_id){
		$query = 
			"UPDATE youtube_bucket SET num_videos = num_videos+1 WHERE youtube_bucket_id = '$youtube_bucket_id'";

//		return $this->DB->query($query);
	}

	function subtract($youtube_bucket_id){
		$query = 
			"UPDATE youtube_bucket SET num_videos = num_videos-1 WHERE youtube_bucket_id = '$youtube_bucket_id'";
//		return $this->DB->query($query);
	}

}

?>