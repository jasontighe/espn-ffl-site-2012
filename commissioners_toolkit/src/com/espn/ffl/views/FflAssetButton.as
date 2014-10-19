package com.espn.ffl.views {
	import com.espn.ffl.constants.SiteConstants;
	import com.espn.ffl.util.FflButtonText;
	import com.espn.ffl.util.FflDropShadow;
	import com.greensock.TweenLite;
	import com.jasontighe.managers.AssetManager;

	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;

	/**
	 * @author jason.tighe
	 */
	public class FflAssetButton 
	extends MovieClip 
	{
		//----------------------------------------------------------------------------
		// public static constants
		//----------------------------------------------------------------------------
		public static const RED_BUTTON						: String = "red";
		public static const GRAY_BUTTON						: String = "gray";
		public static const GREEN_BUTTON					: String = "green";
		//----------------------------------------------------------------------------
		// private variables
		//----------------------------------------------------------------------------
		private var _background								: MovieClip;
		private var _overHolder								: MovieClip;
		private var _outHolder								: MovieClip;
		private var _over									: MovieClip;
		private var _out									: MovieClip;
		private var _isEnabled								: Boolean;
		//----------------------------------------------------------------------------
		// constructor
		//----------------------------------------------------------------------------
		public function FflAssetButton( $assetLinkage : String, 
										$label : String, 
										$cssType : String, 
										$fontSize : uint, 
										$width:Number, 
										$height:Number,
										$useDropShadow : Boolean = false )
		{
			super();
			
			
			_background = MovieClip( AssetManager.gi.getAsset( $assetLinkage, SiteConstants.ASSETS_ID ) );
			addChild( _background );
			
			_outHolder = new MovieClip();
			_overHolder = new MovieClip();
			_background.addChild( _outHolder );
			_background.addChild( _overHolder );
			
			
			_over = _background._over;
			_out = _background._out;
			_over.width = _out.width = $width;
			_over.height = _out.height = $height;
			
			_overHolder.addChild( _over );
			_outHolder.addChild( _out );
			
			var tf : TextField;
			tf = FflButtonText.makeText( $label, $cssType, $fontSize);
			tf.x = int( ( _background.width - tf.width) * 0.5 );
			tf.y = int( ( _background.height - tf.height) * 0.5 ) + 1;
			_outHolder.addChild( tf );
			
			var cssType : String = ".bubbleButtonGrayOver"; // all rollovers use white text;
			
			tf  = FflButtonText.makeText( $label, cssType, $fontSize);
			tf.x = int( ( _background.width - tf.width) * 0.5 );
			tf.y = int( ( _background.height - tf.height) * 0.5 ) + 1;
			if( $cssType == ".bubbleButtonGreen" ) tf.alpha = .5; // GREEN button, white text is alpha .5
			_overHolder.addChild( tf );
			
			if( $useDropShadow ) filters = [ FflDropShadow.getDefault() ];
			
			_overHolder.alpha = 0;
			enable();
		}

		//----------------------------------------------------------------------------
		// public methods
		//----------------------------------------------------------------------------
		public function isEnabled():Boolean
		{
			return _isEnabled;
		}
		
		public function enable():void
		{
			_isEnabled = true;
			this.addEventListener(MouseEvent.ROLL_OVER, onOver);
			this.addEventListener(MouseEvent.ROLL_OUT, onOut);
			this.addEventListener(MouseEvent.CLICK, onClick);
			this.buttonMode = true;
			_overHolder.alpha = 0;
			
		}
		
		public function disable():void
		{
			_isEnabled = false;
			this.removeEventListener(MouseEvent.ROLL_OVER, onOver);
			this.removeEventListener(MouseEvent.ROLL_OUT, onOut);
			this.removeEventListener(MouseEvent.CLICK, onClick);
			this.buttonMode = false;
		}
		
		public function kill():void
		{
			disable();
		}
		
		//----------------------------------------------------------------------------
		// event handlers
		//----------------------------------------------------------------------------
		private function onOver( e : MouseEvent) : void
		{
			TweenLite.to( _overHolder , SiteConstants.TIME_OVER, { alpha: 1 } ); 
		}
		private function onOut( e : MouseEvent ) : void
		{
			TweenLite.to( _overHolder, SiteConstants.TIME_OUT, { alpha: 0 } );
		}
		private function onClick( e : MouseEvent ) : void
		{
			this.dispatchEvent(new Event(Event.SELECT));
		}
	}
}
