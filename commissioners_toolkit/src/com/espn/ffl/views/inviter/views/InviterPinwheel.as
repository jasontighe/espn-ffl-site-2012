package com.espn.ffl.views.inviter.views {
	import com.espn.ffl.constants.SiteConstants;
	import com.espn.ffl.util.Assets;
	import com.greensock.TweenLite;
	import com.greensock.easing.Linear;
	import com.jasontighe.utils.Box;

	import flash.display.MovieClip;

	/**
	 * @author jason.tighe
	 */
	public class InviterPinwheel 
	extends MovieClip 
	{
		private var _pinwheelInner							: MovieClip;
		private var pinwheel								: MovieClip;
		
		public function InviterPinwheel() 
		{	
			var box : Box = new Box( SiteConstants.WEBCAM_FULL_WIDTH, SiteConstants.WEBCAM_FULL_HEIGHT, 0x000000 );
			addChild( box );
			
			pinwheel = new Assets.Pinwheel();
			pinwheel.x = int( box.width * .5 );
			pinwheel.y = int( box.height* .5 ) - 26;
			pinwheel.scaleX *= -1;
			addChild( pinwheel );
		}
		
		public function showPinwheel():void
		{

//			TweenLite.killTweensOf(pinwheel);
//			TweenLite.to(pinwheel, 0.5, { autoAlpha:1 } );
			
			pinwheel.rotation = 0;
			TweenLite.to(pinwheel, 9999, { rotation:9999*360, ease:Linear.easeNone } );
		}
		
		public function hidePinwheel():void
		{
//			TweenLite.killTweensOf(pinwheel);
//			TweenLite.to(pinwheel, 0.2, { alpha:0, onComplete:function():void{pinwheel.visible=false;} } );
			
			TweenLite.killTweensOf(pinwheel);
		}
	}
}
