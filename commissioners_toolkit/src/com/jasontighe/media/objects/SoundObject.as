package com.jasontighe.media.objects
{	
	import flash.net.URLRequest;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.media.ID3Info;
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.events.IOErrorEvent;
	// events
	import com.jasontighe.media.events.MediaEvent;
	// base
	import com.jasontighe.media.objects.AbstractMediaObject;
	
	public class SoundObject extends AbstractMediaObjectProgressive
	{
		private var _sound:Sound;
		private var _soundChannel:SoundChannel;
		private var _id3:ID3Info;
		
		public function SoundObject( url:String )
		{
			super( url );
		}	 
		 
		/*
		 * 
		 * interface
		 * 
		 */	

		override public function init():void
		{		
			super.init();
			
			addSound();
			addSoundChannel();			
		}
		
		override protected function addProperties():void
		{
			_duration = _sound.length;
		}
		
		override protected function onRemovedFromStage( e:Event ):void
		{
			super.onRemovedFromStage( e );	
				
			_sound = null;			
			_soundChannel = null;
			_id3 = null;			
		}
		
		override protected function addEventListeners():void
		{
			super.addEventListeners();			
		}
		
		override protected function removeEventListeners():void
		{
			super.removeEventListeners();				
			
			_sound.removeEventListener( IOErrorEvent.IO_ERROR, onIOError );		
			_sound.removeEventListener( ProgressEvent.PROGRESS, onProgress );		
		}
				
		/*
		 * 
		 * private methods
		 * 
		 */	
		 
		private function addSound():void
		{
			_sound = new Sound();
			_sound.addEventListener( Event.OPEN, onOpen );
			_sound.addEventListener( ProgressEvent.PROGRESS, onProgress );
			_sound.addEventListener( IOErrorEvent.IO_ERROR, onIOError );
			_sound.load( new URLRequest( _url ) );
		}	 
		 
		private function addSoundChannel():void
		{			
			_soundChannel = _sound.play( _time );
			_soundChannel.soundTransform.volume = 0;
			_soundChannel.stop();
		}	 
			
		/*
		 * 
		 * event handlers
		 * 
		 */
		
		private function onOpen( e:Event ):void
		{			
			trace('SoundObject > onOpen');
			
			addProperties();
		}
		
		private function onProgress( e:ProgressEvent ):void
		{			
			trace('SoundObject > onProgress');
			
			_bytesLoaded = e.bytesLoaded;
			_bytesTotal = e.bytesTotal;
		}
		
		private function onIOError( e:IOErrorEvent ):void
		{			
			trace('SoundObject > onIOError > ' + e.type);
		}
		
		private function onID3( e:Event ):void
		{			
			var sound:Sound = e.target as Sound;
			
			_id3 = sound.id3;
			
//			for ( var i:String in _id3 )
//			{
//				trace( i + ' : ' + _id3[ i ] );
//			}
//			trace('------------');	
		}
		
		/*
		 * 
		 * getters
		 * 
		 */			 
				
		override public function get time():Number
		{			
			return _soundChannel.position;	
		}	
		 
		public function get sound():Sound
		{			
			return _sound;
		}
		 
		public function get soundChannel():SoundChannel
		{			
			return _soundChannel;
		}
		 
		public function get id3():ID3Info
		{			
			return _id3;
		}
	}
}