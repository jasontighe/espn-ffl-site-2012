package com.espn.ffl.views.apparel {
	import com.espn.ffl.views.AbstractView;

	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;

	/**
	 * @author jason.tighe
	 */
	public class Apparel 
	extends AbstractView 
	{
		//----------------------------------------------------------------------------
		// constructor
		//----------------------------------------------------------------------------
		public function Apparel() 
		{
			super();
			trace( "APPAREL : Constr" );
			var tf : TextField = new TextField();
			tf.htmlText = "LEAGUE APPAREL";
			tf.autoSize = TextFieldAutoSize.LEFT;
			addChild( tf );
		}
		
		//----------------------------------------------------------------------------
		// public methods
		//----------------------------------------------------------------------------
		public override function transitionIn() : void { }
		public override function transitionOut() : void { }
		
		//----------------------------------------------------------------------------
		// protected methods
		//----------------------------------------------------------------------------
//		protected override function transitionInComplete() : void { }
//		protected override function transitionOutComplete() : void { }
//		protected override function addViews() : void { }
	}
}
