package com.espn.ffl.views.inviter.views {
	import com.espn.ffl.constants.SiteConstants;
	import com.espn.ffl.util.FflDropShadow;
	import com.jasontighe.containers.DisplayContainer;
	import com.jasontighe.managers.AssetManager;
	import com.jasontighe.utils.Box;

	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;

	/**
	 * @author jason.tighe
	 */
	public class WebcamCountdown 
	extends DisplayContainer 
	{
		//----------------------------------------------------------------------------
		// private variables
		//----------------------------------------------------------------------------
		private var _numbers		 						: Array = new Array;
		private var _curNum			 						: uint = 0;
		private var _to										: uint;
		//----------------------------------------------------------------------------
		// public variables
		//----------------------------------------------------------------------------
		public var background		 						: MovieClip;
		public var countdown3		 						: MovieClip;
		public var countdown2		 						: MovieClip;
		public var countdown1		 						: MovieClip;
		//----------------------------------------------------------------------------
		// constructor
		//----------------------------------------------------------------------------
		public function WebcamCountdown() 
		{
			super();
			
			var box : Box = new Box( SiteConstants.WEBCAM_FULL_WIDTH, SiteConstants.WEBCAM_FULL_HEIGHT, 0x000000 );
			box.alpha = .79;
			addChild( box );
			
			background = MovieClip( AssetManager.gi.getAsset( "InviterWebcamCountdownAsset", SiteConstants.ASSETS_ID ) );
			addChild( background );
			
			countdown3 = background.countdown3;
			countdown2 = background.countdown2;
			countdown1 = background.countdown1;
			_numbers = [ countdown3, countdown2, countdown1 ];
			
			addFilters();
			reset();
		}
		
		//----------------------------------------------------------------------------
		// public methods
		//----------------------------------------------------------------------------
		public function begin() : void
		{
			showNum();
			
			if( _curNum < _numbers.length )
			{
				_to = setTimeout( begin, 1000 );
				_curNum++;
			}
			else
			{
				dispatchEvent( new Event( Event.COMPLETE ) ) ;
				reset();
			}
		}
		
		public function kill() : void
		{
			if( _to )
				clearTimeout( _to );
		}
		
		//----------------------------------------------------------------------------
		// private methods
		//----------------------------------------------------------------------------
		private function showNum() : void
		{
			for( var i : uint = 0; i < _numbers.length; i++ )
			{
				var mc : MovieClip = MovieClip( _numbers[ i ] );
				if( _curNum == i )
				{
					mc.alpha = 1;
				}
				else
				{
					mc.alpha = 0;
				}
			}
		}
		
		private function reset() : void
		{
			for( var i : uint = 0; i < _numbers.length; i++ )
			{
				var mc : MovieClip = MovieClip( _numbers[ i ] );
				mc.alpha = 0;
			}
			
			_curNum = 0;
		}
		
		private function addFilters() : void
		{
			for( var i : uint = 0; i < _numbers.length; i++ )
			{
				var mc : MovieClip = _numbers[ i ] as MovieClip;
				mc.filters = [ FflDropShadow.getDefault() ];
			}
		}
	}
}
