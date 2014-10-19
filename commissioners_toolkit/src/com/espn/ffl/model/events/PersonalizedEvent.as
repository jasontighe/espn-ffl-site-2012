package com.espn.ffl.model.events {
	import flash.events.Event;

	/**
	 * @author jason.tighe
	 */
	public class PersonalizedEvent 
	extends Event 
	{
		//----------------------------------------------------------------------------
		// public static constants
		//----------------------------------------------------------------------------
		public static const INTRO						: String = "intro";
		public static const ADD_WEBCAM					: String = "addWebcam";
		public static const POSTIONER					: String = "positioner";
		public static const LEARN						: String = "learn";
		public static const QUESTION					: String = "question";
		public static const READY						: String = "ready";
		public static const COUNTDOWN					: String = "countdown";
		public static const RECORDING					: String = "recording";
		public static const ADD_PHOTO					: String = "addPhoto";
		public static const STOPPED						: String = "stopped";
		public static const COMPLETED					: String = "completed";
		public static const RESET						: String = "reset";
		public static const CREATED						: String = "created";
		public static const FLUSH						: String = "flush";
		//----------------------------------------------------------------------------
		// private model properties
		//----------------------------------------------------------------------------
		private var _item								: Object;
		//----------------------------------------------------------------------------
		// constructor
		//----------------------------------------------------------------------------
		public function PersonalizedEvent(type:String, bubbles:Boolean, item:Object = null)
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
