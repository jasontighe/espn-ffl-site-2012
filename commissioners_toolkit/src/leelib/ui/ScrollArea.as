package leelib.ui
{
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	import leelib.graphics.GrUtil;
	
	// for the nth fucking time
	//
	public class ScrollArea extends Sprite
	{
		public var minThumbHeight:Number = 40;
		
		protected var _scrollBar:Sprite;
		protected var _thumb:Sprite;
		
		protected var _contentMask:Sprite;
		protected var _contentHolder:Sprite;
		
		protected var _width:Number;
		protected var _height:Number;
		protected var _thumbOffsetX:Number;
		protected var _thumbRangeY:Number;
		protected var _thumbHeight:Number;
		protected var _contentRangeY:Number;
		protected var _contentHeight:Number;
		
		public function ScrollArea($width:Number, $height:Number, $thumbOffsetX:Number = 10)
		{
			_width = $width;
			_height = $height;
			_thumbOffsetX = $thumbOffsetX;
			
			_contentMask = GrUtil.makeRect($width, $height, 0xff0000);
			_contentMask.x = 0;
			_contentMask.y = 0;
			this.addChild(_contentMask);

			_contentHolder = new Sprite();
			_contentHolder.x = 0;
			_contentHolder.y = 0;
			this.addChild(_contentHolder);
			
			_contentHolder.mask = _contentMask;

			initScrollBarAndThumb();
			
			// DEBUG:
			// GrUtil.replaceRect(this, _width, _height, 0xfff0f0);
				
			updateAfterContentChange();
		}
		
		protected function initScrollBarAndThumb():void
		{
			_scrollBar = new Sprite();
			_scrollBar.x = _width + _thumbOffsetX;
			_scrollBar.y = 0;
			_scrollBar.buttonMode = true;
			this.addChild(_scrollBar);
			
			_thumb = new Sprite();
			_thumb.x = 0;
			_thumb.y = 0;
			_thumb.buttonMode = true;
			_scrollBar.addChild(_thumb);

			_scrollBar.addEventListener(MouseEvent.CLICK, onScrollBarClick);
			_thumb.addEventListener(MouseEvent.MOUSE_DOWN, onThumbDown);
			_thumb.addEventListener(MouseEvent.CLICK, onThumbClick, false, 1); // get click before _scrollBar
		}
		
		//
		// * This must be called at some point
		//
		public function updateAfterContentChange($explicitContentHeight:Number=NaN):void
		{
			_contentHeight = $explicitContentHeight ? $explicitContentHeight : _contentHolder.height;
			
			_thumbHeight = (_height / _contentHeight) * _height;
			_thumbHeight = Math.max(_thumbHeight, minThumbHeight);
			_thumbRangeY = _height - _thumbHeight;
			_contentRangeY = _contentHeight - _height;
			
			if (_contentRangeY > 0) {
				_scrollBar.visible = true;
				skinThumb(_thumbHeight);
				skinScrollBar(_height);
			}
			else {
				_scrollBar.visible = false;
			}
			
			top(); // ... debatable
		}
		
		public function get contentHolder():Sprite
		{
			return _contentHolder;
		}
		
		public function top():void
		{
			_contentHolder.y = _contentMask.y;
			_thumb.y = 0;
		}

		public function kill():void
		{
			// ...
		}
		
		protected function skinScrollBar($scrollAreaHeight:Number):void
		{
			// Override me.
			GrUtil.replaceRect(_scrollBar, 15, $scrollAreaHeight, 0xff8888);
		}
		
		protected function skinThumb($thumbHeight:Number):void
		{
			// Override me.
			GrUtil.replaceRect(_thumb, 15, $thumbHeight, 0xff0000);
		}
		
		protected function onThumbClick($e:MouseEvent):void
		{
			$e.stopImmediatePropagation(); // prevent onScrollBarClick from happening 
		}
		
		protected function onThumbDown($e:MouseEvent):void
		{
			
			_thumb.startDrag(false, new Rectangle(0, 0, 0, _thumbRangeY));
			
			this.stage.addEventListener(MouseEvent.MOUSE_UP, onThumbDone);
			this.stage.addEventListener(MouseEvent.MOUSE_MOVE, onThumbMove);
		}
		protected function onThumbMove(e:*):void
		{
			var ratio:Number = _thumb.y / _thumbRangeY;
			_contentHolder.y = _contentMask.y  +  (ratio * _contentRangeY * -1); 
		}
		protected function onThumbDone(e:*):void
		{
			this.stage.removeEventListener(MouseEvent.MOUSE_UP, onThumbDone);
			this.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onThumbMove);
			
			_thumb.stopDrag();
		}
		
		protected function onScrollBarClick($e:MouseEvent):void // page up or down
		{
			var ratio:Number;
			
			if ($e.localY < _thumb.y) 
			{
				_contentHolder.y += _height;
				if (_contentHolder.y > 0) _contentHolder.y = 0;
				ratio = Math.abs(_contentHolder.y) / _contentRangeY;
				_thumb.y = ratio * _thumbRangeY; 
			}
			else if ($e.localY > _thumb.y + _thumbHeight) 
			{
				_contentHolder.y -= _height;
				if (_contentHolder.y < -_contentRangeY) _contentHolder.y = -_contentRangeY;
				ratio = Math.abs(_contentHolder.y) / _contentRangeY;
				_thumb.y = ratio * _thumbRangeY; 
			}
		}
	}
}