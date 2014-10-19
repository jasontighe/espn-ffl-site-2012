package com.espn.ffl.views.enforcer.views 
{
	import com.espn.ffl.util.Assets;
	import com.espn.ffl.views.enforcer.vos.VideoVo;
	import com.greensock.TweenLite;
	
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.errors.IOError;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	
	import leelib.graphics.GrUtil;
	import leelib.vid.MinVid;

	public class EnforcerVideo extends Sprite
	{
		public static const WIDTH:Number = 642;
		public static const HEIGHT:Number = 362;
		public static const VIDEO_WIDTH:Number = 640;
		public static const VIDEO_HEIGHT:Number = 360;

		// not directly tied to MinVid state. mehs. 
		private static const STATE_NONE:String = "none";
		private static const STATE_SELECTEDBUTPAUSED:String = "selectedButPaused";
		private static const STATE_PLAYING:String = "playing";
		private static const STATE_PAUSED:String = "paused";
		private static const STATE_ATEND:String = "atend";
		
		private var _minVid:MinVid;
		private var _loaderPlacementImage:Loader;

		private var _playIcon:Bitmap;
		private var _pauseIcon:Bitmap;
		
		private var _videoVo:VideoVo;
		private var _state:String = STATE_NONE;
		
		
		public function EnforcerVideo($placementImageUrl:String)
		{
			GrUtil.replaceRect(this, WIDTH,HEIGHT,0xffffff);
			this.graphics.beginFill(0x0);
			this.graphics.drawRect(1,1,VIDEO_WIDTH,VIDEO_HEIGHT);
			this.graphics.endFill();
			
			_minVid = new MinVid();
			_minVid.sizeWidthHeight(VIDEO_WIDTH, VIDEO_HEIGHT);
			_minVid.x = 1;
			_minVid.y = 1;
			this.addChild(_minVid);
			
			_loaderPlacementImage = new Loader();
			_loaderPlacementImage.x = 1;
			_loaderPlacementImage.y = 1;
			_loaderPlacementImage.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onLoaderError);
			_loaderPlacementImage.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoaderComplete);
			_loaderPlacementImage.load(new URLRequest($placementImageUrl));
			this.addChild(_loaderPlacementImage);
			
			_playIcon = new Assets.EnforcerVideoPlayIcon();
			_playIcon.alpha = 0;
			this.addChild(_playIcon);
			GrUtil.centerInParent(_playIcon);
			
			_pauseIcon = new Assets.EnforcerVideoPauseIcon();
			_pauseIcon.alpha = 0;
			this.addChild(_pauseIcon);
			GrUtil.centerInParent(_pauseIcon);
			
			// states:
			// startup state - hasn't played anything yet but a video is 'selected'
			// is playing
			// is paused
			// is at a end of video
		}
		
		private function onLoaderError(e:*):void
		{
			// ignore
			trace('error');
			_loaderPlacementImage.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onLoaderError);
			_loaderPlacementImage.contentLoaderInfo.removeEventListener(Event.COMPLETE, onLoaderComplete);
		}
		
		private function onLoaderComplete(e:*):void
		{
			trace('complete');
			_loaderPlacementImage.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onLoaderError);
			_loaderPlacementImage.contentLoaderInfo.removeEventListener(Event.COMPLETE, onLoaderComplete);

			_loaderPlacementImage.content.width = VIDEO_WIDTH;
			_loaderPlacementImage.content.height = VIDEO_HEIGHT;
			if (_loaderPlacementImage.content is Bitmap) Bitmap(_loaderPlacementImage.content).smoothing = true; // meh 
		}
		
		public function activate():void
		{
			this.addEventListener(MouseEvent.ROLL_OVER, onOver);
			this.addEventListener(MouseEvent.ROLL_OUT, onOut);
			this.addEventListener(MouseEvent.CLICK, onClick);
			_minVid.addEventListener(Event.COMPLETE, onVideoComplete);
			
			_loaderPlacementImage.visible = true;
		}
		
		public function deactivate():void
		{
			_minVid.close();
			this.removeEventListener(MouseEvent.ROLL_OVER, onOver);
			this.removeEventListener(MouseEvent.ROLL_OUT, onOut);
			this.removeEventListener(MouseEvent.CLICK, onClick);
			_minVid.removeEventListener(Event.COMPLETE, onVideoComplete);
		}
		
		public function play($videoVo:VideoVo, $dontAutoPlay:Boolean):void
		{
			_videoVo = $videoVo;
			
			_minVid.go(_videoVo.videoFullPath, false, ! $dontAutoPlay);
			
			// http://leetest.s3.amazonaws.com/final_95588721_85.flv
			// http://AKIAITDMF2HBDOXP6S4Q:Ul18uiOnokPSCjL8xkQqIIa7%2FTc9UnKGc1X2VuVm@leetest.s3.amazonaws.com/final_95588721_85.flv

			setStateTo($dontAutoPlay ? STATE_SELECTEDBUTPAUSED : STATE_PLAYING); 
		}
		
		private function setStateTo($s:String):void
		{
			_state = $s;

			this.buttonMode = (_state != STATE_NONE);
			
			switch (_state)
			{
				case STATE_SELECTEDBUTPAUSED:
					showPlayIcon();
					break;

				case STATE_PLAYING:
					_loaderPlacementImage.visible = false;
					_minVid.resume();
					hideIcons();
					break;
				
				case STATE_PAUSED:
					_minVid.pause();
					showPlayIcon();
					break;

				case STATE_ATEND:
					showPlayIcon();
					break;
			}
		}
		
		private function hideIcons():void
		{
			TweenLite.to(_playIcon, 0.25, { alpha:0 } );
			TweenLite.to(_pauseIcon, 0.25, { alpha:0 } );
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
		
		private function onVideoComplete(e:*):void
		{
			setStateTo(STATE_ATEND);
		}
		
		private function onOver(e:*):void
		{
			switch (_state) 
			{
				case STATE_SELECTEDBUTPAUSED:
				case STATE_PAUSED:
				case STATE_ATEND:
					showPlayIcon();
					break;

				case STATE_PLAYING:
					showPauseIcon();
					break;
			}
		}
		
		private function onOut(e:*):void
		{
			if (_state == STATE_PLAYING) hideIcons();
		}

		private function onClick(e:*):void
		{
			switch (_state) 
			{
				case STATE_SELECTEDBUTPAUSED:
				case STATE_PAUSED:
					setStateTo(STATE_PLAYING);
					break;
				
				case STATE_PLAYING:
					setStateTo(STATE_PAUSED);
					break;
				
				case STATE_ATEND:
					_minVid.play();
					setStateTo(STATE_PLAYING);
					break;
			}
		}
	}
}
