<?

include "../../includes.inc.php";

if(isset($_REQUEST['league_id'])){
	$LeagueInviterManager = new LeagueInviterManager;
				if($ugc_assets_array = $LeagueInviterManager->getUGCAssets($_REQUEST['league_id'])){
					$EncodingManager = new EncodingManager;
					if($media_id = $EncodingManager->sendFinalmerge($_REQUEST['league_id'], $ugc_assets_array)){
						$LeagueInviterManager->addFinalmergePlaceholder($_REQUEST['league_id'], $media_id);
						echo "i have a media id and it is $media_id";
					} else {
						echo "cannot send to encoding.com";
					}
				} else {
					error_log("FFL: " . "OH SHIT I BE BROKE");
					echo "OH SHIT I BE BROKE";
				}

}

?>

<form action="test_finalmerge.php">
league id: <input type="text" name="league_id" value="" />
<input type="submit" name="submit" value="submit" />
</form>