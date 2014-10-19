package com.jasontighe.containers {
	import com.jasontighe.managers.CssStyleManager;
	import com.jasontighe.utils.BitmapConverter;

	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;

	/**
	 * @author jason.tighe
	 */
	public class TextContainer 
	extends Sprite 
	{
		//----------------------------------------------------------------------------
		// private variables
		//----------------------------------------------------------------------------
		private var _sm 								: CssStyleManager;
		private var _tf 								: TextField;
		private var _bmp 								: Bitmap;
		private var _asBmp 								: Boolean;
		private var _sharp 								: Number;
		private var _thick 								: Number;
		private var _wrap 								: Boolean;
		private var _style 								: String;
		private var _forceWidth 						: Boolean;
		//----------------------------------------------------------------------------
		// constructor
		//----------------------------------------------------------------------------
		public function TextContainer()
		{
		}
		
		//----------------------------------------------------------------------------
		// public methods
		//----------------------------------------------------------------------------
		public function populate( s : String, 
								  style : String = '', 
								  wrap : Boolean = false,
								  forceWidth : Boolean = false,
								  thick : Number = 0,
								  sharp : Number = 0,
								  asBmp : Boolean = false,
								  border : Boolean = false ) : void
		{
			_sm = CssStyleManager.gi;
			_style = style;
			_wrap = wrap;
			_forceWidth = forceWidth;
			_thick = thick;
			_sharp = sharp;
			_asBmp = asBmp;
			
			tf.htmlText = "init text - need to set label";
			tf.borderColor = 0xff0000;
			tf.border = border;
//			tf.autoSize = TextFieldAutoSize.LEFT;
//			tf.multiline = true;
			update(s);
		}
		
		public function update(s : String, style : String = '') : void
		{
			var newStyle : String = (style == '') ? _style : style;
			
			if(newStyle != '')
			{
				if(_sm.getStyle(newStyle).leading) _sm.setFormat(tf, s, newStyle, _wrap, _forceWidth, _thick, _sharp);
				else _sm.setStyle(tf, s, newStyle, _wrap, _forceWidth, _thick, _sharp);
				
			}
			else tf.htmlText = s;

			if(_asBmp)
			{
				updateBmp();
				addChild(_bmp);
				
				tf.visible = false;
			}
		}
		
		public function updateBmp() : void
		{
			if(_bmp) _bmp.bitmapData.dispose();
			_bmp = BitmapConverter.getBmpText(tf);
		}
		
		//----------------------------------------------------------------------------
		// getters/setters
		//----------------------------------------------------------------------------
		public function get tf() : TextField
		{
			if(!_tf)
			{
				_tf = new TextField();
				addChild(_tf);
			}
			return _tf;
		}
		
		public function get bmp() : Bitmap
		{
			return _bmp;
		}	
	}
}
