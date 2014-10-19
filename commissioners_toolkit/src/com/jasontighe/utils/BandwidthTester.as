package com.jasontighe.utils {
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.Timer;

	/**
	 * @author jason.tighe
	 */
	public class BandwidthTester 
	extends EventDispatcher 
	{
		//----------------------------------------------------------------------------
		// public static constants
		//----------------------------------------------------------------------------
		public static const BAND_TESTED 					: String = 'tested';
        public static const TEST							: String = 'test';
 		//----------------------------------------------------------------------------
 		// private variables
 		//----------------------------------------------------------------------------
        private var _bandwidth 								: Number = 0;  //final average bandwidth
        private var _peakBandwidth							: Number = 0;  //peak bandwidth
        private var _currBandwidth 							: Number = 0;  //current take bandwidth
 
        private var _testFile 								: String = "http://www.jasontighe.com/cp_3on3/videos/jordancp_court_f024_c00_m.f4v";
        private var _loader									: URLLoader;    
        private var _timer									: Timer;       
        private var _lastBytes 								: Number = 0;  //bytes loaded last time
        private var _bandwidths								: Array;       //recorded byte speeds
        private var _latency 								: Number = 1;  //network utilization approximation
        //----------------------------------------------------------------------------
        // constructor
        //----------------------------------------------------------------------------
		public function BandwidthTester( latency : Number = 0 ) 
		{	
			trace( "BANDWIDTHTESTER : Constr" );
		    _latency = 1 - latency;
		    
			_timer = new Timer(1000, 3);
		    _timer.addEventListener( TimerEvent.TIMER, getBandwidth );
		    _timer.addEventListener( TimerEvent.TIMER_COMPLETE, onTimerComplete );
		    
		    _bandwidths = new Array();
		}
		 
		//----------------------------------------------------------------------------
		// public methods
		//---------------------------------------------------------------------------- 
		public function start( ) : void
		{
//			trace( "BANDWIDTHTESTER : start()" );
		    _loader = new URLLoader();
		    _loader.addEventListener( Event.OPEN, startTimer );
		    _loader.addEventListener( Event.COMPLETE, onLoadComplete );
		    _loader.load( new URLRequest( _testFile ) );
		}
		 
		public function startTimer( e : Event = null ) : void
		{
//			trace( "BANDWIDTHTESTER : startTimer()" );
		    _timer.start();
		}
		
		//----------------------------------------------------------------------------
		// private methods
		//----------------------------------------------------------------------------
		private function getBandwidth( e : TimerEvent ) : void
		{
//			trace( "BANDWIDTHTESTER : getBandwidth()" );
		    _currBandwidth = Math.floor( ( ( _loader.bytesLoaded-_lastBytes ) / 125 ) * _latency );
		    _bandwidths.push( _currBandwidth );
		    _lastBytes = _loader.bytesLoaded;
		 
		    dispatchEvent( new Event( BandwidthTester.TEST ) );
		}
		
		private function onTimerComplete( e : TimerEvent ) : void
		{
//			trace( "BANDWIDTHTESTER : onTimerComplete()" );
		    _loader.close();
		    _bandwidths.sort( Array.NUMERIC | Array.DESCENDING );
		 
		    _peakBandwidth = _bandwidths[0];
//			trace( "BANDWIDTHTESTER : onTimerComplete() : _peakBandwidth is "+_peakBandwidth );
		    _bandwidth = calcAvgBandwidth();
//			trace( "BANDWIDTHTESTER : onTimerComplete() : _bandwidth is "+_bandwidth );
		 
		    dispatchEvent( new Event( BandwidthTester.BAND_TESTED ) );
		}
		 
		private function onLoadComplete( e : Event ) : void
		{
//			trace( "BANDWIDTHTESTER : onLoadComplete()" );
		    _timer.stop();
		    _loader.close();
		    _bandwidths.sort( Array.NUMERIC | Array.DESCENDING );
		    _bandwidth = 10000;
		    _peakBandwidth = (_bandwidths[0])? _bandwidths[0] : _bandwidth;
		 
		    dispatchEvent( new Event( BandwidthTester.BAND_TESTED ) );
		}
		
		private function calcAvgBandwidth() : Number
		{
//			trace( "BANDWIDTHTESTER : calcAvgBandwidth()" );
		    var I : Number = 0;
		    var i : uint = _bandwidths.length;
		    
		    while( i-- )
		    {
		        I += _bandwidths[ i ];
//				trace( "BANDWIDTHTESTER : calcAvgBandwidth() : _bandwidths[ i ] is "+_bandwidths[ i ] );
		    }
		    
		    return Math.round( I / _bandwidths.length );
		}
		
		//----------------------------------------------------------------------------
		// getters/setters
		//----------------------------------------------------------------------------
		public function set latency( percent : Number ) : void
		{
		    _latency = 1 - percent;
		}
		 
		public function get bandwidth() : Number
		{
		    return _bandwidth;
		}
		 
		public function get peakBandwidth() : Number
		{
		    return _peakBandwidth;
		}
		
		public function get currBandwidth() : Number
		{
		    return _currBandwidth;
		}
	}
}
