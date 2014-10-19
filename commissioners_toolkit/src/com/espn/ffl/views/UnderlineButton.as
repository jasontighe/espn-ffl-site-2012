package com.espn.ffl.views
{
	import com.espn.ffl.model.ContentModel;
	import com.espn.ffl.model.dto.CopyDTO;
	import com.greensock.TweenLite;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.text.TextField;
	
	import leelib.util.TextFieldUtil;
	
	public class UnderlineButton extends Sprite
	{
		private var _tf:TextField;

		// copyDto expected to supply styleName
		//
		public function UnderlineButton($copyDto:CopyDTO, $useDropShadow:Boolean, $dropShadowIsInner:Boolean)
		{
			_tf = TextFieldUtil.makeTextWithCopyDto($copyDto);
			this.addChild(_tf);
			
			var x2:Number = _tf.textWidth;
			var y2:Number = _tf.textHeight + 3;
			
			_tf.styleSheet = null;
			
			this.graphics.lineStyle(1, uint(_tf.defaultTextFormat.color), 1.0);
			this.graphics.moveTo(2, y2);
			this.graphics.lineTo(x2+4, y2);
		
			if ($useDropShadow) {
				this.filters = [ new DropShadowFilter(1,270,0x0,0.40,1,1,1,2, $dropShadowIsInner) ];
			}

			this.buttonMode = true;
			this.addEventListener(MouseEvent.CLICK, onClick);
		}
		
		private function onClick(e:*):void
		{
			this.dispatchEvent(new Event(Event.SELECT));
		}
		
		public function show():void
		{
			this.visible = true;

			TweenLite.killTweensOf(this);
			TweenLite.to(this, 0.33, { alpha:1 } );
		}
		
		public function hide():void
		{
			TweenLite.killTweensOf(this);
			TweenLite.to(this, 0.33, { alpha:0, onComplete:function():void{this.visible=false;} } );
		}
	}
}