package com.espn.ffl.views.inviter.views {
	import leelib.util.TextFieldUtil;

	import com.espn.ffl.constants.SiteConstants;
	import com.espn.ffl.model.ContentModel;
	import com.jasontighe.containers.DisplayContainer;
	import com.jasontighe.managers.AssetManager;

	import flash.display.MovieClip;
	import flash.filters.DropShadowFilter;
	import flash.text.TextField;
	import flash.text.TextFormat;

	/**
	 * @author jason.tighe
	 */
	public class WebcamTimerText 
	extends DisplayContainer 
	{
		//----------------------------------------------------------------------------
		// private static constants
		//----------------------------------------------------------------------------
//		private static const BUTTON_X						: uint = 237;
//		private static const BUTTON_Y						: uint = 10;
		//----------------------------------------------------------------------------
		// private variables
		//----------------------------------------------------------------------------
		private var _cm										: ContentModel = ContentModel.gi;
		//----------------------------------------------------------------------------
		// public variables
		//----------------------------------------------------------------------------
		public var background			 					: MovieClip;
		//----------------------------------------------------------------------------
		// constructor
		//----------------------------------------------------------------------------
		public function WebcamTimerText() 
		{
			super();
			
			background = MovieClip( AssetManager.gi.getAsset( "InviterWebcamTimerAsset", SiteConstants.ASSETS_ID ) );
			addChild( background );
		}
		
		public function makeText( $label : String ) : TextField
		{
			var tf : TextField = new TextField();				  
			tf = TextFieldUtil.makeText( $label, ".liWebcamTimer" );
			tf.styleSheet = null
			
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
