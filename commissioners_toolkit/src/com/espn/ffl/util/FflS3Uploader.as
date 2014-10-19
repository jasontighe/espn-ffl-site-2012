package com.espn.ffl.util
{
	import com.espn.ffl.model.ConfigModel;
	
	import flash.display.BitmapData;
	import flash.events.DataEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.FileReference;
	import flash.utils.ByteArray;
	
	import leelib.ExtendedEvent;
	import leelib.appropriated.Guid;
	import leelib.appropriated.JPEGEncoder;
	import leelib.graphics.GrUtil;
	import leelib.util.Out;
	import leelib.util.s3Util.S3PostOptions;
	import leelib.util.s3Util.S3PostRequest;
	import leelib.util.s3Util.S3Util;
	
	
	public class FflS3Uploader extends EventDispatcher
	{
		public static const EVENT_COMPLETE:String = "ffls3u.eventComplete";
		public static const EVENT_ERROR:String = "ffls3u.eventError";		
		

		// MUST BE HARDCODED:
		private static const S3_SECRETKEY:String = "Ul18uiOnokPSCjL8xkQqIIa7/Tc9UnKGc1X2VuVm"; // <-- lee's test account
		
		
		private var _s3Post:S3PostRequest;
		
		private var _haveRequested:Boolean;
		private var _id:uint;
		

		public function FflS3Uploader()
		{
		}
		
		
		// Uploads a file to S3. Uses randomized filename with optional file suffix.
		//
		public function upload($ba:ByteArray, $fileSuffix:String=null):void
		{
			if (_haveRequested) {
				throw new Error("Use a new instance each time, thanks");
			}
			_haveRequested = true;
			
			S3Util.accessKey = ConfigModel.gi.s3AccessKey;
			S3Util.secretKey = S3_SECRETKEY;
			
			// make key
			var keyName:String = new Date().getTime().toString() + "_" + Guid.create();
			if ($fileSuffix) {
				if ($fileSuffix.indexOf(".") != 0) $fileSuffix = "." + $fileSuffix;
				keyName += $fileSuffix;
			}
			var s3u:S3Util = new S3Util();
			var o:Object = s3u.generatePolicy(ConfigModel.gi.s3BucketName, keyName);
			var policy:String = o.policy;
			var signature:String = o.signature;
			
			// rem, these vals must match up with what was used to generate the policy
			var options:S3PostOptions = new S3PostOptions();
			options.secure = false; // (no https)
			options.acl = "public-read";
			options.contentType = "application/octet-stream";
			options.policy = policy;
			options.signature = signature;			
			
			//
			
			_s3Post = new S3PostRequest(S3Util.accessKey, ConfigModel.gi.s3BucketName, keyName, options);
			_s3Post.addEventListener(IOErrorEvent.IO_ERROR, onS3PostIoError);
			_s3Post.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onS3PostSecurityError);
			_s3Post.addEventListener(ProgressEvent.PROGRESS, onS3PostProgress);
			_s3Post.addEventListener(Event.COMPLETE, onS3Complete);
			_s3Post.uploadByteArray($ba);
		}
		
		// 'CONTROL' TEST
		//
		public function uploadFileReferenceTest($fileReference:FileReference):void
		{
			if (_haveRequested) {
				throw new Error("Use a new instance each time, thanks");
			}
			_haveRequested = true;

			S3Util.accessKey = ConfigModel.gi.s3AccessKey;
			S3Util.secretKey = S3_SECRETKEY;
			
			// make key
			var keyName:String = new Date().getTime().toString() + "_" + Guid.create();
			var s3u:S3Util = new S3Util();
			var o:Object = s3u.generatePolicy(ConfigModel.gi.s3BucketName, keyName);
			var policy:String = o.policy;
			var signature:String = o.signature;
			
			// rem, these vals must match up with what was used to generate the policy
			var options:S3PostOptions = new S3PostOptions();
			options.secure = false; // (no https)
			options.acl = "public-read";
			options.contentType = "application/octet-stream";
			options.policy = policy;
			options.signature = signature;			
			
			//
			
			_s3Post = new S3PostRequest(S3Util.accessKey, ConfigModel.gi.s3BucketName, keyName, options);
			_s3Post.addEventListener(IOErrorEvent.IO_ERROR, onS3PostIoError);
			_s3Post.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onS3PostSecurityError);
			_s3Post.addEventListener(ProgressEvent.PROGRESS, onS3PostProgress);
			_s3Post.addEventListener(Event.COMPLETE, onS3Complete);
			
			_s3Post.uploadFileReference($fileReference);
		}
		
		private function onS3PostIoError($e:IOErrorEvent):void
		{
			Out.e('FflS3Uploader.onS3PostIoError()', $e.text);
			clearReferences();
			this.dispatchEvent(new ExtendedEvent(EVENT_ERROR, $e.text));
		}
		
		private function onS3PostSecurityError($e:SecurityErrorEvent):void 
		{
			Out.e('FflS3Uploader.onS3PostSecurityError()', $e.text);
			clearReferences();
			this.dispatchEvent(new ExtendedEvent(EVENT_ERROR, $e.text));
		}
		
		private function onS3PostProgress($e:ProgressEvent):void
		{
			Out.d('FflS3Uploader.onS3PostProgress()', $e.bytesLoaded, '/', $e.bytesTotal);
			this.dispatchEvent($e);
		}
		
		/*
			Example response:
		
			<PostResponse>
				<Location>http://leetest.s3.amazonaws.com/1276141208361_099A3C9B_74C7_0FBB_C54C_75399BD37302</Location>
				<Bucket>leetest</Bucket>
				<Key>1276141208361_099A3C9B_74C7_0FBB_C54C_75399BD37302</Key>
				<ETag>"f3250ad898836ae96b5d5aa01916811d"</ETag>
			</PostResponse>
		*/
		private function onS3Complete($e:ExtendedEvent):void
		{
			var response:String = $e.object as String;

			clearReferences();
			
			var xml:XML = new XML(response);
			if (xml.Location[0] && xml.Location[0].toString().length > 0)
			{
				var uploadedS3FileUrl:String = xml.Location[0].toString();
				Out.i('FflS3Uploader.onS3Complete() - SUCCESS:', uploadedS3FileUrl);
				this.dispatchEvent(new ExtendedEvent(EVENT_COMPLETE, uploadedS3FileUrl));
			}
			else
			{
				Out.e('FflS3Uploader.onS3Complete() - FAILED:', response);
				this.dispatchEvent(new ExtendedEvent(EVENT_ERROR, response));
			}
		}
		
		private function clearReferences():void
		{
			if (_s3Post) {
				_s3Post.removeEventListener(IOErrorEvent.IO_ERROR, onS3PostIoError);
				_s3Post.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onS3PostSecurityError);
				_s3Post.removeEventListener(ProgressEvent.PROGRESS, onS3PostProgress);
				_s3Post.removeEventListener(Event.COMPLETE, onS3Complete);
			}
		}
		
		//----------------------------------------------------------------------------
		// getter/setters
		//----------------------------------------------------------------------------
		public function get id(  ) : uint
		{
			return _id;
		}
		
		public function set id( n : uint ) : void
		{
			_id = n
		}
		
	}
}