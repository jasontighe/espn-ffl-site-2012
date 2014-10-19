package com.espn.ffl.model {
	import leelib.ExtendedEvent;

	import com.espn.ffl.model.events.InviterEvent;

	import flash.events.EventDispatcher;

	/**
	 * @author jason.tighe
	 */
	public class InviterModel 
	extends EventDispatcher 
	{	
		//----------------------------------------------------------------------------
		// private variables
		//----------------------------------------------------------------------------
		private static var _instance 					: InviterModel;
		//----------------------------------------------------------------------------
		// public static constants
		//----------------------------------------------------------------------------
		// Inviter States
		public static const STATE_PERSONALIZED			: String = "personalized";
		public static const STATE_PREMADE				: String = "premade";
		public static const STATE_PREVIEW				: String = "preview";
		public static const STATE_RESET					: String = "reset";
		
		// Video Types for Nav and Husani Requests
		public static const VIDEO_TYPE_PERSONALIZED		: String = "1";
		public static const VIDEO_TYPE_PREMADE			: String = "2";
		
		// Video Status
		public static const STATUS_NEW					: String = "new";
		public static const STATUS_ERROR				: String = "error";
		public static const STATUS_WAITING				: String = "waiting";
		public static const STATUS_CREATED				: String = "created";
		public static const STATUS_DELETED				: String = "deleted";
		
		// Extended Events
		public static const MIC_CHECK_COMPLETE          : String = "im.micCheckComplete";
		//----------------------------------------------------------------------------
		// protected variables
		//----------------------------------------------------------------------------
		protected var _state							: String = "";
		protected var _previousState					: String;
		protected var _questionCount					: uint = 0;
		protected var _status							: String;
		protected var _s3URL							: String;
		protected var _youtubeURL						: String;
		protected var _videoType						: String = VIDEO_TYPE_PERSONALIZED; // Defaults to personalized
		protected var _premadeVideoId					: uint;
		protected var _hasVerifiedWebcam				: Boolean = false;
		protected var _videoWaitingForCreation			: Boolean = false;
		protected var _interviewStarted					: Boolean = false;
		protected var _micActiveSet						: Boolean = false;
		protected var _micActive						: Boolean = false;
		protected var _webcamDenied						: Boolean = false;
		//----------------------------------------------------------------------------
		// constructor
		//----------------------------------------------------------------------------
		public function InviterModel( e : InviterModelEnforcer ) { }


		//----------------------------------------------------------------------------
		// public methods
		//----------------------------------------------------------------------------
		public function parseData( object : Object ) : void
		{
			trace( "INVITERMODEL : parseData() : object is "+object );
			
			if( object.status )					_status = object.status;
			if( object.s3_url )					_s3URL = object.s3_url;
			if( object.youtube_url )			_youtubeURL = object.youtube_url;
			if( object.video_type )				_videoType = object.video_type;
			
			traceData();
		}
		
		public function traceData( ) : void
		{
			trace( "INVITERMODEL : traceData() : _status is "+_status );
			trace( "INVITERMODEL : traceData() : _s3URL is "+_s3URL );
			trace( "INVITERMODEL : traceData() : _youtubeURL is "+_youtubeURL );
			trace( "INVITERMODEL : traceData() : _videoType is "+_videoType );
		}
		
		//----------------------------------------------------------------------------
		// protected methods
		//----------------------------------------------------------------------------
		 protected function updateState() : void
		 {
			trace( "INVITERMODEL : updateState() : _state is "+_state );
			var category:String;
			switch ( _state )
			{
				case STATE_PERSONALIZED:
					dispatchEvent( new InviterEvent( InviterEvent.PERSONALIZED, false) );
					break;
				case STATE_PREMADE:
					dispatchEvent( new InviterEvent( InviterEvent.PREMADE, false) );
					break;
				case STATE_PREVIEW:
					dispatchEvent( new InviterEvent( InviterEvent.PREVIEW, false) );
					break;
				case STATE_RESET:
					dispatchEvent( new InviterEvent( InviterEvent.RESET, false) );
					break;
			}
		}
		 
		//----------------------------------------------------------------------------
		// getter/setters
		//----------------------------------------------------------------------------
		public static function get gi() : InviterModel
		{
			if(!_instance) _instance = new InviterModel(new InviterModelEnforcer());
			return _instance;
		}
		
		public function get state( ) : String
		{
			return _state;
		} 
		public function set state( value : String ) : void 
		{	
			trace( "\n*******************************************" );
			trace( "INVITERMODEL : STATE = " + value + ",	 OLD STATE = " + _state);
			// THIS COULD BREAK SHIT BUT IS A TEMP SOLVE
//			if( _state != value)
//			{
//				_previousState = _state;
				_state = value;
				updateState();
//			}
		}
		
		public function get previousState( ) : String
		{
			return _previousState;
		}
		public function set previousState( s : String ) : void
		{
			_previousState = s;
		}
		
		public function get questionCount( ) : uint
		{
			return _questionCount;
		}
		public function set questionCount( n : uint ) : void
		{
			_questionCount = n;
		}
		
		public function get status( ) : String
		{
			return _status;
//			return STATUS_DELETED;
		}
		public function set status( s : String ) : void
		{
			_status = s;
		}
		
		public function getRandomStatus( ) : String
		{
			var statuses : Array = new Array( STATUS_NEW, STATUS_ERROR, STATUS_WAITING,	STATUS_CREATED, STATUS_DELETED );
			var randomNum : int = int( Math.random() * statuses.length );
			var status : String = statuses[ randomNum ];
			return status;
		}
		
		public function get s3URL( ) : String
		{
			return _s3URL;
		}
		
		public function get youtubeURL( ) : String
		{
			return _youtubeURL;
		}
		
		public function get videoType( ) : String
		{
			return _videoType;
		}
		public function set videoType( s : String ) : void
		{
			_videoType = s;
		}
		
		public function get premadeVideoId( ) : uint
		{
			return _premadeVideoId;
		}
		public function set premadeVideoId( n : uint ) : void
		{
			_premadeVideoId = n + 1;
		}
		
		public function get hasVerifiedWebcam( ) : Boolean
		{
			return _hasVerifiedWebcam;
		}
		public function set hasVerifiedWebcam( value : Boolean ) : void
		{
//			trace( "INVITERMODEL : set hasVerifiedWebcam = " + value + " : HAS BEEN SET" );
			_hasVerifiedWebcam = value;
		}
		
		public function get videoWaitingForCreation( ) : Boolean
		{
			return _videoWaitingForCreation;
		}
		public function set videoWaitingForCreation( value : Boolean ) : void
		{
			_videoWaitingForCreation = value;
		}
		
		public function get interviewStarted( ) : Boolean
		{
			return _interviewStarted;
		}
		public function set interviewStarted( value : Boolean ) : void
		{
			_interviewStarted = value;
		}
		
		public function get micActive( ) : Boolean
		{
			return _micActive;
		}
		public function set micActive( value : Boolean ) : void
		{
			trace( "INVITERMODEL : set micActive = " + value );
			_micActive = value;
//			_micActive = false;
			_micActiveSet = true;
			dispatchEvent(new ExtendedEvent( MIC_CHECK_COMPLETE, _micActive ) );
		}
		
		public function get micActiveSet( ) : Boolean
		{
			return _micActiveSet;
		}
		public function set micActiveSet( value : Boolean ) : void
		{
			_micActiveSet = value;
		}
		
		public function get webcamDenied( ) : Boolean
		{
			return _webcamDenied;
		}
		public function set webcamDenied( value : Boolean ) : void
		{
			_webcamDenied = value;
		}
	}
}

class InviterModelEnforcer{}