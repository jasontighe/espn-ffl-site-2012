package com.espn.ffl.model {
	import flash.events.EventDispatcher;
	import flash.external.ExternalInterface;
	
	import leelib.util.Out;

	/**
	 * @author jason.tighe
	 */
	public class ConfigModel 
	extends EventDispatcher 
	{
		//----------------------------------------------------------------------------
		// private variables
		//----------------------------------------------------------------------------
		private static var _instance 					: ConfigModel;
		
		private static const FBSECRET_DEV_LOCAL			:String = "a04483e91ee03589ad45129a4dfd585b"; // ! must be hardcoded
		private static const FBSECRET_DEV_EXTERNAL		:String = "16a79443c09f05f9294f9983adc2ff93";
		private static const FBSECRET_ESPNQA			:String = "5f1b4893ec9f4e8ddba7b03a4ef035b3";
		private static const FBSECRET_ESPNPROD			:String = "b9033d2c6c95c3dc90c50466ae3ccf23";
		//----------------------------------------------------------------------------
		// protected variables
		//----------------------------------------------------------------------------
		protected var _bgColor							: uint;
		protected var _createLeagueURL					: String;
		protected var _defaultSeason					: String;
		protected var _uploadFlvs 						: String = "true";
		protected var _flvProgress 						: String = "true";
		protected var _cookieLI 						: String = "true";
		protected var _stageW	 						: uint = 100;
		protected var _stageH	 						: uint = 100;
		protected var _siteURL							: String;
		protected var _contentURL						: String;
		protected var _assetsURL						: String;
		protected var _assets2URL						: String;
		protected var _fontsURL							: String;
		protected var _soundURL 						: String;
		protected var _stylesURL 						: String;
		protected var _encodingURL 						: String;
		protected var _reportCardURL					: String;
		protected var _fonts							: Array = new Array();
		
		protected var _s3AccessKey						: String;
		protected var _s3BucketName						: String;
		
		protected var _mappingsGetStringUrl				: String;
		protected var _mappingsSetStringUrl				: String;
		
		protected var _environment						: XML;
		protected var _flashDomId						: String; 
		protected var _facebookSecret					: String;
		
		protected var _leagueIdFake						: String;
		protected var _leagueIdUseRandom				: String;
		protected var _leagueIdUseReal					: String;
		
		protected var _randomLeagueIdMade				: Boolean = false;
		protected var _randomLeagueId					: String;
		
		protected var _gaLevel1							: String;
		
		protected var _initializeURL					: String;
		protected var _webcamURL						: String;
		protected var _resetURL							: String;
		protected var _statusURL						: String;
		protected var _photoURL							: String;
		protected var _premadeURL						: String;
		
		protected var _apparelURL						: String;
		
		protected var _isPressPreview					: Boolean;
		
		protected var _notLoggedInUrlSubstring			: String;
		
		
		//----------------------------------------------------------------------------
		// constructor
		//----------------------------------------------------------------------------
		public function ConfigModel( e : ConfigModelEnforcer ) 
		{
			trace( "CONFIGMODEL : Constr" );
		}
		
		public function addData( data : * ) : void
		{
			var xml : XML = XML( data );
			
			// TODO - CONFIG SHOULD BE LOCALE SPECIFIC & DICTATE THESE PROPERTIES
			
			if( xml.bg_color )					_bgColor = uint( "0x" + xml.bg_color );
			if( xml.create_league )				_createLeagueURL = xml.create_league;
			if( xml.apparel )					_apparelURL = xml.apparel;
			if( xml.default_season )			_defaultSeason = xml.default_season;
			if( xml.webcam.@uploadFlvs )		_uploadFlvs = xml.webcam.@uploadFlvs;
			if( xml.webcam.@flvProgress )		_flvProgress = xml.webcam.@flvProgress;
			if( xml.webcam.@cookieLI )			_cookieLI = xml.webcam.@cookieLI;
			if( xml.site_url )					_siteURL =  xml.site_url ;
			if( xml.subloads.content.@url )		_contentURL = xml.subloads.content.@url;
			if( xml.subloads.assets.@url )		_assetsURL = xml.subloads.assets.@url;
			if( xml.subloads.assets2.@url )		_assets2URL = xml.subloads.assets2.@url;
			if( xml.subloads.fonts.@url )		_fontsURL = xml.subloads.fonts.@url;
			if( xml.subloads.styles.@url )		_stylesURL = xml.subloads.styles.@url;
			if( xml.subloads.sounds.@url )		_soundURL = xml.subloads.sounds.@url;
			if( xml.subloads.encoding.@url )	_encodingURL = xml.subloads.encoding.@url;
			if( xml.subloads.reportCard.@url )	_reportCardURL = xml.subloads.reportCard.@url;

			if( xml.league_id.@fake )			_leagueIdFake = xml.league_id.@fake;
			if( xml.league_id.@useRandom )		_leagueIdUseRandom = xml.league_id.@useRandom;			
			if( xml.league_id.@useReal )		_leagueIdUseReal = xml.league_id.@useReal;
			
			if( xml.apiUrls.s3AccessKey.@value) _s3AccessKey = xml.apiUrls.s3AccessKey.@value;
			if( xml.apiUrls.s3BucketName.@value) _s3BucketName = xml.apiUrls.s3BucketName.@value;
			
			if( xml.apiUrls.mappingsGetString.@url ) _mappingsGetStringUrl = xml.apiUrls.mappingsGetString.@url;
			if( xml.apiUrls.mappingsSetString.@url ) _mappingsSetStringUrl = xml.apiUrls.mappingsSetString.@url;
			
			if( xml.web_services.@initializeURL )	_initializeURL = xml.web_services.@initializeURL;
			if( xml.web_services.@webcamURL )		_webcamURL = xml.web_services.@webcamURL;
			if( xml.web_services.@resetURL )		_resetURL = xml.web_services.@resetURL;
			if( xml.web_services.@statusURL )		_statusURL = xml.web_services.@statusURL;
			if( xml.web_services.@photoURL )		_photoURL = xml.web_services.@photoURL;
			if( xml.web_services.@premadeURL )		_premadeURL = xml.web_services.@premadeURL;
			
			_flashDomId = xml.environment.@flashDomId;
			
			if( xml.isPressPreview)					_isPressPreview = (xml.isPressPreview == "true");
			if( xml.notLoggedInUrlSubstring) 		_notLoggedInUrlSubstring = xml.notLoggedInUrlSubstring;
			
			//

			var thisHref:String = ExternalInterface.call("window.location.href.toString");
			for (var i:int = 0; i < xml.environment.item.length(); i++)
			{
				var node:XML = xml.environment.item[i];

				if (node.@domainDetect)
				{
					if (thisHref.indexOf(node.@domainDetect) > -1) 
					{
						_environment = node;
						
						var envType:String = _environment.@type; 
						switch (envType)
						{
							case "devlocal": 
								_facebookSecret = FBSECRET_DEV_LOCAL; 
								break; 
							case "devexternal": 
								_facebookSecret = FBSECRET_DEV_EXTERNAL; 
								break; 
							case "espnqa": 
								_facebookSecret = FBSECRET_ESPNQA; 
								break;
							case "espnprod": 
								_facebookSecret = FBSECRET_ESPNPROD; 
								break;
							default: 
								Out.w("ConfigModel.addData() - NO MATCH FOR ENVIRONMENT TYPE. FACEBOOK FUNCTIONALITY WILL FAIL");
								_facebookSecret = "NONE_SET!";
								break;
						}
						
						break; // exit for loop
					}
				}
			}
			if (! _environment) Out.w("ConfigModel.addData() - NO MATCH ON WINDOW HREF. FACEBOOK FUNCTIONALITY WILL FAIL"); 
			
			preview();
		}

		//----------------------------------------------------------------------------
		// private methods
		//----------------------------------------------------------------------------
		private function preview() : void 
		{
			trace( "CONFIGMODEL : preview() : notLoggedInURLSubstring is "+notLoggedInUrlSubstring);
			trace( "CONFIGMODEL : preview() : _bgColor is "+_bgColor );
			trace( "CONFIGMODEL : preview() : _createLeagueURL is "+_createLeagueURL );
			trace( "CONFIGMODEL : preview() : _defaultSeason is "+_defaultSeason );
			trace( "CONFIGMODEL : preview() : _uploadFlvs is "+_uploadFlvs );
			trace( "CONFIGMODEL : preview() : _flvProgress is "+_flvProgress );
			trace( "CONFIGMODEL : preview() : _cookieLI is "+_cookieLI );
			trace( "CONFIGMODEL : preview() : _siteURL is "+_siteURL );
			trace( "CONFIGMODEL : preview() : _contentURL is "+_contentURL );
			trace( "CONFIGMODEL : preview() : _assetsURL is "+_assetsURL );
			trace( "CONFIGMODEL : preview() : _assets2URL is "+_assets2URL );
			trace( "CONFIGMODEL : preview() : _fontsURL is "+_fontsURL );
			trace( "CONFIGMODEL : preview() : _stylesURL is "+_stylesURL );
			trace( "CONFIGMODEL : preview() : _soundURL is "+_soundURL );
			trace( "CONFIGMODEL : preview() : _encodingURL is "+_encodingURL );
			trace( "CONFIGMODEL : preview() : _reportCardURL is "+_reportCardURL );
			
			trace( "CONFIGMODEL : preview() : _leagueIdFake is "+_leagueIdFake );
			trace( "CONFIGMODEL : preview() : _leagueIdUseRandom is "+_leagueIdUseRandom );
			trace( "CONFIGMODEL : preview() : _leagueIdUseReal is "+_leagueIdUseReal );
			trace( "" );
			trace( "CONFIGMODEL : preview() : _mappingsGetString is "+_mappingsGetStringUrl );
			trace( "CONFIGMODEL : preview() : _mappingsSetString is "+_mappingsSetStringUrl );
			trace( "" );
			trace( "CONFIGMODEL : preview() : _environment exists? "+ Boolean(_environment) );
			trace( "CONFIGMODEL : preview() : environmentType is " +  environmentType );
			trace( "CONFIGMODEL : preview() : isEspnEnvironment? " +  isEspnEnvironment );
			trace( "CONFIGMODEL : preview() : customServiceUrl is " + customServiceUrl );
			trace( "CONFIGMODEL : preview() : facebookAppId is " + facebookAppId );
			trace( "CONFIGMODEL : preview() : _facebookSecret is " + _facebookSecret.substr(0,3)+"..." );
			trace( "CONFIGMODEL : preview() : enforcerBaseUrlVideos is " + enforcerBaseUrlVideos);
			trace( "" );
			trace( "CONFIGMODEL : preview() : _initializeURL is "+_initializeURL );
			trace( "CONFIGMODEL : preview() : _webcamURL is "+_webcamURL );
			trace( "CONFIGMODEL : preview() : _resetURL is "+_resetURL );
			trace( "CONFIGMODEL : preview() : _statusURL is "+_statusURL );
			trace( "CONFIGMODEL : preview() : _photoURL is "+_photoURL );
			trace( "CONFIGMODEL : preview() : _premadeURL is "+_premadeURL );
			trace( "" );
			trace( "" );
		}
		 
		//----------------------------------------------------------------------------
		// getter/setters
		//----------------------------------------------------------------------------
		public static function get gi() : ConfigModel
		{
			if(!_instance) _instance = new ConfigModel(new ConfigModelEnforcer());
			return _instance;
		}
		
		public function get notLoggedInUrlSubstring():String
		{
			return _notLoggedInUrlSubstring;
		}
		
		public function get isOnNotLoggedInPage():Boolean
		{
			var s:String = ExternalInterface.call("window.location.href.toString");
			
			Out.i('isOnNotLoggedInPage()', s, _notLoggedInUrlSubstring, s.indexOf(_notLoggedInUrlSubstring)); 
			
			return (s.indexOf(_notLoggedInUrlSubstring) > -1);
		}
		
		public function get bgColor( ) : uint 
		{
			return _bgColor;
		}
		
		public function get uploadFlvs( ) : Boolean 
		{
			var boolean : Boolean = true;
			if( _uploadFlvs != "true" )	boolean = false;
			return boolean;
		}
		
		public function get flvProgress( ) : Boolean 
		{
			var boolean : Boolean = true;
			if( _flvProgress != "true" )	boolean = false;
			return boolean;
		}
		
		public function get cookieLI( ) : Boolean 
		{
			var boolean : Boolean = true;
			if( _cookieLI != "true" )	boolean = false;
			return boolean;
		}
		
		public function get stageW( ) : uint 
		{
			return _stageW;
		}
		
		public function set stageW( n : uint ) : void
		{
			_stageW = n;
		}
		
		public function get stageH( ) : uint 
		{
			return _stageH;
		}
		
		public function set stageH( n : uint ) : void
		{
			_stageH = n;
		}
		
		public function get siteURL( ) : String 
		{
			return _siteURL;
		}
		
		public function get createLeagueURL( ) : String 
		{
			return _createLeagueURL;
		}
		
		public function get contentURL( ) : String 
		{
			return _contentURL;
		}
		
		public function get assetsURL( ) : String 
		{
			return _assetsURL;
		}
		
		public function get assets2URL( ) : String 
		{
			return _assets2URL;
		}

		public function get stylesURL( ) : String 
		{
			return _stylesURL;
		}
		
		public function get fontsURL( ) : String 
		{
			return _fontsURL;
		}
		
		public function get soundURL() : String
		{
			return _soundURL;
		}
		
		public function get encodingURL() : String
		{
			return _encodingURL;
		}
		
		public function get reportCardURL() : String
		{
			return _reportCardURL;
		}

		public function get mappingsGetStringUrl() : String
		{
			return _mappingsGetStringUrl;
		}
		
		public function get mappingsSetStringUrl() : String
		{
			return _mappingsSetStringUrl;
		}
		
		public function get leagueIdFake() : String
		{
			return _leagueIdFake;
		}
		public function get leagueIdUseRandom( ) : Boolean 
		{
			var boolean : Boolean = true;
			if( _leagueIdUseRandom != "true" )	boolean = false;
			return boolean;
		}
		public function get leagueIdUseReal( ) : Boolean 
		{
			var boolean : Boolean = true;
			if( _leagueIdUseReal != "true" )	boolean = false;
			return boolean;
		}
		public function get randomLeagueId( ) : String 
		{
			if( !_randomLeagueIdMade )
			{
				_randomLeagueId = String( int( Math.random() * 99999999 ) );
				_randomLeagueIdMade = true
			}
			
//			_randomLeagueId = String( 13207300 );
			
			return _randomLeagueId;
		}

		//
		
		public function get s3AccessKey():String
		{
			return _s3AccessKey;
		}

		public function get s3BucketName():String
		{
			return _s3BucketName;
		}

		public function get environmentType():String
		{
			if (! _environment) return null;
			return _environment.@type;
		}
		
		public function get isEspnEnvironment():Boolean
		{
			var b:Boolean = environmentType.indexOf("espn") > -1; // ie, "espnqa", "espn"... 
			return b;
		}
		
		public function get flashDomId():String
		{
			return _flashDomId;
		}
		
		public function get customServiceUrl():String
		{
			if (! _environment) return null;
			return _environment.@customService;
		}
		
		public function get facebookAppId():String
		{
			if (! _environment) return null;
			return _environment.@fbAppId;
		}
		
		public function get liCustomServicesUrl():String
		{
			if (! _environment) return null;
			return _environment.@liCustomServices;
		}

		public function get facebookSecret():String
		{
			return _facebookSecret;
		}
		
		public function get facebookCallbackUrl():String
		{
			if (! _environment) return null;
			return _environment.@fbCallback;
		}

		public function get enforcerBaseUrlVideos():String
		{
			if (! _environment) return null;
			return _environment.@enforcerBaseUrlVideos;
		}
		
		
		public function get initializeURL():String
		{
			return _initializeURL;
		}
		
		public function get webcamURL():String
		{
			return _webcamURL;
		}
		
		public function get resetURL():String
		{
			return _resetURL;
		}
		
		public function get statusURL():String
		{
			return _statusURL;
		}
		
		public function get photoURL():String
		{
			return _photoURL;
		}
		
		public function get premadeURL():String
		{
			return _premadeURL;
		}
		
		public function get defaultSeason():String
		{
			return _defaultSeason;
		}
		
		public function get apparelURL():String
		{
			return _apparelURL;
		}
		
		public function get isPressPreview():Boolean
		{
			return _isPressPreview;
		}
	}
}

class ConfigModelEnforcer{}
