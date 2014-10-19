package com.espn.ffl.model {
	import com.espn.ffl.model.events.PersonalizedEvent;

	import flash.events.EventDispatcher;

	/**
	 * @author jason.tighe
	 */
	public class PersonalizedModel 
	extends EventDispatcher 
	{	
		//----------------------------------------------------------------------------
		// private variables
		//----------------------------------------------------------------------------
		private static var _instance 					: PersonalizedModel;
		//----------------------------------------------------------------------------
		// public static constants
		//----------------------------------------------------------------------------
		public static const STATE_INTRO					: String = "intro";
		public static const STATE_ADD_WEBCAM			: String = "addWebcam";
		public static const STATE_POSTIONER				: String = "positioner";
		public static const STATE_LEARN					: String = "learn";
		public static const STATE_QUESTION				: String = "question";
		public static const STATE_READY					: String = "ready";
		public static const STATE_COUNTDOWN				: String = "countdown";
		public static const STATE_RECORDING				: String = "recording";
		public static const STATE_ADD_PHOTO				: String = "addPhoto";
		public static const STATE_STOPPED				: String = "stopped";
		public static const STATE_COMPLETED				: String = "completed";
		public static const STATE_CREATED				: String = "created";
		public static const STATE_FLUSH					: String = "flush";
		public static const STATE_RESET					: String = "reset";
		//----------------------------------------------------------------------------
		// protected variables
		//----------------------------------------------------------------------------
		protected var _state							: String = "";
		protected var _previousState					: String;
		protected var _questionCount					: uint = 0;
		protected var _introViewed						: Boolean = false;
		protected var _isReset							: Boolean = false;
		//----------------------------------------------------------------------------
		// constructor
		//----------------------------------------------------------------------------
		public function PersonalizedModel( e : PersonalizedModelEnforcer ) { }
		
		//----------------------------------------------------------------------------
		// protected methods
		//----------------------------------------------------------------------------
		 protected function updateState() : void
		 {
			trace( "PERSONALIZEDMODEL : updateState() : _state is "+_state );
			var category:String;
			switch ( _state )
			{
				case STATE_RESET:
					dispatchEvent( new PersonalizedEvent( PersonalizedEvent.RESET, false) );
					break;
				case STATE_INTRO:
					dispatchEvent( new PersonalizedEvent( PersonalizedEvent.INTRO, false) );
					break;
				case STATE_ADD_WEBCAM:
					dispatchEvent( new PersonalizedEvent( PersonalizedEvent.ADD_WEBCAM, false) );
					break;
				case STATE_POSTIONER:
					dispatchEvent( new PersonalizedEvent( PersonalizedEvent.POSTIONER, false) );
					break;
				case STATE_LEARN:
					dispatchEvent( new PersonalizedEvent( PersonalizedEvent.LEARN, false) );
					break;
				case STATE_QUESTION:
					dispatchEvent( new PersonalizedEvent( PersonalizedEvent.QUESTION, false) );
					break;
				case STATE_READY:
					dispatchEvent( new PersonalizedEvent( PersonalizedEvent.READY, false) );
					break;
				case STATE_COUNTDOWN:
					dispatchEvent( new PersonalizedEvent( PersonalizedEvent.COUNTDOWN, false) );
					break;
				case STATE_RECORDING: // Called from WebcamFrame.as
					dispatchEvent( new PersonalizedEvent( PersonalizedEvent.RECORDING, false) );
					break;
				case STATE_ADD_PHOTO:
					dispatchEvent( new PersonalizedEvent( PersonalizedEvent.ADD_PHOTO, false) );
					break;
				case STATE_STOPPED:
					dispatchEvent( new PersonalizedEvent( PersonalizedEvent.STOPPED, false) );
					break;
				case STATE_COMPLETED:
					dispatchEvent( new PersonalizedEvent( PersonalizedEvent.COMPLETED, false) );
					break;
				case STATE_CREATED:
					dispatchEvent( new PersonalizedEvent( PersonalizedEvent.CREATED, false) );
					break;
				case STATE_FLUSH:
					dispatchEvent( new PersonalizedEvent( PersonalizedEvent.FLUSH, false) );
					break;
			}
		}
		 
		//----------------------------------------------------------------------------
		// getter/setters
		//----------------------------------------------------------------------------
		public static function get gi() : PersonalizedModel
		{
			if(!_instance) _instance = new PersonalizedModel(new PersonalizedModelEnforcer());
			return _instance;
		}
		
		public function get state( ) : String
		{
			return _state;
		} 
		public function set state( value : String ) : void 
		{	
			trace( "\n*******************************************" );
			trace( "PERSONALIZEDMODEL : STATE = " + value + ",	 OLD STATE = " + _state);
			if( _state != value)
			{
//				_previousState = _state;
				_state = value;
				updateState();
			}
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
		
		public function get introViewed ( ) : Boolean
		{
			return _introViewed ;
		}
		public function set introViewed ( value : Boolean ) : void
		{
			_introViewed = value;
		}
		
		public function get isReset( ) : Boolean
		{
			return _isReset;
		}
		public function set isReset( value : Boolean ) : void
		{
			_isReset = value;
		}
	}
}

class PersonalizedModelEnforcer{}