package com.espn.ffl.views.inviter.views {
	import com.espn.ffl.constants.SiteConstants;
	import com.espn.ffl.util.FflDropShadow;
	import com.jasontighe.managers.AssetManager;

	import flash.display.MovieClip;

	/**
	 * @author jason.tighe
	 */
	public class DialogProgressBar 
	extends MovieClip 
	{
		//----------------------------------------------------------------------------
		// private variables
		//----------------------------------------------------------------------------
		private var _progressW					 			: uint;
		//----------------------------------------------------------------------------
		// public variables
		//----------------------------------------------------------------------------
		public var progress				 					: MovieClip;
		public var gutter				 					: MovieClip;
		//----------------------------------------------------------------------------
		// constructor
		//----------------------------------------------------------------------------
		public function DialogProgressBar() 
		{
			var asset : MovieClip = MovieClip( AssetManager.gi.getAsset( "DialogProgressBarAsset", SiteConstants.ASSETS_ID ) );
			addChild( asset );
			
			progress = asset.progress;
			gutter = asset.gutter;
			_progressW = progress.width;
			
			reset();
		}
		
		//----------------------------------------------------------------------------
		// public methods
		//----------------------------------------------------------------------------
		public function update( percent : Number = 0 ) : void
		{
			progress.width = _progressW * percent;
		}
		
		public function reset( ) : void
		{
			progress.width = 0;
		}
	}
}
