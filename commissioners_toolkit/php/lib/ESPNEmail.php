<?
/**
 * Trigger ESPN email sending
 */
class ESPNEmail{

	/**
	 * Use ESPN API to notify user when video is ready for viewing.
	 */
	function sendVideoReady($league_id, $user_profile_id, $league_manager_name, $youtube_url){
		if(file_get_contents(ESPN_EMAIL_API_URL . "campaignName=commissionerSuccess&userProfileId=".$user_profile_id."&commissionerName=".urlencode($league_manager_name)."&commissionerLink=".urlencode(ESPN_CT_URL.$league_id)."&videoLink=".urlencode($youtube_url))){
			return true;
		} else {
			return false;
		}
	}
	
	/**
	 * Use ESPN API to notify user when video has been rejected
	 */
	function sendVideoDeleted($league_id, $user_profile_id, $league_manager_name){
		if(file_get_contents(ESPN_EMAIL_API_URL . "campaignName=commissionerModeration&userProfileId=".$user_profile_id."&commissionerName=".urlencode($league_manager_name)."&commissionerLink=".urlencode(ESPN_CT_URL.$league_id))){
			return true;
		} else {
			return false;
		}
	}

}

?>