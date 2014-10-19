<?

define("LIB", $_SERVER['DOCUMENT_ROOT'] . "php/lib/");

define("DB_NAME", "ffl");
define("DB_USER", "ffl");
define("DB_PASS", "ffl");

include LIB . "db_connectivity_v2.php";
include LIB . "data_objects/LeagueinviteTable.php";
include LIB . "data_objects/FbmapTable.php";

include LIB . "LeagueinviteManager.php";
include LIB . "FbmapManager.php";

?>