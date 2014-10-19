package com.espn.ffl.views.inviter {
	import leelib.ExtendedEvent;
	import leelib.util.TextFieldUtil;

	import com.espn.ffl.Shell;
	import com.espn.ffl.apis.http.HusaniRequestor;
	import com.espn.ffl.constants.SiteConstants;
	import com.espn.ffl.model.ConfigModel;
	import com.espn.ffl.model.ContentModel;
	import com.espn.ffl.model.InviterModel;
	import com.espn.ffl.model.PersonalizedModel;
	import com.espn.ffl.model.PremadeModel;
	import com.espn.ffl.model.StateModel;
	import com.espn.ffl.model.dto.CopyDTO;
	import com.espn.ffl.model.dto.SectionDTO;
	import com.espn.ffl.model.events.InviterEvent;
	import com.espn.ffl.util.Metrics;
	import com.espn.ffl.views.AbstractView;
	import com.espn.ffl.views.Main;
	import com.espn.ffl.views.dialogs.AbstractDialog;
	import com.espn.ffl.views.dialogs.AlertDialogMaker;
	import com.espn.ffl.views.inviter.views.InviterTabNavItem;
	import com.espn.ffl.views.inviter.views.WebcamFrame;
	import com.espn.ffl.webcam.WebcamApp;
	import com.espn.ffl.webcam.WebcamDebugger;
	import com.espn.ffl.webcam.events.WebcamEvent;
	import com.jasontighe.containers.events.ContainerEvent;
	import com.jasontighe.managers.AssetManager;
	import com.jasontighe.navigations.INavItem;
	import com.jasontighe.navigations.Nav;

	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.text.TextField;

	/**
	 * @author jason.tighe
	 */
	public class Inviter 
	extends AbstractView 
	{
		//----------------------------------------------------------------------------
		// private variables
		//----------------------------------------------------------------------------
		private static var _instance						: Inviter;
		//----------------------------------------------------------------------------
		// private static const
		//----------------------------------------------------------------------------
		private var HOLDER_X								: uint = 46;
		private var HOLDER_Y								: uint = 174;
		//----------------------------------------------------------------------------
		// private variables
		//----------------------------------------------------------------------------
		private var _im										: InviterModel = InviterModel.gi;
		private var _sm										: StateModel = StateModel.gi;
		private var _cm										: ContentModel = ContentModel.gi;
		private var _cf										: ConfigModel = ConfigModel.gi;
		private var _wd										: WebcamDebugger = WebcamDebugger.gi;
		private var _persModel								: PersonalizedModel = PersonalizedModel.gi;
		private var _preModel								: PremadeModel = PremadeModel.gi;
		private var _currentView							: AbstractView;
		private var _navItems								: Array = new Array();
		private var _navItemsText							: Array = new Array();
		private var _navId									: uint = 0;
		private var _webcamAdded							: Boolean = false;
		private var _frameAdded								: Boolean = false;
		private var _webcamDenied							: Boolean = false;
		private var _isReset								: Boolean = false;
		private var _pinwheel								: Sprite;
		private var _pinwheelInner							: MovieClip;
		//----------------------------------------------------------------------------
		// public variables
		//----------------------------------------------------------------------------
		public var nav										: Nav;
		public var landing									: MovieClip; // TODO Maybe make Landing its own class
		public var personalizedTabText						: TextField;
		public var personalizedTabBg						: MovieClip;
		public var prerecordTabText							: TextField;
		public var prerecordTabBg							: MovieClip;
		public var holder									: MovieClip;
		public var webcamHolder								: MovieClip;
		public var personalized								: Personalized;
		public var premade									: Premade;
		public var preview									: Preview;
		public var webcamApp								: WebcamApp;
		public var frame									: WebcamFrame;
//		public var debugger									: WebcamDebugger;
		//----------------------------------------------------------------------------
		// constructor
		//----------------------------------------------------------------------------
		public function Inviter() 
		{
			trace( "INVITER : Constr" );
			super();
			_instance = this;
		}
		
		//----------------------------------------------------------------------------
		// public methods
		//----------------------------------------------------------------------------
		public function getUserVideoStatus() : void
		{			
			trace( "INVITER : getUserVideoStatus() : STEP 1" );
			var hr : HusaniRequestor = new HusaniRequestor();
			hr.addEventListener( Event.COMPLETE, getUserVideoStatusComplete );
			hr.addEventListener( HusaniRequestor.EVENT_ERROR, husaniGetUserRequestorError );
			hr.addEventListener(IOErrorEvent.IO_ERROR, getUserVideoStatusError);
			hr.request( HusaniRequestor.GET_VIDEO_STATUS );
			Shell.instance.showPinwheel();
		}
		
		// Called on Nav Item Click, and Main.as showView();
		public function resetUserVideoStatus() : void
		{			
			trace( "INVITER : resetUserVideoStatus()" );
			var hr : HusaniRequestor = new HusaniRequestor();
			hr.addEventListener( Event.COMPLETE, resetUserStatusComplete );
			hr.addEventListener(IOErrorEvent.IO_ERROR, resetUserStatusError);
			hr.addEventListener( HusaniRequestor.EVENT_ERROR, husaniResetRequestorError );
			hr.request( HusaniRequestor.RESET );
			_isReset = true;
		}
		
		public function flushCurrentView() : void
		{	
			trace( "\n\n\n\n");
			trace( "INVITER : flushCurrentView() : _im.videoType is "+_im.videoType );
			trace( "INVITER : flushCurrentView() : _currentView is "+_currentView );
			trace( "\n\n\n\n");
			
			if( _im.videoType == InviterModel.VIDEO_TYPE_PERSONALIZED && _currentView == personalized  )
			{
				PersonalizedModel.gi.state = PersonalizedModel.STATE_FLUSH;
				removeWebcamAssets();
			}
			else if( _im.videoType == InviterModel.VIDEO_TYPE_PREMADE && _currentView == premade  )
			{
				PremadeModel.gi.state = PremadeModel.STATE_FLUSH;
			}
			else
			{
//				trace( "INVITER : flushCurrentView() : THIS HAS NOT BEEDN CALLED AND IM MAKING THIS TRACE VERY LONG" );
			}
			
			
		}
		
		public function pauseCreated() : void
		{	
			trace( "\n\n\n\n");
			trace( "INVITER : pauseCreated() : _im.videoType is "+_im.videoType );
			trace( "INVITER : pauseCreated() : _currentView is "+_currentView );
			trace( "\n\n\n\n");
			
			if( _im.videoType == InviterModel.VIDEO_TYPE_PERSONALIZED &&  PersonalizedModel.gi.state == PersonalizedModel.STATE_CREATED ) 
			{
				personalized.pause();
			}
			else if( _im.videoType == InviterModel.VIDEO_TYPE_PREMADE &&  PremadeModel.gi.state == PremadeModel.STATE_CREATED   )
			{
				premade.kill();
			}
			else
			{
//				trace( "INVITER : flushCurrentView() : THIS HAS NOT BEEDN CALLED AND IM MAKING THIS TRACE VERY LONG" );
			}
		}
		
		/******************  Webcam and Frame Calls ************************/
		// Added from InviterPositioner.as constructor
		public function addWebcamApp() : void 
		{ 
			trace( "******************** INVITER : addWebcamApp() : webcamApp is "+webcamApp );

			webcamApp = new WebcamApp();
			webcamApp.init();
			webcamHolder.addChild( webcamApp );
			webcamHolder.alpha = 1;
			addWebcamListeners();
			showWebcam();
			_webcamAdded = true;
			
			trace( "******************** INVITER : addWebcamApp() : webcamHolder.alpha is "+webcamHolder.alpha );
			trace( "******************** INVITER : addWebcamApp() : _webcamAdded is "+_webcamAdded );
		}
		
		public function addWebcamFrame() : void 
		{ 
			var offset : int = 1;
		 	frame = new WebcamFrame();
			frame.init();
			frame.x = webcamHolder.x - offset;
			frame.y = webcamHolder.y - offset;
			addChild( frame );
			_frameAdded = true;
			trace( "******************** INVITER : addWebcamFrame() : _frameAdded is "+_frameAdded );
		}
		
		public function showWebcamSilhouette() : void 
		{ 
			trace( "INVITER : showWebcamSilhouette()" );
			frame.showSilhouette();
		}
		
		public function hideWebcamSilhouette() : void 
		{ 
			trace( "INVITER : hideWebcamSilhouette()" );
			frame.hideSilhouette();
		}
		
		public function addWebcamAssets() : void 
		{ 
			trace( "INVITER : addWebcamAssets()" );
			if( _webcamAdded )	addWebcamApp();
			if( _frameAdded )	addWebcamFrame();
		}
		
		public function removeWebcamAssets() : void 
		{ 
			trace( "\n\n\n\n")
			trace( "******************** INVITER : removeWebcamAssets() : _frameAdded is "+_frameAdded );
			trace( "******************** INVITER : removeWebcamAssets() : _webcamAdded is "+_webcamAdded );
			if( _frameAdded )	removeWebcamFrame();
			if( _webcamAdded )	removeWebcamApp();
			
			
			
			// Reset counts
			_cm.webcamS3URLCount = 0;
			PersonalizedModel.gi.questionCount = 0;
			webcamHolder.alpha = 0;
			
			trace( "******************** INVITER : removeWebcamAssets() : _cm.webcamS3URLCount is "+_cm.webcamS3URLCount );
			trace( "******************** INVITER : removeWebcamAssets() : PersonalizedModel.gi.questionCount is "+PersonalizedModel.gi.questionCount );
			trace( "******************** INVITER : removeWebcamAssets() : webcamHolder.alpha is "+webcamHolder.alpha );
			trace( "\n\n\n\n")
		}
		
		protected function removeWebcamFrame() : void 
		{ 
			trace( "******************** INVITER : removeWebcamFrame() : _webcamAdded is "+_webcamAdded );
			if( _frameAdded )	
			{
				frame.kill();
				removeChild( frame );
				frame = null;
				_frameAdded = false;
			}
		}
		
		protected function removeWebcamApp() : void 
		{ 
			trace( "******************** INVITER : removeWebcamApp()" );
			if( webcamHolder.contains( webcamApp ))	
			{
				webcamHolder.removeChild( webcamApp );
				webcamApp.kill();
				webcamApp = null;
				_webcamAdded = false;
			}
		}
		
		public function hideWebcam() : void 
		{ 
			trace( "******************** INVITER : hideWebcam()" );
			if( _webcamAdded )	webcamApp.visible = false;
		}
		
		public function showWebcam() : void 
		{ 
			trace( "******************** INVITER : showWebcam() : _webcamAdded is "+_webcamAdded );
			if( _webcamAdded )	webcamApp.visible = true;
		}
		/******************************************************************/
		
		//----------------------------------------------------------------------------
		// protected methods
		//----------------------------------------------------------------------------
		/******************  Add Views Calls *******************************/
		protected override function addViews() : void 
		{ 
			trace( "INVITER : addViews()" );
			addInviterModel();
			addBackground();
			addHolder();
			
			_navItems = [ personalizedTabBg, prerecordTabBg ];
			personalizedTabText = TextFieldUtil.makeTextWithCopyDto( _cm.getCopyItemByName("liTabPersonalized"));
			addChild( personalizedTabText );
			prerecordTabText = TextFieldUtil.makeTextWithCopyDto( _cm.getCopyItemByName("liTabPremade"));
			addChild( prerecordTabText );
			_navItemsText = [ personalizedTabText, prerecordTabText ];
			addNav();
		}
		
		protected function addInviterModel() : void
		{
			trace( "INVITER : addInviterModel()" );
			_im = InviterModel.gi;
			_im.addEventListener( InviterEvent.PERSONALIZED, onStateChange );
			_im.addEventListener( InviterEvent.PREMADE, onStateChange );
			_im.addEventListener( InviterEvent.PREVIEW, onStateChange );
			_im.addEventListener( InviterEvent.RESET, onStateChange );
		}
		protected function addBackground() : void 
		{ 
			trace( "INVITER : addBackground" );
			background = MovieClip( AssetManager.gi.getAsset( "InviterAsset", SiteConstants.ASSETS_ID ) );
			addChild( background );
			
			var wallpaper : MovieClip = background.wallpaper;
			
			personalizedTabBg = background.personalizedTabBg;
			prerecordTabBg = background.prerecordTabBg;
			webcamHolder = background.webcamHolder;
			webcamHolder.alpha = 0;
		}
		protected function addHolder() : void 
		{ 
			holder = new MovieClip();
			holder.x = HOLDER_X;
			holder.y = HOLDER_Y;
			addChild( holder );
		}	
		/******************************************************************/
		
		/****************** Show View calls *******************************/
		protected function addPersonalized() : void 
		{ 
			trace( "INVITER : addPersonalized()" );
			if( !personalized )
			{	
				personalized = new Personalized();
				personalized.init();
			}
			personalized.showDefaultView();
			holder.addChild( personalized );
			
			_currentView = personalized;
		}
		
		protected function addPremade() : void 
		{ 
			trace( "INVITER : addPremade()" );
			if( !premade )
			{	
				premade = new Premade();
				premade.init();
			}
			premade.showDefaultView();
			holder.addChild( premade );
			
			_currentView = premade;
		}
		
		protected function addPreview() : void 
		{ 
			trace( "INVITER : addPreview()" );
			if( !preview )
			{	
				preview = new Preview();
				preview.init();
			}
			holder.addChild( preview );
			
			_currentView = preview;
		}
		/******************************************************************/
		
		/****************** Nav calls *************************************/
		private function addNav(  ) : void
		{
			trace( "INVITER : addNav()" );
			nav = new Nav();
			
			var dto : SectionDTO;
			var item : InviterTabNavItem;
			var last : InviterTabNavItem;
			var i : uint = 0;
			var I : uint = _navItems.length;
			var lastItem : uint = I - 1;
			
			for( i; i < I; i++)
			{	
				item = new InviterTabNavItem();
				var mc : MovieClip = _navItems[ i ];
				item.mc = mc;
				var txt : TextField = _navItemsText[ i ];
				item.txt = txt;
				item.addChild( mc );
				item.setIndex( i );
				
				item.setOutState();
				item.setOutEventHandler( onNavItemOut );
				item.setOverEventHandler( onNavItemOver );
				item.setClickEventHandler( onNavItemClick );
				
				nav.add( item );
				nav.addChild( item );
			}
			
			nav.init();
			deactivateNav();
			addChild( nav );
		}
		
		public function activateNav( ) : void 
		{ 
			trace( "\n\nINVITER : activateNav() \n\n" );
			nav.enable();
		}
		
		public function deactivateNav( ) : void 
		{ 
			trace( "\n\nINVITER : deactivateNav() \n\n" );
//			nav.reset();
			nav.disable();
		}
		
		public function deactivateActiveNavItem( ) : void 
		{ 
			trace( "\n\nINVITER : deactivateActiveNavItem() \n\n" );
			var iNavItem : INavItem = nav.getItemAt( _navId );
			iNavItem.setActiveState();
			
//			var iNavItem : INavItem;
//			for( var i : uint = 0; i < nav.length; i++ )
//			{
//				iNavItem = nav.getItemAt( i );
//				if( i == _navId )	iNavItem.setInactiveState();
//			 	
//			}
		}
		
		protected function updateNav( id : uint ) : void 
		{ 
			trace( "\n\nINVITER : updateNav() is is "+id );
			nav.setActiveIndex( id );
			var iNavItem : INavItem = nav.getItemAt( id );
			iNavItem.setActiveState();
		}
		/******************************************************************/
		
		/****************** View Transitions ******************************/
		protected function hideView() : void 
		{ 
			trace( "\n*******************************************" );
			trace( "INVITER : hideView() : _currentView is "+_currentView );
			trace( "INVITER : hideView() : _im.state is "+_im.state );
			if( _im.state == InviterModel.STATE_PERSONALIZED )
			{
				trace( "INVITER : hideView() : _im.state is "+ _im.state + " #	#	#	#	#	#	#	#	: FLUSH CALLED" );
				_preModel.state = PremadeModel.STATE_FLUSH;
			}
			else if( _im.state == InviterModel.STATE_PREMADE )
			{
				trace( "INVITER : hideView() : _im.state is "+ _im.state + " #	#	#	#	#	#	#	#	: FLUSH CALLED" );
				_persModel.state = PremadeModel.STATE_FLUSH;
			}
			
			if (personalized && personalized.question) personalized.question.clearTimeouts();
			
			_currentView.addEventListener( ContainerEvent.HIDE, hideViewComplete );
			_currentView.hide( SiteConstants.TIME_TRANSITION_OUT );
		}
		
		public override function hide(duration:Number=0, delay:Number=0):void
		{
			trace('Inviter.hide()');
			
			super.hide(duration,delay);

			if (webcamApp) webcamApp.detachCamera();
			if (personalized && personalized.question) personalized.question.clearTimeouts();
		}

		protected function hideViewComplete( e : ContainerEvent ) : void 
		{ 
			trace( "INVITER : hideViewComplete()" );
			_currentView.addEventListener( ContainerEvent.HIDE, hideViewComplete );
			removeChildrenFromHolder();
			showView();
		}
		
		public override function show(duration:Number=0, delay:Number=0):void
		{
			super.show(duration,delay);
			
			Metrics.pageView("inviter");
		}
		
		protected function showView( ) : void 
		{ 
			trace( "\n*******************************************" );
			trace( "INVITER : showView() : STEP 5 : : _im.status is "+_im.status );
			trace( "INVITER : showView() : STEP 5 : : _im.state is "+_im.state );
			var state : String = _im.state;
			
			switch( state )
			{
				case InviterModel.STATE_PERSONALIZED:
					// THIS MAY NEED OT CHANGE BASED ON WEBCAM VIEW, BUT HOPEFULLY NOT
//					if( _im.status != InviterModel.STATUS_CREATED )   addWebcamAssets();
					addPersonalized();
					Metrics.pageView("inviterCustomize");
					break;
				case InviterModel.STATE_PREMADE:
					addPremade();
					removeWebcamAssets();
					break;
				case InviterModel.STATE_PREVIEW:
					addPreview();
					removeWebcamAssets();
					break;
				case InviterModel.STATE_RESET:
					resetUserVideoStatus();
					break;
			}
			
			_currentView.addEventListener( ContainerEvent.SHOW, showViewComplete );
			_currentView.show( SiteConstants.TIME_TRANSITION_IN );
			_im.previousState = state;
		}
		
		protected function showViewComplete( e : ContainerEvent ) : void 
		{ 
			trace( "INVITER : showViewComplete()" );
			trace( "INVITER : showViewComplete() :_im.status is "+_im.status );
			trace( "INVITER : showViewComplete() :_im.webcamDenied is "+_im.webcamDenied );
			_currentView.removeEventListener( ContainerEvent.SHOW, showViewComplete );
			if( _im.status != InviterModel.STATUS_CREATED )
			{
				if( _im.webcamDenied == false )
				{
					trace( "INVITER : showViewComplete() : _navId is "+_navId );
					nav.enable();
					updateNav( _navId );
				}
			}
		}
		
		protected function removeChildrenFromHolder( ) : void 
		{ 
			trace( "INVITER : removeChildrenFromHolder()" );
			for ( var i:uint = 0; i < holder.numChildren; i++)
			{
				var object : * = holder.getChildAt(i);
				holder.removeChildAt(i);
			}
		}
		/******************************************************************/
		
		
		/****************** Getting Video Status, Setting State ***********/
		// Separated from State because some statuses wont change Inviter State
		protected function updateVideoStatus( status : String ) : void
		{
			// THIS IS GETTING THE VIDEO STATUS OF THE USER
			trace( "INVITER : updateVideoStatus() : STEP 2 : status is "+status );
			trace( "INVITER : updateVideoStatus() : STEP 2 : _im.videoType is "+_im.videoType );
			trace( "INVITER : updateVideoStatus() : STEP 2 : _im.state is "+_im.state );
			
//			var navId : uint;
			if( _im.videoType == InviterModel.VIDEO_TYPE_PERSONALIZED )	_navId = 0;
			if( _im.videoType == InviterModel.VIDEO_TYPE_PREMADE )		_navId = 1;
			// For testing "error" for Press Release
			if( _cf.isPressPreview )
			{
				if( status == InviterModel.STATUS_CREATED )	status = InviterModel.STATUS_DELETED;
			}
			
			trace( "INVITER : updateVideoStatus() : SWITCH : status is "+status );
			
			switch ( status )
			{
				// Active Nav Here
				case InviterModel.STATUS_NEW:
					if( _im.webcamDenied == false )	activateNav();
					_im.videoWaitingForCreation = false;
					updateState( _navId );
//					updateNav( _navId );
					break;
					
				// Deactive Nav Here
				case InviterModel.STATUS_ERROR:
					trace( "INVITER : updateVideoStatus() : CASE ERROR : status is "+status );
					trace( "INVITER : updateVideoStatus() : CASE ERROR : InviterModel.STATUS_ERROR is "+InviterModel.STATUS_ERROR );
					showHRErrorAlert();
					break;
					
				// Deactive Nav Here
				case InviterModel.STATUS_WAITING:
				
					showWaitingAlert();
					deactivateNav();
					break;
					
				// Deactive Nav Here
				case InviterModel.STATUS_CREATED:
				
					updateState( _navId );
					deactivateNav();
					break;
					
				// Deactive Nav Here
				case InviterModel.STATUS_DELETED:
				
					showVideoDeletedAlert();
					break;
			}
		}
		
		protected function updateState( navId : uint ) : void
		{
			trace( "INVITER : updateState() : STEP 3 : navId is "+navId );
			switch ( navId )
			{
				case 0:
					_im.state = InviterModel.STATE_PERSONALIZED;	
					break;
					
				case 1:
					_im.state = InviterModel.STATE_PREMADE;	
					break;
			}
		}
		
		protected function updateVideoType( navId : uint ) : void
		{
			if( navId == 0 )
			{
				_im.videoType = InviterModel.VIDEO_TYPE_PERSONALIZED;
			}
			else
			{
				_im.videoType = InviterModel.VIDEO_TYPE_PREMADE
			}
		}
		/******************************************************************/
		
		/****************** Alerts ****************************************/
		// Webcam Denied Alerts
		private function showWebcamDeniedAlert() : void
		{
			trace( "******************** INVITER : showWebcamDenied()" );
			var dto : CopyDTO = ContentModel.gi.getCopyItemByName( "alertWebcamDenied" );
			var _confirmationDialog : AbstractDialog = AlertDialogMaker.make( true, dto.title, dto.copy, dto.yesLabel, dto.noLabel, onWebcamDeniedYes, null, onWebcamDeniedYes, 505 );
			Main.instance.showDialog(_confirmationDialog);
		}
		
		private function onWebcamDeniedYes():void
		{
			trace( "******************** INVITER : addWebcamListeners()" );

			_navId = 1;
			doNavItemClick();
			_im.webcamDenied = true;
			
			_persModel.state = PersonalizedModel.STATE_FLUSH;
			_im.state = InviterModel.STATE_PREMADE;
			
			Main.instance.hideDialog();
		}
		
		// No Camera Alert
		public function showNoCameraAlert() : void
		{
			trace( "******************** INVITER : showNoCameraAlert()" );
			var dto : CopyDTO = ContentModel.gi.getCopyItemByName( "alertNoCamera" );
			var _confirmationDialog : AbstractDialog = AlertDialogMaker.make( false, dto.title, dto.copy, dto.yesLabel, dto.noLabel, showNoCameraYes, showNoCameraNo, showNoCameraNo, 605 );
			Main.instance.showDialog(_confirmationDialog);
		}
		
		private function showNoCameraYes():void
		{
			trace( "******************** INVITER : showNoCameraYes()" );
			Main.instance.hideDialog();
			webcamApp.init();
		}
		
		private function showNoCameraNo():void
		{
			trace( "******************** INVITER : showNoCameraNo()" );
			_navId = 1;
			doNavItemClick();
			_im.webcamDenied = true;
			
			_persModel.state = PersonalizedModel.STATE_FLUSH;
			_im.state = InviterModel.STATE_PREMADE;
			
			Main.instance.hideDialog();
		}
		
		// No Microphone Alert
		public function showNoMicAlert() : void
		{
			trace( "******************** INVITER : showNoMicAlert()" );
			var dto : CopyDTO = ContentModel.gi.getCopyItemByName( "alertNoMic" );
			var _confirmationDialog : AbstractDialog = AlertDialogMaker.make( false, dto.title, dto.copy, dto.yesLabel, dto.noLabel, showNoMicYes, showNoMicNo, null, 605 );
			Main.instance.showDialog(_confirmationDialog);
		}
		
		private function showNoMicYes():void
		{
			trace( "******************** INVITER : showNoMicYes()" );
			Main.instance.hideDialog();
			webcamApp.init();
		}
		
		private function showNoMicNo():void
		{
			trace( "******************** INVITER : showNoMicNo()" );
			_navId = 1;
			doNavItemClick();
			_im.webcamDenied = true;
			
			_persModel.state = PersonalizedModel.STATE_FLUSH;
			_im.state = InviterModel.STATE_PREMADE;
			
			Main.instance.hideDialog();
		}
		
		// Waiting Alerts
		public function showWaitingAlert() : void
		{
			trace( "INVITER : showWaitingAlert()" );
			var dto : CopyDTO = ContentModel.gi.getCopyItemByName( "alertVideoWaiting" );
			var _confirmationDialog : AbstractDialog = AlertDialogMaker.make( false, dto.title, dto.copy, dto.yesLabel, dto.noLabel, showWaitingYes, null, showWaitingYes, 505 );
			Main.instance.showDialog(_confirmationDialog);
			
		}
		private function showWaitingYes():void
		{
			Metrics.pageView("inviterCustomizeBackToToolkitButton");
			Main.instance.hideDialog();
			sendToTouts();
		}
				
		// Video Deleted Alerts
		public function showVideoDeletedAlert() : void
		{
			trace( "INVITER : showWebcamDenied()" );
			var dto : CopyDTO;
			var _confirmationDialog : AbstractDialog;
			if( _cf.isPressPreview)
			{	
				dto = ContentModel.gi.getCopyItemByName( "alertVideoDeletedPress" );
				_confirmationDialog = AlertDialogMaker.make( false, dto.title, dto.copy, dto.yesLabel, dto.noLabel, showVideoDeletedNo, null, null, 505 );
			}
			else
			{
				dto = ContentModel.gi.getCopyItemByName( "alertVideoDeleted" );
				_confirmationDialog = AlertDialogMaker.make( true, dto.title, dto.copy, dto.yesLabel, dto.noLabel, showVideoDeletedYes, null, showVideoDeletedNo, 505 );
			}
			Main.instance.showDialog(_confirmationDialog);
		}
		
		private function showVideoDeletedYes():void
		{
			trace( "INVITER : addWebcamListeners()" );
			// UPDATE TO STATE depending on video
			resetUserVideoStatus();
		    Main.instance.hideDialog();
		}
		private function showVideoDeletedNo():void
		{
			trace( "INVITER : showVideoDeletedNo()" );
		    Main.instance.hideDialog();
			sendToTouts();
		}	
				
		// HR Error Alerts
		public function showHRErrorAlert() : void
		{
			trace( "INVITER : showWebcamDenied()" );
			var dto : CopyDTO = ContentModel.gi.getCopyItemByName( "alertHRError" );
			var _confirmationDialog : AbstractDialog = AlertDialogMaker.make( false, dto.title, dto.copy, dto.yesLabel, dto.noLabel, showHRErrorYes, showHRErrorNo, showHRErrorNo, 505 );
			Main.instance.showDialog(_confirmationDialog);
		}
		
		private function showHRErrorYes():void
		{
			trace( "INVITER : sshowHRErrorYes()" );
			// UPDATE TO STATE depending on video
			resetUserVideoStatus();
		    Main.instance.hideDialog();
		}
		private function showHRErrorNo():void
		{
			trace( "INVITER : showHRErrorNo()" );
		    Main.instance.hideDialog();
			sendToTouts();
		}
		
		// Husani Database call error
		private function showHusaniErrorAlert() : void
		{
			trace( "******************** INVITER : showWebcamDenied()" );
			var dto : CopyDTO = ContentModel.gi.getCopyItemByName( "alertConnectionError" );
			var _confirmationDialog : AbstractDialog = AlertDialogMaker.make( true, dto.title, dto.copy, dto.yesLabel, dto.noLabel, HusaniErrorYes, null, HusaniErrorYes, 505 );
			Main.instance.showDialog(_confirmationDialog);
		}
		
		private function HusaniErrorYes():void
		{
			trace( "******************** INVITER : addWebcamListeners()" );
			sendToTouts();
		    Main.instance.hideDialog();
		}
		
		private function sendToTouts():void
		{
			StateModel.gi.state = StateModel.STATE_TOUTS;
		}
		/******************************************************************/
		
		/****************** Webcam Listeners ******************************/
		protected function addWebcamListeners( ) : void
		{
			trace( "******************** INVITER : addWebcamListeners()" );
			webcamApp.addEventListener( WebcamEvent.WEBCAM_ACCPEPTED, onWebcamAccepted );
			webcamApp.addEventListener( WebcamEvent.WEBCAM_DENIED, onWebcamDenied );
			webcamApp.addEventListener( WebcamEvent.WEBCAM_ACTIVE, onWebcamActive );
			webcamApp.addEventListener( WebcamEvent.WEBCAM_INACTIVE, onWebcamInactive );
		}
		
		protected function removeWebcamListeners( ) : void
		{
			trace( "******************** INVITER : removeWebcamListeners()" );
			webcamApp.removeEventListener( WebcamEvent.WEBCAM_ACCPEPTED, onWebcamAccepted );
			webcamApp.removeEventListener( WebcamEvent.WEBCAM_DENIED, onWebcamDenied );
			webcamApp.removeEventListener( WebcamEvent.WEBCAM_ACTIVE, onWebcamActive );
			webcamApp.removeEventListener( WebcamEvent.WEBCAM_INACTIVE, onWebcamInactive );
		}
		/******************************************************************/
		
		//----------------------------------------------------------------------------
		// event handlers
		//----------------------------------------------------------------------------
		/****************** State Change Handlers for InviterModel *******/
		protected function onStateChange( e : InviterEvent ) : void
		{	
			trace( "INVITER : onStateChange() : STEP 4" );
			var state : String = e.type;
			var previousState : String = _im.previousState;
			trace( "INVITER : onStateChange() : state is "+state );
			trace( "INVITER : onStateChange() : previousState is "+previousState );
			
			if( previousState == null )
			{
				trace( "INVITER : onStateChange() : STEP 4 : The previous state is null" );
				showView();
				updateNav( _navId );
			}
			else
			{
				hideView();
			}
		}		
		/******************************************************************/
		
		/****************** Video Status Handlers *************************/
		private function getUserVideoStatusComplete( e : Event ) : void
		{
			trace( "INVITER : getUserVideoStatusComplete() : STEP 1 : e is "+e ); 
			var hr : HusaniRequestor = e.target as HusaniRequestor;
			hr.removeEventListener( Event.COMPLETE, getUserVideoStatusComplete );
			hr.removeEventListener(IOErrorEvent.IO_ERROR, getUserVideoStatusError);
			
			var status : String = _im.status;
			var videoType : String = _im.videoType;
			trace( "\n" );
			trace( "*************************************************" );
			trace( "INVITER : getUserVideoStatusComplete() : status is "+status ); 	
			trace( "INVITER : getUserVideoStatusComplete() : videoType is "+videoType ); 
			trace( "*************************************************" );
			trace( "\n" );
			
			Shell.instance.hidePinwheel();
			updateVideoStatus( status ); 
		}
		private function getUserVideoStatusError( e : IOErrorEvent ) : void
		{
			trace( "INVITER : getUserVideoStatusComplete() : e is "+e );
			var hr : HusaniRequestor = e.target as HusaniRequestor;
			hr.removeEventListener( Event.COMPLETE, getUserVideoStatusComplete );
			hr.removeEventListener(IOErrorEvent.IO_ERROR, getUserVideoStatusError);
			
			Shell.instance.hidePinwheel();
			showHusaniErrorAlert();
		}
		private function husaniGetUserRequestorError( e : ExtendedEvent = null ) : void
		{
			var hr : HusaniRequestor = e.target as HusaniRequestor;
			hr.removeEventListener( Event.COMPLETE, getUserVideoStatusComplete );
			hr.removeEventListener(IOErrorEvent.IO_ERROR, resetUserStatusError);
			hr.addEventListener( HusaniRequestor.EVENT_ERROR, husaniGetUserRequestorError );
			
			Shell.instance.hidePinwheel();
			showHusaniErrorAlert();
		}
		
		
		// THIS WILL UPDATE STATE
		private function resetUserStatusComplete( e : Event ) : void
		{
			trace( "INVITER : resetUserStatusComplete() : e is "+e ); 
			var hr : HusaniRequestor = e.target as HusaniRequestor;
			hr.removeEventListener( Event.COMPLETE, getUserVideoStatusComplete );
			hr.removeEventListener(IOErrorEvent.IO_ERROR, resetUserStatusError);
			
			if( !_isReset )
			{
//			if( _sm.state == StateModel.STATE_INVITER )
//			{
				updateState( _navId );
				dispatchCompleteEvent();
//			}
			}

			Shell.instance.hidePinwheel();
			_isReset = false;
		}
		private function resetUserStatusError( e : IOErrorEvent ) : void
		{
			var hr : HusaniRequestor = e.target as HusaniRequestor;
			hr.removeEventListener( Event.COMPLETE, getUserVideoStatusComplete );
			hr.removeEventListener(IOErrorEvent.IO_ERROR, resetUserStatusError);
			hr.addEventListener( HusaniRequestor.EVENT_ERROR, husaniGetUserRequestorError );
			
			Shell.instance.hidePinwheel();
			showHusaniErrorAlert();
		}
		private function husaniResetRequestorError( e : ExtendedEvent = null ) : void
		{
			trace( "INVITER : resetUserStatusError() : e is "+e ); 
			var hr : HusaniRequestor = e.target as HusaniRequestor;
			hr.removeEventListener( Event.COMPLETE, getUserVideoStatusComplete );
			hr.removeEventListener(IOErrorEvent.IO_ERROR, resetUserStatusError);
			hr.addEventListener( HusaniRequestor.EVENT_ERROR, husaniResetRequestorError );
			
			Shell.instance.hidePinwheel();
			showHusaniErrorAlert();
		}
		/******************************************************************/
	
		/****************** Webcam Handlers *******************************/
		protected function onWebcamAccepted( e : WebcamEvent ) : void
		{
			trace( "INVITER : onWebcamAccepted() : WEBCAM ACCEPTED" );
			_im.hasVerifiedWebcam = true;
//			checkMicrophone();
		}
	
		protected function onWebcamDenied( e : WebcamEvent ) : void
		{
			trace( "******************** INVITER : onWebcamDenied() : WEBCAM DENIED" );
			_webcamDenied = true;
			showWebcamDeniedAlert();
		}
	
		protected function onWebcamActive( e : WebcamEvent ) : void
		{
			trace( "******************** INVITER : onWebcamActive() : WEBCAM ACTIVE" );
		}
	
		protected function onWebcamInactive( e : WebcamEvent ) : void
		{
			trace( "******************** INVITER : onWebcamInactive() : WEBCAM INACTIVE" );
		}
		/******************************************************************/
		protected function onNavItemOut( e : Event ) : void
		{
			var item : InviterTabNavItem = e.target as InviterTabNavItem; 
			item.setOutState();
		}
		
		protected function onNavItemOver( e : Event ) : void
		{
			var item : InviterTabNavItem = e.target as InviterTabNavItem; 
			item.setOverState();
		}
		
		protected function onNavItemClick( e : Event ) : void
		{
			var item : InviterTabNavItem = e.target as InviterTabNavItem; 
			_navId = item.getIndex();
			
			
			trace( "INVITER : onNavItemClick() : _currentView is "+_currentView );
			trace( "INVITER : onNavItemClick() : _im.interviewStarted is "+_im.interviewStarted );
			if( _currentView == personalized && _im.interviewStarted )
			{
				showInviterAlert();
			}
			else
			{
				doNavItemClick();
			}
			// TODO MOVING TO RESET COMPLETE
//			updateState( _navId );
//			dispatchCompleteEvent();
		}
		
		protected function showInviterAlert() : void
		{
			trace( "INVITER : showWebcamDenied()" );
			var dto : CopyDTO = ContentModel.gi.getCopyItemByName( "alertDeleteVideo" );
			var _confirmationDialog : AbstractDialog = AlertDialogMaker.make( true, dto.title, dto.copy, dto.yesLabel, dto.noLabel, onInviterAlertYes, null, onInviterAlertNo, 505 );
			Main.instance.showDialog(_confirmationDialog);
		}
		
		private function onInviterAlertYes():void
		{
			// HAPPENS WHEN "MAKE PREMADE VIDEO" BUTTON IN ALERT
			// DO FLUSH
			trace( "INVITER : onInviterAlertYes()" );
			flushCurrentView();
			doNavItemClick();
		    Main.instance.hideDialog();
		}
		private function onInviterAlertNo():void
		{
			// NOT USED
			// HAPPENS WHEN "TRY AGAIN" BUTTON IN ALERT
			trace( "INVITER : onInviterAlertNo()" );
		    Main.instance.hideDialog();
		}	
		
		protected function doNavItemClick( ) : void
		{
//			updateNav( _navId );
			trace("INVITER : doNavItemClick() : _navId is "+_navId );
			
			updateVideoType( _navId );
			resetUserVideoStatus();
			// disables nav and resets
			deactivateNav();
			deactivateActiveNavItem();
		}
		
		// Lo-rent Singleton
		public static function get instance():Inviter
		{
			return _instance;
		}
		 
		//----------------------------------------------------------------------------
		// getter/setters
		//----------------------------------------------------------------------------
		public function getFrame() : WebcamFrame
		{
			return frame;
		}
		public function getWebcamApp() : WebcamApp
		{
			return webcamApp;
		}
	}
}
