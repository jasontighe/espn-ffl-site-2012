package com.espn.ffl.model.dto {

	/**
	 * @author jason.tighe
	 */
	public class VideoDTO 
	implements IDTO 
	{
		//----------------------------------------------------------------------------
		// protected variables
		//----------------------------------------------------------------------------
		protected var _id	 							: uint;
		protected var _name 							: String;

		protected var _stitch							: String;
		protected var _preview							: String;
		protected var _sourceId							: uint;
		protected var _copy								: String;
		
		
		//----------------------------------------------------------------------------
		// contructor
		//----------------------------------------------------------------------------
		public function VideoDTO( data : *, id : uint = 0 )
		{
			var data : Object = Object(data);
			
			_id = id;

			if ( data.@name )			_name = data.@name;
			if ( data.@stitch )			_stitch = data.@stitch;
			if ( data.@preview )		_preview = data.@preview;
			if ( data.@sourceId )		_sourceId = data.@sourceId;
			if ( data )					_copy = String( data );
			
			previewer();
		}

		public function previewer() : void 
		{
			trace("\n");
			trace("VIDEODTO : _id is " + _id );
			trace("VIDEODTO : _name is " + _name );
			trace("VIDEODTO : _copy is " + _copy );
			trace("VIDEODTO : _stitch is " + _stitch );
			trace("VIDEODTO : _preview is " + _preview );
			trace("VIDEODTO : _sourceId is " + _sourceId );
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
		
		public function get copy() : String 
		{
			return _copy;
		}
		
		public function get stitch() : String
		{
			return _stitch;
		}
		
		public function get preview() : String
		{
			return _preview;
		}

		public function get sourceId() : uint 
		{
			return _sourceId;
		}
	}
}
