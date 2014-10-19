package com.espn.ffl.apis.http {
	import leelib.ExtendedEvent;

	import com.adobe.serialization.json.JSON;
	import com.espn.ffl.constants.APIConstants;
	import com.espn.ffl.model.ConfigModel;
	import com.espn.ffl.model.ContentModel;
	import com.espn.ffl.model.InviterModel;
	import com.espn.ffl.model.LeagueModel;

	import flash.events.AsyncErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.HTTPStatusEvent;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;

	/**
	 * @author jason.tighe
	 */
	public class HusaniRequestor 
	extends EventDispatcher 
	{
		//----------------------------------------------------------------------------
		// public static constants
		//----------------------------------------------------------------------------
		public static const GET_VIDEO_STATUS				: String = "getVideoStatus";
//		public static const SET_IMAGE_PERSONALIZED			: String = "setImagePersonalized";
//		public static const SET_IMAGE_PPREMADE				: String = "setImagePremade";
		public static const SET_IMAGE_URL					: String = "setImageURL";
		public static const INITIALIZE						: String = "initialize";
		public static const SET_WEBCAM_URL					: String = "setWebcamURL";
		public static const SET_PREMADE_URL					: String = "setPremadeURL";
		public static const RESET							: String = "reset";
		public static const EVENT_ERROR						: String = "husaniRequestor.eventError";		
		//----------------------------------------------------------------------------
		// private variables
		//----------------------------------------------------------------------------
		private var _lm										: LeagueModel = LeagueModel.gi;
		private var _cm										: ContentModel = ContentModel.gi;
		private var _im										: InviterModel = InviterModel.gi;
		private var _cf										: ConfigModel = ConfigModel.gi;
		private var _leagueId								: String;
		private var _seasonId								: String;
		private var _url									: String;
		private var _photoUrl								: String;
		private var _webcamNum								: uint;
		private var _duration								: int;
		private var _requestType							: String;
		private var _premadeVideoId							: uint;
		//----------------------------------------------------------------------------
		// constructor
		//----------------------------------------------------------------------------
		public function HusaniRequestor( target : IEventDispatcher = null ) 
		{
			trace( "________________________________________________________________");
			trace( "HUSANIREQUESTOR : Constr" );
			super(target);
		}
		
		//----------------------------------------------------------------------------
		// public methods
		//----------------------------------------------------------------------------
		public function request( type : String, num : uint = 0, time : uint = 0 ) : void
		{
			trace( "HUSANIREQUESTOR : request() : type is "+type );
			_requestType = type;
			
			var urlRequest : URLRequest = new URLRequest();
			var urlVariables : URLVariables = new URLVariables();
			var leagueId : String = getLeagueId();
			
			switch ( type )
			{
					
				case  INITIALIZE:
					urlRequest.url = _cf.liCustomServicesUrl + _cf.initializeURL;
					urlRequest.method = URLRequestMethod.POST;
					urlVariables.league_id = leagueId;   //_lm.leagueId;
					urlVariables.league_name = _lm.leagueName;
					urlVariables.league_manager_name = _lm.firstName+" "+_lm.lastName;
					urlVariables.user_profile_id  = _lm.userProfileId;
					urlVariables.video_type = _im.videoType; 
					break;
					
				case  RESET:
					urlRequest.url = _cf.liCustomServicesUrl + _cf.resetURL;
					urlRequest.method = URLRequestMethod.GET;
					urlVariables.league_id = leagueId;   //_lm.leagueId;
					break;
					
				case  GET_VIDEO_STATUS:
					urlRequest.url = _cf.liCustomServicesUrl + _cf.statusURL;
					urlRequest.method = URLRequestMethod.GET;
					urlVariables.league_id = leagueId;   //_lm.leagueId;
					break;
					
				case  SET_PREMADE_URL:
					urlRequest.url = _cf.liCustomServicesUrl + _cf.premadeURL;
					urlRequest.method = URLRequestMethod.POST;
					urlVariables.league_id = leagueId;   //_lm.leagueId;
					urlVariables.video_id = _premadeVideoId;
					break;
					
				case  SET_WEBCAM_URL:
				trace( "\n\n\n\n\n\n\nHUSANIREQUESTOR : request() : SET_WEBCAM_URL : _webcamNum is "+_webcamNum+"\n\n\n\n\n\n\n" );
					urlRequest.url = _cf.liCustomServicesUrl + _cf.webcamURL;
					urlRequest.method = URLRequestMethod.POST;
					urlVariables.league_id = leagueId;   //_lm.leagueId;
					urlVariables.webcam_num = _webcamNum;
					urlVariables.length = _duration;
					urlVariables.webcam_url = _url;	
					break;
					
				case  SET_IMAGE_URL:
				trace( "\n\n\n\n\n\n\nHUSANIREQUESTOR : request() : SET_IMAGE_URL \n\n\n\n\n\n\n" );
					urlRequest.url = _cf.liCustomServicesUrl + _cf.photoURL;
					urlRequest.method = URLRequestMethod.POST;
					urlVariables.league_id = leagueId   //_lm.leagueId;
					urlVariables.photo_url = _photoUrl;	
					break;
			}

//			var leagueName : String = LeagueModel.gi.leagueName;	
				//_lm.;
			urlRequest.data = urlVariables;	
			
			trace( "HUSANIREQUESTOR : request() : urlRequest.url is "+urlRequest.url );
		    for (var name:String in urlVariables) 
		    {
		    	trace( "HUSANIREQUESTOR : request() Sent " + name + " as: " + urlVariables[name]);
		    }
		     
		    var loader : URLLoader = new URLLoader();
		    loader.dataFormat = URLLoaderDataFormat.TEXT;
		    loader.addEventListener( Event.COMPLETE, onRequestComplete );
		    loader.addEventListener( HTTPStatusEvent.HTTP_STATUS, httpStatusHandler );
		    loader.addEventListener( SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler );
		    loader.addEventListener( AsyncErrorEvent.ASYNC_ERROR, errorHandlerAsyncErrorEvent );
		    loader.addEventListener( IOErrorEvent.IO_ERROR, errorHandlerIOErrorEvent );
		    loader.addEventListener( IOErrorEvent.IO_ERROR, infoIOErrorEvent );
		    
		     
		    try
		    {
		  	  loader.load( urlRequest );
		    }
			catch (error:ArgumentError) 
			{ 
			    trace("HUSANIREQUESTOR : request() : An ArgumentError has occurred."); 
			} 
			catch (error:SecurityError) 
			{ 
			    trace("HUSANIREQUESTOR : request() : A SecurityError has occurred."); 
			}
		    catch (error:Error)
		    {
		    	trace("HUSANIREQUESTOR : request() : Unable to load URL");
		    }
		}
		
		//----------------------------------------------------------------------------
		// private methods
		//----------------------------------------------------------------------------
		private function dispatchCompleteEvent( ) : void
		{
			dispatchEvent( new Event( Event.COMPLETE ) );
		}
		
		private function setValues( decodedJSON : Object ) : void
		{
			switch ( _requestType )
			{		
				case  INITIALIZE:
					if( decodedJSON.status == "success")	InviterModel.gi.parseData( decodedJSON.details );
					break;
					
				case  RESET:
					request( HusaniRequestor.INITIALIZE );
					break;
					
				case  GET_VIDEO_STATUS:
					if( decodedJSON.status == "success")
					{
						InviterModel.gi.parseData( decodedJSON.details );
					}
					break;
					
				case  SET_WEBCAM_URL:
					break;
					
			}
				
			trace( "________________________________________________________________");
		}
		
		
		//----------------------------------------------------------------------------
		// event handlers
		//----------------------------------------------------------------------------
		private function onRequestComplete( e : Event ) : void
		{
			trace( "HUSANIREQUESTOR : onRequestComplete()" );
			var loader : URLLoader = e.target as URLLoader;
			var jsonData : String = loader.data;
			trace( "HUSANIREQUESTOR : onRequestComplete() : loader.data is "+loader.data );
			var decodedJSON : Object = JSON.decode( jsonData );
			
			var key : String;
			for (key in decodedJSON )
			{
				trace( "HUSANIREQUESTOR : onRequestComplete() : decodedJSON[key] is "+key+" : "+decodedJSON[key] );
			}
			
			setValues( decodedJSON );
			
			if( _requestType != RESET ) dispatchCompleteEvent();
		}
		
		private function httpStatusHandler( e : HTTPStatusEvent ) : void
		{
			trace( "HUSANIREQUESTOR : ************************************** httpStatusHandler:" + e.type );
//			dispatchEvent(new ExtendedEvent(EVENT_ERROR, e.type));
		}

		private function securityErrorHandler( e : SecurityErrorEvent ) : void
		{
			trace( "HUSANIREQUESTOR : ************************************** securityErrorHandler:" + e.text );
			dispatchEvent(new ExtendedEvent(EVENT_ERROR, e.text));
		}

		private function errorHandlerAsyncErrorEvent( e : AsyncErrorEvent ) : void
		{
			trace( "HUSANIREQUESTOR : ************************************** errorHandlerAsyncErrorEvent:" + e.toString() );
			dispatchEvent(new ExtendedEvent(EVENT_ERROR, e.text));
		}

		private function errorHandlerIOErrorEvent( e : IOErrorEvent ) : void
		{
			trace( "HUSANIREQUESTOR : ************************************** errorHandlerIOErrorEvent:" + e.toString() );
			dispatchEvent(new ExtendedEvent(EVENT_ERROR, e.text));
		}

		private function infoIOErrorEvent( e : IOErrorEvent ) : void
		{
			trace( "HUSANIREQUESTOR : ************************************** infoIOErrorEvent:" + e.toString() );
			dispatchEvent(new ExtendedEvent(EVENT_ERROR, e.text));
		}
		
		//----------------------------------------------------------------------------
		// getter/setters
		//----------------------------------------------------------------------------
		public function set url( s : String ) : void
		{
			_url = s;
		}
		
		public function set photoUrl( s : String ) : void
		{
			_photoUrl = s;
		}
		
		public function set webcamNum( n : uint ) : void
		{
			_webcamNum = n;
		}
		
		public function set premadeVideoId( n : uint ) : void
		{
			_premadeVideoId = n + 1;
		}
		
		public function set duration( n : int ) : void
		{
			_duration = n
		}
		
		public function getLeagueId() : String
		{
			var s : String;
			if( ConfigModel.gi.leagueIdUseReal)
			{
				s = _lm.leagueId
			}
			else if( ConfigModel.gi.leagueIdUseRandom ) 
			{
				s = ConfigModel.gi.randomLeagueId;
			}
			else
			{
				s = ConfigModel.gi.leagueIdFake;
			}
			
			return s;
		}
	}
}
