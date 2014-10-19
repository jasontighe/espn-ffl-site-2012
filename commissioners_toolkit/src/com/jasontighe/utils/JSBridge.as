package com.jasontighe.utils {
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import flash.utils.Timer;

	/**
	 * @author jsuntai
	 */
	public class JSBridge 
	extends EventDispatcher 
	{
		//----------------------------------------------------------------------------
		// protected variables
		//----------------------------------------------------------------------------
		
		//----------------------------------------------------------------------------
		// constructor
		//----------------------------------------------------------------------------
		public function JSBridge( ) 
		{
			init();
		}
		
		//----------------------------------------------------------------------------
		// public methods
		//----------------------------------------------------------------------------
        public function revealShareFooter() : void 
        {
			trace( "JSBRIDGE : revealShareFooter()"  );
            ExternalInterface.call("revealShareFooter");
        }
        
        public function doSocial( value1 : String = "", value2 : String = "" ) : void 
        {
			trace( "JSBRIDGE : doSocial()"  );
			var value1 : String = value1;
			var value2 : String = value2;
            ExternalInterface.call("doSocial", value1, value2 );
        }
        
        public function doFacbook() : void 
        {
			trace( "JSBRIDGE : doFacebook()"  );
            ExternalInterface.call("doFacebook");
        }
        
        public function doTwitter() : void 
        {
			trace( "JSBRIDGE : doTwitter()"  );
            ExternalInterface.call("doTwitter");
        }
		
		//----------------------------------------------------------------------------
		// protected methods
		//----------------------------------------------------------------------------
		protected function init() : void
		{            
			trace( "JSBRIDGE : init() : ExternalInterface.available is "+ExternalInterface.available );
            if (ExternalInterface.available) 
            {
                try 
                {
                    trace( "JSBRIDGE : init() : Adding callback...\n");
                    
//                   ExternalInterface.addCallback("initVideo", jsInitVideo );
                    if ( checkJavaScriptReady( ) ) 
                    {
                    	onBridgeComplete();
                    } 
                    else 
                    {
                        trace( "JSBRIDGE : init() : JavaScript is not ready, creating timer.\n");
                        var readyTimer:Timer = new Timer(100, 0);
                        readyTimer.addEventListener(TimerEvent.TIMER, timerHandler);
                        readyTimer.start();
                    }
                } 
                catch ( error : SecurityError ) 
                {
                    trace( "JSBRIDGE : init() : A SecurityError occurred: " + error.message + "\n");
                } 
                catch (error:Error) 
                {
                    trace( "JSBRIDGE : init() : An Error occurred: " + error.message + "\n");
                }
            } 
            else 
            {
                trace( "JSBRIDGE : init() : External interface is not available for this container.");
            }
        }
        
		protected function onBridgeComplete( ) : void
		{
			trace( "JSBRIDGE : onBridgeComplete()" );
			tellJSBridgeComplete();
		}
		
        protected function tellJSBridgeComplete() : void 
        {
			trace( "JSBRIDGE : tellJSBridgeComplete()"  );
            if (ExternalInterface.available) 
            {
				trace( "JSBRIDGE : tellJSBridgeComplete() : ExternalInterface.available is "+ExternalInterface.available  );
           		 ExternalInterface.call("tellJSBridgeComplete");
            }
        }
		
		//----------------------------------------------------------------------------
		// event handlers
		//----------------------------------------------------------------------------
        protected function timerHandler(event:TimerEvent):void 
        {
			trace( "JSBRIDGE : timerHandler() : Checking JavaScript status...\n"  );
            var isReady : Boolean = checkJavaScriptReady();
            if ( isReady ) 
            {
                trace( "JSBRIDGE : timerHandler() : JavaScript is ready.\n" );
                onBridgeComplete();
                Timer(event.target).stop();
            }
        }
        
        
		//----------------------------------------------------------------------------
		// getters/setters
		//----------------------------------------------------------------------------
        protected function checkJavaScriptReady():Boolean 
        {
            var isReady:Boolean = ExternalInterface.call("isReady");
            return isReady;
        }
	}
}
