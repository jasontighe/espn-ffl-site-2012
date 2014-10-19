package com.espn.ffl.views.inviter.views {
	import leelib.util.TextFieldUtil;

	import com.espn.ffl.constants.SiteConstants;
	import com.espn.ffl.model.ContentModel;
	import com.espn.ffl.model.dto.CopyDTO;
	import com.espn.ffl.views.BubbleButton;
	import com.greensock.TweenLite;
	import com.jasontighe.managers.AssetManager;

	import flash.display.MovieClip;
	import flash.text.TextField;

	/**
	 * @author jason.tighe
	 */
	public class DeletedDialog 
	extends MovieClip 
	{
		//----------------------------------------------------------------------------
		// private static constants
		//----------------------------------------------------------------------------
		private static const BG_WIDTH						: uint = 526;
		private static const BG_HEIGHT						: uint = 196; 
		private static const COLOR_RED						: uint = 0xbd2a39; 
		//----------------------------------------------------------------------------
		// private variables
		//----------------------------------------------------------------------------
		private var _cm										: ContentModel = ContentModel.gi;
		//----------------------------------------------------------------------------
		// public variables
		//----------------------------------------------------------------------------
		public var playBtn									: MovieClip;
		public var outline									: MovieClip;
		public var tryAgainBtn								: BubbleButton;
		//----------------------------------------------------------------------------
		// constructor
		//----------------------------------------------------------------------------
		public function DeletedDialog() 
		{
			trace( "DELETEDDIALOG : Cosntr" );
			var asset : MovieClip = MovieClip( AssetManager.gi.getAsset( "WebcamDialogAsset", SiteConstants.ASSETS_ID ) );
			asset.width = BG_WIDTH;
			asset.height = BG_HEIGHT;
			addChild( asset );
			
			outline = asset.outline;
			outline.alpha = 1;
			TweenLite.to( outline, 0, { tint: COLOR_RED });
			
			var titleTxt : TextField = TextFieldUtil.makeTextWithCopyDto( _cm.getCopyItemByName("deleteDialogTitle"))
			addChild( titleTxt );
			
			var descTxt : TextField = TextFieldUtil.makeHtmlTextWithCopyDto( _cm.getCopyItemByName("deleteDialogDesc"), 480, 60 )
			addChild( descTxt );
			
			var dto : CopyDTO = _cm.getCopyItemByName( "deleteDialogButton" );
			tryAgainBtn = new BubbleButton( dto.copy, 182, true );
			tryAgainBtn.x = dto.xPos;
			tryAgainBtn.y = dto.yPos;
			addChild( tryAgainBtn );
		}
	}
}
