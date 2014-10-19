package com.espn.ffl.views.inviter.views {
	import leelib.ExtendedEvent;
	import leelib.util.TextFieldUtil;

	import com.espn.ffl.apis.http.events.EncodingEvent;
	import com.espn.ffl.apis.http.events.FlvProgressEvent;
	import com.espn.ffl.constants.SiteConstants;
	import com.espn.ffl.model.ConfigModel;
	import com.espn.ffl.model.ContentModel;
	import com.espn.ffl.model.InviterModel;
	import com.espn.ffl.model.PersonalizedModel;
	import com.espn.ffl.util.Assets;
	import com.espn.ffl.util.FflDropShadow;
	import com.espn.ffl.util.Metrics;
	import com.espn.ffl.views.FflAssetButton;
	import com.espn.ffl.views.inviter.Inviter;
	import com.espn.ffl.webcam.WebcamApp;
	import com.greensock.TweenLite;
	import com.greensock.easing.Linear;
	import com.jasontighe.managers.AssetManager;
	import com.jasontighe.utils.Box;

	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextField;

	/**
	 * @author jason.tighe
	 */
	public class DialogTryAgainSave 
	extends MovieClip 
	{
		//----------------------------------------------------------------------------
		// private static constants
		//----------------------------------------------------------------------------
		private static const WIDTH							: uint = 523;
		private static const HEIGHT							: uint = 192;
		private static const BTN_FONT_SIZE					: uint = 23;
		private static const TRY_BTN_WIDTH					: uint = 180;
		private static const TRY_BTN_HEIGHT					: uint = 42;
		private static const TRY_BTN_X						: uint = 96;
		private static const TRY_BTN_Y						: uint = 205;
		private static const SAVE_BTN_WIDTH					: uint = 250;
		private static const SAVE_BTN_HEIGHT				: uint = 42;
		private static const SAVE_BTN_X						: uint = 296;
		private static const SAVE_BTN_Y						: uint = 205;
		private static const PROGRESS_X						: uint = 295;
		private static const PROGRESS_Y						: uint = 180;
		//----------------------------------------------------------------------------
		// private variables
		//----------------------------------------------------------------------------
		private var _cm										: ContentModel = ContentModel.gi;
		private var _im										: InviterModel = InviterModel.gi;
		private var _pm										: PersonalizedModel = PersonalizedModel.gi;
		private var _titlesAdded							: Boolean = false;
		private var _pinwheel								: Sprite;
		private var _pinwheelInner							: MovieClip;	
		//----------------------------------------------------------------------------
		// public variables
		//----------------------------------------------------------------------------
		public var background			 					: MovieClip;
		public var tryAgainBtn			 					: FflAssetButton;
		public var saveContinueBtn			 				: FflAssetButton;
		public var micContinueBtn			 				: FflAssetButton;
		public var title					 				: TextField;
		public var desc						 				: TextField;
		public var holder						 			: MovieClip;
		public var waitingTitleTxt			 				: TextField;
		public var waitingDescTxt			 				: TextField;
		public var progressBar			 					: DialogProgressBar;
		//----------------------------------------------------------------------------
		// constructor
		//----------------------------------------------------------------------------
		public function DialogTryAgainSave() 
		{
			var box : Box = new Box( SiteConstants.WEBCAM_FULL_WIDTH, SiteConstants.WEBCAM_FULL_HEIGHT, 0x000000 );
			box.alpha = .65;
			addChild( box );
			
			background = MovieClip( AssetManager.gi.getAsset( "WebcamDialogAsset", SiteConstants.ASSETS_ID ) );
			background.width = WIDTH;
			background.height = HEIGHT;
			background.x = uint( ( box.width - background.width ) * .5 ) + 4;
			background.y = uint( ( box.height - background.height ) * .5 ) - 8;
			addChild( background );
			
			background.filters = [ FflDropShadow.getDefault() ];
			
			holder = new MovieClip();
			addChild( holder );
			
			var assetLinkage : String = "GrayButtonAsset"; 
			var label : String = ContentModel.gi.getCopyItemByName( "liDialogTryAgain" ).copy;
			var cssType : String = ".bubbleButtonGray";
			var useDropShadow : Boolean = true;
			
			tryAgainBtn = new FflAssetButton( assetLinkage, label, cssType, BTN_FONT_SIZE, TRY_BTN_WIDTH, TRY_BTN_HEIGHT, useDropShadow );
			tryAgainBtn.x = TRY_BTN_X;
			tryAgainBtn.y = TRY_BTN_Y;
			addChild( tryAgainBtn );
			tryAgainBtn.addEventListener( Event.SELECT, onTryAgainClicked );

			assetLinkage = "GreenButtonAsset";
			label = ContentModel.gi.getCopyItemByName( "liDialogSaveContiniue" ).copy;
			cssType = ".bubbleButtonGreen";
			
			saveContinueBtn= new FflAssetButton( assetLinkage, label, cssType, BTN_FONT_SIZE, SAVE_BTN_WIDTH, SAVE_BTN_HEIGHT, useDropShadow );
			saveContinueBtn.x = SAVE_BTN_X;
			saveContinueBtn.y = SAVE_BTN_Y;
			addChild( saveContinueBtn );
			
			label = ContentModel.gi.getCopyItemByName( "liDialogMicContiniue" ).copy;
			micContinueBtn= new FflAssetButton( assetLinkage, label, cssType, BTN_FONT_SIZE, SAVE_BTN_WIDTH, SAVE_BTN_HEIGHT, useDropShadow );
			micContinueBtn.x = SAVE_BTN_X;
			micContinueBtn.y = SAVE_BTN_Y;
			addChild( micContinueBtn );
			micContinueBtn.visible = false;

			progressBar = new DialogProgressBar();
			progressBar.x = PROGRESS_X;
			progressBar.y = PROGRESS_Y;
			addChild( progressBar );
			progressBar.visible = false;
			
			_pinwheel = new Sprite();
			this.addChild(_pinwheel);
			_pinwheelInner = new Assets.Pinwheel();
			_pinwheelInner.scaleX = -.5; 
			_pinwheelInner.scaleY = +.5; 
			_pinwheel.addChild(_pinwheelInner);
			_pinwheel.x = 258+62; // hardcoded
			_pinwheel.y = 135+73;
			_pinwheel.visible = false;
		}
		
		public function initText() : void
		{
			trace( "DIALOGTRYAGAINSAVE : initText()" );
			
			// Only show complete text
			if( _pm.questionCount > 0 )
			{
				trace( "DIALOGTRYAGAINSAVE : initText() : STEP 1" );
				updateText();
				activate();
				return;
			}
			
			// Make sure mic check has been completed
			var micActiveSet : Boolean = _im.micActiveSet;
			trace( "DIALOGTRYAGAINSAVE : initText() : micActiveSet is "+micActiveSet );
			if( micActiveSet == false )
			{
				trace( "DIALOGTRYAGAINSAVE : initText() : STEP 2" );
				_im.addEventListener( InviterModel.MIC_CHECK_COMPLETE, onMicCheckComplete );
				return;
			}
			
			
			var micActive : Boolean = _im.micActive;
			if( micActive)
			{
				trace( "DIALOGTRYAGAINSAVE : initText() : STEP 3" );
				updateText();
			}
			else
			{
				trace( "DIALOGTRYAGAINSAVE : initText() : STEP 4" );
				micInactiveText();
			}
			
			activate();
		}
		
		private function onMicCheckComplete( e : ExtendedEvent = null ) : void
		{
			trace( "DIALOGTRYAGAINSAVE : onMicCheckComplete() : e is "+e );
			_im.removeEventListener( InviterModel.MIC_CHECK_COMPLETE, onMicCheckComplete );
			initText();
		}
		
		public function updateText() : void
		{
			trace( "DIALOGTRYAGAINSAVE : updateText()" );
			removeTitles();
			
			var copy : String;
			var search : String = "#";
			var replace : String ;
			
			replace = ( _pm.questionCount + 1 ).toString();
			copy = _cm.getCopyItemByName( "liDialogTryTitle").copy;
			copy = replaceString( copy, search, replace );
			
			title = TextFieldUtil.makeHtmlText( copy, ".liDialogTryTitle", 500, 30 );
			title.x = _cm.getCopyItemByName( "liDialogTryTitle").xPos;
			title.y = _cm.getCopyItemByName( "liDialogTryTitle").yPos;
			holder.addChild( title );
			
			if( _pm.questionCount == 5 )
			{
				copy = _cm.getCopyItemByName( "liDialogTryDescLast" ).copy;
			}
			else
			{
				replace = ( _pm.questionCount + 2 ).toString();
				copy = _cm.getCopyItemByName( "liDialogTryDesc").copy;
				copy = replaceString( copy, search, replace );
			}
			
			desc = TextFieldUtil.makeHtmlText( copy, ".liDialogTryDesc", 500, 50 );
			desc.x = _cm.getCopyItemByName( "liDialogTryDesc").xPos;
			desc.y = _cm.getCopyItemByName( "liDialogTryDesc").yPos;
			holder.addChild( desc );
			
			_titlesAdded = true;
		}
		
		public function micInactiveText() : void
		{
			trace( "DIALOGTRYAGAINSAVE : micInactiveText()" );
			removeTitles();
			
			title = TextFieldUtil.makeTextWithCopyDto( _cm.getCopyItemByName("liDialogMicTitle"), 500, 50 );
			holder.addChild( title );
			
			desc = TextFieldUtil.makeHtmlTextWithCopyDto( _cm.getCopyItemByName("liDialogMicDesc"), 500, 50 );
			holder.addChild( desc );
			
//			micContinueBtn.visible = true;
//			saveContinueBtn.visible = false;
			
			_titlesAdded = true;
		}
		
		public function activate() : void
		{
			trace( "DIALOGTRYAGAINSAVE : activate()" );
			trace( "DIALOGTRYAGAINSAVE : activate() : _pm.questionCount is "+_pm.questionCount );
			trace( "DIALOGTRYAGAINSAVE : activate() : _im.micActive is "+_im.micActive );
			if( contains( tryAgainBtn ) && contains( saveContinueBtn )  )
			{
				tryAgainBtn.alpha = .5;
				tryAgainBtn.kill();
				tryAgainBtn.visible = true;
				
				if( _pm.questionCount == 0 && _im.micActive == false )
				{
					trace( "DIALOGTRYAGAINSAVE : activate() : STEP 1" );
					micContinueBtn.kill();
					micContinueBtn.visible = true;
					micContinueBtn.alpha = .5;
					
					saveContinueBtn.visible = false;
				}
				else
				{
					trace( "DIALOGTRYAGAINSAVE : activate() : STEP 2" );
					saveContinueBtn.kill();
					saveContinueBtn.visible = true;
					saveContinueBtn.alpha = .5;
					
					micContinueBtn.visible = false;
				}
				
//				if( ConfigModel.gi.uploadFlvs )
//				{	
//					saveContinueBtn.kill();
//					saveContinueBtn.visible = true;
//					saveContinueBtn.alpha = .5;
//				}
//				else
//				{
//					activateSave();
//				}
			}
			trace( "DIALOGTRYAGAINSAVE : activate() : saveContinueBtn.visible is "+saveContinueBtn.visible );
			trace( "DIALOGTRYAGAINSAVE : activate() : micContinueBtn.visible is "+micContinueBtn.visible );
		}
		
		public function activateSave() : void
		{
			saveContinueBtn.alpha = 1;
			saveContinueBtn.addEventListener( Event.SELECT, onSaveContinueClicked );
			saveContinueBtn.enable();
			saveContinueBtn.visible = true;
		}
		
		public function activateTryAgain() : void
		{
			tryAgainBtn.alpha = 1;
			tryAgainBtn.addEventListener( Event.SELECT, onTryAgainClicked );
			tryAgainBtn.enable();
			tryAgainBtn.visible = true;
		}
		
		public function activateContinueAnyways() : void
		{
			micContinueBtn.alpha = 1;
			micContinueBtn.addEventListener( Event.SELECT, onContinueAnywaysClicked );
			micContinueBtn.enable();
			micContinueBtn.visible = true;
		}
		
		public function deactivateContinueAnyways() : void
		{
			micContinueBtn.removeEventListener( Event.SELECT, deactivateContinueAnyways );
			micContinueBtn.disable();
			micContinueBtn.visible = false;
		}
		
		public function deactivateSave() : void
		{
			saveContinueBtn.alpha = .5;
			saveContinueBtn.removeEventListener( Event.SELECT, onSaveContinueClicked );
			saveContinueBtn.disable();
			saveContinueBtn.visible = true;
		}
		
		public function deactivate() : void
		{
			if( contains( tryAgainBtn ) && contains( saveContinueBtn )  )
			{
				tryAgainBtn.removeEventListener( Event.SELECT, onTryAgainClicked );
				tryAgainBtn.kill();
				tryAgainBtn.visible = false;
				
				saveContinueBtn.removeEventListener( Event.SELECT, onSaveContinueClicked );
				saveContinueBtn.kill();
				saveContinueBtn.visible = false;
			}
		}
		
		public function showProgress() : void
		{
			trace( "DIALOGTRYAGAINSAVE : showProgress()" );
			progressBar.visible = true;
			updateProgressBar();
			addProgressListener();
			deactivateSave();
		}
		
		//----------------------------------------------------------------------------
		// private methods
		//----------------------------------------------------------------------------
		private function replaceString( s : String, search : String, replace : String  ) : String
		{
			return s.split(search).join(replace);
		}
		
		public function removeTitles() : void
		{
			if( _titlesAdded )
			{
				holder.removeChild( title );
				title = null;
				
				holder.removeChild( desc );
				desc = null;
			}
		}
		
		private function updateProgressBar() : void
		{
//			trace( "\nDIALOGTRYAGAINSAVE : updateProgressBar()" );
			var wc : WebcamApp = Inviter.instance.getWebcamApp();
			var currentFrame : uint = wc.currentFrame;
			var totalFrames : uint = wc.totalFrames;
			var percent : Number = currentFrame / totalFrames ;
//			trace( "DIALOGTRYAGAINSAVE : updateProgressBar() : currentFrame is "+currentFrame );
//			trace( "DIALOGTRYAGAINSAVE : updateProgressBar() : totalFrames is "+totalFrames );
			
			if( currentFrame == 0 && totalFrames == 999 )	return;
			
			progressBar.update( percent );
			// Catch to kill if everything has already been encoded to byteArray
			if( percent == 1  )
			{
				activateTryAgain();
				
				if( _im.micActive )
				{
					activateSave();
				}
				else
				{
					activateContinueAnyways()
				}
			
				clear();
			}
		}
		
		private function showWaitingView() : void
		{
			waitingTitleTxt = TextFieldUtil.makeTextWithCopyDto( _cm.getCopyItemByName( "liWaitingTitle" ) );
			addChild( waitingTitleTxt );
			waitingDescTxt = TextFieldUtil.makeHtmlTextWithCopyDto( _cm.getCopyItemByName( "liWaitingDesc" ), 500, 90  );
			addChild( waitingDescTxt );
			
			_pinwheel.visible = true;
			_pinwheelInner.rotation = 0;
			TweenLite.to(_pinwheelInner, 99999, { rotation:99999*360, ease:Linear.easeNone } );
		}
		
		private function removeWaitingView() : void
		{
			removeChild( waitingTitleTxt );
			waitingTitleTxt = null;
			removeChild( waitingDescTxt );
			waitingDescTxt = null;
			
			_pinwheel.visible = false;
			TweenLite.killTweensOf(_pinwheelInner);
		}
		
		private function hideProgressBar() : void
		{
			progressBar.visible = false;
			progressBar.reset();
		}
		
		private function dispatchCompleteEvent() : void
		{
			dispatchEvent( new Event( Event.COMPLETE ) );
		}
		
		private function addProgressListener() : void
		{
			trace( "DIALOGTRYAGAINSAVE : removeProgressListener()" );
			var wc : WebcamApp = Inviter.instance.getWebcamApp();
			wc.addEventListener( FlvProgressEvent.PROGRESS_RECEIVED, onEncodingArrayComplete );
			addEventListener( Event.ENTER_FRAME, onEncodingArray );
		}
		
		private function removeProgressListener() : void
		{
			trace( "DIALOGTRYAGAINSAVE : removeProgressListener()" );
			
			var wc : WebcamApp = Inviter.instance.getWebcamApp();
			if( wc.hasEventListener( FlvProgressEvent.PROGRESS_RECEIVED ) )
				wc.removeEventListener( FlvProgressEvent.PROGRESS_RECEIVED, onEncodingArrayComplete );
				
			if( hasEventListener( Event.ENTER_FRAME ) )
				removeEventListener( Event.ENTER_FRAME, onEncodingArray );
		}
		
		private function delayedUpdateState() : void
		{
			trace( "DIALOGTRYAGAINSAVE : delayedUpdateState()" );
			clear();
		}

		private function updateState() : void
		{
			trace( "\n\n" );
			trace( "***************************************" );
			trace( "DIALOGTRYAGAINSAVE : updateState() : _pm.questionCount is "+_pm.questionCount );
			trace( "DIALOGTRYAGAINSAVE : updateState() : _cm.webcamS3URLCount is "+_cm.webcamS3URLCount );
			trace( "DIALOGTRYAGAINSAVE : updateState() : _cm.totalInterviewVideos is "+_cm.totalInterviewVideos );
			trace( "***************************************" );
			trace( "\n\n" );
			
			clear();
			
			if( _pm.questionCount < _cm.totalInterviewVideos )
			{
				trace('x1');
				
				_pm.state = PersonalizedModel.STATE_QUESTION;
				dispatchCompleteEvent();
			}
			else if( _cm.webcamS3URLCount < _cm.totalInterviewVideos )
			{
				deactivate()
				removeTitles();
				showWaitingView();
				_cm.addEventListener( EncodingEvent.WEBCAMS_UPLOADED, onWebcamsUploaded );
			}
			else
			{
				trace('x2');

				_pm.state = PersonalizedModel.STATE_COMPLETED;
				dispatchCompleteEvent();
			}
		}
		
		private function clear() : void
		{
			trace( "DIALOGTRYAGAINSAVE : clear()" );
			removeProgressListener();
			hideProgressBar();
		}
		
		//----------------------------------------------------------------------------
		// event handlers
		//----------------------------------------------------------------------------
		private function onEncodingArray( e : Event ) : void 
		{ 
			// trace( "DIALOGTRYAGAINSAVE : onEncodingArray()" );
			updateProgressBar();
		}
		
		// NO LONGER CALLED
		private function onEncodingArrayComplete( e : FlvProgressEvent ) : void 
		{ 
			trace( "DIALOGTRYAGAINSAVE : onEncodingArrayComplete()" );
			clear();
			activateSave();
		}
		
		private function onTryAgainClicked( e : Event ) : void 
		{ 
			Metrics.pageView("inviterCustomizeTryAgainButton", "[QUESTION_NUM]", (PersonalizedModel.gi.questionCount+1).toString());
			
			if( _pm.questionCount == 0 && _im.micActive == false )	_im.micActiveSet = false;
			
			deactivate();
			dispatchCompleteEvent();
//			var wc : WebcamApp = Inviter.instance.getWebcamApp();
//			wc.resetToWaitingForRecord();
			_pm.state = PersonalizedModel.STATE_READY;
		}
		
		private function onWebcamsUploaded( e : EncodingEvent ) : void 
		{ 
			_cm.removeEventListener( EncodingEvent.WEBCAMS_UPLOADED, onWebcamsUploaded );
			removeWaitingView();
			updateState();
		}
		
		private function onSaveContinueClicked( e : Event ) : void 
		{ 
			trace( "DIALOGTRYAGAINSAVE : onSaveContinueClicked()" );
			deactivate();

			doContinueForNextQuesiton();
		}
		
		private function onContinueAnywaysClicked( e : Event ) : void 
		{ 
			trace( "DIALOGTRYAGAINSAVE : onContinueAnywaysClicked()" );
			deactivate();
			deactivateContinueAnyways()
			
			doContinueForNextQuesiton();
		}
		
		private function doContinueForNextQuesiton() : void
		{
			
			if( ConfigModel.gi.uploadFlvs )
			{	
				var wc : WebcamApp = Inviter.instance.getWebcamApp();
				wc.sendToEncodingS3();
			}
			
			Inviter.instance.hideWebcam();
			
			Metrics.pageView( "onContinueAnywaysClicked", "[QUESTION_NUM]", (PersonalizedModel.gi.questionCount+1).toString());

			trace( "DIALOGTRYAGAINSAVE : onContinueAnywaysClicked() : _pm.questionCount is "+_pm.questionCount );
			_pm.questionCount++;
			trace( "DIALOGTRYAGAINSAVE : onContinueAnywaysClicked() : _pm.questionCount is "+_pm.questionCount );
			updateState();
		}
	}
}
