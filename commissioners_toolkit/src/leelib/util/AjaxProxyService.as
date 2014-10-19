package leelib.util
{
	import com.adobe.serialization.json.JSON;
	import com.adobe.serialization.json.JSONDecoder;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.external.ExternalInterface;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLVariables;
	
	import leelib.ExtendedEvent;


	/**
	 * Was forced to make this a Singleton class to avoid certain race conditions, and 
	 * a runtime error that only started happening later on that I can't figure out when using multiple instances.
	 * 
	 * Before use, "flashId" must be assigned, and jQuery must be already loaded.
	 */
	public class AjaxProxyService extends Service
	{
		private static const INJECT_AJAX_FUNCTION:XML = <script><![CDATA[
			function($flashId)
			{
				window['doAjax'] = function($url)
				{
					$.ajax( { 
						url: $url, 
						success: function(data) { 
							document.getElementById($flashId).onAjaxResponse(data); 
						},
						error: function(xhr, textStatus, errorThrown) { 
							document.getElementById($flashId).onAjaxResponse("ERROR | " + textStatus + " | " + errorThrown); 
						}
					} );
				}
			}
		]]></script>;
		// ... returned error info could be handled more formally...

		private static var _instance:AjaxProxyService;
		private static var _flashId:String;
		private static var _haveAddedJs:Boolean;
		

		public function AjaxProxyService($singletonEnforcer:SingletonEnforcer)
		{
		}

		public static function get instance():AjaxProxyService 
		{
			if (_instance == null) _instance = new AjaxProxyService(new SingletonEnforcer());
			return _instance;
		}

		public static function get flashId():String
		{
			return _flashId;
		}
		
		public static function set flashId($s:String):void
		{
			_flashId = $s;
		}
		
		public static function get doesFlashIdElementExist():Boolean
		{
			var s:String = ExternalInterface.call("function() { return document.getElementById('flashContent').toString(); } ");
			return (s != null);
		}
		 
		public static function get doesJqueryExist():Boolean
		{
			return ExternalInterface.call("$.ajax"); 
		}
		
		private function init():void
		{
			if (! doesJqueryExist) {
				throw new Error("AjaxProxyService - JQUERY DOES NOT SEEM TO BE LOADED");
			}
			if (! doesFlashIdElementExist) {
				throw new Error("Static var 'flashId' not set, or not found in DOM.");
			}
			
			if (! _haveAddedJs) 
			{
				ExternalInterface.call(INJECT_AJAX_FUNCTION, flashId);
				ExternalInterface.addCallback("onAjaxResponse", onAjaxResponse);
				_haveAddedJs = true;
			}
		}
		
		/**
		 * Test for doesJqueryExist and doesFlashIdElementExist before invoking.
		 * 
		 * URL params should be encoded directly into the $url string.
		 * Don't use any of the optional arguments. 
		 */
		public override function request($url:String, $params:Object=null, $method:String="GET", $returnType:String=Service.RETURNTYPE_JSON, $sendTypeJson:Boolean=false):void
		{
			if (! _haveAddedJs) init();
			
			_returnType = $returnType;

			ExternalInterface.call("doAjax", $url);
		}
		
		private function onAjaxResponse($o:Object):void
		{
			// old multi-instance thing, which now causes error when using 2nd instance for some reason, and is not try/catch'able
			// ExternalInterface.addCallback("onAjaxResponse", null); // hah
			
			if (! $o) {
				Out.e("AjaxProxyService.onAjaxReponse - NULL RESPONSE");
				this.dispatchEvent(new ExtendedEvent(Event.COMPLETE, null));
				return;
			}
			if ( $o is String && $o.indexOf("ERROR") == 0) {
				Out.e("AjaxProxyService.onAjaxResponse -", $o);
				this.dispatchEvent(new ExtendedEvent(Event.COMPLETE, null));
				return;
			}
			
			var o:Object = castResponse($o);
			o = transform(o);
			this.dispatchEvent(new ExtendedEvent(Event.COMPLETE, o ));
		}
		
		protected override function castResponse($responseData:Object):Object
		{
			if (_returnType == RETURNTYPE_STRING) 
			{
				return $responseData as String;	
			}
			else if (_returnType == RETURNTYPE_JSON) 
			{
				if ($responseData is String)
				{
					var o:Object;
					try {
						o = new JSONDecoder($responseData as String, false).getValue();
					}
					catch (e:Error) {
						Out.e("AjaxProxyService.castResponse()", e.message);
					}
					return o;
				}
				else if ($responseData is Object) // is-already-Object
				{
					return $responseData;
				}
				else
				{
					Out.e("Unexpected response type?");
					return null;
				}
			}
			else if (_returnType == RETURNTYPE_XML)
			{
				return new XML($responseData) as Object;
			}
			
			return null;
		}
	}
}

class SingletonEnforcer {}
