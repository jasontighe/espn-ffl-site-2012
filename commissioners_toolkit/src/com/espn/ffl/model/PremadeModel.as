package com.espn.ffl.model {
	import com.espn.ffl.model.events.PersonalizedEvent;
	import com.espn.ffl.model.events.PremadeEvent;

	import flash.events.EventDispatcher;

	/**
	 * @author jason.tighe
	 */
	public class PremadeModel 
	extends EventDispatcher 
	{	
		//----------------------------------------------------------------------------
		// private variables
		//----------------------------------------------------------------------------
		private static var _instance 					: PremadeModel;
		//----------------------------------------------------------------------------
		// public static constants
		//----------------------------------------------------------------------------
		public static const STATE_VIDEO_SELECTOR		: String = "videoSelector";
		public static const STATE_COMPLETED				: String = "completed";
		public static const STATE_FLUSH					: String = "flush";
		public static const STATE_CREATED				: String = "created";
		//----------------------------------------------------------------------------
		// protected variables
		//----------------------------------------------------------------------------
		protected var _state							: String;
		protected var _previousState					: String;
		protected var _preview							: Boolean = false;
		protected var _completed						: Boolean = false;
		protected var _curVideo							: uint = 0;
		//----------------------------------------------------------------------------
		// constructor
		//----------------------------------------------------------------------------
		public function PremadeModel( e : PremadeModelEnforcer ) { }
		
		//----------------------------------------------------------------------------
		// protected methods
		//----------------------------------------------------------------------------
		 protected function updateState() : void
		 {
			trace( "PREMADEMODEL : updateState() : _state is "+_state );
			var category:String;
			switch ( _state )
			{
				case STATE_VIDEO_SELECTOR:
					dispatchEvent( new PremadeEvent( PremadeEvent.VIDEO_SELECTOR, false) );
					break;
				case STATE_COMPLETED:
					dispatchEvent( new PremadeEvent( PremadeEvent.COMPLETED, false) );
					break;
				case STATE_FLUSH:
					dispatchEvent( new PremadeEvent( PremadeEvent.FLUSH, false) );
					break;
				case STATE_CREATED:
					dispatchEvent( new PremadeEvent( PremadeEvent.CREATED, false) );
					break;
			}
		}
		 
		//----------------------------------------------------------------------------
		// getter/setters
		//----------------------------------------------------------------------------
		public static function get gi() : PremadeModel
		{
			if(!_instance) _instance = new PremadeModel( new PremadeModelEnforcer() );
			return _instance;
		}
		
		public function get state( ) : String
		{
			return _state;
		} 
		public function set state( value : String ) : void 
		{	
			trace( "\n*******************************************" );
			trace( "PREMADEMODEL : STATE = " + value + ",	 OLD STATE = " + _state);
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
		
		public function get completed( ) : Boolean
		{
			return _completed;
		}
		public function set completed( value : Boolean ) : void
		{
			_completed = value;
		}
		
		public function get preview( ) : Boolean
		{
			return _preview;
		}
		public function set preview( value : Boolean ) : void
		{
			_preview = value;
		}
		
		public function get curVideo( ) : uint
		{
			return _curVideo;
		}
		public function set curVideo( n : uint ) : void
		{
			_curVideo = n;
		}
	}
}

class PremadeModelEnforcer{}