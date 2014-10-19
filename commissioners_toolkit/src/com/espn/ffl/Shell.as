package com.espn.ffl {
	import com.espn.ffl.apis.http.HusaniRequestor;
	import com.espn.ffl.constants.APIConstants;
	import com.espn.ffl.constants.SiteConstants;
	import com.espn.ffl.model.ConfigModel;
	import com.espn.ffl.model.ContentModel;
	import com.espn.ffl.model.LeagueModel;
	import com.espn.ffl.model.dto.CopyDTO;
	import com.espn.ffl.util.Assets;
	import com.espn.ffl.util.FacebookHelper;
	import com.espn.ffl.util.Metrics;
	import com.espn.ffl.util.Styles;
	import com.espn.ffl.views.Main;
	import com.espn.ffl.views.dialogs.AbstractDialog;
	import com.espn.ffl.views.dialogs.AlertDialogMaker;
	import com.greensock.OverwriteManager;
	import com.greensock.TweenLite;
	import com.greensock.easing.Linear;
	import com.greensock.plugins.AutoAlphaPlugin;
	import com.greensock.plugins.BlurFilterPlugin;
	import com.greensock.plugins.GlowFilterPlugin;
	import com.greensock.plugins.TintPlugin;
	import com.greensock.plugins.TweenPlugin;
	import com.jasontighe.loaders.QueueLoadItem;
	import com.jasontighe.loaders.QueueLoader;
	import com.jasontighe.loaders.events.QueueLoadItemEvent;
	import com.jasontighe.managers.AssetManager;
	import com.jasontighe.managers.FontManager;
	import com.jasontighe.utils.Box;
	import com.jasontighe.utils.RightClickVersion;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.StageAlign;
	import flash.display.StageQuality;
	import flash.display.StageScaleMode;
	import flash.errors.IllegalOperationError;
	import flash.events.Event;
	import flash.external.ExternalInterface;
	import flash.media.Camera;
	import flash.media.Video;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.system.Security;
	import flash.utils.setTimeout;
	
	import leelib.ExtendedEvent;
	import leelib.util.AjaxProxyService;
	import leelib.util.Out;
	import leelib.util.Service;

	/**
	 * @author jsuntai
	 */
	public class Shell
	extends MovieClip 
	{
		//----------------------------------------------------------------------------
		// protected static variables
		//---------------------------------------------------------------------------- 
		protected static var _instance						: Shell;
		//----------------------------------------------------------------------------
		// public static variables
		//---------------------------------------------------------------------------- 
		public static const STAGE_WIDTH						: uint = 990;
		public static const STAGE_HEIGHT					: uint = 1000;
		public static const HEADER_HEIGHT					: uint = 196;
		public static const FOOTER_HEIGHT					: uint = 100;
		//----------------------------------------------------------------------------
		// protected static constants
		//----------------------------------------------------------------------------
		private static const VERSION						: String = "ESPN Fantasy Football: Commissioner's Toolkit: version 1.0.0";
		private static const CONFIG_URL						: String = "flash/xml/config.xml";
		private static const CONTENT_URL					: String = "flash/xml/content.xml";
		private static const HOTSPOT_URL					: String = "flash/xml/hotspots.xml";
//		private static const ENCODING_TEST_URL				: String = "flash/xml/encoding_new_features.xml";
//		private static const ENCODING_TEST_URL				: String = "flash/xml/encoding_test2.xml";
		private static const ASSETS_URL						: String = "flash/swf/Assets.swf";
		private static const ASSETS2_URL					: String = "flash/swf/Assets2.swf";
		private static const FONTS_URL						: String = "flash/swf/Fonts.swf";
		private static const COOKIE_URL						: String = "flash/swf/SharedObjectGateway.swf";
		private static const STYLES_URL						: String = "flash/css/ffl_flash_styles.css";
		private static const SOUNDS_URL						: String = "flash/swf/cp_soundAssets.swf";
		//----------------------------------------------------------------------------
		// private variables
		//----------------------------------------------------------------------------
		private var _flashvars								: Object;
		private var _stageW									: uint;
		private var _stageH									: uint;
		private var _configXML								: XML;
		private var _encodingXML							: XML;
		private var _configModel							: ConfigModel;
		private var _contentModel							: ContentModel;
		private var _queueLoader							: QueueLoader;
		private var _assetManager							: AssetManager;
		private var _fontManager							: FontManager;
		private var _subsLoaded								: Boolean = false;
		private var _espnDataReceived						: Boolean = true; // TODO CHANGE TO FALSE!
		private var _service								: Service;		
		private var _fatalCopyDto							: CopyDTO;
		private var _pinwheel								: Sprite;
		private var _pinwheelInner							: MovieClip;	
		private var _espnRequestCounter						: uint = 0;		
		//----------------------------------------------------------------------------
		// public variables
		//----------------------------------------------------------------------------
		public var video									: Video;
		public var camera									: Camera;
		public var main										: Main;
		public var background								: Box;
		//----------------------------------------------------------------------------
		// constructor
		//----------------------------------------------------------------------------
		public function Shell() 
		{
			if (this.stage) {
				_flashvars = loaderInfo.parameters;
				onAddedToStage();
			}
			else {
				this.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			}
		}
		
		private function onAddedToStage(e:Event=null):void
		{
			trace("\n\n\n\n");
			trace("****************************************");
			trace("*                                      *");
			trace("*           Wieden+Kennedy             *");
			trace("*              New York                *");
			trace("*               © 2012                 *");
			trace("*                                      *");
			trace("****************************************");

			this.removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			
			if( _instance ) throw IllegalOperationError( "Only one instance of Shell can exist." );
			
			_instance = this;
			
			// CROSSDOMAIN SECURITY
			//in order to successfully connect to our policy
			Security.allowDomain("*");
			Security.allowDomain("espn-ffl");
			Security.allowDomain("localhost"); 
			Security.allowDomain("http://ffl.sportsr.us"); 
			Security.allowDomain("http://fflsvcs.dev.nyc.wk.com/"); 
			Security.allowDomain("http://espn-ffl.com"); 
			Security.allowDomain("http://staging.ffl.sportsr.us/"); 
			Security.loadPolicyFile("http://leetest.s3.amazonaws.com/crossdomain.xml" );
			Security.loadPolicyFile('https://fbcdn-profile-a.akamaihd.net/crossdomain.xml'); // for Facebook user icons

			// Out tracer verbosity
			Out.level = Out.SHOW_DEBUG;

			stage.align = StageAlign.TOP_LEFT;
			stage.quality = StageQuality.BEST;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.frameRate = 30;
			
			_flashvars = loaderInfo.parameters;
			
			buttonMode = false;
			mouseEnabled = false;
			useHandCursor = false;
			
			var rcv : RightClickVersion = new RightClickVersion( this, VERSION );
 
			// TWEENMAX STUFF
			OverwriteManager.init();
			TweenPlugin.activate([AutoAlphaPlugin, GlowFilterPlugin, BlurFilterPlugin, TintPlugin ] );
						
			stage.addEventListener(Event.RESIZE, onStageResize);
			stage.stageFocusRect = false;

			// Init startup error copy info (must be hardcoded) 
			_fatalCopyDto = new CopyDTO(<copy name="alertConnectionError" title="" yes="OKAY" no=""><![CDATA[We're sorry, an error occurred.]]></copy>);
			
			init();
		}
		
		public static function get instance():Shell
		{
			return _instance;
		}
		
		public static function get stage():Stage
		{
			return _instance.stage;
		}

		public function set flashVars(o:Object):void
		{
			_flashvars = o;
		}
		
		public function showPinwheel():void
		{
			this.stage.mouseChildren = false; // * take note!
			this.stage.addChild(_pinwheel); // goes to top
			
			TweenLite.killTweensOf(_pinwheel);
			TweenLite.to(_pinwheel, 0.5, { autoAlpha:1 } );
			
			_pinwheelInner.rotation = 0;
			TweenLite.to(_pinwheelInner, 9999, { rotation:9999*360, ease:Linear.easeNone } );
		}
		
		public function hidePinwheel():void
		{
			this.stage.mouseChildren = true;
			
			TweenLite.killTweensOf(_pinwheel);
			TweenLite.to(_pinwheel, 0.2, { alpha:0, onComplete:function():void{_pinwheel.visible=false;} } );
			
			TweenLite.killTweensOf(_pinwheelInner);
		}
		
		//----------------------------------------------------------------------------
		// private methods
		//----------------------------------------------------------------------------
		private function init( e : Event = null ) : void
		{
			trace( "SHELL : init() : THIS IS NEW" );
			removeEventListener(Event.ADDED_TO_STAGE, init );
			_stageW = stage.stageWidth;
			_stageH = stage.stageHeight;
			
			addPinwheel();
			showPinwheel();
			
			loadConfig();
		}
		
		private function addPinwheel():void
		{
			_pinwheel = new Sprite();
			_pinwheelInner = new Assets.Pinwheel();
			_pinwheelInner.scaleX = -1; // hah
			_pinwheel.addChild(_pinwheelInner);
			_pinwheel.x = this.stage.stageWidth * .5;
			_pinwheel.y = this.stage.stageHeight * .5 - 150;
			_pinwheel.alpha = 0;
			_pinwheel.visible = false;
		}

		private function loadConfig( ) : void
		{
			trace( "SHELL : loadConfig()" );
			var loader : URLLoader = new URLLoader();
			var url : String = _flashvars.CONFIG || CONFIG_URL;
			loader.addEventListener( Event.COMPLETE, onConfigLoaded );
			loader.load( new URLRequest( url ) );
		}
		
		private function startQueueLoader() : void
		{
			trace( "SHELL : startQueueLoader()" );
			_queueLoader = new QueueLoader();
			
			var assetsURL : String = _configModel.assetsURL || ASSETS_URL;
			var assetsLoadItem : QueueLoadItem = new QueueLoadItem( assetsURL, onAssetsLoadComplete );
			_queueLoader.add( assetsLoadItem );
			
			var assets2URL : String = _configModel.assets2URL || ASSETS2_URL;
			var assets2LoadItem : QueueLoadItem = new QueueLoadItem( assets2URL, onAssets2LoadComplete );
			_queueLoader.add( assets2LoadItem );
			
			var fontsURL : String = _configModel.fontsURL || FONTS_URL;
			var fontsLoadItem : QueueLoadItem = new QueueLoadItem( fontsURL, onFontsLoadComplete );
			_queueLoader.add( fontsLoadItem );
			
			var stylesURL : String = _configModel.stylesURL || STYLES_URL;
			var stylesLoadItem : QueueLoadItem = new QueueLoadItem( stylesURL, onStylesLoadComplete );
			_queueLoader.add( stylesLoadItem );
			
			var contentURL : String = _configModel.contentURL || CONTENT_URL;
			var contentLoadItem : QueueLoadItem = new QueueLoadItem( contentURL, onContentLoadComplete );
			_queueLoader.add( contentLoadItem );
			
			_queueLoader.setLoadProgressEventHandler( onQueueLoaderProgress );
			_queueLoader.setLoadCompleteEventHandler( onQueueLoaderComplete );
			_queueLoader.load();

		}

		private function addConfigModel( xml : XML ) : void
		{
			trace( "SHELL : addConfigModel()" );
			_configModel = ConfigModel.gi;
			_configModel.addData( xml );
			updateStageSize();
		}
		
		private function updateStageSize() : void
		{
			_configModel.stageW = _stageW;
			_configModel.stageH = _stageH;
		}
		
		private function addContentModel( xml : XML ) : void
		{
			trace( "SHELL : addContentModel()" );
			_contentModel = ContentModel.gi;
			_contentModel.addData( xml );
		}

		protected function addFontManager( mc : MovieClip) : void
		{
			trace("SHELL : addFontManager()" );
			_fontManager = FontManager.gi;
			_fontManager.add( "global", mc );
		}
		
		private function addViews() : void
		{
			addBackground();
			updateBackground();
			addMain();
			onStageResize();
		}
		
		private function addBackground() : void
		{
			trace( "SHELL : addBackground() : _stageH is "+_stageH );
			background = new Box( _stageW, _stageH, _configModel.bgColor );
			addChild( background );
		}
		
		private function addMain() : void
		{
			trace( "SHELL : addMain()" );
			main = new Main();
			main.init();
			addChild( main );
		}
		
		private function updateBackground() : void
		{
			trace( "SHELL : updateBackground() : _stageH is "+_stageH );
			background.width = _stageW;
			background.height = _stageH;
		}
		
		private function initializeDb() : void
		{
			trace( "SHELL : initializeDb()" );
			var _hr : HusaniRequestor = new HusaniRequestor();
			_hr.request( HusaniRequestor.INITIALIZE );
		}
		
		//----------------------------------------------------------------------------
		// event handlers
		//----------------------------------------------------------------------------
		private function onStageResize( e : Event = null ) : void
		{
			trace( "SHELL : onStageResize()" );
			
			_stageW = stage.stageWidth;
			_stageH = stage.stageHeight;

			updateStageSize();
			
			if( background && contains( background ) )	updateBackground();
		}

		private function onConfigLoaded( e : Event ) : void
		{
			trace( "SHELL : onConfigLoaded() : CONFIG XML LOADED" );
			var xml : XML = XML( e.target.data );
			addConfigModel( xml );

			// Init ConfigModel-dependent items here:
			AjaxProxyService.flashId = ConfigModel.gi.flashDomId;
			
			startQueueLoader();
		}
		
		private function onAssetsLoadComplete( e : QueueLoadItemEvent ) : void
		{
			trace( "SHELL : onAssetsLoadComplete() :   **** ASSETS SWF LOADED" );
			_assetManager = AssetManager.gi;
			var assets : MovieClip = MovieClip( e.loadItem.content );
			_assetManager.add( SiteConstants.ASSETS_ID, assets );
		}
		
		private function onAssets2LoadComplete( e : QueueLoadItemEvent ) : void
		{
			trace( "SHELL : onAssets2LoadComplete() :   **** ASSETS2 SWF LOADED" );
			var assets : MovieClip = MovieClip( e.loadItem.content );
			AssetManager.gi.add( SiteConstants.LEE_ASSETS_ID, assets );
		}

		private function onContentLoadComplete( e : QueueLoadItemEvent ) : void
		{
			trace( "SHELL : onContentLoadComplete() :  **** CONTENT XML LOADED" );
			addContentModel( XML( e.loadItem ) );
		}
		
		private function onFontsLoadComplete( e : QueueLoadItemEvent ) : void
		{
			trace( "SHELL : onFontsLoadComplete() :     **** FONTS LOADED");
			addFontManager( e.loadItem.content );
		}
		
		private function onStylesLoadComplete( e : QueueLoadItemEvent ) : void
		{
			trace( "SHELL : onStylesLoadComplete() :      **** CSS LOADED" );
			
			Styles.initWith(e.loadItem as String);
		}
		
		private function onQueueLoaderProgress( e : Event ) : void
		{
//			trace( "SHELL : onQueueLoaderProgress() :  **** LOADING" );
		}
		
		private function onQueueLoaderComplete( e : Event ) : void
		{
			trace( "SHELL : onQueueLoaderComplete() :  **** QUEUE LOADING IS COMPLETED" );
			_subsLoaded = true;
			
			addViews();
			
			if (_configModel.isOnNotLoggedInPage)
			{
				// Stop here.
				Out.i("stop here");
				Metrics.pageView("/notloggedin");
				hidePinwheel();
				return;
			}
			
			showPinwheel();

			// Init view-dependent items here
			FacebookHelper.instance.init(main);
			
			// Now load commissioner service data
			requestLeagueInfo();
		}

		private function requestLeagueInfo():void
		{
			trace("SHELL : requestLeagueInfo()");

			var url:String = ConfigModel.gi.customServiceUrl + "?leagueId=" + LeagueModel.gi.leagueId + "&seasonId=" + LeagueModel.gi.seasonId; 

			// create correct service requestor based on environment (either regular one, or AJAX version)
			if (! ConfigModel.gi.isEspnEnvironment) {
				trace("Shell.requestLeagueInfo() - IS NOT ESPN ENVIRONMENT, USING AJAXPROXYSERVICE FOR DEV");
				_service = AjaxProxyService.instance; 
			}
			else {
				trace("Shell.requestLeagueInfo() - USING REGULAR AS3 SERVICE REQUESTOR");
				_service = new Service();
			}
			_service.addEventListener(Event.COMPLETE, onLeagueInfoComplete);
			_service.request(url);
		}

		private function onLeagueInfoComplete($e:ExtendedEvent):void
		{
			trace("SHELL : onLeagueInfoComplete()");

			_service.removeEventListener(Event.COMPLETE, onLeagueInfoComplete);
			
			if (! $e.object) 
			{
				trace("SHELL : onLeagueInfoComplete() : CASE 1" );
				if( _espnRequestCounter < 3 )
				{
					requestLeagueInfo();
					_espnRequestCounter++
				}
				else
				{
					hidePinwheel();
					main.showDialogWithCopyDto(false, _fatalCopyDto);
				}
				return;
			}
			
			LeagueModel.gi.parseLeagueServiceData($e.object);
			initializeDb();
			
			if (LeagueModel.gi.draftResultsUrl) {
				trace("SHELL : onLeagueInfoComplete() : CASE 2" );
				requestDraftResults();
			}
			else {
				trace("SHELL : onLeagueInfoComplete() : CASE 3" );
				hidePinwheel(); // fail silently. done.
			}
			
//			initializeDb();
			
		}
		
		private function requestDraftResults():void
		{
			trace("SHELL : requestDraftResults()");

			_service.addEventListener(Event.COMPLETE, onDraftResultsComplete);
			_service.request(LeagueModel.gi.draftResultsUrl);
		}
		
		private function onDraftResultsComplete($e:ExtendedEvent):void
		{
			trace("SHELL : onDraftResultsComplete()");

			_service.removeEventListener(Event.COMPLETE, onDraftResultsComplete);
			hidePinwheel();

			Metrics.pageView("home");
			
			if (! $e.object) {
				Out.w("Shell.onDraftResultsComplete()- ERROR");
				main.showDialogWithCopyDtoId(false, "alertConnectionError");
				return;
			}
			
			LeagueModel.gi.parseDraftServiceData($e.object);
			
			FacebookHelper.instance.validateMapTeamIdsAgainstLeagueModel();

			if (! LeagueModel.gi.userProfileId || LeagueModel.gi.userProfileId.length == 0) {
				Main.instance.showNotCommissionerDialog();
			}
			else if (LeagueModel.gi.numTeams > 12) {
				showTooBigDialog();
			}
			else {
				// Done
			}
		}
		
		private function showTooBigDialog():void
		{
			var dto:CopyDTO = ContentModel.gi.getCopyItemByName("alertTooManyTeams");
			var dialog:AbstractDialog = AlertDialogMaker.make(true, dto.title, dto.copy, dto.yesLabel, dto.noLabel, onTooBigDialogButton,null,onTooBigDialogButton, 505);
			dialog.redBackgroundVisible = true;
			Main.instance.showDialog(dialog, -120);
			
			Metrics.pageView("homeTooBigDialog");
		}
		private function onTooBigDialogButton():void
		{
			var url : String = ContentModel.gi.getSectionItemAt(3).url; // 3 - hardcoded
			var urlRequest : URLRequest = new URLRequest( url );
			navigateToURL( urlRequest, "_blank");
			
			Metrics.pageView("homeTooBigDialogGetGearButton");
		}
	}
}
