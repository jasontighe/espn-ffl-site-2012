package com.espn.ffl.apis.http.events {
	import flash.events.Event;

	/**
	 * @author jason.tighe
	 */
	public class EncodingEvent 
	extends Event 
	{
		//----------------------------------------------------------------------------
		// public static constants
		//----------------------------------------------------------------------------
		public static const STARTING					: String = "starting";
		public static const UPLOADING					: String = "uploading";
		public static const PROCESSING					: String = "processing";
		public static const DONE						: String = "done";
		public static const FILE_UPLOADED				: String = "fileUploaded";
		public static const ERROR						: String = "error";
		public static const WEBCAMS_UPLOADED			: String = "stitchesUploaded";
		//----------------------------------------------------------------------------
		// private model properties
		//----------------------------------------------------------------------------
		private var _item								: Object;
		//----------------------------------------------------------------------------
		// constructor
		//----------------------------------------------------------------------------
		public function EncodingEvent( type : String, bubbles : Boolean = false, item : Object = null )
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
