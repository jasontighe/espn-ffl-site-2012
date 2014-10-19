<?
/** 
 * Manages and takes action on encoding.com responses
 */
class EncodingResponseManager{
	
	var $xml;
	var $media_id;
	var $stitched_webcam_url;
	var $finalmerge_urls;
	var $error_msg;
	
	/**
	 * Constructor. Take XML and put it in this object for parsing.
	 */
	function EncodingResponseManager($xml){
		global $Logger;
		$this->Logger = $Logger;
		$this->xml = simplexml_load_string($xml);
	}
	
	/**
	 * Parse response to our webcam stitch request and set variables in this object
	 */
	function stitchResponse(){
		if($this->xml->status == "Finished"){
			//encoding.com successfully created a video
			$this->media_id = $this->xml->mediaid;
			$this->stitched_webcam_url = $this->xml->format->destination;
			return true;
		} else {
			//encoding.com errored out
			$this->Logger->criticalLog("URGENT CRITICAL ERROR URGENT - Received error response from encoding.com: ");
			return false;
		}
	}

	/**
	 * Parse response to our finalmerge request and set variables in this object.
	 */
	function finalmergeResponse(){
		if($this->xml->status == "Finished"){
			//encoding.com successfully created a video
			$this->media_id = $this->xml->mediaid;
			
			foreach($this->xml->format->destination as $dest){
				if(strpos($dest, "youtube.com") !== false){
					//youtube
					$this->finalmerge_urls['youtube_url'] = (string) $dest;
				} else {
					//s3
					$this->finalmerge_urls['s3_url'] = (string) $dest;
					$split = explode("@", $this->finalmerge_urls['s3_url']);
					if(count($split) > 1){
						$s3_url = $split[1];
					} else {
						$s3_url = $split;
					}
					$this->finalmerge_urls['s3_url'] = str_replace("?acl=public-read", "", "http://" . $s3_url); 
				}
			}
			return true;
		} else {
			//encoding.com errored out
			$this->Logger->criticalLog("URGENT CRITICAL ERROR URGENT - Received error response from encoding.com: ");
			return false;
		}
	}

	/**
	 * Parse response to our finalpremade request and set variables in this object.
	 */
	function finalpremadeResponse(){
		if($this->xml->status == "Finished"){
			//encoding.com successfully created a video
			$this->media_id = $this->xml->mediaid;
			
			foreach($this->xml->format->destination as $dest){
				if(strpos($dest, "youtube.com") !== false){
					//youtube
					$this->finalmerge_urls['youtube_url'] = (string) $dest;
				} else {
					//s3
					$this->finalmerge_urls['s3_url'] = (string) $dest;
					$split = explode("@", $this->finalmerge_urls['s3_url']);
					if(count($split) > 1){
						$s3_url = $split[1];
					} else {
						$s3_url = $split;
					}
					$this->finalmerge_urls['s3_url'] = str_replace("?acl=public-read", "", "http://" . $s3_url); 
				}
			}
			return true;
		} else {
			//encoding.com errored out
			$this->Logger->criticalLog("URGENT CRITICAL ERROR URGENT - Received error response from encoding.com: ");
			return false;
		}
	}

	/**
	 * Parse generic error message and set variables in this object
	 */
	function errorResponse(){
		$this->media_id = $this->xml->mediaid;
	}

}

?>