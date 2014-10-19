package com.espn.ffl.views.inviter.views {
	import com.espn.ffl.constants.SiteConstants;
	import com.espn.ffl.image_uploader.DialogUploadPhoto;
	import com.espn.ffl.model.InviterModel;
	import com.jasontighe.utils.Box;

	import flash.display.MovieClip;
	import flash.events.Event;

	/**
	 * @author jason.tighe
	 */
	public class PersonalizedImageUploader 
	extends MovieClip 
	{
		//----------------------------------------------------------------------------
		// private static constants
		//----------------------------------------------------------------------------
		private static const BOX_ALPHA						: Number = .76;
		private static const UPLOAD_X						: uint = 32;
		private static const UPLOAD_Y						: uint = 46;
		//----------------------------------------------------------------------------
		// private variables
		//----------------------------------------------------------------------------
//		private var _pm										: PremadeModel = PremadeModel.gi;
		//----------------------------------------------------------------------------
		// public variables
		//----------------------------------------------------------------------------
		public var upload									: DialogUploadPhoto;
		//----------------------------------------------------------------------------
		// constructor
		//----------------------------------------------------------------------------
		public function PersonalizedImageUploader( id : uint = 0 ) 
		{
			var box : Box = new Box( SiteConstants.WEBCAM_FULL_WIDTH, SiteConstants.WEBCAM_FULL_HEIGHT, 0x000000 );
			box.alpha = BOX_ALPHA;
			addChild( box );
			
			upload = new DialogUploadPhoto( InviterModel.STATE_PERSONALIZED, 230, 360 );
			upload.x = int( ( box.width - upload.width) * .5 );
			upload.y = int( ( box.height - upload.height) * .5 );
			upload.id = id;
			upload.addEventListener( Event.COMPLETE , onUploadComplete )
			addChild( upload );
		}
		
		protected function removeUploader() : void
		{
			removeChild( upload );	
		}
		
		//----------------------------------------------------------------------------
		// event handlers
		//----------------------------------------------------------------------------
		private function onUploadComplete( e : Event ) : void
		{
			removeUploader();
			dispatchEvent( new Event( Event.COMPLETE ) );
			
		}
	}
}
