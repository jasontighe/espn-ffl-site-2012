package com.espn.ffl.webcam.http {
	import flash.events.EventDispatcher;

	/**
	 * @author jason.tighe
	 */
	public class FlvProgressRequestor 
	extends EventDispatcher 
	{
		/*
		//----------------------------------------------------------------------------
		// public static variables
		//----------------------------------------------------------------------------
		public static var S3UPLOADING						: String = "s3uploading";
		public static var FILENAME							: String = "filename";
		//----------------------------------------------------------------------------
		// private variables
		//----------------------------------------------------------------------------
		private var _sv										: SignerValue; // = SignerValue.gi;
		private var _doneCount								: uint = 0;
		private var _fileName								: String;
		private var _mediaInfo								: String;
		private var _received								: uint = 0;
		private var _size									: uint = 0;
		private var _id										: uint = 0;
		private var _errorCount								: uint = 0;
		//----------------------------------------------------------------------------
		// constructor
		//----------------------------------------------------------------------------
		public function FlvProgressRequestor(target : IEventDispatcher = null) 
		{
			super(target);
		}
		
		//----------------------------------------------------------------------------
		// public methods
		//----------------------------------------------------------------------------
		public function request( requestType : String = "" ):void
		{
			trace("FLVPROGRESSREQUESTOR : [ _id: "+_id+" ] : request() : requestType is "+requestType ); 
			_sv = ContentModel.gi.getSignerValueItemAt( _id ) as SignerValue;
			var url : String = APIConstants.PROGRESS_URL + "?X-Progress-ID=" + _sv.values.sid;
			
			switch ( requestType )
			{
				case S3UPLOADING:
					url += "&action=" + S3UPLOADING + "&sid=" + _sv.values.sid;
					break;
				case FILENAME:
					url += "&action=" + FILENAME;
					break;
			}
			
//			trace("FLVPROGRESSREQUESTOR : uploadFlvProgress() : requestType is "+requestType ); 
//			trace("FLVPROGRESSREQUESTOR : uploadFlvProgress() : url is "+url ); 
//		     
		    var request : URLRequest = new URLRequest();
		    request.url = url;
			request.method = URLRequestMethod.GET;
			var urlVariables : URLVariables = new URLVariables();
			request.data = urlVariables;
		     
//		    for (var prop:String in urlVariables) 
//		    {
//		    	trace( "FLVPROGRESSREQUESTOR : uploadFlvProgress() Sent " + prop + " as: " + urlVariables[prop]);
//		    }
		     
		    var loader : URLLoader = new URLLoader();
		    loader.dataFormat = URLLoaderDataFormat.TEXT;
		    loader.addEventListener( Event.COMPLETE, onRequestComplete );
		    loader.addEventListener( HTTPStatusEvent.HTTP_STATUS, httpStatusHandler );
		    loader.addEventListener( SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler );
		     
		    try
		    {
		  	  loader.load( request );
		    }
			catch (error:ArgumentError) 
			{ 
			    trace("FLVPROGRESSREQUESTOR : uploadFlvProgress() : An ArgumentError has occurred."); 
			} 
			catch (error:SecurityError) 
			{ 
			    trace("FLVPROGRESSREQUESTOR : uploadFlvProgress() : A SecurityError has occurred."); 
			}
			
		    catch (error:Error)
		    {
		    	trace("FLVPROGRESSREQUESTOR : uploadFlvProgress() : Unable to load URL");
		    }
		}
		
		//----------------------------------------------------------------------------
		// private methods
		//----------------------------------------------------------------------------
		private function objectToURLVariables( parameters : Object ) : URLVariables 
		{
            var paramsToSend : URLVariables = new URLVariables();
            for( var i : String in parameters) 
            {
                if(i!=null)
                 {	
                    if(parameters[i] is Array) 
                    {
                    	paramsToSend[i] = parameters[i];
//                 		trace("FLVPROGRESSREQUESTOR : objectToURLVariables() : parameters[i] is "+parameters[i]);
                    }
                    else 
                    {
                    	paramsToSend[i] = parameters[i].toString();
//                    	trace( "\n" );
//                 		trace("FLVPROGRESSREQUESTOR : objectToURLVariables() : i is "+i);
//                 		trace("FLVPROGRESSREQUESTOR : objectToURLVariables() : parameters[i].toString() is "+parameters[i].toString());
                    }
                }
            }
        	return paramsToSend;
		}
		
		//----------------------------------------------------------------------------
		// event handlers
		//----------------------------------------------------------------------------
		private function onRequestComplete( e : Event ):void
		{
			var loader : URLLoader = e.target as URLLoader;
			var to : uint;
			var time : uint = 500;
			
			trace( "FLVPROGRESSREQUESTOR : [ _id: "+_id+" ] : onRequestComplete:() : loader.data is "+loader.data );
			if( loader.data == null || loader.data == "" )
			{
				to = setTimeout( request, time, S3UPLOADING );
				return;
			}
			
			var jsonData : String = EncodingJSONData.getJSONData( loader.data );
//			trace( "FLVPROGRESSREQUESTOR : onRequestComplete:() : jsonData is "+jsonData );
			var decodedJSON : Object = JSON.decode( jsonData );
			var state : String;
			var progress : String;
			var filename : String;
			var mediainfo : String;
			var error : String;
			if( decodedJSON.state ) 		state = decodedJSON.state;
			if( decodedJSON.received ) 		_received = decodedJSON.received;
			if( decodedJSON.size ) 			_size = decodedJSON.size;
			if( decodedJSON.progress )		progress = decodedJSON.progress;
			if( decodedJSON.filename ) 		filename = decodedJSON.filename;
			if( decodedJSON.mediainfo )		mediainfo = decodedJSON.mediainfo;
			if( decodedJSON.error ) 		error = decodedJSON.error;
//			trace( "FLVPROGRESSREQUESTOR : onRequestComplete:() : state is "+state );
//			trace( "FLVPROGRESSREQUESTOR : onRequestComplete:() : progress is "+progress );
//			trace( "FLVPROGRESSREQUESTOR : onRequestComplete:() : filename is "+filename );
//			trace( "FLVPROGRESSREQUESTOR : onRequestComplete:() : mediainfo is "+mediainfo );
//			trace( "FLVPROGRESSREQUESTOR : onRequestComplete:() : error is "+error );
			
			if( filename != null )
			{
				trace( "FLVPROGRESSREQUESTOR : onRetreiveUploadComplete:() : FILE UPLOADED TO S3" );
				_mediaInfo = mediainfo;
				_fileName = filename;
				dispatchEvent( new Event(Event.COMPLETE ) );
				return;
			}
//			
			switch( state )
			{
				case "starting":	
//					trace( "FLVPROGRESSREQUESTOR : onRetreiveUploadComplete:() : STARTING" );
					to = setTimeout( request, time, S3UPLOADING );
					break;
				case "uploading":	
//					trace( "FLVPROGRESSREQUESTOR : onRetreiveUploadComplete:() : UPLOADING" );
					dispatchEvent( new FlvProgressEvent( FlvProgressEvent.PROGRESS_UPLOADING ) );
					to = setTimeout( request, time );
					break;
				case "done":	
//					trace( "FLVPROGRESSREQUESTOR : onRetreiveUploadComplete:() : DONE" );
//						dispatchEvent( new FlvProgressEvent( FlvProgressEvent.PROGRESS_DONE ) );
						if( _doneCount == 0 )
						{
							to = setTimeout( request, time, S3UPLOADING );
							_doneCount++;
						}
						else if ( progress == "101" )
						{
							to = setTimeout( request, time, FILENAME );
						}
					break;
				case "processing":	
//					trace( "FLVPROGRESSREQUESTOR : onRetreiveUploadComplete:() : PROCESSING" );
					to = setTimeout( request, time, S3UPLOADING );
					break;
				case "error":	
					if( _errorCount < 2)	to = setTimeout( request, time, S3UPLOADING );
					WebcamDebugger.gi.addMessage( "WEBCAM "+_id+ " ERROR: "+error);
					_errorCount++
//					trace( "FLVPROGRESSREQUESTOR : onRetreiveUploadComplete:() : ERROR" );
					break;	
			}
			
			loader = null;
		}
		
		private function httpStatusHandler( e : HTTPStatusEvent ) : void
		{
			trace( "FLVPROGRESSREQUESTOR : ************************************** httpStatusHandler:" + e );
		}

		private function securityErrorHandler( e : SecurityErrorEvent ) : void
		{
			trace( "FLVUPLOADREQUESTOR : ************************************** securityErrorHandler:" + e );
		}
		
		//----------------------------------------------------------------------------
		// getter/setters
		//----------------------------------------------------------------------------
		public function set id( n : int ) : void
		{
			_id = n
		}
		
		public function get fileName( ) : String
		{
			return _fileName;
		}
		public function set fileName( s : String ) : void
		{
			_fileName = s;
		}
		
		public function get mediaInfo( ) : String
		{
			return _mediaInfo;
		}
		public function set mediaInfo( s : String ) : void
		{
			_mediaInfo = s;
		}
		
		public function get received( ) : uint
		{
			return _received;
		}
		
		public function get size( ) : uint
		{
			return _size;
		}
		
		*/
	}
}
