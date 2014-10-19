package com.jasontighe.media.events
{

	import flash.events.Event;
	
	public class MediaEvent extends Event 
	{
		// load event types
		public static const MEDIA_OBJECT_LOAD_START:String = new String( 'mediaObjectLoadStart' );
		public static const MEDIA_OBJECT_LOAD_PROGRESS:String = new String( 'mediaObjectLoadProgress' );
		public static const MEDIA_OBJECT_LOAD_COMPLETE:String = new String( 'mediaObjectLoadComplete' );
		// status event types		
		public static const MEDIA_PLAYER_READY:String = new String( 'mediaPlayerReady' );
		public static const MEDIA_PLAYER_START:String = new String( 'mediaPlayerStart' );
		public static const MEDIA_PLAYER_PROGRESS:String = new String( 'mediaPlayerProgress' );
		public static const MEDIA_PLAYER_FINISHED:String = new String( 'mediaPlayerFinished' );
		public static const MEDIA_PLAYER_CUSTOM_START:String = new String( 'mediaPlayerStartCustom' );
		// interface event types
		public static const MEDIA_PLAYER_RESUME:String = new String( 'mediaPlayerResume' );
		public static const MEDIA_PLAYER_PAUSE:String = new String( 'mediaPlayerPause' );
		public static const MEDIA_PLAYER_SEEK:String = new String( 'mediaPlayerSeek' );
		public static const MEDIA_PLAYER_RESET:String = new String( 'mediaPlayerReset' );
		public static const MEDIA_PLAYER_SKIP:String = new String( 'mediaPlayerSkip' );

		public function MediaEvent( type:String, bubbles:Boolean = false, cancelable:Boolean = false )
		{
			super( type, bubbles, cancelable );
		}

		public override function clone():Event
		{
			return new MediaEvent( type, bubbles, cancelable );
		}

		public override function toString():String
		{
			return formatToString( 'MediaEvent', type, bubbles, cancelable, eventPhase );
		}
	}
}
