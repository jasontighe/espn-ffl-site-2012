package com.espn.ffl.views.dialogs
{
	import com.espn.ffl.Shell;
	import com.espn.ffl.constants.SiteConstants;
	import com.espn.ffl.model.ContentModel;
	import com.espn.ffl.model.dto.CopyDTO;
	import com.espn.ffl.util.Assets;
	import com.espn.ffl.views.AbstractView;
	import com.espn.ffl.views.BubbleButton;
	import com.espn.ffl.views.FflButton;
	import com.espn.ffl.views.Main;
	import com.espn.ffl.views.inviter.views.InviterPinwheel;
	import com.greensock.TweenLite;
	import com.greensock.easing.Linear;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import leelib.graphics.GrUtil;
	import leelib.graphics.Scale9BitmapSprite;
	import leelib.ui.Component;
	import leelib.ui.DumbWrapper;
	import leelib.ui.ThreeStateButton;
	import leelib.util.TextFieldUtil;
	import leelib.vid.MinVid;
	import leelib.vid.VidProgressBar;

	
	public class NotLoggedInDialog extends AbstractDialog
	{
		public static const WIDTH:Number = 500;
		public static const HEIGHT:Number = 570;

		private static const VIDEO_W:Number = 420; // 640x407
		private static const VIDEO_H:Number = 236;
		
		private var _chrome:Scale9BitmapSprite;
		private var _okButton:BubbleButton;
		
		// unencapsulated videoplayer logic, duplicated from inviter/Preview.as
		public var _videoArea: Sprite;
			private var _minVid:MinVid;
			private var _progressBar: VidProgressBar;
			private var _playIcon:Bitmap;
			private var _pauseIcon:Bitmap;
			private var _startButtonHit:Sprite;	
			
			private var _pinwheel: Sprite;
			private var _pinwheelInner: MovieClip;

		private var _videoStartedAt:Number;

			
		public function NotLoggedInDialog($yesCallback:Function)
		{
			var dto : CopyDTO = ContentModel.gi.getCopyItemByName( "alertNotLoggedInPageNew" );

			this.yesButtonCallback = $yesCallback;
			this.noButtonCallback = null;
			this.closeButtonCallback = null;
			
			var r:Rectangle = new Rectangle(22,29, 340,160);
			var b:BitmapData = new Assets.DialogBgWithX().bitmapData;
			var bg9:Scale9BitmapSprite = new Scale9BitmapSprite(b, r);
			this.addChild(bg9);
			
			b = new Assets.DialogBgWithXRed9().bitmapData; 
			var redBg9:Scale9BitmapSprite = new Scale9BitmapSprite(b, r);
			redBg9.visible = false;
			this.addChild(redBg9);
			
			this.redBackground = redBg9;
			
			var buttonYes:ThreeStateButton;
			var buttonNo:ThreeStateButton;
			var tfTitle:TextField;
			var tfCopy:TextField;
			
			tfTitle = TextFieldUtil.makeText(dto.title, ".alertDialogTitle");
			tfTitle.x = 35;
			tfTitle.y = 32;
			this.addChild(tfTitle);
	
			initVideoParts();
			
			tfCopy = TextFieldUtil.makeHtmlText(dto.copy, ".notLoggedInCopy", 450);
			tfCopy.x = 35;
			tfCopy.y = 347;
			this.addChild(tfCopy);
			
			var buttonHolder:Sprite = new Sprite();
			buttonHolder.y = HEIGHT - 90;
			this.addChild(buttonHolder);
			
			buttonYes = new BubbleButton(dto.yesLabel);
			buttonYes.x = buttonNo  ?  buttonNo.x + buttonNo.width + 25  :  0;
			buttonHolder.addChild(buttonYes);
			
			// center buttonHolder
			buttonHolder.x = (WIDTH - buttonHolder.width) * .5  -  3;
			
			var close:Sprite;
			close = GrUtil.makeCircle(15, 0xff0000, 0.0);
			close.x = WIDTH + 2;
			close.y = 17;
			close.buttonMode = true;
			this.addChild(close);
			
			bg9.width = WIDTH + 30;
			bg9.height = HEIGHT;
			
			redBg9.width = WIDTH + 30;
			redBg9.height = HEIGHT;
			
			this.dialogWidth = WIDTH;
			this.dialogHeight = HEIGHT + 200; // push it up the screen meh
			
			this.assignButtons(buttonYes, buttonNo, close);
			this.tfCopy = tfCopy; // ?
		}

		private function initVideoParts():void
		{
			_videoArea = GrUtil.makeRect(VIDEO_W+2,VIDEO_H+2, 0x0);
			_videoArea.x = 35;
			_videoArea.y = 77;
			this.addChild(_videoArea);
			
				_minVid = new MinVid();
				_minVid.x = 1;
				_minVid.y = 1;
				_minVid.sizeWidthHeight(VIDEO_W, VIDEO_H);
				_videoArea.addChild(_minVid);
				
					var bb:Component = new DumbWrapper( new Assets.InviterScrubberBg() );
					var lb:Component = new DumbWrapper( new Assets.InviterScrubberLoaded() );
					
					var thumb:Component = new Component();
					var b:Bitmap = new Assets.InviterScrubberThumb();
					b.x = b.width/-2;
					b.y = b.height/-2 + bb.height/2;
					thumb.addChild(b);
					
					_progressBar = new VidProgressBar(bb,lb,thumb, true, VIDEO_W+2, bb.height, false, Shell.stage);
					_progressBar.x = 0;
					_progressBar.y = _minVid.y + VIDEO_H + 0;
					_videoArea.addChild(_progressBar);
					_minVid.progressBar = _progressBar;

				_playIcon = new Assets.EnforcerVideoPlayIcon();
				_playIcon.alpha = 0;
				_videoArea.addChild(_playIcon);
				GrUtil.centerInParent(_playIcon);
				
				_pauseIcon = new Assets.EnforcerVideoPauseIcon();
				_pauseIcon.alpha = 0;
				_videoArea.addChild(_pauseIcon);
				GrUtil.centerInParent(_pauseIcon);
				
				_pinwheel = new Sprite();
				_pinwheel.x = VIDEO_W * .5;
				_pinwheel.y = VIDEO_H * .5;
				_pinwheel.alpha = 0;
				_pinwheel.visible = false;

					_pinwheelInner = new Assets.Pinwheel();
					_pinwheelInner.scaleX = _pinwheelInner.scaleY = 0.66; 
					_pinwheelInner.scaleX = -_pinwheelInner.scaleX; // hah
					_pinwheel.addChild(_pinwheelInner);
				
				_videoArea.addChild( _pinwheel );
			
			_startButtonHit = GrUtil.makeRect(VIDEO_W, VIDEO_H, 0xff0000, 0.0);
			_startButtonHit.x = 0;
			_startButtonHit.y = 0;
			_videoArea.addChild( _startButtonHit );
		}
		
		public override function show(duration:Number=0, delay:Number=0):void
		{
			super.show(duration, delay);
			
			// har
			activateStart();
			onClickToStartPlay(null); 
		}
		
		// video logic:
		
		private function activateStart( ) : void
		{
			_startButtonHit.buttonMode = true;
			_startButtonHit.useHandCursor = true;
			_startButtonHit.mouseEnabled = true
			_startButtonHit.mouseChildren = false;
			_startButtonHit.addEventListener( MouseEvent.CLICK, onClickToStartPlay );
			_startButtonHit.visible = true;
			
			_progressBar.mouseEnabled = _progressBar.mouseChildren = false;
			
			showPlayIcon();
		}
		
		private function deactivateStart( ) : void
		{
			_startButtonHit.removeEventListener( MouseEvent.CLICK, onClickToStartPlay );
			
			_startButtonHit.buttonMode = false;
			_startButtonHit.useHandCursor = false;
			_startButtonHit.mouseEnabled = false
			_startButtonHit.mouseChildren = false;
			_startButtonHit.visible = false;
		}

		private function playVideo(  ) : void
		{
			showPinwheel();
			hideIcons();
			
			var url : String = ContentModel.gi.getCopyItemByName("notLoggedInVideoUrl").copy;
			_minVid.addEventListener( Component.EVENT_LOADED, onVideoLoaded );
			_minVid.go(url);
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
		
		protected function onClickToStartPlay( e : MouseEvent ) : void
		{	
			playVideo();
			deactivateStart();
		}
		
		private function onVideoLoaded( e : Event ) : void 
		{ 
			_minVid.removeEventListener( Component.EVENT_LOADED, onVideoLoaded );
			hidePinwheel();
			
			_minVid.buttonMode = true;
			_minVid.useHandCursor = true;
			_minVid.mouseEnabled = true;
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
		
		private function showPinwheel():void
		{
			TweenLite.killTweensOf(_pinwheel);
			TweenLite.to(_pinwheel, 0.5, { autoAlpha:1 } );
			
			_pinwheelInner.rotation = 0;
			TweenLite.to(_pinwheelInner, 9999, { rotation:9999*360, ease:Linear.easeNone } );
		}
		private function hidePinwheel():void
		{
			TweenLite.killTweensOf(_pinwheel);
			TweenLite.to(_pinwheel, 0.2, { alpha:0, onComplete:function():void{_pinwheel.visible=false;} } );
			
			TweenLite.killTweensOf(_pinwheelInner);
		}
		
		protected override function onYesButton($e:*):void
		{
			_minVid.pause(); // for good measure
			super.onYesButton($e);
		}
		
		public override function hide(duration:Number=0, delay:Number=0):void
		{
			super.hide(duration, delay);
			
			_minVid.pause(); // for good measure
		}
		
		
	}
}
