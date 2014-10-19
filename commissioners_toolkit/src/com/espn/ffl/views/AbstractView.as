package com.espn.ffl.views {
	import com.espn.ffl.constants.SiteConstants;
	import com.jasontighe.containers.DisplayContainer;
	import com.jasontighe.containers.events.ContainerEvent;

	import flash.display.MovieClip;

	/**
	 * @author jason.tighe
	 */
	public class AbstractView 
	extends DisplayContainer 
	{
		//----------------------------------------------------------------------------
		// public variables
		//----------------------------------------------------------------------------
		public var background								: MovieClip;
		//----------------------------------------------------------------------------
		// constructor
		//----------------------------------------------------------------------------
		public function AbstractView() 
		{
			super();
		}
		
		//----------------------------------------------------------------------------
		// public methods
		//----------------------------------------------------------------------------
		public function transitionIn() : void 
		{ 
			show( SiteConstants.TIME_TRANSITION_IN ); // Will dispatch ContainerEvent.SHOW on complete from onShowComplete()
		}

		public function transitionOut() : void 
		{ 
			show( SiteConstants.TIME_TRANSITION_OUT ); // Will dispatch ContainerEvent.HIDE on complete from onHideComplete()
		}
		
		public override function init() : void 
		{
			addViews();	
			alpha = 0;
		}
		
		public function reset() : void {}
		//----------------------------------------------------------------------------
		// protected methods
		//----------------------------------------------------------------------------
//		protected function transitionInComplete() : void { }
		protected function addViews() : void { }
		
//		protected function transitionOutComplete() : void 
//		{ 
//			trace( "ABSTRACTVIEW : transitionOutComplete()" );
//			dispatchCompleteEvent();
//		}
		
		protected function dispatchCompleteEvent() : void 
		{ 
			trace( "ABSTRACTVIEW : dispatchCompleteEvent()" );
			dispatchEvent( new ContainerEvent( ContainerEvent.HIDE));
		}
	}
}
