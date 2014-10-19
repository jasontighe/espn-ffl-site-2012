<?

include "../../includes.inc.php";

if(!isset($_REQUEST['sort'])){
	$sort = "date";
	$dir = "desc";
	$page = "1";
} else {
	$sort = $_REQUEST['sort'];
	$dir = $_REQUEST['dir'];
	$page = $_REQUEST['page'];
}

$ModerationManager = new ModerationManager;
$approved_array = $ModerationManager->getApproved($sort, $dir, $page);
$total_records = $ModerationManager->getApprovedTotal();
$total_pages = ceil($total_records / MODERATION_PER_PAGE);

$all_totals = $ModerationManager->getAllTotals();

$me = "approved";

?>

<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
	<title>FFL Commisioner Toolkit - Content Moderation System</title>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="">
    <meta name="author" content="">
	
	<link href="/css/bootstrap.min.css" rel="stylesheet" />
	<link href="/css/prettyPhoto.css" rel="stylesheet" />

</head>

  <body>

	<? include "../nav.inc.php"; ?>

	<!-- container -->
	<div class="container-fluid">

		<!-- intro -->
		<div class="row-fluid">
	        <div class="jumbotron subhead">
				<h1>Approved Videos</h1>
				<p class="lead">These videos have been approved. If you change your mind and want to reject an approved video, click the "reject" button.</p>
				<hr/>
			</div>				
		</div>
		<!-- /intro -->
		
		<div class="row-fluid">
			<div class="span2">
				<!-- left side -->
					<div class="well sidebar-nav">
						<ul class="nav nav-list">
							<li class="nav-header">SORT BY</li>
							<li <?if(($sort=="date")&&($dir=="desc")){?>class="active"<?}?>><a href="index.php?sort=date&dir=desc&page=1">Date (newest first)</a></li>
							<li <?if(($sort=="date")&&($dir=="asc")){?>class="active"<?}?>><a href="index.php?sort=date&dir=asc&page=1">Date (oldest first)</a></li>
							<li <?if(($sort=="leaguename")&&($dir=="asc")){?>class="active"<?}?>><a href="index.php?sort=leaguename&dir=asc&page=1">League Name (a-z)</a></li>
							<li <?if(($sort=="leaguename")&&($dir=="desc")){?>class="active"<?}?>><a href="index.php?sort=leaguename&dir=desc&page=1">League Name (z-a)</a></li>
						</ul>
					</div>
				<!-- /left side -->
			</div>
			<div class="span10">

				<div class="alert alert-error hide" id="error_message">
					<a class="close" data-dismiss="alert" href="#">×</a>
					<h4 class="alert-heading">Uh oh.</h4>
					A database error has occurred. Please notify W+K immediately.
				</div>

				<?if(!is_array($approved_array)){?>
					There are no approved videos to display.
				<?} else {?>
				
					<!-- pagination -->
					<div class="pagination">
						<ul>
							<?
								if($page == "1"){
									$prevclass = "disabled";
									$prevnum = "";
									$url = "";
								} else {
									$prevclass = "";
									$prevnum = $page - 1;
									$url = "index.php?sort=$sort&dir=$dir&page=$prevnum";
								}
							?>
							<li class="<?=$prevclass?>"><a href="<?=$url?>">«</a></li>
							<?
								$lastpage = $total_pages;
								$printed_ellipsis = false;
								for($page_number = 1; $page_number <= $lastpage; $page_number++) {
									$url = "index.php?sort=$sort&dir=$dir&page=$page_number";
									
									if ($page_number > 4 && !$printed_ellipsis) {
										echo '<li class="disabled"><a href="#">&hellip;</a></li>';
										$page_number = max(0, $lastpage - 3);
										$printed_ellipsis = true;
									}
									if($page_number == $page) {
										echo "<li class=\"active\"><a href=\"\">$page_number</a></li>";
									} else {
										echo "<li><a href=\"$url\">$page_number</a></li>";
									}
								}
							?>
							<?
								if($page == $total_pages){
									$nextclass = "disabled";
									$nextnum = "";
									$url = "";
								} else {
									$nextclass = "";
									$nextnum = $page + 1;
									$url = "index.php?sort=$sort&dir=$dir&page=$nextnum";
								}
							?>
							<li class="<?=$nextclass?>"><a href="<?=$url?>">»</a></li>
						</ul>
					</div>
					<!-- /pagination -->
				
					<!-- videos -->
					<? foreach($approved_array as $vid){ ?>
						<div class="span4" style="margin-left:0; margin-bottom:30px">
							<div class="row-fluid">
								<div class="span12">
									<h3>League ID #<?=$vid['league_id']?></h3>
									<div class="row-fluid">
										<div class="span6">
											<p style="margin-top:5px"><a href="<?=$vid['youtube_url']?>" rel="prettyPhoto" title="<?=$vid['league_id']?>"><img src="http://img.youtube.com/vi/<?=$vid['youtube_id']?>/0.jpg" /></a></p>
										</div>
										<div class="span6" style="font-size:85% !important">
											<div style="margin-bottom:9px; line-height:11px">
												<b>League Name:</b><br/>
												<?=$vid['league_name']?>
											</div>
											<div style="margin-bottom:9px; line-height:11px">
												<b>LM Name:</b><br/>
												<?=$vid['league_manager_name']?>
											</div>
											<div style="margin-bottom:9px; line-height:11px">
												<a class="btn btn-mini btn-danger" rel="reject" data-vid="<?=$vid['league_id']?>">REJECT</a>
											</div>
										</div>
									</div>
								</div>
							</div>
						</div>
					<? } ?>
					<!-- /videos -->
				</div>
			</div>
	
			<div class="row-fluid">
				<div class="span2"></div>
				<div class="span10">
					<div class="pagination">
						<ul>
							<?
								if($page == "1"){
									$prevclass = "disabled";
									$prevnum = "";
									$url = "";
								} else {
									$prevclass = "";
									$prevnum = $page - 1;
									$url = "index.php?sort=$sort&dir=$dir&page=$prevnum";
								}
							?>
							<li class="<?=$prevclass?>"><a href="<?=$url?>">«</a></li>
							<?
								$lastpage = $total_pages;
								$printed_ellipsis = false;
								for($page_number = 1; $page_number <= $lastpage; $page_number++) {
									$url = "index.php?sort=$sort&dir=$dir&page=$page_number";
									
									if ($page_number > 4 && !$printed_ellipsis) {
										echo '<li class="disabled"><a href="#">&hellip;</a></li>';
										$page_number = max(0, $lastpage - 3);
										$printed_ellipsis = true;
									}
									if($page_number == $page) {
										echo "<li class=\"active\"><a href=\"\">$page_number</a></li>";
									} else {
										echo "<li><a href=\"$url\">$page_number</a></li>";
									}
								}
							?>
							<?
								if($page == $total_pages){
									$nextclass = "disabled";
									$nextnum = "";
									$url = "";
								} else {
									$nextclass = "";
									$nextnum = $page + 1;
									$url = "index.php?sort=$sort&dir=$dir&page=$nextnum";
								}
							?>
							<li class="<?=$nextclass?>"><a href="<?=$url?>">»</a></li>
						</ul>
					</div>
					<!-- /pagination -->
				
				<?}?>

			</div>
		</div>

	</div>
	<!-- /container -->

	<!-- hidden fields for IDs -->
	<input type="hidden" id="reject_video_id" value="" />
	<input type="hidden" id="ignore_video_id" value="" />
	<!-- /hidden fields for IDs -->
	
	<!-- modals -->
		<!-- pleasewait -->
		<div class="modal hide" id="modal_pleasewait">
  			<div class="modal-header"><button type="button" class="close" data-dismiss="modal">×</button><h3>Please wait.</h3></div>
			<div class="modal-body"><p>Please wait while I modify the database...</p></div>
		</div>
		<!-- /pleasewait -->
		<!-- reject -->
		<div class="modal hide" id="modal_reject">
  			<div class="modal-header"><button type="button" class="close" data-dismiss="modal">×</button><h3>Reject Video?</h3></div>
			<div class="modal-body"><p>Are you sure you wish to reject this video? Rejected videos cannot be restored; this is a permanent deletion. The video will be removed from YouTube, and an email will be sent to the League Manager.</p></div>
			<div class="modal-footer"><a href="#" class="btn" data-dismiss="modal">NO, cancel</a><a href="#" class="btn btn-danger" rel="do_reject" data-dismiss="modal">YES, reject</a></div>
		</div>
		<!-- /reject -->
	<!-- /modals -->

	<script language="javascript">
		var webservice_url = "<?=WEBSERVICE_URL?>";
	</script>
	<script language="javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/1.7.2/jquery.min.js"></script>
	<script language="javascript" src="/js/bootstrap.min.js"></script>
	<script language="javascript" src="/js/jquery.prettyPhoto.js"></script>
	<script language="javascript">
		$(document).ready(function(){
			$("a[rel^='prettyPhoto']").prettyPhoto({
				deeplinking: false,
				social_tools: '<div class="pp_social" id="pp_buttons"><a class="btn btn-small btn-danger" rel="reject">REJECT video</a></div>'
			});
		});
	</script>
	<script language="javascript" src="/js/application.js"></script>
	
</body>
</html>