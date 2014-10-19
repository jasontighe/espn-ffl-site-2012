package com.espn.ffl.views.quicknav {
	import com.espn.ffl.constants.SiteConstants;
	import com.espn.ffl.model.ContentModel;
	import com.espn.ffl.util.FflButtonText;
	import com.greensock.TweenLite;
	import com.jasontighe.navigations.NavItem;
	import com.jasontighe.utils.Box;

	import flash.display.MovieClip;
	import flash.text.TextField;

	/**
	 * @author jason.tighe
	 */
	public class QuickNavItem 
	extends NavItem 
	{
		//----------------------------------------------------------------------------
		// protected static variables
		//----------------------------------------------------------------------------
		protected static var COLOR_ACTIVE				: uint = 0x95d648;
		protected static var COLOR_OVER					: uint = 0x5e5e5e;
		protected static var COLOR_OUT					: uint = 0x373737;
		protected static var BG_SIZE					: uint = 20;
		//----------------------------------------------------------------------------
		// protected variables
		//----------------------------------------------------------------------------
		protected var _mc								: MovieClip;
		//----------------------------------------------------------------------------
		// public variables
		//----------------------------------------------------------------------------
		public var background							: Box;
		public var outTxt								: TextField;
		public var activeTxt							: TextField;
		//----------------------------------------------------------------------------
		// constructor
		//----------------------------------------------------------------------------
		public function QuickNavItem() 
		{
			
		}
		
		//----------------------------------------------------------------------------
		// public methods
		//----------------------------------------------------------------------------
		public override function init( ) : void
		{
			addViews();
		}

		public override function setOverState ( active : int = -1 ) : void
		{
			doOverState();
		}

		public override function setOutState () : void
		{
			doOutState();
		}

		public override function setActiveState ( active : int = -1 ) : void
		{
			doClickState();
		}

		public override function setInactiveState () : void
		{
		}

		public function addTitle( n : uint ) : void
		{
			var fontSize : uint = 14;
			var name : String = ContentModel.gi.getSectionItemAt( n ).name;
			outTxt = FflButtonText.makeText( name, ".quickNavText", fontSize );
			outTxt.x = int( _mc.x + ( ( _mc.width - outTxt.textWidth ) * .5 ) );
			outTxt.y = _mc.y + _mc.height; 
			addChild( outTxt );
			
			name = ContentModel.gi.getSectionItemAt( n ).name;
			activeTxt = FflButtonText.makeText( name, ".quickNavTextActive", fontSize );
			activeTxt.x = int( _mc.x + ( ( _mc.width - activeTxt.textWidth ) * .5 ) );
			activeTxt.y = _mc.y + _mc.height; 
			addChild( activeTxt );
			activeTxt.alpha = 0;
		}
		
		//----------------------------------------------------------------------------
		// protected methods
		//----------------------------------------------------------------------------
		protected function addViews( ) : void {}
		
		protected function doOverState( ) : void
		{
			TweenLite.to( _mc.background, SiteConstants.TIME_OVER, { tint: COLOR_OVER } );
		}

		protected function doOutState( ) : void
		{
			TweenLite.to( _mc.background, SiteConstants.TIME_OUT, { tint: COLOR_OUT } );
			TweenLite.to( activeTxt, SiteConstants.TIME_OUT, { alpha: 0 } );
			TweenLite.to( outTxt, SiteConstants.TIME_OUT, { alpha: 1 } );
		}
		
		protected function doClickState( ) : void
		{	
			TweenLite.to( _mc.background, SiteConstants.TIME_OUT, { tint: COLOR_ACTIVE } );
			TweenLite.to( activeTxt, SiteConstants.TIME_OUT, { alpha: 1 } );
			TweenLite.to( outTxt, SiteConstants.TIME_OUT, { alpha: 0 } );
		}
		
		//----------------------------------------------------------------------------
		// protected methods
		//----------------------------------------------------------------------------
		public function set mc( m : MovieClip ) : void
		{
			_mc = m;
		}
		
//		public function set mcX( n : uint ) : void
//		{
//			_mcX = n;
//		}
	}
}
