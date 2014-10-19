package com.espn.ffl.views.touts {
	import com.espn.ffl.constants.SiteConstants;
	import com.espn.ffl.model.ConfigModel;
	import com.espn.ffl.model.ContentModel;
	import com.espn.ffl.model.events.FflButtonEvent;
	import com.espn.ffl.util.Metrics;
	import com.espn.ffl.views.FflButton;
	import com.espn.ffl.views.Main;
	import com.greensock.TweenLite;
	import com.greensock.easing.Quad;
	import com.jasontighe.managers.AssetManager;
	import com.jasontighe.utils.Box;

	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;

	/**
	 * @author jason.tighe
	 */
	public class ApparelTout 
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
		public var brandon									: MovieClip;
		public var teamTxt									: MovieClip;
//		public var starTxt									: MovieClip;
		public var gearTxt									: MovieClip;
		//----------------------------------------------------------------------------
		// constructor
		//----------------------------------------------------------------------------
		public function ApparelTout() 
		{
			super();
		}
		
		//----------------------------------------------------------------------------
		// protected methods
		//----------------------------------------------------------------------------
		protected override function addViews() : void 
		{ 
			trace( "APPARELTOUT : addViews()" );
			var asset : MovieClip = MovieClip( AssetManager.gi.getAsset( "ApparelTout", SiteConstants.ASSETS_ID ) );
			addChild( asset );
			
			var masker : Box = new Box( asset.width, asset.height );
			addChild( masker );
			asset.mask = masker;
			
			brandon = asset.brandon;
			teamTxt = asset.teamTxt;
//			starTxt = asset.starTxt;
			gearTxt = asset.gearTxt;
			
			_positionItems = [ teamTxt, gearTxt, brandon ];
		
			var copy : String = _cm.getCopyItemByName( "toutAPButton" ).copy;
			var fflButton : FflButton = new FflButton( copy, BUTTON_WIDTH, BUTTON_HEIGHT, BUTTON_SIZE, FflButton.BACKGROUNDTYPE_GREEN, false );
			fflButton.x = _cm.getCopyItemByName( "toutAPButton" ).xPos;
			fflButton.y = _cm.getCopyItemByName( "toutAPButton" ).yPos;
			addChild( fflButton );
			
			for( var i : uint = 0; i < _positionItems.length; i++ )
			{
				var item : MovieClip = _positionItems[ i ];
				_positions.push( [ item.x, item.y ] );
			}
			
			fflButton.addEventListener( Event.SELECT, onButtonClicked );
			fflButton.addEventListener( FflButtonEvent.FFL_OVER, doAnimationOver );	
			fflButton.addEventListener( FflButtonEvent.FFL_OUT, doAnimationOut );	
		}
		
		protected override function doAnimationOver( e : FflButtonEvent = null ) : void 
		{
			resetAssets();
			
			var scale : Number;
			var xPos : int;
			var yPos : int;
			var time : Number = SiteConstants.TIME_TRANSITION_IN;

			var offset : uint = 50;
//			trace( "INVITERTOUT : doAnimationOver() : xPos is "+xPos );
			var delay : Number = time * .85;
			var blur : uint = 50;
			
			TweenLite.from( teamTxt, time, { alpha: 0, x: _positions[ 0 ][ 0 ] + offset, blurFilter: { blurX: blur }, ease: Quad.easeOut } );
			TweenLite.from( gearTxt, time, { alpha: 0, x: _positions[ 1 ][ 0 ] - offset, blurFilter: { blurX: blur }, ease: Quad.easeOut } );
//			
//			icon.alpha = 0;
//			scale = 1.25;
//			xPos = -40;
//			yPos = ( ditka.height - ( ditka.height * scale ) ) * .5;
//			TweenLite.to( ditka, time, { x: xPos, y: yPos, scaleX: scale, scaleY: scale, alpha: 1, ease: Quad.easeInOut } );
//
//			scale = .2;
//			xPos = starTxt.x + ( ( starTxt.width - ( starTxt.width * scale ) ) * .5 );
//			yPos = starTxt.y + ( ( starTxt.height - ( starTxt.height * scale ) ) * .5 );
//			
//			TweenLite.from( starTxt, time * .5, { alpha: 0, x: xPos, y: yPos, scaleX: scale, scaleY: scale, delay: .15, ease: Quad.easeOut } );
			
			scale = 1.1;
			xPos = brandon.x + ( ( brandon.width - ( brandon.width * scale ) ) * .5 );
			yPos = brandon.y + ( ( brandon.height - ( brandon.height * scale ) ) * .5 );
			
			TweenLite.to( brandon, time * .5, { x: xPos, y: 0, scaleX: scale, scaleY: scale, ease: Quad.easeOut } );
		}

		protected override function doAnimationOut( e : FflButtonEvent = null ) : void 
		{
			var time : Number = SiteConstants.TIME_TRANSITION_OUT;
//			TweenLite.to( background, time, { x: 0, y: 0, scaleX: 1, scaleY: 1, ease: Quad.easeOut } );
			TweenLite.to( brandon, time * 1.25, { x: _positions[ 2 ][ 0 ], y: _positions[ 2 ][ 1 ], scaleX: 1, scaleY: 1, ease: Quad.easeOut } );
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
		protected function onButtonClicked( e : Event ) : void
		{	
			var button : FflButton = e.target as FflButton;
			var urlRequest : URLRequest = new URLRequest( ConfigModel.gi.apparelURL );
			navigateToURL( urlRequest, "_blank");
			
			Main.instance.updateQuickNav( _id );
			
			Metrics.pageView("homeTeamGearButton");
		}
	}
}
