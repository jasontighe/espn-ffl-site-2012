package com.espn.ffl.views.inviter.views {
	import com.espn.ffl.constants.SiteConstants;
	import com.espn.ffl.util.FflDropShadow;
	import com.jasontighe.containers.DisplayContainer;
	import com.jasontighe.managers.AssetManager;

	import flash.display.MovieClip;

	/**
	 * @author jason.tighe
	 */
	public class WebcamSilhouette 
	extends DisplayContainer 
	{
		//----------------------------------------------------------------------------
		// public variables
		//----------------------------------------------------------------------------
		public var background			 					: MovieClip;
		//----------------------------------------------------------------------------
		// constructor
		//----------------------------------------------------------------------------
		public function WebcamSilhouette() 
		{
			super();
			
			background = MovieClip( AssetManager.gi.getAsset( "InviterWebcamSilhouetteAsset", SiteConstants.ASSETS_ID ) );
			addChild( background );
		}
	}
}
