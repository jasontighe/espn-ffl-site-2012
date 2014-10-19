package com.espn.ffl.model.events {
	import flash.events.Event;

	/**
	 * @author jason.tighe
	 */
	public class StateEvent 
	extends Event 
	{
		//----------------------------------------------------------------------------
		// public static constants
		//----------------------------------------------------------------------------
		public static const COMMISSIONER				: String = "commissioner";
		public static const LEAGUE_MANAGER				: String = "leagueManager";
		public static const TOUTS						: String = "touts";
		public static const INVITER						: String = "inviter";
		public static const ENFORCER					: String = "enforcer";
		public static const REPORT_CARD					: String = "reportCard";
		public static const APPAREL						: String = "apparel";
		public static const VIDEO_CREATED				: String = "videoCreated";
		public static const VIDEO_APPROVED				: String = "videoApproved";
		public static const VIDEO_UNAPPROVED			: String = "videoUnapproved";
		public static const VIDEO_REJECTED				: String = "videoRejected";
		//----------------------------------------------------------------------------
		// private model properties
		//----------------------------------------------------------------------------
		private var _item								: Object;
		//----------------------------------------------------------------------------
		// constructor
		//----------------------------------------------------------------------------
		public function StateEvent(type:String, bubbles:Boolean, item:Object = null)
		{
			super(type, bubbles);
			
			_item = item;
		}
		
		//----------------------------------------------------------------------------
		// public implicit getters/setters
		//----------------------------------------------------------------------------
		public function get item():Object
		{
			return _item;
		}
	}
}
