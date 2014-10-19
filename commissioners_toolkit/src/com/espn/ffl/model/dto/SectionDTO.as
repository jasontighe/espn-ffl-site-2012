package com.espn.ffl.model.dto {

	/**
	 * @author jason.tighe
	 */
	public class SectionDTO 
	implements IDTO 
	{
		//----------------------------------------------------------------------------
		// protected variables
		//----------------------------------------------------------------------------
		protected var _id	 							: uint;
		protected var _name 							: String;
		protected var _url	 							: String;
		protected var _active 							: String;
		//----------------------------------------------------------------------------
		// contructor
		//----------------------------------------------------------------------------
		public function SectionDTO( data : *, id : uint = 0 )
		{
			var data : Object = Object(data);
			
			_id = id;
			if ( data.@name )			_name = data.@name;
			if ( data.@url )			_url = data.@url;
			if ( data.@active )			_active = data.@active;
			
//			preview();
		}

		//----------------------------------------------------------------------------
		// private methods
		//----------------------------------------------------------------------------
		private function preview() : void 
		{
			trace( "\n" );
			trace( "SECTIONDTO : preview() : _id is "+_id );
			trace( "SECTIONDTO : preview() : _name is "+_name );
			trace( "SECTIONDTO : preview() : _url is "+_url );
			trace( "SECTIONDTO : preview() : _active is "+_active );
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
		
		public function get url() : String 
		{
			return _url;
		}
		
		public function get active() : String 
		{
			return _active;
		}
	}
}
