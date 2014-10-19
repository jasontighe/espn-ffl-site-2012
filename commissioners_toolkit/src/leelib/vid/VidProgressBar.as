package leelib.vid
{
	import flash.display.DisplayObject;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.clearInterval;
	import flash.utils.setInterval;
	
	import leelib.ExtendedEvent;
	import leelib.ui.Component;
	import leelib.util.MathUtil;
	
	public class VidProgressBar extends Component
	{
		public static const EVENT_DRAGSTART:String = "VidProgressBar.eventDragStart";
		public static const EVENT_DRAGEND:String = "VidProgressBar.eventDragEnd";
		
		private var _bgBar:Component;
		private var _loadBar:Component;
		private var _playElement:Component;
		
		private var _stage:Stage;

		private var _progressIsBarNotThumb:Boolean;

		private var _loadProgress:Number = 0;
		private var _playProgress:Number = 0;
		private var _scrubbable:Boolean;
		
		private var _intervalId:Number;
		
		
		/**
		 * Elements get reparented 
		 */		
		public function VidProgressBar($backgroundBar:Component, $loadProgressBar:Component, $playThing:Component, $scrubbable:Boolean, $width:Number, $height:Number, $progressIsBarNotThumb:Boolean, $stageRef:Stage)
		{
			_stage = $stageRef;
			_progressIsBarNotThumb = $progressIsBarNotThumb;
			
			_bgBar = $backgroundBar;
			this.addChild(_bgBar);
			
			_loadBar = $loadProgressBar;
			this.addChild(_loadBar);
			
			_playElement = $playThing;
			this.addChild(_playElement);
			
			_playElement.visible = false; // gets turns on by MinVid on-ready

			_scrubbable = $scrubbable;
			if (_scrubbable) {
				this.buttonMode = true;
				this.addEventListener(MouseEvent.MOUSE_DOWN, onDown);
			}

			sizeWidthHeight($width, $height);
		}
		
		public function get loadProgress():Number
		{
			return _loadProgress;
		}
		public function set loadProgress($scalar:Number):void
		{
			_loadProgress = MathUtil.clamp($scalar, 0,1);
			sizeLoadBar();
		}
		
		public function get playProgress():Number
		{
			return _playProgress;
		}
		public function set playProgress($scalar:Number):void
		{
			_playProgress = MathUtil.clamp($scalar, 0,1);
			sizePlay();
		}
		
		public function get playElement():DisplayObject
		{
			return _playElement;
		}
		
		public override function sizeWidthHeight($width:Number, $height:Number):void
		{
			_sizeWidth = $width;
			_sizeHeight = $height;

			_bgBar.sizeWidthHeight(_sizeWidth, _sizeHeight);

			size();
		}
		
		public override function size():void
		{
			sizeLoadBar();
			sizePlay();
		}
		
		private function sizeLoadBar():void
		{
			_loadBar.sizeWidthHeight(_sizeWidth * _loadProgress, _sizeHeight);
		}
		
		private function sizePlay():void
		{
			if (_progressIsBarNotThumb)
				_playElement.sizeWidthHeight(_sizeWidth * _playProgress, _sizeHeight);
			else
				_playElement.x = _sizeWidth * _playProgress;
		}
		
		private function onDown(e:*):void
		{
			this.dispatchEvent(new Event(EVENT_DRAGSTART));

			onDragging();
			
			clearInterval(_intervalId);
			_intervalId = setInterval(onDragging, 100);
			
			_stage.addEventListener(MouseEvent.MOUSE_UP, onUp);
			_stage.addEventListener(Event.MOUSE_LEAVE, onUp);
		}
		
		private function onDragging():void
		{
			var n:Number = this.mouseX / _sizeWidth;
			n = MathUtil.clamp(n, 0,1);
			this.dispatchEvent(new ExtendedEvent(Event.CHANGE, n as Object));
		}
		
		private function onUp(e:*):void
		{
			onDragging();

			clearInterval(_intervalId);
			_intervalId = NaN;
			
			_stage.removeEventListener(MouseEvent.MOUSE_UP, onUp);
			_stage.removeEventListener(Event.MOUSE_LEAVE, onUp);
			
			this.dispatchEvent(new Event(EVENT_DRAGEND));
		}
	}
}
