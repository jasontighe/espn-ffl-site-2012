package com.encoding.utils {
	import com.jasontighe.utils.StringReplacer;

	/**
	 * @author jason.tighe
	 * 
	 * Because Encoding.com's json response comes as 
	 * "new Object({ 'state' : 'uploading', 'received' : 3931129, 'size' : 6341448 })"
	 * This class removes the "new Object()" portion, and replaces 
	 * the ' with ", since JSON does not read '.
	 * 
	 */
	public class EncodingJSONData 
	{
		public function EncodingJSONData() {}
		
		public static function getJSONData( data : String ) : String
		{
			var char : String = data.charAt( 12 );
//			trace( "ENCODINGJSONDATA : getJSONData() : char is "+char );
			
			var start : int = data.search( "{" );
			var end : int = data.search( "}" );
			var jsonData : String = data.slice( start, end ) + "}" as String; 
			
			if( char == '"')
			{
//				trace( "ENCODINGJSONDATA : getJSONData() : CASE 1" );
				return jsonData;
			}
			else
			{
//				trace( "ENCODINGJSONDATA : getJSONData() : CASE 2" );
				// REPLACE ' to " to AVOID JSON PARSING ERRORS
				var string : String = StringReplacer.replace( jsonData, "'", '"' );
				return string;
			}
			
		}
	}
}
