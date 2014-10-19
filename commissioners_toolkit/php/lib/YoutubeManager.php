<?
/**
 * Manages make-public and delete functionality for youtube
 */
class YoutubeManager{

	var $YoutubeBucketTable;
	var $yt;
		
	/**
	 * Constructor
	 */
	function YoutubeManager(){
		$this->YoutubeBucketTable = new YoutubeBucketTable;
	}
	
	/**
	 * Authenticate with YT
	 */
	function authenticate($creds){
		Zend_Loader::loadClass('Zend_Gdata_YouTube');
		Zend_Loader::loadClass('Zend_Gdata_ClientLogin'); 
		
		$authenticationURL= 'https://www.google.com/accounts/ClientLogin';
		$httpClient = 
		  Zend_Gdata_ClientLogin::getHttpClient(
		              $username = $creds['email'],
		              $password = $creds['password'],
		              $service = 'youtube',
		              $client = null,
		              $source = 'ESPN FFL', // a short string identifying your application
		              $loginToken = null,
		              $loginCaptcha = null,
		              $authenticationURL);	
		$this->yt = new Zend_Gdata_YouTube($httpClient, $creds['application_id'], $creds['client_id'], $creds['developer_key']);
		if($this->yt){
			$this->yt->setMajorProtocolVersion(2);
			return true;
		} else {
			$this->Logger->criticalLog("URGENT CRITICAL ERROR URGENT - Unable to authenticate to YouTube with " . print_r($creds, true));
			return false;
		}
	}
	
	/**
	 * Increment bucket count after a successful video upload
	 */
	function addToBucket($youtube_bucket_id){
		$this->YoutubeBucketTable->add($youtube_bucket_id);
	}
	
	/**
	 * Decrement bucket count after a successful video deletion (admin OR user)
	 */
	function subtractFromBucket($youtube_bucket_id){
		$this->YoutubeBucketTable->subtract($youtube_bucket_id);
	}
	
	/**
	 * Determine which bucket is available for new youtube videos and return credentials.
	 */
	function getAvailableBucket(){
		if($youtube_bucket_id = $this->YoutubeBucketTable->getFirstAvailableBucket()){
			return $this->getBucketCreds($youtube_bucket_id);
		} else {
			echo "NO BUCKETS AVAIL!!!"; //FIXFIX
		}

	}
	
	/**
	 * Lookup and return youtube creds in XML by ID
	 */
	function getBucketCreds($youtube_bucket_id){
		$this->_getCredsXML();
		$creds_obj = $this->creds_xml->getElementById($youtube_bucket_id);
		$creds = array('youtube_bucket_id'=>$youtube_bucket_id);
		foreach($creds_obj->childNodes as $cred){
			if(strpos($cred->nodeName, "#") === false){
				$creds[$cred->nodeName] = $cred->nodeValue;
			}
		}
		return $creds;
	}
	
	/**
	 * Open XML, set ID attrib so we can access stuff.
	 */
	function _getCredsXML(){
		$this->creds_xml = new DOMDocument;
		$this->creds_xml->load(YOUTUBE_CREDS_XML_LOCATION);
		$buckets = $this->creds_xml->getElementsByTagname("bucket");
		foreach($buckets as $bucket){
			$bucket->setIdAttribute("id", true);
		}
	}
	
	function makeVideoPublic($league_id, $youtube_bucket_id, $youtube_id){
		//authenticate
		$creds = $this->getBucketCreds($youtube_bucket_id);
		if($this->authenticate($creds)){	
			$videoEntry = $this->yt->getFullVideoEntry($youtube_id); 
			$listed = new Zend_Gdata_App_Extension_Element( 'yt:accessControl', 'yt', 'http://gdata.youtube.com/schemas/2007', '' );
			$listed->setExtensionAttributes(array(
			    array('namespaceUri' => '', 'name' => 'action', 'value' => 'list'),
			    array('namespaceUri' => '', 'name' => 'permission', 'value' => 'allowed')
			));
			$videoEntry->setExtensionElements(array($listed));
			$putUrl = $videoEntry->getEditLink()->getHref();
			$this->yt->updateEntry($videoEntry, $putUrl);
			if($videoEntry->isVideoPrivate()){
				return false;
			} else {
				return true;
			}			
		} else {
			return false;
		}
	}
		
	function deleteVideo($league_id, $youtube_bucket_id, $youtube_id){
		//authenticate
		$creds = $this->getBucketCreds($youtube_bucket_id);
		if($this->authenticate($creds)){
			//delete video
			$the_video = $this->yt->getFullVideoEntry($youtube_id);
			$this->yt->delete($the_video);
			$this->subtractFromBucket($youtube_bucket_id);
			return true;
		} else {
			//error_log("NOT AUTHENTCIATED");
			//FIXFIX
			return false;
		}
	}

}


?>