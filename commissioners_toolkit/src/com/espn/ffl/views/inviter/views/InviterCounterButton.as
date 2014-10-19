package com.espn.ffl.views.inviter.views {
	import com.espn.ffl.constants.SiteConstants;
	import com.greensock.TweenLite;
	import com.jasontighe.containers.DisplayContainer;
	import com.jasontighe.managers.AssetManager;

	import flash.display.MovieClip;

	/**
	 * @author jason.tighe
	 */
	public class InviterCounterButton 
	extends DisplayContainer 
	{
		//----------------------------------------------------------------------------
		// private static constants
		//----------------------------------------------------------------------------
		private static const X_OFFSET						: uint = 60;
		//----------------------------------------------------------------------------
		// private variables
		//----------------------------------------------------------------------------
		private var _counters								: Array = new Array();
		//----------------------------------------------------------------------------
		// public variables
		//----------------------------------------------------------------------------
		public var gray										: MovieClip;
		public var green									: MovieClip;
		public var background								: MovieClip;
		//----------------------------------------------------------------------------
		// constructor
		//----------------------------------------------------------------------------
		public function InviterCounterButton() 
		{
			super();
			init();
		}
		
		public override function init() : void
		{
			background = MovieClip( AssetManager.gi.getAsset( "InviterCounterButtonAsset", SiteConstants.ASSETS_ID ) );
			addChild( background );
			
			gray = background.gray;
			green = background.green;
			green.alpha = 0;
			
			var dig2 : MovieClip = background.dig2;
			var dig3 : MovieClip = background.dig3;
			var dig4 : MovieClip = background.dig4;
			var dig5 : MovieClip = background.dig5;
			var dig6 : MovieClip = background.dig6;
			_counters = [ dig2, dig3, dig4, dig5, dig6 ];
			
			for( var i : uint = 0; i < _counters.length; i++)
			{
				_counters[ i ].alpha = 0;
			}
		}
		
		public function setNum( n : uint ) : void
		{
			var digit : MovieClip = _counters[ n ];
			digit.alpha = 1;
		}
		
		public function highlight() : void
		{
			TweenLite.to( green, SiteConstants.TIME_OVER, { alpha: 1 } );
			TweenLite.to( gray, SiteConstants.TIME_OVER, { alpha: 0 } );
		}
	}
}
