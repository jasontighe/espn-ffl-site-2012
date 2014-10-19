package com.espn.ffl.util
{
	import flash.text.Font;
	import flash.text.StyleSheet;
	import flash.utils.ByteArray;
	
	import leelib.util.TextFieldUtil;

	/**
	 * Static class.
	 * Holds site's stylesheet.
	 * Call init() before using.
	 */
	public class Styles
	{
		// Embedded font files
		
		[Embed(source="./../../../../../embeds_fonts/Stratum2-Black.otf", fontName="Stratum2Black", mimeType="application/x-font", advancedAntiAliasing="true", embedAsCFF="false")]
		public static var FontStratum2Black:Class;

		[Embed(source="./../../../../../embeds_fonts/Stratum2-Bold.otf", fontName="Stratum2Bold", mimeType="application/x-font", advancedAntiAliasing="true", embedAsCFF="false")]
		public static var FontStratum2Bold:Class;
		
		[Embed(source="./../../../../../embeds_fonts/Stratum2-Medium.otf", fontName="Stratum2Medium", mimeType="application/x-font", advancedAntiAliasing="true", embedAsCFF="false")]
		public static var FontStratum2Medium:Class;
		
		[Embed(source="./../../../../../embeds_fonts/DroidSansPro.ttf", fontName="DroidSansPro", mimeType="application/x-font", advancedAntiAliasing="true", embedAsCFF="false")]
		public static var FontDroidSansPro:Class;
		
		[Embed(source="./../../../../../embeds_fonts/DroidSansPro-Bold.ttf", fontName="DroidSansProBold", mimeType="application/x-font", advancedAntiAliasing="true", embedAsCFF="false")]
		public static var FontDroidSansProBold:Class;
		
		[Embed(source="./../../../../../embeds_fonts/BlenderPro-Heavy.otf", fontName="BlenderProHeavy", mimeType="application/x-font", advancedAntiAliasing="true", embedAsCFF="false")]
		public static var FontBlenderProHeavy:Class;
		
		[Embed(source="./../../../../../embeds_fonts/BlenderPro-Medium.otf", fontName="BlenderProMedium", mimeType="application/x-font", advancedAntiAliasing="true", embedAsCFF="false")]
		public static var FontBlenderProMedium:Class;
		
		[Embed(source="./../../../../../embeds_fonts/BlenderPro-MediumItalic.otf", fontName="BlenderProMedium", fontStyle="italic", mimeType="application/x-font", advancedAntiAliasing="true", embedAsCFF="false")]
		public static var FontBlenderProMediumItalic:Class;

		[Embed(source="./../../../../../embeds_fonts/BlenderPro-Book.otf", fontName="BlenderProBook", mimeType="application/x-font", advancedAntiAliasing="true", embedAsCFF="false")]
		public static var FontBlenderProBook:Class;

		
		private static var _styles:StyleSheet;
		
		
		public function Styles()
		{
		}
		
		public static function initWith($cssString:String):void
		{
			var a:Array = [	FontStratum2Black,FontStratum2Bold,FontStratum2Medium,
							FontBlenderProHeavy,FontBlenderProMedium,FontBlenderProBook,
							FontDroidSansProBold];
			
			for each (var font:Class in a) {
				Font.registerFont(font);
			}
			
			// var ba:ByteArray = new CssTextFile() as ByteArray;
			// var string:String = ba.readMultiByte(ba.length, "iso-8859-01");
			_styles = new StyleSheet();
			_styles.parseCSS($cssString);
			
			TextFieldUtil.defaultStyleSheet = _styles; // (for Lee)
		}
		
		public static function get styles():StyleSheet
		{
			return _styles;
		}
	}
}
