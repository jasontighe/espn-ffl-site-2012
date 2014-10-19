<?
$env = "dev";

if($env == "dev"){
	define("LIB", $_SERVER['DOCUMENT_ROOT'] . "php/lib/");
	define("DB_HOST", "localhost");
	define("DB_NAME", "ffl");
	define("DB_USER", "ffl");
	define("DB_PASS", "ffl");
} else {
	define("LIB", "/var/www/vhosts/ffl.sportsr.us/lib/");
	define("DB_HOST", "instance23188.db.xeround.com:15192");
	define("DB_NAME", "ffl");
	define("DB_USER", "wknyc");
	define("DB_PASS", "Oakley99");
}

define("ASSET_XML_LOCATION", LIB . "xml/assets.xml");

define("ENCODING_USERID", "9937");
define("ENCODING_USERKEY", "ca6b96df5ccdd6b2187636b478a3a3a8");

define("LISTENER_STITCH_URL", "http://ffl.sportsr.us/listener_stitch.php");
define("LISTENER_ERROR_URL", "http://ffl.sportsr.us/listener_error.php");

include LIB . "db_connectivity_v2.php";
include LIB . "data_objects/LeagueinviterTable.php";
include LIB . "data_objects/LeagueinviterMediaTable.php";

include LIB . "LeagueInviterManager.php";
include LIB . "EncodingManager.php";
include LIB . "EncodingResponseManager.php";

?>