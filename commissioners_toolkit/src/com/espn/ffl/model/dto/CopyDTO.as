package com.espn.ffl.model.dto {

	/**
	 * @author jason.tighe
	 */
	public class CopyDTO 
	implements IDTO 
	{
		//----------------------------------------------------------------------------
		// protected variables
		//----------------------------------------------------------------------------
		protected var _id	 							: uint;
		protected var _name 							: String;
		protected var _copy 							: String;

		protected var _style							: String;
		protected var _xPos	 							: int;
		protected var _yPos	 							: int;
//		protected var _w	 							: uint;
//		protected var _h	 							: uint;
		
		protected var _title							: String;
		protected var _yesLabel							: String;
		protected var _noLabel							: String;
		
		
		//----------------------------------------------------------------------------
		// contructor
		//----------------------------------------------------------------------------
		public function CopyDTO( data : *, id : uint = 0 )
		{
			var data : Object = Object(data);
			
			_id = id;
			if ( data.@name )			_name = data.@name;
			if ( data )					_copy = String( data );

			if ( data.@style )			_style = data.@style;
			if ( data.@x )				_xPos = data.@x;
			if ( data.@y )				_yPos = data.@y;
//			if ( data.@width )			_w = data.@width;
//			if ( data.@height )			_h = data.@height;

			if ( data.@title )			_title = data.@title;
			if ( data.@yes )			_yesLabel = data.@yes;
			if ( data.@no )				_noLabel = data.@no;
			
//			preview();
		}

		public function preview() : void 
		{
			trace("\n");
			trace("COPYDTO : _id is " + _id );
			trace("COPYDTO : _name is " + _name );
			trace("COPYDTO : _copy is " + _copy );
			
			trace("COPYDTO : _style is " + _style );
			trace("COPYDTO : _xPos is " + _xPos );
			trace("COPYDTO : _yPos is " + _yPos );
//			trace("COPYDTO : _w is " + _w );
//			trace("COPYDTO : _h is " + _h );
			
			trace("COPYDTO : _title is " + _title );
			trace("COPYDTO : _yesLabel is " + _yesLabel );
			trace("COPYDTO : _noLabel is " + _noLabel );
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
		
		public function get title() : String
		{
			return _title;
		}
		public function get yesLabel() : String
		{
			return _yesLabel;
		}
		public function get noLabel() : String
		{
			return _noLabel;
		}
	}
}
