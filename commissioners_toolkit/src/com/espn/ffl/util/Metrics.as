package com.espn.ffl.util
{
	import com.espn.ffl.model.ContentModel;
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.external.ExternalInterface;
	
	import leelib.util.Out;
	
	public class Metrics extends EventDispatcher
	{
		public static function pageViewWithTag($tag:String):void
		{
			var result:String = ExternalInterface.call("_gaq.push", ['_trackPageview', $tag] );
			
			Out.d('Metrics.pageView() -', $tag, " (result:"+result+")");
		}

		public static function pageView($xmlName:String, $andReplaceThis:String=null, $withThis:String=null):void
		{
			var s:String = ContentModel.gi.metricsData[$xmlName];
			if (! s) {
				Out.w("Metrics.pageView - NO XML NODE WITH THAT NAME", $xmlName);
				return;
			}

			if ($andReplaceThis) {
				s = s.replace($andReplaceThis, $withThis);
			}
			pageViewWithTag(s);
		}

		public static function event($notDoneYet:String):void
		{
		}
	}
}
