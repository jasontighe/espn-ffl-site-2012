<?
/**
 * Handles all logging, both normal (for dev) and URGENT ERROR logging (for prod)
 */
class Logger{

	function Logger(){

	}

	function serviceLog($service, $msg){
		if(DEBUG){
			error_log("[FFL - ".strtoupper($service)."] " . $msg);
		}
	}
	
	function criticalLog($msg){
		error_log("[FFL CRITICAL ERROR] " . $msg);
		return $msg;
	}
	
	

}

?>