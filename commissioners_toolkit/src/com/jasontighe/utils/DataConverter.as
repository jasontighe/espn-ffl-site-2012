package com.jasontighe.utils {

	/**
	 * @author jason.tighe
	 */
	public class DataConverter 
	{
		public function DataConverter() {};
		
		public static function formatFileSize( bytes : Number ) : String
    	{
	        if( bytes < 1024 )
	            return bytes + " bytes";
	        else
	        {
	            bytes /= 1024;
	            if(bytes < 1024)
	                return Math.round(bytes *100)/100 + " KB";
	            else
	            {
	                bytes /= 1024;
	                if(bytes < 1024)
	                    return Math.round(bytes *100)/100 + " MB";
	                else
	                {
	                    bytes /= 1024;
	                    if(bytes < 1024)
	                        return Math.round(bytes *100)/100 + " GB";
	                }
	            }
	        }
	        return String(bytes);
		}
	}
}