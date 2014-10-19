package leelib.ui 
{
	import com.greensock.TweenLite;
	import com.greensock.TweenMax;
	
	import flash.display.BlendMode;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.geom.Point;

	/**
	 * TODO: Make abstracted 'dropdowns controller'
	 * 		 A concrete implementation of this currently lives in com.espn.ffl.ReportTable...
	 */
	public class Dropdown extends Sprite
	{
		public static const EVENT_OPENED:String = "dd.eventOpened";

		protected var _mainItem:DropdownItem;
		
		protected var _caret:Sprite;
			protected var _caretOff:DisplayObject;
			protected var _caretOver:DisplayObject;
			protected var _caretOpen:DisplayObject;
			
		protected var _dropdownHolder:Sprite;
		protected var _dropdownItems:Array;

		protected var _dropdownItemClass:Class;
		
		private var _isEditable:Boolean;
		private var _dropdownItemsShowSelectedState:Boolean;
		private var _bottomThresholdGlobal:Number;
		private var _entireItemActivatesDropdown:Boolean

		/**
		 * $caret 					gets reparented
		 * $caretOver, $caretOpen	optional
		 * $maxBottom 				y threshold in global space which ...
		 */
		public function Dropdown($dropdownItemClass:Class, $caretOff:DisplayObject, $caretOver:DisplayObject, $caretOpen:DisplayObject, 
								 $isEditable:Boolean, $dropdownItemsShowSelectedState:Boolean, $entireItemActivatesDropdown:Boolean, $maxBottom:Number=NaN)
		{
			_dropdownItemClass = $dropdownItemClass;
			_isEditable = $isEditable;
			_dropdownItemsShowSelectedState = $dropdownItemsShowSelectedState;
			_entireItemActivatesDropdown = $entireItemActivatesDropdown;
			_bottomThresholdGlobal = $maxBottom;
			
			_mainItem = new _dropdownItemClass(true, _isEditable, _dropdownItemsShowSelectedState);
			_mainItem.addEventListener(FocusEvent.FOCUS_OUT, onMainItemFocusOut);
			_mainItem.addEventListener(FocusEvent.FOCUS_IN, onMainItemFocusIn);
			_mainItem.isEnabled = false;
			_mainItem.dropdownReference = this; // NB!
			this.addChild(_mainItem);
			
			_caret = new Sprite();
			
				_caretOff = $caretOff;
				_caret.addChild(_caretOff);
				_caretOver = $caretOver;
				if (_caretOver) _caret.addChild(_caretOver);
				_caretOpen = $caretOpen;
				if (_caretOpen) _caret.addChild(_caretOpen);
			
			_caret.x = _mainItem.itemWidth + 1;
			_caret.y = 0;
			_caret.buttonMode = true;
			_caret.addEventListener(MouseEvent.CLICK, onCaretClick);
			this.addChild(_caret); // * reparents
			
			if (_entireItemActivatesDropdown) 
			{
				// this is not a good way of doing things
				_caret.graphics.beginFill(0xff0000, 0.0);
				_caret.graphics.drawRect( -(_mainItem.itemWidth + 1), 0, (_mainItem.itemWidth + 1), _caret.height );
				_caret.graphics.endFill();
			}
			
			_dropdownHolder = new Sprite();
			_dropdownHolder.blendMode = BlendMode.LAYER
			_dropdownHolder.x = 0;
			_dropdownHolder.visible = false;
			this.addChild(_dropdownHolder);
			
			close(true);
		}

		public function set bottomThresholdGlobal($n:Number):void
		{
			_bottomThresholdGlobal = $n;
		}
		
		public function get itemWidth():Number
		{
			return _mainItem.itemWidth
		}
		
		public function get itemPlusCaretWidth():Number
		{
			if (_entireItemActivatesDropdown)
				return _caret.x + _caret.width - (_mainItem.itemWidth + 1); // lame; adjust for extra width of see-thru rect
			else
				return _caret.x + _caret.width;
		}

		public function open($now:Boolean=false):void
		{
			if (_caretOpen) _caretOpen.visible = true;

			var thresh:Number = localToGlobal(new Point()).y + _mainItem.height + _dropdownHolder.height;
			var growUp:Boolean = (thresh > _bottomThresholdGlobal);

			if (! growUp) {
				_dropdownHolder.y = _mainItem.itemHeight
			}
			else {
				// add up dropdownitems' heights
				var sum:Number = 0;
				for each (var ddi:DropdownItem in _dropdownItems) {
					sum += ddi.itemHeight;
				}
				_dropdownHolder.y = -sum;
			}
			
			this.addEventListener(MouseEvent.CLICK, onThisClick, false, 1);
			this.stage.addEventListener(MouseEvent.CLICK, onStageClick, false, 0);
			
			showOpen($now);
		}
		
		protected function showOpen($now:Boolean):void
		{
			_dropdownHolder.visible = true;
		}
		
		public function close($now:Boolean=false):void
		{
			if (_caretOver) _caretOver.visible = false;
			if (_caretOpen) _caretOpen.visible = false;
			
			_caret.addEventListener(MouseEvent.ROLL_OVER, onCaretOver);
			_caret.addEventListener(MouseEvent.ROLL_OUT, onCaretOut);

			if (this.stage) this.stage.removeEventListener(MouseEvent.CLICK, onStageClick);
			this.removeEventListener(MouseEvent.CLICK, onThisClick);
			
			showClosed($now);
		}
		
		protected function showClosed($now:Boolean):void
		{
			_dropdownHolder.visible = false;
		}
		
		public function get isOpen():Boolean
		{
			return _dropdownHolder.visible;
		}
		
		public function get value():Object
		{
			return _mainItem.value;
		}
		
		public function set value($o:Object):void
		{
			_mainItem.value = $o;
			
			for each (var item:DropdownItem in _dropdownItems) 
			{
				item.isSelected = (item.value == _mainItem.value);
			}
		}
		
		public function get dropdownData():Array
		{
			var a:Array = [];
			for (var i:int = 0; i < _dropdownItems.length; i++) {
				a.push(DropdownItem(_dropdownItems[i]).value);
			}
			return a;
		}

		public function set dropdownData($a:Array):void
		{
			var ddi:DropdownItem;
			
			while (_dropdownHolder.numChildren > 0) // cleanup first
			{
				ddi = _dropdownHolder.removeChildAt(0) as DropdownItem;
				ddi.kill();
			}
			
			_dropdownItems = [];
			var y:Number = 0;
			
			for (var i:int = 0; i < $a.length; i++)
			{
				ddi = new _dropdownItemClass(false, false, _dropdownItemsShowSelectedState);
				
				ddi.value = $a[i];
				
				ddi.x = 0;
				
				ddi.y = y;
				y += ddi.itemHeight;
				
				ddi.addEventListener(Event.SELECT, onDropdownItemSelect);
				
				_dropdownHolder.addChild(ddi);
				_dropdownItems.push(ddi);
			}
			
			close();
		}
		
		public function get mainItem():DropdownItem
		{
			return _mainItem;
		}
		
		public function kill():void
		{
			_mainItem.dropdownReference = null;
			
			_mainItem.removeEventListener(FocusEvent.FOCUS_OUT, onMainItemFocusOut);
			_mainItem.removeEventListener(FocusEvent.FOCUS_IN, onMainItemFocusIn);

			_caret.removeEventListener(MouseEvent.ROLL_OVER, onCaretOver);
			_caret.removeEventListener(MouseEvent.ROLL_OUT, onCaretOut);
			
			for (var i:int = 0; i < _dropdownItems.length; i++) {
				DropdownItem( _dropdownItems[i] ).removeEventListener(Event.SELECT, onDropdownItemSelect);
				DropdownItem( _dropdownItems[i] ).kill() 
			}
		}
		
		private function onCaretOver(e:*):void
		{
			if (_caretOver) _caretOver.visible = true;
		}
		private function onCaretOut(e:*):void
		{
			if (_caretOver) _caretOver.visible = false;
		}
		
		private function onCaretClick($e:Event):void
		{
			$e.stopImmediatePropagation();
			
			if (this.isOpen)
			{
				this.close();
			}
			else
			{
				this.open();
				this.dispatchEvent(new Event(EVENT_OPENED, true));
			}
		}
		
		private function onThisClick($e:Event):void
		{
			$e.stopImmediatePropagation();
		}
		private function onStageClick($e:Event):void
		{
			// while this isOpen, user clicked anywhere outside of this
			this.close();
		}
		
		protected function onMainItemFocusIn($e:Event):void
		{
			if (this.isOpen) this.close();
			
			// rem, focus event keeps bubbling
		}

		private function onDropdownItemSelect($e:Event):void
		{
			var targetItem:DropdownItem = $e.target as DropdownItem;
			commitChange(targetItem.value as String);
		}
		protected function onMainItemFocusOut($e:Event):void
		{
			commitChange(_mainItem.text);
			
			// rem, focus event keeps bubbling. 
			// at the point when handled, make sure focusout and change handling logic don't get confused.
		}
		protected function commitChange($o:Object):void
		{
			value = $o;
			this.close();
			this.dispatchEvent(new Event(Event.CHANGE));
		}
	}
}