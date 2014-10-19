package com.espn.ffl.views.inviter.views {
	import com.espn.ffl.constants.SiteConstants;
	import com.espn.ffl.model.PremadeModel;
	import com.espn.ffl.views.AbstractView;
	import com.jasontighe.managers.AssetManager;

	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;

	/**
	 * @author jason.tighe
	 */
	public class DeletedVideo 
	extends AbstractView 
	{
		//----------------------------------------------------------------------------
		// public variables
		//----------------------------------------------------------------------------
		public var deleted									: DeletedDialog;
		//----------------------------------------------------------------------------
		// constructor
		//----------------------------------------------------------------------------
		public function DeletedVideo() 
		{
			trace( "DELETEDVIDEO : Cosntr" );
			super();
		}
		//----------------------------------------------------------------------------
		// protected methods
		//----------------------------------------------------------------------------
//		protected function transitionInComplete() : void { }
//		protected function transitionOutComplete() : void { }
		
		protected override function addViews() : void 
		{ 
			var asset : MovieClip = MovieClip( AssetManager.gi.getAsset( "InviterDeletedAsset", SiteConstants.ASSETS_ID ) );
			addChild( asset );
			
			deleted = new DeletedDialog();
			deleted.x = 180;
			deleted.y = 175;
			addChild( deleted );
			deleted.addEventListener( MouseEvent.CLICK, onClick );
		}
		
		//----------------------------------------------------------------------------
		// event handlers
		//----------------------------------------------------------------------------
		protected function onClick( e : MouseEvent ) : void
		{	
			deleted.removeEventListener( MouseEvent.CLICK, onClick );
			PremadeModel.gi.state = PremadeModel.STATE_VIDEO_SELECTOR;	
		}
	}
}
