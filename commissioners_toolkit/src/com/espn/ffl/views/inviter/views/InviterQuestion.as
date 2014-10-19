package com.espn.ffl.views.inviter.views {
	import com.espn.ffl.constants.SiteConstants;
	import com.espn.ffl.model.ContentModel;
	import com.espn.ffl.model.PersonalizedModel;
	import com.espn.ffl.util.FflDropShadow;
	import com.espn.ffl.views.AbstractView;
	import com.espn.ffl.views.inviter.Inviter;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	import leelib.ui.Component;
	import leelib.util.TextFieldUtil;
	import leelib.vid.MinVid;

	/**
	 * @author jason.tighe
	 */
	public class InviterQuestion 
	extends AbstractView 
	{
		//----------------------------------------------------------------------------
		// private static constants
		//----------------------------------------------------------------------------
		private static const BUTTON_WIDTH					: uint = 171;
		private static const BUTTON_HEIGHT					: uint = 47;
		private static const BUTTON_SIZE					: uint = 22;
		private static const BUTTON_X						: uint = 548;
		private static const BUTTON_Y						: uint = 480;
		private static const COUNTDOWN_X					: uint = 253;
		private static const COUNTDOWN_Y					: uint = 472;
		//----------------------------------------------------------------------------
		// private variables
		//----------------------------------------------------------------------------
		private var _cm										: ContentModel = ContentModel.gi;
		private var _frame									: WebcamFrame;
		private var _pm										: PersonalizedModel = PersonalizedModel.gi;
		private var _questionBoxAdded						: Boolean = false;
		private var _isReset								: Boolean = false;
		private var _timeoutIdShowStopButton				: Number;
		private var _timeoutIdShowTimer						: Number;
		//----------------------------------------------------------------------------
		// public variables
		//----------------------------------------------------------------------------
		public var title									: TextField;
		public var pinwheel									: InviterPinwheel;
		public var pinwheelHolder							: MovieClip;
		public var _minVid									: MinVid;
		public var counter									: InviterCounter;
		//----------------------------------------------------------------------------
		// constructor
		//----------------------------------------------------------------------------
		public function InviterQuestion() 
		{
			super();
		}
		
		protected override function addViews() : void 
		{ 
			trace( "INVITERQUESTION : addViews()" );
			title  = TextFieldUtil.makeTextWithCopyDto( _cm.getCopyItemByName("liQuestionTitle") );
			addChild( title );
			title.filters = [ FflDropShadow.getDefault() ];
			
			if( !counter )
			{
				counter = new InviterCounter();
				counter.x = COUNTDOWN_X;
				counter.y = COUNTDOWN_Y;
				addChild( counter );
			}
			
			var xPos : uint = 119;
			var yPos : uint = 87;
			
			_minVid = new MinVid();
			_minVid.sizeWidthHeight( SiteConstants.WEBCAM_FULL_WIDTH, SiteConstants.WEBCAM_FULL_HEIGHT);
			_minVid.x = xPos;
			_minVid.y = yPos;
			addChild( _minVid );
			
			pinwheelHolder = new MovieClip()
			pinwheelHolder.x = xPos;
			pinwheelHolder.y = yPos;
			addChild( pinwheelHolder );
			
			_frame = Inviter.instance.getFrame();
		}
		
		//----------------------------------------------------------------------------
		// public methods
		//----------------------------------------------------------------------------
		public override function reset() : void 
		{ 
			trace( "INVITERQUESTION : reset() : _questionBoxAdded is "+_questionBoxAdded );
			hideMinVideo();
			counter.reset();

			clearTimeouts();

			_questionBoxAdded = false;
			_isReset = true;
		}
		
		public function clearTimeouts():void
		{
			clearTimeout(_timeoutIdShowStopButton);
			clearTimeout(_timeoutIdShowTimer);
		}

		public function playPerryVideo() : void 
		{ 
			_isReset = false;
			
			_frame.showControls();
			_frame.hideQuestionBox();
			var controls : WebcamControls = _frame.controls;	
			controls.showRecordInactive();
//			showCover();
			addPinwheel();
			Inviter.instance.hideWebcam();
			
			if( !contains( _minVid ))	addChild( _minVid );
			trace( "INVITERQUESTION : playPerryVideo() : contains( _minVid ) is "+contains( _minVid ) );
			
			var questionCount : uint = _pm.questionCount;
			var url : String = _cm.getInterviewVideoItemAt( questionCount ).previewURL;
			_minVid.addEventListener( Event.COMPLETE, onVideoComplete );
			_minVid.addEventListener( Component.EVENT_LOADED, onVideoLoaded );
//			_minVid.addEventListener( VideoEvent.PLAYING, onVideoPlaying );
			
			_minVid.go( url );
			
			if( questionCount > 0 )		counter.highlight( questionCount );
		}
		
		public function showQuestionBox() : void 
		{ 
			trace( "INVITERQUESTION : showQuestionBox() : _questionBoxAdded is "+_questionBoxAdded );
			var questionCount : uint = _pm.questionCount;
			if( _questionBoxAdded )
			{
				var questionBox : WebcamQuestionBox = _frame.questionBox;
				questionBox.cleanUp();
			}
			
			_frame.showQuestionBox();
			_questionBoxAdded = true;
		}
		
		public function showReady() : void 
		{ 
			trace( "INVITERQUESTION : showReady()" );
			showQuestionBox();
			
			// SHOW RECORD BUTTON
			var controls : WebcamControls = _frame.controls;
			controls.showRecordActive();
			controls.showInstructions();
		}
		
		public function showCountdown() : void 
		{ 
			_frame.showCountdown();
			Inviter.instance.showWebcam();
			hideMinVideo();
			
			_timeoutIdShowStopButton = setTimeout( showStopButton, 3000 );
			_timeoutIdShowTimer = setTimeout( showTimer, 3000 );
		}	
		
		public function showStopped() : void 
		{ 
			var controls : WebcamControls = _frame.controls;
			controls.addEventListener( Event.COMPLETE, onTimerComplete );
			controls.hideTimer();
			controls.deactiveStopButton();
			
			trace( "INVITERQUESTION : showStopped() : _pm.questionCount is "+_pm.questionCount );
			if( _pm.questionCount == 2 )
			{
				_frame.addImageUploader();
			}
			else
			{
				_frame.showDialogTryAgain();
			}
		}	
		
		//----------------------------------------------------------------------------
		// private methods
		//----------------------------------------------------------------------------
		private function addPinwheel() : void 
		{ 
			trace( "INVITERQUESTION : addPinwheel()" );
			pinwheel= new InviterPinwheel;
			pinwheelHolder.addChild( pinwheel );
			pinwheel.showPinwheel();
		}
		private function removePinwheel() : void 
		{ 
			trace( "INVITERQUESTION : removePinwheel()" );
			if( pinwheelHolder.contains( pinwheel ))
			{
				pinwheel.hidePinwheel();
				pinwheelHolder.removeChild( pinwheel );
				pinwheel = null;
			}
		}
		
		private function hideMinVideo() : void 
		{ 
			if( contains( _minVid ) )
			{
				_minVid.close();
				removeChild( _minVid );
			}
		}
		
		private function showTimer() : void 
		{ 
			if( !_isReset )
			{
				var controls : WebcamControls = _frame.controls;
				controls.addEventListener( Event.COMPLETE, onTimerComplete );
				controls.showTimer();
			}
		}
		
		private function showStopButton() : void 
		{ 
			if( !_isReset )
			{
				var controls : WebcamControls = _frame.controls;
				controls.showStop();
			}
		}
		
		//----------------------------------------------------------------------------
		// event handlers
		//----------------------------------------------------------------------------
		private function onVideoComplete( e : Event ) : void 
		{ 
			_minVid.removeEventListener( Event.COMPLETE, onVideoComplete );
			_pm.state = PersonalizedModel.STATE_READY;
		}
		private function onVideoLoaded( e : Event ) : void 
		{ 
			_minVid.removeEventListener( Component.EVENT_LOADED, onVideoLoaded );
			removePinwheel();
		}
		
		protected function onTimerComplete( e : Event ) : void 
		{ 
			trace( "INVITERQUESTION : onTimerComplete()" );
		}
		
		//----------------------------------------------------------------------------
		// getters/setters
		//----------------------------------------------------------------------------
		public function get questionBoxAdded( ) : Boolean
		{
			return _questionBoxAdded;
		}
		public function set questionBoxAdded( s : Boolean ) : void
		{
			_questionBoxAdded = s;
		}

	}
}
