package com.espn.ffl.views.quicknav {
	import com.espn.ffl.model.ContentModel;
	import com.espn.ffl.model.StateModel;
	import com.espn.ffl.model.dto.SectionDTO;
	import com.espn.ffl.views.AbstractView;
	import com.jasontighe.navigations.Nav;

	import flash.events.Event;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;

	/**
	 * @author jason.tighe
	 */
	public class QuickNav 
	extends AbstractView 
	{
		//----------------------------------------------------------------------------
		// public static const
		//----------------------------------------------------------------------------
		public static const BG_COLOR						: uint = 0xECE5CE;
		//----------------------------------------------------------------------------
		// protected static variables
		//----------------------------------------------------------------------------
//		protected static var NAVITEM_X_SPACE				: uint = 25;
		protected static var NAV_WIDTH						: uint = 100;
		protected static var NAV_HEIGHT						: uint = 30;
		protected static var NAV_PADDING					: uint = 5;
		//----------------------------------------------------------------------------
		// protected variables
		//----------------------------------------------------------------------------
		protected var _id									: uint;
		protected var _contentModel							: ContentModel = ContentModel.gi;
		protected var _sections								: Array = new Array();
		//----------------------------------------------------------------------------
		// public variables
		//----------------------------------------------------------------------------
		public var nav										: Nav;
		public var tf										: TextField;
		//----------------------------------------------------------------------------
		// constructor
		//----------------------------------------------------------------------------
		public function QuickNav() 
		{
			trace( "QUICKNAV : Constr" );
			super();
		}
		
		//----------------------------------------------------------------------------
		// public methods
		//----------------------------------------------------------------------------
		public override function init() : void 
		{ 
			addViews();		
		}
		
		public override function transitionIn() : void { }
		public override function transitionOut() : void { }
		
		//----------------------------------------------------------------------------
		// protected methods
		//----------------------------------------------------------------------------
//		protected override function transitionInComplete() : void { }
//		protected override function transitionOutComplete() : void { }
		
		protected override function addViews() : void 
		{ 
			addNav();
			addTextField();
		}
		
		//----------------------------------------------------------------------------
		// private methods
		//----------------------------------------------------------------------------
		private function addNav(  ) : void
		{
			trace( "QUICKNAV : addNav()" );
			nav = new Nav();
			
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
				item.setIndex( i );
				
				item.init();
				var name : String = _contentModel.getSectionItemAt( i ).name as String;
				_sections.push( name );
				
				item.setOutState();
				item.setOutEventHandler( onNavItemOut );
				item.setOverEventHandler( onNavItemOver );
				item.setClickEventHandler( onNavItemClick );
				
				item.x = i * ( item.width + NAV_PADDING );
				item.y = 0;
				
				nav.add( item );
				nav.addChild( item );
			}
			
			nav.init();
			addChild( nav );
		}
		
		private function addTextField(  ) : void
		{
			tf = new TextField();
			tf.autoSize = TextFieldAutoSize.LEFT;
			tf.y = nav.height + NAV_PADDING;
			addChild( tf );
		}
		
		protected function updateTextField( id : uint ) : void
		{
			var text : String = _sections[ id ];
			tf.htmlText = text;
			tf.autoSize = TextFieldAutoSize.LEFT;
		}
		
		protected function updateState( id : uint ) : void
		{
			var name : String = ContentModel.gi.getSectionItemAt( id ).name;
			switch ( name )
			{
				case "League Inviter":
					StateModel.gi.state = StateModel.STATE_INVITER;
					break;
					
				case "Report Card":
					StateModel.gi.state = StateModel.STATE_REPORT_CARD;
					break;
					
				case "The Enforcer":
					StateModel.gi.state = StateModel.STATE_ENFORCER;
					break;
					
				case "Team Apparel":
					StateModel.gi.state = StateModel.STATE_APPAREL;		
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
			var item : QuickNavItem = e.target as QuickNavItem; 
			_id = item.getIndex();
			nav.setActiveItem( item );
			updateTextField( _id );
			item.setActiveState();
			trace("QUICKNAV : onNavItemClick() : _id is "+_id );
			updateState( id );
			dispatchCompleteEvent();
		}
			
		//----------------------------------------------------------------------------
		// getters/setters
		//----------------------------------------------------------------------------
		public function get id( ) : uint
		{
			return _id;
		}
	}
}
