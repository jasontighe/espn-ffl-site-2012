package com.espn.ffl.views.report_card.views
{
	import com.espn.ffl.util.Assets;
	import com.espn.ffl.util.Metrics;
	
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	
	import leelib.graphics.GrUtil;
	import leelib.ui.DropdownItem;
	import leelib.util.TextFieldUtil;

	
	public class GradeDropdownItem extends DropdownItem
	{
		public static const WIDTH:Number = 80;
		public static const DROPDOWNITEM_HEIGHT:Number = 31;
		public static const LEGAL_VALUES:Array = ['A+','A','A-','B+','B','B-','C+','C','C-','D','F'];

		private var _fmtMain:TextFormat;
		private var _fmtItemOff:TextFormat;
		private var _fmtItemOn:TextFormat;
		
		private var _bg:DisplayObject;

		
		public function GradeDropdownItem($isMainItemNotDropdownItem:Boolean, $isEditable:Boolean, $showsSelectedState:Boolean)
		{
			super($isMainItemNotDropdownItem, $isEditable, $showsSelectedState);
		}
		
		protected override function initSkin():void
		{
			if (_isMain) {
				_bg = new Assets.ReportCardRowGradeBg();
				_width = _bg.width;
				_height = _bg.height;
			}
			else {
				var s:Sprite = GrUtil.makeRect(88,DROPDOWNITEM_HEIGHT, 0xd5d0cb);
				s.graphics.lineStyle(1, 0xb0b0b0); // strokes on left and right
				s.graphics.moveTo(0,0);
				s.graphics.lineTo(0,_height);
				s.graphics.moveTo(_width,0);
				s.graphics.lineTo(_width,_height);
				_bg = s;
				_width = _bg.width;
				_height = DROPDOWNITEM_HEIGHT;
			}
			this.addChild(_bg);

			_hilite = GrUtil.makeRect(_width - 5,_height-2, 0xbd2a39);
			_hilite.x = 3;
			_hilite.y = 1; 
			this.addChild(_hilite); // 1px margin on top and bottom
			
			_fmtMain = new TextFormat();
			_fmtMain.color = 0xbd2a39;
			
			_fmtItemOff = new TextFormat();
			_fmtItemOff.color = 0xbd2a39;
			
			_fmtItemOn = new TextFormat();
			_fmtItemOn.color = 0xffffff;

			_tf = TextFieldUtil.makeText(" ", ".reportCardTableGrade", 50);
			_tf.styleSheet = null;
			_tf.x = 8;
			_tf.y = (_isMain) ? 1 : -2;
			_tf.selectable = false;
			_tf.mouseEnabled = false;
			this.addChild(_tf);
			
			// _tf.filters = [ new DropShadowFilter(1, 90, 0x0, .5, 0,0, 2, 2) ];
			
			if (_isEditable)
			{
				_tf.type = TextFieldType.INPUT;
			}
		}

		public override function kill():void
		{
			super.kill();
		}
		
		protected override function showOffState():void
		{
			_hilite.visible = false;
			
			if (_isMain) {
				_tf.defaultTextFormat = _fmtMain;
				_tf.setTextFormat(_fmtMain);
			}
			else {
				_tf.defaultTextFormat = _fmtItemOff;
				_tf.setTextFormat(_fmtItemOff);
			}
		}
		
		protected override function showOnState():void
		{
			_hilite.visible = true;
			
			_tf.defaultTextFormat = _fmtItemOn;
			_tf.setTextFormat(_fmtItemOn);
		}
		
		protected override function onClick(e:*):void
		{
			super.onClick(e);
			Metrics.pageView("reportCardGradeSelected");
		}	

	}
}