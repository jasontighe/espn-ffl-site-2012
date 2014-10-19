package com.espn.ffl.views.inviter.views {
	import flash.events.Event;
	import com.espn.ffl.constants.SiteConstants;
	import com.espn.ffl.model.ContentModel;
	import com.espn.ffl.model.PersonalizedModel;
	import com.espn.ffl.util.FflButtonText;
	import com.jasontighe.containers.DisplayContainer;
	import com.jasontighe.managers.AssetManager;

	import flash.display.MovieClip;
	import flash.text.TextField;
	import flash.utils.setTimeout;

	/**
	 * @author jason.tighe
	 */
	public class WebcamTimer 
	extends DisplayContainer 
	{
		//----------------------------------------------------------------------------
		// private static constants
		//----------------------------------------------------------------------------
		private static const NUMBER_X						: uint = 10;
		private static const NUMBER_Y						: uint = 12;
		//----------------------------------------------------------------------------
		// private variables
		//----------------------------------------------------------------------------
		private var _cm										: ContentModel = ContentModel.gi;
		private var _pm										: PersonalizedModel = PersonalizedModel.gi;
		private var _active									: Boolean = false;
		private var _totalTime								: uint = 0;
		//----------------------------------------------------------------------------
		// public variables
		//----------------------------------------------------------------------------
		public var numText					 				: TextField;
		public var background			 					: MovieClip;
		//----------------------------------------------------------------------------
		// constructor
		//----------------------------------------------------------------------------
		public function WebcamTimer() 
		{
			super();
			
			background = MovieClip( AssetManager.gi.getAsset( "InviterWebcamTimerAsset", SiteConstants.ASSETS_ID ) );
			
			// shikata ga nai
			background.x += background.width;
			background.scaleX *= -1;
			
			addChild( background );
			
			pauseTimer();
		}
		
		public function kill( ) : void
		{	
			removeEnterFrame();
		}
		
		public function playTimer( ) : void
		{	
			// GET TOTAL TIME FROM CURRENT QUESTION, THEN SET 
			var questionCount : uint = _pm.questionCount;
			_totalTime = _cm.getInterviewVideoItemAt( questionCount ).time;
			
//			countdown();
			background.play();
			background.addEventListener( Event.ENTER_FRAME, onTimerPlaying );
			showNum();
		}
		
		public function pauseTimer( ) : void
		{	
			if( background.hasEventListener( Event.ENTER_FRAME ))	background.removeEventListener( Event.ENTER_FRAME, onTimerPlaying );
			background.stop();
		}
		
		//----------------------------------------------------------------------------
		// private methods
		//----------------------------------------------------------------------------
		private function showNum( ) : void
		{	
			if( numText )
			{
					removeChild( numText );
					numText = null;
			}
			
			numText = getTime( _totalTime );
			numText.x = NUMBER_X;
			numText.y = NUMBER_Y;
			addChild( numText );
		}
		
		private function removeEnterFrame() : void
		{
			trace( "WEBCAMAPP : removeEnterFrame()" );
			if( background.hasEventListener(Event.ENTER_FRAME) )
				background.removeEventListener(Event.ENTER_FRAME, onTimerPlaying);
		}
		
		private function getTime( n : uint ) : TextField
		{	
			var s : String = ":" + get2DigNum( n ) as String;
			var tf : TextField = FflButtonText.makeText( s, ".redButtonText", 26);
			
			return tf
		}
		
		private function onTimerPlaying( e : Event ) : void
		{	
			var mc : MovieClip = e.target as MovieClip;
			if( mc.currentFrame ==  mc.totalFrames )
			{
				_totalTime--;
				showNum();
			}
			
			if( _totalTime == 0 )
			{
				pauseTimer();
				_pm.state = PersonalizedModel.STATE_STOPPED;
			}
		}
		
		private function get2DigNum( n : uint ) : String
		{
			var s : String = n.toString();
			if( n < 10 ) s = "0" + n.toString();
			return s; 
		}	
	}
}
