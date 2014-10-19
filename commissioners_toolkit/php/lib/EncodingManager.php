<?
/** 
 * Manages all outbound communication with encoding.com's API. 
 */
class EncodingManager{

	var $xml;
	var $assets_xml;
	var $flores_duration = 0;

	/**
	 * Constructor. Create XML backbone for later use.
	 */
	function EncodingManager(){
		global $Logger;
		$this->Logger = $Logger;
		$this->LeagueinviterTable = new LeagueinviterTable;
		$this->LeagueinviterMediaTable = new LeagueinviterMediaTable;
		
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

		//final
		$this->xml->appendChild($query);
		
		//get assets xml and set IDs for premade
		$this->assets_xml = new DOMDocument;
		$this->assets_xml->load(ASSET_XML_LOCATION);
		$premades = $this->assets_xml->getElementsByTagname("premade");
		foreach($premades as $premade){
			$premade->setIdAttribute("id", true);
		}
	}

	function _addFormat(){
		$query = $this->xml->documentElement;
		$format = $this->xml->createElement("format");
		$format->appendChild($this->xml->createElement("output", "mp4"));
		$format->appendChild($this->xml->createElement("bitrate", "4000k"));
		$format->appendChild($this->xml->createElement("audio_bitrate", "128k"));
		$format->appendChild($this->xml->createElement("audio_sample_rate", "44100"));
		$format->appendChild($this->xml->createElement("audio_channels_number", "2"));
		$format->appendChild($this->xml->createElement("framerate", "30"));
		$format->appendChild($this->xml->createElement("keep_aspect_ratio", "yes"));
		$format->appendChild($this->xml->createElement("video_codec", "libx264"));
		$format->appendChild($this->xml->createElement("profile", "main"));
		$format->appendChild($this->xml->createElement("audio_codec", "libfaac"));
		$format->appendChild($this->xml->createElement("two_pass", "no"));
		$format->appendChild($this->xml->createElement("turbo", "no"));
		$format->appendChild($this->xml->createElement("twin_turbo", "no"));
		$format->appendChild($this->xml->createElement("cbr", "no"));
		$format->appendChild($this->xml->createElement("deinterlacing", "auto"));
		$format->appendChild($this->xml->createElement("video_sync", "old"));
		$format->appendChild($this->xml->createElement("keyframe", "300"));
		$format->appendChild($this->xml->createElement("audio_volume", "100"));
		$format->appendChild($this->xml->createElement("rotate", "def"));
		$format->appendChild($this->xml->createElement("strip_chapters", "no"));
		$format->appendChild($this->xml->createElement("frame_packing", "no"));
		$format->appendChild($this->xml->createElement("file_extension", "mp4"));
		$format->appendChild($this->xml->createElement("hint", "no"));
		$metadata = $this->xml->createElement("metadata");
		$copy = $this->xml->createElement("copy", "no");
		$metadata->appendChild($copy);
		$format->appendChild($metadata);
		$query->appendChild($format);
	}


	/**
	 * Create XML and send request for encoding.com to stitch a webcam video with a flores question video.
	 */
	function sendWebcam($league_id, $webcam_num, $webcam_url){
		//add webcam-specific notification url
		$query = $this->xml->documentElement;
		$notify = $this->xml->createElement('notify', LISTENER_STITCH_URL);
		$query->appendChild($notify);
		$notifyerror = $this->xml->createElement('notify_encoding_errors', LISTENER_ERROR_URL);
		$query->appendChild($notifyerror);
		$this->_addFormat();

		//depending on the number, we'll send a different request
		switch($webcam_num){
			case "1":
				$this->_buildQuestion1($webcam_url);
				break;
			case "2":
				$this->_buildQuestion2($webcam_url);
				break;
			case "3":
				$this->_buildQuestion3($league_id, $webcam_url);
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
			$this->Logger->criticalLog("URGENT CRITICAL ERROR URGENT - Received error response from encoding.com: " . (string) $res->errors->error);
			return false;
		} else {
			return $res->MediaID;
		}
	}
	
	/**
	 * Send data to encoding.com via curl.
	 */
	function _curl(){
		//error_log($this->xml->saveXML());
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

		$this->_addSuper();
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
	function _buildQuestion3($league_id, $webcam_url){
		//add splitscreen
		$this->_addSplitscreen();
		$query = $this->xml->documentElement;

		//is there a photo for this video?
		if($media_array = $this->LeagueinviterMediaTable->getPhotoAssetsForMerge($league_id)){
			//use photo instead of reaction vid
			//$url = "http://" . urlencode(FINALMERGE_S3_ACCESSKEY) . ":" . urlencode(FINALMERGE_S3_SECRETKEY) . "@" . FINALMERGE_S3_BUCKETNAME . ".s3.amazonaws.com/";
			//$photo_source = $this->xml->createElement('source', $url . "1344358645469_C12C5982-FBDC-4A72-5B39-C8DA93E1A3E5?acl=public-read");
			$query->appendChild($this->xml->createElement("source", $media_array['url']));
			
			//add size to format
			$format = $this->xml->getElementsByTagName('format')->item(0);
			$format->appendChild($this->xml->createElement("size", "640x360"));
			
		} else {
			//use reaction vid
			$query->appendChild($this->xml->createElement("source", $this->_getReactionVideoRandom(array("reaction_12s_shrug", "reaction_10s_yawn"))));
		}		
			
		//webcam		
		//$url = "http://" . urlencode(FINALMERGE_S3_ACCESSKEY) . ":" . urlencode(FINALMERGE_S3_SECRETKEY) . "@" . FINALMERGE_S3_BUCKETNAME . ".s3.amazonaws.com/";
		//$webcam_source = $this->xml->createElement("source", $url . "1344358648025_FE110541-3AD8-B47F-FECB-3311EA5BE250?acl=public-read");
		$query->appendChild($this->xml->createElement("source", $webcam_url));
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
		//set up for splitscreen
		$splitscreen = $this->xml->createElement("split_screen");
		$paddingleft = $this->xml->createElement("padding_left", "86");
		$paddingright = $this->xml->createElement("padding_right", "86");
		$paddingbottom = $this->xml->createElement("padding_bottom", "36");
		$splitscreen->appendChild($paddingleft);
		$splitscreen->appendChild($paddingright);
		$splitscreen->appendChild($paddingbottom);
		$query->appendChild($splitscreen);
		
		//add image background ("overlay")
		$format = $this->xml->getElementsByTagName('format')->item(0);
		$overlay = $this->xml->createElement('overlay');
		
		$overlay_source = $this->xml->createElement('overlay_source', $this->_getSplitScreenOverlay());
		$size = $this->xml->createElement("size", "640x360");
		$overlay->appendChild($overlay_source);
		$overlay->appendChild($size);
		$format->appendChild($overlay);	
	}

	
	/**
	 * Get specific reaction video asset by name
	 */
	function _getReactionVideoByName($name){
		$reactionvideos = $this->assets_xml->getElementsByTagName("reactionvideo");
		foreach($reactionvideos as $vid){
			if($vid->getAttribute("name") == $name){
				$this->_addDuration($vid->getAttribute("length"));
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
				$this->_addDuration($vid->getAttribute("length"));
				return $vid->nodeValue;
			}
		}
	}

	/**
	 * Get specific intro video asset by name
	 */
	function _getIntroVideoByName($name){
		$introvideos = $this->assets_xml->getElementsByTagName("introvideo");
		foreach($introvideos as $vid){
			if($vid->getAttribute("name") == $name){
				$this->_addDuration($vid->getAttribute("length"));
				return $vid->nodeValue;
			}
		}
	}
	
	/**
	 * Get specific outro video asset by name
	 */
	function _getOutroVideoByName($name){
		$outrovideos = $this->assets_xml->getElementsByTagName("outrovideo");
		foreach($outrovideos as $vid){
			if($vid->getAttribute("name") == $name){
				$this->_addDuration($vid->getAttribute("length") - 17);
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
	 * Get random question video asset
	 */
	function _getQuestionVideoRandom($array){
		//pick random item from array
		$name = $array[rand(0, count($array)-1)];
		return $this->_getQuestionVideoByName($name);
	}

	/**
	 * Get random outro video asset
	 */
	function _getOutroVideoRandom($array){
		//pick random item from array
		$name = $array[rand(0, count($array)-1)];
		return $this->_getOutroVideoByName($name);
	}

	/**
	 * Get URL of splitscreen overlay image
	 */
	function _getSplitScreenOverlay(){
		$name = "splitscreen";
		$overlays = $this->assets_xml->getElementsByTagName("overlay");
		foreach($overlays as $overlay){
			if($overlay->getAttribute("name") == $name){
				return $overlay->nodeValue;
			}
		}
	}

	/**
	 * Get URL of ticker overlay video
	 */
	function _getTickerOverlay(){
		$name = "ticker";
		$overlays = $this->assets_xml->getElementsByTagName("overlay");
		foreach($overlays as $overlay){
			if($overlay->getAttribute("name") == $name){
				return $overlay->nodeValue;
			}
		}
	}

	/**
	 * Get URL of ticker overlay video
	 */
	function _getSuperOverlay(){
		$name = "super";
		$overlays = $this->assets_xml->getElementsByTagName("overlay");
		foreach($overlays as $overlay){
			if($overlay->getAttribute("name") == $name){
				return $overlay->nodeValue;
			}
		}
	}

	/**
	 * Create XML and send request for encoding.com to create a premade video
	 */
	function sendPremade($league_id, $video_id){
		//set up initial XML
		$query = $this->xml->documentElement;
		$notify = $this->xml->createElement('notify', LISTENER_FINALPREMADE_URL);
		$query->appendChild($notify);
		$notifyerror = $this->xml->createElement('notify_encoding_errors', LISTENER_ERROR_URL);
		$query->appendChild($notifyerror);

		$this->_addFormat();

		//get premade asset details
		$video_asset = $this->assets_xml->getElementById($video_id);

		//is there a photo?
		if($media_array = $this->LeagueinviterMediaTable->getPhotoAssetsForMerge($league_id)){
			//yes -- add it as an overlay, with timing and position dependent on the video choice
			$format = $this->xml->getElementsByTagName('format')->item(0);
			$overlay = $this->xml->createElement('overlay');

			$overlay->appendChild($this->xml->createElement('overlay_source', $media_array['url']));
			$overlay->appendChild($this->xml->createElement("size", $video_asset->getAttribute('photosize')));
			$overlay->appendChild($this->xml->createElement("overlay_x", $video_asset->getAttribute('x')));
			$overlay->appendChild($this->xml->createElement("overlay_y", $video_asset->getAttribute('y')));
			$overlay->appendChild($this->xml->createElement("overlay_start", $video_asset->getAttribute('photoin')));
			$overlay->appendChild($this->xml->createElement("overlay_duration", $video_asset->getAttribute('photoduration')));

			$format->appendChild($overlay);	
			
		}
		//set source to the premade source
		$query->appendChild($this->xml->createElement("source", $video_asset->nodeValue));
		
		//add youtube URL and s3 URL
		$this->_addYoutube($league_id, "premade", $video_id);
		$this->_addFinalmergeS3Destination($league_id);				
				
		return $this->_encoding();
	}


	/**
	 * Create XML and send request for encoding.com to create the final video
	 */
	function sendFinalmerge($league_id, $ugc_assets_array){
		
		//get all UGC assets into an array, and remove the stuff we don't need.
		$assets = $this->_cleanupUGC($ugc_assets_array);

		//set up initial XML
		$query = $this->xml->documentElement;
		$notify = $this->xml->createElement('notify', LISTENER_FINALMERGE_URL);
		$query->appendChild($notify);
		$notifyerror = $this->xml->createElement('notify_encoding_errors', LISTENER_ERROR_URL);
		$query->appendChild($notifyerror);
		
		//intro - one specific intro
		$intro_source = $this->xml->createElement("source", $this->_getIntroVideoByName("personalized_intro"));
		$query->appendChild($intro_source);

		//question 1 - one specific question
		$question1_source = $this->xml->createElement("source", $this->_getQuestionVideoByName("personalized_question_1"));
		$query->appendChild($question1_source);

		//stitch 1 - already made
		$stitch1_source = $this->xml->createElement("source", $assets['webcam'][1]['url']);
		$query->appendChild($stitch1_source);
		
		//fakequestion - random
		$fakequestion = $this->xml->createElement("source", $this->_getQuestionVideoRandom(array("personalized_question_2a", "personalized_question_2b", "personalized_question_2c")));
		$query->appendChild($fakequestion);
		
		//stitch 2 - already made
		$stitch2_source = $this->xml->createElement("source", $assets['webcam'][2]['url']);
		$query->appendChild($stitch2_source);
		
		//question 2 - random
		$question2_source = $this->xml->createElement("source", $this->_getQuestionVideoRandom(array("personalized_question_5a", "personalized_question_5b")));
		$query->appendChild($question2_source);
		
		//stitch 3 - already made
		$stitch3_source = $this->xml->createElement("source", $assets['webcam'][3]['url']);
		$query->appendChild($stitch3_source);
		
		//question 3 - random
		$question3_source = $this->xml->createElement("source", $this->_getQuestionVideoByName("personalized_question_6c"));
		$query->appendChild($question3_source);
		
		//stitch 4 - already made
		$stitch4_source = $this->xml->createElement("source", $assets['webcam'][4]['url']);
		$query->appendChild($stitch4_source);

		//question 4 - random
		$question4_source = $this->xml->createElement("source", $this->_getQuestionVideoRandom(array("personalized_question_7a", "personalized_question_7b")));
		$query->appendChild($question4_source);

		//stitch 5 - already made
		$stitch5_source = $this->xml->createElement("source", $assets['webcam'][5]['url']);
		$query->appendChild($stitch5_source);

		//question 5 - random
		$question5_source = $this->xml->createElement("source", $this->_getQuestionVideoRandom(array("personalized_question_8a", "personalized_question_8b")));
		$query->appendChild($question5_source);		

		//stitch 6 - already made
		$stitch6_source = $this->xml->createElement("source", $assets['webcam'][6]['url']);
		$query->appendChild($stitch6_source);

		//outro - random
		$outro_source = $this->xml->createElement("source", $this->_getOutroVideoRandom(array("personalized_outro_a", "personalized_outro_b", "personalized_outro_c")));
		$query->appendChild($outro_source);

		$this->_addFormat();

		//add ticker
		$this->_addTicker($league_id);
		
		//add super
		//$this->_addSuper($league_id);

		//add youtube URL and s3 URL
		$this->_addYoutube($league_id, "personalized", false);
		$this->_addFinalmergeS3Destination($league_id);
				
				
		//error_log("FFL: " . $this->xml->saveXML());		
		//die;		
		return $this->_encoding();
	}
	
	/**
	 * Add YouTube
	 */
	function _addYoutube($league_id, $video_type, $video_id=false){
		//get youtube bucket into
		$YoutubeManager = new YoutubeManager;
		if($creds_array = $YoutubeManager->getAvailableBucket()){
			//update youtube bucket id for this leagueinviter record
			$this->LeagueinviterTable->updateYoutubeBucketId($league_id, $creds_array['youtube_bucket_id']);
			//get leaguemanager's info
			$league_array = $this->LeagueinviterTable->getByLeagueId($league_id);
			//create youtube url
			if($video_type == "personalized"){
				$raw_title = $this->_getYoutubeMeta("personalized", "title", false);
				$raw_description = $this->_getYoutubeMeta("personalized", "description", false);
				$raw_category = $this->_getYoutubeMeta("personalized", "category", false);
				$raw_tags = $this->_getYoutubeMeta("personalized", "tags", false);
			} elseif($video_type == "premade"){
				//depends on video id
				$raw_title = $this->_getYoutubeMeta("premade", "title", $video_id);
				$raw_description = $this->_getYoutubeMeta("premade", "description", $video_id);
				$raw_category = $this->_getYoutubeMeta("premade", "category", $video_id);
				$raw_tags = $this->_getYoutubeMeta("premade", "tags", $video_id);
			}
			$video_title = urlencode(str_replace("{league_name}", $league_array['league_name'], $raw_title));
			$video_desc = urlencode(str_replace("{league_manager_name}", $league_array['league_manager_name'], str_replace("{league_name}", $league_array['league_name'], $raw_description)));
			$video_category = urlencode($raw_category);
			$video_tags = urlencode(str_replace("{league_manager_name}", $league_array['league_manager_name'], str_replace("{league_name}", $league_array['league_name'], $raw_tags)));
			$youtube_url = "http://" . $creds_array['username'] . ":" . $creds_array['password'] . "@youtube.com/?title=" . $video_title . "&amp;category=" . $video_category . "&amp;keywords=" . $video_tags . "&amp;description=" . $video_desc . "&amp;acl=unlisted";
			//add tag to FORMAT section of xml
			$format = $this->xml->getElementsByTagName('format')->item(0);
			$youtube_source = $this->xml->createElement('destination', $youtube_url);
			$format->appendChild($youtube_source);
		} else {
			//NO AVAILABLE YOUTUBE ACCOUNTS - BIG BIG BIG PROBLEM
			$this->Logger->criticalLog("URGENT CRITICAL ERROR URGENT - Unable to find available YouTube bucket for league_id " . $league_id);
			return false;
		}
	}

	
	/**
	 * Get youtube info stored as attribute in an element
	 */
	function _getYoutubeMeta($elem_name, $attrib_name, $video_id=false){
		if(!$video_id){
			//personalized
			$personalized = $this->assets_xml->getElementsByTagName($elem_name)->item(0);
			return $personalized->getAttribute($attrib_name);
		} else {
			//premade
			$premade = $this->assets_xml->getElementById($video_id);
			return $premade->getAttribute($attrib_name);
		}
	}

	
	/**
	 * Add Finalmerge S3 destination
	 */
	function _addFinalmergeS3Destination($league_id){
		$format = $this->xml->getElementsByTagName('format')->item(0);
		$url = "http://" . urlencode(FINALMERGE_S3_ACCESSKEY) . ":" . urlencode(FINALMERGE_S3_SECRETKEY) . "@" . FINALMERGE_S3_BUCKETNAME . ".s3.amazonaws.com/";
		$s3_source = $this->xml->createElement('destination', $url . "final_" . $league_id . "_" . rand(0,100) . ".flv?acl=public-read");
		$format->appendChild($s3_source);
	}
	
	/**
	 * Add ticker overlay, with IN and DURATION set via number and length of UGC content
	 */
	function _addTicker($league_id){
		$ugc_duration = $this->LeagueinviterMediaTable->getRawDuration($league_id);
		$flores_duration = $this->flores_duration;
		$final_duration = $ugc_duration + $flores_duration;
		
		$format = $this->xml->getElementsByTagName('format')->item(0);
		$overlay = $this->xml->createElement('overlay');

		$overlay->appendChild($this->xml->createElement('overlay_source', $this->_getTickerOverlay()));
		$overlay->appendChild($this->xml->createElement("size", "640x37"));
		$overlay->appendChild($this->xml->createElement("overlay_x", "0"));
		$overlay->appendChild($this->xml->createElement("overlay_y", "323"));
		$overlay->appendChild($this->xml->createElement("overlay_start", "6"));
		$overlay->appendChild($this->xml->createElement("overlay_duration", $final_duration));

		$format->appendChild($overlay);	 
	}
	
	/**
	 * Add super overlay, with IN and DURATION set via length of first UGC response video
	 */
	function _addSuper(){
		$format = $this->xml->getElementsByTagName('format')->item(0);
		$overlay = $this->xml->createElement('overlay');
		$overlay->appendChild($this->xml->createElement('overlay_source', $this->_getSuperOverlay()));
		$overlay->appendChild($this->xml->createElement("size", "640x360"));
		$overlay->appendChild($this->xml->createElement("overlay_x", "0")); //152 149
		$overlay->appendChild($this->xml->createElement("overlay_y", "0")); //256 266
		$format->appendChild($overlay);	
	}
	
	/** 
	 * Get UGC URLs into a format we can work with, split into separate arrays for stitched webcam / photo
	 */
	function _cleanupUGC($array){
		$final_array = array();
		foreach($array as $key => $subarray){
			if(strpos($subarray['media_type'], "stitched_") === 0){
				$buf = explode("_", $subarray['media_type']);
				$final_array['webcam'][$buf[count($buf)-1]] = array("type"=>$subarray['media_type'], "url"=>$subarray['url']);
			}
			if(strpos($subarray['media_type'], "photo_") === 0){
				$buf = explode("_", $subarray['media_type']);
				$final_array['photo'][$buf[count($buf)-1]] = array("type"=>$subarray['media_type'], "url"=>$subarray['url']);
			}
		}
		ksort($final_array['webcam']);
		return $final_array;
	}

	/**
	 * Add to object's flores_duration
	 */
	function _addDuration($seconds){
		$this->flores_duration = $this->flores_duration + $seconds;
	}

}

?>