package com.espn.ffl.views.touts {
	import com.espn.ffl.constants.SiteConstants;
	import com.espn.ffl.model.ConfigModel;
	import com.espn.ffl.model.ContentModel;
	import com.espn.ffl.model.LeagueModel;
	import com.espn.ffl.model.StateModel;
	import com.espn.ffl.model.events.FflButtonEvent;
	import com.espn.ffl.util.FflDropShadow;
	import com.espn.ffl.util.Metrics;
	import com.espn.ffl.views.FflButton;
	import com.espn.ffl.views.Main;
	import com.greensock.TweenLite;
	import com.greensock.easing.Elastic;
	import com.greensock.easing.Quad;
	import com.jasontighe.managers.AssetManager;
	import com.jasontighe.utils.Box;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	import leelib.util.TextFieldUtil;

	/**
	 * @author jason.tighe
	 */
	public class EnforcerTout 
	extends AbstractTout 
	{
		//----------------------------------------------------------------------------
		// private static constants
		//----------------------------------------------------------------------------
		private static const BUTTON_WIDTH					: uint = 261;
		private static const BUTTON_HEIGHT					: uint = 47;
		private static const BUTTON_SIZE					: uint = 23;
		//----------------------------------------------------------------------------
		// private variables
		//----------------------------------------------------------------------------
		private var _cm										: ContentModel = ContentModel.gi;
		private var _positions								: Array = new Array();
		private var _positionItems							: Array = new Array();
		//----------------------------------------------------------------------------
		// public variables
		//----------------------------------------------------------------------------
		public var theTxt										: MovieClip;
		public var enforcerTxt									: MovieClip;
//		public var apostropheLTxt								: MovieClip;
//		public var apostropheRTxt								: MovieClip;
		public var videoBtn										: MovieClip;
		public var ditka										: MovieClip;
//		public var video										: MovieClip;
		//----------------------------------------------------------------------------
		// constructor
		//----------------------------------------------------------------------------
		public function EnforcerTout() 
		{
			super();
		}
		
		//----------------------------------------------------------------------------
		// public methods
		//----------------------------------------------------------------------------
		
		//----------------------------------------------------------------------------
		// protected methods
		//----------------------------------------------------------------------------
		protected override function addViews() : void 
		{ 
			var asset : MovieClip = MovieClip( AssetManager.gi.getAsset( "EnforcerTout", SiteConstants.ASSETS_ID ) );
			addChild( asset );
			
			theTxt = asset.theTxt;
			enforcerTxt = asset.enforcerTxt;
//			apostropheLTxt = asset.apostropheLTxt;
//			apostropheRTxt = asset.apostropheRTxt;
			videoBtn = asset.videoBtn;
//			video = asset.video;
			background = asset.background;
			ditka = asset.ditka;
			
			var masker : Box = new Box( asset.width, asset.height );
			addChild( masker );
			asset.mask = masker;
			
			var tf : TextField = TextFieldUtil.makeHtmlTextWithCopyDto( _cm.getCopyItemByName("toutEFDesc"), 380, 80 );
			addChild( tf );
			tf.filters = [ FflDropShadow.getDefault() ];
			
			tf = TextFieldUtil.makeTextWithCopyDto( _cm.getCopyItemByName("toutEFDemo"));
			addChild( tf );
			tf.filters = [ FflDropShadow.getDefault() ];
		
			var copy : String = _cm.getCopyItemByName( "toutEFButton" ).copy;
			var fflButton : FflButton = new FflButton( copy, BUTTON_WIDTH, BUTTON_HEIGHT, BUTTON_SIZE, FflButton.BACKGROUNDTYPE_GREEN, false );
			fflButton.x = _cm.getCopyItemByName( "toutEFButton" ).xPos;
			fflButton.y = _cm.getCopyItemByName( "toutEFButton" ).yPos;
			addChild( fflButton );
			
			_positionItems = [ theTxt, enforcerTxt ];
			for( var i : uint = 0; i < _positionItems.length; i++ )
			{
				var item : MovieClip = _positionItems[ i ];
				_positions.push( [ item.x, item.y ] );
			}
			
			
			fflButton.addEventListener( Event.SELECT, onButtonClicked );
			fflButton.addEventListener( FflButtonEvent.FFL_OVER, doAnimationOver );	
			fflButton.addEventListener( FflButtonEvent.FFL_OUT, doAnimationOut );	
			
			videoBtn.buttonMode = true;
			videoBtn.useHandCursor = true;
			videoBtn.mouseEnabled = true;
			videoBtn.mouseChildren = false;
			videoBtn.addEventListener( MouseEvent.CLICK, doVideoClicked );
			videoBtn.addEventListener( MouseEvent.MOUSE_OVER, doVideoOver );	
			videoBtn.addEventListener( MouseEvent.MOUSE_OUT, doVideoOut );	
		}
		
		protected function doVideoClicked( e : MouseEvent ) : void 
		{
			if (ConfigModel.gi.isOnNotLoggedInPage) {
				Main.instance.showNotLoggedInPageDialog();
				return;
			}
			
			if( LeagueModel.gi.isCommissioner )
			{
				videoBtn.removeEventListener( MouseEvent.CLICK, doVideoClicked );
				StateModel.gi.state = StateModel.STATE_ENFORCER;	
				
				Main.instance.updateQuickNav( _id );
			}
			else
			{
				Main.instance.showNotCommissionerDialog();
			}
		}
		protected function doVideoOver( e : MouseEvent ) : void 
		{
			doAnimationOver();
		}
		protected function doVideoOut( e : MouseEvent ) : void 
		{
			doAnimationOut();
		}
		
		
		protected override function doAnimationOver( e : FflButtonEvent = null ) : void 
		{
			resetAssets();
			
			var scale : Number;
			var xPos : int;
			var yPos : int;
			var time : Number = SiteConstants.TIME_TRANSITION_IN;

			var offset : uint = 40;
//			trace( "INVITERTOUT : doAnimationOver() : xPos is "+xPos );
			var delay : Number = time * .85;
			var blur : uint = 30;
			TweenLite.from( theTxt, time, { alpha: 0, y: -theTxt.height, blurFilter: { blurY: blur }, delay: delay, ease: Elastic.easeOut } );
			
			scale = 3;
			xPos = enforcerTxt.x + ( ( enforcerTxt.width - ( enforcerTxt.width * scale ) ) * .5 );
			yPos = enforcerTxt.y + ( ( enforcerTxt.height - ( enforcerTxt.height * scale ) ) * .5 );
			TweenLite.from( enforcerTxt, time, { alpha: 0, x: xPos, y: yPos,  scaleX: scale, scaleY: scale, ease: Quad.easeIn } );
//			
//			icon.alpha = 0;
			scale = 1.25;
			xPos = -40;
			yPos = ( ditka.height - ( ditka.height * scale ) ) * .5;
			TweenLite.to( ditka, time, { x: xPos, y: yPos, scaleX: scale, scaleY: scale, alpha: 1, ease: Quad.easeInOut } );

			scale = 1.05;
			xPos = ( background.width - ( background.width * scale ) ) * .5;
			yPos = ( background.height - ( background.height * scale ) ) * .5;
			TweenLite.to( background, time * 2, { x: xPos, y: yPos, scaleX: scale, scaleY: scale, ease: Quad.easeOut } );
		}

		protected override function doAnimationOut( e : FflButtonEvent = null ) : void 
		{
			var time : Number = SiteConstants.TIME_TRANSITION_OUT;
			TweenLite.to( background, time, { x: 0, y: 0, scaleX: 1, scaleY: 1, ease: Quad.easeOut } );
			TweenLite.to( ditka, time * 1.25, { x: 0, y: 0, scaleX: 1, scaleY: 1, ease: Quad.easeOut } );
		}
		
		protected function resetAssets( ) : void 
		{
			for( var i : uint = 0; i < _positionItems.length; i++ )
			{
				var item : MovieClip = _positionItems[ i ];
				item.alpha = 1;
				item.x = _positions[ i ][ 0 ];
				item.y = _positions[ i ][ 1 ];
				item.scaleX = item.scaleY = 1;
				TweenLite.to( item, 0, { blurFilter: { blurX: 0, blurY: 0  } } );
			}
		}
		
		//----------------------------------------------------------------------------
		// event handlers
		//----------------------------------------------------------------------------
		protected function onButtonClicked( e : Event = null ) : void
		{	
			if (ConfigModel.gi.isOnNotLoggedInPage) {
				Main.instance.showNotLoggedInPageDialog();
				return;
			}
			
			if( LeagueModel.gi.isCommissioner )
			{
				var button : FflButton = e.target as FflButton;
				button.removeEventListener( Event.SELECT, onButtonClicked );
				button.kill();
				StateModel.gi.state = StateModel.STATE_ENFORCER;	
				
				Main.instance.updateQuickNav( _id );
				
				Metrics.pageView("homeEnforcerButton");
			}
			else
			{
				Main.instance.showNotCommissionerDialog();
			}
		}
	}
}
