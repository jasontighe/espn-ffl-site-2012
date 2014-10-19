package com.espn.ffl.views.inviter.views {
	import leelib.util.TextFieldUtil;

	import com.espn.ffl.constants.SiteConstants;
	import com.espn.ffl.model.ContentModel;
	import com.espn.ffl.model.InviterModel;
	import com.espn.ffl.model.PersonalizedModel;
	import com.espn.ffl.util.FflDropShadow;
	import com.espn.ffl.views.AbstractView;
	import com.espn.ffl.views.FflButton;
	import com.jasontighe.managers.AssetManager;

	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.text.TextField;

	/**
	 * @author jason.tighe
	 */
	public class InviterLearn
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
		//----------------------------------------------------------------------------
		// private variables
		//----------------------------------------------------------------------------
		private var _inviterModel							: InviterModel;
		private var _currentView							: AbstractView;
		//----------------------------------------------------------------------------
		// public variables
		//----------------------------------------------------------------------------
		public var title									: TextField;
		public var step1									: MovieClip; 
		public var step2									: MovieClip;
		public var stopBtn									: MovieClip;
		public var countdown								: MovieClip;
		//----------------------------------------------------------------------------
		// constructor
		//----------------------------------------------------------------------------
		public function InviterLearn() 
		{
			super();
			trace( "INVITERLEARN : Constr" );
		}
		
		protected override function addViews() : void 
		{ 
			trace( "INVITERLEARN : addViews()" );
			background = MovieClip( AssetManager.gi.getAsset( "InviterLearnAsset", SiteConstants.ASSETS_ID ) );
			addChild( background );
			
			step1 = background.step1;
			step2 = background.step2;
			countdown = background.countdown;
			stopBtn = background.stopBtn;
			stopBtn.filters = [ FflDropShadow.getDefault() ];
			
			// FOR ALL TEXT
			var textId : String;
			var cssId : String;
			var copy : String;
			var xPos : int;
			var yPos : int;
			var tf : TextField;
			
			//STEPS
			cssId = ".inviter-learn-steps";
			
			textId = "inviter-learn-step1";
			copy = ContentModel.gi.getCopyItemByName( textId ).copy;
			tf = TextFieldUtil.makeText( copy, cssId);
			xPos = ContentModel.gi.getCopyItemByName( textId ).xPos;
			yPos = ContentModel.gi.getCopyItemByName( textId ).yPos;
			tf.x = xPos;
			tf.y = yPos;
			step1.addChild( tf );
			
			textId = "inviter-learn-step2";
			copy = ContentModel.gi.getCopyItemByName( textId ).copy;
			tf = TextFieldUtil.makeHtmlText( copy, cssId, 300, 100 );
			xPos = ContentModel.gi.getCopyItemByName( textId ).xPos;
			yPos = ContentModel.gi.getCopyItemByName( textId ).yPos;
			tf.x = xPos;
			tf.y = yPos;
			step2.addChild( tf );
			
			// TITLE
			textId = "inviter-learn-title";
			cssId = ".inviter-intro-title";
			copy = ContentModel.gi.getCopyItemByName( textId ).copy;
			title = TextFieldUtil.makeText( copy, cssId );
			xPos = ContentModel.gi.getCopyItemByName( textId ).xPos;
			yPos = ContentModel.gi.getCopyItemByName( textId ).yPos;
			title.x = xPos;
			title.y = yPos;
			addChild( title );
			title.filters = [ FflDropShadow.getDefault() ];
			
			textId = "inviter-learn-desc";
			cssId = "." + textId;
			copy = ContentModel.gi.getCopyItemByName( textId ).copy;
			tf = TextFieldUtil.makeHtmlText( copy, cssId, 400, 200 );
			xPos = ContentModel.gi.getCopyItemByName( textId ).xPos;
			yPos = ContentModel.gi.getCopyItemByName( textId ).yPos;
			tf.x = xPos;
			tf.y = yPos;
			addChild( tf );
			
			copy = ContentModel.gi.getCopyItemByName( "inviter-learn-button" ).copy;
			var fflButton : FflButton = new FflButton( copy, BUTTON_WIDTH, BUTTON_HEIGHT, BUTTON_SIZE, FflButton.BACKGROUNDTYPE_GREEN, false );
			fflButton.x = BUTTON_X;
			fflButton.y = BUTTON_Y;
			addChild( fflButton );
			
			fflButton.addEventListener( Event.SELECT, onButtonClicked )
		}
		
		//----------------------------------------------------------------------------
		// event handlers
		//----------------------------------------------------------------------------
		protected function onButtonClicked( e : Event ) : void
		{	
			PersonalizedModel.gi.state = PersonalizedModel.STATE_LEARN;
		}
	}
}
