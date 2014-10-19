package com.espn.ffl.model.events {
	import flash.events.Event;

	/**
	 * @author jason.tighe
	 */
	public class InviterEvent 
	extends Event 
	{
		//----------------------------------------------------------------------------
		// public static constants
		//----------------------------------------------------------------------------
		public static const PERSONALIZED				: String = "personalized";
		public static const PREMADE						: String = "premade";
		public static const PREVIEW						: String = "preview";
		public static const CREATED						: String = "created";
		public static const RESET						: String = "created";
		//----------------------------------------------------------------------------
		// private model properties
		//----------------------------------------------------------------------------
		private var _item								: Object;
		//----------------------------------------------------------------------------
		// constructor
		//----------------------------------------------------------------------------
		public function InviterEvent(type:String, bubbles:Boolean, item:Object = null)
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
