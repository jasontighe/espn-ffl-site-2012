<?

$docroot = $_SERVER['DOCUMENT_ROOT'];

switch($_SERVER['HTTP_HOST']){
	case "home.husani.com": //husani's localdev at home - for external access of backend
		define("ENV", "husani localdev at home, external access of backend");
		define("LIB", "/Users/husani/htdocs/ffl/trunk/commissioners_toolkit/php/lib/");
		define("DB_HOST", "localhost");
		define("DB_NAME", "ffl");
		define("DB_USER", "ffl");
		define("DB_PASS", "ffl");
		define("WEBSERVICE_URL", "http://home.husani.com/");
		define("LOG_LOCATION", "/Applications/MAMP/logs/php_error.log");	
		define("SERVER1_LOG", "http://home.husani.com/logging/index.php");
		define("SERVER2_LOG", "http://home.husani.com/logging/index.php");
		define("SERVER3_LOG", "http://home.husani.com/logging/index.php");
		define("LISTENER_STITCH_URL", "http://home.husani.com/listener_stitch.php");
		define("LISTENER_FINALMERGE_URL", "http://home.husani.com/listener_finalmerge.php");
		define("LISTENER_FINALPREMADE_URL", "http://home.husani.com/listener_finalpremade.php");
		define("LISTENER_ERROR_URL", "http://home.husani.com/listener_error.php");
		define("DEBUG", true);
		break;
	case "ffl.dev": //husani's localdev
		define("ENV", "husani localdev");
		define("LIB", "/Users/husani/htdocs/ffl/trunk/commissioners_toolkit/php/lib/");
		define("DB_HOST", "localhost");
		define("DB_NAME", "ffl");
		define("DB_USER", "ffl");
		define("DB_PASS", "ffl");
		define("WEBSERVICE_URL", "http://ffl.dev/");
		define("LOG_LOCATION", "/Applications/MAMP/logs/php_error.log");	
		define("SERVER1_LOG", "http://ffl.dev/logging/index.php");
		define("SERVER2_LOG", "http://ffl.dev/logging/index.php");
		define("SERVER3_LOG", "http://ffl.dev/logging/index.php");

		define("LISTENER_STITCH_URL", "http://fflsvcs.dev.nyc.wk.com/listener_stitch.php");
		define("LISTENER_FINALMERGE_URL", "http://fflsvcs.dev.nyc.wk.com/listener_finalmerge.php");
		define("LISTENER_FINALPREMADE_URL", "http://fflsvcs.dev.nyc.wk.com/listener_finalpremade.php");
		define("LISTENER_ERROR_URL", "http://fflsvcs.dev.nyc.wk.com/listener_error.php");

		/**
		define("LISTENER_STITCH_URL", "http://home.husani.com/listener_stitch.php");
		define("LISTENER_FINALMERGE_URL", "http://home.husani.com/listener_finalmerge.php");
		define("LISTENER_FINALPREMADE_URL", "http://home.husani.com/listener_finalpremade.php");
		define("LISTENER_ERROR_URL", "http://home.husani.com/listener_error.php");
		*/

		define("DEBUG", true);
		break;
	case "moderation.ffl.dev": //husani's localdev
		define("ENV", "husani localdev");
		define("LIB", "/Users/husani/htdocs/ffl/trunk/commissioners_toolkit/php/lib/");
		define("DB_HOST", "localhost");
		define("DB_NAME", "ffl");
		define("DB_USER", "ffl");
		define("DB_PASS", "ffl");
		define("WEBSERVICE_URL", "http://ffl.dev/");
		define("LOG_LOCATION", "/Applications/MAMP/logs/php_error.log");	
		define("SERVER1_LOG", "http://ffl.dev/logging/index.php");
		define("SERVER2_LOG", "http://ffl.dev/logging/index.php");
		define("SERVER3_LOG", "http://ffl.dev/logging/index.php");
		define("DEBUG", true);
		break;
	case "admin.ffl.dev": //localdev
		define("ENV", "husani localdev");
		define("LIB", "/Users/husani/htdocs/ffl/trunk/commissioners_toolkit/php/lib/");
		define("DB_HOST", "localhost");
		define("DB_NAME", "ffl");
		define("DB_USER", "ffl");
		define("DB_PASS", "ffl");
		define("WEBSERVICE_URL", "http://ffl.dev/");
		define("LOG_LOCATION", "/Applications/MAMP/logs/php_error.log");	
		define("SERVER1_LOG", "http://ffl.dev/logging/index.php");
		define("SERVER2_LOG", "http://ffl.dev/logging/index.php");
		define("SERVER3_LOG", "http://ffl.dev/logging/index.php");
		define("DEBUG", true);
		break;
	case "fflsvcs.dev.nyc.wk.com": //dev
		define("ENV", "WK dev, fflsvcs");
		define("LIB", "/var/www/vhosts/fflsvcs.dev.nyc.wk.com/lib/");
		define("DB_HOST", "localhost");
		define("DB_NAME", "ffl");
		define("DB_USER", "ffl");
		define("DB_PASS", "ffl");
		define("WEBSERVICE_URL", "http://fflsvcs.dev.nyc.wk.com/");
		define("LOG_LOCATION", $docroot . "/../logs/error_log");	
		define("SERVER1_LOG", "http://fflsvcs.dev.nyc.wk.com/logging/index.php");
		define("SERVER2_LOG", "http://fflsvcs.dev.nyc.wk.com/logging/index.php");
		define("SERVER3_LOG", "http://fflsvcs.dev.nyc.wk.com/logging/index.php");
		define("LISTENER_STITCH_URL", "http://fflsvcs.dev.nyc.wk.com/listener_stitch.php");
		define("LISTENER_FINALMERGE_URL", "http://fflsvcs.dev.nyc.wk.com/listener_finalmerge.php");
		define("LISTENER_FINALPREMADE_URL", "http://fflsvcs.dev.nyc.wk.com/listener_finalpremade.php");
		define("LISTENER_ERROR_URL", "http://fflsvcs.dev.nyc.wk.com/listener_error.php");
		define("DEBUG", true);
		break;
	case "fflsvcspress.dev.nyc.wk.com": //dev
		define("ENV", "WK dev, fflsvcspress");
		define("LIB", "/var/www/vhosts/fflsvcspress.dev.nyc.wk.com/lib/");
		define("DB_HOST", "localhost");
		define("DB_NAME", "fflpress");
		define("DB_USER", "ffl");
		define("DB_PASS", "ffl");
		define("WEBSERVICE_URL", "http://fflsvcspress.dev.nyc.wk.com/");
		define("LOG_LOCATION", $docroot . "/../logs/error_log");	
		define("SERVER1_LOG", "http://fflsvcspress.dev.nyc.wk.com/logging/index.php");
		define("SERVER2_LOG", "http://fflsvcspress.dev.nyc.wk.com/logging/index.php");
		define("SERVER3_LOG", "http://fflsvcspress.dev.nyc.wk.com/logging/index.php");
		define("LISTENER_STITCH_URL", "http://fflsvcspress.dev.nyc.wk.com/listener_stitch.php");
		define("LISTENER_FINALMERGE_URL", "http://fflsvcspress.dev.nyc.wk.com/listener_finalmerge.php");
		define("LISTENER_FINALPREMADE_URL", "http://fflsvcspress.dev.nyc.wk.com/listener_finalpremade.php");
		define("LISTENER_ERROR_URL", "http://fflsvcspress.dev.nyc.wk.com/listener_error.php");
		define("DEBUG", true);
		break;
	case "moderation.ffl.dev.nyc.wk.com": //dev - moderation
		define("ENV", "WK dev - moderation, fflsvcs");
		define("LIB", "/var/www/vhosts/fflsvcs.dev.nyc.wk.com/lib/");
		define("DB_HOST", "localhost");
		define("DB_NAME", "ffl");
		define("DB_USER", "ffl");
		define("DB_PASS", "ffl");
		define("WEBSERVICE_URL", "http://fflsvcs.dev.nyc.wk.com/");
		define("LOG_LOCATION", $docroot . "/../logs/error_log");	
		define("SERVER1_LOG", "http://fflsvcs.dev.nyc.wk.com/logging/index.php");
		define("SERVER2_LOG", "http://fflsvcs.dev.nyc.wk.com/logging/index.php");
		define("SERVER3_LOG", "http://fflsvcs.dev.nyc.wk.com/logging/index.php");
		define("LISTENER_STITCH_URL", "http://fflsvcs.dev.nyc.wk.com/listener_stitch.php");
		define("LISTENER_FINALMERGE_URL", "http://fflsvcs.dev.nyc.wk.com/listener_finalmerge.php");
		define("LISTENER_FINALPREMADE_URL", "http://fflsvcs.dev.nyc.wk.com/listener_finalpremade.php");
		define("LISTENER_ERROR_URL", "http://fflsvcs.dev.nyc.wk.com/listener_error.php");
		define("DEBUG", true);
		break;
	case "admin.ffl.dev.nyc.wk.com": //dev - admin
		define("ENV", "WK dev - admin, fflsvcs");
		define("LIB", "/var/www/vhosts/fflsvcs.dev.nyc.wk.com/lib/");
		define("DB_HOST", "localhost");
		define("DB_NAME", "ffl");
		define("DB_USER", "ffl");
		define("DB_PASS", "ffl");
		define("WEBSERVICE_URL", "http://fflsvcs.dev.nyc.wk.com/");
		define("LOG_LOCATION", $docroot . "/../logs/error_log");	
		define("SERVER1_LOG", "http://fflsvcs.dev.nyc.wk.com/logging/index.php");
		define("SERVER2_LOG", "http://fflsvcs.dev.nyc.wk.com/logging/index.php");
		define("SERVER3_LOG", "http://fflsvcs.dev.nyc.wk.com/logging/index.php");
		define("LISTENER_STITCH_URL", "http://fflsvcs.dev.nyc.wk.com/listener_stitch.php");
		define("LISTENER_FINALMERGE_URL", "http://fflsvcs.dev.nyc.wk.com/listener_finalmerge.php");
		define("LISTENER_FINALPREMADE_URL", "http://fflsvcs.dev.nyc.wk.com/listener_finalpremade.php");
		define("LISTENER_ERROR_URL", "http://fflsvcs.dev.nyc.wk.com/listener_error.php");
		define("DEBUG", true);
		break;
	case "staging.ffl.sportsr.us": //staging
		define("ENV", "staging");
		define("LIB", "/var/www/vhosts/staging.ffl.sportsr.us/lib/");
		define("DB_HOST", "instance24599.db.xeround.com:16088");
		define("DB_NAME", "staging_ffl");
		define("DB_USER", "wknyc");
		define("DB_PASS", "Oakley99");
		define("WEBSERVICE_URL", "http://staging.ffl.sportsr.us/");
		define("LOG_LOCATION", $docroot . "/../logs/error_log");	
		define("SERVER1_LOG", "http://espn-ffl-stage1.sportsr.us/logging/index.php");
		define("SERVER2_LOG", "http://espn-ffl-stage2.sportsr.us/logging/index.php");
		define("SERVER3_LOG", "http://espn-ffl-stage3.sportsr.us/logging/index.php");
		define("LISTENER_STITCH_URL", "http://staging.ffl.sportsr.us/listener_stitch.php");
		define("LISTENER_FINALMERGE_URL", "http://staging.ffl.sportsr.us/listener_finalmerge.php");
		define("LISTENER_FINALPREMADE_URL", "http://staging.ffl.sportsr.us/listener_finalpremade.php");
		define("LISTENER_ERROR_URL", "http://staging.ffl.sportsr.us/listener_error.php");
		define("DEBUG", true);
		break;
	case "moderation.staging.ffl.sportsr.us": //staging - moderation
		define("ENV", "staging");
		define("LIB", "/var/www/vhosts/staging.ffl.sportsr.us/lib/");
		define("DB_HOST", "instance24599.db.xeround.com:16088");
		define("DB_NAME", "staging_ffl");
		define("DB_USER", "wknyc");
		define("DB_PASS", "Oakley99");
		define("WEBSERVICE_URL", "http://staging.ffl.sportsr.us/");
		define("LOG_LOCATION", $docroot . "/../logs/error_log");	
		define("SERVER1_LOG", "http://espn-ffl-stage1.sportsr.us/logging/index.php");
		define("SERVER2_LOG", "http://espn-ffl-stage2.sportsr.us/logging/index.php");
		define("SERVER3_LOG", "http://espn-ffl-stage3.sportsr.us/logging/index.php");
		define("LISTENER_STITCH_URL", "http://staging.ffl.sportsr.us/listener_stitch.php");
		define("LISTENER_FINALMERGE_URL", "http://staging.ffl.sportsr.us/listener_finalmerge.php");
		define("LISTENER_FINALPREMADE_URL", "http://staging.ffl.sportsr.us/listener_finalpremade.php");
		define("LISTENER_ERROR_URL", "http://staging.ffl.sportsr.us/listener_error.php");
		define("DEBUG", true);
		break;
	case "admin.staging.ffl.sportsr.us": //staging - admin
		define("ENV", "staging");
		define("LIB", "/var/www/vhosts/staging.ffl.sportsr.us/lib/");
		define("DB_HOST", "instance24599.db.xeround.com:16088");
		define("DB_NAME", "staging_ffl");
		define("DB_USER", "wknyc");
		define("DB_PASS", "Oakley99");
		define("WEBSERVICE_URL", "http://staging.ffl.sportsr.us/");
		define("LOG_LOCATION", $docroot . "/../logs/error_log");	
		define("SERVER1_LOG", "http://espn-ffl-stage1.sportsr.us/logging/index.php");
		define("SERVER2_LOG", "http://espn-ffl-stage2.sportsr.us/logging/index.php");
		define("SERVER3_LOG", "http://espn-ffl-stage3.sportsr.us/logging/index.php");
		define("LISTENER_STITCH_URL", "http://staging.ffl.sportsr.us/listener_stitch.php");
		define("LISTENER_FINALMERGE_URL", "http://staging.ffl.sportsr.us/listener_finalmerge.php");
		define("LISTENER_FINALPREMADE_URL", "http://staging.ffl.sportsr.us/listener_finalpremade.php");
		define("LISTENER_ERROR_URL", "http://staging.ffl.sportsr.us/listener_error.php");
		define("DEBUG", true);
		break;
	case "ffl.sportsr.us": //production
		define("ENV", "production");
		define("LIB", "/var/www/vhosts/ffl.sportsr.us/lib/");
		define("DB_HOST", "instance24599.db.xeround.com:16088");
		define("DB_NAME", "ffl");
		define("DB_USER", "wknyc");
		define("DB_PASS", "Oakley99");
		define("WEBSERVICE_URL", "http://ffl.sportsr.us/");
		define("LOG_LOCATION", $docroot . "/../logs/error_log");
		define("SERVER1_LOG", "http://espn-ffl-prod1.sportsr.us/logging/index.php");
		define("SERVER2_LOG", "http://espn-ffl-prod2.sportsr.us/logging/index.php");
		define("SERVER3_LOG", "http://espn-ffl-prod3.sportsr.us/logging/index.php");
		define("LISTENER_STITCH_URL", "http://ffl.sportsr.us/listener_stitch.php");
		define("LISTENER_FINALMERGE_URL", "http://ffl.sportsr.us/listener_finalmerge.php");
		define("LISTENER_FINALPREMADE_URL", "http://ffl.sportsr.us/listener_finalpremade.php");
		define("LISTENER_ERROR_URL", "http://ffl.sportsr.us/listener_error.php");
		define("DEBUG", false);
		break;
	case "moderation.ffl.sportsr.us": //production - moderation
		define("ENV", "production");
		define("LIB", "/var/www/vhosts/ffl.sportsr.us/lib/");
		define("DB_HOST", "instance24599.db.xeround.com:16088");
		define("DB_NAME", "ffl");
		define("DB_USER", "wknyc");
		define("DB_PASS", "Oakley99");
		define("WEBSERVICE_URL", "http://ffl.sportsr.us/");
		define("LOG_LOCATION", $docroot . "/../logs/error_log");
		define("SERVER1_LOG", "http://espn-ffl-prod1.sportsr.us/logging/index.php");
		define("SERVER2_LOG", "http://espn-ffl-prod2.sportsr.us/logging/index.php");
		define("SERVER3_LOG", "http://espn-ffl-prod3.sportsr.us/logging/index.php");
		define("LISTENER_STITCH_URL", "http://ffl.sportsr.us/listener_stitch.php");
		define("LISTENER_FINALMERGE_URL", "http://ffl.sportsr.us/listener_finalmerge.php");
		define("LISTENER_FINALPREMADE_URL", "http://ffl.sportsr.us/listener_finalpremade.php");
		define("LISTENER_ERROR_URL", "http://ffl.sportsr.us/listener_error.php");
		define("DEBUG", false);
		break;
	case "admin.ffl.sportsr.us": //production - admin
		define("ENV", "production");
		define("LIB", "/var/www/vhosts/ffl.sportsr.us/lib/");
		define("DB_HOST", "instance24599.db.xeround.com:16088");
		define("DB_NAME", "ffl");
		define("DB_USER", "wknyc");
		define("DB_PASS", "Oakley99");
		define("WEBSERVICE_URL", "http://ffl.sportsr.us/");
		define("LOG_LOCATION", $docroot . "/../logs/error_log");
		define("SERVER1_LOG", "http://espn-ffl-prod1.sportsr.us/logging/index.php");
		define("SERVER2_LOG", "http://espn-ffl-prod2.sportsr.us/logging/index.php");
		define("SERVER3_LOG", "http://espn-ffl-prod3.sportsr.us/logging/index.php");
		define("LISTENER_STITCH_URL", "http://ffl.sportsr.us/listener_stitch.php");
		define("LISTENER_FINALMERGE_URL", "http://ffl.sportsr.us/listener_finalmerge.php");
		define("LISTENER_FINALPREMADE_URL", "http://ffl.sportsr.us/listener_finalpremade.php");
		define("LISTENER_ERROR_URL", "http://ffl.sportsr.us/listener_error.php");
		define("DEBUG", false);
		break;
}

set_include_path(get_include_path() . PATH_SEPARATOR . LIB);

date_default_timezone_set('America/New_York'); 

/** non-environment-specific file locations */
define("ASSET_XML_LOCATION", LIB . "xml/assets.xml");
define("YOUTUBE_CREDS_XML_LOCATION", LIB . "xml/youtube_credentials.xml");

/** external system credentials */
define("ENCODING_USERID", "9937");
define("ENCODING_USERKEY", "ca6b96df5ccdd6b2187636b478a3a3a8");
define("FINALMERGE_S3_BUCKETNAME", "leetest");
define("FINALMERGE_S3_ACCESSKEY", "AKIAITDMF2HBDOXP6S4Q");
define("FINALMERGE_S3_SECRETKEY", "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");

/** external system URLs */
define("ESPN_EMAIL_API_URL", "http://games.espn.go.com/ffl/util/createCommissionerEmail?");
define("ESPN_CT_URL", "http://games.espn.go.com/ffl/commissionertoolkit?leagueId=");

/** misc settings */
define("MODERATION_PER_PAGE", 9);
define("REJECTED_THUMB_LOC", $_SERVER['DOCUMENT_ROOT'] . "/../moderation_src/data/rejected_video_thumbs/");
define("MAX_YOUTUBE_VIDEO_COUNT", "5000");
//define("CRITICAL_ERROR_NOTIFY_EMAILS", ); //FIXFIX

//fixfix externalize this into xml file
define("YOUTUBE_TITLE", "{league_name} Commissioner ESPN Interview");
define("YOUTUBE_DESC", "ESPN Fantasy Football commissioner {league_manager_name} discusses {league_name}'s upcoming season with Robert Flores via satellite feed.");
define("YOUTUBE_CATEGORY", "Sports");
define("YOUTUBE_TAGS", "Fantasy Football, Robert Flores, Football, League Inviter, ESPN, {league_name}, {league_manager_name}");

/** includes */
include LIB . "db_connectivity_v2.php";
include LIB . "data_objects/LeagueinviterTable.php";
include LIB . "data_objects/LeagueinviterMediaTable.php";
include LIB . "data_objects/LeagueinviterRejectTable.php";
include LIB . "data_objects/FbmapTable.php";
include LIB . "data_objects/YoutubeBucketTable.php";
include LIB . "data_objects/CriticalErrorTable.php";
include LIB . "FbmapManager.php";
include LIB . "LeagueInviterManager.php";
include LIB . "EncodingManager.php";
include LIB . "EncodingResponseManager.php";
include LIB . "ModerationManager.php";
include LIB . "AdminManager.php";
include LIB . "YoutubeManager.php";
include LIB . "ESPNEmail.php";
include LIB . "PHPTail.php";
include LIB . "Utils.php";
include LIB . "phpmailer/class.phpmailer.php";

require_once LIB . "Zend/Loader.php";

/** logging and error-handling includes */
include LIB . "CriticalErrorManager.php";
$CriticalErrorManager = new CriticalErrorManager;

include LIB . "Logger.php";
$Logger = new Logger;


?>