<?

include "../../includes.inc.php";

$me = "logs";

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
	<link href="/css/application.css" rel="stylesheet" />

</head>

  <body>

	<? include "../nav.inc.php"; ?>

	<!-- container -->
	<div class="container-fluid">

		<!-- intro -->
		<div class="row-fluid">
	        <div class="jumbotron subhead">
				<h1>Logs</h1>
				<p class="lead">Real-time system logs for all FFL CT webservers.</p>
				<hr/>
			</div>				
		</div>
		<!-- /intro -->
	
		<!-- stats -->
		<div class="row-fluid" style="margin-bottom:15px">
			<div class="span12">
				<span class="label label-info">espn-ffl-prod1</span> <small><a href="<?=SERVER1_LOG?>" target="_blank">open in new window</a></small>
				<p class="well"><iframe src="<?=SERVER1_LOG?>"></iframe></p>
			</div>
		</div>
		<div class="row-fluid" style="margin-bottom:15px">
			<div class="span12">
				<span class="label label-info">espn-ffl-prod2</span> <small><a href="<?=SERVER2_LOG?>" target="_blank">open in new window</a></small>
				<p class="well"><iframe src="<?=SERVER2_LOG?>"></iframe></p>
			</div>
		</div>
		<div class="row-fluid" style="margin-bottom:15px">
			<div class="span12">
				<span class="label label-info">espn-ffl-prod3</span> <small><a href="<?=SERVER3_LOG?>" target="_blank">open in new window</a></small>
				<p class="well"><iframe src="<?=SERVER3_LOG?>"></iframe></p>
			</div>
		</div>
		<!-- /stats -->

		

	</div>
	<!-- /container -->
	
	<? include "../jsincludes.inc.php"; ?>
	

</body>
</html>