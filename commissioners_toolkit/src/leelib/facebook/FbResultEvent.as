package leelib.facebook
{
	import flash.events.Event;
	
	public class FbResultEvent extends Event
	{
		public static const RESULT_OKAY:String = "okay";
		public static const RESULT_ERROR:String = "error";

		public static const RESULT_DISMISSED:String = "dismissed";
		public static const RESULT_DENIED:String = "denied";
		
		
		public var result:String; 
		public var message:String;
		public var data:*;

		/**
		 * @param $result	eg, RESULT_OKAY, etc.
		 * @param $message	extra description of the result. Eg, an error message.
		 * @param $data		optional
		 * 
		 */
		public function FbResultEvent($eventName:String, $result:String, $message:String=null, $data:*=null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super($eventName, bubbles, cancelable);
			
			result = $result;
			message = $message;
			data = $data;
		}
	}
}