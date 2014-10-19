package com.espn.ffl.model.events {
	import flash.events.Event;

	/**
	 * @author jason.tighe
	 */
	public class FflButtonEvent 
	extends Event 
	{
		//----------------------------------------------------------------------------
		// public static constants
		//----------------------------------------------------------------------------
		public static const FFL_OVER					: String = "fflOver";
		public static const FFL_OUT						: String = "fflOut";
		//----------------------------------------------------------------------------
		// private model properties
		//----------------------------------------------------------------------------
		private var _item								: Object;
		//----------------------------------------------------------------------------
		// constructor
		//----------------------------------------------------------------------------
		public function FflButtonEvent(type:String, bubbles:Boolean, item:Object = null)
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
