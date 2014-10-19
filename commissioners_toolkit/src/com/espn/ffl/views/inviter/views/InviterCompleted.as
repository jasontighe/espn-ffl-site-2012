package com.espn.ffl.views.inviter.views {
	import leelib.util.TextFieldUtil;

	import com.espn.ffl.apis.http.HusaniRequestor;
	import com.espn.ffl.constants.SiteConstants;
	import com.espn.ffl.model.ConfigModel;
	import com.espn.ffl.model.ContentModel;
	import com.espn.ffl.model.InviterModel;
	import com.espn.ffl.model.PersonalizedModel;
	import com.espn.ffl.model.StateModel;
	import com.espn.ffl.util.FflDropShadow;
	import com.espn.ffl.util.Metrics;
	import com.espn.ffl.views.AbstractView;
	import com.espn.ffl.views.FflButton;
	import com.espn.ffl.views.Main;
	import com.espn.ffl.views.inviter.Inviter;
	import com.greensock.TweenLite;
	import com.greensock.easing.Quad;
	import com.jasontighe.managers.AssetManager;

	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.text.TextField;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;

	/**
	 * @author jason.tighe
	 */
	public class InviterCompleted 
	extends AbstractView 
	{
		//----------------------------------------------------------------------------
		// private static constants
		//----------------------------------------------------------------------------
		private static const BUTTON_WIDTH					: uint = 261;
		private static const BUTTON_HEIGHT					: uint = 47;
		private static const BUTTON_SIZE					: uint = 22;
		private static const BUTTON_X						: uint = 310;
		private static const BUTTON_Y						: uint = 473;
		private static const DEBUG_WIDTH					: uint = 880;
		private static const DEBUG_HEIGHT					: uint = 465;
		private static const TIME_OUT						: uint = 150000;
		//----------------------------------------------------------------------------
		// private variables
		//----------------------------------------------------------------------------
		private var _cm										: ContentModel = ContentModel.gi;
		private var _pm										: PersonalizedModel = PersonalizedModel.gi;
		private var _cf										: ConfigModel = ConfigModel.gi;
		private var _im										: InviterModel = InviterModel.gi;
		private var _to										: uint;
		//----------------------------------------------------------------------------
		// public variables
		//----------------------------------------------------------------------------
		public var check				 					: MovieClip;
		//----------------------------------------------------------------------------
		// constructor
		//----------------------------------------------------------------------------
		public function InviterCompleted() 
		{
			super();
			
			background = MovieClip( AssetManager.gi.getAsset( "InviterCompletedAsset", SiteConstants.ASSETS_ID ) );
			addChild( background );
			
			check = background.check;
			check.alpha = 0;
			
			// FOR ALL TEXT
			var tf : TextField;
			var dtoTitleName : String;
			var dtoDescName : String;
			var copy : String;
			
			// TITLE
			if( _cf.isPressPreview)
			{	
				dtoTitleName = "liCompletedPressTitle";
				dtoDescName = "liCompletedPressDesc";
			}
			else
			{
				dtoTitleName = "liCompletedTitle";
				dtoDescName = "liCompletedDesc";
			}
			tf = TextFieldUtil.makeTextWithCopyDto( _cm.getCopyItemByName(dtoTitleName));
			tf.x = Math.round( ( background.width - tf.width ) * .5 );
			addChild( tf );
			tf.filters = [ FflDropShadow.getDefault() ];
			
			copy = _cm.getCopyItemByName(dtoTitleName).copy;
			trace( "INVITERCOMPLETED : tf is "+tf );
			trace( "INVITERCOMPLETED : title is "+copy );
			
			var newTf : TextField;
			newTf = TextFieldUtil.makeHtmlTextWithCopyDto( _cm.getCopyItemByName(dtoDescName), 800, 50);
			newTf.x = Math.round( ( background.width - newTf.width ) * .5 );
			addChild( newTf );
			tf.filters = [ FflDropShadow.getDefault() ];
			
			copy = _cm.getCopyItemByName(dtoDescName).copy;
			trace( "INVITERCOMPLETED : newTf is "+newTf );
			trace( "INVITERCOMPLETED : desc is "+copy );
			
			copy = _cm.getCopyItemByName( "liCompletedButton" ).copy;
			var fflButton : FflButton = new FflButton( copy, BUTTON_WIDTH, BUTTON_HEIGHT, BUTTON_SIZE, FflButton.BACKGROUNDTYPE_BLUE, false );
			fflButton.x = BUTTON_X;
			fflButton.y = BUTTON_Y;
			addChild( fflButton );
			
			trace( "INVITERCOMPLETED : button is "+copy );
			
			fflButton.addEventListener( Event.SELECT, onButtonClicked );
			var to : uint = setTimeout( showCheck, 500 );
			
			InviterModel.gi.videoWaitingForCreation = true;
			Inviter.instance.deactivateNav();
			
			startTimer();
		}
	
		
		//----------------------------------------------------------------------------
		// private methods
		//----------------------------------------------------------------------------
		private function showCheck( ) : void
		{	
			var offset : uint = 10;
			check.x -= offset;
			TweenLite.to( check, SiteConstants.TIME_TRANSITION_IN, { alpha: 1, x: check.x + offset, ease:Quad.easeOut } );
		}
		
		private function startTimer( ) : void
		{
			trace( "INVITERCOMPLETE : startTimer()" );
			_to = setTimeout( getVideoStatus, TIME_OUT )
		}
		
		private function getVideoStatus( ) : void
		{
			trace( "INVITERCOMPLETE : getVideoStatus()" );
			var hr : HusaniRequestor = new HusaniRequestor();
			hr.addEventListener( Event.COMPLETE, getUserVideoStatusComplete );
			hr.addEventListener(IOErrorEvent.IO_ERROR, getUserVideoStatusError);
			hr.request( HusaniRequestor.GET_VIDEO_STATUS );
		}

		//----------------------------------------------------------------------------
		// event handlers
		//----------------------------------------------------------------------------
		protected function onButtonClicked( e : Event ) : void
		{	
			Metrics.pageView("inviterCustomizeBackToToolkitButton");
			
			StateModel.gi.state = StateModel.STATE_TOUTS;
			PersonalizedModel.gi.state = PersonalizedModel.STATE_FLUSH;
			Main.instance.header.nav.reset();
			clearTimeout( _to );
		}

		private function getUserVideoStatusComplete( e : Event ) : void
		{
			trace( "INVITERCOMPLETE : getUserVideoStatusComplete() : e is "+e ); 
			var hr : HusaniRequestor = e.target as HusaniRequestor;
			hr.removeEventListener( Event.COMPLETE, getUserVideoStatusComplete );
			hr.removeEventListener(IOErrorEvent.IO_ERROR, getUserVideoStatusError);
			
			var status : String = _im.status;
			var videoType : String = _im.videoType;
			trace( "\n" );
			trace( "*************************************************" );
			trace( "INVITERCOMPLETE : getUserVideoStatusComplete() : status is "+status ); 	
			trace( "INVITERCOMPLETE : getUserVideoStatusComplete() : videoType is "+videoType ); 
			trace( "*************************************************" );
			trace( "\n" );
			
			if( status == InviterModel.STATUS_CREATED )
			{
				if( _cf.isPressPreview )
				{
					Inviter.instance.showVideoDeletedAlert();
				}
				else
				{
					_im.state = InviterModel.STATE_PREVIEW;
				}
			} 
			else if( status == InviterModel.STATUS_ERROR ) 
			{
				Inviter.instance.showHRErrorAlert();
			}
			else
			{
				startTimer();
			}
		}
		
		private function getUserVideoStatusError( e : IOErrorEvent ) : void
		{
			trace( "INVITERCOMPLETE : getUserVideoStatusComplete() : e is "+e );
			var hr : HusaniRequestor = e.target as HusaniRequestor;
			hr.removeEventListener( Event.COMPLETE, getUserVideoStatusComplete );
			hr.removeEventListener(IOErrorEvent.IO_ERROR, getUserVideoStatusError)
		}
	}
}
