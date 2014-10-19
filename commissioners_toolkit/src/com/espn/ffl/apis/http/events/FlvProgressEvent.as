package com.espn.ffl.apis.http.events {
	import flash.events.Event;

	/**
	 * @author jason.tighe
	 */
	public class FlvProgressEvent 
	extends Event
	{
		//----------------------------------------------------------------------------
		// public static constants
		//----------------------------------------------------------------------------
		public static const PROGRESS_UPLOADING			: String = "progressUploading";
		public static const PROGRESS_RECEIVED			: String = "progressReceived";
		public static const PROGRESS_DONE				: String = "progressDone";
		//----------------------------------------------------------------------------
		// private model properties
		//----------------------------------------------------------------------------
		private var _item								: Object;
		//----------------------------------------------------------------------------
		// constructor
		//----------------------------------------------------------------------------
		public function FlvProgressEvent( type : String, bubbles : Boolean = false, item : Object = null )
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
