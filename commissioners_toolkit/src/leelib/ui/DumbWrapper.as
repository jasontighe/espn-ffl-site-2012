package leelib.ui
{
	import flash.display.DisplayObject;

	public class DumbWrapper extends Component
	{
		private var _do:DisplayObject;

		
		public function DumbWrapper($s:DisplayObject)
		{
			_do = $s;
			this.addChild(_do);
		}
		
		public override function size():void
		{
			_do.width = _sizeWidth;
			_do.height = _sizeHeight;
		}
	}
}
