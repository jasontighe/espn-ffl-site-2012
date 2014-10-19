package com.espn.ffl.views.inviter.views {
	import leelib.util.TextFieldUtil;

	import com.espn.ffl.constants.SiteConstants;
	import com.espn.ffl.model.ContentModel;
	import com.espn.ffl.model.InviterModel;
	import com.espn.ffl.model.PersonalizedModel;
	import com.espn.ffl.util.FflDropShadow;
	import com.espn.ffl.util.Metrics;
	import com.espn.ffl.views.AbstractView;
	import com.espn.ffl.views.FflButton;
	import com.espn.ffl.views.inviter.Inviter;
	import com.greensock.TweenLite;
	import com.jasontighe.containers.events.ContainerEvent;
	import com.jasontighe.managers.AssetManager;

	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.media.Camera;
	import flash.text.TextField;

	/**
	 * @author jason.tighe
	 */
	public class InviterPositioner
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
		private static const POSITIONER						: String = "positioner";
		private static const LEARN							: String = "learn";
		//----------------------------------------------------------------------------
		// private variables
		//----------------------------------------------------------------------------
		private var _inviterModel							: InviterModel;
		private var _currentView							: AbstractView;
		private var _cm										: ContentModel = ContentModel.gi;
		private var _state									: String;
		//----------------------------------------------------------------------------
		// public variables
		//----------------------------------------------------------------------------
		public var title									: TextField;
		public var desc										: TextField;
		public var screen									: MovieClip;
		public var marker									: MovieClip;
		public var fflButton								: FflButton;
		// LEARN
		public var step1									: MovieClip; 
		public var step2									: MovieClip;
		public var stopBtn									: MovieClip;
		public var countdown								: MovieClip;
		public var positionerHolder							: MovieClip;
		public var learnHolder								: MovieClip;
		//----------------------------------------------------------------------------
		// constructor
		//----------------------------------------------------------------------------
		public function InviterPositioner() 
		{
			super();
			trace( "INVITERPOSITIONER : Constr" );
		}
		
		//----------------------------------------------------------------------------
		// public methods
		//----------------------------------------------------------------------------
		public override function reset() : void 
		{
		
		}
		public function showDefaultView() : void 
		{
			addPositionerViews();
		}
		
		//----------------------------------------------------------------------------
		// protected methods
		//----------------------------------------------------------------------------
		protected override function addViews() : void 
		{ 
			trace( "INVITERPOSITIONER : addViews()" );
//			var tf : TextField;
			
//			Inviter.instance.addWebcamApp();
//			Inviter.instance.showWebcamSilhouette();

			// Positioner Views
//			positionerHolder = new MovieClip();
//			addChild( positionerHolder );
//			// Positioner Title
//			title  = TextFieldUtil.makeTextWithCopyDto( _cm.getCopyItemByName("liPositionerTitle") );
//			addChild( title );
//			title.filters = [ FflDropShadow.getDefault() ];
//			// Positioner Desc
//			desc  = TextFieldUtil.makeHtmlTextWithCopyDto( _cm.getCopyItemByName("liPositionerDesc"), 400, 200 );
//			addChild( desc );
//			
//			var copy : String = ContentModel.gi.getCopyItemByName( "liPositionerButton" ).copy;
//			fflButton = new FflButton( copy, BUTTON_WIDTH, BUTTON_HEIGHT, BUTTON_SIZE, FflButton.BACKGROUNDTYPE_GREEN, false );
//			fflButton.x = BUTTON_X;
//			fflButton.y = BUTTON_Y;
//			addChild( fflButton );
//			
//			fflButton.addEventListener( Event.SELECT, onButtonClicked );
		}
		
		protected function addPositionerViews() : void 
		{
			
			// TITLE
			title  = TextFieldUtil.makeTextWithCopyDto( _cm.getCopyItemByName("liPositionerTitle") );
			addChild( title );
			title.filters = [ FflDropShadow.getDefault() ];
			
			desc  = TextFieldUtil.makeHtmlTextWithCopyDto( _cm.getCopyItemByName("liPositionerDesc"), 400, 200 );
			addChild( desc );
			
			var copy : String = ContentModel.gi.getCopyItemByName( "liPositionerButton" ).copy;
			fflButton = new FflButton( copy, BUTTON_WIDTH, BUTTON_HEIGHT, BUTTON_SIZE, FflButton.BACKGROUNDTYPE_GREEN, false );
			fflButton.x = BUTTON_X;
			fflButton.y = BUTTON_Y;
			addChild( fflButton );
			
			fflButton.addEventListener( Event.SELECT, onButtonClicked );
			
			_state = POSITIONER;
		}
		
		protected function removePositionerViews() : void 
		{ 
			trace( "INVITERPOSITIONER : removePositionerViews()" );
			removeChild( fflButton );
			removeChild( title );
			removeChild( desc );
			
			fflButton = null;
			title = null;
			desc = null;
		}
		
		protected function addLearnViews() : void 
		{ 
			trace( "INVITERPOSITIONER : addLearnViews()" );
			
			learnHolder = new MovieClip();
			addChild( learnHolder );
			learnHolder.alpha = 0;
			
			var learnBg : MovieClip = MovieClip( AssetManager.gi.getAsset( "InviterLearnAsset", SiteConstants.ASSETS_ID ) );
			learnHolder.addChild( learnBg );
			
			step1 = learnBg.step1;
			step2 = learnBg.step2;
			countdown = learnBg.countdown;
			stopBtn = learnBg.stopBtn;
			stopBtn.filters = [ FflDropShadow.getDefault() ];
			
			learnHolder.addChild( step1 );
			learnHolder.addChild( step2 );
			learnHolder.addChild( countdown );
			learnHolder.addChild( stopBtn );
			
			// FOR ALL TEXT
			var tf : TextField;
			
			// TITLE
			title = TextFieldUtil.makeTextWithCopyDto( _cm.getCopyItemByName("liLearnTitle") );
			learnHolder.addChild( title );
			title.filters = [ FflDropShadow.getDefault() ];
			
			desc = TextFieldUtil.makeHtmlTextWithCopyDto( _cm.getCopyItemByName("liLearnDesc"), 400, 200 );
			learnHolder.addChild( desc );
			
			//STEPS
			tf = TextFieldUtil.makeHtmlTextWithCopyDto( _cm.getCopyItemByName("liLearnStep1"), 310, 100 );
			step1.addChild( tf );
			
			tf = TextFieldUtil.makeHtmlTextWithCopyDto( _cm.getCopyItemByName("liLearnStep2"), 300, 100 );
			step2.addChild( tf );
			
			var copy : String = _cm.getCopyItemByName( "liLearnButton" ).copy;
			fflButton = new FflButton( copy, BUTTON_WIDTH, BUTTON_HEIGHT, BUTTON_SIZE, FflButton.BACKGROUNDTYPE_GREEN, false );
			fflButton.x = BUTTON_X;
			fflButton.y = BUTTON_Y;
			learnHolder.addChild( fflButton );
			
			fflButton.addEventListener( Event.SELECT, onLearnButtonClicked );
			
			_state = LEARN;
		}
		
		protected function removeLearnViews() : void 
		{ 
			trace( "INVITERPOSITIONER : removeLearnViews()" );
			learnHolder.removeChild( fflButton );
			learnHolder.removeChild( title );
			learnHolder.removeChild( desc );
			removeChild( learnHolder );
			
			fflButton = null;
			title = null;
			desc = null;
			learnHolder = null
		}
		
		protected function removeCurrentView() : void 
		{ 
			switch ( _state )
			{
				case POSITIONER:
					removePositionerViews();
					break;
				case LEARN:
					removeLearnViews();
					break;			
			}
		}
		
		//----------------------------------------------------------------------------
		// event handlers
		//----------------------------------------------------------------------------
		protected function onButtonClicked( e : Event ) : void
		{	
			Metrics.pageView("inviterCustomizeImInButton");
			
			fflButton.removeEventListener( Event.SELECT, onButtonClicked );
			Inviter.instance.hideWebcamSilhouette();
			
			removePositionerViews();
			addLearnViews();
			TweenLite.to( learnHolder, SiteConstants.TIME_TRANSITION_IN, { alpha: 1 } );
		}

		protected function onLearnButtonClicked( e : Event ) : void
		{	
			Metrics.pageView("inviterCustomizeGotItButton");
			
			fflButton.removeEventListener( Event.SELECT, onLearnButtonClicked );
			PersonalizedModel.gi.state = PersonalizedModel.STATE_QUESTION;
		}
		
		protected override function onHideComplete ( e : Event = null ) : void
		{
			
			removeCurrentView();
			visible = false;
			dispatchEvent( new ContainerEvent( ContainerEvent.HIDE ) );
		}
	}
}
