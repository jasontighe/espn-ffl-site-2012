package com.espn.ffl.views.inviter.views {
	import com.espn.ffl.constants.SiteConstants;
	import com.espn.ffl.model.ContentModel;
	import com.espn.ffl.model.InviterModel;
	import com.espn.ffl.model.PersonalizedModel;
	import com.espn.ffl.util.Metrics;
	import com.espn.ffl.views.AbstractView;
	import com.espn.ffl.views.FflButton;
	import com.greensock.TweenLite;
	import com.greensock.easing.Bounce;
	import com.greensock.easing.Quart;
	import com.jasontighe.managers.AssetManager;
	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.utils.setTimeout;
	
	import leelib.graphics.GrUtil;
	import leelib.util.TextFieldUtil;

	/**
	 * @author jason.tighe
	 */
	public class InviterIntro
	extends AbstractView 
	{
		//----------------------------------------------------------------------------
		// private static constants
		//----------------------------------------------------------------------------
		private static const BUTTON_WIDTH					: uint = 261;
		private static const BUTTON_HEIGHT					: uint = 47;
		private static const BUTTON_SIZE					: uint = 22;
		private static const BUTTON_X						: uint = 310;
		private static const BUTTON_Y						: uint = 465;
		//----------------------------------------------------------------------------
		// private variables
		//----------------------------------------------------------------------------
		private var _inviterModel							: InviterModel;
		private var _currentView							: AbstractView;
		private var _cm										: ContentModel = ContentModel.gi;
		private var _didAnimIn								: Boolean;
		//----------------------------------------------------------------------------
		// public variables
		//----------------------------------------------------------------------------
		public var asterik									: MovieClip; 
		public var step1									: MovieClip; 
		public var step2									: MovieClip;
		public var step3									: MovieClip;
		public var step4									: MovieClip;
		public var title									: TextField;
		//----------------------------------------------------------------------------
		// constructor
		//----------------------------------------------------------------------------
		public function InviterIntro() 
		{
			super();
			trace( "INVITERINTRO : Constr" );
		}
		
		protected override function addViews() : void 
		{ 
			trace( "INVITERINTRO : addViews()" );
			background = MovieClip( AssetManager.gi.getAsset( "InviterIntroAsset", SiteConstants.ASSETS_ID ) );
			addChild( background );
			
			asterik = background.asterik;
			step1 = background.step1;
			step2 = background.step2;
			step3 = background.step3;
			step4 = background.step4;
			
			// FOR ALL TEXT
			var tf : TextField;
			
			// TITLE
			title = TextFieldUtil.makeTextWithCopyDto( _cm.getCopyItemByName("liIntroTitle"));
			title.x = Math.round( ( background.width - title.width ) * .5 );
			addChild( title );
			
			//STEPS
			tf = TextFieldUtil.makeHtmlTextWithCopyDto( _cm.getCopyItemByName("liIntroStep1"), 300, 100 );
			tf.name = "tf";
			step1.addChild( tf );
			
			tf = TextFieldUtil.makeHtmlTextWithCopyDto( _cm.getCopyItemByName("liIntroStep2"), 300, 100 );
			tf.name = "tf";
			step2.addChild( tf );
			
			tf = TextFieldUtil.makeHtmlTextWithCopyDto( _cm.getCopyItemByName("liIntroStep3"), 300, 100 );
			tf.name = "tf";
			step3.addChild( tf );
			
			tf = TextFieldUtil.makeHtmlTextWithCopyDto( _cm.getCopyItemByName("liIntroStep4"), 300, 100 );
			tf.name = "tf";
			step4.addChild( tf );
			
			var copy : String = _cm.getCopyItemByName( "liIntroButton" ).copy;
			var fflButton : FflButton = new FflButton( copy, BUTTON_WIDTH, BUTTON_HEIGHT, BUTTON_SIZE, FflButton.BACKGROUNDTYPE_GREEN, false );
			fflButton.x = BUTTON_X;
			fflButton.y = BUTTON_Y;
			addChild( fflButton );
			
			var asterikHolder : MovieClip = new MovieClip();
			addChild( asterikHolder );
			asterikHolder.addChild( asterik );
			
			tf = TextFieldUtil.makeHtmlTextWithCopyDto( _cm.getCopyItemByName("liIntroTerms"), 400, 30 );
			addChild( tf );
			
			fflButton.addEventListener( Event.SELECT, onButtonClicked )
		}
		
		public function animateIn():void
		{
			if (_didAnimIn) return;
			
			var steps:Array = [step1, step2, step3, step4];
			
			var circles:Array = []
			for (var i:int = 0; i < steps.length; i++) {
				circles[i] = steps[i].circle;
				circles[i].scaleX = circles[i].scaleY = 0; 
			}

			var tfs:Array = [];
			for (i = 0; i < steps.length; i++) {
				tfs[i] = steps[i].getChildByName("tf") as TextField;
				tfs[i].alpha = 0;
			}
			
			var masks:Array = [];
			for (i = 0; i < steps.length; i++) {
				masks[i] = steps[i].mask;
				masks[i].scaleX = 0;
				steps[i].mask = masks[i];
			}
			
			//
			
			var animInStep:Function = function(index:int):void
			{
				TweenLite.to(masks[index], 0.5, { delay:0, scaleX:1, ease:Quart.easeIn, onComplete:function():void{ 
					steps[index].mask = null;
					masks[index].visible = false;
				} } );

				TweenLite.to(circles[index], 0.5, { delay:0.33, scaleX:1, scaleY:1, ease:Bounce.easeOut } );
				
				TweenLite.to(tfs[index], 0.5, { delay:0.5, alpha:1, ease:Quart.easeOut } );
			}

			
			for (i = 0; i < steps.length; i++)
			{
				setTimeout(animInStep, 500*i, i);
			}
			
			_didAnimIn = true;
		}
		
		//----------------------------------------------------------------------------
		// event handlers
		//----------------------------------------------------------------------------
		protected function onButtonClicked( e : Event ) : void
		{	
			PersonalizedModel.gi.state = PersonalizedModel.STATE_ADD_WEBCAM;
			
			Metrics.pageView("inviterCustomizeGetStartedButton");
		}
	}
}
