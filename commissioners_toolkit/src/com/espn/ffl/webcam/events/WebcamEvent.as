package com.espn.ffl.webcam.events {
	import flash.events.Event;

	/**
	 * @author jason.tighe
	 */
	public class WebcamEvent 
	extends Event 
	{
		//----------------------------------------------------------------------------
		// public static constants
		//----------------------------------------------------------------------------
		public static const WEBCAM_DENIED				: String = "webcamDenied";
		public static const WEBCAM_ACCPEPTED			: String = "webcamAccepted";
		public static const WEBCAM_ACTIVE				: String = "webcamActive";
		public static const WEBCAM_INACTIVE				: String = "webcamInactive";
		//----------------------------------------------------------------------------
		// private model properties
		//----------------------------------------------------------------------------
		private var _item								: Object;
		//----------------------------------------------------------------------------
		// constructor
		//----------------------------------------------------------------------------
		public function WebcamEvent( type : String, bubbles : Boolean = false, item : Object = null )
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
