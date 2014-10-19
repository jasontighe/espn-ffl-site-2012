package com.espn.ffl.views.inviter {
	import com.espn.ffl.constants.SiteConstants;
	import com.espn.ffl.model.ContentModel;
	import com.espn.ffl.model.InviterModel;
	import com.espn.ffl.model.PremadeModel;
	import com.espn.ffl.model.events.PremadeEvent;
	import com.espn.ffl.views.AbstractView;
	import com.espn.ffl.views.inviter.views.InviterFlush;
	import com.espn.ffl.views.inviter.views.PremadeCompleted;
	import com.espn.ffl.views.inviter.views.PremadeVideoSelector;
	import com.jasontighe.containers.events.ContainerEvent;

	import flash.display.MovieClip;

	/**
	 * @author jason.tighe
	 */
	public class Premade 
	extends AbstractView
	{
		//----------------------------------------------------------------------------
		// private static constants
		//----------------------------------------------------------------------------
		//----------------------------------------------------------------------------
		// private variables
		//----------------------------------------------------------------------------
		private var _cm										: ContentModel = ContentModel.gi;
		private var _pm										: PremadeModel;
		private var _completed								: Boolean = false;
		private var _currentView							: AbstractView;
		//----------------------------------------------------------------------------
		// public variables
		//----------------------------------------------------------------------------
		public var holder									: MovieClip;
		public var videoSelector							: PremadeVideoSelector;
		public var completed								: PremadeCompleted;
		public var flush									: InviterFlush;
		public var preview									: Preview;
		//----------------------------------------------------------------------------
		// constructor
		//----------------------------------------------------------------------------
		public function Premade() 
		{
			super();
			trace( "PREMADE : Constr" );
		}
		
		//----------------------------------------------------------------------------
		// public methods
		//----------------------------------------------------------------------------
		public function showDefaultView() : void 
		{ 
			trace( "PREMADE : showDefaultView()" );
//			_pm.state = PremadeModel.STATE_VIDEO_SELECTOR;
			trace( "PREMADE : checkIfViewed() : InviterModel.gi.status is "+InviterModel.gi.status );
			switch( InviterModel.gi.status )
			{	
				case InviterModel.STATUS_NEW:
					_pm.state = PremadeModel.STATE_VIDEO_SELECTOR;
					break;
					
				case InviterModel.STATUS_CREATED:
					_pm.state = PremadeModel.STATE_CREATED;
					break;
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
		protected override function addViews() : void 
		{ 
			trace( "PREMADE : addViews()" );
			addHolder();
			addPremadeModel();
		}
		
		protected function addHolder() : void 
		{ 
			trace( "PREMADE : addHolder()" );
			holder = new MovieClip();
			addChild( holder );
		}

		protected function addPremadeModel() : void
		{
			trace( "PREMADE : addPremadeModel()" );
			_pm = PremadeModel.gi;
			_pm.addEventListener( PremadeEvent.VIDEO_SELECTOR, onStateChange );
			_pm.addEventListener( PremadeEvent.COMPLETED, onStateChange );
			_pm.addEventListener( PremadeEvent.FLUSH, onStateChange );
			_pm.addEventListener( PremadeEvent.CREATED, onStateChange );
		}
		
		//----------------------------------------------------------------------------
		// private methods
		//----------------------------------------------------------------------------
		protected function showVideoSelector() : void 
		{ 
			trace( "PREMADE : showVideoSelector()" );
			if( !videoSelector )
			{	
				videoSelector = new PremadeVideoSelector();
				videoSelector.init();
			}
			holder.addChild( videoSelector );
			
			_currentView = videoSelector;
		}
		
		protected function showCompleted() : void 
		{ 
			trace( "PREMADE : showCompleted()" );
			if( !completed )
			{	
				completed = new PremadeCompleted();
				completed.init();
			}
			holder.addChild( completed );
			
			_currentView = completed;
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
		
		protected function showFlush() : void 
		{ 
			trace( "PREMADE : showFlush()" );
			if( !flush )
			{	
				flush = new InviterFlush();
				flush.init();
			}
			holder.addChild( flush );
			
			_currentView = flush;
		}
		
		public function kill() : void 
		{ 
			if( preview )	
			{
				preview.pause();
				preview = null;
			}
			if( completed )	
			{
				completed = null;
			}
			if( videoSelector )	
			{
				videoSelector = null;
			}
		}
		
		private function hideView() : void 
		{ 
			trace( "\n*******************************************" );
			trace( "PREMADE : hideView() _currentView is "+_currentView );
			_currentView.addEventListener( ContainerEvent.HIDE, hideViewComplete );
			_currentView.hide( SiteConstants.TIME_TRANSITION_OUT );
		}
		
		private function hideViewComplete( e : ContainerEvent ) : void 
		{ 
			trace( "PREMADE : hideViewComplete()" );
			_currentView.addEventListener( ContainerEvent.HIDE, hideViewComplete );
			removeChildrenFromHolder();
			showView();
		}
		
		private function showView( ) : void 
		{ 
			trace( "\n*******************************************" );
			trace( "PREMADE : showView()" );
			var state : String = _pm.state;
			
			switch( state )
			{
				case PremadeModel.STATE_VIDEO_SELECTOR:
					showVideoSelector();
					break;
				case PremadeModel.STATE_COMPLETED:
					showCompleted();
					break;
				case PremadeModel.STATE_FLUSH:
					kill();
					showFlush();
					break;
				case PremadeModel.STATE_CREATED:
					showCreated();
					break;
			}
			
			_currentView.addEventListener( ContainerEvent.SHOW, showViewComplete );
			_currentView.show( SiteConstants.TIME_TRANSITION_IN );
			_pm.previousState = state;
		}
		
		private function showViewComplete( e : ContainerEvent ) : void 
		{ 
			trace( "PREMADE : showViewComplete()" );
			_currentView.removeEventListener( ContainerEvent.SHOW, showViewComplete );
		}
		
		private function removeChildrenFromHolder( ) : void 
		{ 
			trace( "PREMADE : removeChildrenFromHolder()" );
			// REMOVE CHILDREN TODO CLEAN THIS UP
			for ( var i:uint = 0; i < holder.numChildren; i++)
			{
				var object : * = holder.getChildAt(i);
				trace( "PREMADE : removeChildrenFromHolder() : object is "+object );
				
				holder.removeChildAt(i);
				object = null;
			}
		}	

		//----------------------------------------------------------------------------
		// event handlers
		//----------------------------------------------------------------------------
		protected function onStateChange( e : PremadeEvent ) : void
		{	
			trace( "PREMADE : onStateChange()" );
			var state : String = e.type;
			var previousState : String = _pm.previousState;
			trace( "PREMADE : onStateChange() : state is "+state );
			trace( "PREMADE : onStateChange() : previousState is "+previousState );

			if( previousState == null )
			{
//				trace( "PERSONALIZED : onStateChange() : THE PREVIOUS STATE IS NULL! : state is "+state );
//				trace( "PERSONALIZED : onStateChange() : THE PREVIOUS STATE IS NULL! : previousState is "+previousState );
				showView();
			}
			else if( state == PremadeModel.STATE_FLUSH )
			{
				removeChildrenFromHolder();
				showView();
			}
			else
			{
				hideView();
			}
		}
	}
}
