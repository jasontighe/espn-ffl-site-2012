package com.espn.ffl.views.report_card.vos
{
	import flash.utils.Dictionary;
	
	import leelib.facebook.FbFriendVo;
	import leelib.util.Out;

	public class TeamVo
	{
		public var id:String;
		public var teamLocation:String;
		public var teamNickname:String;
		
		public var managerFirstName:String;
		public var managerLastName:String;
		public var managerUserName:String;
		
		public var playersById:Dictionary;
		
		// derived:
		public var cumulativePoints:int;			 
		
		public var assignedGrade:String; 			 
		public var userGrade:String;	 			
		
		public var assignedComment:String;
		public var userComment:String;
		
		
		public function TeamVo()
		{
		}

		public function get fullTeamName():String
		{
			var s:String = "";
			if (teamLocation && teamLocation.length > 0) s += teamLocation;
			if (teamNickname && teamNickname.length > 0) {
				if (s.length > 0) s += " ";
				s += teamNickname;
			}
			return s;
		}
		
		public static function makeFromDraftResultObject($o:Object):TeamVo
		{
			if (! $o.teamId) {
				Out.w("TeamVo.fromDraftResultObject - NO TEAM ID, RETURNING NULL");
				return null;
			}

			var tvo:TeamVo = new TeamVo();
			tvo.id = $o.teamId;
			tvo.teamLocation = $o.teamLocation || "";
			tvo.teamNickname = $o.teamNickname || "";			
			return tvo;
			
			// ... rem, team manager info must get filled in later
		}
	}
	
}
