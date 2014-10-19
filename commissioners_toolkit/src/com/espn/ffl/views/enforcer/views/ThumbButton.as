package com.espn.ffl.views.enforcer.views
{
	import com.espn.ffl.util.Assets;
	import com.espn.ffl.views.enforcer.vos.VideoVo;
	import com.greensock.TweenLite;
	
	import flash.display.Bitmap;
	import flash.display.CapsStyle;
	import flash.display.DisplayObject;
	import flash.display.JointStyle;
	import flash.display.Loader;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;
	import flash.text.TextField;
	
	import leelib.graphics.GrUtil;
	import leelib.ui.ThreeStateButton;
	import leelib.util.Out;
	import leelib.util.TextFieldUtil;
	
	
	public class ThumbButton extends ThreeStateButton
	{
		public static const RECT_WIDTH:Number = 151;
		public static const RECT_HEIGHT:Number = 85;
		
		public static const IMAGE_WIDTH:Number = 149;
		public static const IMAGE_HEIGHT:Number = 83;

		private var _bg:Sprite;
		private var _image:Loader;
		private var _overRect:Shape;
		private var _playIcon:Sprite;
		private var _playIconInner:Bitmap;
		
		private var _tf:TextField;
		
		private var _videoVo:VideoVo;
		
		
		public function ThumbButton()
		{
			_bg = GrUtil.makeRect(RECT_WIDTH,RECT_HEIGHT, 0xffffff);
			_bg.graphics.beginFill(0x444444);
			_bg.graphics.drawRect(1,1,IMAGE_WIDTH,IMAGE_HEIGHT);
			_bg.graphics.endFill();
			this.addChild(_bg);
			
			_image = new Loader();
			_image.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onImageIoError);
			_image.contentLoaderInfo.addEventListener(Event.COMPLETE, onImageComplete);
			_image.x = 1;
			_image.y = 1;
			this.addChild(_image);
			
			_playIcon = new Sprite();
			_playIcon.alpha = 0;
			this.addChild(_playIcon);
			GrUtil.centerInParent(_playIcon);

				_playIconInner = new Assets.EnforcerThumbPlayIcon();
				_playIcon.addChild(_playIconInner);
				_playIconInner.x = _playIconInner.width/-2;
				_playIconInner.y = _playIconInner.height/-2;
				_playIconInner.smoothing = true;
			
			_overRect = new Shape();
			_overRect.graphics.lineStyle(6, 0xffffff, 1,false,"normal",CapsStyle.SQUARE,JointStyle.MITER);
			_overRect.graphics.drawRect(3,3, RECT_WIDTH-6, RECT_HEIGHT-6);
			_overRect.alpha = 0;
			this.addChild(_overRect);
			
			_tf = TextFieldUtil.makeText(" ", ".enforcerThumb");
			_tf.y = IMAGE_HEIGHT + 5;
			this.addChild(_tf);
			
			selectEventBubbles = true;
			
			super();
		}
		
		public function get videoVo():VideoVo
		{
			return _videoVo;
		}
		
		public function set videoVo($videoVo:VideoVo):void
		{
			_videoVo = $videoVo;
			_image.load( new URLRequest(_videoVo.thumbPath));
			
			_tf.text = _videoVo.thumbTitle;
			_tf.x = IMAGE_WIDTH*.5 - _tf.width*.5; 
		}
		
		public override function kill():void
		{
			try { _image.close() } catch (e:*) {}
			try { _image.unload() } catch (e:*) {}
		}
		
		protected override function showUnselectedOut():void
		{
			TweenLite.to(_overRect, .25, { alpha:0 } );
			TweenLite.to(_playIcon, .25, { alpha:0, scaleX:1, scaleY:1 } );
		}

		protected override function showUnselectedOver():void
		{
			TweenLite.to(_overRect, .25, { alpha:1 } );
			TweenLite.to(_playIcon, .25, { alpha:1, scaleX:1, scaleY:1 } );
		}
		
		protected override function showSelected():void
		{
			TweenLite.to(_overRect, .25, { alpha:1 } );
			TweenLite.to(_playIcon, .25, { alpha:1, scaleX:.66, scaleY:.66 } );
		}

		private function onImageIoError(e:*):void 
		{
			// meh
		}
		
		private function onImageComplete(e:*):void
		{
			if (_image.width > 0 && _image.height > 0) 
			{
				if (_image.width != IMAGE_WIDTH || _image.height != IMAGE_HEIGHT)
				{
					Out.w("ThumbButton - ASSET IS OF UNEXPECTED DIMENSIONS. RESIZING.");
					_image.width = IMAGE_WIDTH;
					_image.height = IMAGE_HEIGHT;
				}
			}
		}
	
	}
}