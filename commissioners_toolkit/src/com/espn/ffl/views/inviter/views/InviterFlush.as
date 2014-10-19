package com.espn.ffl.views.inviter.views {
	import com.espn.ffl.apis.http.HusaniRequestor;
	import com.espn.ffl.views.AbstractView;
	import com.jasontighe.utils.Box;

	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.text.TextField;

	/**
	 * @author jason.tighe
	 */
	public class InviterFlush 
	extends AbstractView 
	{
		public function InviterFlush() 
		{
			super();
		}
		
		//----------------------------------------------------------------------------
		// public methods
		//----------------------------------------------------------------------------
		public override function init() : void 
		{
			alpha = 0;
		}
	}
}
