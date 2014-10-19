<?
/** 
 * Manages and takes action on encoding.com responses
 */
class EncodingResponseManager{
	
	var $xml;
	var $media_id;
	var $stitched_webcam_url;
	var $error_msg;
	
	/**
	 * Constructor. Take XML and put it in this object for parsing.
	 */
	function EncodingResponseManager($xml){
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
			$this->error_msg = $this->xml->description;
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