package com.espn.ffl.webcam.http {
	import flash.events.EventDispatcher;

	/**
	 * @author jason.tighe
	 */
	public class FlvUploadRequestor 
	extends EventDispatcher 
	{
		/*
		public static const USE_MULTIPARTUPLOADER:Boolean = true;
	
		//----------------------------------------------------------------------------
		// private variables
		//----------------------------------------------------------------------------
		private var _sv										: SignerValue; // = SignerValue.gi;
		private var _id										: uint = 0;
		//----------------------------------------------------------------------------
		// constructor
		//----------------------------------------------------------------------------
		public function FlvUploadRequestor(target : IEventDispatcher = null) 
		{
			super(target);
		}
		
		//----------------------------------------------------------------------------
		// public methods
		//----------------------------------------------------------------------------
		public function request( flv : ByteArray ):void
		{
			trace( "FLVUPLOADREQUESTOR : [ _id: "+_id+" ] : request(), flv length", flv.length);
			_sv = ContentModel.gi.getSignerValueItemAt( _id ) as SignerValue;
			var url : String = APIConstants.FLV_UPLOADER_URL + "?" + APIConstants.X_PROGRESS_ID + "=" + _sv.values.sid;
			trace("FLVUPLOADREQUESTOR : uploadFlv() : url is "+url ); 
			
			trace('USING MULTIPARTURLLOADER UTILITY');
			var filename : String = "webcam_video_" + _id+".flv";
			var multi:MultipartURLLoader = new MultipartURLLoader();
			multi.dataFormat = URLLoaderDataFormat.BINARY;
			multi.addFile(flv, filename, "userfile", "video/x-flv");
			multi.addEventListener( Event.COMPLETE, onFlvUploadComplete, false,0,true );
			multi.addEventListener( AsyncErrorEvent.ASYNC_ERROR, errorHandlerAsyncErrorEvent, false,0,true);
			multi.addEventListener( HTTPStatusEvent.HTTP_STATUS, httpStatusHandler, false,0,true);
			multi.addEventListener( IOErrorEvent.IO_ERROR, ioErrorHandler, false,0,true);
				
				/*
				for (var key:String in _sv.values) {
					multi.addVariable(key, _sv.values[key]);
					trace('key:', key, 'value:', _sv.values[key]);
				}
				*/
				
			/*
			Out.i("About to call load() method.");
			multi.load(url, false);
			Out.i("Called load() method.");
		}
		
		//----------------------------------------------------------------------------
		// event handlers
		//----------------------------------------------------------------------------
		private function onFlvUploadComplete( e : Event ):void
		{
			var loader:URLLoader;
			
			if (e.target is MultipartURLLoader)
			{
				var multi:MultipartURLLoader = e.target as MultipartURLLoader;
				multi.removeEventListener( Event.COMPLETE, onFlvUploadComplete );
				multi.removeEventListener( AsyncErrorEvent.ASYNC_ERROR, errorHandlerAsyncErrorEvent);
				multi.removeEventListener( HTTPStatusEvent.HTTP_STATUS, httpStatusHandler );
				multi.removeEventListener( IOErrorEvent.IO_ERROR, ioErrorHandler);

				loader = multi.loader;
			}
			else
			{
				loader = e.target as URLLoader;
			}
			
			loader.removeEventListener( Event.COMPLETE, onFlvUploadComplete );
			var data : String = loader.data;
			trace( "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" );
			trace( "FLVUPLOADREQUESTOR : onFlvUploadComplete:() : data is "+data );
			trace( "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" );
			loader = null;
			
			dispatchEvent( new Event(Event.COMPLETE ) );
		}

		private function httpStatusHandler( e : HTTPStatusEvent ) : void
		{
			trace( "FLVUPLOADREQUESTOR : ************************************** httpStatusHandler:" + e );
		}
		
		private function errorHandlerAsyncErrorEvent( e : AsyncErrorEvent ) : void
		{
			trace( "FLVUPLOADREQUESTOR : ************************************** errorHandlerAsyncErrorEvent: e is "+e );
		}
		
		private function ioErrorHandler( e : Event ) : void
		{
			trace( "FLVUPLOADREQUESTOR : ************************************** ioErrorHandler: " + e );
		}
		
		//----------------------------------------------------------------------------
		// getter/setters
		//----------------------------------------------------------------------------
		public function set id( n : int ) : void
		{
			_id = n
		}
		*/
	}
}
