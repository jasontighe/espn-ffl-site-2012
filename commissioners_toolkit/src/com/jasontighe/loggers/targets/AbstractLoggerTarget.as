package com.jasontighe.loggers.targets {	import flash.utils.getTimer;		import com.jasontighe.loggers.LevelObject;	import com.jasontighe.loggers.Logger;	import com.jasontighe.loggers.TargetCreator;		public class AbstractLoggerTarget implements ILoggerTarget	{		public function publish( level:LevelObject, obj:* ):void 		{		}			public function get id():String		{			return TargetCreator.TRACE;			}		protected function checkFormat( obj:* ):*		{			if ( !obj ) obj = "null";			obj = checkIntervalTime( obj );			obj = checkElapseTime( obj );			obj = checkTimeStamp( obj );			return obj;		}				protected function checkLevel( levelObject:LevelObject ):Boolean		{				var isLevelActive:Boolean;			if ( levelObject.index < Logger.level )				isLevelActive = true;			return isLevelActive;		}		protected function checkFilter( obj:* ):Boolean		{			var isFiltered:Boolean;			if ( Boolean( Logger.filter ) && String( obj ).indexOf( Logger.filter, -1 ) )				isFiltered = true;			return isFiltered;			}		private function addZeros( value:int, digits:uint ):String 		{			var zeros:String = ""; 			var i:int = 0;			var l:int = digits - value.toString( ).length; 			for ( i; i < l ; i++ ) 			{				zeros += "0"; 			}			return String( zeros + value.toString( ) ); 		}		private function formatDate( d:Date ):String		{			return d.toLocaleTimeString( ).split( " " ).join( String( ":" + addZeros( d.milliseconds, 4 ) + " " ) );		}		private function formatTime( ms:uint ):String		{			var s:Number = ms / 1000;			var m:Number = s / 60;			var h:Number = m / 60;			return addZeros( h, 2 ) + ":" + addZeros( m, 2 ) + ":" + addZeros( s, 2 ) + ":" + addZeros( ms, 4 );		}		private function getTimeStamp( ):String 		{			return formatDate( new Date( ) );		}		private function getElapseTime( ):String		{			return formatTime( getTimer() );		}		private function getIntervalTime( ):String		{			var t:int = getTimer( );			var ms:int = t - Logger.lastTime;			Logger.lastTime = t;			return formatTime( ms );		}		private function checkIntervalTime( obj:* ):*		{			if ( Logger.isMeasuringIntervalTime )				obj = "Interval = " + getIntervalTime( ) + " : " + obj;			return obj;			}		private function checkElapseTime( obj:* ):*		{			if ( Logger.isMeasuringElapseTime )				obj = "Elapse = " + getElapseTime( ) + " : " + obj;			return obj;			}		private function checkTimeStamp( obj:* ):String		{			if ( Logger.isRecordingTimeStamp )				obj = "Time = " + getTimeStamp( ) + " : " + obj;			return obj;			}	}}