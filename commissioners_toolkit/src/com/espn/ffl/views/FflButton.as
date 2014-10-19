package com.espn.ffl.views {
	import leelib.graphics.GrUtil;
	import leelib.ui.ThreeStateButton;
	import leelib.util.TextFieldUtil;

	import com.espn.ffl.model.events.FflButtonEvent;
	import com.espn.ffl.util.Assets;
	import com.greensock.TweenLite;

	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.filters.DropShadowFilter;
	import flash.text.TextField;
	import flash.text.TextFormat;

	// 'setDisabled' untested..
	//
	public class FflButton extends ThreeStateButton
	{
		public static const BACKGROUNDTYPE_GREEN:uint = 0;
		public static const BACKGROUNDTYPE_GRAY:uint = 1;
		public static const BACKGROUNDTYPE_RED:uint = 2;
		public static const BACKGROUNDTYPE_BLUE:uint = 3;

		private static const GREEN_OVER_COLOR:uint = 0x70941e;
		private static const GRAY_OVER_COLOR:uint = 0x919191;
		private static const RED_OVER_COLOR:uint = 0xbd2a39;
		private static const BLUE_OVER_COLOR:uint = 0x0c71d2;
		
		private static const OUTERRECT_THICKNESS:Number = 3.0;
		
		private var _offRect:DisplayObject;
		private var _overRect:DisplayObject;
		private var _tf:TextField;
		private var _disabled:Sprite;
		

		/**
		 * $width and $height includes the light gray outer rounded rect
		 */
		public function FflButton($label:String, $width:Number, $height:Number, $fontSize:Number, $backgroundType:uint, $useWiderLetterSpacing:Boolean)
		{
			// outer rect
			
			this.graphics.beginFill(0xffffff, 0.35);
			this.graphics.drawRoundRect(0,0, $width, $height, OUTERRECT_THICKNESS*2, OUTERRECT_THICKNESS*2);
			this.graphics.endFill();
			this.graphics.beginFill(0x000000, 1.0); // 'inner' part of rect is black
			this.graphics.drawRect(OUTERRECT_THICKNESS,OUTERRECT_THICKNESS, $width-OUTERRECT_THICKNESS*2, $height-OUTERRECT_THICKNESS*2);
			this.graphics.endFill();
			
			// gradient shape
			
			switch ($backgroundType)
			{
				case BACKGROUNDTYPE_GRAY:
					_offRect = new Assets.GradientGray();
					_overRect = GrUtil.makeRect($width,$height, GRAY_OVER_COLOR);
					break;
				case BACKGROUNDTYPE_RED:
					_offRect = new Assets.GradientRed();
					_overRect = GrUtil.makeRect($width,$height, RED_OVER_COLOR);
					break;
				case BACKGROUNDTYPE_BLUE:
					_offRect = new Assets.GradientBlue();
					_overRect = GrUtil.makeRect($width,$height, BLUE_OVER_COLOR);
					break;
				case BACKGROUNDTYPE_GREEN:
				default:
					_offRect = new Assets.GradientGreen();
					_overRect = GrUtil.makeRect($width,$height, GREEN_OVER_COLOR);
					break;
			}
			
			_offRect.width = $width - OUTERRECT_THICKNESS*2;
			_offRect.height = $height - OUTERRECT_THICKNESS*2;
			_offRect.x = OUTERRECT_THICKNESS;
			_offRect.y = OUTERRECT_THICKNESS;
			this.addChild(_offRect);
			
			_overRect.width = _offRect.width;
			_overRect.height = _offRect.height;
			_overRect.x = _offRect.x;
			_overRect.y = _offRect.y;
			_overRect.alpha = 0;
			this.addChild(_overRect);
			
			_overRect.rotation = 180; // (turn gradientOver upside-down)
			_overRect.x += _overRect.width;
			_overRect.y += _overRect.height;
			
			// textfield
			
			var s:String = $useWiderLetterSpacing ? ".roundRectButtonWider" : ".roundRectButton";
			_tf = TextFieldUtil.makeText($label, ".roundRectButton");
			_tf.styleSheet = null;
			var f:TextFormat = new TextFormat(null, $fontSize);
			_tf.setTextFormat(f); // ha
			
			_tf.x = int( ($width - _tf.width) * 0.5 );
			_tf.y = int( ($height - _tf.height) * 0.5 ) + 1;
			this.addChild(_tf);
			
			// 'disabled' sprite - translucent white rect on top 
			
			_disabled = new Sprite();
			_disabled.graphics.beginFill(0xffffff, 0.35);
			_disabled.graphics.drawRect(OUTERRECT_THICKNESS,OUTERRECT_THICKNESS, $width - OUTERRECT_THICKNESS*2, $height - OUTERRECT_THICKNESS*2);
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
			_tf.filters = [ new DropShadowFilter(1.0,45,0x0,0.33,1.0,1.0,2,2) ];
			TweenLite.to(_overRect, 0.33, { alpha:0 } );
			dispatchEvent( new FflButtonEvent( FflButtonEvent.FFL_OUT, false ) );
		}
		
		protected override function showUnselectedOver():void
		{
			_tf.filters = [ new DropShadowFilter(1.0,33,0x0,0.33,0,0,1,2,  true) ];
			TweenLite.to(_overRect, 0.33, { alpha:1 } );
			dispatchEvent( new FflButtonEvent( FflButtonEvent.FFL_OVER, false ) );
		}
		
		protected override function showSelected():void
		{
			showUnselectedOver();
		}
	}
}
