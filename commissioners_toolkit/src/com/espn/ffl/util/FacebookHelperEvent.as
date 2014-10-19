package com.espn.ffl.util
{
	import flash.events.Event;
	
	public class FacebookHelperEvent extends Event
	{
		public static const RESULT_OKAY:String = "okay";
		public static const RESULT_ERROR:String = "error";
		public static const RESULT_CANCELLED:String = "cancelled";
		public static const RESULT_DENIED:String = "denied";
		
		public var result:String; 
		public var message:String;
		public var data:*;
		
		/**
		 * @param $result	eg, RESULT_OKAY, etc.
		 * @param $message	optional extra description of the result. Eg, an error message.
		 * @param $data		optional
		 */
		public function FacebookHelperEvent($eventName:String, $result:String, $message:String=null, $data:*=null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super($eventName, bubbles, cancelable);
			
			result = $result;
			message = $message;
			data = $data;
		}
	}
}