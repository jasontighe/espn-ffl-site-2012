package com.espn.ffl.views.report_card.views
{
	import com.espn.ffl.util.Assets;
	
	import flash.display.Bitmap;
	import flash.display.GradientType;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	
	import leelib.graphics.GrUtil;
	import leelib.graphics.Scale9BitmapSprite;
	import leelib.ui.ScrollArea;

	public class FflScrollArea extends ScrollArea
	{
		private var _thumbIsGreenNotRed:Boolean;
		
		public function FflScrollArea($width:Number, $height:Number, $thumbIsGreenNotRed:Boolean)
		{
			super($width, $height, 10);
			
			_thumbIsGreenNotRed = $thumbIsGreenNotRed;
			_scrollBar.filters = [ new GlowFilter(0x0, 0.25, 2,2, 2,2) ];
		}
		
		protected override function skinScrollBar($scrollAreaHeight:Number):void
		{
			_scrollBar.graphics.clear();
			_scrollBar.graphics.beginFill(0xe8e4d6);
			_scrollBar.graphics.drawRoundRect(0,0, 7, $scrollAreaHeight, 7,7);
			_scrollBar.graphics.endFill();
		}
		
		protected override function skinThumb($thumbHeight:Number):void
		{
			_thumb.graphics.clear();

			// hit area wider than thumb
			_thumb.graphics.beginFill(0xff0000, 0.0); 
			_thumb.graphics.drawRect(-2,0, 7+4, $thumbHeight);
			_thumb.graphics.endFill();
			
			var m:Matrix = new Matrix();
			m.createGradientBox(7, $thumbHeight, (Math.PI/180)*90, 0, 0);

			if (_thumbIsGreenNotRed) {
				_thumb.graphics.beginGradientFill(GradientType.LINEAR, [0xb5d66f, 0x6c901b], [1,1], [0,255], m);
			}
			else {
				_thumb.graphics.beginGradientFill(GradientType.LINEAR, [0xbd2b3a, 0xd95865], [1,1], [0,255], m);
			}
			_thumb.graphics.drawRoundRect(0,0, 7, $thumbHeight, 7,7);
			_thumb.graphics.endFill();
		}
	}
}