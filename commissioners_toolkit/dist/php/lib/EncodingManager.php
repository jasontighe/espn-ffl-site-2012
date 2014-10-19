<?
/** 
 * Manages all outbound communication with encoding.com's API.
 */
class EncodingManager{

	var $xml;
	var $assets_xml;

	/**
	 * Constructor. Create XML backbone for later use.
	 */
	function EncodingManager(){
		$this->xml = new DOMDocument;
		$this->xml->formatOutput = true;
		$query = $this->xml->createElement("query");
		//type
		$action = $this->xml->createElement('action', "AddMedia");
		$query->appendChild($action);
		//creds
		$userid = $this->xml->createElement("userid", ENCODING_USERID);
		$query->appendChild($userid);
		$userkey = $this->xml->createElement("userkey", ENCODING_USERKEY);
		$query->appendChild($userkey);
		//formatting
		$format = $this->xml->createElement("format");
		$output = $this->xml->createElement("output", "mp4");
		$format->appendChild($output);
		$bitrate = $this->xml->createElement('bitrate', "4000k");
		$format->appendChild($bitrate);
		$framerate = $this->xml->createElement("framerate", "30");
		$format->appendChild($framerate);
		$profile = $this->xml->createElement("profile", "main");
		$format->appendChild($profile);
		$size = $this->xml->createElement("size", "640x360");
		$format->appendChild($size);
		$audiocodec = $this->xml->createElement("audio_codec", "libfaac");
		$format->appendChild($audiocodec);
		$audiobitrate = $this->xml->createElement("audio_bitrate", "128k");
		$format->appendChild($audiobitrate);		
		$audiosamplerate = $this->xml->createElement("audio_sample_rate", "44100");
		$format->appendChild($audiosamplerate);
		$query->appendChild($format);
		//final
		$this->xml->appendChild($query);
		
		//get assets xml
		$this->assets_xml = new DOMDocument;
		$this->assets_xml->load(ASSET_XML_LOCATION);
	}

	/**
	 * Create XML and send request for encoding.com to stitch a webcam video with a flores question video.
	 */
	function sendWebcam($webcam_num, $webcam_url){
		//add webcam-specific notification url
		$query = $this->xml->documentElement;
		$notify = $this->xml->createElement('notify', LISTENER_STITCH_URL);
		$query->appendChild($notify);
		$notifyerror = $this->xml->createElement('notify_encoding_errors', LISTENER_ERROR_URL);
		$query->appendChild($notifyerror);
		//depending on the number, we'll send a different request
		switch($webcam_num){
			case "1":
				$this->_buildQuestion1($webcam_url);
				break;
			case "2":
				$this->_buildQuestion2($webcam_url);
				break;
			case "3":
				$this->_buildQuestion3($webcam_url);
				break;
			case "4":
				//we should never get here.
				break;
			case "5":
				$this->_buildQuestion5($webcam_url);
				break;
			case "6":
				$this->_buildQuestion6($webcam_url);
				break;
		}
		//send request
		return $this->_encoding();
	}

	/**
	 * Send request to encoding.com and parse out response. return media_id from encoding.
	 */
	function _encoding(){
		$res = simplexml_load_string($this->_curl());
		if($res->errors){
			return false;
		} else {
			return $res->MediaID;
		}
	}
	
	/**
	 * Send data to encoding.com via curl.
	 */
	function _curl(){
	    $ch = curl_init();  
	    curl_setopt($ch, CURLOPT_URL, "http://stage.encoding.com/");  
	    curl_setopt($ch, CURLOPT_POSTFIELDS, "xml=" . urlencode($this->xml->saveXML()));  
	    curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);  
	    curl_setopt($ch, CURLOPT_HEADER, 0);  
	    return curl_exec($ch);  	
	}

	/**
	 * Build XML for Question 1.
	 * SPLIT. REACTION 20s LISTENING + WEBCAM 1
	 */
	function _buildQuestion1($webcam_url){
		//add splitscreen
		$this->_addSplitscreen();
		//add sources
		$query = $this->xml->documentElement;
		$reaction_source = $this->xml->createElement("source", $this->_getReactionVideoByName("reaction_20s_listening"));
		$query->appendChild($reaction_source);
		$webcam_source = $this->xml->createElement("source", $webcam_url);
		$query->appendChild($webcam_source);
	}
	
	/**
	 * Build XML for Question 2.
	 * SPLIT. QUESTION 3 + WEBCAM 2
	 */
	function _buildQuestion2($webcam_url){
		//add splitscreen
		$this->_addSplitscreen();
		//add sources
		$query = $this->xml->documentElement;
		$question_source = $this->xml->createElement("source", $this->_getQuestionVideoByName("personalized_question_3"));
		$query->appendChild($question_source);
		$webcam_source = $this->xml->createElement("source", $webcam_url);
		$query->appendChild($webcam_source);
	}
	
	/**
	 * Build XML for Question 3.
	 * SPLIT. REACTION (12s_shrug OR 10s_yawn OR photo) + WEBCAM 3
	 */
	function _buildQuestion3($webcam_url){
		//add splitscreen
		$this->_addSplitscreen();
		//add sources
		$query = $this->xml->documentElement;
		$reaction_source = $this->xml->createElement("source", $this->_getReactionVideoRandom(array("reaction_12s_shrug", "reaction_10s_yawn")));
		$query->appendChild($reaction_source);
		$webcam_source = $this->xml->createElement("source", $webcam_url);
		$query->appendChild($webcam_source);
	}
	
	/**
	 * Build XML for Question 5.
	 * SPLIT. REACTION (12s_spin OR 14s_yawn) + WEBCAM 5
	 */
	function _buildQuestion5($webcam_url){
		//add splitscreen
		$this->_addSplitscreen();
		//add sources
		$query = $this->xml->documentElement;
		$reaction_source = $this->xml->createElement("source", $this->_getReactionVideoRandom(array("reaction_12s_spin", "reaction_14s_yawn")));
		$query->appendChild($reaction_source);
		$webcam_source = $this->xml->createElement("source", $webcam_url);
		$query->appendChild($webcam_source);	
	}
	
	/**
	 * Build XML for Question 6.
	 * SPLIT. REACTION (14s_yawn or 15s_fan) + WEBCAM 6
	 */
	function _buildQuestion6($webcam_url){
		//add splitscreen
		$this->_addSplitscreen();
		//add sources
		$query = $this->xml->documentElement;
		$reaction_source = $this->xml->createElement("source", $this->_getReactionVideoRandom(array("reaction_14s_yawn", "reaction_15s_fan")));
		$query->appendChild($reaction_source);
		$webcam_source = $this->xml->createElement("source", $webcam_url);
		$query->appendChild($webcam_source);	
	}
	
	function _addSplitscreen(){
		$query = $this->xml->documentElement;
		$splitscreen = $this->xml->createElement("split_screen");
		$paddingleft = $this->xml->createElement("padding_left", "86");
		$paddingright = $this->xml->createElement("padding_right", "86");
		$paddingbottom = $this->xml->createElement("padding_bottom", "36");
		$splitscreen->appendChild($paddingleft);
		$splitscreen->appendChild($paddingright);
		$splitscreen->appendChild($paddingbottom);
		$query->appendChild($splitscreen);
	}
	
	/**
	 * Get specific reaction video asset by name
	 */
	function _getReactionVideoByName($name){
		$reactionvideos = $this->assets_xml->getElementsByTagName("reactionvideo");
		foreach($reactionvideos as $vid){
			if($vid->getAttribute("name") == $name){
				return $vid->nodeValue;
			}
		}
	}
	
	/**
	 * Get specific question video asset by name
	 */
	function _getQuestionVideoByName($name){
		$questionvideos = $this->assets_xml->getElementsByTagName("questionvideo");
		foreach($questionvideos as $vid){
			if($vid->getAttribute("name") == $name){
				return $vid->nodeValue;
			}
		}
	}
	
	/**
	 * Get random reaction video asset
	 */
	function _getReactionVideoRandom($array){
		//pick random item from array
		$name = $array[rand(0, count($array)-1)];
		return $this->_getReactionVideoByName($name);
	}
	
	/**
	 * Create XML and send request for encoding.com to create the final video
	 */
	function sendFinalmerge($league_id){
		error_log("SEND THE FINAL MERGE REQUEST, BITCHES!!!!!!!!!!!");
	}

}

?>