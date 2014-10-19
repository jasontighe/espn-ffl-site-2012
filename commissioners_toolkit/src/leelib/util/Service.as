package leelib.util
{
	import com.adobe.serialization.json.JSON;
	import com.adobe.serialization.json.JSONDecoder;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLVariables;
	
	import leelib.ExtendedEvent;
	
	
	public class Service extends EventDispatcher
	{
		public static const RETURNTYPE_STRING:String = "service.returnTypeString";
		public static const RETURNTYPE_JSON:String = "service.returnTypeJsonObject";
		public static const RETURNTYPE_XML:String = "service.returnTypeXml";

		protected var _returnType:String;

		
		public function Service()
		{
		} 
		
		public function request($url:String, $params:Object=null, $method:String="GET", $returnType:String=RETURNTYPE_JSON, $sendTypeJson:Boolean=false):void
		{
			Out.d('Service.request() ' + $url + "?" + paramsToString($params));
			
			_returnType = $returnType;
			
			var urlReq:URLRequest = new URLRequest($url);
			urlReq.method = $method;
			
			var urlVars:URLVariables = new URLVariables();
			
			if (! $sendTypeJson) 
			{
				for ( var i:* in $params ) { 
					urlVars[i] = $params[i];
				}
				urlReq.data = urlVars;
			}
			else
			{
				urlReq.data = com.adobe.serialization.json.JSON.encode($params);
				urlReq.requestHeaders = [ new URLRequestHeader("Content-Type", "application/json"), new URLRequestHeader("charset", "utf-8") ];
			}

			//
			
			var urlLoader:URLLoader = new URLLoader(urlReq);
			urlLoader.dataFormat = URLLoaderDataFormat.TEXT;
			urlLoader.addEventListener(Event.COMPLETE, onLoaded); 
			urlLoader.addEventListener(IOErrorEvent.IO_ERROR, onError);
			urlLoader.load(urlReq); 
		}
		
		private function onError($event:IOErrorEvent):void
		{
			Out.e('Service.onError()', $event.text);

			var urlLoader:URLLoader = $event.target as URLLoader;
			urlLoader.removeEventListener(Event.COMPLETE, onLoaded); 
			urlLoader.removeEventListener(IOErrorEvent.IO_ERROR, onError);
			
			this.dispatchEvent($event); 
		}

		private function onLoaded($event:Event):void
		{
			var urlLoader:URLLoader = $event.target as URLLoader;
			urlLoader.removeEventListener(Event.COMPLETE, onLoaded); 
			urlLoader.removeEventListener(IOErrorEvent.IO_ERROR, onError);
			
			var s:String = urlLoader.data;
			
			Out.d("Service.onLoaded");
			Out.v(s);
			
			var o:Object = castResponse(s);
			o = transform(o);
			this.dispatchEvent(new ExtendedEvent(Event.COMPLETE, o ));
		}
		
		
		protected function castResponse($responseData:Object):Object
		{
			var s:String = $responseData as String;
			
			if (_returnType == RETURNTYPE_STRING) 
			{
				return s;	
			}
			else if (_returnType == RETURNTYPE_JSON) 
			{
				var o:Object;
				try {
					o = new JSONDecoder(s, false).getValue();
				}
				catch (e:Error) {
					Out.e("Service.castResponse()", e.message);
				}
				return o;
			}
			else if (_returnType == RETURNTYPE_XML)
			{
				return new XML(s) as Object;
			}
			
			return null;
		}
		
		/**
		 * Override if desired.
		 * Idea is to take the XML, JSON, or string, and "transform" it 
		 * into ready-to-use data objects, or whatever  
		 */
		protected function transform($o:Object):Object
		{
			return $o
		}
		
		private function paramsToString($o:Object):String
		{
			var string:String = "";
			for (var s:String in $o) {
				string += s + "=" + $o[s] + "&";
			}
			return string;
		}		
	}
}
