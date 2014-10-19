package com.espn.ffl.views.header {
	import leelib.ui.TwoImageButton;

	import com.espn.ffl.constants.SiteConstants;
	import com.espn.ffl.model.ConfigModel;
	import com.espn.ffl.model.ContentModel;
	import com.espn.ffl.model.InviterModel;
	import com.espn.ffl.model.LeagueModel;
	import com.espn.ffl.model.StateModel;
	import com.espn.ffl.model.dto.CopyDTO;
	import com.espn.ffl.model.dto.SectionDTO;
	import com.espn.ffl.util.Assets;
	import com.espn.ffl.util.Metrics;
	import com.espn.ffl.views.Main;
	import com.espn.ffl.views.dialogs.AbstractDialog;
	import com.espn.ffl.views.dialogs.AlertDialogMaker;
	import com.espn.ffl.views.inviter.Inviter;
	import com.espn.ffl.views.quicknav.QuickNavItem;
	import com.espn.ffl.views.touts.AbstractTout;
	import com.jasontighe.managers.AssetManager;
	import com.jasontighe.navigations.INavItem;
	import com.jasontighe.navigations.Nav;

	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;

	/**
	 * @author jason.tighe
	 */
	public class Header 
	extends AbstractTout 
	{
		//----------------------------------------------------------------------------
		// protected variables
		//----------------------------------------------------------------------------
		protected var _contentModel							: ContentModel = ContentModel.gi;
		protected var _sections								: Array = new Array();
		protected var _navItems								: Array = new Array();
		//----------------------------------------------------------------------------
		// public variables
		//----------------------------------------------------------------------------
		public var nav										: Nav;
		public var facebookBtn								: TwoImageButton;
		public var twitterBtn								: TwoImageButton;
		public var settingsButton							: TwoImageButton;
		public var inviterNavItem							: MovieClip;
		public var enforcerNavItem							: MovieClip;
		public var reportNavItem							: MovieClip;
		public var apparelNavItem							: MovieClip;
		public var shield									: MovieClip;
		public var title									: MovieClip;
		public var lineL									: MovieClip;
		public var starL									: MovieClip;
		public var lineR									: MovieClip;
		public var starR									: MovieClip;
		
		public var tempEnforcerShareButton					: Sprite;
		
		//----------------------------------------------------------------------------
		// constructor
		//----------------------------------------------------------------------------
		public function Header() 
		{
			super();
		}
		
		//----------------------------------------------------------------------------
		// public methods
		//----------------------------------------------------------------------------
		public function updateQuickNav( i : uint ) : void 
		{ 
			if( i != 3 )
			{
				var item : INavItem = nav.getItemAt( i ) as INavItem;
				nav.setActiveItem( item );
				item.setActiveState();
			}
		}
		
		public function resetNav( ) : void 
		{ 
			nav.reset();
		}
		
		//----------------------------------------------------------------------------
		// protected methods
		//----------------------------------------------------------------------------
		protected override function addViews() : void 
		{ 
			trace( "HEADER : addViews()" );
			background = MovieClip( AssetManager.gi.getAsset( "Header", SiteConstants.ASSETS_ID ) );
			addChild( background );

			background.connectBtn.visible = false;
			background.facebookBtn.visible = false;
			background.twitterBtn.visible = false;
			
			settingsButton = new SettingsButtn(); 
			settingsButton.x = 814;
			settingsButton.y = 11;
			this.addChild(settingsButton);
			
			facebookBtn = new TwoImageButton(new Assets.FacebookButtonNormal(), new Assets.FacebookButtonNormal(), TwoImageButton.OVERTREATMENT_FADEONTOP); 
			facebookBtn.x = 12;
			facebookBtn.y = 10-1;
			this.addChild(facebookBtn);
			
			twitterBtn = new TwoImageButton(new Assets.TwitterButtonNormal(), new Assets.TwitterButtonNormal(), TwoImageButton.OVERTREATMENT_FADEONTOP); 
			twitterBtn.x = 60;
			twitterBtn.y = 10;
			this.addChild(twitterBtn);
			
			inviterNavItem = background.inviterNavItem;
			enforcerNavItem = background.enforcerNavItem;
			reportNavItem = background.reportNavItem;
			apparelNavItem = background.apparelNavItem;
			
			shield = background.shield;
			title = background.title;
			lineL = background.lineL;
			starL = background.starL;
			lineR = background.lineR;
			starR = background.starR;
			
			_navItems = [ inviterNavItem, enforcerNavItem, reportNavItem, apparelNavItem ];
			
			addNav();
		}
		
		private function addNav(  ) : void
		{
//			trace( "HEADER : addNav()" );
			nav = new Nav();
			var buttonIcons : Array = new Array( inviterNavItem.inviter,
												 enforcerNavItem.enforcer,
												 reportNavItem.report,
												 apparelNavItem.apparel );
												 
												 
			
			var dto : SectionDTO;
			var item : QuickNavItem;
			var last : QuickNavItem;
			var i : uint = 0;
			var I : uint = 4;
			var lastItem : uint = I - 1;
			
			for( i; i < I; i++)
			{	
//				dto = _contentModel.getSectionItemAt( i ) as SectionDTO;
				item = new QuickNavItem();
				// Set HeaderBtn to 
				var mc : MovieClip = _navItems[ i ];
				item.mc = mc;
				var icon : MovieClip = buttonIcons[ i ];
				icon.alpha = 1;
				item.addChild( mc );
				item.setIndex( i );
				item.addTitle( i );
				
//				item.init(); // No longer need to add views
				var name : String = _contentModel.getSectionItemAt( i ).name as String;
				_sections.push( name );
				
				item.setOutState();
				item.setOutEventHandler( onNavItemOut );
				item.setOverEventHandler( onNavItemOver );
				item.setClickEventHandler( onNavItemClick );
				
				nav.add( item );
				nav.addChild( item );
			}
			
			nav.init();
			addChild( nav );
			
			shield.buttonMode = true;
			shield.mouseEnabled = true;
			shield.mouseChildren = false;
			shield.useHandCursor = true;
			shield.addEventListener( MouseEvent.CLICK, onShieldClicked );
			
		}
		
		protected function updateState( id : uint ) : void
		{
			var name : String = ContentModel.gi.getSectionItemAt( id ).name;
			switch ( name )
			{
				case "LEAGUE INVITER":
					StateModel.gi.state = StateModel.STATE_INVITER;
					break;
					
				case "REPORT CARD":
					StateModel.gi.state = StateModel.STATE_REPORT_CARD;
					break;
					
				case "THE ENFORCER":
					StateModel.gi.state = StateModel.STATE_ENFORCER;
					break;
					
				case "TEAM GEAR":
					var url : String = _contentModel.getSectionItemAt( id ).url;
					var urlRequest : URLRequest = new URLRequest( url );
					navigateToURL( urlRequest, "_blank");
//					StateModel.gi.state = StateModel.STATE_APPAREL;		
					break;
			}
		}
			
		//----------------------------------------------------------------------------
		// event handlers
		//----------------------------------------------------------------------------
		protected function onNavItemOut( e : Event ) : void
		{
			var item : QuickNavItem = e.target as QuickNavItem; 
			item.setOutState();
		}
		
		protected function onNavItemOver( e : Event ) : void
		{
			var item : QuickNavItem = e.target as QuickNavItem; 
			item.setOverState();
		}
		
		protected function onNavItemClick( e : Event ) : void
		{
			if (QuickNavItem(e.target).getIndex() == 3)
			{
				_id = QuickNavItem(e.target).getIndex();
				
				var urlRequest : URLRequest = new URLRequest( ConfigModel.gi.apparelURL );
				navigateToURL( urlRequest, "_blank");
				
				Main.instance.updateQuickNav( _id );
				
				Metrics.pageView("globalTeamGearButton");

				return;
			}

			if (ConfigModel.gi.isOnNotLoggedInPage) {
				Main.instance.showNotLoggedInPageDialog();
				return;
			}
			
			if (! LeagueModel.gi.isCommissioner)
			{
				Main.instance.showNotCommissionerDialog();
				return;
			}
			
			
			var item : QuickNavItem = e.target as QuickNavItem; 
			_id = item.getIndex();

			if( _id != 3 )
			{	
				
				// CHECK FOR INVITER VIDEO BEING MADE
				trace( "INVITER : onNavItemClick() : InviterModel.gi.status is "+InviterModel.gi.status );
				trace( "INVITER : onNavItemClick() : !InviterModel.gi.videoWaitingForCreation is "+!InviterModel.gi.videoWaitingForCreation );
				trace( "INVITER : onNavItemClick() : InviterModel.gi.interviewStarted is "+InviterModel.gi.interviewStarted );
				if( StateModel.gi.state == StateModel.STATE_INVITER 
					&& InviterModel.gi.status == InviterModel.STATUS_NEW 
					&& !InviterModel.gi.videoWaitingForCreation
					&& InviterModel.gi.interviewStarted )
				{
					showInviterAlert()
				}
				else
				{
					nav.setActiveItem( item );
					item.setActiveState();
		//			trace("QUICKNAV : onNavItemClick() : _id is "+_id );
					updateState( _id );
					if( Inviter.instance ) 	
					{
						if( InviterModel.gi.status == InviterModel.STATUS_CREATED )	
						{
							Inviter.instance.pauseCreated();
						}
						Inviter.instance.flushCurrentView();
					}
					dispatchCompleteEvent();
				}
			}
			else
			{
				var urlReq : URLRequest = new URLRequest( ConfigModel.gi.apparelURL );
				navigateToURL( urlReq, "_blank");
				
				Main.instance.updateQuickNav( _id );
				
				Metrics.pageView("globalTeamGearButton");
			}
		}
		
		protected function doNavItemClick( ) : void
		{
			var item : INavItem;
			item = nav.getItemAt( _id );
			 
			if( _id != 3 )
			{
				nav.setActiveItem( item );
				item.setActiveState();
//			trace("QUICKNAV : onNavItemClick() : _id is "+_id );
			}
			updateState( _id );
			dispatchCompleteEvent();
		}
		
		protected function showInviterAlert() : void
		{
			trace( "INVITER : showWebcamDenied()" );
			var dto : CopyDTO = ContentModel.gi.getCopyItemByName( "alertDeleteVideo" );
			var _confirmationDialog : AbstractDialog = AlertDialogMaker.make( true, dto.title, dto.copy, dto.yesLabel, dto.noLabel, onInviterAlertYes, onInviterAlertNo, onInviterAlertClose, 505 );
			Main.instance.showDialog(_confirmationDialog);
			
			Metrics.pageView("inviterCustomizeLeaveDialog");
		}
		
		private function onInviterAlertYes():void
		{
			// HAPPENS WHEN "MAKE PREMADE VIDEO" BUTTON IN ALERT
			// DO FLUSH
			trace( "INVITER : onInviterAlertYes()" );
			Inviter.instance.flushCurrentView();
			doNavItemClick();
		    Main.instance.hideDialog();
			
			Metrics.pageView("inviterCustomizeLeaveDialogLeaveButton");
		}
		
		private function onInviterAlertNo():void
		{
			Metrics.pageView("inviterCustomizeLeaveDialogBackButton");
			Main.instance.hideDialog();
		}

		private function onInviterAlertClose():void
		{
			// NOT USED
			// HAPPENS WHEN "TRY AGAIN" BUTTON IN ALERT
			trace( "INVITER : onInviterAlertNo()" );
		    Main.instance.hideDialog();
		}	
		
		protected function onShieldClicked( e : MouseEvent ) : void
		{
			StateModel.gi.state = StateModel.STATE_TOUTS;
			if( Inviter.instance ) Inviter.instance.flushCurrentView();
			resetNav();
		}
			
		//----------------------------------------------------------------------------
		// getters/setters
		//----------------------------------------------------------------------------
	}
}
