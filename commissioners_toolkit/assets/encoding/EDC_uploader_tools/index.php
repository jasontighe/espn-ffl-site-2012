<html>
<head>
<title>Encoding.com video uploader</title>

<link href="encoding.com_uploader.css" media="all" rel="stylesheet" type="text/css" />
<script src="encoding.com_uploader.js" type="text/javascript"></script>

</head>

	<body>
<?php
    require_once("config.php");
?>
		<form id="upload" name="upload" enctype="multipart/form-data" 
		  action="<?=UPLOADING_SERVER?>/upload" target="uploadframe"  method="post">
			
			<input type="hidden" id="uid" name="uid" value="0" />
			<input type="hidden" id="sid" name="sid" value="0" />
			<input type="hidden" id="timestamp" name="timestamp" value="0" />
			<input type="hidden" id="signature" name="signature" value="0" />
			<input name="userfile" id="userfile" type="file" label="fileupload" />
			<input type="button" id="submit-form" value="Send File" disabled />
		</form>
		
		<iframe id="uploadframe" name="uploadframe" width="0" height="0" frameborder="0" border="0" ></iframe>
		<br/>
		<div id="progress"> </div>
	<div> </div>
	</body>
</html>