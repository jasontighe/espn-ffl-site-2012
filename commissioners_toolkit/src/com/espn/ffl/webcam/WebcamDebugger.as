package com.espn.ffl.webcam {
	import leelib.util.TextFieldUtil;

	import com.espn.ffl.constants.SiteConstants;
	import com.espn.ffl.model.ContentModel;
	import com.greensock.TweenLite;
	import com.greensock.easing.Quad;
	import com.jasontighe.containers.DisplayContainer;
	import com.jasontighe.utils.Box;

	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.text.TextField;

	/**
	 * @author jason.tighe
	 */
	public class WebcamDebugger 
	extends DisplayContainer 
	{
		//----------------------------------------------------------------------------
		// private variables
		//----------------------------------------------------------------------------
		private static var _instance						: WebcamDebugger;
		//----------------------------------------------------------------------------
		// private static constants
		//----------------------------------------------------------------------------
		private static const DEBUG_WIDTH					: uint = 970;
		private static const DEBUG_HEIGHT					: uint = 700;
		private static const DEBUG_COLOR					: uint = 0x000000;
		private static const DEBUG_ALPHA					: Number = .75;
		private static const DEBUG_CLOSED					: uint = 25;
		private static const COPY_Y_SPACE					: uint = 15;
		private static const MESSAGE_Y						: uint = 44;
		private static const URL_X							: uint = 300;
		//----------------------------------------------------------------------------
		// private variables
		//----------------------------------------------------------------------------
		private var _cm										: ContentModel = ContentModel.gi;
		private var _open				 					: Boolean = false;
		private var _copies				 					: Array = new Array();
		private var _urlButtons				 				: Array = new Array();
		private var _urlStrings			 					: Array = new Array();
		private var _urlHolders			 					: Array = new Array();
		//----------------------------------------------------------------------------
		// public variables
		//----------------------------------------------------------------------------
		public var background			 					: Box;
		public var masker				 					: Box;
		//----------------------------------------------------------------------------
		// constructor
		//----------------------------------------------------------------------------
		public function WebcamDebugger( e : WebcamDebuggerEnforcer ) 
		{
			_instance = this;
			
			background = new Box( DEBUG_WIDTH, DEBUG_HEIGHT, DEBUG_COLOR );
			background.alpha = DEBUG_ALPHA;
			addChild( background );
			
			masker = new Box( DEBUG_WIDTH, DEBUG_CLOSED );
			addChild( masker );
			
			mask = masker;
			
			var title : TextField = TextFieldUtil.makeHtmlTextWithCopyDto( _cm.getCopyItemByName( "liUDebuggerTitle" ) );
			addChild( title );
			
			_copies.push( title );
			
			activate();
		}
		
		//----------------------------------------------------------------------------
		// public methods
		//----------------------------------------------------------------------------
		public function addMessage( s : String, url : String = "" ) : void
		{
//			trace( "WEBCAMDEBUGGER : addMessage() : s is "+s );
//			trace( "WEBCAMDEBUGGER : addMessage() : url "+url );
			var message : TextField = TextFieldUtil.makeText( s, ".liUDebuggerMessage" );
			var prevCopy : TextField = _copies[ _copies.length - 1 ] as TextField;
			
			message.x = prevCopy.x;
			if(  _copies.length == 1 )
			{
				message.y = MESSAGE_Y;
			}
			else
			{
				message.y = prevCopy.y + COPY_Y_SPACE;
			}
//			trace( "WEBCAMDEBUGGER : addMessage() : message.x "+message.x );
//			trace( "WEBCAMDEBUGGER : addMessage() : message.y "+message.y );
			
			addChild( message );
			_copies.push( message );
			
			var holder : MovieClip = new MovieClip();
			holder.alpha = .8;
			addChild( holder );
			_urlHolders.push( holder );
			
			var urlTxt : TextField = TextFieldUtil.makeText( url, ".liUDebuggerUrl" );
			urlTxt.x = URL_X;
			urlTxt.y = message.y;
			holder.addChild( urlTxt );
			
			
			var box : Box = new Box( urlTxt.textWidth, urlTxt.textHeight );
			_urlStrings.push( url );
			_urlButtons.push( box );
			box.alpha = 0;
			box.x = urlTxt.x + 2;
			box.y = urlTxt.y + 2;

			box.id = _urlButtons.length - 1;
//			trace( "WEBCAMDEBUGGER : addMessage() : _urlButtons.length "+_urlButtons.length );
			
			box.buttonMode = true;
			box.mouseEnabled = true;
			box.mouseChildren = false;
			box.useHandCursor = true;
			box.addEventListener( MouseEvent.CLICK, onBoxClick );	
			box.addEventListener( MouseEvent.MOUSE_OVER, onBoxOver );
			box.addEventListener( MouseEvent.MOUSE_OUT, onBoxOut );
			addChild( box );
			
			
//			trace( "WEBCAMDEBUGGER : addMessage() : _urlStrings.length "+_urlStrings.length );
//			trace( "WEBCAMDEBUGGER : addMessage() : _urlButtons.length "+_urlButtons.length );
//			trace( "WEBCAMDEBUGGER : addMessage() : url "+url );
//			trace( "WEBCAMDEBUGGER : addMessage() : box.id "+box.id );
		}
		
		//----------------------------------------------------------------------------
		// private methods
		//----------------------------------------------------------------------------
		private function activate( ) : void
		{	
			background.buttonMode = true;
			background.mouseEnabled = true;
			background.mouseChildren = false;
			background.useHandCursor = true;
			
			background.addEventListener( MouseEvent.CLICK, onClick );	
		}
		
		private function toggleMask( ) : void
		{	
			if( _open )
			{
				TweenLite.to( masker, SiteConstants.TIME_OUT, { width: DEBUG_WIDTH, height: DEBUG_CLOSED, ease: Quad.easeOut } );
			}
			else
			{
				TweenLite.to( masker, SiteConstants.TIME_OVER, { width: DEBUG_WIDTH, height: DEBUG_HEIGHT, ease: Quad.easeOut } );
			}
			_open = !_open;
		}
		
		
		//----------------------------------------------------------------------------
		// event handlers
		//----------------------------------------------------------------------------
		private function onClick( e : MouseEvent ) : void
		{
			toggleMask();
		}
		
		private function onBoxClick( e : MouseEvent ) : void
		{
			var box : Box = e.target as Box;
			var id : uint = box.id as uint;
			var url : String = _urlStrings[ id ] as String;
			var urlRequest : URLRequest = new URLRequest( url );
			navigateToURL( urlRequest, "_blank");
		}
		
		private function onBoxOver( e : MouseEvent ) : void
		{
			var box : Box = e.target as Box;
			var id : uint = box.id as uint;
			var holder : MovieClip = _urlHolders[ id ] as MovieClip;
			TweenLite.to( holder, SiteConstants.TIME_OVER, { alpha: 1 } );
		}
		
		private function onBoxOut( e : MouseEvent ) : void
		{
			var box : Box = e.target as Box;
			var id : uint = box.id as uint;
			var holder : MovieClip = _urlHolders[ id ] as MovieClip;
			TweenLite.to( holder, SiteConstants.TIME_OUT, { alpha: .8 } );
		}
		
		//----------------------------------------------------------------------------
		// getter/setters
		//----------------------------------------------------------------------------
		public static function get gi() : WebcamDebugger
		{
			if(!_instance) _instance = new WebcamDebugger(new WebcamDebuggerEnforcer());
			return _instance;
		}
	}
}

class WebcamDebuggerEnforcer{}
