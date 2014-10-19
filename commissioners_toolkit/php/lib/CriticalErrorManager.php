<?
/**
 * Handles notification and DB CRUD when critical, show-stopping errors occur.
 */
class CriticalErrorManager{

	/**
	 * Constructor
	 */
	function CriticalErrorManager(){
		$this->notify_emails = array("husani.oakley@husani.com", "brandon.kaplan@wk.com", "hana.newman@wk.com", "sean.jones@wk.com");
	}
	
	/**
	 * Mark league-id as errored, send email notifications, add to critical error DB log
	 */
	function handleError($league_id, $msg){
		//set up what we need
		$CriticalErrorTable = new CriticalErrorTable;
		$LeagueinviterTable = new LeagueinviterTable;
		$phpmailer = new PHPMailer;

		if($league_id){
			//mark as error
			$LeagueinviterTable->updateStatus($league_id, "ERROR");
		}
		//add to log
		$CriticalErrorTable->insert($league_id, $msg);
		//send email on PRODUCTION ONLY
		if(ENV == "production"){
			$phpmailer->IsHTML(false);
			$phpmailer->IsMail();
			$phpmailer->Priority = "1";
			$phpmailer->From = "no-reply@ffl.sportsr.us";
			$phpmailer->FromName = "ESPN FFL SERVER";
			$phpmailer->Sender = "no-reply@ffl.sportsr.us";
			foreach($this->notify_emails as $email){
			    $phpmailer->AddAddress($email);
			}
			$phpmailer->Subject = "URGENT: A CRITICAL FFL ERROR HAS OCCURRED!";
		    $phpmailer->Body = "Hello,\n\nA critical error has occurred on ESPN FFL, environment " . ENV . ". Error messaging is as follows:\n\n" . $msg;
		    if(!$phpmailer->Send()){
		    	error_log("COULD NOT SEND CRITICAL ERROR NOTIFICATION: " . $phpmailer->ErrorInfo);
		    } else {
		    	error_log("SENT CRITICAL ERROR NOTIFICATION");
		    }
		}
	}

}


?>