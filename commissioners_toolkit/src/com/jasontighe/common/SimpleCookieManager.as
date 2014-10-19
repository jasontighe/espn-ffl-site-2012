package com.jasontighe.common 
{
	import flash.display.MovieClip;
	import flash.events.NetStatusEvent;
	import flash.net.SharedObject;
	import flash.net.SharedObjectFlushStatus;

	/**
	 * @author jsuntai
	 */
	public class SimpleCookieManager 
	extends MovieClip
	{
		//----------------------------------------------------------------------------
		// public static variables
		//----------------------------------------------------------------------------
		public static var DAYS							: Number = 86400000;
		public static var HOURS							: Number = 3600000;
		public static var MINUTES						: Number = 600000;
		//----------------------------------------------------------------------------
		// public variables
		//----------------------------------------------------------------------------
		public var thisSO								: SharedObject;
		//----------------------------------------------------------------------------
		// constructor
		//----------------------------------------------------------------------------
		public function SimpleCookieManager()
		{
			trace( "SIMPLECOOKIEMANAGER : Constr" );
		}
		
		public function getCookie( cookiename : String ) : Object
		{
//			trace( "SIMPLECOOKIEMANAGER : getCookie() : cookiename is "+cookiename );
			thisSO = SharedObject.getLocal(cookiename, "/");
//			trace( "SIMPLECOOKIEMANAGER : getCookie() : thisSO is "+thisSO );
			if( thisSO == null || isExpired( thisSO ) )
			{
				return null;
			}
			
			return thisSO.data.valueObject;
		}
		
		public function setCookie( cookiename : String, obj : Object, time : Number ) : Object
		{
//			trace( "SIMPLECOOKIEMANAGER : setCookie() : cookiename is "+cookiename );
//			trace( "SIMPLECOOKIEMANAGER : setCookie() : obj is "+obj );
//			trace( "SIMPLECOOKIEMANAGER : setCookie() : time is "+time );
			var thisDate : Date = new Date();
			var timeMS : Number = time;
			var expirationDate : Number = thisDate.valueOf() + timeMS;
			
			thisSO = SharedObject.getLocal( cookiename, "/");
			thisSO.data.expirationDate = expirationDate;
			thisSO.data.valueObject = obj;
			
			var flushStatus : String = null;
			
            try 
            {
				trace("SIMPLECOOKIEMANAGER : setCookie() : Now Cookieing " + cookiename + ": " + thisSO.data.expirationDate + ", " + " and an array with " + thisSO.data.valueObject._deepLink.length + " values.");
                flushStatus = thisSO.flush( 10000 );
            } 
            catch ( error : Error ) 
            {
                trace("Error...Could not write SharedObject to disk\n");
            }
			
            if ( flushStatus != null ) 
                {
                     switch ( flushStatus ) 
                     {
                           case SharedObjectFlushStatus.PENDING:
                                trace("Requesting permission to save object...\n");
                                thisSO.addEventListener(NetStatusEvent.NET_STATUS, onFlushStatus);
                                break;
                           case SharedObjectFlushStatus.FLUSHED:
                                trace("Value flushed to disk.\n");
                                break;
                      }
                }
			
			return obj;
		}
		
		public function deleteCookie( cookiename : String ) : void
		{
			thisSO = SharedObject.getLocal(cookiename, "/");
			thisSO.data.expirationDate = null;
			var flushed:Object = thisSO.flush();
			thisSO.clear();	
		}
		
		public function cookieExists( cookiename : String ) : Boolean
		{
			//thisSO = SharedObject.getLocal(name, "/");
			thisSO = SharedObject.getLocal(cookiename, "/");
			trace("SIMPLECOOKIEMANAGER : cookieExists() : looking for " + SharedObject.getLocal(cookiename, "/").data);
			
			if(thisSO == null || isExpired(thisSO))
			{
				trace("SIMPLECOOKIEMANAGER : cookieExists() : simple cookie manager thinks " + cookiename + " doesn't exist");
				return false;
			}
			return true;
		}
 
	    public function onFlushStatus( e : NetStatusEvent ) : void 
	    {
//			trace("SIMPLECOOKIEMANAGER : onFlushStatus() : User closed permission dialog...\n");
			switch ( e.info.code ) 
			{
				 case "SharedObject.Flush.Success":
					   trace("User granted permission -- value saved.\n");
					   break;
				 case "SharedObject.Flush.Failed":
					   trace("User denied permission -- value not saved.\n");
					   break;
			}
			thisSO.removeEventListener(NetStatusEvent.NET_STATUS, onFlushStatus); 
	    }
		
		//----------------------------------------------------------------------------
		// private methods
		//----------------------------------------------------------------------------
		private function isExpired( so : SharedObject ) : Boolean
		{
//			trace("SIMPLECOOKIEMANAGER : isExpired()" );
			var thisDate : Date = new Date();
//			trace( "SIMPLECOOKIEMANAGER : isExpired() : thisDate is "+ thisDate.valueOf() );
//			trace( "SIMPLECOOKIEMANAGER : isExpired() : so.data.expirationDate is "+so.data.expirationDate );
			if( so == null || so.data.expirationDate == null || so.data.expirationDate.valueOf() < thisDate.valueOf() )
			{
				trace("SIMPLECOOKIEMANAGER : isExpired() : *expiration failing");
				return true;
			}	
			return false;
		}
	}
}