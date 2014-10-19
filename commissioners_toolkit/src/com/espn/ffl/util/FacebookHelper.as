package com.espn.ffl.util 
{
	import com.adobe.serialization.json.JSON;
	import com.espn.ffl.constants.APIConstants;
	import com.espn.ffl.model.ConfigModel;
	import com.espn.ffl.model.ContentModel;
	import com.espn.ffl.model.LeagueModel;
	import com.espn.ffl.model.dto.CopyDTO;
	import com.espn.ffl.views.Main;
	import com.espn.ffl.views.dialogs.enforcerPicker.EnforcerDialog;
	import com.espn.ffl.views.dialogs.mapper.MapperDialog;
	import com.espn.ffl.views.report_card.vos.TeamVo;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.SharedObject;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	import leelib.ExtendedEvent;
	import leelib.facebook.FbFriendVo;
	import leelib.facebook.FbResultEvent;
	import leelib.facebook.FbUserVo;
	import leelib.facebook.FbUtilWeb;
	import leelib.util.Out;
	import leelib.util.Service;

	
	public class FacebookHelper extends EventDispatcher
	{
		public static const EVENT_LOGINRESULT:String = "fbh.eventAuthorizeResult";
		public static const EVENT_FRIENDPICKER_RESULT:String = "fbh.eventFriendPickerResult";
		public static const EVENT_INVITESHARE_RESULT:String = "fbh.eventInviteShareResult";
		public static const EVENT_LOGGEDOUT:String = "fbh.eventLoggedOut";

		public static const MESSAGE_LOGINERROR:String = "An error occurred logging into Facebook. Please try again.";
		public static const MESSAGE_USERDIDNTAUTHORIZE_FBAPP:String = "Please authorize page to share on Facebook.";
		public static const MESSAGE_LOGIN_FIRST:String = "Please log in first.";
		public static const MESSAGE_PICKFRIENDS_FIRST:String = "Please select your friends first.";
		public static const MESSAGE_FACEBOOK_POST_ERROR:String = "Sorry, an error occurred posting to Facebook. Please try again.";
		public static const MESSAGE_FACEBOOK_SUCCEEDED_INVITER:String = "Your invite/s have been sent.";
		public static const MESSAGE_FACEBOOK_SUCCEEDED_REPORTCARD:String = "Your report card/s has been posted.";
		public static const MESSAGE_FACEBOOK_SUCCEEDED_ENFORCER:String = "Your video/s have been posted.";
		public static const MESSAGE_LOGGEDOUT:String = "You've logged out of the Commissioner Toolkit Facebook app.";

		// not sure about this one
		public static const EVENT_VERIFYLOGINANDPERMISSIONS:String = "wkFfl.eventVlpgf";

		public static const PERMISSIONS:Array = ["publish_stream", "user_photos"];

		private static const COOKIE_NAME:String = "espnFflFbHelper";

		private static var _instance:FacebookHelper;

		private var _fb:FbUtilWeb;
		private var _cm:ContentModel = ContentModel.gi;
		private var _main:Main;
		
		private var _isFullyLoggedIn:Boolean;

		private var _mapperDialog:MapperDialog;
		private var _enforcerDialog:EnforcerDialog;

		private var _multiPostIds:Array;
		private var _multiPostIndex:int;
		private var _multiPostObject:Object;
		
		private var _loginCallback:Function;
		private var _showMapAfterLogin:String;

		private var _reportCardBytes:ByteArray;
		private var _serialShareInviterNotEnforcer:Boolean;
		
		private var _teamFriendMap:Object; // key = teamId; value = facebook friend id
		
		private var _serviceGet:Service;
		private var _serviceSet:Service;


		public function FacebookHelper($enforcer:SingletonEnforcer)
		{
			Out.i("FacebookHelper.ctor()");
			
			_fb = FbUtilWeb.getInstance();

			_serviceGet = new Service();
			_serviceSet = new Service();
			
			_enforcerDialog = new EnforcerDialog();
			_mapperDialog = new MapperDialog(); 
		}
		
		public static function get instance():FacebookHelper 
		{
			if (_instance == null) {
				_instance = new FacebookHelper(new SingletonEnforcer());
			}
			return _instance;
		}
		
		/**
		 * ConfigModel and ContentModel must be initialized before init.
		 * init must be called before use.
		 */
		public function init($main:Main):void
		{
			_main = $main;

			var cf:ConfigModel = ConfigModel.gi;
			_fb.init(cf.flashDomId, cf.facebookAppId, cf.facebookSecret, cf.facebookCallbackUrl, PERMISSIONS, _main.showDimmer, _main.hideDimmer);
		}

		public function get facebookUtil():FbUtilWeb
		{
			return _fb;
		}
		
		public function get user():FbUserVo
		{
			return _fb.user;
		}
		
		public function get isFullyLoggedIn():Boolean
		{
			return _isFullyLoggedIn;
		}
		
		public function get hasMeInfo():Boolean
		{
			return (_fb.user && _fb.user.id);
		}
		
		public function get hasFriendsInfo():Boolean
		{
			return (_fb.user && _fb.user.friends);
		}
		
		public function get teamFriendMap():Object
		{
			return _teamFriendMap;
		}
		
		public function getFriendIdsFromMap():Array
		{
			var a:Array = [];
			for each (var friendIdValue:String in _teamFriendMap) {
				if (friendIdValue.length > 0) a.push(friendIdValue);
			}
			
			Out.i("FacebookHelper.getFriendIdsFromMap()", a);
			
			return a;
		}
		
		public function getFriendVosFromMap():Array // O(n*m)
		{
			var ids:Array = getFriendIdsFromMap();
			var a:Array = [];
			for each (var friendId:String in ids) {
				var vo:FbFriendVo = _fb.user.getFriendById(friendId);
				if (! vo) {
					Out.w("FacebookHelper.getFriendVosFromMap - LOOKUP FAILED, SKIPPING", friendId);
				}
				else {
					a.push(vo);
				}
			}
			return a;
		}

		// Called by Shell after loading league model
		//
		public function validateMapTeamIdsAgainstLeagueModel():void
		{
			var keys:Array = [];
			for (var s:String in _teamFriendMap) {
				keys.push(s);
			}
			
			for each (var key:String in keys) 
			{
				var teamId:String = key;
				if (! LeagueModel.gi.getTeamVoById(teamId)) {
					// this really shouldn't happen
					Out.w("FacebookHelper.validateTeamIdsInMapAgainstLeagueModel() - NO MATCH FOR TEAMID, DELETING FROM MAP! ", key);
					delete _teamFriendMap[key];
				}
			}
		}
		
		private function validateMapFriendIds():void
		{
			var keys:Array = [];
			for (var s:String in _teamFriendMap) {
				keys.push(s);
			}

			for each (var key:String in keys) 
			{
				var teamId:String = key;
				var friendId:String = _teamFriendMap[teamId];
				if (! friendId || friendId.length == 0) continue;
				
				var friendVo:FbFriendVo = _fb.user.getFriendById(friendId);
				if (! friendVo) { 
					// person was de-friended or whatever
					Out.w("FacebookHelper.validateMapFriendsIds - NO MATCH FOR FACEBOOKID, DELETING FROM MAP! ", friendId)
					delete _teamFriendMap[key];
				}
			}
		}
		
		
		// Use this to set _teamFriendMap. 
		// Do not set _teamFriendMap directly
		//
		private function setAndSaveTeamFriendMap($o:Object):void
		{
			_teamFriendMap = $o;
			
			Out.i("FacebookHelper.setAndSaveTeamFriendMap()");
			printTeamFriendMap(_teamFriendMap);
			
			var s:String = JSON.encode(_teamFriendMap);
			Out.i("FacebookHelper.setAndSaveTeamFriendMap() - jsonified: " + s);

			// Save to service, but don't wait on it or anything else
			var url:String = ConfigModel.gi.mappingsSetStringUrl + "?" + "league_id=" + LeagueModel.gi.leagueId + "&" + "facebook_id=" + _fb.user.id + "&" + "str=" + s;
			_serviceSet.addEventListener(Event.COMPLETE, onSetMappings);
			_serviceSet.request(url, null, "GET", Service.RETURNTYPE_STRING);
		}
		private function onSetMappings($e:ExtendedEvent):void
		{
			if ($e.object && $e.object.indexOf("success") > -1) 
				Out.i("FacebookHelper.onSetMappings() - " + $e.object);
			else
				Out.e("FacebookHelper.onSetMappings() - UNEXPECTED RESPONSE: " + $e.object);
		}
			
		public function printTeamFriendMap($tfm:Object):void
		{
			Out.i("---------------------------------------------------------------");
			Out.i("FacebookHelper.printTeamFriendMap()");
			for (var teamId:String in $tfm) 
			{
				var teamVo:TeamVo = LeagueModel.gi.getTeamVoById(teamId);
				var teamName:String = teamVo ? teamVo.fullTeamName : "";
				
				var friendId:String = $tfm[teamId];
				var friendVo:FbFriendVo = _fb.user.getFriendById(friendId);
				var friendName:String = friendVo ? friendVo.name : "";
				
				Out.i('team id [' + teamId + '] team name [' + teamName + '] friend id [' + friendId + '] friend name [' + friendName + ']');
			}
			Out.i("---------------------------------------------------------------");
		}
		
		// No longer using this.
		public function clearAccessToken():void
		{
			_isFullyLoggedIn = false;
			_fb.accessToken = null;
		}

		// ==============
		// LOGIN SEQUENCE
		// ==============
		
		// $showMap should be "yes" or "no"
		public function login($showMapAfterLogin:String, $successCallback:Function=null):void
		{
			_loginCallback = $successCallback;
			_showMapAfterLogin = $showMapAfterLogin;
			
			doAuthPopup();
		}

		// [0]  
		private function verifyPermissionsPreLogin():void
		{
			_main.showPinwheel();
			_fb.addEventListener(FbUtilWeb.EVENT_GETPERMISSIONSRESULT, onVerifyPermissionsPreLogin);
			_fb.getPermissions();
		}
		private function onVerifyPermissionsPreLogin($e:FbResultEvent):void
		{
			_fb.removeEventListener(FbUtilWeb.EVENT_GETPERMISSIONSRESULT, onVerifyPermissionsPreLogin);

			if ($e.result != FbResultEvent.RESULT_OKAY || ! _fb.currentPermissionsIncludeRequestedPermissions) 
				doAuthPopup();
			else 
			 	getMeInfo(); // go straight to getting me-info 
		}
		
		// [1] 
		private function doAuthPopup():void
		{
			// clear some values
			_isFullyLoggedIn = false;
			_fb.accessToken = null;
			
			_fb.addEventListener(FbUtilWeb.EVENT_LOGINRESULT, onAuthPopupResponse);
			_fb.authorize();
		}
		
		private function onAuthPopupResponse($e:FbResultEvent):void
		{
			switch ($e.result)
			{
				case FbResultEvent.RESULT_DISMISSED:
					// -->|
					break; 
					
				case FbResultEvent.RESULT_DENIED:
					_main.showDialogWithCopyDtoId(false, "alertFbPermissions", function():void{ Main.instance.hideDialog(); login(_showMapAfterLogin, _loginCallback); } ); // -->| 
					break; 
					
				case FbResultEvent.RESULT_ERROR: 
					_fb.accessToken = null;
					_main.showDialogWithCopyDtoId(false, "alertFbLoginError", function():void{ Main.instance.hideDialog(); login(_showMapAfterLogin, _loginCallback); } ); // -->|
					break;
				
				case FbResultEvent.RESULT_OKAY:
				default:
					verifyPermissions();
					break;
			}
		}
		
		// [2]
		private function verifyPermissions():void
		{
			_main.showPinwheel();
			
			_fb.addEventListener(FbUtilWeb.EVENT_GETPERMISSIONSRESULT, onVerifyPermissions);
			_fb.getPermissions();
		}
		
		private function onVerifyPermissions($e:FbResultEvent):void
		{
			_fb.removeEventListener(FbUtilWeb.EVENT_GETPERMISSIONSRESULT, onVerifyPermissions);

			if ($e.result != FbResultEvent.RESULT_OKAY) 
			{
				_main.hidePinwheel();
				_main.showDialogWithCopyDtoId(false, "alertFbLoginError", function():void{ Main.instance.hideDialog(); login(_showMapAfterLogin, _loginCallback); } ); // -->|
			}
			else 
			{
				if (! _fb.currentPermissionsIncludeRequestedPermissions) {
					_main.hidePinwheel();
					_main.showDialogWithCopyDtoId(false, "alertFbPermissions", function():void{ Main.instance.hideDialog(); login(_showMapAfterLogin, _loginCallback); } ); // -->|
				}
				else {
					getMeInfo();
				}
			}
		}
		
		// [3]
		private function getMeInfo():void
		{
			_fb.addEventListener(FbUtilWeb.EVENT_GETMEINFORESULT, onGetMeInfo);
			_fb.getMeInfo();
		}
		private function onGetMeInfo($e:FbResultEvent):void
		{
			_fb.removeEventListener(FbUtilWeb.EVENT_GETMEINFORESULT, onGetMeInfo);
			
			if ($e.result != FbResultEvent.RESULT_OKAY) 
			{
				_main.hidePinwheel();
				_main.showDialogWithCopyDtoId(false, "alertFbLoginError", function():void{ Main.instance.hideDialog(); login(_showMapAfterLogin, _loginCallback); }); // -->|
			}
			else 
			{
				getFriends();
			}
		}
		
		// [4]
		private function getFriends():void
		{
			_fb.addEventListener(FbUtilWeb.EVENT_GETFRIENDSRESULT, onGetFriends);
			_fb.getFriends();
		}
		private function onGetFriends($e:FbResultEvent):void
		{
			_fb.removeEventListener(FbUtilWeb.EVENT_GETMEINFORESULT, onGetFriends);

			_main.hidePinwheel();

			if ($e.result != FbResultEvent.RESULT_OKAY) 
			{
				_main.showDialogWithCopyDtoId(false, "alertFbLoginError", function():void{ Main.instance.hideDialog(); login(_showMapAfterLogin, _loginCallback); }); 
				return; // -->|
			}
			
			getMappings();
		}
		
		private function getMappings():void
		{
			_serviceGet.addEventListener(Event.COMPLETE, onGetMappings);
			var url:String = ConfigModel.gi.mappingsGetStringUrl + "?" + "league_id=" + LeagueModel.gi.leagueId + "&" + "facebook_id=" + _fb.user.id;
			trace('FacebookHelper.getMappings() - ', url);
			_serviceGet.request(url, null, "GET", Service.RETURNTYPE_STRING);
		}
		private function onGetMappings($e:ExtendedEvent):void
		{
			trace('FacebookHelper.onGetMappings() - ', $e.object);
			
			var s:String = $e.object as String;
			if (! s || s.length == 0) {
				_teamFriendMap = [];
			}
			else {
				try {
					_teamFriendMap = JSON.decode(s, false);
					printTeamFriendMap(_teamFriendMap);
				}
				catch (e:Error) {
					Out.e("FacebookHelper.onGetMappings() -", e.message);
				}
			}
			
			// [5] login fully done
			
			validateMapFriendIds();

			_isFullyLoggedIn = true;

			if (_showMapAfterLogin == "yes")
				doMapperDialog();
			else
				if (_loginCallback != null) {
					var f:Function = _loginCallback;
					_loginCallback = null;
					f();
				}
		}
		
		public function doMapperDialog($callback:Function=null):void
		{
			if ($callback != null) {
				_loginCallback = $callback;
			}
			else {
				// leave _loginMapperCallback as it was, having been set at the login() stage...
			}
			
			_mapperDialog.initializeBeforeShow(LeagueModel.gi.teamsByAlpha, _fb.user.friends, _teamFriendMap);
			_mapperDialog.yesButtonCallback = onMapperDialogYes;
			_mapperDialog.closeButtonCallback = onMapperDialogClose;
			_main.showDialog(_mapperDialog);
			
			Metrics.pageView("shareSettings");
		}
		
		private function onMapperDialogYes():void
		{
			setAndSaveTeamFriendMap( _mapperDialog.makeTeamFriendMapFromCurrentState() );
			
			// [6] callback, if any
			if (_loginCallback != null) { 
				var f:Function = _loginCallback;
				_loginCallback = null;
				f();
			}
			
			Main.instance.hideDialog();
			
			Metrics.pageView("shareSettingsSaveButton");
		}
		
		private function onMapperDialogClose():void
		{
			Main.instance.hideDialog();
			Metrics.pageView("shareSettingsCloseButton");
		}
		
		
		// ===============
		//  OUR WEBSERVICE
		// ===============
		
		public function getMapFromService():void
		{
			
		}
		
		public function saveMapToService():void
		{
			
		}
		
		// ===========
		// REPORT CARD
		// ===========

		public function doReportCardShare($imageFile:ByteArray):void
		{
			Out.i("FacebookHelper.doReportCardShare()");
			_reportCardBytes = $imageFile;
			
			doReportCardShare_2();
		}
		
		private function doReportCardShare_2():void
		{
			_main.showPinwheel();
			_fb.addEventListener(FbUtilWeb.EVENT_POSTPHOTORESULT, onPostReportCard);
			
			// _fb.postPhoto("me", { "name":_enforcerDialog.committedMessage }, _reportCardBytes);
			_fb.postPhoto("me", {  }, _reportCardBytes);
		}
		
		private function onPostReportCard($e:FbResultEvent):void
		{
			_fb.removeEventListener(FbUtilWeb.EVENT_POSTPHOTORESULT, onPostReportCard);

			if ($e.result != FbResultEvent.RESULT_OKAY)
			{
				_main.hidePinwheel();
				_main.showDialogWithCopyDtoId(false, "alertFbPostError", doReportCardShare_2); // -->|
				return;
			}
			
			var o:Object = $e.data as Object;
			if (! o || ! o.id) // null or incomplete response 
			{
				_main.hidePinwheel();
				_main.showDialogWithCopyDtoId(false, "alertFbPostError", doReportCardShare_2); // -->|
				return;
			}
	
			// [3] tag photo
			_fb.addEventListener(FbUtilWeb.EVENT_TAGPHOTORESULT, onTagPhotoResult);
			_fb.tagPhoto(o.id, getFriendIdsFromMap());
		}
		
		private function onTagPhotoResult($e:FbResultEvent):void
		{
			_fb.removeEventListener(FbUtilWeb.EVENT_TAGPHOTORESULT, onTagPhotoResult)
			_main.hidePinwheel();
			
			if ($e.result != FbResultEvent.RESULT_OKAY)
			{
				_main.showDialogWithCopyDtoId(false, "alertFbPostError", doReportCardShare_2); // -->|
				return;
			}

			// done
			_main.showToastWithCopyDto(_cm.getCopyItemByName("toastFbPostedReportCard"));
		}
		
		// ===========		
		// ENFORCER
		// ===========		

		public function doEnforcerShare($postParams:Object):void
		{
			_multiPostObject = $postParams;
			_serialShareInviterNotEnforcer = false;

			if (! isFullyLoggedIn) 
				login("no", doEnforcerShare_2);
			else
				doEnforcerShare_2();
		}
		private function doEnforcerShare_2():void
		{
			// show enforcer dialog
			var friendVos:Array = getFriendVosFromMap();
			_enforcerDialog.setVos(friendVos);
			_enforcerDialog.yesButtonCallback = onEnforcerShareDialogYes;
			_enforcerDialog.noButtonCallback = onEnforcerShareDialogNo;
			_main.showDialog(_enforcerDialog);
			
			Metrics.pageView("enforcerShareDialog");
		}
		
		private function onEnforcerShareDialogNo():void
		{
			_main.hideDialog();
			
			Metrics.pageView("enforcerShareDialogCancelButton");			
		}

		private function onEnforcerShareDialogYes():void
		{
			Main.instance.hideDialog();
			
			// add the picker dialog user text to the post object
			if (_enforcerDialog.committedMessage && _enforcerDialog.committedMessage.length > 0) 
				_multiPostObject.message = _enforcerDialog.committedMessage;
			
			Out.i("FacebookHelper - enforcer share message: [" + _multiPostObject.message + "]");

			// do facebook posts to friends' walls, one by one
			_multiPostIds = _enforcerDialog.getSelectedIds();
			_multiPostIndex = 0;
			
			trace('onEnforcerShareDialogYes - About to post to these ids:', _multiPostIds); 
			doNextVideoPost()
			
			Metrics.pageView("enforcerShareDialogPublishButton");			
		}

		// ===========		
		// INVITER
		// ===========		
		
		public function doInviterShare($postParams:Object):void
		{
			_multiPostObject = $postParams;
			_serialShareInviterNotEnforcer = true;

			if (! isFullyLoggedIn)
				login("no", doInviterShare_2);
			else
				doInviterShare_2();
		}
		private function doInviterShare_2():void
		{
			_multiPostIds = getFriendIdsFromMap();
			_multiPostIndex = 0;

			trace('onInviterShare_2 - About to post to these ids:', _multiPostIds);
			doNextVideoPost();
		}
		
		// SERIAL POSTING LOGIC FOR BOTH ENFORCER AND INVITER
		
		private function doNextVideoPost():void
		{
			_main.showPinwheel();

			Out.i("FacebookHelper.doNextVideoPost()", (_multiPostIndex+1), "of", _multiPostIds.length);
			_fb.post(_multiPostIds[_multiPostIndex], "feed", _multiPostObject, onVideoPostResult);
		}
		private function onVideoPostResult($e:FbResultEvent):void
		{
			if ($e.result != FbResultEvent.RESULT_OKAY) 
			{
				_main.hidePinwheel();
				_main.showDialogWithCopyDtoId(false, "alertFbPostError", doNextVideoPost); // -->|
				// (when user selects "Try Again", it retries same friend and continues from there)
				return;
			}
			
			_multiPostIndex++;
			
			if (_multiPostIndex < _multiPostIds.length) {
				doNextVideoPost();
			}
			else {
				// done
				_main.hidePinwheel();
				var dto:CopyDTO = _cm.getCopyItemByName(_serialShareInviterNotEnforcer ? "toastFbPostedInvite" : "toastFbPostedEnforcer");

				_main.showToastWithCopyDto(dto); // -->|
			}
		}
	}
}

class SingletonEnforcer {}
