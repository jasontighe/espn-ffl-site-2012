package com.espn.ffl.views.inviter.views {
	import com.espn.ffl.constants.SiteConstants;
	import com.greensock.TweenLite;
	import com.jasontighe.navigations.NavItem;
	import com.jasontighe.utils.Box;

	import flash.display.MovieClip;
	import flash.text.TextField;

	/**
	 * @author jason.tighe
	 */
	public class InviterTabNavItem 
	extends NavItem 
	{
		//----------------------------------------------------------------------------
		// protected static variables
		//----------------------------------------------------------------------------
		protected static var COLOR_OVER					: uint = 0x5e5e5e;
		protected static var COLOR_OUT					: uint = 0x373737;
		protected static var BG_SIZE					: uint = 20;
		//----------------------------------------------------------------------------
		// protected variables
		//----------------------------------------------------------------------------
		protected var _mc								: MovieClip;
		protected var _txt								: TextField;
		//----------------------------------------------------------------------------
		// public variables
		//----------------------------------------------------------------------------
		public var background							: Box;
		//----------------------------------------------------------------------------
		// constructor
		//----------------------------------------------------------------------------
		public function InviterTabNavItem() 
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
		
		//----------------------------------------------------------------------------
		// protected methods
		//----------------------------------------------------------------------------
		protected function addViews( ) : void
		{
//			addBackground();
		}
		
//		protected function addBackground( ) : void
//		{
//			var color : uint = Math.random() * 0xFFFFFF;
//			background = new Box( BG_SIZE, BG_SIZE, color );
//			addChild( background );
//		}
		
		protected function doOverState( ) : void
		{
			TweenLite.to( _mc, SiteConstants.TIME_OVER, { alpha: .5 } );
			TweenLite.to( _txt, SiteConstants.TIME_OVER, { alpha: 1 } );
		}

		protected function doOutState( ) : void
		{
			TweenLite.to( _mc, SiteConstants.TIME_OUT, { alpha: 1 } );
			TweenLite.to( _txt, SiteConstants.TIME_OVER, { alpha: .25 } );
		}
		
		protected function doClickState( ) : void
		{	
			TweenLite.to( _mc, SiteConstants.TIME_OVER, { alpha: 0 } );
			TweenLite.to( _txt, SiteConstants.TIME_OVER, { alpha: 1 } );
		}
		
		//----------------------------------------------------------------------------
		// protected methods
		//----------------------------------------------------------------------------
		public function set mc( m : MovieClip ) : void
		{
			_mc = m;
		}
		
		public function set txt( t : TextField ) : void
		{
			_txt = t;
		}
	}
}
