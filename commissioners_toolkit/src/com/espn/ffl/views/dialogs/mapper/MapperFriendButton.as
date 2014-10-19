package com.espn.ffl.views.dialogs.mapper
{
	import com.espn.ffl.util.Assets;
	import com.espn.ffl.views.BubbleButton;
	import com.greensock.TweenMax;
	
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
	import leelib.ui.ThreeStateButton;
	import leelib.util.Out;
	import leelib.util.TextFieldUtil;
	
	
	public class MapperFriendButton extends ThreeStateButton
	{
		public static const WIDTH:Number = 278;
		public static const HEIGHT:Number = 50;
		public static const ICON_HEIGHT:Number = 50;
		public static const MARGIN_V:Number = 5;
		
		private var _checkBox:Bitmap;
		private var _checkMark:Bitmap;
		
		private var _icon:Bitmap;
		private var _tf:TextField;
		
		private var _vo:FbFriendVo;
		private var _loadCompleteCallback:Function;
		private var _selected:Boolean;
		
		private var _loader:Loader;
		private var _isLoaded:Boolean;
		
		private var _selectedFlag:Boolean;
		
		
		public function MapperFriendButton($vo:FbFriendVo, $loadCompleteCallback:Function)
		{
			_vo = $vo;
			_loadCompleteCallback = $loadCompleteCallback;
			
			selectEventBubbles = true;
			
			GrUtil.replaceRect(this, WIDTH,HEIGHT, 0xff0000, 0.0); // clickabilty
			
			_checkBox = new Assets.Checkbox()
			_checkBox.x = 0;
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
			
			_tf = TextFieldUtil.makeText(_vo.name, ".dialogMapperTeamButton", WIDTH-93);
			_tf.x = 93;
			_tf.y = (HEIGHT - _tf.height) * .5;
			this.addChild(_tf);
			
			TextFieldUtil.ellipsize(_tf, _tf.width);
			
			_loader = new Loader();
			_loader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onLoaderSecurityError, false,0,true);
			_loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onLoaderError, false,0,true);
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoaderComplete, false,0,true);
			// ... but don't load yet
			
			super();
		}

		// read-only (setting is done thru ctor)
		public function get friendVo():FbFriendVo
		{
			return _vo;
		}
		
		public function isLoaded():Boolean
		{
			return _isLoaded;
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
		
		public override function kill():void
		{
			super.kill();

			_loader.contentLoaderInfo.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, onLoaderSecurityError);
			_loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onLoaderError);
			_loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onLoaderComplete);

			try {
				if (! _isLoaded) _loader.close();
				_loader.unload();
			}
			catch (e:Error) {}
			
			if (_icon.bitmapData) _icon.bitmapData.dispose();
			_icon = null;
		}
		
		protected override function showUnselectedOut():void
		{
			_icon.alpha = _tf.alpha = 1;
			_checkMark.visible = false;
			
			if (_selectedFlag) {
				_selectedFlag = false;
				TweenMax.to(_icon, 0, {colorMatrixFilter:{brightness: 1, saturation:1} } );
			}
		}
		
		protected override function showUnselectedOver():void
		{
			_icon.alpha = _tf.alpha = 1;
			_checkMark.visible = true;
			_checkMark.alpha = 0.5;
			
			if (_selectedFlag) {
				_selectedFlag = false;
				TweenMax.to(_icon, 0, {colorMatrixFilter:{brightness: 1, saturation:1} } );
			}
		}
		
		protected override function showSelected():void
		{
			TweenMax.to(_icon, 0.5, {colorMatrixFilter:{brightness: 1.33, saturation:0} } );
			_tf.alpha = .5;
			_checkMark.visible = true;
			_checkMark.alpha = 1;
			
			_selectedFlag = true;
		}
	}
}
