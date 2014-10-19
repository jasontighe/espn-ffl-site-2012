package leelib.util.s3Util
{
	import com.hurlant.crypto.hash.HMAC;
	import com.hurlant.crypto.hash.SHA1;
	import com.hurlant.util.Base64;
	
	import flash.errors.IOError;
	import flash.events.DataEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.FileReference;
	import flash.utils.ByteArray;


	
	public class S3Util
	{
		private static var _accessKey:String;
		private static var _secretKey:String;
		
		private var fileReference:FileReference;
		private var request:S3PostRequest;

		private var _bucketName:String;
		private var _key:String;
		

		public function S3Util()
		{
		}

		// MUST BE SET IN ORDER TO USE
		public static function set accessKey($s:String):void
		{
			_accessKey = $s;
		}
		public static function get accessKey():String
		{
			return _accessKey;
		}
		
		// MUST BE SET IN ORDER TO USE. Write-only.
		public static function set secretKey($s:String):void
		{
			_secretKey = $s;
		}
		
		public function generatePolicy($bucketName:String, $key:String):Object 
		{
			_bucketName = $bucketName;
			_key = $key;

			var buffer:Array = new Array();
			buffer.indents = 0;
			
			write(buffer, "{\n");
			indent(buffer);
			
			// expiration
			var mm:String = "12";
			var dd:String = "31"
			var yyyy:String = "2019"

			write(buffer, "'expiration': '");
			write(buffer, yyyy);
			write(buffer, "-");
			write(buffer, mm);
			write(buffer, "-");
			write(buffer, dd);
			write(buffer, "T12:00:00.000Z'");
			write(buffer, ",\n");
			
			// conditions
			write(buffer, "'conditions': [\n");
			indent(buffer);
			
			// bucket
			writeSimpleCondition(buffer, "bucket", _bucketName, true);
			
			// key
			writeSimpleCondition(buffer, "key", _key, true);
			
			// acl - public-read, public-read-write, authenticated-read, private
			// (what happens if this is omitted?)
			writeSimpleCondition(buffer, "acl", "public-read", true); // xxx
			
			// Content-Type
			writeSimpleCondition(buffer, "Content-Type", "application/octet-stream", true);
			
			// Filename
			/**
			 * FileReference.Upload sends along the "Filename" form field.
			 * The "Filename" form field contains the name of the local file being
			 * uploaded.
			 * 
			 * See http://livedocs.adobe.com/flex/2/langref/flash/net/FileReference.html for more imformation
			 * about the FileReference API.
			 * 
			 * Since there is no provided way to exclude this form field, and since
			 * Amazon S3 POST interface requires that all form fields are handled by
			 * the policy document, we must always add this 'starts-with' condition that 
			 * allows ANY 'Filename' to be specified.  Removing this condition from your
			 * policy will result in Adobe Flash clients not being able to POST to Amazon S3.
			 */
			writeCondition(buffer, "starts-with", "$Filename", "", true);
			
			// success_action_status
			/**
			 * Certain combinations of Flash player version and platform don't handle
			 * HTTP responses with the header 'Content-Length: 0'.  These clients do not
			 * dispatch completion or error events when such a response is received.
			 * Therefore it is impossible to tell when the upload has completed or failed.
			 * 
			 * Flash clients should always set the success_action_status parameter to 201
			 * so that Amazon S3 returns a response with Content-Length being non-zero.
			 * The policy sent along with the POST MUST therefore contain a condition
			 * enabling use of the success_action_status parameter with a value of 201.
			 * 
			 * There are many possible conditions satisfying the above requirements.
			 * This policy generator adds one for you below.
			 */
			writeCondition(buffer, "eq", "$success_action_status", "201", true);
			
			write(buffer, "\n");
			outdent(buffer);
			write(buffer, "]");
			
			write(buffer, "\n");
			outdent(buffer);
			write(buffer, "}");
			
			// Now sign it
			var unsignedPolicy:String = buffer.join("");
			var policy:String = Base64.encode(unsignedPolicy);
			var signature:String = generateSignature(policy, _secretKey);
			
			return { policy: policy, signature: signature }
		}
		
		private function generateSignature(data:String, secretKey:String):String {
			
			var secretKeyByteArray:ByteArray = new ByteArray();
			secretKeyByteArray.writeUTFBytes(secretKey);
			secretKeyByteArray.position = 0;
			
			var dataByteArray:ByteArray = new ByteArray();
			dataByteArray.writeUTFBytes(data);
			dataByteArray.position = 0;
			
			var hmac:HMAC = new HMAC(new SHA1());            
			var signatureByteArray:ByteArray = hmac.compute(secretKeyByteArray, dataByteArray);
			return Base64.encodeByteArray(signatureByteArray);
		}

		//
		
		private function write(buffer:Array, value:String):void {
			if(buffer.length > 0) {
				var lastPush:String =  String(buffer[buffer.length-1]);
				if(lastPush.length && lastPush.charAt(lastPush.length - 1) == "\n") {
					writeIndents(buffer);
				}
			}
			buffer.push(value);
		}
		
		private function indent(buffer:Array):void {
			buffer.indents++;
		}
		
		private function outdent(buffer:Array):void {
			buffer.indents = Math.max(0, buffer.indents-1);
		}
		
		private function writeIndents(buffer:Array):void {
			for(var i:int=0;i<buffer.indents;i++) {
				buffer.push("    ");
			}
		}
		
		private function writeCondition(buffer:Array, type:String, name:String, value:String, commaNewLine:Boolean):void {
			write(buffer, "['");
			write(buffer, type);
			write(buffer, "', '");
			write(buffer, name);
			write(buffer, "', '");
			write(buffer, value);
			write(buffer, "'");
			write(buffer, "]");
			if(commaNewLine) {
				write(buffer, ",\n");
			}
			
		}
		
		private function writeSimpleCondition(buffer:Array, name:String, value:String, commaNewLine:Boolean):void {
			write(buffer, "{'");
			write(buffer, name);
			write(buffer, "': ");
			write(buffer, "'");
			write(buffer, value);
			write(buffer, "'");
			write(buffer, "}");
			if(commaNewLine) {
				write(buffer, ",\n");
			}
		}
		
		
		private function browse():void 
		{
			this.fileReference = new FileReference();
			
			// setup file reference event handlers
			fileReference.addEventListener(Event.CANCEL, function(event:Event):void 
			{
				setProgress(0);
				trace("Upload cancelled");
			});
			
			fileReference.addEventListener(Event.SELECT, function(event:Event):void 
			{
				// at this point, a file has been selected
				
				// build a S3PostOptions object using the various input fields on the page
				var options:S3PostOptions = new S3PostOptions();
				options.secure = false; // (no https)
				options.acl = "public-read";
				options.contentType = "image/jpeg";
//				options.policy = _policy;
//				options.signature = _signature;
				
				// do the post
				post(_accessKey, _bucketName, _key, options, fileReference);
			});
			
			fileReference.browse();
		}
		
		private function post(accessKeyId:String, bucket:String, key:String, options:S3PostOptions, fileReference:FileReference):void {
			
			// create the post request
			this.request = new S3PostRequest(accessKeyId, bucket, key, options);
			
			// hook up the user interface
			request.addEventListener(Event.OPEN, function(event:Event):void {
				trace("Upload started: " + fileReference.name);
			});
			request.addEventListener(ProgressEvent.PROGRESS, function(event:ProgressEvent):void {
				setProgress(Math.floor(event.bytesLoaded/event.bytesTotal * 100));
			});
			request.addEventListener(IOErrorEvent.IO_ERROR, function(event:IOErrorEvent):void {
				trace("An IO error occurred: " + event);
			});
			request.addEventListener(SecurityErrorEvent.SECURITY_ERROR, function(event:SecurityErrorEvent):void {
				trace("A security error occurred: " + event);
			});
			request.addEventListener(DataEvent.UPLOAD_COMPLETE_DATA, function(event:Event):void {
				trace("Upload complete!");
				trace("Upload completed: " + event);
			});
			
			try {
				// submit the post request
				request.uploadFileReference(fileReference);
			} catch(e:Error) {
				trace("Upload error!");
				trace("An error occurred: " + e);
			}
		}
		
		private function setProgress(percent:uint):void {
			trace(percent);
		}
		
	}
}