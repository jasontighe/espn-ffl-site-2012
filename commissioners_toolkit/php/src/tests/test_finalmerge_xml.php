<?

include "../../includes.inc.php";
$EncodingResponseManager = new EncodingResponseManager("<result><mediaid>8078</mediaid><source></source><status>Finished</status><description></description><format><taskid>8060</taskid><output>mp4</output><status>Finished</status><destination>http://ESPNFF:Fanta5yESPN@youtube.com/?title=blah+Commissioner+ESPN+Interview&amp;category=Sports&amp;keywords=Fantasy+Football%2C+Robert+Flores%2C+Football%2C+League+Inviter%2C+ESPN%2C+blah%2C+blahblah&amp;description=ESPN+Fantasy+Football+commissioner+blahblah+discusses+blah%27s+upcoming+season+with+Robert+Flores+via+satellite+feed.&amp;acl=private</destination><destination_status>Saved</destination_status><destination>http://AKIAITDMF2HBDOXP6S4Q:Ul18uiOnokPSCjL8xkQqIIa7%2FTc9UnKGc1X2VuVm@leetest.s3.amazonaws.com/final_100_27.mp4?acl=public-read</destination><destination_status>Saved</destination_status></format></result>");
	
	
		if($EncodingResponseManager->finalmergeResponse()){
		//get league_id based on this media_id
		$LeagueInviterManager = new LeagueInviterManager;
		$league_id = $LeagueInviterManager->getLeagueIdFromMediaId($EncodingResponseManager->media_id);
		//successful encoding response - update final URLs, remove media records, update status
		if(!$LeagueInviterManager->storeAndProcessFinalmergeVideo($league_id, $EncodingResponseManager->media_id, $EncodingResponseManager->finalmerge_urls)){
			//db or other backend failure
			$LeagueInviterManager->indicateError($league_id);
		}
	} else {
		//failed encoding response - note the failure in the main league record
		$LeagueInviterManager->indicateError($league_id);	
		//...and in the encoding-error logfile
		//FIXFIX
	}


?>

<form action="http://ffl.dev/test_finalmerge_xml.php" method="post">
	<textarea name="xml" rows="10" cols="50"></textarea>
	<input type="submit" name="submit" />
</form>