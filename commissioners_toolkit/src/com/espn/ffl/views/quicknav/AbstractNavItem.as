package com.espn.ffl.views.quicknav {
	import com.jasontighe.navigations.NavItem;
	import com.jasontighe.utils.Box;

	/**
	 * @author jason.tighe
	 */
	public class AbstractNavItem 
	extends NavItem 
	{
		//----------------------------------------------------------------------------
		// protected static variables
		//----------------------------------------------------------------------------
		protected static var BG_COLOR					: uint = 0x000000;
		protected static var BG_SIZE					: uint = 20;
		//----------------------------------------------------------------------------
		// public variables
		//----------------------------------------------------------------------------
		public var background							: Box;
		//----------------------------------------------------------------------------
		// constructor
		//----------------------------------------------------------------------------
		public function AbstractNavItem() 
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
			addBackground();
		}
		
		protected function addBackground( ) : void
		{
			background = new Box( BG_SIZE, BG_SIZE, BG_COLOR );
			addChild( background );
		}
		
		protected function doOverState( ) : void
		{
		}

		protected function doOutState( ) : void
		{
		}
		
		protected function doClickState( ) : void
		{	
			buttonMode = true;
			mouseEnabled = true;
			mouseChildren = false;
			useHandCursor = true;
		}
	}
}
