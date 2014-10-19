package com.jasontighe.utils {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.text.TextField;

	/**
	 * @author jason.tighe
	 */
	public class BitmapConverter 
	extends Sprite 
	{
		public static function getBmp(o : DisplayObject, smooth : Boolean = true, drawBox : Boolean = false) : Bitmap
		{
			return convert(o, o.width, o.height, smooth, drawBox);
		}
		
		public static function getBmpText(o : TextField, smooth : Boolean = true, drawBox : Boolean = false) : Bitmap
		{
			return convert(o, o.textWidth, o.textHeight, smooth, drawBox);
		}

		private static function convert(o : DisplayObject, w : int, h : int, smooth : Boolean = true, drawBox : Boolean = false) : Bitmap
		{
			var bmd : BitmapData = new BitmapData(w, h, true, 0x000000);
			bmd.draw(o);
			
			if(drawBox)
			{
				var box : Sprite = new Sprite();
				box.graphics.lineStyle(1, 0xff0000, 1, true);
				box.graphics.drawRect(0,0,w, h);
				bmd.draw(box);
			}
			
			var bmp : Bitmap = new Bitmap(bmd.clone());
			bmp.smoothing = smooth;
			bmd.dispose();
			
			return bmp;
		}
	
	}
}