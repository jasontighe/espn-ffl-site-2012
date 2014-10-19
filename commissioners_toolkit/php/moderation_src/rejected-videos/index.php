<?

include "../../includes.inc.php";

if(!isset($_REQUEST['sort'])){
	$sort = "date";
	$dir = "asc";
	$page = "1";
} else {
	$sort = $_REQUEST['sort'];
	$dir = $_REQUEST['dir'];
	$page = $_REQUEST['page'];
}

$ModerationManager = new ModerationManager;
$rejected_array = $ModerationManager->getRejected($page);
$total_records = $ModerationManager->getRejectedTotal();
$total_pages = ceil($total_records / MODERATION_PER_PAGE);

$all_totals = $ModerationManager->getAllTotals();

$me = "rejected";

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
				<h1>Rejected Videos</h1>
				<p class="lead">These videos have been rejected, removed from YouTube, and their creators notified via email.</p>
				<hr/>
			</div>				
		</div>
		<!-- /intro -->
		
		<div class="row-fluid">
			<div class="span12">
			
				<?if(!is_array($rejected_array)){?>
					There are no rejected videos to display.
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
					<? foreach($rejected_array as $vid){ ?>
						<div class="span4" style="margin-left:0; margin-bottom:30px">
							<div class="row-fluid">
								<div class="span12">
									<h3>League ID #<?=$vid['league_id']?></h3>
									<div class="row-fluid">
										<div class="span6">
										
											<p style="margin-top:5px"><a href="http://www.maxilamba.com/player.swf?width=480&amp;height=340&amp;flashvars=file=<?=$vid['s3_url']?>&image=http://www.maxilamba.com/embed.jpg" target="_blank" rel="prettyPhoto" title="<?=$vid['league_id']?>"><img src="/data/rejected_video_thumbs/<?=$vid['thumb_filename']?>" /></a></p>
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
				<div class="span12">
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
				social_tools: '<div class="pp_social" id="pp_buttons"></div>'
			});
		});
	</script>
	<script language="javascript" src="/js/application.js"></script>
	
</body>
</html>