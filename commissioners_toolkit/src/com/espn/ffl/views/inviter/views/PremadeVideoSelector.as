package com.espn.ffl.views.inviter.views {
	import com.espn.ffl.constants.SiteConstants;
	import com.espn.ffl.image_uploader.DialogUploadPhoto;
	import com.espn.ffl.model.ContentModel;
	import com.espn.ffl.model.InviterModel;
	import com.espn.ffl.util.Assets;
	import com.espn.ffl.util.FflDropShadow;
	import com.espn.ffl.util.Metrics;
	import com.espn.ffl.views.AbstractView;
	import com.espn.ffl.views.FflButton;
	import com.greensock.TweenLite;
	import com.greensock.easing.Quad;
	import com.jasontighe.managers.AssetManager;
	import com.jasontighe.utils.Box;
	
	import flash.display.Bitmap;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	import leelib.ExtendedEvent;
	import leelib.graphics.GrUtil;
	import leelib.ui.Component;
	import leelib.util.TextFieldUtil;
	import leelib.vid.MinVid;

	/**
	 * @author jason.tighe
	 */
	public class PremadeVideoSelector 
	extends AbstractView 
	{
		//----------------------------------------------------------------------------
		// private static constants
		//----------------------------------------------------------------------------
		private static const BUTTON_WIDTH					: uint = 155;
		private static const BUTTON_HEIGHT					: uint = 33;
		private static const BUTTON_SIZE					: uint = 18;
		private static const BUTTON_X						: uint = 367;
		private static const BUTTON_Y						: uint = 495;
		private static const FRAME_X						: uint = 118;
		private static const FRAME_Y						: uint = 110;
		private static const FRAME_COLOR					: uint = 0xFFFFFF;
		private static const FRAME_BG_COLOR					: uint = 0x000000;
		private static const ALPHA_INACTIVE					: Number = .25;
		private static const ALPHA_OVER						: uint = 1;
		private static const ALPHA_OUT						: Number = .75;
		private static const Y_SPACE						: uint = 200;
		private static const MASKER_WIDTH					: uint = 880;
		private static const MASKER_HEIGHT					: uint = 485;
		private static const COLOR_OVER						: uint = 0x5d5d5d;
		private static const COLOR_OUT						: uint = 0x232323;
		private static const TITLE_BAR_HEIGHT				: uint = 45;
		private static const TITLE_BAR_ALPHA				: Number = .8;
		private static const UPLOAD_Y						: uint = 13;
		//----------------------------------------------------------------------------
		// private variables
		//----------------------------------------------------------------------------
		private var _im										: InviterModel = InviterModel.gi;
		private var _cm										: ContentModel = ContentModel.gi;
		private var _indicators								: Array = new Array();
		private var _images									: Array = new Array();
		private var _curVideo								: uint = 0;
		
		private var _playIcon:Bitmap;
		private var _pauseIcon:Bitmap;
		private var _videoStartedAt:Number;
		//----------------------------------------------------------------------------
		// public variables
		//----------------------------------------------------------------------------
		public var arrowL									: MovieClip;
		public var arrowR									: MovieClip;
		public var indicator0								: MovieClip;
		public var indicator1								: MovieClip;
		public var indicator2								: MovieClip;
		public var watching									: MovieClip;
		public var stuff									: MovieClip;
		public var classes									: MovieClip;
		public var imageHolder								: MovieClip;
		public var frameHolder								: MovieClip;
		public var arrowHolder								: MovieClip;
		public var _minVid									: MinVid;
		public var pinwheel									: InviterPinwheel;
		public var pinwheelHolder							: MovieClip;
		public var imageUploader							: PremadeImageUploader;
		//----------------------------------------------------------------------------
		// constructor
		//----------------------------------------------------------------------------
		public function PremadeVideoSelector() 
		{
			super();
		}
		//----------------------------------------------------------------------------
		// protected methods
		//----------------------------------------------------------------------------
//		protected function transitionInComplete() : void { }
//		protected function transitionOutComplete() : void { }
		
		protected override function addViews() : void 
		{ 
			var asset : MovieClip = MovieClip( AssetManager.gi.getAsset( "PremadeAsset", SiteConstants.ASSETS_ID ) );
			addChild( asset );
			
			// FOR ALL TEXT
			var tf : TextField;
			
			// TITLE
			tf = TextFieldUtil.makeHtmlTextWithCopyDto( _cm.getCopyItemByName( "liPremadeTitle" ), 800, 60 );
//			tf.x = Math.round( ( asset.width - tf.width ) * .5 );
			addChild( tf );
			tf.filters = [ FflDropShadow.getDefault() ];
			
			// DESC
			tf = TextFieldUtil.makeHtmlTextWithCopyDto( _cm.getCopyItemByName( "liPremadeDesc" ), 600, 30 );
//			tf.x = Math.round( ( asset.width - tf.width ) * .5 );
			addChild( tf );
			tf.filters = [ FflDropShadow.getDefault() ];
			
			arrowL = asset.arrowL;
			arrowR = asset.arrowR;
			indicator0 = asset.indicator0;
			indicator1 = asset.indicator1;
			indicator2 = asset.indicator2;
			classes = asset.classes;
			stuff = asset.stuff;
			watching = asset.watching;
			
			_indicators = [ indicator0, indicator1, indicator2 ];
			_images = [ classes, stuff, watching ];
			
			var frame : Box = new Box( SiteConstants.WEBCAM_FULL_WIDTH + 2, SiteConstants.WEBCAM_FULL_HEIGHT + 2, FRAME_COLOR );
			frame.x = FRAME_X;
			frame.y = FRAME_Y;
			addChild( frame );
			var frameBg : Box = new Box( SiteConstants.WEBCAM_FULL_WIDTH, SiteConstants.WEBCAM_FULL_HEIGHT, FRAME_BG_COLOR );
			frameBg.x = FRAME_X + 1;
			frameBg.y = FRAME_Y + 1;
			addChild( frameBg );
			
			frameHolder = new MovieClip();
			addChild( frameHolder );
			frameHolder.addChild( frame );
			frameHolder.addChild( frameBg );
			frameHolder.alpha = 0;
			frameHolder.filter = [ FflDropShadow.getDefault() ];
			
			imageHolder = new MovieClip();
			addChild( imageHolder );
			imageHolder.addChild( watching );
			imageHolder.addChild( stuff );
			imageHolder.addChild( classes );
			imageHolder.x = FRAME_X;
//			imageHolder.filter = [ FflDropShadow.getDefault() ];
			classes.filter = [ FflDropShadow.getDefault() ];
			stuff.filter = [ FflDropShadow.getDefault() ];
			watching.filter = [ FflDropShadow.getDefault() ];
			
			var masker : Box = new Box( MASKER_WIDTH, MASKER_HEIGHT );
			addChild( masker );
			imageHolder.mask = masker;
			
			arrowHolder = new MovieClip();
			arrowHolder.addChild( arrowL );
			arrowHolder.addChild( arrowR );
			addChild( arrowHolder );
			arrowL.filter = [ FflDropShadow.getDefault() ];
			arrowR.filter = [ FflDropShadow.getDefault() ];
			
			_minVid = new MinVid();
			_minVid.sizeWidthHeight( SiteConstants.WEBCAM_FULL_WIDTH, SiteConstants.WEBCAM_FULL_HEIGHT);
			_minVid.x = FRAME_X + 1;
			_minVid.y = FRAME_Y + 1;
			addChild( _minVid );
			
			_playIcon = new Assets.EnforcerVideoPlayIcon();
			_playIcon.alpha = 0;
			_minVid.addChild(_playIcon);
			GrUtil.centerInParent(_playIcon);
			
			_pauseIcon = new Assets.EnforcerVideoPauseIcon();
			_pauseIcon.alpha = 0;
			_minVid.addChild(_pauseIcon);
			GrUtil.centerInParent(_pauseIcon);
			
			
			pinwheelHolder = new MovieClip()
			pinwheelHolder.x = FRAME_X;
			pinwheelHolder.y = FRAME_Y;
			addChild( pinwheelHolder );
			
			var copy : String = _cm.getCopyItemByName( "liPremadeButton" ).copy;
			var fflButton : FflButton = new FflButton( copy, BUTTON_WIDTH, BUTTON_HEIGHT, BUTTON_SIZE, FflButton.BACKGROUNDTYPE_GREEN, false );
			fflButton.x = BUTTON_X;
			fflButton.y = BUTTON_Y;
			addChild( fflButton );
			
			fflButton.addEventListener( Event.SELECT, onSelectClicked )
			
			updateArrows();
			positionImages();
			updateIndicators();
			activateImage();
			addImageTitles();
		}
		
		//----------------------------------------------------------------------------
		// private methods
		//----------------------------------------------------------------------------
		private function activateStart( item : MovieClip ) : void
		{
			Metrics.pageView("inviterPrerecorded");
			
			item.buttonMode = true;
			item.useHandCursor = true;
			item.mouseEnabled = true
			item.mouseChildren = false;
			item.addEventListener( MouseEvent.CLICK, doItemClick );
			item.addEventListener( MouseEvent.MOUSE_OVER, doItemOver );
			item.addEventListener( MouseEvent.MOUSE_OUT, doItemOut );
			item.alpha = ALPHA_OUT;
		}
		
		private function deactivateStart( item : MovieClip ) : void
		{
			item.buttonMode = false;
			item.useHandCursor = false;
			item.mouseEnabled = false
			item.mouseChildren = false;
			item.removeEventListener( MouseEvent.CLICK, doItemClick );
			item.removeEventListener( MouseEvent.MOUSE_OVER, doItemOver );
			item.removeEventListener( MouseEvent.MOUSE_OUT, doItemOut );
			item.alpha = ALPHA_INACTIVE;
		}
		
		private function positionImages( ) : void
		{
			var i : uint = 0
			var I : uint = _images.length;
			for( i; i < I; i++ )
			{
				var item : MovieClip = _images[i];
				item.x = (item.width + Y_SPACE) * i;
			}
		}
		
		private function activateImage( ) : void
		{
			var item : MovieClip = _images[ _curVideo ];
			item.buttonMode = true;
			item.useHandCursor = true;
			item.mouseEnabled = true
			item.mouseChildren = false;
			item.addEventListener( MouseEvent.CLICK, doImageClick );
			item.addEventListener( MouseEvent.MOUSE_OVER, doImageOver );
			item.addEventListener( MouseEvent.MOUSE_OUT, doImageOut );
		}
		
		private function deactivateImage( ) : void
		{
			var item : MovieClip = _images[ _curVideo ];
			item.buttonMode = false;
			item.useHandCursor = false;
			item.mouseEnabled = false
			item.mouseChildren = false;
			item.removeEventListener( MouseEvent.CLICK, doImageClick );
			item.removeEventListener( MouseEvent.MOUSE_OVER, doImageOver );
			item.removeEventListener( MouseEvent.MOUSE_OUT, doImageOut );
		}
		
		private function addImageTitles( ) : void
		{
			var i : uint = 0
			var I : uint = _indicators.length;
			for( i; i < I; i++ )
			{
				var item : MovieClip = _images[i];
				var box : Box = new Box( SiteConstants.WEBCAM_FULL_WIDTH, TITLE_BAR_HEIGHT, 0x000000 );
				box.alpha = TITLE_BAR_ALPHA;
				box.x = 1;
				box.y = item.height - TITLE_BAR_HEIGHT - 1;
				item.addChild( box );
				
				var copy : String = _cm.getPremadeVideoItem( i ).copy;
				var tf : TextField = TextFieldUtil.makeText( copy, ".liPremadeVideoTitle" );
				tf.x =  box.x + ( ( box.width - tf.textWidth ) * .5 );
				tf.y =  box.y + ( ( box.height - tf.textHeight ) * .5 ) - 4;
				item.addChild( tf );
			}
		}
		
		private function updateArrows( ) : void
		{
			if( _curVideo == 0 )
			{
				deactivateStart( arrowL );
				activateStart( arrowR );
			}
			else if( _curVideo == ( _cm.premadeVideos.length - 1 ) )
			{
				activateStart( arrowL );
				deactivateStart( arrowR );
			}
			else
			{
				activateStart( arrowL );
				activateStart( arrowR );
			}
		}
		
		private function updateIndicators( ) : void
		{
			var i : uint = 0
			var I : uint = _indicators.length;
			for( i; i < I; i++ )
			{
				var item : MovieClip = _indicators[i];
				var onLight : MovieClip = item.onLight as MovieClip;
				if( i == _curVideo )
				{
					TweenLite.to( onLight, SiteConstants.TIME_TRANSITION_IN, { alpha: 1 });
				}
				else
				{
					TweenLite.to( onLight, SiteConstants.TIME_OUT, { alpha: 0 });
				}
			}
		}
		
		protected function removeUploader() : void 
		{ 
			trace( "PREMADEVIDEOSELECTOR : removeUploader()" );
			removeChild( imageUploader );
			imageUploader = null;
		}
		
		private function deactivateArrows( ) : void
		{
			deactivateStart( arrowL );
			deactivateStart( arrowR );
		}
		
		private function onImageComplete(  ) : void
		{
//			updateArrows();
			activateImage();
		}
		
		private function playVideo(  ) : void
		{
			if( !contains( _minVid ))	addChild( _minVid );

			addPinwheel();
			
			hideIcons();
			
			frameHolder.alpha = 1;
			
			var url : String = _cm.getPremadeVideoItem( _curVideo ).previewURL;
			_minVid.addEventListener( Event.COMPLETE, onVideoComplete );
			_minVid.addEventListener( Component.EVENT_LOADED, onVideoLoaded );
			_minVid.go( url );
		}
		
		private function hideMinVideo() : void 
		{ 
			if( contains( _minVid ) )
			{
				_minVid.close();
				_minVid.buttonMode = false;
				_minVid.useHandCursor = false;
				_minVid.mouseEnabled = false
				_minVid.mouseChildren = false;
				_minVid.removeEventListener( MouseEvent.CLICK, onMinVidClick );
				removeChild( _minVid );
			}
			frameHolder.alpha = 0;
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

		private function switchToImages() : void
		{
			imageHolder.visible = true;
			activateImage();
			hideMinVideo();
		}
		
		private function addImageUploader() : void
		{
			trace( "PREMADEVIDEOSELECTOR addImageUploader()" );
			imageUploader = new PremadeImageUploader( _curVideo );
			imageUploader.y = UPLOAD_Y;
			addChild( imageUploader );
			imageUploader.addEventListener( Event.COMPLETE, onImageUploaderComplete );
			imageUploader.addEventListener( DialogUploadPhoto.CLOSE_CLICKED, onCloseClicked );
			switchToImages();
		}

		//----------------------------------------------------------------------------
		// event handlers
		//----------------------------------------------------------------------------
		protected function onSelectClicked( e : Event ) : void
		{	
			Metrics.pageView( "inviterPrerecordedSelectButton", "[VIDEO_NUM]", (_curVideo+1).toString() );
			
			trace( "PREMADEVIDEOSELECTOR onSelectClicked() : _curVideo is " + _curVideo)
			addImageUploader();
		}
		
		private function onCloseClicked( e : ExtendedEvent ) : void
		{
			trace( " PREMADEVIDEOSELECTOR : onCloseClicked"  );
			removeUploader();
		}
		
		protected function doItemClick( e : MouseEvent ) : void
		{	
			var offset : uint = classes.width + Y_SPACE;
			var xPos : int;
			var item : MovieClip = e.target as MovieClip;
			var name : String = item.name;
			if( name == "arrowL" )
			{
				_curVideo--;
			}
			else
			{
				_curVideo++;
			}
			xPos = ( FRAME_X + 1 ) - ( offset * _curVideo );
			
			TweenLite.to( imageHolder, SiteConstants.TIME_OVER, { x: xPos, ease: Quad.easeInOut, onComplete: onImageComplete } );
			updateArrows();
			updateIndicators();
			switchToImages();
		}

		protected function onImageUploaderComplete( e : Event ) : void
		{	
			trace( "PREMADEVIDEOSELECTOR onImageUploaderComplete()" );
			imageUploader.removeEventListener( Event.COMPLETE, onImageUploaderComplete );
			removeChild( imageUploader );
			imageUploader = null;
		}
		
		protected function doItemOver( e : MouseEvent ) : void
		{	
			var item : MovieClip = e.target as MovieClip;
			TweenLite.to( item, SiteConstants.TIME_OVER, { alpha: ALPHA_OVER} );
		}

		protected function doItemOut( e : MouseEvent ) : void
		{	
			var item : MovieClip = e.target as MovieClip;
			TweenLite.to( item, SiteConstants.TIME_OVER, { alpha: ALPHA_OUT } );
		}
		
		protected function doImageClick( e : MouseEvent ) : void
		{	
			var item : MovieClip = _images[ _curVideo ];
			imageHolder.visible = false;
			playVideo();
			deactivateImage();

			Metrics.pageView( "inviterPrerecordedPlayButton", "[VIDEO_NUM]", (_curVideo+1).toString() );
		}
		
		protected function doImageOver( e : MouseEvent ) : void
		{	
			var item : MovieClip = _images[ _curVideo ];
			var inner : MovieClip = item.playBtn.inner;
			var arrow : MovieClip = item.playBtn.arrow;
			TweenLite.to( arrow, SiteConstants.TIME_OVER, { alpha: ALPHA_OVER } );
			TweenLite.to( inner, SiteConstants.TIME_OVER, { tint : COLOR_OVER, alpha: ALPHA_OVER } );
		}

		protected function doImageOut( e : MouseEvent ) : void
		{	
			var item : MovieClip = _images[ _curVideo ];
			var inner : MovieClip = item.playBtn.inner;
			var arrow : MovieClip = item.playBtn.arrow;
			TweenLite.to( arrow, SiteConstants.TIME_OVER, { alpha: ALPHA_OUT } )
			TweenLite.to( inner, SiteConstants.TIME_OVER, { tint : COLOR_OUT, alpha: ALPHA_OUT } );
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
			
			hideIcons();
		}
		
		private function onVideoComplete( e : Event ) : void 
		{ 
			_minVid.removeEventListener( Event.COMPLETE, onVideoComplete );
			switchToImages();
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
	}
}
