package leelib.graphics
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.GradientType;
	import flash.display.PixelSnapping;
	import flash.display.Sprite;
	import flash.filters.ColorMatrixFilter;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
	import flash.text.TextField;
	
	public class GradientTextSprite extends Sprite
	{
		private var _tf:TextField;
		private var _colorTop:uint;
		private var _colorBottom:uint;
		private var _ratioTop:int;
		private var _ratioBottom:int;
		
		private var _holder:Sprite;
		private var _mask:Sprite;
		
		
		// Warning -- $tf gets reparented
		public function GradientTextSprite($tf:TextField, $colorTop:uint=0xffffff, $colorBottom:uint=0xbbbbbb, $ratioTop:int=0, $ratioBottom:int=255)
		{
			_tf = $tf;
			_colorTop = $colorTop;
			_colorBottom = $colorBottom;
			_ratioTop = $ratioTop;
			_ratioBottom = $ratioBottom;
			
			_tf.x = 0;
			_tf.y = 0;
			
			_holder = new Sprite();
			this.addChild(_holder);
			
			_mask = new Sprite();
			this.addChild(_mask);
			
			_mask.addChild(_tf);

			_tf.filters = [ new ColorMatrixFilter() ];
			_holder.cacheAsBitmap = true;
			_mask.cacheAsBitmap = true;
			
			_holder.mask = _mask;
			
			
			update();
		}
		
		public function get textField():TextField
		{
			return _tf;
		}

		public function get colorTop():uint
		{
			return _colorTop;
		}
		public function set colorTop($color:uint):void
		{
			_colorTop = $color;
			update();
		}
		
		public function get colorBottom():uint
		{
			return _colorBottom;
		}
		public function set colorBottom($color:uint):void
		{
			_colorBottom = $color;
			update();
		}

		/**
		 * Call this after making any changes to contents of TextField
		 */		
		public function update():void
		{
			var m:Matrix = new Matrix();
			m.createGradientBox(_tf.width, _tf.height, Math.PI/2);
			
			_holder.graphics.clear();
			_holder.graphics.beginGradientFill( GradientType.LINEAR, [_colorTop,_colorBottom], [1,1], [_ratioTop,_ratioBottom], m );
			_holder.graphics.drawRect(0,0, _tf.width, _tf.height);
			_holder.graphics.endFill();
		}

		//
		
		public function toBitmap():Bitmap
		{
			var bmd:BitmapData = new BitmapData(this.width, this.height, true, 0x00);
			bmd.draw(this, null,null,null,null,false);
			
			var bmp:Bitmap = new Bitmap(bmd);
			bmp.smoothing = true;
			return bmp;
		}
	}
}