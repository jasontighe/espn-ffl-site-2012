package leelib.facebook
{
	import com.adobe.serialization.json.JSONDecoder;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.errors.IOError;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.external.ExternalInterface;
	import flash.geom.Matrix;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.net.navigateToURL;
	import flash.system.LoaderContext;
	import flash.system.SecurityDomain;
	import flash.utils.ByteArray;
	import flash.utils.clearInterval;
	import flash.utils.setInterval;
	import flash.utils.setTimeout;
	
	import leelib.ExtendedEvent;
	import leelib.appropriated.MultipartURLLoader;
	import leelib.util.Out;
	import leelib.util.Service;
	import leelib.util.StringUtil;

	/**
	 * USAGE:
	 * 
	 * [1] Call FbUtil.init(...) to populate the necessary values.
	 * 
	 * [2] Call authorize() to start the login process, and listen for event for when it completes.
	 *
	 * 
	 * EXPLANATION: 
	 * 	
	 * In authorize(), a Facebook login window is popped up. 
	 * When the user logs in and authorizes the Facebook app, the window redirects to the callback url.
	 * This callback handler page must be deployed, presumably in the same directory as the Flash's html page.
	 * See "FbUtil.txt" included in this package directory for sample code.
	 * The callback page parses the url's querystring for the value of "code", and
	 * passes it to the parent window's function "onOauthCallback" (which was injected into the page at runtime),.
	 * which passes the value to the Flash function "onOauthCallback" (which was mapped via ExternalInterface.addCallback)
	 * 
	 * Note how "onOauthCallback" uses _flashObjectDomId to find the Flash object.  
	 * This could be done programmatically, without using a hardcoded value, using ExternalInterface.objectId, 
	 * but it's unclear this would work in IE, etc (use of "name" versus "id", etc).
	 * 
	 * 
	 * TO DO:
	 * 
	 * Logic involving "_authorizeMessage" not fully ironed out for general request() calls after authorize sequence.
	 * 
	 */
	public class FbUtilWeb extends EventDispatcher
	{
		public static const EVENT_LOGINRESULT:String = "FbUtilWeb.eventLoginResult";
		public static const EVENT_POSTRESULT:String = "FbUtilWeb.eventPostResult";
		public static const EVENT_GETMEINFORESULT:String = "FbUtilWeb.eventGetMeInfoResult";
		public static const EVENT_GETPERMISSIONSRESULT:String = "FbUtilWeb.eventGetPermissionsResult";
		public static const EVENT_GETFRIENDSRESULT:String = "FbUtilWeb.eventGetFriendsResult";
		public static const EVENT_POSTPHOTORESULT:String = "FbUtilWeb.eventPostPhotoResult";
		public static const EVENT_TAGPHOTORESULT:String = "FbUtilWeb.eventTagPhotoResult";
		
		public static const REQUESTTYPE_INFO:String 		= "REQUESTTYPE_Info";
		public static const REQUESTTYPE_PERMISSIONS:String 	= "REQUESTTYPE_Permissions";
		public static const REQUESTTYPE_LIKES:String		= "REQUESTTYPE_Likes";
		public static const REQUESTTYPE_FRIENDS:String 		= "REQUESTTYPE_Friends";
		public static const REQUESTTYPE_ALBUMLIST:String 	= "REQUESTTYPE_Albums";
		public static const REQUESTTYPE_IMAGELIST:String 	= "REQUESTTYPE_ImageList";
		public static const REQUESTTYPE_FEED:String			= "REQUESTTYPE_Feed";
		
		public static const POPUP_FUNCTION:XML = <script><![CDATA[
			function ($url, $w, $h)
			{
				var vars = 'resizable=yes,location=no,directories=no,status=no,menubar=no,scrollbars=no,toolbar=no,left=100,top=100,width='+$w+',height='+$h;
				gFbPop = window.open($url, "Facebook", vars);
				
			}
		]]></script>;
		

		private static const IS_POPUP_CLOSED_FUNCTION:XML = <script><![CDATA[
			function()
			{
				if (! gFbPop) return true;
				return gFbPop.closed;
			}
		]]></script>;


		private static var INJECT_CALLBACK_FUNCTION:XML = <script><![CDATA[
			function($flashId)
			{
				window['onOauthCallback'] = function($code)
				{
					flashObject = document.getElementById($flashId);
					flashObject.onOauthCallback($code);
				}
			}
		]]></script>;

		
		[Embed(source="fbDefaultThumb.gif")] // (note, is in source directory)
		public static const ClsFbDefaultThumb:Class;
		
		public var authUrl:String = "https://graph.facebook.com/oauth/authorize";
		public var getTokenUrl:String = "https://graph.facebook.com/oauth/access_token";
		public var graphUrl:String = "https://graph.facebook.com/"; 
		public var javascriptPopupFunction:* = POPUP_FUNCTION;
		
		private static var _instance:FbUtilWeb;

		private var _flashObjectDomId:String;
		private var _clientId:String;
		private var _clientSecret:String;
		private var _redirectUri:String; 
		private var _requestedPermissions:Array;
		private var _showBlockedStateFunction:Function;
		private var _hideBlockedStateFunction:Function;
		
		private var _isLoggingIn:Boolean;
		private var _loginInterval:Number;
		private var _code:String;
		private var _accessToken:String;
		
		private var _service:Service;
		private var _urlLoader:URLLoader;
		private var _loader:Loader;

		private var _requestCallback:Function;
		private var _postCallback:Function;
		private var _loadImageCallback:Function;
		private var _loadImagesCallback:Function
		private var _queuedImageVos:Array;
		
		private var _user:FbUserVo;
		
		
		public function FbUtilWeb($enforcer:SingletonEnforcer)
		{
			_user = new FbUserVo();
			_service = new Service();
			_loader = new Loader();
		}

		public static function getInstance():FbUtilWeb 
		{
			if (_instance == null) _instance = new FbUtilWeb(new SingletonEnforcer());
			return _instance;
		}
		
		/**
		 * 
		 * @param $flashObjectDomId		The id of the DOM object which is the Flash.
		 * @param $clientId
		 * @param $secret
		 * @param $redirectUri
		 * @param $scopeItems
		 */
		public function init($flashObjectDomId:String, $clientId:String, $secret:String, $redirectUri:String, $requestPermissions:Array, 
							 $showBlockedStateFunction:Function, $hideBlockedStateFunction:Function):void
		{
			_flashObjectDomId = $flashObjectDomId;
			_clientId = $clientId;
			_clientSecret = $secret;
			_redirectUri = $redirectUri;
			_requestedPermissions = $requestPermissions; // || ["read_stream"];
			_showBlockedStateFunction = $showBlockedStateFunction;
			_hideBlockedStateFunction = $hideBlockedStateFunction; 
		}
		
		public function get user():FbUserVo
		{
			return _user;
		}
		
		public function get isLoggedIn():Boolean
		{
			return Boolean(_accessToken && _user.id);
		}
		
		public function get accessToken():String
		{
			return _accessToken;
		}
		public function set accessToken($s:String):void
		{
			_accessToken = $s;
		}
		
		// =============================================
		// START OF AUTH SEQUENCE
		//
		public function authorize():void
		{
			_service.removeEventListener(IOErrorEvent.IO_ERROR, onGetTokenError);
			_service.removeEventListener(Event.COMPLETE, onGetToken);
			_service.removeEventListener(IOErrorEvent.IO_ERROR, onRequestError);
			_service.removeEventListener(Event.COMPLETE, onRequest);
			
			_accessToken = null;

			_isLoggingIn = true;
			_showBlockedStateFunction();
			
			// Set up callback function mechanics
			
			ExternalInterface.call(INJECT_CALLBACK_FUNCTION, _flashObjectDomId);
			ExternalInterface.addCallback("onOauthCallback", onOauthCallback);
			
			// Show login popup
			
			var url:String = authUrl + "?client_id=" + _clientId + "&redirect_uri=" + _redirectUri;			
			
			if (_requestedPermissions && _requestedPermissions.length > 0) {
				url += "&scope=" + StringUtil.commaDelimitedListFrom(_requestedPermissions);
			}

			url = encodeURI(url);
			
			trace('popup url', url);
			
			ExternalInterface.call(javascriptPopupFunction, url, 1000,550);
			
			_loginInterval = setInterval(pollPopup, 333);
		}
		private function pollPopup():void
		{
			var isClosed:Boolean = ExternalInterface.call(IS_POPUP_CLOSED_FUNCTION);
			if (isClosed)
			{
				clearInterval(_loginInterval);
				_isLoggingIn = false;
				_hideBlockedStateFunction();
				this.dispatchEvent(new FbResultEvent(EVENT_LOGINRESULT, FbResultEvent.RESULT_DISMISSED));
			}
			else
			{
				// Out.i("still open");
			}
		}
		private function onOauthCallback($locationHref:String):void
		{
			// User has logged in if necessary
			// FB has redirected to callback url.
			// Our callback url pagehandler has sent back the code to the parent page and closed itself 
			// Parent page has called this function with the token (code).
			
			Out.i("FbUtilWeb.onOauthCallback()", $locationHref);
			
			clearInterval(_loginInterval);
			
			var o:Object = StringUtil.getQueryStringObject($locationHref);
			
			if (o.error_reason) // eg, "error_reason=user_denied"
			{
				_isLoggingIn = false;
				_hideBlockedStateFunction();
				
				if (o.error_reason == "user_denied") {
					this.dispatchEvent(new FbResultEvent(EVENT_LOGINRESULT, FbResultEvent.RESULT_DENIED));
				}
				else {
					this.dispatchEvent(new FbResultEvent(EVENT_LOGINRESULT, FbResultEvent.RESULT_ERROR, o.error_reason));
				}
				return;
			}
			if (! o.code || o.code.length == 0)
			{
				_isLoggingIn = false;
				_hideBlockedStateFunction();
				this.dispatchEvent(new FbResultEvent(EVENT_LOGINRESULT, FbResultEvent.RESULT_ERROR, "No code"));
				return;
			}
			
			_code = o.code;
			Out.i('FbUtil.onOauthCallback() - got code: ', _code.substr(0, 5) + "...");

			requestToken();
		}
		private function requestToken():void
		{
			_service.addEventListener(IOErrorEvent.IO_ERROR, onGetTokenError);
			_service.addEventListener(Event.COMPLETE, onGetToken);

			var url:String = getTokenUrl + "?client_id=" + _clientId + "&client_secret=" + _clientSecret + "&redirect_uri=" + _redirectUri + "&code=" + _code; 
			
			Out.i("FbUtilWeb.requestToken() " + url);
			
			_service.request(url,null,"GET", Service.RETURNTYPE_STRING );
		}
		private function onGetTokenError($e:IOErrorEvent):void
		{
			Out.e('FbUtil.onGetTokenError() -' + $e.text);
			_service.removeEventListener(IOErrorEvent.IO_ERROR, onGetTokenError);
			_service.removeEventListener(Event.COMPLETE, onGetToken);
			_isLoggingIn = false;
			_hideBlockedStateFunction();
			this.dispatchEvent(new FbResultEvent(EVENT_LOGINRESULT, FbResultEvent.RESULT_ERROR, "Error getting access token"));
		}
		private function onGetToken($e:ExtendedEvent):void
		{
			_service.removeEventListener(IOErrorEvent.IO_ERROR, onGetTokenError);
			_service.removeEventListener(Event.COMPLETE, onGetToken);
			_isLoggingIn = false;
			_hideBlockedStateFunction();

			var s:String = $e.object as String;
			var o:Object = s ? StringUtil.getQueryStringObject(s) : null;
			if (! o || ! o["access_token"]) 
			{
				this.dispatchEvent(new FbResultEvent(EVENT_LOGINRESULT, FbResultEvent.RESULT_ERROR, "No access token value in response"));
				return;
			}

			_accessToken = o["access_token"];
			Out.i('FbUtil.onGetToken() - token:', _accessToken); // .substr(0, 5) + "...");

			this.dispatchEvent(new FbResultEvent(EVENT_LOGINRESULT, FbResultEvent.RESULT_OKAY));
		}
		//		
		// END OF AUTH SEQUENCE
		// =============================================


		// Also serves as an auth check
		//
		public function getPermissions():void
		{
			request("me", REQUESTTYPE_PERMISSIONS, onPermissions);
		}
		private function onPermissions($o:Object):void
		{
			if (! $o) {
				this.dispatchEvent(new FbResultEvent(EVENT_GETPERMISSIONSRESULT, FbResultEvent.RESULT_ERROR, "Network error"));
				return;
			}
			
			var b:Boolean = user.parsePermissions($o);
			if (b)
				this.dispatchEvent(new FbResultEvent(EVENT_GETPERMISSIONSRESULT, FbResultEvent.RESULT_OKAY));
			else
				this.dispatchEvent(new FbResultEvent(EVENT_GETPERMISSIONSRESULT, FbResultEvent.RESULT_ERROR, "Incomplete response"));
		}
		
		//
		
		public function getMeInfo():void
		{
			request("me", REQUESTTYPE_INFO, onMeInfo);			
		}
		private function onMeInfo($o:Object):void
		{
			if (! $o) {
				this.dispatchEvent(new FbResultEvent(EVENT_GETMEINFORESULT, FbResultEvent.RESULT_ERROR));
				return;
			}
			
			var b:Boolean = _user.parseUserInfo($o);
			if (! b) 
				this.dispatchEvent(new FbResultEvent(EVENT_GETMEINFORESULT, FbResultEvent.RESULT_ERROR, "Incomplete response"));
			else 
				this.dispatchEvent(new FbResultEvent(EVENT_GETMEINFORESULT, FbResultEvent.RESULT_OKAY));
		}
		
		//
		
		public function getFriends():void
		{
			request("me", REQUESTTYPE_FRIENDS, onFriends);
		}
		private function onFriends($o:Object):void
		{
			if (! $o) {
				this.dispatchEvent(new FbResultEvent(EVENT_GETFRIENDSRESULT, FbResultEvent.RESULT_ERROR));
				return;
			}
			
			var b:Boolean = _user.parseFriends($o);
			if (! b)
				this.dispatchEvent(new FbResultEvent(EVENT_GETFRIENDSRESULT, FbResultEvent.RESULT_ERROR, "No friend info in response"));
			else 
				this.dispatchEvent(new FbResultEvent(EVENT_GETFRIENDSRESULT, FbResultEvent.RESULT_OKAY));

		}
		
		//
		
		public function tagPhoto($photoId:String, $friends:Array):void
		{
			// construct json string - eg, [{"tag_uid":"1108600512"}]
			var s:String = '[';
			for (var i:int = 0; i < $friends.length; i++) {
				s += "{'tag_uid' : '" + $friends[i] + "'}";
				if (i < $friends.length-1) s += ","
			}
			s += ']';
			
			Out.d("FbUtilWeb.tagPhoto - friends array: " + $friends);
			Out.d("FbUtilWeb.tagPhoto - uid string: " + s);
			
			var o:Object = {"tags": s};
			post($photoId, "tags", o, onTagPhoto);
		}
		private function onTagPhoto($e:FbResultEvent):void
		{
			// forward event but change type to EVENT_TAGPHOTORESULT
			var e:FbResultEvent = new FbResultEvent(EVENT_TAGPHOTORESULT, $e.result, $e.message, $e.data);
			this.dispatchEvent(e);
		}
		
		// =============================================
		
		public function request($id:String, $REQUESTTYPE:String, $callback:Function):void
		{
			_requestCallback = $callback;
			
			var s:String;
			
			switch($REQUESTTYPE) 
			{
				case REQUESTTYPE_INFO:			s = ""; break; 
				case REQUESTTYPE_PERMISSIONS: 	s = "permissions"; break;
				case REQUESTTYPE_LIKES:			s = "likes"; break; 
				case REQUESTTYPE_FRIENDS:		s = "friends"; break;
				case REQUESTTYPE_ALBUMLIST:		s = "albums"; break;
				case REQUESTTYPE_IMAGELIST:		s = "photos"; break;
				case REQUESTTYPE_FEED:			s = "feed"; break;
			}
			
			_service.addEventListener(Event.COMPLETE, onRequest);
			_service.addEventListener(IOErrorEvent.IO_ERROR, onRequestError);
			_service.request(graphUrl + $id + "/" + s, { "access_token":_accessToken } );
		}
		private function onRequestError($e:IOErrorEvent):void
		{
			Out.e('FbUtil.onRequestError() - fail gracefully', $e.text);
			_service.removeEventListener(Event.COMPLETE, onRequest);
			_service.removeEventListener(IOErrorEvent.IO_ERROR, onRequestError);

			var fn:Function = _requestCallback;
			_requestCallback = null;
			fn(null);
		}
		private function onRequest($e:ExtendedEvent):void
		{
			_service.removeEventListener(Event.COMPLETE, onRequest);
			_service.removeEventListener(IOErrorEvent.IO_ERROR, onRequestError);
			
			var fn:Function = _requestCallback;
			_requestCallback = null;
			fn($e.object);
		}

		//
		
		// User icons don't need access_token qsp btw
		//
		public function makeImageUrl($id:String, $type:String="large", $withToken:Boolean=true):String
		{
			var url:String = graphUrl + $id + "/picture" + "&" + "type=" + $type;
			if ($withToken) url += "&" + "access_token=" + _accessToken;
			return url;
		}
		
		//

		public function loadImage($id:String, $callback:Function, $type:String="large"):void // small | normal | large | square
		{
			_loadImageCallback = $callback;
			
			_loader = new Loader();
			var lc:LoaderContext = new LoaderContext();
			lc.checkPolicyFile = true;
			lc.securityDomain = SecurityDomain.currentDomain;
			
			var url:String = graphUrl + $id + "/picture" + "&" + "type=" + $type+ "&" + "access_token=" + _accessToken;
			Out.i('FbUtil.loadImage()', url);
			_loader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onLoadImageSecurityError);
			_loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onLoadImageIoError);
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoadImage);
			_loader.load( new URLRequest(url), lc );
		}
		private function onLoadImageSecurityError($e:SecurityErrorEvent):void
		{
			// this can happen, eg, when facebook returns the default user profile pic, which is on a different domain 

			_loader.contentLoaderInfo.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onLoadImageSecurityError);
			_loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onLoadImageIoError);
			_loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onLoadImage);
			
			Out.e('onLoadImageSecurityError()', $e.text);
			_loadImageCallback(null);
		}
		private function onLoadImageIoError($e:IOErrorEvent):void
		{
			_loader.contentLoaderInfo.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onLoadImageSecurityError);
			_loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onLoadImageIoError);
			_loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onLoadImage);
			
			Out.e('onLoadImageIoError()', $e.text);
			_loadImageCallback(null);
		}
		private function onLoadImage(e:Event):void
		{
			_loader.contentLoaderInfo.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onLoadImageSecurityError);
			_loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onLoadImageIoError);
			_loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onLoadImage);
			
			var b:Bitmap = e.target.content as Bitmap;
			_loadImageCallback(b); // * Callback takes image as argument
		}
		
		//

		public function loadImages($arrayOfImageVos:Array, $callback:Function, $max:int=5):void
		{
			_loadImagesCallback = $callback;

			_queuedImageVos = [];
			var num:int = Math.min($arrayOfImageVos.length, $max);
			if (num == 0) { 
				_loadImagesCallback();
				return;
			}
			
			//
			
			for (var i:int = 0; i < num; i++) { // 'clone' array
				_queuedImageVos[i] = $arrayOfImageVos[i];
			}

			loadImages_2();
		}
		private function loadImages_2():void
		{
			var vo:ImageVo = _queuedImageVos[0];
			loadImage(vo.id, loadImages_3, "normal");
		}
		private function loadImages_3($b:Bitmap):void
		{
			var vo:ImageVo = _queuedImageVos.shift();
			vo.bitmap = $b;

			if (!$b) Out.e('FbUtil.onLoadAlbumImage() - NO BITMAP');

			if (_queuedImageVos.length > 0) { 
				loadImages_2();
			}
			else {
				_loadImagesCallback();
			}
		}
		
		
		/**
		 * Nothing special, basically just a regular POST
		 * 
		 * http://developers.facebook.com/docs/reference/api/post/
		 *  
		 * @param $id
		 * @param $methodCrumb	Typically just "feed"
		 * @param $params
		 * @param $callback
		 */		
		public function post($id:String, $methodCrumb:String, $params:Object, $callback:Function):void
		{
			_postCallback = $callback;
			
			var url:String = graphUrl + $id;
			if ($methodCrumb && $methodCrumb.length > 0) url += "/" + $methodCrumb;

			/*
			if (url.indexOf("?") == -1)
				url += "?access_token=" + _accessToken;
			else
				url += "&access_token=" + _accessToken;
			url += "&format=json&method=POST";
			*/
			
			Out.d('FbUtilWeb.post()', url);
			
			var urlReq:URLRequest = new URLRequest(url);
			urlReq.method = URLRequestMethod.POST;
			
			var urlVars:URLVariables = new URLVariables();
			urlVars["access_token"] = _accessToken;
			if ($params) {
				for ( var key:* in $params ) { 
					urlVars[key] = $params[key];
				}
			}
			urlReq.data = urlVars;
			
			var urlLoader:URLLoader = new URLLoader(urlReq);
			urlLoader.dataFormat = URLLoaderDataFormat.TEXT;
			
			urlLoader.addEventListener(Event.COMPLETE, onPostComplete); 
			urlLoader.addEventListener(IOErrorEvent.IO_ERROR, onPostError);
			
			urlLoader.load(urlReq); 
			
			// TEST - ACTIONS - THIS WORKS:
			// urlVars["actions"] = "{ 'name':'Action1', 'link':'http://www.yahoo.com' }";
			// TEST - PROPERTIES... NOT WORKING?
			// urlVars["properties"] = { "a search engine..." : { "text" : "Text", "href" : "http://www.yahoo.com" } }
		}
		private function onPostError($e:IOErrorEvent):void
		{
			$e.target.removeEventListener(Event.COMPLETE, onPostComplete); 
			$e.target.removeEventListener(IOErrorEvent.IO_ERROR, onPostError);

			var fn:Function = _postCallback;
			_postCallback = null;
			fn( new FbResultEvent(EVENT_POSTRESULT, FbResultEvent.RESULT_ERROR, $e.text) );
		}
		private function onPostComplete($e:Event):void
		{
			$e.target.removeEventListener(Event.COMPLETE, onPostComplete); 
			$e.target.removeEventListener(IOErrorEvent.IO_ERROR, onPostError);

			// response string is either "true/false" in plaintext, or a JSON string:
			
			var s:String = $e.target.data;
			Out.d('FbUtilWeb post response:', s);
			
			var fn:Function = _postCallback;
			_postCallback = null;

			if (s == "true") 
			{
				fn( new FbResultEvent(EVENT_POSTRESULT, FbResultEvent.RESULT_OKAY) );
			}
			else if (s == "false") 
			{
				fn( new FbResultEvent(EVENT_POSTRESULT, FbResultEvent.RESULT_ERROR, "Facebook API replied with 'false'") );
			}
			else 
			{
				// treat as JSON string
				var o:Object;
				
				try 
				{
					o = new JSONDecoder(s, false).getValue();
				}
				catch (e:Error) 
				{
					fn( new FbResultEvent(EVENT_POSTRESULT, FbResultEvent.RESULT_ERROR, "Malformed JSON response") );
					return;
				}

				for (var property:String in o) // check for an 'error' property
				{
					if (property.toLowerCase().indexOf("error") > -1)
					{
						fn( new FbResultEvent(EVENT_POSTRESULT, FbResultEvent.RESULT_ERROR, property + ": " + o[property]) );
						return;
					}
				}
				
				fn(new FbResultEvent(EVENT_POSTRESULT, FbResultEvent.RESULT_OKAY, null, o));
			}
		}

		//
		
		public function postPhoto($id:String, $params:Object, $imageFile:ByteArray):void
		{
			var multi:MultipartURLLoader = new MultipartURLLoader;
			multi.addFile($imageFile, "reportcard.jpg");
			multi.addVariable("access_token", _accessToken);
			for ( var key:* in $params ) { 
				multi.addVariable(key, $params[key]);
			}

			multi.addEventListener(IOErrorEvent.IO_ERROR, onPostPhotoError);
			multi.addEventListener(Event.COMPLETE, onPostPhotoComplete);
			multi.load(graphUrl + $id + "/photos");
			
			// Rem, it appears not possible to both post and tag at the same time (7/2012)
			// multi.addVariable("tags", '[{"to":"1108600512","x":0,"y":0}]'); - "invalid key 'to'" - also tried "id" and "tag_uid"
		}
		private function onPostPhotoError($e:IOErrorEvent):void
		{
			var multi:MultipartURLLoader = $e.target as MultipartURLLoader;
			multi.removeEventListener(IOErrorEvent.IO_ERROR, onPostPhotoError);
			multi.removeEventListener(Event.COMPLETE, onPostPhotoComplete);

			this.dispatchEvent(new FbResultEvent(EVENT_POSTPHOTORESULT, FbResultEvent.RESULT_ERROR)); 
		}
		private function onPostPhotoComplete($e:Event):void
		{
			var multi:MultipartURLLoader = $e.target as MultipartURLLoader;
			multi.removeEventListener(IOErrorEvent.IO_ERROR, onPostPhotoError);
			multi.removeEventListener(Event.COMPLETE, onPostPhotoComplete);

			// Out.d('onPostPhotoComplete() response: ', multi.loader.data);
			
			var o:Object = new JSONDecoder(multi.loader.data, false).getValue();
			this.dispatchEvent(new FbResultEvent(EVENT_POSTPHOTORESULT, FbResultEvent.RESULT_OKAY, null, o));
		}
		
		//

		// Do this check after doing getPermissions(). 
		//
		public function get currentPermissionsIncludeRequestedPermissions():Boolean
		{
			for (var i:int = 0; i < _requestedPermissions.length; i++)
			{
				var req:String = _requestedPermissions[i];
				if (_user.permissions.indexOf(req) == -1) return false;
			}
			return true;
		}
	}
}
class SingletonEnforcer {}


/*
private function loadProfileThumb():void
{
loadImage(_user.id, onLoadProfileThumb, "square");
}
private function onLoadProfileThumb($image:Bitmap):void
{
if ($image && $image.bitmapData) {
_user.profileImageSquare = $image.bitmapData;
}
else {
// Don't complain
// _authErrorMessages += "Error getting profile image\n";
}

}

finishAuth(); // ... done



request(_user.id, REQUESTTYPE_LIKES, onRequestLikes);

private function onRequestLikes($o:Object):void
{
_user.parseLikes($o);
// ...
}



request(_user.id, REQUESTTYPE_FEED, onRequestWall);

private function onRequestWall($o:Object):void
{
_user.parseFeedForFriendActivity($o);
}



request(_user.id, REQUESTTYPE_ALBUMLIST, onRequestAlbums);

private function onRequestAlbums($o:Object):void
{
_user.parseAlbumList($o);

// pick album with most items
if (_user.getBiggestAlbum()) {
request(_user.getBiggestAlbum().id, REQUESTTYPE_IMAGELIST, onRequestImageList);
}
else {
loadImage(_user.id, onLoadProfileThumb);
}
}

private function onRequestImageList($o:Object):void
{
if (! user.getBiggestAlbum()) {
trace('FbUtil.onRequestImageList - No albums.');
loadProfileThumb();
return;
}

//

user.getBiggestAlbum().parsePhotos($o);
loadImages( user.getBiggestAlbum().imageVos, loadProfileThumb );
}

private function loadProfileThumb():void
{
loadImage(_user.id, onLoadProfileThumb);
}
private function onLoadProfileThumb($image:Bitmap):void
{
if ($image && $image.bitmapData)
_user.profilePic = $image.bitmapData;
else
_authorizeMessage += "Error getting profile image\n";

//$image.width = 64;
//$image.scaleY = $image.scaleX;
//$image.x = $image.y = 10;
//Global.getInstance().stage.addChild($image);

_user.isDataPopulated = true;

this.dispatchEvent(new ExtendedEvent(Event.COMPLETE, { message:_authorizeMessage } ) );
}
*/
