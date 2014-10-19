package com.espn.ffl.model.dto {

	/**
	 * @author jason.tighe
	 */
	public class EncodingDTO 
	implements IDTO 
	{
		//----------------------------------------------------------------------------
		// protected variables
		//----------------------------------------------------------------------------
		protected var _id	 							: uint;
		protected var _name	 							: String;
		protected var _url 								: String;
		protected var _previewURL						: String;
		protected var _stitchURL						: String;
		protected var _type								: String;
		protected var _sourceId							: uint;
		protected var _time	 							: uint;
		protected var _copy								: String;
		protected var _recordEarly						: String;

		protected var _style							: String;
		protected var _xPos	 							: int;
		protected var _yPos	 							: int;
		
		protected var _webcamS3URL						: String;
		protected var _stichS3URL						: String;
		//----------------------------------------------------------------------------
		// contructor
		//----------------------------------------------------------------------------
		public function EncodingDTO( data : *, id : uint = 0 )
		{
			var data : Object = Object(data);
			
			_id = id;
			
			if ( data.@name )			_name = data.@name;
			if ( data.@stitchURL )		_stitchURL = data.@stitchURL;
			if ( data.@previewURL )		_previewURL = data.@previewURL;
			if ( data.@type )			_type = data.@type;
			if ( data.@url )			_url = data.@url;
			if ( data.@sourceId )		_sourceId = data.@sourceId;
			if ( data.@time )			_time = data.@time;
			if ( data.@recordEarly )	_recordEarly = data.@recordEarly;
			if ( data )					_copy = String( data );

			if ( data.@style )			_style = data.@style;
			if ( data.@x )				_xPos = data.@x;
			if ( data.@y )				_yPos = data.@y;
		}

		public function traceData() : void 
		{
			trace("\n");
			trace("ENCODINGDTO : _id is " + _id );
			trace("ENCODINGDTO : _name is " + _name );
			trace("ENCODINGDTO : _stitchURL is " + _stitchURL );
			trace("ENCODINGDTO : _previewURL is " + _previewURL );
			trace("ENCODINGDTO : _type is " + _type );
			trace("ENCODINGDTO : _url is " + _url );
			trace("ENCODINGDTO : _sourceId is " + _sourceId );
			trace("ENCODINGDTO : _time is " + _time );
			trace("ENCODINGDTO : _recordEarly is " + _recordEarly );
			trace("ENCODINGDTO : _copy is " + _copy );
			
			trace("ENCODINGDTO : _style is " + _style );
			trace("ENCODINGDTO : _xPos is " + _xPos );
			trace("ENCODINGDTO : _yPos is " + _yPos );
		}

		//----------------------------------------------------------------------------
		// getters/setters
		//----------------------------------------------------------------------------
		public function get id() : uint 
		{
			return _id;
		}
		
		public function get name() : String 
		{
			return _name;
		}
		public function set name( s : String ) : void 
		{
			_name = s;
		}
		
		public function get url() : String 
		{
			return _url;
		}
		public function set url( s : String ) : void 
		{
			_url = s;
		}
		
		public function get sourceId() : uint 
		{
			return _sourceId;
		}
		public function set sourceId( n : uint ) : void 
		{
			_sourceId = n;
		}
		
		public function get copy() : String 
		{
			return _copy;
		}
		
		public function get stitchURL() : String
		{
			return _stitchURL;
		}
		
		public function get previewURL() : String
		{
			return _previewURL;
		}
		
		public function get type() : String
		{
			return _type;
		}
		
		public function get style() : String
		{
			return _style;
		}

		public function get xPos() : int 
		{
			return _xPos;
		}
		
		public function get yPos() : int 
		{
			return _yPos;
		}
		
		public function get time() : uint 
		{
			return _time;
		}
		
		public function get recordEarly() : Boolean 
		{ 
			var b : Boolean = true;
			if( _recordEarly == "false" ) b = false;
			return b;
		}
		
		public function get webcamS3URL() : String
		{
			return _webcamS3URL;
		}
		public function set webcamS3URL( s : String ) : void 
		{
			_webcamS3URL = s;
		}
		
		public function get stichS3URL() : String
		{
			return _stichS3URL;
		}
		public function set stichS3URL( s : String ) : void 
		{
			_stichS3URL = s;
		}
	}
}
