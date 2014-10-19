package com.jasontighe.managers {
	import flash.text.AntiAliasType;
	import flash.text.StyleSheet;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;

	/**
	 * @author jason.tighe
	 */
	public class CssStyleManager {
		private static var _instance 			: CssStyleManager;
		private var _sheet 						: StyleSheet;
		
		public function CssStyleManager(e : Enforcer)
		{
			trace( "CSSSTYLEAMANGER : Constr" );
		}
		
		//----------------------------------------------------------------------
		//
		// PUBLIC METHODS
		//
		//----------------------------------------------------------------------
		public function parse(css : String) : void
		{
			_sheet = new StyleSheet();
			_sheet.parseCSS(css);
		}
		
		//----------------------------------------------------------------------
		//
		// GETTERS & SETTERS
		//
		//----------------------------------------------------------------------
		public static function get gi() : CssStyleManager
		{
			if(!_instance) _instance = new CssStyleManager(new Enforcer());
			return _instance;
		}
		
		public function get sheet() : StyleSheet
		{
			// TODO - EXPAND THIS TO GRAB STYLESHEET BASED ON KEY FROM DICTIONARY
			return _sheet;
		}
		
		public static function getHex(s : String) : uint
		{
			if(s.indexOf("#") < 0) trace('BAD HEX VALUE SUPPLIED', s);
			return uint('0x' + s.substring(1, s.length));
		}
	
		public function getStyle(id : String) : Object
		{
			return _sheet.getStyle('.' + id);
		}
		
		public function setStyle(tf : TextField,
								 s : String,
								 id : String, 
								 wrap : Boolean = false,
								 forcedWidth : Boolean = false,
								 thick : Number = 0, 
								 sharp : Number = 0,
								 select : Boolean = false) : void
		{
			// TODO - EXPAND THIS TO GRAB STYLESHEET BASED ON KEY FROM DICTIONARY
			tf.styleSheet = sheet;
			//			tf.border = true;
			tf.multiline = wrap;
			tf.wordWrap = wrap;
			tf.selectable = select;
			tf.embedFonts = true;
			// -200 to 200
			tf.thickness = Number(getStyle(id).thickness) || thick;
			// -400 to 400
			tf.sharpness = Number(getStyle(id).sharpness) || sharp;
			if(!forcedWidth)
			{
				tf.autoSize = TextFieldAutoSize.LEFT;
			}
			tf.antiAliasType = AntiAliasType.ADVANCED;
			tf.htmlText = '<span class="' + id + '">' + s + '</span>';
			
//			trace('\n\n\n\n\n\n----------------------------------------------------------');
//			trace("PlodeStyleManager.setStyle(tf, s, id, wrap, forcedWidth, thick, sharp, select)");
//			trace('tf.htmlText', tf.htmlText);
		}

		public function setFormat(tf : TextField,
								 s : String,
								 id : String, 
								 wrap : Boolean = false,
								 forcedWidth : Boolean = false,
								 thick : Number = 0, 
								 sharp : Number = 0,
								 select : Boolean = false) : void
		{
//			tf.border = true;
			tf.multiline = wrap;
			tf.wordWrap = wrap;
			tf.selectable = select;
			tf.embedFonts = true;
			// -200 to 200
			tf.thickness = Number(getStyle(id).thickness) || thick;
			// -400 to 400
			tf.sharpness = Number(getStyle(id).sharpness) || sharp;
			if(!forcedWidth)
			{
				tf.autoSize = TextFieldAutoSize.LEFT;
			}
			tf.antiAliasType = AntiAliasType.ADVANCED;
			tf.htmlText = '<span class="' + id + '">' + s + '</span>';
			tf.setTextFormat(getFormatFromStyle(id));
		}
		
		public function getFormatFromStyle(styleId : String) : TextFormat
		{
			var style : Object = getStyle(styleId);
			var format : TextFormat = new TextFormat();
			format.align = style.textAlign;
			format.color = getHex(style.color);
			format.font = style.fontFamily;
			format.kerning = Number(style.letterSpacing);
			if(style.leading) format.leading = Number(style.leading);
			format.size = Number(style.fontSize);
			
			return format;
		}
		
	}
}

class Enforcer{}