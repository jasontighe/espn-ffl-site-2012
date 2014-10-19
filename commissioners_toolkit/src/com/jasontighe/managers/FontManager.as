package com.jasontighe.managers {
	import flash.display.MovieClip;
	import flash.events.EventDispatcher;
	import flash.text.Font;
	import flash.utils.Dictionary;

	/**
	 * @author jason.tighe
	 */
	public class FontManager 
	extends EventDispatcher 
	{
		//----------------------------------------------------------------------------
		// private static variables
		//----------------------------------------------------------------------------
		private static var _instance 						: FontManager;
		//----------------------------------------------------------------------------
		// private variables
		//----------------------------------------------------------------------------
		private var _fonts 									: Dictionary;
		//----------------------------------------------------------------------------
		// constructor
		//----------------------------------------------------------------------------
		public function FontManager(e : FontManagerEnforcer) { }
		
		//----------------------------------------------------------------------------
		// public methods
		//----------------------------------------------------------------------------
		public function add(id : String, font : MovieClip) : void
		{
			trace( "FONTMANAGER: add() : id is "+id+" : font is "+font );
			if(!_fonts) _fonts = new Dictionary();
			if(_fonts[id] == null)
			{
				_fonts[id] = font;
			}
			else new Error( "THIS FONT HAS ALREADY BEEN ADDED" );

			traceLoadedFonts();
		}
		
		//----------------------------------------------------------------------------
		// private methods
		//----------------------------------------------------------------------------
		private function traceLoadedFonts() : void
		{
			var embeddedFonts : Array = Font.enumerateFonts( false );
			embeddedFonts.sortOn( "fontName", Array.CASEINSENSITIVE );
			for (var i:String in embeddedFonts)
			{
				trace( "FONTMANAGER:", embeddedFonts[i].fontName );
			}		
		}
		
		//----------------------------------------------------------------------------
		// getters/setters
		//----------------------------------------------------------------------------
		public static function get gi() : FontManager
		{
			if(!_instance) _instance = new FontManager(new FontManagerEnforcer());
			return _instance;
		}
	

	}
}

class FontManagerEnforcer{}