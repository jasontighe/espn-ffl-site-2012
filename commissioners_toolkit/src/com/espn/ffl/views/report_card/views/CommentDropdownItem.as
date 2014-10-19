package com.espn.ffl.views.report_card.views
{
	import com.espn.ffl.util.Assets;
	import com.espn.ffl.util.Metrics;
	import com.espn.ffl.views.report_card.ReportCardUtil;
	import com.hurlant.crypto.symmetric.NullPad;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import leelib.graphics.GrUtil;
	import leelib.ui.DropdownItem;
	import leelib.util.TextFieldUtil;
	

	public class CommentDropdownItem extends DropdownItem
	{
		public static const EVENT_OVER_INPUT:String = "cddi.eventOverInput";
		
		private var _fmtOff:TextFormat;
		private var _fmtOn:TextFormat;
		
		private var _bgMain:Bitmap;
		private var _bgMainTextOver:Sprite;
		private var _bgMainEditing:Bitmap;
		private var _bgItem:Sprite;
		
		private var _textHolder:Sprite;
		
		
		public function CommentDropdownItem($isMainItemNotDropdownItem:Boolean, $isEditable:Boolean, $showsSelectedState:Boolean)
		{
			super($isMainItemNotDropdownItem, $isEditable, $showsSelectedState);
		}

		protected override function initSkin():void
		{
			if (_isMain) 
			{
				_bgMain = new Assets.ReportCardRowCommentBg();
				this.addChild(_bgMain);
				
				_width = _bgMain.width;
				_height = _bgMain.height;
				
				_bgMainTextOver = new Sprite();
				_bgMainTextOver.graphics.beginFill(0xd5bfbf, .5);
				_bgMainTextOver.graphics.drawRect(14,10,385,16);
				_bgMainTextOver.graphics.endFill();
				this.addChild(_bgMainTextOver);

				_bgMainEditing = new Assets.ReportCardRowCommentEditBg();
				this.addChild(_bgMainEditing);
			}
			else 
			{
				_width = 433;
				_height = 38;
				_bgItem = GrUtil.makeRect(_width,_height, 0xd5d0cb); // width here = main's width + caret
				
				_bgItem.graphics.lineStyle(1, 0xb0b0b0); // strokes on left and right
				_bgItem.graphics.moveTo(0,0);
				_bgItem.graphics.lineTo(0,_height);
				_bgItem.graphics.moveTo(_width,0);
				_bgItem.graphics.lineTo(_width,_height);
				
				this.addChild(_bgItem);
			}
			
			_hilite = GrUtil.makeRect(_width - 5,_height-1, 0xbd2a39);
			_hilite.x = 3;
			_hilite.y = 0;
			this.addChild(_hilite);
		
			_fmtOff = new TextFormat();
			_fmtOff.color = 0x000000;
			
			_fmtOn = new TextFormat();
			_fmtOn.color = 0xffffff;

			_textHolder = new Sprite();
			_textHolder.x = 14;
			_textHolder.y = 10;
			this.addChild(_textHolder);
			
				_tf = TextFieldUtil.makeText(" ", ".reportCardTableComment", 385);
				_tf.styleSheet = null;
				_tf.selectable = false;
				_tf.mouseEnabled = false;
				_textHolder.addChild(_tf);
		}
		
		public override function set isEditable($b:Boolean):void
		{
			super.isEditable = $b;
			
			if ($b) {
				// add extra listener
				_textHolder.addEventListener(MouseEvent.ROLL_OVER, onTextHolderOver);
				_textHolder.addEventListener(MouseEvent.ROLL_OUT, onTextHolderOut);
				_tf.addEventListener(TextEvent.TEXT_INPUT, onCommentTextInput, false,1); // higher priority than base class's listener
			}
			else {
				_textHolder.removeEventListener(MouseEvent.ROLL_OVER, onTextHolderOver);
				_textHolder.removeEventListener(MouseEvent.ROLL_OUT, onTextHolderOut);
			}
		}
		
		protected override function showOffState():void
		{
			if (_isMain) 
			{
				_bgMainTextOver.visible = false;
				_bgMainEditing.visible = false;
			}
			
			_hilite.visible = false;
			
			_tf.defaultTextFormat = _fmtOff;
			_tf.setTextFormat(_fmtOff);
		}
		
		protected override function showOnState():void
		{
			_hilite.visible = true;
			
			_tf.defaultTextFormat = _fmtOn;
			_tf.setTextFormat(_fmtOn);
		}
		
		protected override function showEditState():void
		{
			_bgMainEditing.visible = true;
		}
		
		private function onTextHolderOver(e:*):void
		{
			if (ReportTable.instance.isEditingComment) return;
			_bgMainTextOver.visible = true;
			this.dispatchEvent(new Event(EVENT_OVER_INPUT, true));
		}
		private function onTextHolderOut(e:*):void
		{
			if (ReportTable.instance.isEditingComment) return;
			_bgMainTextOver.visible = false;
		}
		
		// need to hook this up
		private function showTextFieldOverState():void
		{
			
		}
		
		private function onCommentTextInput($e:TextEvent):void
		{
			if (_tf.textWidth > ReportCardUtil.COMMENT_WIDTH_THRESH * 0.89) { 
				// rem the width of this text and the image output text are different,
				// but they are the same typeface, so using a ratio here should work out
				$e.preventDefault();
			}
			if ($e.text.length > 1) {
				$e.preventDefault(); // prevent pasting text basically
			}
		}
		
		protected override function onClick(e:*):void
		{
			super.onClick(e);
			Metrics.pageView("reportCardCommentSelected");
		}
		
		protected override function onTextFieldFocusOut($e:Event):void
		{
			if (_textIsDirty) {
				Metrics.pageView("reportCardCommentEntered");
			}
			super.onTextFieldFocusOut($e);
		}

	}
}
