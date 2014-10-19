package com.espn.ffl.views.enforcer.views
{
	import com.greensock.TweenLite;
	
	import flash.display.DisplayObject;
	
	import leelib.ui.ThreeStateButton;
	
	public class QuickButton extends ThreeStateButton
	{
		public var overDuration:Number = 0.5;
		public var disabledAlpha:Number = 0.5;
		
		private var _off:DisplayObject;
		private var _over:DisplayObject;
		
		private var _isDisabled:Boolean;
		
		
		public function QuickButton($off:DisplayObject, $over:DisplayObject)
		{
			_off = $off;
			this.addChild(_off);
			
			_over = $over;
			_over.alpha = 0;
			this.addChild(_over);

			super();
		}
		
		public function get isDisabled():Boolean
		{
			return _isDisabled;
		}
		
		public function set isDisabled($b:Boolean):void
		{
			_isDisabled = $b;
			if (_isDisabled) {
				this.mouseEnabled = this.mouseChildren = false;
				TweenLite.to(this, overDuration*2, { alpha:disabledAlpha } );
			}
			else {
				TweenLite.to(this, overDuration*2, { alpha:1 } );
				this.mouseEnabled = this.mouseChildren = true;
			}
		}
		
		protected override function showUnselectedOut():void
		{
			TweenLite.to(_over, overDuration, { alpha:0 } );
		}
		
		protected override function showUnselectedOver():void
		{
			TweenLite.to(_over, overDuration, { alpha:1 } );
		}
		
		protected override function showSelected():void
		{
			showUnselectedOver();
		}
	}
}