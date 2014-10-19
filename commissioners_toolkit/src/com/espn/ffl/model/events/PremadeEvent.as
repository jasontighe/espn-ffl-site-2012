package com.espn.ffl.model.events {
	import flash.events.Event;

	/**
	 * @author jason.tighe
	 */
	public class PremadeEvent 
	extends Event 
	{
		//----------------------------------------------------------------------------
		// public static constants
		//----------------------------------------------------------------------------
		public static const VIDEO_SELECTOR				: String = "videoSelector";
		public static const COMPLETED					: String = "completed";
		public static const FLUSH						: String = "flush";
		public static const CREATED						: String = "created";
//		public static const DELETED						: String = "deleted";
		//----------------------------------------------------------------------------
		// private model properties
		//----------------------------------------------------------------------------
		private var _item								: Object;
		//----------------------------------------------------------------------------
		// constructor
		//----------------------------------------------------------------------------
		public function PremadeEvent(type:String, bubbles:Boolean, item:Object = null)
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
