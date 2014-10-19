package com.espn.ffl.views.inviter.views {
	import com.espn.ffl.constants.SiteConstants;
	import com.espn.ffl.model.ContentModel;
	import com.espn.ffl.model.PersonalizedModel;
	import com.espn.ffl.util.Metrics;
	import com.greensock.TweenLite;
	import com.greensock.easing.Quad;
	import com.jasontighe.containers.DisplayContainer;
	import com.jasontighe.managers.AssetManager;
	import com.jasontighe.utils.Box;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.text.TextField;
	
	import leelib.util.TextFieldUtil;

	/**
	 * @author jason.tighe
	 */
	public class WebcamControls 
	extends DisplayContainer 
	{
		//----------------------------------------------------------------------------
		// private static constants
		//----------------------------------------------------------------------------
		private static const TIMER_X						: uint = 568;
		private static const TIMER_Y						: uint = 6;
		//----------------------------------------------------------------------------
		// private variables
		//----------------------------------------------------------------------------
		private var _cm										: ContentModel = ContentModel.gi;
		private var _pm										: PersonalizedModel = PersonalizedModel.gi;
		private var _instructionsViewed						: Boolean = false;
		private var _stopBtnAdded							: Boolean = false;
//		private var _timerAdded								: Boolean = false;
		//----------------------------------------------------------------------------
		// public variables
		//----------------------------------------------------------------------------
		public var recordBtn			 					: FflRecordButton;
		public var stopBtn				 					: FflStopButton;
		public var timer				 					: WebcamTimer;
		public var background			 					: MovieClip;
//		public var waitTxt				 					: TextField;
		public var instructionsTxt				 			: TextField;
		public var masker				 					: Box;
		//----------------------------------------------------------------------------
		// constructor
		//----------------------------------------------------------------------------
		public function WebcamControls() 
		{
			super();
			
			background = MovieClip( AssetManager.gi.getAsset( "InviterWebcamControlsAsset", SiteConstants.ASSETS_ID ) );
			addChild( background );
			
			masker = new Box( background.width, background.height );
			addChild( masker );
			
			background.mask = masker;
//			background.y = masker.y + masker.height;
		}
		
		//----------------------------------------------------------------------------
		// public methods
		//----------------------------------------------------------------------------
		public function showControls() : void
		{
			trace( "WEBCAMCONTROLS : showControls() : _pm.questionCount is "+_pm.questionCount );
			if( _pm.questionCount == 0 )
			{
				background.y = masker.y + masker.height;
				TweenLite.to( background, SiteConstants.TIME_OVER, { y: masker.y, ease: Quad.easeOut } );
			}
			else
			{
				clearBar();
			}
			
			showRecordInactive();
			
		}
		
		public function killMask() : void
		{
			background.mask = null;
		}
		
		public function showRecordInactive() : void
		{
			if( !recordBtn )
			{
				var copy : String = _cm.getCopyItemByName( "liRecordButton" ).copy;
				recordBtn = new FflRecordButton( copy, 176, 47 );
				recordBtn.x = _cm.getCopyItemByName( "liRecordButton" ).xPos;
				recordBtn.y = _cm.getCopyItemByName( "liRecordButton" ).yPos;
			}
			background.addChild( recordBtn );
			recordBtn.alpha = .5;
			recordBtn.isSelected = true;
		}
		
		public function showRecordActive() : void
		{
			trace( "WEBCAMCONTROLS : showRecordActive()" );
			hideStop();

			if( !background.contains( recordBtn ) ) 	background.addChild( recordBtn );
			recordBtn.addEventListener( Event.SELECT, onRecordClicked );
			recordBtn.isSelected = false;
			
			TweenLite.to( recordBtn, SiteConstants.TIME_OVER, { alpha: 1 } );
		}
		
		public function showInstructions() : void
		{
			if( !_instructionsViewed )
			{
				instructionsTxt = TextFieldUtil.makeHtmlTextWithCopyDto( _cm.getCopyItemByName( "liWebcamPressIf" ), 300, 100 );
				var xoffset : int = 25;
				var yoffset : int = -1;
				instructionsTxt.x = recordBtn.x + recordBtn.width + xoffset;
				instructionsTxt.y = int( ( background.height -  instructionsTxt.textHeight ) * .5 ) + yoffset;
				background.addChild( instructionsTxt );
				_instructionsViewed = true;
			}
		}

		public function showStop() : void
		{
			if( !stopBtn )
			{
				var copy : String = _cm.getCopyItemByName( "liStopButton" ).copy;
				stopBtn = new FflStopButton( copy, 176, 47 );
				stopBtn.x = _cm.getCopyItemByName( "liStopButton" ).xPos;
				stopBtn.y = _cm.getCopyItemByName( "liStopButton" ).yPos;
			}
			stopBtn.addEventListener( Event.SELECT, onStopClicked );
			background.addChild( stopBtn );
			stopBtn.isSelected = false;
			stopBtn.startBlinking();
			_stopBtnAdded = true;
		}

		public function deactiveStopButton() : void
		{
			if( stopBtn && background.contains( stopBtn ) )
			{
				stopBtn.isSelected = true;
			}
		}
		
		public function showTimer() : void
		{
			trace( "WEBCAMCONTROLS : showTimer()   ^   ^   ^   ^   ^   ^   ^   ^" );
			if( !timer )
			{
				timer = new WebcamTimer();
				timer.x = TIMER_X;
				timer.y = TIMER_Y;
//				_timerAdded = true;
			}
			background.addChild( timer );
			timer.playTimer();
		}
		
		public function killTimer() : void
		{
			if( timer && background.contains( timer ) )	timer.kill();
		}
		
		public function hideTimer() : void
		{
			trace( "WEBCAMCONTROLS : hideTimer()   ^   ^   ^   ^   ^   ^   ^   ^" );
			if( timer && background.contains( timer ) )
			{
				trace( "WEBCAMCONTROLS : hideTimer() : IT WENT THROUGH." );
				timer.pauseTimer();
				background.removeChild( timer );
			}
		}
		
		public function clearBar( ) : void
		{	
			hideRecord();
			hideStop();
			hideInstructions();
		}
		
		//----------------------------------------------------------------------------
		// private variables
		//----------------------------------------------------------------------------
		private function hideRecord( ) : void
		{	
			if( background.contains( recordBtn ) )	background.removeChild( recordBtn );
		}
		
		private function hideStop( ) : void
		{	
			if( _stopBtnAdded )
			{
				if( background.contains( stopBtn ) )	background.removeChild( stopBtn );
			}
		}
		
		private function hideInstructions( ) : void
		{	
			if( instructionsTxt && background.contains( instructionsTxt ) )	
				background.removeChild( instructionsTxt );
		}
		
		
		//----------------------------------------------------------------------------
		// event handlers
		//----------------------------------------------------------------------------
		private function onRecordClicked( e : Event ) : void
		{
			trace( "WEBCAMCONTROLS : onRecordClicked()" );
			recordBtn.removeEventListener( Event.SELECT, onRecordClicked );
			recordBtn.isSelected = true;
			recordBtn.kill();
			_pm.state = PersonalizedModel.STATE_COUNTDOWN;
			
			hideInstructions();
			
			Metrics.pageView("inviterCustomizeQuestionRecordButton", "[QUESTION_NUM]", (PersonalizedModel.gi.questionCount+1).toString());
		}
		
		private function onStopClicked( e : Event ) : void
		{
			trace( "WEBCAMCONTROLS : onRecordClicked()" );
			stopBtn.removeEventListener( Event.SELECT, onStopClicked );
			_pm.state = PersonalizedModel.STATE_STOPPED;
			
		}
	}
}
