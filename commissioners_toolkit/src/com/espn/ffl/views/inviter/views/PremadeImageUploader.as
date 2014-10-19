package com.espn.ffl.views.inviter.views {
	import leelib.ExtendedEvent;
	import leelib.util.Out;

	import com.espn.ffl.apis.http.HusaniRequestor;
	import com.espn.ffl.image_uploader.DialogUploadPhoto;
	import com.espn.ffl.model.InviterModel;
	import com.espn.ffl.model.PremadeModel;
	import com.jasontighe.utils.Box;

	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;

	/**
	 * @author jason.tighe
	 */
	public class PremadeImageUploader 
	extends MovieClip 
	{
		//----------------------------------------------------------------------------
		// private static constants
		//----------------------------------------------------------------------------
		private static const BOX_WIDTH						: uint = 880;
		private static const BOX_HEIGHT						: uint = 543;
		private static const BOX_ALPHA						: Number = .76;
		private static const UPLOAD_X						: uint = 138;
		private static const UPLOAD_Y						: uint = 143;
		//----------------------------------------------------------------------------
		// private variables
		//----------------------------------------------------------------------------
		private var _pm										: PremadeModel = PremadeModel.gi;
		//----------------------------------------------------------------------------
		// public variables
		//----------------------------------------------------------------------------
		public var upload									: DialogUploadPhoto;
		//----------------------------------------------------------------------------
		// constructor
		//----------------------------------------------------------------------------
		public function PremadeImageUploader( id : uint = 0 ) 
		{
			trace( "PREMADEIMAGEUPLOADER : Constr : id is "+id );
			var box : Box = new Box( BOX_WIDTH, BOX_HEIGHT, 0x000000 );
			box.alpha = BOX_ALPHA;
			addChild( box );
			
			_pm.curVideo = id;
			
			// DIMENSIONS FROM HANNA
//			var widths : Array = new Array( 233, 228, 236 );
//			var heights : Array = new Array( 132, 127, 131 );
			
			// 138, 143
//			var xPos : Array = new Array( 233, 228, 236 );
//			var yPos : Array = new Array( 132, 127, 131 );
			
			var w : uint = 99; //widths[ id ];
			var h : uint = 90; //heights[ id ];
			
			upload = new DialogUploadPhoto( InviterModel.STATE_PREMADE, w, h);
			upload.x = UPLOAD_X;
			upload.y = UPLOAD_Y;
			upload.id = id;
			upload.activateCloseButton();
			upload.addEventListener( Event.COMPLETE , onUploadComplete );
			upload.addEventListener( DialogUploadPhoto.CLOSE_CLICKED, onCloseClicked );
			addChild( upload );
		}
		
		
		private function sendPremadeToHusani( ) : void
		{
			trace( "PREMADEIMAGEUPLOADER : sendURLToHusani()" ); 
			var hr : HusaniRequestor = new HusaniRequestor();
			hr.premadeVideoId = _pm.curVideo;
			hr.addEventListener( Event.COMPLETE, sendURLToHusaniComplete);
			hr.addEventListener(IOErrorEvent.IO_ERROR, onS3PostIoError);
			hr.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onS3PostSecurityError);
			hr.request( HusaniRequestor.SET_PREMADE_URL);
		}
		
		protected function updateStateToComplete(  ) : void 
		{
			_pm.state = PremadeModel.STATE_COMPLETED;
		}
		
		//----------------------------------------------------------------------------
		// event handlers
		//----------------------------------------------------------------------------
		private function onUploadComplete( e : Event ) : void
		{
			trace( " PREMADEIMAGEUPLOADER : onUploadComplete"  );
			sendPremadeToHusani();
		}
		
		private function onCloseClicked( e : ExtendedEvent ) : void
		{
			trace( " PREMADEIMAGEUPLOADER : onCloseClicked"  );
			dispatchEvent(new ExtendedEvent( DialogUploadPhoto.CLOSE_CLICKED, e));
		}
		
		private function sendURLToHusaniComplete( e : Event ) : void
		{
			trace( "PREMADEIMAGEUPLOADER : sendURLToHusaniComplete()" ); 
			dispatchEvent( new Event( Event.COMPLETE ) );
			updateStateToComplete();
		}
		
		private function onS3PostIoError($e:IOErrorEvent):void
		{
			Out.i("PREMADEIMAGEUPLOADER : FflS3Uploader.onS3PostIoError()", $e.text);
		}
		
		private function onS3PostSecurityError($e:SecurityErrorEvent):void 
		{
			Out.i("PREMADEIMAGEUPLOADER : FflS3Uploader.onS3PostSecurityError()", $e.text);
		}
	}
}
