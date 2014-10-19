package com.espn.ffl.views.touts {
	import com.espn.ffl.constants.SiteConstants;
	import com.espn.ffl.model.ConfigModel;
	import com.espn.ffl.model.ContentModel;
	import com.espn.ffl.model.LeagueModel;
	import com.espn.ffl.model.StateModel;
	import com.espn.ffl.model.events.FflButtonEvent;
	import com.espn.ffl.util.Metrics;
	import com.espn.ffl.views.FflButton;
	import com.espn.ffl.views.Main;
	import com.greensock.TweenLite;
	import com.greensock.easing.Quad;
	import com.jasontighe.managers.AssetManager;
	import com.jasontighe.utils.Box;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	
	import leelib.graphics.GrUtil;

	/**
	 * @author jason.tighe
	 */
	public class ReportCardTout 
	extends AbstractTout 
	{
		//----------------------------------------------------------------------------
		// private static constants
		//----------------------------------------------------------------------------
		private static const BUTTON_WIDTH					: uint = 261;
		private static const BUTTON_HEIGHT					: uint = 47;
		private static const BUTTON_SIZE					: uint = 23;
		private static const MASK_WIDTH						: uint = 626;
		private static const MASK_HEIGHT					: uint = 250;
		//----------------------------------------------------------------------------
		// private variables
		//----------------------------------------------------------------------------
		private var _cm										: ContentModel = ContentModel.gi;
		private var _positions								: Array = new Array();
		private var _positionItems							: Array = new Array();
		//----------------------------------------------------------------------------
		// public variables
		//----------------------------------------------------------------------------
		public var arrow									: MovieClip;
		public var draftTxt									: MovieClip;
		public var reportTxt								: MovieClip;
		public var cardTxt									: MovieClip;
		//----------------------------------------------------------------------------
		// constructor
		//----------------------------------------------------------------------------
		public function ReportCardTout() 
		{
			super();
		}
		
		//----------------------------------------------------------------------------
		// protected methods
		//----------------------------------------------------------------------------
		protected override function addViews() : void 
		{ 
			var asset : MovieClip = MovieClip( AssetManager.gi.getAsset( "ReportCardTout", SiteConstants.ASSETS_ID ) );
			addChild( asset );
			
			arrow = asset.arrow;
			draftTxt = asset.draftTxt;
			reportTxt = asset.reportTxt;
			cardTxt = asset.cardTxt;
			background = asset.bgImage;
			
			trace( "REPORTCARDTOUT : addViews() : width is "+width );
			trace( "REPORTCARDTOUT : addViews() : height is "+height );
		
			var masker : Box = new Box( MASK_WIDTH, MASK_HEIGHT );
			addChild( masker );
			mask = masker;
			
			
			_positionItems = [ arrow, draftTxt, reportTxt, cardTxt, background ];
			for( var i : uint = 0; i < _positionItems.length; i++ )
			{
				var item : MovieClip = _positionItems[ i ];
				_positions.push( [ item.x, item.y ] );
			}
			
			var copy : String = _cm.getCopyItemByName( "toutRCButton" ).copy;
			var fflButton : FflButton = new FflButton( copy, BUTTON_WIDTH, BUTTON_HEIGHT, BUTTON_SIZE, FflButton.BACKGROUNDTYPE_GREEN, false );
			fflButton.x = _cm.getCopyItemByName( "toutRCButton" ).xPos;
			fflButton.y = _cm.getCopyItemByName( "toutRCButton" ).yPos;
			addChild( fflButton );
			
			fflButton.addEventListener( Event.SELECT, onButtonClicked );
			fflButton.addEventListener( FflButtonEvent.FFL_OVER, doAnimationOver );	
			fflButton.addEventListener( FflButtonEvent.FFL_OUT, doAnimationOut );	
		}
		
		//----------------------------------------------------------------------------
		// event handlers
		//----------------------------------------------------------------------------
		protected function onButtonClicked( e : Event ) : void
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
				StateModel.gi.state = StateModel.STATE_REPORT_CARD;	
				
				Main.instance.updateQuickNav( _id );
				
				Metrics.pageView("homeReportCardButton");
			}
			else
			{
				Main.instance.showNotCommissionerDialog();
			}
		}
		
		protected override function doAnimationOver( e : FflButtonEvent = null ) : void 
		{
			var time : Number = SiteConstants.TIME_TRANSITION_IN;
			var scale : Number = 1.1;
			var arrowScale : Number = 1.25;
			var offset : Number = 60;
			var delay : Number = .1;
			TweenLite.to( background, time * 2, { x: -30, y: -30, scaleX: scale, scaleY: scale, rotation: 3, ease: Quad.easeOut } );
			TweenLite.to( arrow, time * 1.5, { x: 520, y: -30, scaleX: arrowScale, scaleY: arrowScale, rotation: 40, ease: Quad.easeOut } );
			TweenLite.from( draftTxt, time, { alpha: 0, x: ( _positions[ 1 ][ 0 ] - offset ), delay: delay * 0, ease: Quad.easeOut } );
			TweenLite.from( reportTxt, time, { alpha: 0, x: ( _positions[ 2 ][ 0 ] + offset ), delay: delay * 1, ease: Quad.easeOut } );
			TweenLite.from( cardTxt, time, { alpha: 0, x: ( _positions[ 3 ][ 0 ] - offset ), delay: delay * 2, ease: Quad.easeOut } );
		}

		protected override function doAnimationOut( e : FflButtonEvent = null ) : void 
		{
			var time : Number = SiteConstants.TIME_TRANSITION_OUT;
			TweenLite.to( background, time, { x: 0, y: 0, scaleX: 1, scaleY: 1, rotation: 0, ease: Quad.easeOut } );
			TweenLite.to( arrow, time * .75, { x: _positions[ 0 ][ 0 ], y: _positions[ 0 ][ 1 ], scaleX: 1, scaleY: 1, rotation: 0, ease: Quad.easeOut } );
//			TweenLite.to( draftTxt, time, { x: _positions[ 1 ][ 0 ], ease: Quad.easeOut } );
//			TweenLite.to( reportTxt, time, { x: _positions[ 2 ][ 0 ], ease: Quad.easeOut } );
//			TweenLite.to( cardTxt, time, { x: _positions[ 3 ][ 0 ], ease: Quad.easeOut } );
		}
	}
}
