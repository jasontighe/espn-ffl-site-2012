package com.jasontighe.media.objects
{
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.media.SoundTransform;
	import flash.net.URLRequest;

	import com.jasontighe.media.objects.AbstractMediaObject;	

	public class MovieClipObject extends AbstractMediaObjectProgressive
	{		

		private var _mc:MovieClip;
		private var _loader:Loader;
		private var _fps:int = 31;

		public function MovieClipObject( url:String )
		{
			super( url );
		}

		override public function init():void
		{			
			super.init( );
			
			_loader = new Loader( );	
			_loader.contentLoaderInfo.addEventListener( IOErrorEvent.IO_ERROR, onLoaderIOError );
			_loader.contentLoaderInfo.addEventListener( Event.OPEN, onLoaderOpen );
			_loader.contentLoaderInfo.addEventListener( Event.INIT, onLoaderInit );
			_loader.contentLoaderInfo.addEventListener( ProgressEvent.PROGRESS, onLoaderProgress );
			_loader.contentLoaderInfo.addEventListener( Event.COMPLETE, onLoaderComplete );	
			_loader.load( new URLRequest( _url ) );
			
			addChild( _loader );
		}

		override protected function onRemovedFromStage( e:Event ):void
		{
			super.onRemovedFromStage( e );
					
			_mc = null;
			_loader = null;		
		}

		override protected function addProperties():void
		{		
			super.addProperties( );
				
			_mc = _loader.content as MovieClip;
			_mc.stop( );
			_duration = _mc.totalFrames / _fps;
		}

		override protected function addEventListeners():void
		{
			super.addEventListeners( );			
		}

		override protected function removeEventListeners():void
		{
			super.removeEventListeners( );				
			
			_loader.contentLoaderInfo.removeEventListener( IOErrorEvent.IO_ERROR, onLoaderIOError );
			_loader.contentLoaderInfo.removeEventListener( ProgressEvent.PROGRESS, onLoaderProgress );
			_loader.contentLoaderInfo.removeEventListener( Event.COMPLETE, onLoaderComplete );			
		}

		/*
		 * 
		 * interface
		 * 
		 */		
		override public function resume():void
		{	
			_mc.gotoAndPlay( _mc.currentFrame + 1 );
		}

		override public function pause():void
		{
			super.pause( );
			
			_mc.stop( );				
		}

		override public function reset():void
		{	
			super.reset( );		
			
			_mc.gotoAndStop( 1 );
		}

		override public function seek( time:Number ):void
		{			
			var offset:int = time;
			if ( offset < 1 ) 
			{ 
				offset = 1; 
			}
			if ( offset > _mc.totalFrames ) 
			{ 
				offset = _mc.totalFrames; 
			}
			
			_mc.gotoAndStop( offset );
		}	

		/*
		 * 
		 * getters/setters
		 * 
		 */
		override public function get vol():Number
		{	
			return _volume;
		}	

		override public function set vol( volume:Number ):void
		{			
			var st:SoundTransform = new SoundTransform( );

			st.volume = volume;
			
			if ( Boolean( _mc ) ) 
			{ 
				_mc.soundTransform = st; 
			}
			
			_volume = volume;
		}

		/*
		 * 
		 * event handlers
		 * 
		 */
		private function onLoaderIOError( e:IOErrorEvent ):void
		{			
			trace( 'MovieClipObject > onLoaderIOError > ' + e.type );
		}

		private function onLoaderOpen( e:Event ):void
		{			
//			trace('MovieClipObject > onLoaderOpen');
		}

		private function onLoaderInit( e:Event ):void
		{			
			//			trace('MovieClipObject > onLoaderInit');
			addProperties( );
		}

		private function onLoaderProgress( e:ProgressEvent ):void
		{			
			//			trace('MovieClipObject > onLoaderProgress');
			_bytesLoaded = e.bytesLoaded;
			_bytesTotal = e.bytesTotal;
		}

		private function onLoaderComplete( e:Event ):void
		{			
//			trace('MovieClipObject > onLoaderComplete');
		}
	}
}