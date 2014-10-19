Encoding.com uploader scripts installation guide. v. 1.1

The audience for this document is intended to be web script authors, software developers and system administrators.


Introduction:

The Encoding.com User Uploader Script enables the direct upload of User Generated Video (UGV) content to Encoding.com storage so you can avoid a workflow where users first upload to your storage location and then having Encoding.com "re-download" from your storage location to begin processing. This guide will help you to implement the User Uploader Script into your workflow.

To receive media files, Encoding.com uses a special uploading server - upload.encoding.com. Only Encoding.com users are able to access this service. Each upload request must contain an Encoding.com user ID and special signature (API key) to authorize the user.

Once the video file is received, we will extract the MediaInfo (technical parameters of the video) and move the file to S3 storage, and it's now ready to be processed.  The uploading service will return a new file destination URL, and the URL for the XML file that contains the MediaInfo.  During this process, users can get progress status and percentage completed.

How it works:

To better understand the uploading service, please see the example scripts. First, unpack the provided .zip file, and then copy these files to your web server into the website's public path in a root directory or any other subfolder. The provided files also include a simple form for showing progress and upload status (Progress.php).

First, please set up your authorization options. In config.php you need to change values in the following two lines (YOUR_USER_ID and YOUR_USER_KEY):

define("USER_ID", "YOUR_USER_ID");
define("USER_KEY", "YOUR_USER_KEY");

This will allow you to start usage of the uploader tool.

To integrate the Uploader Script into one of your existing website pages, please add the following code to the head section:

<link href="encoding.com_uploader.css" media="all" rel="stylesheet" type="text/css" />
<script src="encoding.com_uploader.js" type="text/javascript"></script>

And, add the following form into the body section of your page:

<form id="upload" name="upload" enctype="multipart/form-data" action="https://upload.encoding.com/upload" target="uploadframe" method="post">
                                                
<input type="hidden" id="uid" name="uid" value="0" />
<input type="hidden" id="sid" name="sid" value="0" />
<input type="hidden" id="timestamp" name="timestamp" value="0" />
<input type="hidden" id="signature" name="signature" value="0" />
<input name="userfile" id="userfile" type="file" label="fileupload" />
<input type="button" id="submit-form" value="Send File" disabled />
</form>
<div id="progress"></div>
<iframe id="uploadframe" name="uploadframe" width="0" height="0" frameborder="0" border="0" ></iframe>

When a user uploads a video using this form, the script will call Signer.php which will return values for uid, sid, timestamp and signature fields. Each source video should have a unique sid.  See Signer.php to understand how it works.

<?
...

date_default_timezone_set('Europe/London');

$retval = array();

$retval['timestamp'] = date("Y-m-d H:i:s O");
$retval['sid'] = md5(uniqid($_SERVER['HTTP_HOST'] . USER_KEY,true));
$retval['signature'] = hash("sha256", $retval['timestamp'] . $retval['sid'] . USER_KEY);
$retval['uid'] = USER_ID;
?>


Setting up a different path for php scripts:

By default, the PHP scripts included in this package must be stored in the same directory as the page with the Uploader form.  You may customize different paths by opening the following file: encoding.com_uploader.js 

Change line:

var script_path = '';

to something like this:

var script_path = '/YOUR/PATH/';

Uploading Status and Progress:

While a file is uploading to the server, the script periodically requests progress information from the server. Uploading process consists of two parts:

1. uploading file from client PC to server
2. uploading file from server to s3 bucket

Each step should return its own progress information. That information could be requested by calls:

https://upload.encoding.com/progress?X-Progress-ID={SID} - returns percentage of 1st step progress
https://upload.encoding.com/s3info.php?sid={SID} - returns percentage of 2nd step progress
https://upload.encoding.com/fileinfo.php?sid={SID} - returns result URL

First call returns JSON object like this:

new Object({ 'state' : 'uploading', 'received' : 5340229, 'size' : 21269377 })

When state value become 'done', it means step 1 is done and we should call the 2nd step.

Second call returns JSON object like this:

new Object({"progress":"81","state":"done"})

When progress value reaches 101, it means step 2 is done and the final URLs are ready to be retrieved via the 3rd step.

Fileinfo.php returns JSON object with urls.

{"filename":"http:\/\/pc-upload.s3.amazonaws.com\/e716afec11b7865c5b2461242a5c891fc_111.mkv","mediainfo":"http:\/\/upload.encoding.com\/mediainfo\/e716afec11b7865c5b2461242a5c891fc.xml","error":""}


Those calls are implemented in Progress.php file and can be changed by the "action" variable.

Stored files will be available on a server and s3 storage for 14 days.

To get the current uploading status in JS script, you could use the variable from FileUploader.callback function which is called periodically during the upload. The function contains variable [response] (JSON Object) with the current state: response.status (starting, uploading, processing, done, error), response.size (total size of the file in the bytes) and response.received (loaded bytes). Thus, it can be used to create your custom progress bar.

When upload is successfully completed (response.status is done), you can then retrieve a path to the file by using the filename variable.

Get Media Info
When upload is successfully completed, Encoding.com will analyze the file and generate an XML document with complete MediaInfo data which can be used when generating the AddMedia request. The link to the file will be in the MediaInfo variable.

To access those variables, see encoding.com_uploader.js FileUploader.callback function.

Response.state param describes eachstep of the uploading process. 

starting - process is starting now.
uploading - file is being uploaded.
processing - File has been uploaded and now is being processed.
done - File has been finally uploaded and processed.
error - An error was occurred and file uploading had aborted.

