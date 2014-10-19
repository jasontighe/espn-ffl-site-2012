package leelib.ui
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	
	import leelib.graphics.GrUtil;

	
	public class DropdownItem extends Sprite
	{
		protected var _dropdownRef:Dropdown; // * circular ref
		
		protected var _width:Number;
		protected var _height:Number;
		
		protected var _hilite:Sprite;
		
		protected var _isMain:Boolean;
		protected var _isEditable:Boolean;
		protected var _value:Object;

		protected var _isSelected:Boolean;
		protected var _isEnabled:Boolean;
		protected var _showsSelectedState:Boolean;
		
		protected var _tf:TextField;
		
		protected var _textIsDirty:Boolean;

		
		// Subclasses must maintain same constructor signature
		// 
		// Really shoulda make 2 classes, 'dropdownmain' and 'dropdownitem',
		// since this must handle both 'types'...
		//
		public function DropdownItem($isMainItemNotDropdownItem:Boolean, $isEditable:Boolean, $showsSelectedState:Boolean)
		{
			_isMain = $isMainItemNotDropdownItem;
			_isEditable = $isEditable
			_showsSelectedState = $showsSelectedState;

			initSkin();
			
			isEditable = _isEditable; // commit change

			isEnabled = true;
			showOffState();
		}
		
		protected function initSkin():void
		{
		}
		
		public function set dropdownReference($dd:Dropdown):void
		{
			_dropdownRef = $dd;
		}
		
		public function get itemWidth():Number
		{
			return _width;
		}
		public function get itemHeight():Number
		{
			return _height;
		}
		
		public function get isEnabled():Boolean
		{
			return _isEnabled;
		}
		
		public function set isEnabled($b:Boolean):void
		{
			_isEnabled = $b;
			if (_isEnabled) 
			{
				this.addEventListener(MouseEvent.ROLL_OVER, onOver);
				this.addEventListener(MouseEvent.ROLL_OUT, onOut);
				this.addEventListener(MouseEvent.CLICK, onClick);
			}
			else 
			{
				this.removeEventListener(MouseEvent.ROLL_OVER, onOver);
				this.removeEventListener(MouseEvent.CLICK, onClick);
				this.removeEventListener(MouseEvent.ROLL_OUT, onOut);
			}
		}
		
		public function get isEditable():Boolean
		{
			return _isEditable;
		}
		public function set isEditable($b:Boolean):void
		{
			_isEditable = $b;

			if (_isEditable) {
				
				_tf.type = TextFieldType.INPUT;
				_tf.selectable = true;
				_tf.mouseEnabled = true;
				
				_tf.addEventListener(FocusEvent.FOCUS_IN, onTextFieldFocusIn);
				_tf.addEventListener(KeyboardEvent.KEY_DOWN, onTextFieldKeyDown);
				_tf.addEventListener(FocusEvent.FOCUS_OUT, onTextFieldFocusOut);
			}
			else {
				_tf.type = TextFieldType.DYNAMIC;
				_tf.selectable = false;
				_tf.mouseEnabled = false;
				
				_tf.removeEventListener(FocusEvent.FOCUS_IN, onTextFieldFocusIn);
				_tf.removeEventListener(KeyboardEvent.KEY_DOWN, onTextFieldKeyDown);
				_tf.removeEventListener(FocusEvent.FOCUS_OUT, onTextFieldFocusOut);
			}
		}
		
		public function get showsSelectedState():Boolean
		{
			return _showsSelectedState;
		}
		public function set showsSelectedState($b:Boolean):void
		{
			_showsSelectedState = $b;
		}
		
		// NB, these getter/setters bypass _value
		//
		public function get text():String
		{
			return _tf.text;
		}
		public function set text($s:String):void
		{
			_tf.text = $s;
		}

		public function get value():Object
		{
			return _value;
		}
		public function set value($o:Object):void
		{
			_value = $o;
			
			onValueUpdated();
		}
		protected function onValueUpdated():void
		{
			// Update view here based on value
			
			// This is the typical behavior: (override if needed)
			_tf.text = _value as String;
		}
		
		public function get isSelected():Boolean
		{
			return _isSelected;
		}
		public function set isSelected($b:Boolean):void
		{
			_isSelected = $b;
			
			if (_showsSelectedState) 
			{ 
				if (_isSelected) { 
					showOnState();
					this.buttonMode = false;
				}
				else {
					showOffState();
					this.buttonMode = true;
				}
			}
			else {
				showOffState();
				this.buttonMode = true;
			}			
		}
		
		public function kill():void
		{
			isEnabled = false;
			isEditable = false;
		}
		
		private function onOver(e:*):void
		{
			showOnState();
		}
		private function onOut(e:*):void
		{
			if (_showsSelectedState) 
			{ 
				if (_isSelected) 
					showOnState();
				else
					showOffState()
			}
			else {
				showOffState();
			}
		}
		protected function onClick(e:*):void
		{
			showOffState();
			this.dispatchEvent(new Event(Event.SELECT));
		}	
		
		protected function onTextFieldFocusIn($e:FocusEvent):void
		{
			_textIsDirty = false;
			_tf.addEventListener(TextEvent.TEXT_INPUT, onTextInput);
			showEditState();
			// rem, $e keeps bubbling
		}
		
		protected function onTextInput($e:TextEvent):void
		{
			_textIsDirty = true; // subclass can use this for whatever needs (eg, metrics)
		}
		
		protected function onTextFieldKeyDown($e:KeyboardEvent):void
		{
			if ($e.keyCode == 13) // pressed enter
			{
				$e.stopImmediatePropagation();
				this.stage.focus = null; 
				// and then onTextFieldFocusOut gets called... 
			}
		}
		
		protected function onTextFieldFocusOut($e:Event):void
		{
			_tf.removeEventListener(TextEvent.TEXT_INPUT, onTextInput);
			showOffState();
			// rem, $e keeps bubbling
		}
		
		protected function showOffState():void
		{
			_hilite.visible = false;
		}
		
		protected function showOnState():void
		{
			_hilite.visible = true;
		}
		
		protected function showEditState():void
		{
			// override this
			_tf.border = true;
		}
	}
}
