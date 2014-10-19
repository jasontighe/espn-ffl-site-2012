package com.espn.ffl.views.inviter.views {
	import com.espn.ffl.constants.SiteConstants;
	import com.espn.ffl.model.ConfigModel;
	import com.espn.ffl.model.ContentModel;
	import com.espn.ffl.model.PersonalizedModel;
	import com.espn.ffl.util.FflDropShadow;
	import com.espn.ffl.views.inviter.Inviter;
	import com.greensock.TweenLite;
	import com.jasontighe.containers.DisplayContainer;
	import com.jasontighe.managers.AssetManager;
	import com.jasontighe.utils.Box;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;

	/**
	 * @author jason.tighe
	 */
	public class WebcamFrame 
	extends DisplayContainer 
	{
		//----------------------------------------------------------------------------
		// private static constants
		//----------------------------------------------------------------------------
		private static const QUESTION_BOX_X					: uint = 1;
		private static const QUESTION_BOX_Y					: uint = 246;
		private static const CONTROLS_X						: uint = 1;
		private static const CONTROLS_Y						: uint = 295;
		//----------------------------------------------------------------------------
		// private variables
		//----------------------------------------------------------------------------
		private var _cm										: ContentModel = ContentModel.gi;
		private var _pm										: PersonalizedModel = PersonalizedModel.gi;
		private var _questionAdded							: Boolean;
		//----------------------------------------------------------------------------
		// public variables
		//----------------------------------------------------------------------------
		public var frame			 						: MovieClip;
		public var countdown		 						: WebcamCountdown;
		public var silhouette		 						: WebcamSilhouette;
		public var questionBox		 						: WebcamQuestionBox;
		public var controls			 						: WebcamControls;
		public var dialog			 						: DialogTryAgainSave;
		public var imageUploader							: PersonalizedImageUploader;
		//----------------------------------------------------------------------------
		// constructor
		//----------------------------------------------------------------------------
		public function WebcamFrame( ) 
		{
			trace( ">> WEBCAMFRAME : Constr" );
			super();
		}
		
		//----------------------------------------------------------------------------
		// public methods
		//----------------------------------------------------------------------------
		public override function init( ) : void
		{
			trace( ">> WEBCAMFRAME : init()" );
			frame = MovieClip( AssetManager.gi.getAsset( "InviterWebcamFrameAsset", SiteConstants.ASSETS_ID ) );
			addChild( frame );
			
			var awesomeDropShadow : Box = new Box( width, height );
			var filter : DropShadowFilter = FflDropShadow.getDefault();
			filter.knockout = true;
			awesomeDropShadow.filters = [ filter ];
			addChild( awesomeDropShadow );
		}
		
		public function kill() : void
		{
			trace( ">> WEBCAMFRAME : kill()" );
			killQuestionBox();
			killControls();
			killCountdown();
		}
		
		public function reset() : void
		{
			trace( ">> WEBCAMFRAME : reset()" );
			hideQuestionBox();
			hideControls();
			hideSilhouette();
			hideDialogTryAgain();
			countdown.kill();
		}

		public function showControls() : void
		{
			trace( ">> WEBCAMFRAME : showControls()" );
			if( !controls )
			{
				controls = new WebcamControls();
				controls.x = CONTROLS_X;
				controls.y = CONTROLS_Y;
			}
			addChild( controls );
			controls.showControls();
		}

		public function hideControls() : void
		{
			trace( ">> WEBCAMFRAME : hideControls()" );
			if( controls && contains( controls ) )
			{
				controls.clearBar();
				removeChild( controls );
				controls = null;
			}
		}

		public function showQuestionBox() : void
		{
			trace( ">> WEBCAMFRAME : showQuestionBox()" );
			if( !questionBox )
			{
				trace( ">> WEBCAMFRAME : showQuestionBox() : init" );
				questionBox = new WebcamQuestionBox();
				questionBox.x = QUESTION_BOX_X;
				questionBox.y = QUESTION_BOX_Y;
			}
			addChild( questionBox );
			questionBox.cleanUp()
			questionBox.showQuestion();
			
			_questionAdded = true;
		}
		
		public function hideQuestionBox() : void 
		{ 
			trace( ">> WEBCAMFRAME : hideQuestionBox() : _questionAdded is "+_questionAdded );
			if( _questionAdded )		
			{
				removeChild( questionBox );
				_questionAdded = false;
			}
		}

		public function showSilhouette( ) : void
		{
			trace( ">> WEBCAMFRAME : showSilhouette()" );
			if( !silhouette )
			{
				silhouette = new WebcamSilhouette();
				silhouette.x = 1;
				silhouette.y = 1;
				addChild( silhouette );
			}
			silhouette.alpha = 0;
			TweenLite.to( silhouette, SiteConstants.TIME_TRANSITION_IN, { alpha: 1 } );
		}
		public function hideSilhouette( ) : void
		{
			trace( ">> WEBCAMFRAME : hideSilhouette()" );
			if( silhouette )
				TweenLite.to( silhouette, SiteConstants.TIME_TRANSITION_OUT, { alpha: 0 } );
		}

		public function showCountdown() : void
		{
			trace( ">> WEBCAMFRAME : showCountdown()" );
			if( !countdown )
			{
				countdown = new WebcamCountdown();
				countdown.x = 1;
				countdown.y = 1;
			}
			addChild( countdown );
			countdown.addEventListener( Event.COMPLETE, onCountdownComplete )
			countdown.begin();
			
			var questionCount : uint = _pm.questionCount;

			var recordEarly : Boolean = _cm.getInterviewVideoItemAt( questionCount ).recordEarly;
			if( recordEarly ) 
			{
				_pm.state = PersonalizedModel.STATE_RECORDING;
			}
			trace( ">> WEBCAMFRAME : showCountdown() : recordEarly is "+recordEarly );
		}

		public function showDialogTryAgain() : void
		{
			trace( "\n\n\n\n\n\n\>> WEBCAMFRAME : showDialogTryAgain()" );
			
			if( !dialog )
			{
				dialog = new DialogTryAgainSave();
				dialog.x = 1;
				dialog.y = 1;
			}
			dialog.initText();
//			dialog.micInactiveText();
			addChild( dialog );
			dialog.addEventListener( Event.COMPLETE, onDialogTryAgainComplete );
//			dialog.activate();
			
			if( ConfigModel.gi.uploadFlvs )
			{	
				dialog.showProgress();
			}
		}
		
		private function hideDialogTryAgain() : void
		{
			trace( ">> WEBCAMFRAME : hideDialogTryAgain()" );
			if( dialog && contains( dialog ) )
				removeChild( dialog );
		}
		
		public function addImageUploader() : void
		{
			trace( ">> WEBCAMFRAME : addImageUploader()" );
			imageUploader = new PersonalizedImageUploader( );
			imageUploader.x = 1;
			imageUploader.y = 1;
			imageUploader.addEventListener( Event.COMPLETE , onImageUploadComplete )
			addChild( imageUploader );
		}
		
		public function removeImageUploader( ) : void
		{
			trace( ">> WEBCAMFRAME : removeImageUploader()" );
			if( imageUploader )
			{
				removeChild( imageUploader );
				imageUploader = null;
			}
		}
		
		protected function killQuestionBox( ) : void
		{
			trace( ">> WEBCAMFRAME : killQuestionBox()" );
			if( questionBox && contains( questionBox ) )
			{
				removeChild( questionBox );
				questionBox = null;
				_questionAdded = false;
			}
		}
		
		protected function killControls( ) : void
		{
			trace( ">> WEBCAMFRAME : killControls()" );
			if( controls )
			{
				controls.clearBar();
				controls.killTimer();
				controls.killMask();
				removeChild( controls );
				controls = null;
			}
		}
		
		protected function killCountdown( ) : void
		{
			trace( ">> WEBCAMFRAME : killCountdown()" );
			if( countdown && contains( countdown ) )
			{
				countdown.kill();
				removeChild( countdown );
				countdown = null;
			}
		}
		
		//----------------------------------------------------------------------------
		// event handlers
		//----------------------------------------------------------------------------
		private function onCountdownComplete( e : Event ) : void
		{
			countdown.removeEventListener( Event.COMPLETE, onCountdownComplete );
			removeChild( countdown );
			
			var questionCount : uint = _pm.questionCount;
			var recordEarly : Boolean = _cm.getInterviewVideoItemAt( questionCount ).recordEarly;
			trace( ">> WEBCAMFRAME : onCountdownComplete() : recordEarly is "+recordEarly );
			if( !recordEarly )	_pm.state = PersonalizedModel.STATE_RECORDING;
		}
		
		private function onDialogTryAgainComplete( e : Event ) : void
		{
			dialog.removeEventListener( Event.COMPLETE, onDialogTryAgainComplete );
			hideDialogTryAgain();
		}
		
		private function onImageUploadComplete( e : Event ) : void
		{
			removeImageUploader();
			showDialogTryAgain();
		}
	}
}
