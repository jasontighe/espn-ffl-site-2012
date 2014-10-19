package com.espn.ffl.views {
	import com.espn.ffl.Shell;
	import com.espn.ffl.constants.SiteConstants;
	import com.espn.ffl.image_uploader.DialogUploadPhoto;
	import com.espn.ffl.model.ConfigModel;
	import com.espn.ffl.model.ContentModel;
	import com.espn.ffl.model.LeagueModel;
	import com.espn.ffl.model.StateModel;
	import com.espn.ffl.model.dto.CopyDTO;
	import com.espn.ffl.model.events.StateEvent;
	import com.espn.ffl.util.FacebookHelper;
	import com.espn.ffl.util.FflS3Uploader;
	import com.espn.ffl.util.Metrics;
	import com.espn.ffl.views.apparel.Apparel;
	import com.espn.ffl.views.dialogs.AbstractDialog;
	import com.espn.ffl.views.dialogs.AlertDialogMaker;
	import com.espn.ffl.views.dialogs.NotLoggedInDialog;
	import com.espn.ffl.views.enforcer.Enforcer;
	import com.espn.ffl.views.header.Header;
	import com.espn.ffl.views.inviter.Inviter;
	import com.espn.ffl.views.report_card.ReportCard;
	import com.espn.ffl.views.touts.Touts;
	import com.greensock.TweenLite;
	import com.jasontighe.containers.events.ContainerEvent;
	import com.jasontighe.utils.Box;
	
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.net.FileReference;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.utils.ByteArray;
	import flash.utils.setTimeout;
	
	import leelib.ExtendedEvent;
	import leelib.appropriated.JPEGEncoder;
	import leelib.facebook.FbUtilWeb;
	import leelib.graphics.GrUtil;
	import leelib.util.Out;
	import leelib.util.s3Util.S3PostRequest;
	import leelib.util.s3Util.S3Util;

	/**
	 * @author jason.tighe
	 */
	public class Main 
	extends AbstractView 
	{
		//----------------------------------------------------------------------------
		// public static const
		//----------------------------------------------------------------------------
		public static const BG_COLOR						: uint = 0xDCDCDC;
		public static const VIEWS_X							: uint = 10;
		public static const VIEWS_Y							: uint = 60;
		public static const HEADER_X						: uint = 10;
		public static const HEADER_Y						: uint = 10;
		public static const HOLDER_X						: uint = 10;
		public static const HOLDER_Y						: uint = 219;
		public static const LOGO_X							: uint = 4;
		public static const LOGO_Y							: uint = 4;
		public static const LOGO_WIDTH						: uint = 100;
		public static const LOGO_HEIGHT						: uint = 25;
		public static const QUICKNAV_PADDING				: int = 10;
		//----------------------------------------------------------------------------
		// private static variables
		//----------------------------------------------------------------------------
		private static var _instance						: Main;
		//----------------------------------------------------------------------------
		// private variables
		//----------------------------------------------------------------------------
		private var _stateModel								: StateModel;
		private var _currentView							: AbstractView;
		private var _notLoggedInDialog					: AbstractDialog
		//----------------------------------------------------------------------------
		// public variables
		//----------------------------------------------------------------------------
		public var touts									: Touts;
		public var header									: Header;
		public var holder									: MovieClip;
		public var inviter									: Inviter;
		public var enforcer									: Enforcer;
		public var reportCard								: ReportCard;
		public var apparel									: Apparel;
		public var box										: Box;
		public var dimmer									: Sprite;
		public var dialogHolder								: Sprite;
		//----------------------------------------------------------------------------
		// constructor
		//----------------------------------------------------------------------------
		public function Main() 
		{
			trace( "MAIN : Constr" );
			super();
			_instance = this;
		}
		
		//----------------------------------------------------------------------------
		// public methods
		//----------------------------------------------------------------------------
		public override function init() : void 
		{ 
			trace( "MAIN : init()" );
			initState();
			addStateModel();
			addViews();		
		}
		
		public override function transitionIn() : void { }
		public override function transitionOut() : void { }
		
		public function updateQuickNav( i : uint ) : void
		{
			header.updateQuickNav( i );
		}
		
		//----------------------------------------------------------------------------
		// protected methods
		//----------------------------------------------------------------------------
//		protected override function transitionInComplete() : void { }
//		protected override function transitionOutComplete() : void { }
		
		protected override function addViews() : void 
		{ 
			trace( "MAIN : addViews()" );
			addStateModel();
			addBackgroundBox();
			addHeader();
			addHolder();
			addDimmer();
			addDialogHolder();
			show();
			StateModel.gi.state = StateModel.STATE_TOUTS;	
			
			header.settingsButton.addEventListener(Event.SELECT, onHeaderConnectButton);
			header.facebookBtn.addEventListener(Event.SELECT, onHeaderFacebookButtonSelect);
			header.twitterBtn.addEventListener(Event.SELECT, onHeaderTwitterButtonSelect);

			// TEST CODE
			/*
			var s:Sprite = GrUtil.makeRect(30,30);
			s.x = 0;
			s.y = 0;
			this.addChild(s);
			s.addEventListener(MouseEvent.CLICK, testS3Upload);
			*/
			
			// TEST CODE 2
			/*
			var dup:DialogUploadPhoto = new DialogUploadPhoto("", 300,100);
			dup.x = 400; dup.y = 400;
			this.addChild(dup);
			*/
		}	

		//----------------------------------------------------------------------------
		// private methods
		//----------------------------------------------------------------------------
		protected function addStateModel() : void
		{
			_stateModel = StateModel.gi;
			_stateModel.addEventListener( StateEvent.TOUTS, onStateChange );
			_stateModel.addEventListener( StateEvent.INVITER, onStateChange );
			_stateModel.addEventListener( StateEvent.ENFORCER, onStateChange );
			_stateModel.addEventListener( StateEvent.REPORT_CARD, onStateChange );
			_stateModel.addEventListener( StateEvent.APPAREL, onStateChange );
		}
		
		protected function addBackgroundBox() : void 
		{ 
			trace( "MAIN : addBackgroundBox()" );
			box = new Box( ConfigModel.gi.stageW, ConfigModel.gi.stageH, ConfigModel.gi.bgColor );
			addChild( box );
		}
		
		protected function addHeader() : void 
		{ 
			trace( "MAIN : addHeader()" );
			header = new Header();
			header.x = HEADER_X;
			header.y = HEADER_Y;
			header.init();
			addChild( header );
		}
		
		protected function addDimmer():void
		{
			// if we use this one, let's block the top area too though even if it's not 'dimmed'...
			// dimmer = GrUtil.makeRect(SiteConstants.CONTENT_AREA_WIDTH, SiteConstants.CONTENT_AREA_HEIGHT, 0x0, 0.5);
			// dimmer.x = holder.x;
			// dimmer.y = holder.y;
			
			dimmer = GrUtil.makeRect(ConfigModel.gi.stageW, ConfigModel.gi.stageH, 0x0, 0.5);
			dimmer.x = 0;
			dimmer.y = 0;

			dimmer.visible = false;
			this.addChild(dimmer);
		}
		
		protected function addDialogHolder():void
		{
			dialogHolder = new Sprite();
			dialogHolder.x = holder.x;
			dialogHolder.y = holder.y;
			this.addChild(dialogHolder);
		}
		
		protected function initState() : void 
		{ 
			var isCommisioner : Boolean = LeagueModel.gi.isCommissioner;
			trace( "MAIN : initState() : isCommisioner is "+isCommisioner );
		}
		
		protected function addHolder() : void 
		{ 
			trace( "MAIN : addHolder()" );
			holder = new MovieClip();
			holder.x = HOLDER_X;
			holder.y = HOLDER_Y;
			addChild( holder );
		}
		
		protected function addTouts() : void 
		{ 
			trace( "MAIN : addTouts()" );
			touts = new Touts();
			touts.init();
//			touts.y = header.height;
			
			// add tout just above holder (below dialog holder)
			this.addChildAt( touts, this.getChildIndex(holder) ); 
			header.resetNav();
			
			_currentView = touts;
		}
		
		protected function addInviter() : void 
		{ 
			trace( "MAIN : addInviter()" );
			if( !inviter )
			{	
				inviter = new Inviter();
				inviter.init();
			}
			inviter.getUserVideoStatus();
			holder.addChild( inviter );
			
			_currentView = inviter;
		}
		
		protected function addEnforcer() : void 
		{ 
			trace( "MAIN : addEnforcer()" );
			if( !enforcer )
			{	
				enforcer = new Enforcer();
				enforcer.init();
			}
			holder.addChild( enforcer );
			
			_currentView = enforcer;
		}
		
		protected function addReportCard() : void 
		{ 
			trace( "MAIN : addReportCard()" );
			if( !reportCard )
			{	
				reportCard = new ReportCard();
				reportCard.init();
			}
			holder.addChild( reportCard );
			
			_currentView = reportCard;
		}
		
		protected function addApparel() : void 
		{ 
			trace( "MAIN : addApparel()" );
			if( !apparel )
			{	
				apparel = new Apparel();
				apparel.init();
			}
			holder.addChild( apparel );
			
			_currentView = apparel;
		}
		
		protected function showView( ) : void 
		{ 
			trace( "\n*******************************************" );
			trace( "MAIN : showView()" );
			var state : String = _stateModel.state;
			
			switch( state )
			{
				case StateModel.STATE_TOUTS:
					addTouts();
					break;
				case StateModel.STATE_INVITER:
					addInviter();
					break;
				case StateModel.STATE_ENFORCER:
					addEnforcer();
					break;
				case StateModel.STATE_REPORT_CARD:
					addReportCard();
					break;
				case StateModel.STATE_APPAREL:
					addApparel();
					break;
			}
			
			_currentView.addEventListener( ContainerEvent.SHOW, showViewComplete );
			
			_currentView.blendMode = BlendMode.LAYER;
			_currentView.show( SiteConstants.TIME_TRANSITION_IN );
			
			_stateModel.previousState = state;
//			if( _stateModel.previousState == StateModel.STATE_INVITER )	inviter.resetUserVideoStatus();
		}
		
		protected function showViewComplete( e : ContainerEvent ) : void 
		{ 
			trace( "MAIN : showViewComplete()" );
			_currentView.removeEventListener( ContainerEvent.SHOW, showViewComplete );
			_currentView.blendMode = BlendMode.NORMAL; // (restore)
			
		}
		
		protected function hideView() : void 
		{ 
			trace( "\n*******************************************" );
			trace( "MAIN : hideView()" );
			_currentView.addEventListener( ContainerEvent.HIDE, hideViewComplete );
			_currentView.blendMode = BlendMode.LAYER;
			_currentView.hide( SiteConstants.TIME_TRANSITION_OUT );
		}
		
		protected function hideViewComplete( e : ContainerEvent ) : void 
		{ 
			trace( "MAIN : hideViewComplete() : _currentView.name is "+_currentView.name );
			_currentView.removeEventListener( ContainerEvent.HIDE, hideViewComplete );
			_currentView.blendMode = BlendMode.NORMAL;
			
			removeChildrenFromHolder();
			showView();
		}
		
		protected function removeChildrenFromHolder( ) : void 
		{ 
			trace( "MAIN : removeChildrenFromHolder()" );
			for ( var i:uint = 0; i < holder.numChildren; i++)
			{
				var object : * = holder.getChildAt(i);
				holder.removeChildAt(i);
			}
		}
		
		public function showNotCommissionerDialog() : void
		{
			var dto : CopyDTO = ContentModel.gi.getCopyItemByName( "alertNotCommissioner" );
			var _confirmationDialog : AbstractDialog = AlertDialogMaker.make( true, dto.title, dto.copy, dto.yesLabel, dto.noLabel, onCommissionerYes, onCommissionerNo, null, 505 );
			showDialog(_confirmationDialog);
			
			Metrics.pageView("homeNotCommissionerDialog");
		}
		
		// User is on the alternate not-logged-in landing page, not on the real site
		//
		public function showNotLoggedInPageDialog():void
		{
			var useNewVersion:Boolean = true;
			
			if (useNewVersion)
			{
				if (! _notLoggedInDialog) {
					_notLoggedInDialog = new NotLoggedInDialog(onNotLoggedInDialogYes);
				}
				showDialog(_notLoggedInDialog);
			}
			else
			{
				var dto : CopyDTO = ContentModel.gi.getCopyItemByName( "alertNotLoggedInPage" );
				var dialog:AbstractDialog = AlertDialogMaker.makeNotLoggedInPageDialog(dto.title,dto.copy,dto.yesLabel, onNotLoggedInDialogYes, 505);
				showDialog(dialog);
			}

			Metrics.pageView("notLoggedInPageDialog");
		}
		private function onNotLoggedInDialogYes():void
		{
			var url:String = ContentModel.gi.getCopyItemByName("alertNotLoggedInPageCreateALeagueUrl").copy;
			navigateToURL(new URLRequest(url), "_self");
		}
		private function onNotLoggedInDialogExtraLinkClick(e:*=null):void
		{
			var url:String = ContentModel.gi.getCopyItemByName("alertNotLoggedInPageCommissionerUrl").copy;
			navigateToURL(new URLRequest(url), "_self");
		}
		
		public function showPinwheel():void
		{
			Shell.instance.showPinwheel();
		}
		
		public function hidePinwheel():void
		{
			Shell.instance.hidePinwheel();
		}
		
		public function showDimmer():void
		{
			dimmer.visible = true;
			dimmer.alpha = 1.0;
		}
		
		public function hideDimmer():void
		{
			TweenLite.to(dimmer, SiteConstants.TIME_TRANSITION_OUT, { alpha:0, onComplete:function():void{ dimmer.visible = false; } } );
		}

		//----------------------------------------------------------------------------
		// dialog logic. 
		// is now officially a nightmare.
		//----------------------------------------------------------------------------

		public function showDialog($d:AbstractDialog, $yOffset:Number=0):void
		{
			showDimmer(); 

			$d.x = int( (SiteConstants.CONTENT_AREA_WIDTH - $d.dialogWidth) * .5 );
			$d.y = int( (SiteConstants.CONTENT_AREA_HEIGHT - $d.dialogHeight) * .5 ) - 15; // "-15" for extra height above and below the chrome
			$d.y += $yOffset;
			dialogHolder.addChild($d);

			Out.i("showDialog() - numdialogs:", dialogHolder.numChildren);
			
			$d.alpha = 0;
			$d.blendMode = BlendMode.LAYER;
			$d.show(SiteConstants.TIME_TRANSITION_IN);
		}
		
		public function showDialogQuick($showCloseButton:Boolean, $title:String, $message:String):void
		{
			var dialog:AbstractDialog = AlertDialogMaker.make($showCloseButton, $title, $message, "OKAY", null);
			showDialog(dialog);
		}
		
		public function showDialogWithCopyDto($useCloseButton:Boolean, dto:CopyDTO, $callbackYes:Function=null, $callbackNo:Function=null, $callbackClose:Function=null, $width:Number=400):void
		{
			if (! dto || ! dto.yesLabel || (dto.yesLabel && dto.yesLabel.length == 0)) {
				Out.w("showDialogWithCopyDto() - MISSING INFORMATION");
				return;
			}
			
			var dialog:AbstractDialog = AlertDialogMaker.make($useCloseButton, dto.title, dto.copy, dto.yesLabel, dto.noLabel, $callbackYes,$callbackNo,$callbackClose, $width);
			showDialog(dialog);
		}

		public function showDialogWithCopyDtoId($useCloseButton:Boolean, $dtoId:String, $callbackYes:Function=null, $callbackNo:Function=null, $callbackClose:Function=null, $width:Number=400):void
		{
			var dto:CopyDTO = ContentModel.gi.getCopyItemByName($dtoId);
			showDialogWithCopyDto($useCloseButton, dto, $callbackYes, $callbackNo, $callbackClose, $width);
		}

		public function hideDialog($slowerForToast:Boolean=false):void
		{
			Out.i("hideDialog() - numdialogs:", dialogHolder.numChildren-1);
			
			// get top-most dialog
			var view:AbstractDialog = dialogHolder.getChildAt(dialogHolder.numChildren-1 ) as AbstractDialog;

			var onHide:Function = function($e:Event):void {
				$e.target.removeEventListener(ContainerEvent.HIDE, onHide);
				var d:DisplayObject = $e.target as DisplayObject;
				if (d && d.parent) d.parent.removeChild(d);
			}
			view.addEventListener(ContainerEvent.HIDE, onHide);
			var time:Number = $slowerForToast ? SiteConstants.TIME_TRANSITION_OUT * 4 : SiteConstants.TIME_TRANSITION_OUT; 
			view.hide(time);
			
			if (dialogHolder.numChildren == 1) {
				// fade out dimmer because there's only one dialog left
				hideDimmer();
			}
			
			this.mouseEnabled = this.mouseChildren = true;
		}
		
		// A 'toast' is just a dialog with no buttons that fades out after a short delay
		//
		public function showToast($title:String, $copy:String):void
		{
			var dialog:AbstractView = AlertDialogMaker.make(false, $title, $copy, null,null);
			dialog.x = int( (SiteConstants.CONTENT_AREA_WIDTH - dialog.width) * .5 );
			dialog.y = int( (SiteConstants.CONTENT_AREA_HEIGHT - dialog.height) * .5 );
			dialogHolder.addChild(dialog);
			dialog.alpha = 0;
			dialog.blendMode = BlendMode.LAYER;
			dialog.show(SiteConstants.TIME_TRANSITION_IN);
			
			this.mouseEnabled = this.mouseChildren = false;
			
			setTimeout(hideDialog, 2000, true);
		}
		
		public function showToastWithCopyDto($dto:CopyDTO):void
		{
			showToast($dto.title, $dto.copy);
		}
		
		private function onCommissionerYes():void
		{
		    hideDialog();
			var url : String = ConfigModel.gi.createLeagueURL;
			var urlRequest : URLRequest = new URLRequest( url );
			navigateToURL( urlRequest, "_blank");
			
			Metrics.pageView("homeLoggedOutDialogSignupButton");
		}
		private function onCommissionerNo():void
		{
//		    _fb.doMapperDialog( onMapperDialogDone );
		}
		
		//----------------------------------------------------------------------------
		// event handlers
		//----------------------------------------------------------------------------
		protected function onStateChange( e : StateEvent ) : void
		{	
			trace( "MAIN : onStateChange()" );
			var state : String = e.type;
			var previousState : String = _stateModel.previousState;
			trace( "MAIN : onStateChange() : state is "+state );
			trace( "MAIN : onStateChange() : previousState is "+previousState );
			
			if( previousState == null )
			{
				trace( "MAIN : onStateChange() : THE PREVIOUS STATE IS NULL!" );
				showView();
			}
			else 
			{
				hideView();
			}
		}
		
		private function onHeaderFacebookButtonSelect(e:*):void
		{
			if (ConfigModel.gi.isPressPreview) return;

			if (ConfigModel.gi.isOnNotLoggedInPage) {
				Main.instance.showNotLoggedInPageDialog();
				return;
			}
			
			if (! LeagueModel.gi.isCommissioner ) {
				Main.instance.showNotCommissionerDialog();
				return;
			}

			var s:String = ContentModel.gi.getCopyItemByName("fbPopupUrl").copy;
			var url:String = ContentModel.gi.getCopyItemByName("fbShareUrl").copy
			s += "?u=" + escape(url); // note, must be url encoded
			
			Metrics.pageView("globalShareFacebookButton");

			Out.i("Main.onHeaderFbButton()", s);
			
			ExternalInterface.call(FbUtilWeb.POPUP_FUNCTION, s, 675,380); 
		}

		private function onHeaderTwitterButtonSelect(e:*):void
		{
			if (ConfigModel.gi.isPressPreview) return;
			
			if (ConfigModel.gi.isOnNotLoggedInPage) {
				Main.instance.showNotLoggedInPageDialog();
				return;
			}
			
			if (! LeagueModel.gi.isCommissioner ) {
				Main.instance.showNotCommissionerDialog();
				return;
			}
			
			Metrics.pageView("globalShareTwitterButton");
			
			var s:String = ContentModel.gi.getCopyItemByName("twitterPopupUrl").copy;
			
			// Docs say to use URL-encoded, but that fails for me fyi. 
			var url:String = ContentModel.gi.getCopyItemByName("twitterTweetUrl").copy;
			
			// properly UTF-8 and percent-encoded Tweet body text
			var text:String = ContentModel.gi.getCopyItemByName("twitterTweetCopy").copy
			
			// omit the "#" symbol and separate multiple hashtags with commas
			var hashtags:String = ContentModel.gi.getCopyItemByName("twitterTweetHashTags").copy
			
			s += "?text=" + text + "&url=" + url + "&hashtags=" + hashtags;
			
			ExternalInterface.call(FbUtilWeb.POPUP_FUNCTION, s, 675,380); 

		}
		
		protected function onHeaderConnectButton(e:*):void
		{
			if (ConfigModel.gi.isPressPreview) return;
			
			if (ConfigModel.gi.isOnNotLoggedInPage) {
				Main.instance.showNotLoggedInPageDialog();
				return;
			}

			if (! LeagueModel.gi.isCommissioner ) {
				Main.instance.showNotCommissionerDialog();
				return;
			}
			
			Metrics.pageView("globalSettingsButton");

			FacebookHelper.instance.login("yes", null);
		}
		
		//----------------------------------------------------------------------------
		// getters/setters
		//----------------------------------------------------------------------------

		// Lo-rent Singleton
		public static function get instance():Main
		{
			return _instance;
		}
		
		
		private function testS3Upload(e:*=null):void
		{
			var s3uploader:FflS3Uploader = new FflS3Uploader();
			var b:BitmapData = GrUtil.makePerlinBitmap(640,480, false).bitmapData;
			var ba:ByteArray = new JPEGEncoder(90).encode(b);
			
			s3uploader.addEventListener(FflS3Uploader.EVENT_COMPLETE, onS3Complete);
			s3uploader.upload(ba, "jpg");
		}
		private function onS3Complete(e:ExtendedEvent):void
		{
			trace('TEST S3 UPLOAD COMPLETE: ', e.object);
		}
	}
}
