package com.espn.ffl.views.inviter.views {
	import com.espn.ffl.constants.SiteConstants;
	import com.espn.ffl.model.ContentModel;
	import com.espn.ffl.model.InviterModel;
	import com.espn.ffl.model.PersonalizedModel;
	import com.espn.ffl.util.FflDropShadow;
	import com.espn.ffl.util.Metrics;
	import com.espn.ffl.views.AbstractView;
	import com.espn.ffl.views.FflButton;
	import com.espn.ffl.views.inviter.Inviter;
	import com.jasontighe.managers.AssetManager;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.text.TextField;
	
	import leelib.util.TextFieldUtil;

	/**
	 * @author jason.tighe
	 */
	public class InviterAddWebcam
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
		private var _cm										: ContentModel = ContentModel.gi;
		//----------------------------------------------------------------------------
		// public variables
		//----------------------------------------------------------------------------
		public var title									: TextField;
		public var screen									: MovieClip;
		//----------------------------------------------------------------------------
		// constructor
		//----------------------------------------------------------------------------
		public function InviterAddWebcam() 
		{
			super();
			trace( "INVITERADDWEBCAM : Constr" );
		}
		
		protected override function addViews() : void 
		{ 
			trace( "INVITERADDWEBCAM : addViews()" );
			background = MovieClip( AssetManager.gi.getAsset( "InviterAddWebcamAsset", SiteConstants.ASSETS_ID ) );
			addChild( background );
			
//			Inviter.instance.addWebcamFrame();
			
			// TITLE
			
			title = TextFieldUtil.makeTextWithCopyDto( _cm.getCopyItemByName("liAddWebcamTitle") );
			addChild( title );
			title.filters = [ FflDropShadow.getDefault() ];
			
			var tf : TextField
			
			tf  = TextFieldUtil.makeHtmlTextWithCopyDto( _cm.getCopyItemByName("liAddWebcamDesc"), 300, 100 );
			addChild( tf );
			
//			tf  = TextFieldUtil.makeHtmlTextWithCopyDto( _cm.getCopyItemByName("liAddWebcamChrome"), 500, 30 );
//			addChild( tf );
			
			var copy : String = ContentModel.gi.getCopyItemByName( "liAddWebcamButton" ).copy;
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
			Metrics.pageView("inviterCustomizeConnectButton");
			
			PersonalizedModel.gi.state = PersonalizedModel.STATE_POSTIONER;
		}
	}
}
