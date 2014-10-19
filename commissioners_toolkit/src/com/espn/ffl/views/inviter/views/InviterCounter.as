package com.espn.ffl.views.inviter.views {
	import com.espn.ffl.constants.SiteConstants;
	import com.espn.ffl.model.ContentModel;
	import com.espn.ffl.util.FflDropShadow;
	import com.jasontighe.containers.DisplayContainer;
	import com.jasontighe.managers.AssetManager;

	import flash.display.MovieClip;

	/**
	 * @author jason.tighe
	 */
	public class InviterCounter 
	extends DisplayContainer 
	{
		//----------------------------------------------------------------------------
		// private static constants
		//----------------------------------------------------------------------------
		private static const X_OFFSET						: uint = 60;
		//----------------------------------------------------------------------------
		// private variables
		//----------------------------------------------------------------------------
		private var _cm										: ContentModel = ContentModel.gi;
		private var _counters								: Array = new Array();
		//----------------------------------------------------------------------------
		// public variables
		//----------------------------------------------------------------------------
		public var counter1									: MovieClip;
//		public var background								: MovieClip;
		//----------------------------------------------------------------------------
		// constructor
		//----------------------------------------------------------------------------
		public function InviterCounter() 
		{
			super();
			init();
		}
		
		public override function init() : void
		{
			var asset : MovieClip = MovieClip( AssetManager.gi.getAsset( "InviterCounterAsset", SiteConstants.ASSETS_ID ) );
			addChild( asset );
			
			counter1 = asset.counter1;
			
			reset();
			
			filters = [ FflDropShadow.getDefault() ];
		}
		
		public function reset() : void
		{
			var i : uint = 0;
			var I : uint = _cm.totalInterviewVideos - 1;
			for( i; i < I; i++)
			{
				var counter : InviterCounterButton = new InviterCounterButton();
				counter.setNum( i );
				var xPos : uint = ( i + 1 ) * X_OFFSET;
				var yPos : uint = counter1.y;
				counter.x = xPos;
				counter.y = yPos;
				addChild( counter );
				_counters.push( counter )
			}
		}
		
		public function highlight( n : uint ) : void
		{
			if( n > 0 )
			{
				var num : uint = n - 1; // offset since 1 is always highlighted 
				var counter : InviterCounterButton = _counters[ num ].highlight();
			}
		}
		
		
	}
}
