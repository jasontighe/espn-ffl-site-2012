package com.jasontighe.utils {

	/**
	 * @author jason.tighe
	 */
	public class StringReplacer {
		
		public static function replace( haystack:String, needle:String, replacement:String ):String
		{
		    var tmpA:Array = haystack.split( needle );
		    return tmpA.join( replacement );
		}
		
		private function multiSplit( haystack:String, needles:Array ):Array
		{
		    // generate a unique String for concatenation.
		    var salt:String = String( Math.random() ); //replace with anything you like
		
		    // Replace all of the strings in the needles array with the salt variable
		    for( var i:Number = 0; i < needles.length; i++ )
		    {
		        haystack = replace( haystack, needles[ i ], salt );
		    }
		
		    //haystack now only has the objects you want split up concatenated by the salt variable.
		    //split haystack and you'll have your desired result.
		    return haystack.split( salt );
		}
	}
}