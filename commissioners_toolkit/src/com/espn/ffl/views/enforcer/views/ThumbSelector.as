package com.espn.ffl.views.enforcer.views
{
	import com.espn.ffl.util.Assets;
	import com.espn.ffl.views.enforcer.vos.VideoVo;
	import com.greensock.TweenLite;
	
	import flash.display.Sprite;
	import flash.events.Event;
	
	import leelib.graphics.GrUtil;
	
	
	// Structured for flexibility based on not knowing final IA...
	//
	public class ThumbSelector extends Sprite
	{
		private static const MARGIN_H:Number = 13;
		
		private var _holder:Sprite;
		private var _mask:Sprite;
		
		private var _videoVos:Array;
		private var _thumbButtons:Array;
		
		private var _arrowLeft:QuickButton;
		private var _arrowRight:QuickButton;
		
		private var _offsetIndex:int;
		private var _selectedThumbIndex:int = -1;
		
		private var _numVisible:uint;
		private var _visibleWidth:Number;

		
		public function ThumbSelector()
		{
			_numVisible = 4;
			_visibleWidth = _numVisible * ThumbButton.RECT_WIDTH  +  (_numVisible-1) * MARGIN_H;
			
			_holder = new Sprite();
			this.addChild(_holder);
			
			_mask = GrUtil.makeRect(_visibleWidth, 122, 0xff);
			this.addChild(_mask);
			_holder.mask = _mask;

			// note how arrow goes beyond 'bounding box'
			_arrowLeft = new QuickButton(new Assets.EnforcerArrowLeft(), new Assets.EnforcerArrowLeftOver());
			_arrowLeft.overDuration = 0.2;
			_arrowLeft.disabledAlpha = 0.33;
			_arrowLeft.x = -12 - _arrowLeft.width;
			_arrowLeft.y = 24;
			_arrowLeft.addEventListener(Event.SELECT, onArrow);
			this.addChild(_arrowLeft);

			_arrowRight = new QuickButton(new Assets.EnforcerArrowLeft(), new Assets.EnforcerArrowLeftOver());
			_arrowRight.overDuration = 0.2;
			_arrowRight.disabledAlpha = 0.33;
			_arrowRight.x = _visibleWidth + 12;
			_arrowRight.y = 24;
			_arrowRight.addEventListener(Event.SELECT, onArrow);

			_arrowRight.rotation = 180;
			_arrowRight.x += _arrowRight.width;
			_arrowRight.y += _arrowRight.height;
			this.addChild(_arrowRight);
		}
		
		public function reset():void
		{
			_offsetIndex = 0;
			_holder.x = 0;
			
			_arrowLeft.alpha = _arrowLeft.disabledAlpha;
			_arrowLeft.isDisabled = true;
			
			_arrowRight.alpha = 1;
			_arrowRight.isDisabled = false;
		}

		public function setThumbsUsingVideoVos($a:Array):void
		{
			_videoVos = $a; 
			
			while (_holder.numChildren > 0) {  
				_holder.removeChildAt(0);
			}
			
			_thumbButtons = [];
			for (var i:int = 0; i < _videoVos.length; i++)
			{
				var videoVo:VideoVo = _videoVos[i];
				
				var thumbButton:ThumbButton = new ThumbButton();
				thumbButton.videoVo = videoVo;
				_thumbButtons.push(thumbButton);
			}
			
			for (i = 0; i < _thumbButtons.length; i++)
			{
				var tb:ThumbButton = _thumbButtons[i];
				tb.x = (ThumbButton.RECT_WIDTH + MARGIN_H) * i;
				tb.y = 0;
				_holder.addChild(tb);
			}
		}
		
		public function selectByVideoVo($videoVo:VideoVo):void
		{
			for each (var thumb:ThumbButton in _thumbButtons)
			{
				thumb.isSelected = (thumb.videoVo == $videoVo);
			}
		}
		
		private function onArrow($e:Event):void
		{
			_offsetIndex += ($e.target == _arrowRight) ? +1 : -1;
			var tox:Number = _offsetIndex * (ThumbButton.RECT_WIDTH + MARGIN_H) * -1;
			TweenLite.to( _holder, 0.5, { x: tox } );
		
			updateArrows();
		}
		
		private function updateArrows():void
		{
			_arrowLeft.isDisabled = (_offsetIndex <= 0); 
			_arrowRight.isDisabled = (_offsetIndex >= _videoVos.length - _numVisible); 
		}
	}
}
