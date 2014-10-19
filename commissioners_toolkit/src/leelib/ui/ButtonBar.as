package leelib.ui
{
	import flash.events.Event;
	

	// Note, updates own state.
	// Not currently designed to have num buttons change dynamically.
	//
	// For concrete use, best to make a static 'factory' method off a Button subclass,
	// that kind of thing.
	//
	public class ButtonBar extends Component
	{
		protected var _buttons:Vector.<Button>;
		private var _enabled:Boolean;
		private var _selectedIndex:int = -1;
		
		/**
		 * Buttons expected to be already baked. 
		 * Their positions will be changed, but not their sizes.
		 */
		public function ButtonBar($buttons:Array)
		{
			super();
			_buttons = Vector.<Button>($buttons);
		}

		protected override function doInit():void
		{
			for (var i:int = 0; i < _buttons.length; i++) {
				_buttons[i].addEventListener(Event.SELECT, onButtonSelect);
				this.addChild(_buttons[i]);
			}

			// Overwrites sizeWidth and Height passed thru initialize() with values based on _buttons vector!
			_sizeWidth = 0;
			for each (var b:Button in _buttons) {
				_sizeWidth += b.sizeWidth;
			}
			_sizeHeight = _buttons[0].sizeHeight;
			enabled = true;
		}
		
		public override function size():void
		{
			var x:Number = 0;
			for (var i:int = 0; i < _buttons.length; i++)
			{
				_buttons[i].x = x;
				x += _buttons[i].sizeWidth;
			}
		}
		
		public function get enabled():Boolean
		{
			return _enabled;
		}
		public function set enabled($b:Boolean):void
		{
			_enabled = $b;
			
			this.mouseChildren = _enabled;
			this.alpha = (_enabled ? 1 : 0.5); // for now			
		}

		public function get selectedIndex():int
		{
			return _selectedIndex;
		}
		public function set selectedIndex($i:int):void
		{
			_selectedIndex = $i;
			updateButtonSelectedness();
		}
		
		//
		
		protected function updateButtonSelectedness():void
		{
			for (var i:int = 0; i < _buttons.length; i++)
			{
				_buttons[i].selected = (i == _selectedIndex);
			}
		}
		
		protected function onButtonSelect($e:Event):void
		{
			selectedIndex = _buttons.indexOf($e.target);
			this.dispatchEvent(new Event(Event.SELECT));
		}
	}
}
