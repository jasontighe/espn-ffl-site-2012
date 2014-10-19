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
	import com.greensock.easing.Bounce;
	import com.greensock.easing.Quad;
	import com.jasontighe.managers.AssetManager;
	import com.jasontighe.utils.Box;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.text.TextField;
	
	import leelib.util.TextFieldUtil;

	/**
	 * @author jason.tighe
	 */
	public class InviterTout 
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
		public var leagueTxt								: MovieClip;
		public var inviterTxt								: MovieClip;
		public var icon										: MovieClip;
		public var videoBtn									: MovieClip;
		public var video									: MovieClip;
		//----------------------------------------------------------------------------
		// constructor
		//----------------------------------------------------------------------------
		public function InviterTout() 
		{
			super();
		}
		
		//----------------------------------------------------------------------------
		// protected methods
		//----------------------------------------------------------------------------
		protected override function addViews() : void
		{ 
			var asset : MovieClip = MovieClip( AssetManager.gi.getAsset( "InviterTout", SiteConstants.ASSETS_ID ) );
			addChild( asset );
			
			var masker : Box = new Box( asset.width, asset.height );
			addChild( masker );
			
			asset.mask = masker;
			
			leagueTxt = asset.leagueTxt;
			inviterTxt = asset.inviterTxt;
			icon = asset.icon;
			videoBtn = asset.videoBtn;
			video = asset.video;
			background = asset.background;
			
			_positionItems = [ leagueTxt, icon, inviterTxt];
			for( var i : uint = 0; i < _positionItems.length; i++ )
			{
				var item : MovieClip = _positionItems[ i ];
				_positions.push( [ item.x, item.y ] );
			}
			
			var tf : TextField = TextFieldUtil.makeHtmlTextWithCopyDto( _cm.getCopyItemByName("toutLIDesc"), 400, 200 );
			addChild( tf );
			tf.filters = [ FflDropShadow.getDefault() ];
		
			var copy : String = _cm.getCopyItemByName( "toutLIButton" ).copy;
			var fflButton : FflButton = new FflButton( copy, BUTTON_WIDTH, BUTTON_HEIGHT, BUTTON_SIZE, FflButton.BACKGROUNDTYPE_GREEN, false );
			fflButton.x = _cm.getCopyItemByName( "toutLIButton" ).xPos;
			fflButton.y = _cm.getCopyItemByName( "toutLIButton" ).yPos;
			addChild( fflButton );
			
			
			fflButton.addEventListener( Event.SELECT, onButtonClicked );	
			fflButton.addEventListener( FflButtonEvent.FFL_OVER, doAnimationOver );	
			fflButton.addEventListener( FflButtonEvent.FFL_OUT, doAnimationOut );	
		}
		
		protected override function doAnimationOver( e : FflButtonEvent = null ) : void 
		{
			TweenLite.killTweensOf([ leagueTxt, inviterTxt, icon, background ]);
			resetAssets();
			

			var offset : uint = 50;
			var time : Number = SiteConstants.TIME_TRANSITION_IN;
			var delay : Number = time * .15;
			var blur : uint = 50;
			TweenLite.from( leagueTxt, time, { alpha: 0, x: leagueTxt.x - offset, blurFilter: { blurX: blur }, ease: Quad.easeOut } );
			TweenLite.from( inviterTxt, time, { alpha: 0, x: inviterTxt.x + offset, blurFilter: { blurX: blur }, ease: Quad.easeOut } );
			
			icon.alpha = 0;
			var scale : Number = 1.2;
			var xPos : int = _positions[ 1 ][ 0 ] + ( icon.width - ( icon.width * scale ) ) * .5;
			var yPos : int = _positions[ 1 ][ 1 ] + ( icon.height - ( icon.height * scale ) ) * .5;
			TweenLite.to( icon, time, { x: xPos, y: yPos, scaleX: scale, scaleY: scale, alpha: 1, ease: Quad.easeInOut, onComplete: doIconOut } );

			scale = 1.1;
			xPos = ( background.width - ( background.width * scale ) ) * .5;
			yPos = ( background.height - ( background.height * scale ) ) * .5;
			TweenLite.to( background, time * 2, { x: xPos, y: yPos, scaleX: scale, scaleY: scale, ease: Quad.easeOut } );
		}

		protected function doIconOut( e : FflButtonEvent = null ) : void 
		{
			var time : Number = SiteConstants.TIME_TRANSITION_OUT;
			var xPos : uint = _positions[ 1 ][ 0 ];
			var yPos : uint = _positions[ 1 ][ 1 ];
			TweenLite.to( icon, time, { x: xPos, y: yPos, scaleX: 1, scaleY: 1, ease: Bounce.easeOut } );
		}

		protected override function doAnimationOut( e : FflButtonEvent = null ) : void 
		{
			var time : Number = SiteConstants.TIME_TRANSITION_OUT;
			TweenLite.to( background, time, { x: 0, y: 0, scaleX: 1, scaleY: 1, ease: Quad.easeOut } );
		}
		
		protected function resetAssets( ) : void 
		{
			for( var i : uint = 0; i < _positionItems.length; i++ )
			{
				var item : MovieClip = _positionItems[ i ];
				item.alpha = 1;
				item.x = _positions[ i ][ 0 ];
				item.y = _positions[ i ][ 1 ];
				TweenLite.to( item, 0, { blurFilter: { blurX: 0 } } );
			}
		}
		
		//----------------------------------------------------------------------------
		// event handlers
		//----------------------------------------------------------------------------
		protected function onButtonClicked( e : Event ) : void
		{	
//			_micChecker.stopCheck();
			
			if (ConfigModel.gi.isOnNotLoggedInPage) {
				Main.instance.showNotLoggedInPageDialog();
				return;
			}
			
			if ( LeagueModel.gi.isCommissioner )
			{
				var button : FflButton = e.target as FflButton;
				button.removeEventListener( Event.SELECT, onButtonClicked );
				button.kill();
				StateModel.gi.state = StateModel.STATE_INVITER;	
				
				Main.instance.updateQuickNav( _id );
				
				Metrics.pageView("homeInviterButton");
			}
			else
			{
				Main.instance.showNotCommissionerDialog();
			}
		}
	}
}
