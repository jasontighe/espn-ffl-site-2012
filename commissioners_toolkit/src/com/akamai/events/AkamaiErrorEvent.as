package com.akamai.events
{
	import flash.events.Event;
	
	/**
	 * The AkamaiErrorEvent class provides notification of run-time errors
	 * encountered by the AkamaiConnection class. It makes available an error number 
	 * and error description for each error event.
	 * 
	 * @see com.akamai.AkamaiConnection
	 */
	public class AkamaiErrorEvent extends Event
	{
		/** 
		 * The AkamaiErrorEvent.ERROR constant defines the value of an error event's
		 * <code>type</code> property, which indicates that the class
		 * has encountered a run-time error.
		 * 
		 */
  		public static const ERROR:String = "error";
		/**
		 * An integer value representing the error condition.
		 */
        public var errorNumber:uint;
        /**
		 * A description of the error condition.
		 */
        public var errorDescription:String;
		/**
		 * Constructor. Normally called by the AkamaiConnection class, not used in application code.
		 * 
		 * @param type The event type; indicates the action that caused the event.
		 * @param errorNumber An integer specifying the error condition.
		 * @param errorDescription A verbose description of the error condition. 
		 */
            public function AkamaiErrorEvent(type:String, errorNumber:uint, errorDescription:String)             {
                // Call the constructor of the superclass.
                super(type);
                // Set the new properties.
                this.errorNumber = errorNumber;
                this.errorDescription = errorDescription;
   			}

            /** 
            * @private 
            * Override the inherited clone() method.
            */
            override public function clone():Event {
                return new AkamaiErrorEvent(type, errorNumber,errorDescription);
            }

	}
}