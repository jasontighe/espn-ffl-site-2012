package com.espn.ffl.views.dialogs.enforcerPicker
{
	import com.espn.ffl.util.Assets;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	import flash.text.TextField;
	
	import leelib.facebook.FbFriendVo;
	import leelib.graphics.GrUtil;
	import leelib.util.Out;
	import leelib.util.TextFieldUtil;
	
	public class EnforcerAllButton extends Sprite
	{
		public static const WIDTH:Number = 280;
		public static const HEIGHT:Number = 50 + 4;
		public static const ICON_HEIGHT:Number = 50;
		public static const TEXT_WIDTH:Number = 195;
		
		private var _checkBox:Bitmap;
		private var _checkMark:Bitmap;
		
		private var _tf:TextField;
		
		private var _selected:Boolean;
		
		
		public function EnforcerAllButton()
		{
			_checkBox = new Assets.Checkbox()
			_checkBox.x = 0;
			_checkBox.y = 0;
			this.addChild(_checkBox);
			
			_checkMark = new Assets.Check();
			_checkMark.x = _checkBox.x + 4;
			_checkMark.y = _checkBox.y + 4;
			this.addChild(_checkMark);
			
			_tf = TextFieldUtil.makeText("Select All", ".enforcerAllButton");
			_tf.selectable = false;
			_tf.x = 26;
			_tf.y = -4;
			this.addChild(_tf);
			
			selected = false;
			enable();
		}
		
		public function enable():void
		{
			this.addEventListener(MouseEvent.ROLL_OVER, onOver);
			this.addEventListener(MouseEvent.ROLL_OUT, onOut);
			this.addEventListener(MouseEvent.CLICK, onClick);
		}
		
		public function disable():void
		{
			this.removeEventListener(MouseEvent.ROLL_OVER, onOver);
			this.removeEventListener(MouseEvent.ROLL_OUT, onOut);
			this.removeEventListener(MouseEvent.CLICK, onClick);
		}
		
		public function kill():void
		{
			disable();
			
			_checkBox = null;
			
			_tf = null;
		}
		
		public function get selected():Boolean
		{
			return _selected;
		}
		
		public function set selected($b:Boolean):void
		{
			_selected = $b;
			
			_checkMark.visible = $b;
			if ($b) _checkMark.alpha = 1;
		}
		
		private function onOver(e:*):void
		{
			if (_selected) return;
			_checkMark.visible = true;
			_checkMark.alpha = 0.5
		}
		private function onOut(e:*):void
		{
			if (_selected) return;
			_checkMark.visible = false;
		}
		
		private function onClick(e:*):void
		{
			// this changes own state
			selected = !_selected;
			this.dispatchEvent(new Event(Event.CHANGE, true));
		}
	}
}
