package com.espn.ffl.views.inviter {
	import com.espn.ffl.constants.SiteConstants;
	import com.espn.ffl.model.InviterModel;
	import com.espn.ffl.model.PersonalizedModel;
	import com.espn.ffl.model.events.PersonalizedEvent;
	import com.espn.ffl.views.AbstractView;
	import com.espn.ffl.views.inviter.views.InviterAddWebcam;
	import com.espn.ffl.views.inviter.views.InviterCompleted;
	import com.espn.ffl.views.inviter.views.InviterFlush;
	import com.espn.ffl.views.inviter.views.InviterIntro;
	import com.espn.ffl.views.inviter.views.InviterLearn;
	import com.espn.ffl.views.inviter.views.InviterPositioner;
	import com.espn.ffl.views.inviter.views.InviterQuestion;
	import com.espn.ffl.webcam.WebcamApp;
	import com.jasontighe.containers.events.ContainerEvent;

	import flash.display.MovieClip;

	/**
	 * @author jason.tighe
	 */
	public class Personalized 
	extends AbstractView
	{
		//----------------------------------------------------------------------------
		// private static constants
		//----------------------------------------------------------------------------
		private static const COOKIE_NAME					: String = "espnFflLIInstructions";
		//----------------------------------------------------------------------------
		// private variables
		//----------------------------------------------------------------------------
		private var _pm										: PersonalizedModel;
		private var _currentView							: AbstractView;
		private var _im										: InviterModel = InviterModel.gi;
		private var _isReset								: Boolean = false;
		//----------------------------------------------------------------------------
		// public variables
		//----------------------------------------------------------------------------
		public var holder									: MovieClip;
		public var intro									: InviterIntro;
		public var addWebcam								: InviterAddWebcam;
		public var positioner								: InviterPositioner;
		public var learn									: InviterLearn;
		public var question									: InviterQuestion;
		public var completed								: InviterCompleted;
		public var preview									: Preview;
		public var flush									: InviterFlush; 
		//----------------------------------------------------------------------------
		// constructor
		//----------------------------------------------------------------------------
		public function Personalized() 
		{
			super();
			trace( "PERSONALIZED : Constr" );
		}
		
		//----------------------------------------------------------------------------
		// public methods
		//----------------------------------------------------------------------------
		public function showDefaultView() : void 
		{ 
			trace( "PREMADE : showDefaultView()" );

			trace( "PERSONALIZED : checkIfViewed() : InviterModel.gi.status is "+InviterModel.gi.status );
			switch( InviterModel.gi.status )
			{	
				case InviterModel.STATUS_NEW:
					_pm.state = PersonalizedModel.STATE_INTRO;
					break;
					
				case InviterModel.STATUS_CREATED:
					_pm.state = PersonalizedModel.STATE_CREATED;
					break;
			}
		}
		
		public override function reset( ) : void
		{
			trace( "\n\n\n\nPERSONALIZED : reset() $ $ $ $ $ $ $ $ $ $ $ $ $" );
			if( question )
			{	
				trace( "PERSONALIZED : reset() THIS IS HAPPENING\n\n\n\n" );
				question.reset();
				question.questionBoxAdded = false;
//				holder.removeChild( question );
				question = null;
			}
		}
		
		public function pause() : void
		{
			if( preview && holder.contains( preview ) )
			{
				preview.pause();
			}
		}

		//----------------------------------------------------------------------------
		// protected methods
		//----------------------------------------------------------------------------
//		protected function transitionInComplete() : void { }
//		protected function transitionOutComplete() : void { }

		protected override function addViews() : void 
		{ 
			addHolder();
			addPersonalziedModel();
		}
		
		protected function addHolder() : void 
		{ 
			holder = new MovieClip();
			addChild( holder );
		}

		protected function addPersonalziedModel() : void
		{
			_pm = PersonalizedModel.gi;
			_pm.addEventListener( PersonalizedEvent.INTRO, onStateChange );
			_pm.addEventListener( PersonalizedEvent.ADD_WEBCAM, onStateChange );
			_pm.addEventListener( PersonalizedEvent.POSTIONER, onStateChange );
			_pm.addEventListener( PersonalizedEvent.QUESTION, onStateChange );
			_pm.addEventListener( PersonalizedEvent.READY, onStateChange );
			_pm.addEventListener( PersonalizedEvent.COUNTDOWN, onStateChange );
			_pm.addEventListener( PersonalizedEvent.RECORDING, onStateChange );
			_pm.addEventListener( PersonalizedEvent.ADD_PHOTO, onStateChange );
			_pm.addEventListener( PersonalizedEvent.STOPPED, onStateChange );
			_pm.addEventListener( PersonalizedEvent.COMPLETED, onStateChange );
			_pm.addEventListener( PersonalizedEvent.CREATED, onStateChange );
			_pm.addEventListener( PersonalizedEvent.FLUSH, onStateChange );
		}
		
		protected function showIntro() : void 
		{ 
			trace( "PERSONALIZED : showIntro()" );
			if( !intro )
			{	
				intro = new InviterIntro();
				intro.init();
			}
			holder.addChild( intro );
			
			intro.animateIn();
			
			_currentView = intro;
		}
		
		protected function showAddWebcamView() : void 
		{ 
			trace( "PERSONALIZED : showAddWebcamView()" );
			if( !addWebcam )
			{	
				addWebcam = new InviterAddWebcam();
				addWebcam.init();
			}
			Inviter.instance.addWebcamFrame();
			holder.addChild( addWebcam );
			
			_currentView = addWebcam;
		}
		
		protected function removeAddWebcam() : void 
		{ 
			trace( "PERSONALIZED : showAddWebcam()" );
			if( !addWebcam )
			{
				holder.removeChild( addWebcam );	
			}
		}
		
		protected function showPositioner() : void 
		{ 
			trace( "PERSONALIZED : showPositioner()" );
			if( !positioner )
			{	
				positioner = new InviterPositioner();
				positioner.init();
			}
			positioner.showDefaultView();
			Inviter.instance.addWebcamApp();
			Inviter.instance.showWebcamSilhouette();
			holder.addChild( positioner );
			
			_currentView = positioner;
		}
		
		protected function showQuestion() : void 
		{ 
//			trace( "PERSONALIZED : showQuestion() : question is "+question );
//			trace( "PERSONALIZED : showQuestion() : contains( question )  is "+contains( question ) );
			if( !question )
			{	
				question = new InviterQuestion();
				question.init();
			}
			holder.addChild( question );
			
			_currentView = question;
			question.playPerryVideo();
		}
		
		protected function showReady() : void 
		{ 
			question.showReady();
		}
		
		protected function showAddPhoto() : void 
		{ 
		}
		
		protected function showCountdown() : void 
		{ 
			question.showCountdown();
			Inviter.instance.getWebcamApp().startRecordingAudio();
		}
		
		protected function showRecording() : void 
		{ 
			trace( "PERSONALIZED : showRecording()" );

			_isReset = false
			Inviter.instance.getWebcamApp().startRecordingVideo();
		}

		protected function showStopped() : void 
		{ 
			if( !_isReset ) question.showStopped();
			
			Inviter.instance.getWebcamApp().startEncoding();
		}
		
		protected function showCompleted() : void 
		{ 
			trace( "PERSONALIZED : showCompleted()" );
			if( !completed )
			{	
				completed = new InviterCompleted();
				completed.init();
			}
			holder.addChild( completed );
			Inviter.instance.removeWebcamAssets();
			
			_currentView = completed;
		}
		
		protected function showFlush() : void 
		{ 
			trace( "PERSONALIZED : showFlush()" );
			if( !flush )
			{	
				flush = new InviterFlush();
				flush.init();
			}
			holder.addChild( flush );
			
			_currentView = flush;
		}
		
		protected function showCreated() : void 
		{ 
			trace( "PERSONALIZED : showCreated() : SHOW MOTHER P COMPLETED!" );
			if( !preview )
			{	
				preview = new Preview();
				preview.init();
			}
			holder.addChild( preview );
			
			_currentView = preview;
		}
		
		protected function showView( ) : void 
		{ 
			trace( "\n*******************************************" );
			trace( "PERSONALIZED : showView()" );
			var state : String = _pm.state;

			switch( state )
			{
				case PersonalizedModel.STATE_INTRO:
					showIntro();
					_im.interviewStarted = false;
					break;
				case PersonalizedModel.STATE_ADD_WEBCAM:
					showAddWebcamView();
					break;
				case PersonalizedModel.STATE_POSTIONER:
					showPositioner();
					break;
				case PersonalizedModel.STATE_QUESTION:
					showQuestion();
					_im.interviewStarted = true;
					break;
				case PersonalizedModel.STATE_READY:
					showReady();
					break;
				case PersonalizedModel.STATE_COUNTDOWN:
					showCountdown();
					break;
				case PersonalizedModel.STATE_RECORDING:
					_pm.isReset = false;
					showRecording();
					break;
				case PersonalizedModel.STATE_ADD_PHOTO:
					showAddPhoto();
					break;
				case PersonalizedModel.STATE_STOPPED:
					showStopped();
					break;
				case PersonalizedModel.STATE_COMPLETED:
					showCompleted();
					break;
				case PersonalizedModel.STATE_CREATED:
					showCreated();
					break;
//				case PersonalizedModel.STATE_RESET:
//					reset();
//					break;
				case PersonalizedModel.STATE_FLUSH:
					reset();
					_pm.isReset = true;
					Inviter.instance.removeWebcamAssets();
					showFlush();
					break;
			}
			
			_currentView.addEventListener( ContainerEvent.SHOW, showViewComplete );
			_currentView.show( SiteConstants.TIME_TRANSITION_IN );
			_pm.previousState = state;
		}
		
		protected function showViewComplete( e : ContainerEvent ) : void 
		{ 
			trace( "PERSONALIZED : showViewComplete()" );
			_currentView.removeEventListener( ContainerEvent.SHOW, showViewComplete );
		}
		
		protected function hideView() : void 
		{ 
			trace( "\n*******************************************" );
			trace( "PERSONALIZED : hideView() _currentView is "+_currentView );
			_currentView.addEventListener( ContainerEvent.HIDE, hideViewComplete );
			_currentView.hide( SiteConstants.TIME_TRANSITION_OUT );
			
			if (question) question.clearTimeouts();
		}
		
		protected function hideViewComplete( e : ContainerEvent ) : void 
		{ 
			trace( "PERSONALIZED : hideViewComplete()" );
			_currentView.addEventListener( ContainerEvent.HIDE, hideViewComplete );
			removeChildrenFromHolder();
			showView();
		}
		
		protected function removeChildrenFromHolder( ) : void 
		{ 
			trace( "PERSONALIZED : removeChildrenFromHolder()" );
			// REMOVE CHILDREN TODO CLEAN THIS UP
			for ( var i:uint = 0; i < holder.numChildren; i++)
			{
				var object : * = holder.getChildAt(i);
				trace( "PERSONALIZED : onStateChange() : object is "+object );
				
				holder.removeChildAt(i);
				object = null;
			}
		}
		
		//----------------------------------------------------------------------------
		// event handlers
		//----------------------------------------------------------------------------
		protected function onStateChange( e : PersonalizedEvent ) : void
		{	
			trace( "PERSONALIZED : onStateChange()" );
			var state : String = e.type;
			var previousState : String = _pm.previousState;
			trace( "PERSONALIZED : onStateChange() : state is "+state );
			trace( "PERSONALIZED : onStateChange() : previousState is "+previousState );
//			if( previousState == null || state == PersonalizedModel.STATE_LEARN ) {

			if( previousState == null || 
				state ==  PersonalizedModel.STATE_READY ||
				state ==  PersonalizedModel.STATE_COUNTDOWN ||
				state ==  PersonalizedModel.STATE_RECORDING ||
				state ==  PersonalizedModel.STATE_ADD_PHOTO ||
				state ==  PersonalizedModel.STATE_STOPPED )
			{
//				trace( "PERSONALIZED : onStateChange() : THE PREVIOUS STATE IS NULL! : state is "+state );
//				trace( "PERSONALIZED : onStateChange() : THE PREVIOUS STATE IS NULL! : previousState is "+previousState );
				showView();
			}
			else
			{
				hideView();
			}
		}
	}
}
