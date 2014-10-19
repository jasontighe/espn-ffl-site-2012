package com.espn.ffl.views.dialogs
{
	import com.espn.ffl.views.AbstractView;
	import com.espn.ffl.views.Main;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.text.TextField;
	
	import leelib.ui.ThreeStateButton;
	
	// does very little; not pretty neither
	//
	public class AbstractDialog extends AbstractView
	{
		public var dialogWidth:Number;
		public var dialogHeight:Number;
		
		public var yesButton:ThreeStateButton;
		public var noButton:ThreeStateButton;
		public var closeButton:Sprite;
		public var redBackground:Sprite;
		
		public var tfCopy:TextField;
		
		public var yesButtonCallback:Function;
		public var noButtonCallback:Function;
		public var closeButtonCallback:Function;
		
		
		public function AbstractDialog()
		{
			super();
		}
		
		public function set redBackgroundVisible($b:Boolean):void
		{
			if (redBackground) redBackground.visible = $b;
		}
		
		// yes and no take select event, close takes a mouseclick
		//
		public function assignButtons($yes:ThreeStateButton, $no:ThreeStateButton, $close:Sprite):void
		{
			if ($yes) $yes.addEventListener(Event.SELECT, onYesButton, false,0,true);
			if ($no) $no.addEventListener(Event.SELECT, onNoButton, false,0,true);
			if ($close) $close.addEventListener(MouseEvent.CLICK, onCloseButton, false,0,true);
			
			yesButton = $yes;
			noButton = $no;
			closeButton = $close;
		}
		
		protected function onYesButton($e:*):void
		{
			if (yesButtonCallback != null)
				yesButtonCallback();
			else
				Main.instance.hideDialog();
		}
		
		protected function onNoButton($e:*):void
		{
			if (noButtonCallback != null)
				noButtonCallback();
			else
				Main.instance.hideDialog();
		}
		
		protected function onCloseButton($e:*):void
		{
			if (closeButtonCallback != null)
				closeButtonCallback();
			else
				Main.instance.hideDialog();
		}
	}
}