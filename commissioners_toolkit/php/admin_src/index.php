<?

include "../includes.inc.php";

$me = "stats";

$AdminManager = new AdminManager;
$total_array = $AdminManager->getStats();

?>

<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
	<title>w+k ffl admin</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="">
    <meta name="author" content="">
	
	<link href="/css/bootstrap.min.css" rel="stylesheet" />
	<link href="/css/prettyPhoto.css" rel="stylesheet" />

</head>

  <body>

	<? include "./nav.inc.php"; ?>

	<!-- container -->
	<div class="container-fluid">

		<!-- intro -->
		<div class="row-fluid">
	        <div class="jumbotron subhead">
				<h1>Stats</h1>
				<p class="lead">Real-time statistics for ESPN FFL Commissioner's Toolkit. 92% of statistics are made up; these are real.</p>
				<hr/>
			</div>				
		</div>
		<!-- /intro -->
	
		<!-- stats -->
		<div class="row-fluid" style="margin-bottom:15px">
			<div style="margin-bottom:15px">
				<h1><?=$total_array['visitors']?> unique toolkit visitors.</h1>
				<p>People who visited the Toolkit framework page at least one time.</p>
			</div>
			<div style="margin-bottom:15px">
				<h1><?=$total_array['videos_created']?> videos created.</h1>
				<p>Since users can delete videos, this is a real-time count of current videos that may be lower than the total-created-count.</p>
			</div>
			<div style="margin-bottom:15px">
				<h1><?=$total_array['personalized_videos']?> personalized videos created.</h1>
				<p>All personalized videos.</p>
			</div>
			<div style="margin-bottom:15px">
				<h1><?=$total_array['premade_videos']?> pre-made videos created.</h1>
				<p>All pre-made videos.</p>
			</div>
			<div style="margin-bottom:15px">
				<h1><?=$total_array['videos_approved']?> videos approved</h1>
				<p>All videos actively approved by ICUC.</p>
			</div>
			<div style="margin-bottom:15px">
				<h1><?=$total_array['videos_rejected']?> rejected videos.</h1>
				<p>Videos that were considered inappropriate and rejected by ICUC.</p>
			</div>
		</div>
		<!-- /stats -->

		

	</div>
	<!-- /container -->
	
	<? include "./jsincludes.inc.php"; ?>
	

</body>
</html>