package com.espn.ffl.views.report_card.views
{
	import com.espn.ffl.util.Assets;
	import com.greensock.TweenLite;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	import leelib.graphics.GrUtil;
	
	public class HelmetButton extends Sprite
	{
		public static const WIDTH:Number = 68;
		public static const HEIGHT:Number = 38;
		
		private var _over:Bitmap;
		
		
		public function HelmetButton()
		{
			GrUtil.makeRect(WIDTH,HEIGHT,0XFF0000);
		
			var b:Bitmap = new Assets.ReportCardHelmetOff() as Bitmap;
			this.addChild(b);
			
			_over = new Assets.ReportCardHelmetOver() as Bitmap;
			_over.alpha = 0;
			this.addChild(_over);
			
			enable();
		}
		
		public function enable():void
		{
			this.addEventListener(MouseEvent.MOUSE_OVER, onOver);
			this.addEventListener(MouseEvent.MOUSE_OUT, onOut);
		}
		public function disable():void
		{
			this.removeEventListener(MouseEvent.MOUSE_OVER, onOver);
			this.removeEventListener(MouseEvent.MOUSE_OUT, onOut);
		}
		
		private function onOver(e:*):void
		{
			showOver();
		}
		
		private function onOut(e:*):void
		{
			showOff();
		}

		public function showOver():void
		{
			TweenLite.killTweensOf(_over);
			TweenLite.to(_over, 0.33, { alpha:1 } );
		}
		
		public function showOff():void
		{
			TweenLite.killTweensOf(_over);
			TweenLite.to(_over, 0.16, { alpha:0 } );
		}
		
		public function kill():void
		{
			disable();
		}
	}
}