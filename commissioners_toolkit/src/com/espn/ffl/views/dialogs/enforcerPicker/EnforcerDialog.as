package com.espn.ffl.views.dialogs.enforcerPicker
{
	import com.espn.ffl.model.ContentModel;
	import com.espn.ffl.model.LeagueModel;
	import com.espn.ffl.util.Assets;
	import com.espn.ffl.util.FacebookHelper;
	import com.espn.ffl.util.Metrics;
	import com.espn.ffl.views.AbstractView;
	import com.espn.ffl.views.BubbleButton;
	import com.espn.ffl.views.Main;
	import com.espn.ffl.views.dialogs.AbstractDialog;
	import com.espn.ffl.views.dialogs.AlertDialogMaker;
	import com.espn.ffl.views.report_card.views.FflScrollArea;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	
	import leelib.facebook.FbResultEvent;
	import leelib.facebook.FbUtilWeb;
	import leelib.graphics.GrUtil;
	import leelib.graphics.Scale9BitmapSprite;
	import leelib.ui.ScrollArea;
	import leelib.util.Out;
	import leelib.util.StringUtil;
	import leelib.util.TextFieldUtil;
	
	
	public class EnforcerDialog extends AbstractDialog
	{
		public static const RESULT_OK:String = "ok";
		public static const RESULT_CANCEL:String = "cancel";
		
		public static const WIDTH:Number = 705;
		public static const HEIGHT:Number = 690;
		
		private var _chrome:Scale9BitmapSprite;
		private var _cancelButton:BubbleButton;
		private var _okButton:BubbleButton;
		private var _tfTitle:TextField;
		private var _tfSub:TextField;
		private var _inputBg:Shape;
		private var _tfInput:TextField;
		private var _allButton:EnforcerAllButton;
		private var _scrollAreaBg:Shape;
		private var _scrollArea:FflScrollArea;
		private var _buttons:Array;
		private var _tfNoFriends:TextField;
		
		private var _vos:Array;
		
		private var _fb:FbUtilWeb;
		
		private var _itemLoadCounter:int;
		
		private var _promptText:String;
		private var _committedMessage:String;
		
		/**
		 * @param $vos	Rem, this is the set of friend-vo's previously selected thru the friend picker dialog.
		 */		
		public function EnforcerDialog()
		{
			this.dialogWidth = WIDTH;
			this.dialogHeight = HEIGHT;
			
			_fb = FbUtilWeb.getInstance();
			_promptText = ContentModel.gi.getCopyItemByName("dialogPickerPrompt").copy;			
			
			var b:BitmapData = new Assets.DialogBg().bitmapData;
			_chrome = new Scale9BitmapSprite(b, new Rectangle(20,20,b.width-35-20,b.height-35-20));
			_chrome.width = WIDTH + 26;
			_chrome.height = HEIGHT + 12; // +12,12 for dropshadow
			this.addChild(_chrome);
			
			_tfTitle = TextFieldUtil.makeText(ContentModel.gi.getCopyItemByName("enforcerDialogTitle").copy, ".enforcerDialogTitle");
			_tfTitle.x = 30;
			_tfTitle.y = 35;
			this.addChild(_tfTitle);
			
			_tfSub = TextFieldUtil.makeText(ContentModel.gi.getCopyItemByName("enforcerDialogSub").copy, ".enforcerDialogSub");
			_tfSub.x = 30;
			_tfSub.y = 76;
			_tfSub.mouseEnabled = true;
			_tfSub.addEventListener(TextEvent.LINK, onTextLinkSettings);
			this.addChild(_tfSub);
			
			_inputBg = new Shape();
			_inputBg.graphics.lineStyle(1, 0x0);
			_inputBg.graphics.beginFill(0xffffff);
			_inputBg.graphics.drawRect(0,0, 645,51);
			_inputBg.graphics.endFill();
			_inputBg.x = 30;
			_inputBg.y = 131;
			this.addChild(_inputBg);
			
			_tfInput = TextFieldUtil.makeInput("", 630, ".enforcerDialogInput", 255);
			_tfInput.maxChars = 140;
			_tfInput.x = 45;
			_tfInput.y = 147;
			this.addChild(_tfInput);
			
			_scrollAreaBg = new Shape();
			_scrollAreaBg.graphics.lineStyle(1, 0x0);
			_scrollAreaBg.graphics.beginFill(0xffffff);
			_scrollAreaBg.graphics.drawRect(0,0, 645,405);
			_scrollAreaBg.graphics.endFill();
			_scrollAreaBg.x = 30;
			_scrollAreaBg.y = 199;
			this.addChild(_scrollAreaBg);
			
			_tfNoFriends = TextFieldUtil.makeText(ContentModel.gi.getCopyItemByName("enforcerDialogNoFriends").copy, ".alertDialogCopyRed");
			_tfNoFriends.mouseEnabled = true;
			_tfNoFriends.addEventListener(TextEvent.LINK, onTextLinkSettings);
			_tfNoFriends.x = 45;
			_tfNoFriends.y = 219;
			this.addChild(_tfNoFriends);
			
			_scrollArea = new FflScrollArea(606, EnforcerFriendButton.HEIGHT * 6, true);
			_scrollArea.x = 30;
			_scrollArea.y = 249+13;
			this.addChild(_scrollArea);
			
			_allButton = new EnforcerAllButton();
			_allButton.x = 47;
			_allButton.y = 218;
			this.addChild(_allButton);
			
			_cancelButton = new BubbleButton(ContentModel.gi.getCopyItemByName("dialogPickerCancelButton").copy, NaN, true);
			_cancelButton.x = 251;
			_cancelButton.y = 619;
			this.addChild(_cancelButton);
			
			_okButton = new BubbleButton(ContentModel.gi.getCopyItemByName("dialogPickerOkButton").copy, NaN);
			_okButton.x = 410;
			_okButton.y = 619;
			this.addChild(_okButton);
			
			this.alpha = 0;
			
			updateOkButtonState();
			
			this.assignButtons(_okButton, _cancelButton, _cancelButton);
		}
		
		public function get committedMessage():String
		{
			return _committedMessage;
		}
		
		// Takes array of FriendVo's
		//
		public function setVos($a:Array):void
		{
			_vos = $a;
			var item:EnforcerFriendButton;
			
			// cleanup first
			while (_scrollArea.contentHolder.numChildren > 0) {
				item = _scrollArea.contentHolder.removeChildAt(0) as EnforcerFriendButton;
				item.kill();
			}
			
			_buttons = [];
			for (var i:int = 0; i < _vos.length; i++)
			{
				item = new EnforcerFriendButton(_vos[i], loadNextItemImage);
				item.x = (i % 2 == 0) ? 12 : 310;
				item.y = 0 + int(i/2) * EnforcerFriendButton.HEIGHT;
				
				_scrollArea.contentHolder.addChild(item);
				_buttons.push(item);
			}
			
			_scrollArea.updateAfterContentChange(Math.ceil(_vos.length/2) * EnforcerFriendButton.HEIGHT);
			
			_itemLoadCounter = 0;
			loadNextItemImage();
			loadNextItemImage();
			
			updateViewState(_vos.length > 0);
		}
		
		public function updateViewState($hasFriends:Boolean):void
		{
			if ($hasFriends)
			{
				_tfSub.visible = true;
				_allButton.visible = true;
				_scrollArea.visible = true;
				_tfNoFriends.visible = false;
				_inputBg.alpha = 1;
				_tfInput.alpha = 1;
				_tfInput.mouseEnabled = true;
			}
			else
			{
				_tfSub.visible = false;
				_allButton.visible = false;
				_scrollArea.visible = false;
				_tfNoFriends.visible = true;
				_inputBg.alpha = 0.5;
				_tfInput.alpha = 0,5;
				_tfInput.mouseEnabled = false;
			}
		}
		
		public function getFriendVos():Array
		{
			return _vos;
		}
		
		public override function show(a:Number=0,b:Number=0):void
		{
			for each (var item:EnforcerFriendButton in _buttons)
			{
				item.enable();
			}
			
			_cancelButton.addEventListener(MouseEvent.CLICK, onCloseButtonClick);
			_okButton.addEventListener(MouseEvent.CLICK, onOkButtonClick, false,10); // make sure we hear button before before the other listener does
			_scrollArea.addEventListener(Event.CHANGE, onButtonChange); // bubbs
			_allButton.addEventListener(Event.CHANGE, onAllButtonChange, false,10);
			
			_tfInput.addEventListener(FocusEvent.FOCUS_IN, onInputIn);
			_tfInput.addEventListener(FocusEvent.FOCUS_OUT, onInputOut);
			
			_tfInput.text = _promptText;
			
			updateOkButtonState();
			
			super.show(a,b);
		}
		
		public override function hide(a:Number=0,b:Number=0):void
		{
			for each (var item:EnforcerFriendButton in _buttons)
			{
				item.disable();
			}
			
			_cancelButton.removeEventListener(MouseEvent.CLICK, onCloseButtonClick);
			_okButton.removeEventListener(MouseEvent.CLICK, onOkButtonClick);
			_scrollArea.removeEventListener(Event.CHANGE, onButtonChange);
			
			_tfInput.removeEventListener(FocusEvent.FOCUS_IN, onInputIn);
			_tfInput.removeEventListener(FocusEvent.FOCUS_OUT, onInputOut);
			
			super.hide(a,b);
		}
		
		public function getSelectedIds():Array
		{
			var a:Array = [];
			for each (var item:EnforcerFriendButton in _buttons)
			{
				if (item.selected) a.push(item.vo.id);
			}
			return a;
		}
		
		private function updateOkButtonState():void
		{
			var anItemIsSelected:Boolean = false;
			if (_buttons)
			{
				for each (var item:EnforcerFriendButton in _buttons)
				{
					if (item.selected) {
						anItemIsSelected = true;
						break;
					}
				}
			}
			
			if (anItemIsSelected) {
				_okButton.setDisabled(false);
			}
			else {
				_okButton.setDisabled(true);
			}
		}
		
		private function updateAllButtonState():void
		{
			// allButton is on, and if any button is off, turn allbutton off

			if (_allButton.selected) 
			{
				for each (var b:EnforcerFriendButton in _buttons) {
					if (! b.selected) {
						_allButton.selected = false;
						return;
					}
				}
			}
		}
		
		private function onButtonChange(e:*):void
		{
			updateAllButtonState();
			updateOkButtonState();
		}
		
		private function onInputIn(e:*):void
		{
			if (_tfInput.text == _promptText) _tfInput.text = "";
		}
		
		private function onInputOut(e:*):void
		{
			if (StringUtil.trim(_tfInput.text) == "") _tfInput.text = _promptText;			
		}
		
		private function onCloseButtonClick(e:*):void
		{
			// reset _committedMessage for good measure; leave user text alone tho
			_committedMessage = "";
			
			// ... super handles on-close callback
		}

		private function onOkButtonClick(e:*):void
		{
			_committedMessage = (_tfInput.text == _promptText) ? "" : _tfInput.text;
			if (_tfInput.text == _promptText) _tfInput.text = "";

			Out.i("EnforcerDialog.onOkButtonClick() - committedMessage:", _committedMessage);
			
			// ... super handles on-yes callback
		}
		
		private function loadNextItemImage():void
		{
			if (_itemLoadCounter >= _buttons.length) {
				// Out.i("PickFriendsDialog - done loading");
				return;
			}
			EnforcerFriendButton(_buttons[_itemLoadCounter]).loadImage();
			_itemLoadCounter += 1;
		}
		
		private function onAllButtonChange(e:*):void
		{
			if (_allButton.selected) {
				// check all
				for each (var b:EnforcerFriendButton in _buttons) {
					b.selected = true;
				}
			}
			else {
				// uncheck all
				for each (b in _buttons) {
					b.selected = false;
				}
			}
			updateOkButtonState();
		}
		
		private function onTextLinkSettings($e:Event):void
		{
			if ($e.target == _tfNoFriends)
				Metrics.pageView("enforcerShareDialogNoFriendsSettingsLink");
			else
				Metrics.pageView("enforcerShareDialogSettingsLink");
			
			FacebookHelper.instance.doMapperDialog( onMapperDialogDone );
		}
		private function onMapperDialogDone():void
		{
			this.setVos( FacebookHelper.instance.getFriendVosFromMap() );
		}
	}
}
