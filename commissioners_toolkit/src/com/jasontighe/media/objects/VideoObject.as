package com.jasontighe.media.objects
{
	import com.jasontighe.loggers.Logger;
	import com.jasontighe.containers.events.ContainerEvent;
	import com.jasontighe.media.events.MediaEvent;
	import com.jasontighe.media.objects.AbstractMediaObject;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.NetStatusEvent;
	import flash.events.TimerEvent;
	import flash.media.SoundTransform;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.utils.Timer;	

	public class VideoObject extends AbstractMediaObjectProgressive
	{		
		private var _nc:NetConnection;
		private var _ns:NetStream;
		private var _video:Video;
		private var _meta:Object;
		private var _timer:Timer;
		public function VideoObject( url:String )
		{
			super( url );
		}
		override public function init():void
		{			
			super.init( );
						
			addNetConnection( );
		}	
		private function addNetConnection():void
		{			
			_nc = new NetConnection( );
			_nc.addEventListener( NetStatusEvent.NET_STATUS, onNetConnectionStatus );
			_nc.connect( null );
		}	
		private function addNetStream():void
		{			
			_ns = new NetStream( _nc );
			
			_ns.bufferTime = bufferTime;
			_ns.addEventListener( IOErrorEvent.IO_ERROR, onIOError );
			_ns.addEventListener( NetStatusEvent.NET_STATUS, onNetStreamStatus );
			
			var ob:Object = new Object( );			
			ob.onMetaData = onMetaData;
			ob.onPlayStatus = onPlayStatus;
			_ns.client = ob;		
			
			_video = new Video( );
			_video.deblocking = 3;
			_video.smoothing = false;
			_video.visible = false;
			
			addChild( _video );
			
			_video.attachNetStream( _ns );
			
			_ns.play( _url );
			_ns.pause( );
			_ns.seek( 0 );
			
			dispatchEvent( new MediaEvent( MediaEvent.MEDIA_OBJECT_LOAD_START ) );
		}
		private function addTimer():void
		{			
			_timer = new Timer( 32 );
			_timer.addEventListener( TimerEvent.TIMER, onUpdateBytesLoaded );
			_timer.start( );			
		}	
		private function removeNetConnection():void
		{
			if ( _nc )
			{				
				_nc.removeEventListener( NetStatusEvent.NET_STATUS, onNetConnectionStatus );
				_nc.close( );
				_nc = null;
			}
		}		
		private function removeNetStream():void
		{
			if ( _ns )
			{
				_ns.removeEventListener( IOErrorEvent.IO_ERROR, onIOError );			
				_ns.removeEventListener( NetStatusEvent.NET_STATUS, onNetStreamStatus );
				_ns.close( );			
				_ns = null;		
			}	
		}
		private function removeVideo():void
		{
			if ( _video )
			{
				_video.attachNetStream( null );
				_video.clear( );
				_video = null;
			}
		}

		private function removeTimer():void
		{
			if ( _timer )
			{
				_timer.removeEventListener( TimerEvent.TIMER, onUpdateBytesLoaded );	
				_timer.stop( );
				_timer = null;
			}
		}
		override protected function onRemovedFromStage( e:Event ):void
		{
			super.onRemovedFromStage( e );
					
			removeTimer( );
			removeNetConnection( );
			removeNetStream( );
			removeVideo( );
			_meta = null;		
		}
		override protected function addProperties():void
		{		
			super.addProperties( );		
				
			_duration = _meta.duration;
			_video.width = _video.videoWidth;
			_video.height = _video.videoHeight;
			if ( !Boolean( _video.width ) ) 			{ 				_video.width = _meta.width; 			}
			if ( !Boolean( _video.height ) ) 			{ 				_video.height = _meta.height; 			}
			_video.visible = true;
		}
		/*
		 * 
		 * interface
		 * 
		 */		
		override public function resume():void
		{		
			_ns.resume( );
		}
		override public function pause():void
		{
			super.pause( );
			
			_ns.pause( );				
		}
		override public function reset():void
		{	
			super.reset( );		
			
			_ns.seek( 0 );
		}
		override public function seek( time:Number ):void
		{			
			var offset:int = time;
			
			if ( offset < 0 )
			{
				offset = 0;
			}
			if ( offset > time )
			{
				offset = int( time );
			}
			
			_ns.seek( offset );			
		}	
		/*
		 * 
		 * getters/setters
		 * 
		 */
		public function get ns():NetStream
		{			
			return _ns;			
		}
		public function get meta():Object
		{			
			return _meta;			
		}
		override public function get time():Number
		{			
			return _ns.time;	
		}	
		override public function get vol():Number
		{	
			return ns.soundTransform.volume;
		}	
		override public function set vol( volume:Number ):void
		{			
			var st:SoundTransform = new SoundTransform( );

			st.volume = volume;
			
			if ( ns ) 			{					ns.soundTransform = st; 			}
		}
		override public function get bufferTime():Number
		{	
			return _bufferTime;
		}	
		override public function set bufferTime( bufferTime:Number ):void
		{	
			if ( ns ) 			{ 				ns.bufferTime = bufferTime; 			}
				
			_bufferTime = bufferTime;
		}
		/*
		 * 
		 * event handlers
		 * 
		 */
		private function onUpdateBytesLoaded( e:TimerEvent ):void
		{
			//			trace('onUpdateBytesLoaded > _ns.bytesLoaded > ' + _ns.bytesLoaded);
			//			trace('onUpdateBytesLoaded > _ns.bytesTotal > ' + _ns.bytesTotal);
			_bytesLoaded = _ns.bytesLoaded;
			_bytesTotal = _ns.bytesTotal;			
			
			dispatchEvent( new MediaEvent( MediaEvent.MEDIA_OBJECT_LOAD_PROGRESS ) );
			
			if ( _bytesLoaded > 4 && _bytesLoaded == _bytesTotal )
			{				
				removeTimer( );
				
				dispatchEvent( new MediaEvent( MediaEvent.MEDIA_OBJECT_LOAD_COMPLETE ) );
			}
		}
		private function onIOError( e:IOErrorEvent ):void
		{			
			trace( 'VideoObject > onIOError > ' + e.type );
		}
		private function onNetConnectionStatus( e:NetStatusEvent ):void
		{			
			//			trace('VideoObject > onNetConnectionStatus > ' + e.info.code);			
			if ( e.info.code == 'NetConnection.Connect.Success' )
			{
				addNetStream( );
				addTimer( );
			}		
			
			if ( e.info.level == 'error' )
			{
				Logger.error( 'VideoObject > onNetConnectionStatus > ' + e.info.code );
//				Logger.alert('VideoObject > onNetConnectionStatus > ' + e.info.code );
			}		
		}
		private function onNetStreamStatus( e:NetStatusEvent ):void
		{			
			//			trace('VideoObject > onNetStreamStatus > ' + e.info.code);
			if ( e.info.level == 'error' )
			{
				Logger.error( 'VideoObject > onNetStreamStatus > ' + e.info.code );
				//				Logger.alert('VideoObject > onNetStreamStatus > ' + e.info.code );
				if ( e.info.code == 'NetStream.Play.StreamNotFound' )
				{
					Logger.error( 'Stream not found for URL ' + _url );
				}	
			}		
		}
		private function onMetaData( meta:Object ):void
		{							
			if ( !Boolean( _meta ) )
			{						
				_meta = meta;
			
				//				for ( var i:String in _meta )
				//				{
				//					trace( i + ' : ' + _meta[ i ] );
				//				}
				//				trace( '------------' );
				addProperties( );					
				
				dispatchEvent( new ContainerEvent( ContainerEvent.INIT ) );
			}		
		}
		private function onPlayStatus( status:* ):void
		{			
			//			trace('VideoObject > onPlayStatus')
//			for ( var i:String in status )
//			{
//				trace( i + ' : ' + status[ i ] );
//			}			
		}
	}
}