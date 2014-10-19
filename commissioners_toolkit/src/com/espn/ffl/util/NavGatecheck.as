package com.espn.ffl.util {
	import com.espn.ffl.model.ContentModel;
	import com.espn.ffl.model.LeagueModel;
	import com.espn.ffl.model.StateModel;
	import com.espn.ffl.views.Main;

	import flash.net.URLRequest;
	import flash.net.navigateToURL;

	/**
	 * @author jason.tighe
	 */
	public class NavGatecheck 
	{
		//----------------------------------------------------------------------------
		// private variables
		//----------------------------------------------------------------------------
		private static var _instance 					: NavGatecheck;
		//----------------------------------------------------------------------------
		// constructor
		//----------------------------------------------------------------------------
		public function NavGatecheck(  e : NavGatecheckEnforcer ) {}
		 
		//----------------------------------------------------------------------------
		// getter/setters
		//----------------------------------------------------------------------------
		public static function get gi() : NavGatecheck
		{
			if(!_instance) _instance = new NavGatecheck(new NavGatecheckEnforcer());
			return _instance;
		}
		
		public function checkCommissioner( id : uint ) : void
		{
			if ( LeagueModel.gi.isCommissioner )
				updateState( id );
			else
				Main.instance.showNotCommissionerDialog();
		}
		
		private function updateState( id : uint ) : void
		{
			
			var name : String = ContentModel.gi.getSectionItemAt( id ).name;
			switch ( name )
			{
				case "LEAGUE INVITER":
					StateModel.gi.state = StateModel.STATE_INVITER;
					break;
					
				case "REPORT CARD":
					StateModel.gi.state = StateModel.STATE_REPORT_CARD;
					break;
					
				case "THE ENFORCER":
					StateModel.gi.state = StateModel.STATE_ENFORCER;
					break;
					
				case "TEAM GEAR":
					var url : String = ContentModel.gi.getSectionItemAt( id ).url;
					var urlRequest : URLRequest = new URLRequest( url );
					navigateToURL( urlRequest, "_blank");
//					StateModel.gi.state = StateModel.STATE_APPAREL;		
					break;
			}
		}
	}
}

class NavGatecheckEnforcer{}
