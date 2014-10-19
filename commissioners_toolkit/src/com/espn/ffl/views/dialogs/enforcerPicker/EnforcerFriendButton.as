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
	
	public class EnforcerFriendButton extends Sprite
	{
		public static const WIDTH:Number = 280;
		public static const HEIGHT:Number = 50 + 4;
		public static const ICON_HEIGHT:Number = 50;
		public static const TEXT_WIDTH:Number = 195;
		
		private var _checkBox:Bitmap;
		private var _checkMark:Bitmap;
			
		private var _icon:Bitmap;
		private var _tf:TextField;
		
		private var _vo:FbFriendVo;
		private var _loadCompleteCallback:Function;
		private var _selected:Boolean;
		
		private var _loader:Loader;
		private var _isLoaded:Boolean;
		
		
		public function EnforcerFriendButton($vo:FbFriendVo, $loadCompleteCallback:Function)
		{
			_vo = $vo;
			_loadCompleteCallback = $loadCompleteCallback;

			_checkBox = new Assets.Checkbox()
			_checkBox.x = 5;
			_checkBox.y = (HEIGHT - _checkBox.height) * .5;
			this.addChild(_checkBox);
			
			_checkMark = new Assets.Check();
			_checkMark.x = _checkBox.x + 4;
			_checkMark.y = _checkBox.y + 4;
			this.addChild(_checkMark);
			

			_icon = new Bitmap();
			var b:BitmapData = new BitmapData(ICON_HEIGHT,ICON_HEIGHT, false, 0x888888);
			_icon.bitmapData = b;
			_icon.x = 35;
			_icon.y = (HEIGHT - ICON_HEIGHT) * .5;
			this.addChild(_icon);
				
			_tf = TextFieldUtil.makeText(" ", ".fbFriend", TEXT_WIDTH);
			_tf.selectable = false;
			_tf.x = 96;
			_tf.y = (HEIGHT - _tf.height) * .5;
			_tf.text = _vo.name;
			this.addChild(_tf);
			
			TextFieldUtil.ellipsize(_tf, TEXT_WIDTH-5);
			
			selected = false;
			enable();
			
			_loader = new Loader();
			_loader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onLoaderSecurityError, false,0,true);
			_loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onLoaderError, false,0,true);
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoaderComplete, false,0,true);
			// ... but don't load yet
		}

		public function loadImage():void
		{
			if (_isLoaded) {
				_loadCompleteCallback();
				return;
			}
			var url:String = _vo.squareIconUrl;
			_loader.load(new URLRequest(url), new LoaderContext(true));
		}
		
		private function onLoaderSecurityError($e:SecurityErrorEvent):void
		{
			Out.e("FriendPickerItem.onLoaderSecurityError()", $e.text);
			_isLoaded = true; // it's really not but yea
			_icon.bitmapData = new Assets.FacebookDefaultThumb().bitmapData
			_loadCompleteCallback();
		}
		
		private function onLoaderError($e:IOErrorEvent):void
		{
			Out.e("FriendPickerItem.onLoaderError()", $e.text);
			_isLoaded = true;
			_icon.bitmapData = new Assets.FacebookDefaultThumb().bitmapData
			_loadCompleteCallback();
		}
		
		private function onLoaderComplete($e:Event):void
		{
			_isLoaded = true;
			if (_loader.content && _loader.content is Bitmap) 
			{
				var b:Bitmap = _loader.content as Bitmap;
				if (b.bitmapData) _icon.bitmapData = b.bitmapData;
			}
			_loadCompleteCallback();
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
		
		public function isLoaded():Boolean
		{
			return _isLoaded;
		}
		
		public function kill():void
		{
			disable();

			_checkBox = null;
			
			_tf = null;
			_vo = null;

			try {
				if (! _isLoaded) _loader.close();
				_loader.unload();
			}
			catch (e:Error) {}

			if (_icon.bitmapData) _icon.bitmapData.dispose();
			_icon = null;
		}
		
		public function get vo():FbFriendVo
		{
			return _vo;
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
