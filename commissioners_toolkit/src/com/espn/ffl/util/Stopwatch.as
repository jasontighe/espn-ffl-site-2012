package com.espn.ffl.util {
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.utils.getTimer;

	/**
	 * @author jason.tighe
	 */
	public class Stopwatch 
	extends Sprite 
	{
		//----------------------------------------------------------------------------
		// protected variables
		//----------------------------------------------------------------------------
		protected var _startTime						: int;
		protected var _stopTime							: int;
		protected var _elapsedTime						: int;
		//----------------------------------------------------------------------------
		// constructor
		//----------------------------------------------------------------------------
		public function Stopwatch() {}
		
		//----------------------------------------------------------------------------
		// public methods
		//----------------------------------------------------------------------------
		public function begin() : void
		{
			_startTime = getTimer();
			_elapsedTime = 0;
//			trace("STOPWATCH : begin() : _startTime: "+_startTime);
		}
		
		public function end() : void
		{
			_stopTime = getTimer();
		
//			trace("\n\nSTOPWATCH : end() : _stopTime: "+_stopTime);
			var timeDiff : int = _stopTime - _startTime;
			_elapsedTime =  int( ( _stopTime - _startTime ) / 1000 );
//			trace("STOPWATCH : end() : _elapsedTime: "+_elapsedTime);
			clearTimers();
		}
 
		//----------------------------------------------------------------------------
		// private methods
		//----------------------------------------------------------------------------
		private function clearTimers( ) : void 
		{
			_startTime = 0;
			_stopTime = 0;
		}
		
		private function formatTime( $time : uint ) : String 
		{
			var formattedTime:String;
			var hrs:uint;
			var mins:uint;
			var secs:uint;
			var ms:uint;
			 
			var msAfterHrs:uint = $time % ((1000 * 60) * 60);
			hrs = ($time - msAfterHrs) / ((1000 * 60) * 60);
			 
			var msAfterMins:uint = msAfterHrs % (1000 * 60);
			mins = (msAfterHrs - msAfterMins) / (1000 * 60);
			 
			var msAfterSecs:uint = msAfterMins % 1000;
			secs = (msAfterMins - msAfterSecs) / 1000;
			 
			ms = msAfterSecs;
			 
			if (ms == 100) 
			{
				ms = 0;
			}
 
			//formattedTime = formatNumber(hrs, 2)+":"+formatNumber(mins, 2)+":"+formatNumber(secs, 2)+"."+formatNumber(ms, 3);
			formattedTime = formatNumber(hrs, 2)+"h "+formatNumber(mins, 2)+"m "+formatNumber(secs, 2)+"s";
			 
			return formattedTime;
		}
 
		private function formatNumber( $num : uint, $digits : uint) : String 
		{
			var formattedNum:String;
				 
			if ( $digits == 2 ) 
			{
				if ($num < 10) 
				{
					formattedNum = "0"+$num;
				} 
				else 
				{
					formattedNum = String($num);
				}
			} 
			else if ( $digits == 3 ) 
			{
				if ($num < 10) 
				{
					formattedNum = "00"+$num;
				} 
				else if ($num < 100) 
				{
					formattedNum = "0"+$num;
				} 
				else 
				{
					formattedNum = String($num);
				}
			}
			return formattedNum;
		}
		
		//----------------------------------------------------------------------------
		// getter/setters
		//----------------------------------------------------------------------------
		public function get elapsedTime() : uint
		{
			return _elapsedTime;
		}
	}
}