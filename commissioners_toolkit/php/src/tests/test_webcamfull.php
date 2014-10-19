<?

$shit = array(
	urlencode("http://pc-upload.s3.amazonaws.com/30d0c75f4b1f9a8fb82b0469e2c620f7_31513.flv?nocopy"),
	urlencode("http://pc-upload.s3.amazonaws.com/b9b0848e6d7aa35ba1473e6ac87dc30b_31514.flv?nocopy"),
	urlencode("http://pc-upload.s3.amazonaws.com/3ecb88e6e957008a8ae4496244cd4545_31515.flv?nocopy"),
	urlencode("http://pc-upload.s3.amazonaws.com/8f0cd8b6e4e17b3e13cc4c2eada24b63_31516.flv?nocopy"),
	urlencode("http://pc-upload.s3.amazonaws.com/e17c350c8f5a2fc47ce37b70e704fd8f_31517.flv?nocopy"),
	urlencode("http://pc-upload.s3.amazonaws.com/68fab4a456537a0c1402f6087f31f189_31519.flv?nocopy")
);

?>

<? foreach($shit as $key => $fuck){ ?>
	<a href="http://<?=$_SERVER['SERVER_NAME']?>/webcam.php?league_id=100&webcam_num=<?=$key+1?>&length=4&webcam_url=<?=$fuck?>" target="_blank">webcam <?=$key+1?></a>
<? } ?>