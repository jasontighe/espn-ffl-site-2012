package com.espn.ffl.webcam {
	import com.espn.ffl.Shell;
	import com.espn.ffl.apis.http.HusaniRequestor;
	import com.espn.ffl.constants.SiteConstants;
	import com.espn.ffl.model.ConfigModel;
	import com.espn.ffl.model.ContentModel;
	import com.espn.ffl.model.InviterModel;
	import com.espn.ffl.model.PersonalizedModel;
	import com.espn.ffl.util.FflDropShadow;
	import com.espn.ffl.util.FflS3Uploader;
	import com.espn.ffl.util.Stopwatch;
	import com.espn.ffl.views.Main;
	import com.espn.ffl.views.inviter.Inviter;
	import com.espn.ffl.webcam.events.WebcamEvent;
	import com.espn.ffl.webcam.ui.States;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.ActivityEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.StatusEvent;
	import flash.external.ExternalInterface;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
	import flash.media.Camera;
	import flash.media.Microphone;
	import flash.media.Video;
	import flash.net.FileReference;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.utils.ByteArray;
	import flash.utils.clearTimeout;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;
	
	import leelib.ExtendedEvent;
	import leelib.util.Out;
	import leelib.util.flvEncoder.ByteArrayFlvEncoder;
	import leelib.util.flvEncoder.FlvEncoder;
	import leelib.util.flvEncoder.MicRecorderUtil;
	import leelib.util.flvEncoder.VideoPayloadMakerAlchemy;
	
	/**
	 * @author jason.tighe
	 */
	public class WebcamApp 
		extends Sprite 
	{
		public static const SHOW_DEBUG_FRAME:Boolean = false;
		
		//----------------------------------------------------------------------------
		// public static constants
		//----------------------------------------------------------------------------
		public static const FULL					: String = "full";
		public static const HALF					: String = "half";
		public static const STITCH					: String = "stitch";
		//----------------------------------------------------------------------------
		// private constants
		//----------------------------------------------------------------------------
		private const VIDEO_FRAME_RATE				: Number = 30;
		private const FLV_FRAMERATE					: int = 15;
		private const MIN_MIC_LEVEL					: Number = .025;
		private const AUDIO_HEADSTART_MS			: int = 1000;
		//----------------------------------------------------------------------------
		// private variables
		//----------------------------------------------------------------------------
		private var _pm								: PersonalizedModel = PersonalizedModel.gi;
		private var _cm								: ContentModel = ContentModel.gi;
		private var _im								: InviterModel = InviterModel.gi;
		private var _output							: Sprite;
		
		private var _checkboxVideo					: Boolean = true;
		private var _checkboxAudio					: Boolean = true;
		private var _baFlvEncoderAdded				: Boolean = false;
		
		private var _camera							: Camera;
		private var _video							: Video;
		private var _netConnection					: NetConnection;
		private var _ns								: NetStream;
		private var _micUtil						: MicRecorderUtil;
		
		private var _flvEncoders					: Array = new Array();
		private var _encodeFrameNum					: int;
		private var _durations						: Array = new Array();
		
		private var _bitmaps						: Array;
		private var _audioData						: ByteArray;
		
		private var _videoStartTime					: Number;
		private var _endTime						: Number;
		private var _captureLoopTimeoutId			: Number;
		private var _state							: String;
		
		private var _cameraW						: uint;
		private var _cameraH						: uint;
		
		private var _outputW						: uint;
		private var _outputH						: uint;
		
		private var _currentFrame					: uint = 0;
		private var _totalFrames					: uint = 9999;
		
		private var _progressCount					: uint = 0;
		
		private var _threeSecondSilence				: Boolean;
		
		private var _received						: uint = 0;
		private var _size							: uint = 0;
		private var _questionCount					: uint = 0;
		private var _stopwatch						: Stopwatch;
		private var _isReset						: Boolean = false;
		private var _audioCheckVidNum				: uint = 0;
		
		private var _audioStartTime					: Number
		private var _audioOffsetAtVideoStart		: Number;

		//----------------------------------------------------------------------------
		// constructor
		//----------------------------------------------------------------------------
		public function WebcamApp( ) {}
		
		//----------------------------------------------------------------------------
		// public methods
		//----------------------------------------------------------------------------
		public function init( ) : void
		{
			trace( "\n\n\n\nWEBCAMAPP : init()" );
			filters = [ FflDropShadow.getDefault() ];
			setOutputValues( SiteConstants.WEBCAM_FULL );
			makeByteArrays();
			
			_output = new Sprite();
			_output.graphics.beginFill(0xe5e5e5);
			_output.graphics.drawRect(0,0, SiteConstants.WEBCAM_FULL_WIDTH, SiteConstants.WEBCAM_FULL_HEIGHT );
			_output.graphics.endFill();
			this.addChild(_output);
			
			
			var mic:Microphone = Microphone.getMicrophone();
			if( mic == null )
			{
				Inviter.instance.showNoMicAlert();
				return;
			}
			else
			{
				mic.setSilenceLevel(0, int.MAX_VALUE);
				mic.gain = 100;
				mic.rate = 44;
				_micUtil = new MicRecorderUtil(mic);	
			}
			
			// Get Camera width and height after initializing, then find scale amount
			_camera = Camera.getCamera();
			
			trace( "WEBCAMAPP : init() : _camera is "+_camera );
			
			if( _camera == null )
			{
				trace( "WEBCAMAPP : init() : _camera is null, show showNoCameraAlert()");
				Inviter.instance.showNoCameraAlert();
				return;
			}
			
			if ( _camera.muted ) 
			{
			    // "remember" checkbox was not checked, or user needs to allow access
			}
			else 
			{
			    // "remember" checkbox was checked, access is already granted
			    _im.hasVerifiedWebcam = true;
			}
			
			var ratioW : Number = SiteConstants.WEBCAM_FULL_WIDTH / _camera.width;
			var ratioH : Number = SiteConstants.WEBCAM_FULL_HEIGHT / _camera.height;
			var scale : Number = Math.max( ratioW, ratioH );
			
			trace( "WEBCAMAPP : init() : _camera.width is "+_camera+" : _camera.height is "+ _camera.height );
			trace( "WEBCAMAPP : init() : _camera.width is "+_camera.width+" : _camera.height is "+ _camera.height );
			trace( "WEBCAMAPP : init() : scale is "+scale );
			
			var cameraW : Number = Math.ceil( _camera.width * scale );
			var cameraH : Number = Math.ceil( _camera.height * scale );
			trace( "WEBCAMAPP : init() : cameraW is "+cameraW );
			trace( "WEBCAMAPP : init() : cameraH is "+cameraH );
			
			_camera.setMode( cameraW, cameraH, VIDEO_FRAME_RATE );
			_camera.setQuality(0, 100);
			
			// User camera w and h to set video sizes.
			_video = new Video( cameraW, cameraH );
			_output.addChild(_video);
			
			// Center video accourding to VIDEO_HEIGHT AND VIDEO_WIDTH
			var videoX : Number = Math.round( ( SiteConstants.WEBCAM_FULL_WIDTH - cameraW ) * .5 );
			var videoY : Number = Math.round( ( SiteConstants.WEBCAM_FULL_HEIGHT - cameraH ) * .5 );
			_video.width = cameraW;
			_video.height = cameraH;
			
			// flip webcam video
			var tempScale : Number = _video.scaleX;
			_video.scaleX = -tempScale;
			
			_video.x += _video.width;
			_video.y = videoY;
			
			_netConnection = new NetConnection();
			_netConnection.connect(null);
			_ns = new NetStream(_netConnection);		
			
			setState(States.WAITING_FOR_WEBCAM);
		}

		private function makeByteArrays() : void
		{
			for( var i : uint = 0; i < 6; i++ )
			{
				var baFlvEncoder : ByteArrayFlvEncoder = new ByteArrayFlvEncoder(FLV_FRAMERATE);
				_flvEncoders.push( baFlvEncoder );
			}
		}
		
		public function startRecordingAudio():void
		{
			doStartRecordingAudio();
		}
		public function startRecordingVideo() : void
		{
			setState( States.RECORDING );
		}
		
		public function startEncoding():void
		{
			setState(States.ENCODING);
		}
		
		public function resetToWaitingForRecord() : void
		{
			_state == States.WAITING_FOR_RECORD;
		}
		
		public function sendToEncodingS3() : void
		{
			trace( "WEBCAMAPP : sendToEncodingS3()" );

			var thisHref:String = ExternalInterface.call("window.location.href.toString");
			var saveLocalOverride:Boolean = thisHref.indexOf("saveLocal") > -1;
			
			if (ConfigModel.gi.uploadFlvs && ! saveLocalOverride)
				uploadFlv();
			else
				saveFlvLocally();

			setState( States.WAITING_FOR_RECORD );
		}
		
		public function kill() : void
		{
			trace( "WEBCAMAPP : kill()" );
			
			detachCamera();

			_micUtil.stop();
			
			clearTimeout(_captureLoopTimeoutId);
			
			this.removeEventListener(Event.ENTER_FRAME, onEnterFrameEncode);
			
			for( var i : uint = 0; i < 6; i++ )
			{
				var baFlvEncoder : ByteArrayFlvEncoder = _flvEncoders[ i ];
				baFlvEncoder.kill();
			}
			
			//	setState( States.WAITING_FOR_RECORD );
			_isReset = true;
		}
		
		// Called on progressFlvComplete()
		public function clearByteArray( ) : void
		{
			trace( "\n" );
			trace( "*************************************************" );
			var baFlvEncoder : ByteArrayFlvEncoder = _flvEncoders[ _questionCount ] as ByteArrayFlvEncoder;
			if( _baFlvEncoderAdded )
			{
				// DESTROY
				trace( "WEBCAMAPP : clearByteArray() : baFlvEncoder.byteArray.length is "+baFlvEncoder.byteArray.length );
//				baFlvEncoder.kill();
				baFlvEncoder.byteArray.length = 0;
				baFlvEncoder = null;
				
				// THEN MAKE NEW
				baFlvEncoder = new ByteArrayFlvEncoder(FLV_FRAMERATE);
				_flvEncoders[ _questionCount ] = baFlvEncoder;
			}
			_currentFrame = 0;
			_totalFrames = 9999;
			trace( "|" );
			trace( "|" );
			//			trace( "WEBCAMAPP : clearByteArray() : _baFlvEncoder.byteArray.length is "+_baFlvEncoder.byteArray.length );
			trace( "*************************************************" );
			trace( "\n" );
		}
		
		public function retryWebcamPermissions( ) : void
		{
			trace( "WEBCAMAPP : retryWebcamPermissions()" );
			attachCameraAndConfirm();
		}
		
		//----------------------------------------------------------------------------
		// private methods
		//----------------------------------------------------------------------------
		private function attachCameraAndConfirm( ) : void
		{
			_camera.addEventListener( StatusEvent.STATUS, onCamStatus );
			//			_camera.addEventListener( ActivityEvent.ACTIVITY, onCamActivity );
			_video.attachCamera(_camera);
			
			trace( "WEBCAMAPP : retryWebcamPermissions() : _isReset is "+_isReset );
			
			if( InviterModel.gi.hasVerifiedWebcam )
				setState( States.WAITING_FOR_RECORD );
		}
		
		public function detachCamera():void
		{
			if (_video) _video.attachCamera(null);
		}
		
		private function onCamStatus($e:StatusEvent):void
		{
			trace( "WEBCAMAPP : onCamStatus() : $e.code is "+$e.code );
			
			_camera.removeEventListener( StatusEvent.STATUS, onCamStatus );
			
			if ($e.code == "Camera.Unmuted") // rem: this event can't be relied upon 
			{
				_im.hasVerifiedWebcam = true;
				dispatchEvent( new WebcamEvent( WebcamEvent.WEBCAM_ACCPEPTED ) );
				setState(States.WAITING_FOR_RECORD);
			}	
			else
			{
				dispatchEvent( new WebcamEvent( WebcamEvent.WEBCAM_DENIED));	
			}
		}
		private function onCamActivity($e:ActivityEvent):void
		{
			trace( "WEBCAMAPP : onCamActivity() : $e is "+$e );
			
			_camera.removeEventListener( StatusEvent.STATUS, onCamStatus );
			
			setState(States.WAITING_FOR_RECORD);
		}
		
		private function doStartRecordingAudio():void
		{
			_audioStartTime = getTimer();
			_micUtil.record();
		}
		
		private function doStartRecordingVideo():void
		{	
			_questionCount = _pm.questionCount;
			_isReset = false;
			var type : String = _cm.getInterviewVideoItemAt( _questionCount ).type;
			
			var isRecordingEarly:Boolean = _cm.getInterviewVideoItemAt( _questionCount ).recordEarly;
			if (isRecordingEarly) startRecordingAudio(); // *// special case!
			_threeSecondSilence = isRecordingEarly;
			
			setOutputValues( type );
			
			clearByteArray();
			_bitmaps = new Array();
			
			_videoStartTime = getTimer();
			_audioOffsetAtVideoStart = _micUtil.byteArray.length;

			_stopwatch = new Stopwatch();
			_stopwatch.begin();

			// start loop
			captureFrame();
		}
		
		private function checkMicActivity() : void
		{
			trace( "WEBCAMAPP : checkMicActivity() : _micUtil.byteArray.length is "+_micUtil.byteArray.length ); 
			_micUtil.byteArray.position = 0;
			var floatTotal : Number = 0;
			var floatLength : Number = _micUtil.byteArray.length/4;
			for( var i : uint = 0; i < floatLength; i++ ) 
			{ 
				// trace( "WEBCAMAPP : checkMicAvtivity() : _micUtil.byteArray.readFloat() is "+_micUtil.byteArray.readFloat() ); 
				floatTotal += Math.abs( _micUtil.byteArray.readFloat() );
			} 
			
			var average : Number = floatTotal/ floatLength;
			trace( "WEBCAMAPP : checkMicActivity() : floatTotal is "+floatTotal ); 
			trace( "WEBCAMAPP : checkMicActivity() : floatLength is "+floatLength ); 
			trace( "WEBCAMAPP : checkMicActivity() : average is "+average ); 
			
			_im.micActive = ( average > MIN_MIC_LEVEL );
		}
		
		private function captureFrame():void
		{
			// capture frame
			if( _isReset ) return;
			
			var offsetX:int = (_output.width - _outputW) * -0.5; 
			
			var m:Matrix = new Matrix();
			m.tx = offsetX;
			
			var b:BitmapData = new BitmapData( _outputW, _outputH,false,0x0);
			b.draw(_output, m);
			_bitmaps.push(b);
			
			// end condition:
			var maxSeconds : uint = 20
			if (_bitmaps.length / FLV_FRAMERATE >= maxSeconds) {
				setState(States.ENCODING);
				return;
			}
			
			// schedule next captureFrame
			var elapsedMs:int = getTimer() - _videoStartTime;
			var nextMs:int = (_bitmaps.length / FLV_FRAMERATE) * 1000;
			var deltaMs:int = nextMs - elapsedMs;
			if (deltaMs < 10) deltaMs = 10; 
			_captureLoopTimeoutId = setTimeout(captureFrame, deltaMs);
		}
		
		private function doStartEncoding():void
		{
			trace( "WEBCAMAPP : doStartEncoding()" );
			
			_endTime = getTimer();
			_stopwatch.end();
			
			// Get just a little more Mic input!
			// (or enough time for last chunk of data to come in?)			
			setTimeout(doStartEncoding_2, 200);
		}
		
		private function doStartEncoding_2():void
		{
			trace( "WEBCAMAPP : doStartEncoding_2()", _outputW, _outputH );
			_micUtil.stop();
			
			_audioData = _micUtil.byteArray;
			
			// Make FlvEncoder object
			//			_baFlvEncoder = new ByteArrayFlvEncoder(FLV_FRAMERATE);
			var baFlvEncoder : ByteArrayFlvEncoder = _flvEncoders[ _questionCount ] as ByteArrayFlvEncoder;
			_baFlvEncoderAdded = true;
			if ( _checkboxVideo ) 
			{
				baFlvEncoder.setVideoProperties( _outputW, _outputH, VideoPayloadMakerAlchemy );
			}
			if ( _checkboxAudio ) 
			{
				baFlvEncoder.setAudioProperties( FlvEncoder.SAMPLERATE_44KHZ, true, false, true);
			}
			
			trace("WEBCAMAPP SANITY CHECK: =================================");
			trace("EXPECTED AUDIO LENGTH ~" + (_bitmaps.length * baFlvEncoder.audioFrameSize)/1024 + "k");
			trace("REAL AUDIO LENGTH", (_audioData.length / 1024) + "k");
			trace("EXPECTED ELAPSED TIME", _bitmaps.length * (1000/15) + "ms");
			trace("REAL ELAPSED TIME", (_endTime - _videoStartTime) + "ms");
			
			baFlvEncoder.start();
			
			_encodeFrameNum = -1;
			this.addEventListener(Event.ENTER_FRAME, onEnterFrameEncode);
			// ... encode FLV frames on an interval to keep UI from locking up
		}
		
		private function onEnterFrameEncode(e:*):void
		{
			// Encode 3 frames per iteration
			for (var i:int = 0; i < 3; i++)
			{
				_encodeFrameNum++;
				// This is being used by TryAgainSaveAndContinue button
				_currentFrame = _encodeFrameNum;
				_totalFrames = _bitmaps.length;
				//				trace( "\n" );
				//				trace("WEBCAMAPP : onEnterFrameEncode() : _currentFrame is "+_currentFrame ); 
				//				trace("WEBCAMAPP : onEnterFrameEncode() : _totalFrames is "+_totalFrames ); 
				
				if (_encodeFrameNum < _bitmaps.length) 
				{
					encodeNextFrame();
				}
				else 
				{
					// done
					this.removeEventListener(Event.ENTER_FRAME, onEnterFrameEncode);
					
					var baFlvEncoder : ByteArrayFlvEncoder = _flvEncoders[ _questionCount ] as ByteArrayFlvEncoder;
					baFlvEncoder.updateDurationMetadata();
					setState(States.WAITING_FOR_RECORD);
					return;
				}
			}
			
			//			_tfPrompt.text = "encoding\r" + (_encodeFrameNum+1) + " of " + _bitmaps.length;
		}
		
		private function encodeNextFrame():void
		{
			var baAudio:ByteArray;
			var bmdVideo:BitmapData;
			var baFlvEncoder : ByteArrayFlvEncoder = _flvEncoders[ _questionCount ] as ByteArrayFlvEncoder;
			
			// [a] prepare audio

			baAudio = new ByteArray();
			
			var audioPos:int = _encodeFrameNum * baFlvEncoder.audioFrameSize;
			audioPos += _audioOffsetAtVideoStart;
			
			if (audioPos < 0 || audioPos + baFlvEncoder.audioFrameSize > _audioData.length) 
			{
				baAudio.length = baFlvEncoder.audioFrameSize; // write zero's
			}
			else 
			{
				if (_threeSecondSilence && _encodeFrameNum < 15*3)
				{
					// write zero's instead of the real audio (silence)
					var silence:ByteArray = new ByteArray();
					silence.length = baFlvEncoder.audioFrameSize;
					baAudio.writeBytes(silence);
				}
				else
				{
					baAudio.writeBytes(_audioData, audioPos, baFlvEncoder.audioFrameSize);
				}
				
			}
			
			// [b] prepare video (easy)
			
			bmdVideo = _bitmaps[_encodeFrameNum];

			
			if (SHOW_DEBUG_FRAME)
			{
				if (_encodeFrameNum == 10) 
				{
					var old:DisplayObject = Shell.instance.stage.getChildByName("testthing");
					if (old) Shell.instance.stage.removeChild(old);
					
					var b:Bitmap = new Bitmap( bmdVideo.clone() );
					b.name = "testthing";
					b.filters = [ new GlowFilter(0xff0000, 1, 6,6,3,2,false) ];
					b.scaleX = b.scaleY = 0.5;
					b.x = 20; b.y = 20;
					Shell.instance.stage.addChild(b);
				}
			}
			
			// rem _encodeFrameNum is 1-indexed
			// trace('sanity check - flv id', _questionCount, 'framenum', _encodeFrameNum, 'of', _bitmaps.length, 'dim', bmdVideo.width, bmdVideo.height, 'audio len', baAudio.length);
			
			baFlvEncoder.addFrame(bmdVideo, baAudio);
			
			// Video frame has been encoded, so we can discard it now
			_bitmaps[_encodeFrameNum].dispose();
		}
		
		private function saveFlvLocally():void
		{	
			trace( "WEBCAMAPP : saveFlvLocally()" );
			var fileRef:FileReference = new FileReference();
			var baFlvEncoder : ByteArrayFlvEncoder = _flvEncoders[ _questionCount ] as ByteArrayFlvEncoder;
			fileRef.save( baFlvEncoder.byteArray, "no_server_required.flv");	
			
			setState(States.WAITING_FOR_RECORD);
		}
		
		private function uploadFlv():void
		{		
			trace( "\n**************************************" );
			trace("WEBCAMAPP : [ "+_questionCount+" ] : uploadFlv()" ); 
			_audioCheckVidNum++;
			
			// TODO Add complete listener and garbage collect
			//			var webcamUploader : WebcamUploader = new WebcamUploader();
			//			webcamUploader.addEventListener( EncodingEvent.FILE_UPLOADED, uploadFlvComplete );
			//			webcamUploader.duration = _stopwatch.elapsedTime;
			//			webcamUploader.uploadArray( baFlvEncoder.byteArray, _questionCount );
			
			_durations[ _questionCount ] = _stopwatch.elapsedTime;
			var baFlvEncoder : ByteArrayFlvEncoder = _flvEncoders[ _questionCount ] as ByteArrayFlvEncoder;
			
			var s3uploader:FflS3Uploader = new FflS3Uploader();
			s3uploader.id = _questionCount;
			s3uploader.addEventListener( FflS3Uploader.EVENT_COMPLETE, onS3uploaderComplete );
			s3uploader.addEventListener( FflS3Uploader.EVENT_ERROR, onS3uploaderError );
			s3uploader.addEventListener( ProgressEvent.PROGRESS, onS3uploaderProgress );
			trace("WEBCAMAPP : [ "+_questionCount+" ] : uploadFlv() : baFlvEncoder.byteArray.length is "+baFlvEncoder.byteArray.length ); 
			s3uploader.upload( baFlvEncoder.byteArray );
		}
		
		private function setState( $state : String ) : void
		{
			trace("WEBCAMAPP : setState() : $state is "+$state ); 
			_state = $state;
			
			switch (_state)
			{
				case States.WAITING_FOR_WEBCAM:
					attachCameraAndConfirm();
					break;
				
				case States.WAITING_FOR_RECORD:
					_video.attachCamera(_camera);
					break;
				
				case States.RECORDING:
					doStartRecordingVideo();
					break;
				
				case States.ENCODING:
					if( _audioCheckVidNum == 0 )	checkMicActivity();
					clearTimeout(_captureLoopTimeoutId);
					doStartEncoding();
					break;
			}
		}
		
		public function setOutputValues( s : String ) : void
		{
			if( s == SiteConstants.WEBCAM_FULL )
			{
				_outputW = SiteConstants.WEBCAM_FULL_WIDTH;
				_outputH = SiteConstants.WEBCAM_FULL_HEIGHT;
			}
			else if( s == SiteConstants.WEBCAM_HALF ) 
			{
				_outputW = SiteConstants.WEBCAM_FULL_WIDTH;
				_outputH = SiteConstants.WEBCAM_FULL_HEIGHT;
			}
			else if( s == SiteConstants.WEBCAM_SPLIT ) 
			{
				_outputW = SiteConstants.WEBCAM_SPLIT_WIDTH;
				_outputH = SiteConstants.WEBCAM_SPLIT_HEIGHT;
			}
			
			trace("WEBCAMAPP : setOutputValues() : s is "+s, ' -', _outputW, _outputH ); 
		}
		
		private function sendURLToHusani( url : String, id : uint ) : void
		{
			trace( "WEBCAMUPLOADER : sendURLToHusani()" ); 
			var hr : HusaniRequestor = new HusaniRequestor();
			hr.duration = _durations[ id ];
			hr.webcamNum = id + 1;
			hr.url = url;
			hr.addEventListener( Event.COMPLETE, sendURLToHusaniComplete);
			hr.addEventListener(IOErrorEvent.IO_ERROR, onS3PostIoError);
			hr.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onS3PostSecurityError);
			hr.request( HusaniRequestor.SET_WEBCAM_URL );
		}
		
		//----------------------------------------------------------------------------
		// event handlers
		//----------------------------------------------------------------------------
		private function onBtnRecClick(e:*):void
		{
			trace("WEBCAMAPP : onBtnRecClick()" ); 
			if (_state == States.WAITING_FOR_RECORD) 
				setState(States.RECORDING);
			else if (_state == States.RECORDING)
				setState(States.ENCODING);
		}
		
		private function onS3uploaderComplete( e : ExtendedEvent = null ) : void
		{
			var s3uploader : FflS3Uploader = e.target as FflS3Uploader;
			var id : uint = s3uploader.id;
			var url : String = e.object as String;
			
			var baFlvEncoder : ByteArrayFlvEncoder = _flvEncoders[ id ] as ByteArrayFlvEncoder;
			//			baFlvEncoder.kill();
			baFlvEncoder.byteArray.length = 0;
			
			trace( "\n\n\n" );
			trace( "WEBCAMAPP : onS3uploaderComplete() : [ "+id+" ]"); 
			trace( "WEBCAMAPP : onS3uploaderComplete() : s3uploader is " +s3uploader ); 
			trace( "WEBCAMAPP : onS3uploaderComplete() : url is " +url );
			
			WebcamDebugger.gi.addMessage( "WEBCAM "+id + 1+" UPLOAD COMPELTE: ", url );
			sendURLToHusani( url, id );
		}
		
		private function onS3uploaderError( e : ExtendedEvent = null ) : void
		{
			trace( "WEBCAMAPP : onS3uploaderError() : e is " +e ); 
		}
		
		private function onS3uploaderProgress( e : ProgressEvent = null ) : void
		{
			trace( "WEBCAMAPP : onS3uploaderProgress() : e is " +e ); 
		}
		
		private function sendURLToHusaniComplete( e : Event ) : void
		{
			trace( "WEBCAMUPLOADER : sendURLToHusaniComplete()" ); 
			_cm.upWebcamS3URLCount();
		}
		
		private function onS3PostIoError($e:IOErrorEvent):void
		{
			Out.i("WEBCAMUPLOADER : FflS3Uploader.onS3PostIoError()", $e.text);
		}
		
		private function onS3PostSecurityError($e:SecurityErrorEvent):void 
		{
			Out.i("WEBCAMUPLOADER : FflS3Uploader.onS3PostSecurityError()", $e.text);
		}
		
		//		private function uploadFlvComplete( e : EncodingEvent ) : void
		//		{
		//			var webcamUploader : WebcamUploader = e.target as WebcamUploader;
		//			var id : uint = webcamUploader.id;
		//			webcamUploader.removeEventListener( Event.COMPLETE, uploadFlvComplete )
		//			trace("WEBCAMAPP : uploadFlvComplete() : id is "+id ); 
		//			
		//			var baFlvEncoder : ByteArrayFlvEncoder = _flvEncoders[ id ] as ByteArrayFlvEncoder;
		//			baFlvEncoder.kill();
		//		}
		
		//----------------------------------------------------------------------------
		// getter/setters
		//----------------------------------------------------------------------------
		//		public static function get gi() : WebcamApp
		//		{
		//			if(!_instance) _instance = new WebcamApp(new WebcamAppEnforcer());
		//			return _instance;
		//		}
		
		public function get received( ) : uint
		{
			return _received;
		}
		
		public function get size( ) : uint
		{
			return _size;
		}
		
		public function get currentFrame( ) : uint
		{
			return _currentFrame;
		}
		
		public function get totalFrames( ) : uint
		{
			return _totalFrames;
		}
	}
}

class WebcamAppEnforcer{}
