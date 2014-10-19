package com.espn.ffl.model {
	import com.espn.ffl.model.events.StateEvent;

	import flash.events.EventDispatcher;

	/**
	 * @author jason.tighe
	 */
	public class StateModel 
	extends EventDispatcher 
	{	
		//----------------------------------------------------------------------------
		// private variables
		//----------------------------------------------------------------------------
		private static var _instance 					: StateModel;
		//----------------------------------------------------------------------------
		// public static constants
		//----------------------------------------------------------------------------
		public static const STATE_COMMISSIONER			: String = "commissioner";
		public static const STATE_LEAGUE_MANAGER		: String = "leagueManager";
		public static const STATE_TOUTS					: String = "touts";
		public static const STATE_INVITER				: String = "inviter";
		public static const STATE_ENFORCER				: String = "enforcer";
		public static const STATE_REPORT_CARD			: String = "reportCard";
		public static const STATE_APPAREL				: String = "apparel";
		public static const STATE_VIDEO_CREATED			: String = "videoCreated";
		public static const STATE_VIDEO_APPROVED		: String = "videoApproved";
		public static const STATE_VIDEO_UNAPPROVED		: String = "videoUnapproved";
		public static const STATE_VIDEO_REJECTED		: String = "videoRejected";
		//----------------------------------------------------------------------------
		// protected variables
		//----------------------------------------------------------------------------
		protected var _state							: String = "";
		protected var _previousState					: String;
		protected var _webcamCount						: uint = 0;
		//----------------------------------------------------------------------------
		// constructor
		//----------------------------------------------------------------------------
		public function StateModel( e : StateModelEnforcer ) { }
		
		//----------------------------------------------------------------------------
		// protected methods
		//----------------------------------------------------------------------------
		 protected function updateState() : void
		 {
			trace( "STATEMODEL : updateState() : _state is "+_state );
			var category:String;
			switch ( _state )
			{
//				case STATE_COMMISSIONER:
//					dispatchEvent( new StateEvent( StateEvent.COMMISSIONER, false) );
//					break;
//				case STATE_LEAGUE_MANAGER:
//					dispatchEvent( new StateEvent( StateEvent.LEAGUE_MANAGER, false) );
//					break;
				case STATE_TOUTS:
					dispatchEvent( new StateEvent( StateEvent.TOUTS, false) );
					break;
				case STATE_INVITER:
					dispatchEvent( new StateEvent( StateEvent.INVITER, false) );
					break;
				case STATE_ENFORCER:
					dispatchEvent( new StateEvent( StateEvent.ENFORCER, false) );
					break;
				case STATE_REPORT_CARD:
					dispatchEvent( new StateEvent( StateEvent.REPORT_CARD, false) );
					break;
				case STATE_APPAREL:
					dispatchEvent( new StateEvent( StateEvent.APPAREL, false) );
					break;
//				case STATE_VIDEO_APPROVED:
//					dispatchEvent( new StateEvent( StateEvent.VIDEO_APPROVED, false) );
//					break;
//				case STATE_VIDEO_UNAPPROVED:
//					dispatchEvent( new StateEvent( StateEvent.VIDEO_UNAPPROVED, false) );
//					break;
//				case STATE_VIDEO_REJECTED:
//					dispatchEvent( new StateEvent( StateEvent.VIDEO_REJECTED, false) );
//					break;
			}
		}
		 
		//----------------------------------------------------------------------------
		// getter/setters
		//----------------------------------------------------------------------------
		public static function get gi() : StateModel
		{
			if(!_instance) _instance = new StateModel(new StateModelEnforcer());
			return _instance;
		}
		
		public function get state( ) : String
		{
			return _state;
		} 
		public function set state( value : String ) : void 
		{	
			trace( "\n*******************************************" );
			trace( "STATEMODEL : STATE = " + value + ",	 OLD STATE = " + _state);
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
		
		public function get webcamCount( ) : uint
		{
			return _webcamCount;
		}
		public function set webcamCount( n : uint ) : void
		{
			_webcamCount = n;
		}
	}
}

class StateModelEnforcer{}