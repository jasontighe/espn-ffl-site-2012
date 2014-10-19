package com.espn.ffl.util {
	import flash.filters.DropShadowFilter;

	/**
	 * @author jason.tighe
	 */
	public class FflDropShadow  
	{
		public static const DISTANCE					: uint = 5;
		public static const COLOR						: uint = 0x000000;
		public static const BLUR_X						: uint = 9;
		public static const BLUR_Y						: uint = 9;
		public static const QUALITY						: uint = 3;
		public static const ALPHA						: Number = .75;
		
		public static function getDefault() : DropShadowFilter
		{
			var filter : DropShadowFilter = new DropShadowFilter();
			filter.distance = DISTANCE;
			filter.color = COLOR;
			filter.blurX = BLUR_X;
			filter.blurY = BLUR_Y;
			filter.quality = QUALITY;
			filter.alpha = ALPHA;
			//my_mc.filters = [myShadow];
			return filter;
		}
	}
}
