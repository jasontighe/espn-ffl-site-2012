package com.espn.ffl.views.report_card.vos
{
	import leelib.util.Out;

	// is 'owned' by TeamVo
	public class PlayerVo
	{
		public var id:String;
		public var name:String;
		public var proTeam:String;
		public var primaryPosition:String;
		
		public var draftNumber:int; // order the player was chosen in draft. not used in algorithm.
		
		// derived from ReportCard.rankings array
		public var berryRank:int;

		
		public function PlayerVo()
		{
		}
		
		public static function makeFromDraftResultObject($o:Object, $draftNumber:int):PlayerVo
		{
			var pvo:PlayerVo = new PlayerVo();
			pvo.draftNumber = $draftNumber;
			
			if (! $o.playerId) {
				Out.w("PlayerVo.makeFromDraftResultObject - NO PLAYER ID, RETURNING NULL");
				return null;
			}
			pvo.id = $o.playerId;
			
			if (! $o.playerName) {
				Out.w("PlayerVo.makeFromDraftResultObject - NO PLAYER NAME, RETURNING NULL");
				return null;
			}
			pvo.name = $o.playerName;

			if (! $o.proTeam) {
				Out.w("PlayerVo.makeFromDraftResultObject - NO PRO TEAM, RETURNING NULL");
				return null;
			}
			pvo.proTeam = $o.proTeam;
			
			if (! $o.primaryPosition) {
				Out.w("PlayerVo.makeFromDraftResultObject - NO PRIMARYPOSITION, FYI");
			}
			pvo.primaryPosition = $o.primaryPosition;
			
			return pvo;
		}
	}
}
