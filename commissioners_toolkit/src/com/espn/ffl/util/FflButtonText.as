package com.espn.ffl.util {
	import leelib.util.TextFieldUtil;

	import com.espn.ffl.views.FflAssetButton;

	import flash.filters.DropShadowFilter;
	import flash.text.TextField;
	import flash.text.TextFormat;

	/**
	 * @author jason.tighe
	 */
	public class FflButtonText 
	extends TextField 
	{
		//----------------------------------------------------------------------------
		// constructor
		//----------------------------------------------------------------------------
		public function FflButtonText( ) {}

		//----------------------------------------------------------------------------
		// public methods
		//----------------------------------------------------------------------------
		public static function makeText( $label : String, 
										$cssType : String, 
										$fontSize : uint ) : TextField
		{
			var tf : TextField;			  
								  
			tf = TextFieldUtil.makeText( $label, $cssType );
			tf.styleSheet = null;
			
			var f : TextFormat = new TextFormat( null, $fontSize );
			tf.setTextFormat(f);
			
			var dropShadow : DropShadowFilter = new DropShadowFilter();
			dropShadow.distance = 1, 
			dropShadow.angle = 120, 
			dropShadow.color = 0xFFFFFF, 
			dropShadow.alpha = .27, 
			dropShadow.blurX = 0, 
			dropShadow.blurY = 0, 
			dropShadow.strength = 1.0, 
			dropShadow.quality = 2;
			
			var innerDropShadow : DropShadowFilter = new DropShadowFilter();
			innerDropShadow.distance = 1, 
			innerDropShadow.angle = 120, 
			innerDropShadow.color = 0x000000, 
			innerDropShadow.alpha = .18, 
			innerDropShadow.blurX = 0, 
			innerDropShadow.blurY = 0, 
			innerDropShadow.strength = 1.0, 
			innerDropShadow.quality = 2;
			innerDropShadow.inner = true;
			tf.filters = [ dropShadow, innerDropShadow ];
			
			return tf;	
		}
	}
}
