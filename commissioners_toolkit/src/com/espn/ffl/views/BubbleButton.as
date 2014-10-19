package com.espn.ffl.views
{
	import com.greensock.TweenLite;
	
	import flash.display.GradientType;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.filters.DropShadowFilter;
	import flash.geom.Matrix;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import leelib.ui.ThreeStateButton;
	import leelib.util.TextFieldUtil;
	
	public class BubbleButton extends ThreeStateButton
	{
		public static const HEIGHT:Number = 43;
			
		private static const GREEN_OVER_COLOR:uint = 0x70941e;
		private static const GRAY_OVER_COLOR:uint = 0x919191;
		
		private var _off:Sprite;
		private var _over:Sprite;
		private var _disabled:Sprite;
		
		
		public function BubbleButton($label:String, $buttonWidth:Number=NaN, $isGrayNotGreen:Boolean=false)
		{
			// 'off' sprite
			
			_off = new Sprite();
			this.addChild(_off);
			
			var tfOff:TextField = TextFieldUtil.makeText($label, $isGrayNotGreen ? ".bubbleButtonGray" : ".bubbleButtonGreen");
			_off.addChild(tfOff);
			
			if (isNaN($buttonWidth)) {
				$buttonWidth = 20 + tfOff.textWidth + 20;
				if ($buttonWidth < 135) $buttonWidth = 135;
			}
			
			tfOff.x = int(($buttonWidth - tfOff.textWidth)/2);
			tfOff.y = int((HEIGHT - tfOff.textHeight)/2) - 2;
			
			var m:Matrix = new Matrix();
			m.createGradientBox($buttonWidth, HEIGHT, (Math.PI/180)*90, 0, 0);
			var colors:Array = $isGrayNotGreen ? [0xd5d4d4,0x8b8b8b] : [0x719622,0x3f6d2d];
			_off.graphics.beginGradientFill(GradientType.LINEAR, colors, [1,1], [0,255], m);
			_off.graphics.drawRoundRect(0,0, $buttonWidth, HEIGHT, 6,6);
			_off.graphics.endFill();
			
			// 'over' sprite
			
			_over = new Sprite();
			this.addChild(_over);
			
			var tfOver:TextField = TextFieldUtil.makeText($label, $isGrayNotGreen ? ".bubbleButtonGrayOver" : ".bubbleButtonGreenOver");
			_over.addChild(tfOver);
			
			tfOver.x = tfOff.x;
			tfOver.y = tfOff.y;
			
			var overColor:uint = $isGrayNotGreen ? GRAY_OVER_COLOR : GREEN_OVER_COLOR;
			_over.graphics.beginFill(overColor);
			_over.graphics.drawRoundRect(0,0, $buttonWidth, HEIGHT, 6,6);
			_over.graphics.endFill();

			tfOff.filters = tfOver.filters = [ new DropShadowFilter(1,45,0x0,.3,1,1,1,2, true) ];
			this.filters = [ new DropShadowFilter(5,45,0x0,.44,5,5,1,2) ];
		
			_over.alpha = 0;
			
			// 'disabled' sprite - translucent white rect on top 

			_disabled = new Sprite();
			_disabled.graphics.beginFill(0xffffff, 0.35);
			_disabled.graphics.drawRoundRect(0,0, $buttonWidth, HEIGHT, 6,6);
			_disabled.graphics.endFill();
			_disabled.visible = false;
			this.addChild(_disabled);

			super();
		}
		
		public function setDisabled($b:Boolean):void
		{
			if ($b) {
				this.mouseEnabled = this.mouseChildren = false;
				_disabled.visible = true;
				showUnselectedOut();
			}
			else {
				this.mouseEnabled = this.mouseChildren = true;
				_disabled.visible = false;
				_isSelected ? showSelected() : showUnselectedOut();
			}
		}
		
		protected override function showUnselectedOut():void
		{
			TweenLite.to(_over, 0.33, { alpha:0 } );
		}
		
		protected override function showUnselectedOver():void
		{
			TweenLite.to(_over, 0.33, { alpha:1 } );
		}
		
		protected override function showSelected():void
		{
			showUnselectedOver();
		}
	}
}