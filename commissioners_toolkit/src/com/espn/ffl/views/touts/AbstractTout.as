package com.espn.ffl.views.touts {
	import com.espn.ffl.constants.SiteConstants;
	import com.espn.ffl.model.events.FflButtonEvent;
	import com.greensock.TweenMax;
	import com.greensock.easing.Quad;
	import com.jasontighe.containers.DisplayContainer;

	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;

	/**
	 * @author jason.tighe
	 */
	public class AbstractTout 
	extends DisplayContainer 
	{
		//----------------------------------------------------------------------------
		// public static const
		//----------------------------------------------------------------------------
		public static const BG_COLOR						: uint = 0xFFFFFF;
		public static const BG_WIDTH						: uint = 400;
		public static const BG_HEIGHT						: uint = 120;
		//----------------------------------------------------------------------------
		// protected variables
		//----------------------------------------------------------------------------
		protected var _id									: uint;
		//----------------------------------------------------------------------------
		// public variables
		//----------------------------------------------------------------------------
		public var background								: MovieClip;
		//----------------------------------------------------------------------------
		// constructor
		//----------------------------------------------------------------------------
		public function AbstractTout() 
		{
			super();
		}
		
		//----------------------------------------------------------------------------
		// public methods
		//----------------------------------------------------------------------------
		public override function init() : void 
		{ 
//			trace( "ABSTRACTTOUT : init()" );
//			alpha = 0;
			addViews();		
		}
		
		public function transitionIn( time : Number = 0, delay : Number = 0 ) : void 
		{ 
			var offset : uint = 10;
			var xPos : int = x;
			x = xPos - offset;
			TweenMax.to( this, time, { x: xPos, alpha: 1, ease: Quad.easeOut, delay: delay, onComplete: transitionInComplete } );
		}
		
		public function transitionOut( time : Number = 0, delay : Number = 0  ) : void 
		{
			var offset : uint = 10;
			var xPos : int = x + offset;
			TweenMax.to( this, time, { x: xPos, alpha: 0, ease: Quad.easeOut, delay: delay, onComplete: transitionOutComplete } );
		}
		
//		public function activate() : void 
//		{ 
//			useHandCursor = true;
//			buttonMode = true;
//			mouseEnabled = true;
//			mouseChildren = false;
//			
//			addEventListener( MouseEvent.MOUSE_OVER, doOver );
//			addEventListener( MouseEvent.MOUSE_OUT, doOut );
//			addEventListener( MouseEvent.CLICK, doClick );
//		}
//		
//		public function deactivate() : void 
//		{ 
//			useHandCursor = false;
//			buttonMode = false;
//			mouseEnabled = false;
//			mouseChildren = false;
//			
//			removeEventListener( MouseEvent.MOUSE_OVER, doOver );
//			removeEventListener( MouseEvent.MOUSE_OUT, doOut );
//			removeEventListener( MouseEvent.CLICK, doClick );
//		}
		
		//----------------------------------------------------------------------------
		// protected methods
		//----------------------------------------------------------------------------
		protected function transitionInComplete() : void 
		{ 
//			activate();
			onShowComplete();
		}
		
		protected function transitionOutComplete() : void 
		{ 
			onHideComplete();
		}
		
		protected function addBackground() : void { }
		
		protected function addViews() : void 
		{ 
//			trace( "ABSTRACTTOUT : addViews()" );
			addBackground();
		}
		
		protected function dispatchCompleteEvent() : void 
		{ 
			dispatchEvent( new Event( Event.COMPLETE ) );	
		}
		
		protected function doAnimationOver( e : FflButtonEvent = null ) : void {}
		
		protected function doAnimationOut( e : FflButtonEvent = null ) : void {}
		
		//----------------------------------------------------------------------------
		// event handlers
		//----------------------------------------------------------------------------
		protected function doOver( e : MouseEvent ) : void 
		{ 
			TweenMax.to( this, SiteConstants.TIME_OVER, { alpha: .75 } );
		}

		protected function doOut( e : MouseEvent ) : void 
		{ 
			TweenMax.to( this, SiteConstants.TIME_OUT, { alpha: 1 } );
		}
		
		protected function doClick( e : MouseEvent ) : void { }
		
		//----------------------------------------------------------------------------
		// getters/setters
		//----------------------------------------------------------------------------
		public function get id() : uint
		{
			return _id;
		}
		
		public function set id( n : uint ) : void
		{
			_id = n;
		}
	}
}
