package com.espn.ffl.views.inviter {
	import com.espn.ffl.Shell;
	import com.espn.ffl.constants.SiteConstants;
	import com.espn.ffl.model.ContentModel;
	import com.espn.ffl.model.InviterModel;
	import com.espn.ffl.model.LeagueModel;
	import com.espn.ffl.model.PersonalizedModel;
	import com.espn.ffl.model.PremadeModel;
	import com.espn.ffl.model.dto.CopyDTO;
	import com.espn.ffl.util.Assets;
	import com.espn.ffl.util.FacebookHelper;
	import com.espn.ffl.util.FflDropShadow;
	import com.espn.ffl.util.Metrics;
	import com.espn.ffl.views.AbstractView;
	import com.espn.ffl.views.FflButton;
	import com.espn.ffl.views.Main;
	import com.espn.ffl.views.dialogs.AbstractDialog;
	import com.espn.ffl.views.dialogs.AlertDialogMaker;
	import com.espn.ffl.views.inviter.views.InviterPinwheel;
	import com.greensock.TweenLite;
	import com.jasontighe.managers.AssetManager;
	import com.jasontighe.utils.Box;
	
	import flash.display.Bitmap;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.system.System;
	import flash.text.TextField;
	
	import leelib.graphics.GrUtil;
	import leelib.ui.Component;
	import leelib.ui.DumbWrapper;
	import leelib.util.Out;
	import leelib.util.TextFieldUtil;
	import leelib.vid.MinVid;
	import leelib.vid.VidProgressBar;

	/**
	 * @author jason.tighe
	 */
	public class Preview 
	extends AbstractView
	{
		//----------------------------------------------------------------------------
		// private static constants
		//----------------------------------------------------------------------------
		private static const DELETE_WIDTH					: uint = 326;
		private static const DELETE_HEIGHT					: uint = 41;
		private static const DELETE_SIZE					: uint = 23;
		private static const SHARE_WIDTH					: uint = 252;
		private static const SHARE_HEIGHT					: uint = 41;
		private static const SHARE_SIZE						: uint = 23;
		private static const ALPHA_INACTIVE					: Number = .25;
		private static const ALPHA_OVER						: uint = 1;
		private static const ALPHA_OUT						: Number = .75;
		private static const COLOR_OVER						: uint = 0x5d5d5d;
		private static const COLOR_OUT						: uint = 0x232323;
		
		//----------------------------------------------------------------------------
		// private variables
		//----------------------------------------------------------------------------
		private var _cm										: ContentModel = ContentModel.gi;
		private var _im										: InviterModel = InviterModel.gi;
		private var _progressBar							: VidProgressBar;
		private var _playIcon:Bitmap;
		private var _pauseIcon:Bitmap;
		private var _videoStartedAt:Number;
		
		//----------------------------------------------------------------------------
		// public variables
		//----------------------------------------------------------------------------
		public var holder									: MovieClip;
		public var frame									: MovieClip;
		public var deleteBtn								: FflButton;
		public var shareOrGetUrlBtn									: FflButton;
		public var _minVid									: MinVid;
		public var videoBtn									: Box;
		public var pinwheel									: InviterPinwheel;
		public var pinwheelHolder							: MovieClip;
		public var _fb										: FacebookHelper = FacebookHelper.instance;
		//----------------------------------------------------------------------------
		// constructor
		//----------------------------------------------------------------------------
		public function Preview() 
		{
			super();
			trace( "PREVIEW : Constr" );
		}
		
		//----------------------------------------------------------------------------
		// public methods
		//----------------------------------------------------------------------------
		public function pause() : void
		{
			_minVid.pause();
//			_minVid = null;
		}
		
		//----------------------------------------------------------------------------
		// protected methods
		//----------------------------------------------------------------------------

//		protected function transitionInComplete() : void { }
//		protected function transitionOutComplete() : void { }
		
		protected override function addViews() : void 
		{ 
			var asset : MovieClip = MovieClip( AssetManager.gi.getAsset( "PreviewAsset", SiteConstants.ASSETS_ID ) );
			addChild( asset );
			
			holder = asset.holder;
			frame = asset.frame;
			asset.playBtn.visible = false; // remove original playbutton
			
			var copy : String;
			var search : String = "#";
//			var replace : String;
		
			copy = _cm.getCopyItemByName("previewTitle").copy;
			var leagueName : String = LeagueModel.gi.leagueName;	
			copy = replaceString( copy, search, leagueName );		
			var title : TextField  = TextFieldUtil.makeText( copy, ".previewTitle");
			title.x = _cm.getCopyItemByName("previewTitle").xPos;
			title.y = _cm.getCopyItemByName("previewTitle").yPos;
			addChild( title );
			title.filters = [ FflDropShadow.getDefault() ];
			
			
			copy = _cm.getCopyItemByName( "previewDeleteButton" ).copy;
			deleteBtn = new FflButton( copy, DELETE_WIDTH, DELETE_HEIGHT, DELETE_SIZE, FflButton.BACKGROUNDTYPE_GRAY, false);
			deleteBtn.x = _cm.getCopyItemByName( "previewDeleteButton" ).xPos;
			deleteBtn.y = _cm.getCopyItemByName( "previewDeleteButton" ).yPos;
			addChild( deleteBtn );
			
			if (LeagueModel.gi.teamsByAlpha && LeagueModel.gi.teamsByAlpha.length > 0) {
				copy = _cm.getCopyItemByName( "previewShareButton" ).copy;
			}
			else {
				copy = _cm.getCopyItemByName( "previewGetUrlButton" ).copy;
			}
			shareOrGetUrlBtn = new FflButton( copy, SHARE_WIDTH, SHARE_HEIGHT, SHARE_SIZE, FflButton.BACKGROUNDTYPE_GREEN, false );
			shareOrGetUrlBtn.x = _cm.getCopyItemByName( "previewShareButton" ).xPos;
			shareOrGetUrlBtn.y = _cm.getCopyItemByName( "previewShareButton" ).yPos;
			addChild( shareOrGetUrlBtn );
			
			deleteBtn.addEventListener( Event.SELECT, onDeleteClicked );
			shareOrGetUrlBtn.addEventListener( Event.SELECT, onShareOrGetUrlClicked );	
			
			_minVid = new MinVid();
			_minVid.sizeWidthHeight( SiteConstants.WEBCAM_FULL_WIDTH, SiteConstants.WEBCAM_FULL_HEIGHT );
			holder.addChild( _minVid );
			
			_playIcon = new Assets.EnforcerVideoPlayIcon();
			_playIcon.alpha = 0;
			holder.addChild(_playIcon);
			GrUtil.centerInParent(_playIcon);
			
			_pauseIcon = new Assets.EnforcerVideoPauseIcon();
			_pauseIcon.alpha = 0;
			holder.addChild(_pauseIcon);
			GrUtil.centerInParent(_pauseIcon);
			
			// progress bar / scrubber setup
			
			var bb:Component = new DumbWrapper( new Assets.InviterScrubberBg() );
			var lb:Component = new DumbWrapper( new Assets.InviterScrubberLoaded() );

			var thumb:Component = new Component();
			var b:Bitmap = new Assets.InviterScrubberThumb();
			b.x = b.width/-2;
			b.y = b.height/-2 + bb.height/2;
			thumb.addChild(b);

			_progressBar = new VidProgressBar(bb,lb,thumb, true, SiteConstants.WEBCAM_FULL_WIDTH+2, bb.height, false, Shell.stage);
			_progressBar.x = -1;
			_progressBar.y = SiteConstants.WEBCAM_FULL_HEIGHT;
			holder.addChild(_progressBar);
			_minVid.progressBar = _progressBar;
			
			//
			
			pinwheelHolder = new MovieClip()
			pinwheelHolder.x = holder.x;
			pinwheelHolder.y = holder.y;
			addChild( pinwheelHolder );
			
			videoBtn = new Box( SiteConstants.WEBCAM_FULL_WIDTH, SiteConstants.WEBCAM_FULL_HEIGHT );
			videoBtn.x = holder.x;
			videoBtn.y = holder.y;
			addChild( videoBtn );
			videoBtn.alpha = 0;
			
			activateStart();
		}

		//----------------------------------------------------------------------------
		// private methods
		//----------------------------------------------------------------------------
		private function replaceString( s : String, search : String, replace : String  ) : String
		{
			return s.split(search).join(replace);
		}
		
		private function activateStart( ) : void
		{
			videoBtn.buttonMode = true;
			videoBtn.useHandCursor = true;
			videoBtn.mouseEnabled = true
			videoBtn.mouseChildren = false;
			videoBtn.addEventListener( MouseEvent.CLICK, onClickToStartPlay );
			videoBtn.visible = true;
			_progressBar.mouseEnabled = _progressBar.mouseChildren = false;
			
			showPlayIcon();
		}

		private function deactivateStart( ) : void
		{
			videoBtn.removeEventListener( MouseEvent.CLICK, onClickToStartPlay );

			videoBtn.buttonMode = false;
			videoBtn.useHandCursor = false;
			videoBtn.mouseEnabled = false
			videoBtn.mouseChildren = false;
			videoBtn.visible = false;
		}
		
		private function playVideo(  ) : void
		{
			if (! contains( _minVid )) addChild( _minVid );
			
			addPinwheel();
			
			hideIcons();
		
			// var url = "http://testqa.s3.amazonaws.com/dvp/issues/li0123456789/questions_test1.mp4";
			// var url : String = _cm.getInterviewVideoItemAt( 3 ).previewURL;
			 var url : String = InviterModel.gi.s3URL;
			_minVid.addEventListener( Component.EVENT_LOADED, onVideoLoaded );
			_minVid.go( url );
		}
		
		private function addPinwheel() : void 
		{ 
			pinwheel= new InviterPinwheel;
			pinwheelHolder.addChild( pinwheel );
			pinwheel.showPinwheel();
		}
		
		private function removePinwheel() : void 
		{ 
			if( pinwheelHolder.contains( pinwheel ))
			{
				pinwheel.hidePinwheel();
				pinwheelHolder.removeChild( pinwheel );
				pinwheel = null;
			}
		}
		
		private function showPlayIcon():void
		{
			TweenLite.to(_playIcon, 0.25, { alpha:1 } );
			TweenLite.to(_pauseIcon, 0.25, { alpha:0 } );
		}
		private function showPauseIcon():void
		{
			TweenLite.to(_pauseIcon, 0.25, { alpha:1 } );
			TweenLite.to(_playIcon, 0.25, { alpha:0 } );
		}
		private function hideIcons():void
		{
			TweenLite.to(_playIcon, 0.25, { alpha:0 } );
			TweenLite.to(_pauseIcon, 0.25, { alpha:0 } );
		}

		//----------------------------------------------------------------------------
		// event handlers
		//----------------------------------------------------------------------------
		protected function onClickToStartPlay( e : MouseEvent ) : void
		{	
			playVideo();
			deactivateStart();
		}
		
		private function onVideoLoaded( e : Event ) : void 
		{ 
			_minVid.removeEventListener( Component.EVENT_LOADED, onVideoLoaded );
			removePinwheel();
			
			_minVid.buttonMode = true;
			_minVid.useHandCursor = true;
			_minVid.mouseEnabled = true
			_minVid.mouseChildren = false;
			_minVid.addEventListener( MouseEvent.CLICK, onMinVidClick );
			
			_videoStartedAt = new Date().time; 
			_minVid.addEventListener( MouseEvent.ROLL_OVER, onMinVidOver);
			_minVid.addEventListener( MouseEvent.ROLL_OUT, onMinVidOut);
			_minVid.addEventListener( Event.COMPLETE, onVideoComplete );
			
			_progressBar.mouseEnabled = _progressBar.mouseChildren = true;
			
			hideIcons();
		}

		private function onMinVidOver(e:*):void
		{
			if (new Date().time - _videoStartedAt < 100) return; // yes this is lame
			
			if (_minVid.state != "playing")
			{
				showPlayIcon();
			}
			else
			{
				showPauseIcon();
			}
		}
		
		private function onMinVidOut(e:*):void
		{
			if (_minVid.state == "playing")
			{
				hideIcons();
			}
		}
		
		private function onVideoComplete( e : Event ) : void 
		{ 
			trace('complete xxxxxxxxxxxxx', _minVid.videoDuration);
			
			_minVid.removeEventListener( Event.COMPLETE, onVideoComplete );
			activateStart();
		}

		private function onMinVidClick( e : MouseEvent ) : void 
		{
			switch ( _minVid.state )
			{
				case "playing":					
					_minVid.pause();
					showPlayIcon();
					break;
					
				case "paused":
					_minVid.resume();
					showPauseIcon();
					break;
			}
		}
		
		protected function onDeleteClicked( e : Event ) : void
		{	
			deleteBtn.removeEventListener( Event.SELECT, onDeleteClicked );
			
			if (_im.videoType == InviterModel.VIDEO_TYPE_PERSONALIZED)
				Metrics.pageView("inviterCustomizeStartOverButton");
			else
				Metrics.pageView("inviterPrerecordedStartOverButton");
			
			Inviter.instance.pauseCreated();
			
			InviterModel.gi.state = InviterModel.STATE_RESET;	
			
//			if( _im.videoType == InviterModel.VIDEO_TYPE_PERSONALIZED )
//			{
//				PersonalizedModel.gi.state = PersonalizedModel.STATE_INTRO;	
//			} 
//			else
//			{
//				PremadeModel.gi.state = PremadeModel.STATE_VIDEO_SELECTOR;	
//			}
		}

		
		// ==============================
		// SHARE STUFFS
		// ==============================
		
		private var _confirmationDialog:AbstractDialog;
		private var _confirmationDialogStateIsDefault:Boolean;
		private var _shareParams:Object;
		
		
		protected function onShareOrGetUrlClicked( e : Event ) : void
		{	
//			shareBtn.removeEventListener( Event.SELECT, onShareClicked );
//			StateModel.gi.state = StateModel.STATE_INVITER;
			
			if (! LeagueModel.gi.teamsByAlpha || LeagueModel.gi.teamsByAlpha.length == 0)
			{
				System.setClipboard(InviterModel.gi.youtubeURL);
				Main.instance.showToastWithCopyDto(ContentModel.gi.getCopyItemByName("toastInviterGetUrl"));
				
				if (_im.videoType == InviterModel.VIDEO_TYPE_PERSONALIZED)
					Metrics.pageView("inviterCustomizeGetUrlButton");
				else
					Metrics.pageView("inviterPrerecordedGetUrlButton");

				return;
			}
			
			//
			
			if (_im.videoType == InviterModel.VIDEO_TYPE_PERSONALIZED)
				Metrics.pageView("inviterCustomizeShareButton");
			else
				Metrics.pageView("inviterPrerecordedShareButton");
			
			_shareParams = {};
			
			_shareParams.link = InviterModel.gi.youtubeURL;
			_shareParams.caption = ContentModel.gi.getCopyItemByName("liShareCaption").copy;
			/* _shareParams.name is not supplied, so post will get its title from linked Youtube video's title */
                
			var stringId:String;
			if (_im.videoType == InviterModel.VIDEO_TYPE_PERSONALIZED) {
				stringId = "liShareDescription";
			}
			else {
				if (_im.premadeVideoId == 0) 
					stringId = "liShareDescriptionPremade1";
				else if (_im.premadeVideoId == 0) 
					stringId = "liShareDescriptionPremade2";
				else 
					stringId = "liShareDescriptionPremade3";
			}
			_shareParams.description =  ContentModel.gi.getCopyItemByName(stringId).copy;
			trace('onShareClicked()', stringId, _shareParams.description);
			
			// if not logged in, log in. if login successful, show popoup
			if (! _fb.isFullyLoggedIn) {
				_fb.login("no", showConfirmationDialog);
			}
			else {
				showConfirmationDialog();
			}
		}
		private function showConfirmationDialog():void
		{	
			var dto:CopyDTO = ContentModel.gi.getCopyItemByName("alertInviterShare");
			_confirmationDialog = AlertDialogMaker.make(true, dto.title, dto.copy, dto.yesLabel, dto.noLabel, onConfirmationDialogYes,onConfirmationDialogNo,onConfirmationDialogClose, 550);
			_confirmationDialog.addEventListener(TextEvent.LINK, onConfirmationDialogLink, false,0,true);
			
			setConfirmationDialogState(_fb.getFriendIdsFromMap().length > 0);
			Main.instance.showDialog(_confirmationDialog);
			
			if (_im.videoType == InviterModel.VIDEO_TYPE_PERSONALIZED)
				Metrics.pageView(_confirmationDialogStateIsDefault ? "inviterCustomizeShareDialog" : "inviterCustomizeNoFriendsDialog");
			else
				Metrics.pageView(_confirmationDialogStateIsDefault ? "inviterPrerecordedShareDialog" : "inviterPrerecordedNoFriendsDialog");
		}
		private function onConfirmationDialogYes():void
		{
			Main.instance.hideDialog();
			doTheShare();

			if (_im.videoType == InviterModel.VIDEO_TYPE_PERSONALIZED)
				Metrics.pageView("inviterCustomizeShareDialogPublishButton");
			else
				Metrics.pageView("inviterPrerecordedShareDialogPublishButton");
		}
		private function onConfirmationDialogNo():void
		{
			_fb.doMapperDialog( onMapperDialogDone );

			if (_im.videoType == InviterModel.VIDEO_TYPE_PERSONALIZED)
				Metrics.pageView(_confirmationDialogStateIsDefault ? "inviterCustomizeShareDialogSettingsButton" : "inviterCustomizeNoFriendsDialogSettingsButton");
			else
				Metrics.pageView(_confirmationDialogStateIsDefault ? "inviterPrerecordedShareDialogSettingsButton" : "inviterPrerecordedNoFriendsDialogSettingsButton");
		}
		private function onConfirmationDialogLink($e:TextEvent):void
		{
			if (_im.videoType == InviterModel.VIDEO_TYPE_PERSONALIZED)
				Metrics.pageView("inviterCustomizeNoFriendsDialogSettingsLink");
			else
				Metrics.pageView("inviterPrerecordedNoFriendsDialogSettingsLink");
			
			Out.i("onConfirmationDialogLink() - " + $e.text);
			_fb.doMapperDialog( onMapperDialogDone );
		}
		private function onConfirmationDialogClose():void
		{
			Main.instance.hideDialog();

			if (_im.videoType == InviterModel.VIDEO_TYPE_PERSONALIZED)
				Metrics.pageView(_confirmationDialogStateIsDefault ? "inviterCustomizeShareDialogCloseButton" : "inviterCustomizeNoFriendsDialogCloseButton");
			else
				Metrics.pageView(_confirmationDialogStateIsDefault ? "inviterPrerecordedShareDialogCloseButton" : "inviterPrerecordedNoFriendsDialogCloseButton");
		}
		private function onMapperDialogDone():void
		{
			setConfirmationDialogState( _fb.getFriendIdsFromMap().length > 0 );
		}
		private function doTheShare():void
		{
			var fb : FacebookHelper =  FacebookHelper.instance;
			fb.doInviterShare(_shareParams);
		}
		
		private function setConfirmationDialogState($hasSelectedFriends:Boolean):void
		{
			_confirmationDialogStateIsDefault = $hasSelectedFriends;
			
			if ($hasSelectedFriends)
			{
				var dto:CopyDTO = ContentModel.gi.getCopyItemByName("alertInviterShare");
				_confirmationDialog.tfCopy.htmlText = dto.copy;
				TextFieldUtil.applyAndMakeDefaultStyle(_confirmationDialog.tfCopy, ".alertDialogCopy");
				_confirmationDialog.yesButton.alpha = 1;
				_confirmationDialog.yesButton.mouseEnabled = _confirmationDialog.yesButton.mouseChildren = true;
				_confirmationDialog.redBackgroundVisible = false;
			}
			else
			{
				_confirmationDialog.tfCopy.htmlText = ContentModel.gi.getCopyItemByName("alertReportCardShareNoFriends").copy;
				TextFieldUtil.applyAndMakeDefaultStyle(_confirmationDialog.tfCopy, ".alertDialogCopyRed");
				_confirmationDialog.yesButton.alpha = 0.5;
				_confirmationDialog.yesButton.mouseEnabled = _confirmationDialog.yesButton.mouseChildren = false;
				_confirmationDialog.redBackgroundVisible = true;
			}
		}
	}
}
