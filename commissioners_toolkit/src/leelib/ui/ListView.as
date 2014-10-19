package leelib.ui
{
	import com.greensock.TweenLite;
	import com.greensock.easing.Cubic;
	import com.greensock.easing.Linear;
	
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.system.Capabilities;
	import flash.utils.Dictionary;
	
	import leelib.loadUtil.LoadUtil;
	import leelib.loadUtil.LoadUtilEvent;
	import leelib.util.Out;
	
	import mx.utils.LoaderUtil;
	
	import wk.adcolor.G;
	

	// Designed for mobile UI 'idiom'
	// 
	// Rem, ListItems' select event (AbstractListItem.EVENT_SELECT) bubble.
	//
	public class ListView extends Component
	{
		protected var _data:Array;
		
		private static var _DEBUG:Boolean = false;
		private static var _instanceCounter:int = -1;
		
		private static var _dragMinThresh:int; // amount of vertical travel allowed before a touch turns into a drag
		
		private var _instanceLoadEventName:String;

		private var _assetLoader:LoadUtil;

		private var _dataImageUrlField:String;

		private var _stage:Stage;
		private var _mask:Sprite;
		private var _holder:Sprite;

		private var _pools:Dictionary; // key = Class; value = object-pool array
		
		private var _isDragging:Boolean;
		private var _isTweening:Boolean;
		private var _dragStartMouseY:Number;
		private var _dragStartHolderY:Number;
		private var _dragCurrentMouseY:Number;
		private var _dragLastMouseY1:Number;
		private var _dragLastMouseY2:Number;
		private var _velocity:Number;
		
		private var _offsets:Array;
		private var _totalHeight:Number;
		private var _lastY:Number = 0;
		private var _topIndex:int; // points to the the y value of the top-most visible element
		private var _bottomIndex:int; // points to the y value _below_ the bottom-most visible element
		
		private var _posY:Number;
		
		private var _thumb:Sprite;
		private var _thumbRightMargin:Number = 5;
		private var _thumbVerticalMargin:Number = 5;
		private var _contentVerticalRange:Number;
		private var _thumbVerticalRange:Number;
		private var _isScrollingApplicable:Boolean;
		private var _tweenObject:Object;
		
		/**
		 * ListItem subclasses' data-classes must be unique.
		 * 
		 * If two data-classes share the same type (eg, a POD like String or even Object),
		 * one must be wrapped in a custom class.
		 */
		public function ListView($assetLoader:LoadUtil=null)
		{
			super();
			
			_assetLoader = $assetLoader;

			// dictionary of listitem pools
			_pools = new Dictionary();
						
			_instanceLoadEventName = "listview" + (++_instanceCounter).toString(); 

			if (! _dragMinThresh) {
				_dragMinThresh = Math.round(0.03 * Capabilities.screenDPI);  
			}
			
			_holder = new Sprite();
			this.addChild(_holder);
			
			_mask = new Sprite();
			this.addChild(_mask);
			if (! _DEBUG) _holder.mask = _mask;
			
			_thumb = new Sprite();
			_thumb.alpha = 0;
			_thumb.mouseEnabled = false;
			this.addChild(_thumb);
			
			// xxx check for dataClass uniqueness
			
			this.addEventListener(Event.ADDED_TO_STAGE, onA2s);
		}
		private function onA2s(e:*):void
		{
			this.removeEventListener(Event.ADDED_TO_STAGE, onA2s);
			_stage = this.stage;
		}

		protected override function doInit():void
		{
			activate();
		}
		
		public function activate():void
		{
			if (_assetLoader) _assetLoader.addEventListener(_instanceLoadEventName, onAssetLoaded);
			
			if (_isScrollingApplicable) {
				this.addEventListener(AbstractListItem.EVENT_MOUSEDOWN, onDragStart);
			}
		}
		
		public function deactivate():void
		{
			if (_assetLoader){
				_assetLoader.removeEventListener(_instanceLoadEventName, onAssetLoaded);
				_assetLoader.removeByEventName(_instanceLoadEventName, true);
			}
			this.removeEventListener(AbstractListItem.EVENT_MOUSEDOWN, onDragStart);
			this.removeEventListener(Event.ENTER_FRAME, onEnterFrameDragOrFling);
			
			// removing other listeners for good measure
			if (_stage) _stage.removeEventListener(MouseEvent.MOUSE_UP, onDraggingMouseUp);
			if (_stage) _stage.removeEventListener(MouseEvent.MOUSE_MOVE, onDragMove);
			
			resetDragRelatedState();
		}
		
		public override function kill():void
		{
			deactivate();
			
			// pools
			
			replaceActiveItemsToPool();
			
			for (var key:Object in _pools)
			{
				var a:Array = _pools[key] as Array;
				for each (var listItem:AbstractListItem in a)
				{
					listItem.kill();
				}
				delete _pools[key];
			}
			_pools = null;
			
			// displayobjects

			_holder.mask = null;
			this.removeChild(_holder);
			_holder = null;
			
			this.removeChild(_mask);
			_mask = null;
			
			this.removeChild(_thumb);
			_thumb = null;
			
			_data = null;
		}
		
		public function get data():Array
		{
			return _data;
		}
		
		public function get assetLoader():LoadUtil
		{
			return _assetLoader;
		}

		// Elements must be of type ListItemVo
		//
		public function set data($a:Array):void
		{			
			resetDragRelatedState();

			_data = $a;
			if (! _data) _data = [];
			trace('ListView.data - num:', $a.length);
			
			replaceActiveItemsToPool();
			
			// calc offsets
			calcOffsets();

			_isScrollingApplicable = (_totalHeight > _sizeHeight);
			_thumb.visible = _isScrollingApplicable;
			sizeThumb();			
			if (_isScrollingApplicable) {
				this.addEventListener(AbstractListItem.EVENT_MOUSEDOWN, onDragStart);
			}
			else {
				this.removeEventListener(AbstractListItem.EVENT_MOUSEDOWN, onDragStart);
			}
			if (_DEBUG) {
				_mask.addEventListener(MouseEvent.MOUSE_DOWN, onDragStart);
			}

			_thumb.alpha = 0;
			_topIndex = 0;
			_bottomIndex = 0;
			_posY = 0;
			moveHolderTo(0);
		}
		
		private function resetDragRelatedState():void
		{
			_velocity = 0;
			this.removeEventListener(Event.ENTER_FRAME, onEnterFrameDragOrFling);
			if (_stage) {
				_stage.removeEventListener(MouseEvent.MOUSE_MOVE, onDragMove);
				_stage.removeEventListener(MouseEvent.MOUSE_UP, onDraggingMouseUp);
			}
			_isDragging = false;
		}

		// Any change in number of elements in height or
		// any change in height of any element
		// requires recalculating ALL offsets.
		//
		private function calcOffsets():void
		{
			// rem, offset elements are positive numbers starting from 0
			_offsets = []; 

			if (! _data) return;
			
			_offsets.push(0);
			var cum:Number = 0;

			var i:int = 0;
			for (i = 0; i < _data.length; i++)
			{
				var o:Object = _data[i];
				var o2:IListItemData = o as IListItemData;
				if (! o2) throw new Error("Data object must implement IListItemData");
				var calcHeightFunction:Function = o2.listItemSubclass["calcHeightFor"]; // xxx change this interface 
				if (calcHeightFunction == null) {
					throw new Error("ListView.calcOffsets() - CLASS MUST IMPLEMENT STATIC FUNCTION CALCHEIGHTFOR" + o);
				}
				var h:Number = calcHeightFunction(o, _sizeWidth);
				cum += h;
				_offsets[i+1] = cum;
			}
			_totalHeight = cum;
		}

		public override function size():void
		{
			super.size();
			_mask.graphics.beginFill(0xff0000, (_DEBUG ? 0.33 : 1.0));
			_mask.graphics.drawRect(0,0, _sizeWidth, _sizeHeight);
			_mask.graphics.endFill();
			
			// TEMP
			this.graphics.clear();
			this.graphics.lineStyle(4, 0xff0000, 1.0);
			this.graphics.drawRect(-2,-2,_sizeWidth+4, _sizeHeight+4);
			
			sizeThumb();
		}

		public function scrollToItemByDataObject($dataObject:IListItemData, $tween:Boolean):Boolean
		{
			var index:int = _data.indexOf($dataObject); 
			if (index == -1) return false;

			resetDragRelatedState();

			var tweenStart:Number = _holder.y;
			var tweenEnd:Number = _offsets[index] * -1;
			var limit:Number = (_totalHeight - _sizeHeight) * -1; // clamp
			if (tweenEnd < limit) tweenEnd = limit;
			
			if ($tween) {
				_tweenObject = { value:tweenStart }
				TweenLite.to(_tweenObject, 0.66, { value:tweenEnd, ease:Cubic.easeOut, onUpdate:scrollToItemTweenUpdate, onComplete:scrollToItemTweenComplete } );
			}
			else {
				moveHolderTo(tweenEnd);
			}
			
			return true;
		}
		private function scrollToItemTweenUpdate():void
		{
			moveHolderTo(_tweenObject.value);
		}
		private function scrollToItemTweenComplete():void
		{
			_isTweening = false;
		}
		
		// Where topItem means first list item that is > 50% visible
		//
		public function getTopItemDataObject():Object
		{
			if (_data.length == 0) return null;
			if (_data.length == 1) return _data[0];
			
			var item0:AbstractListItem = _holder.getChildAt(0) as AbstractListItem;
			var item1:AbstractListItem = _holder.getChildAt(1) as AbstractListItem;
			if (! item0 || ! item1) {
				Out.w("ListView.getTopItemDataObject - SHOULDNT HAPPEN");
				return null;
			}
			
			var hy:Number = Math.abs(_holder.y);
			var item0MajorityVisible:Boolean = (hy - item0.y) < (item0.sizeHeight * 0.5);
			if (item0MajorityVisible)
				return item0.data;
			else
				return item1.data;
		}
		
		
		private function replaceActiveItemsToPool():void
		{
			while (_holder.numChildren > 0) {
				var item:AbstractListItem = _holder.removeChildAt(0) as AbstractListItem; // remove from holder
				var itemClass:Class = Object(item).constructor; // add item back to its object-pool
				_pools[itemClass].push(item); 
			}
		}
		
		private function sizeThumb():void
		{
			if (! _isScrollingApplicable) return;

			var w:Number = G.pw(0.025);
			var h:Number = (_sizeHeight / _totalHeight) * _sizeHeight;
			h = Math.max(_sizeHeight * 0.08, h);
			_thumb.graphics.clear();
			_thumb.graphics.beginFill(0x888888, 0.5);
			_thumb.graphics.drawRoundRect(0,0, w,h, w,w);
			_thumb.graphics.endFill();

			_thumbVerticalRange = _sizeHeight - h - _thumbVerticalMargin*2;
			_contentVerticalRange = _totalHeight - _sizeHeight;
			
			_thumb.x = _sizeWidth - w - _thumbRightMargin;

			positionThumbY();
		}
		
		private function showThumb():void
		{
			if (_isScrollingApplicable) TweenLite.to(_thumb, 0.20, { alpha:1.0, ease:Linear.easeNone } );
		}
		private function hideThumb():void
		{
			if (_isScrollingApplicable) TweenLite.to(_thumb, 0.35, { alpha:0, ease:Linear.easeNone } );
		}
		
		private function onDragStart($e:Event):void
		{
			_dragStartMouseY = _stage.mouseY;
			_dragCurrentMouseY = _dragLastMouseY1 = _dragLastMouseY2  =  _dragStartMouseY;
			
			_dragStartHolderY = _holder.y;

			_isDragging = true;
			_velocity = 0;

			_stage.addEventListener(MouseEvent.MOUSE_MOVE, onDragMove);
			_stage.addEventListener(MouseEvent.MOUSE_UP, onDraggingMouseUp);
		}
		private function onDragMove(e:*):void
		{
			if (Math.abs(_stage.mouseY - _dragStartMouseY) < _dragMinThresh) return;
			
			// at this point, we 'really' start the vertical dragging:

			_stage.removeEventListener(MouseEvent.MOUSE_MOVE, onDragMove);
			
			for (var i:int = 0; i < _holder.numChildren; i++) {
				AbstractListItem( _holder.getChildAt(i) ).cancelMouseDown();
			}
			this.addEventListener(Event.ENTER_FRAME, onEnterFrameDragOrFling);
			
			showThumb();
		}
		
		private function onEnterFrameDragOrFling($e:Event):void
		{
			var newy:Number;

			if (_isDragging)
			{
				_dragLastMouseY2 = _dragLastMouseY1;
				_dragLastMouseY1 = _dragCurrentMouseY;
				_dragCurrentMouseY = _stage.mouseY; // hah

				if (_dragCurrentMouseY == _dragLastMouseY1) return;
				
				var delta:Number = _dragCurrentMouseY - _dragStartMouseY;
				newy = _dragStartHolderY + delta; // later: ensure step is less than itemheight
			}
			else
			{
				_velocity *= 0.85; // friction
				
				if (Math.abs(_velocity) < 1.0) { // stops
					_velocity = 0;
					hideThumb();
					this.removeEventListener(Event.ENTER_FRAME, onEnterFrameDragOrFling);
				}
				
				newy = _holder.y + _velocity;
			}
			
			moveHolderTo(newy);
		}
		
		private function onEnterFrameTween():void
		{
		}
		
		public function get offset():Number
		{
			return Math.abs(_holder.y);
		}
		
		public function set offset($y:Number):void
		{
			moveHolderTo($y);
		}

		// $y = holder y value (should be negative)
		//
		private function moveHolderTo($y:Number):void
		{
			var wasPosY:Number = _posY;
			_posY = - $y; // switch sign (easier to work with positive numbers)

			// clamp $y
			if (_posY <= 0) { 
				_posY = 0; 
				_velocity = 0; 
			}
			else if (_posY > _totalHeight - _sizeHeight) { 
				_posY = _totalHeight - _sizeHeight; 
				_velocity = 0; 
			}
			
			_holder.y = - _posY;
			
			var holderDirectionIsUpNotDown:Boolean = (_posY - wasPosY >= 0);
			updateIncremental(holderDirectionIsUpNotDown, _posY-wasPosY);
			
			positionThumbY();
		}
		
		private function positionThumbY():void
		{
			_thumb.y = (_posY / _contentVerticalRange) * _thumbVerticalRange  +  _thumbVerticalMargin;
		}
		
		private function updateIncremental($holderDirectionIsUpNotDown:Boolean, $delta:Number):void
		{
			var orig:int;
			
			if ($holderDirectionIsUpNotDown)
			{
				// remove top elements that are no longer visible
				orig = _holder.numChildren;
				while (_offsets[_topIndex+1] < _posY)
				{
					if (_holder.numChildren == 0) // xxx I can remove this now yea?
					{
						trace('problem...', orig, $delta);
						_topIndex++
						continue;
					}
					
					var item1:AbstractListItem = _holder.removeChildAt(0) as AbstractListItem; // remove from holder
					var item1Class:Class = Object(item1).constructor; // add item back to its object-pool
					_pools[item1Class].push(item1); 
					_topIndex++;
				}

				// add elements to the bottom
				while (_offsets[_bottomIndex] < _posY + _sizeHeight)
				{
					// edge case
					if (_data.length == 0) break;
					
					addItem(_bottomIndex, false);
					_bottomIndex++;
					
					// edge case, happens when content height < sizeHeight:
					if (_bottomIndex == _offsets.length-1) break; 
				}
			}
			else // holder moved downwards
			{
				// remove bottom elements that are no longer visible
				orig = _holder.numChildren;
				while (_offsets[_bottomIndex-1] > _posY + _sizeHeight)
				{
					if (_holder.numChildren == 0)
					{
						trace('problem...', orig, $delta, _stage.mouseY);
						_bottomIndex--;
						continue;
					}
					var item2:AbstractListItem = _holder.removeChildAt(_holder.numChildren-1) as AbstractListItem;
					var item2Class:Class = Object(item2).constructor;
					_pools[item2Class].push(item2); 
					_bottomIndex--;
				}
				
				// add elements at the top
				while (_offsets[_topIndex] > _posY)
				{
					_topIndex--;
					addItem(_topIndex, true);
				}
			}			
		}

		// Remove a ListItem instance from object pool and add it to the display.
		// If no pool for that class exists yet, create it.
		// If pool is empty, instantiate a new item.
		//
		private function addItem($index:int, $toTopNotBottom:Boolean):void
		{
			var o:IListItemData = _data[$index];
			
			// check out a ListItem from correct object pool
			var pool:Array = _pools[o.listItemSubclass];

			if (! pool)
			{
				// Out.i("ListView.addItem - creating pool for ", o.listItemSubclass);
				pool = [];
				_pools[o.listItemSubclass] = pool;
			}

			if (pool.length == 0)
			{
				// temp: debugging info...
				// var num:int = 0; 
				// for (var i:int = 0; i < _holder.numChildren; i++) {
				//	  if (_holder.getChildAt(i) is o.listItemSubclass) num++;
				// }
				// Out.i("ListView.addItem -", o.listItemSubclass, " Added new item. New total:", num+1);
				
				// make new listitem and add it to the pool 
				var item:AbstractListItem = new o.listItemSubclass();
				item.initialize(Component.ORIGIN_TL, new Rectangle(0, 0, _sizeWidth, 50)); // 50 is temporary/arbitrary  
				pool.push(item);
			}
			
			var listItem:AbstractListItem = pool.pop(); // xxx need logic for empty pool
			
			// initialize it
			listItem.data = o;
			listItem.sizeHeight = _offsets[$index+1] - _offsets[$index+0];
			
			// add it to the display
			listItem.y = _offsets[$index];
			if (! $toTopNotBottom)
				_holder.addChild(listItem);
			else
				_holder.addChildAt(listItem, 0);
			
			// load async-asset if applicable
			if (listItem is AbstractAsyncListItem && o is IAsyncAssetData)
			{
				var ao:IAsyncAssetData = o as IAsyncAssetData;	
				var url:String = ao.assetUrl;
				var ali:AbstractAsyncListItem = AbstractAsyncListItem( listItem );
				if (! _assetLoader) {
					Out.w("ListView.addItem - NO ASSET LOADER");
					ali.setAsyncAssetToBlank();
				}
				else if (! url) {
					ali.setAsyncAssetToBlank();
				}
				else {
					ali.setAsyncAssetToLoading();
					_assetLoader.load(url, _instanceLoadEventName, ao.loadUtilAssetType, ao, true, false,false);
				}
			}
			
			// trace('index',$index, 'y', listItem.y, ' -', vo.listItemClass, vo.toString());
		}
		
		private function onAssetLoaded($e:LoadUtilEvent):void
		{
			var hit:AbstractAsyncListItem;
			
			for (var i:int = 0; i < _holder.numChildren; i++) // lookup 
			{
				var ali:AbstractAsyncListItem = _holder.getChildAt(i) as AbstractAsyncListItem;
				if (! ali) continue;
				if (ali.data == $e.callbackData) {
					hit = ali;
					break;
				}
			}

			if (hit)
			{
				if ($e.errorText || ! $e.data) 
				{
					trace('listview assetloaded ERROR', $e.errorText);
					hit.setAsyncAssetToError();
				}
				else 
				{
					hit.setAsyncAsset($e.data);
				}
			}
			else
			{
				// no match - cell must have already been scrolled out of view
			}
		}

		private function onDraggingMouseUp($e:Event):void
		{
			_isDragging = false;
			_stage.removeEventListener(MouseEvent.MOUSE_UP, onDraggingMouseUp);
			_stage.removeEventListener(MouseEvent.MOUSE_MOVE, onDragMove);
			
			_velocity = _dragCurrentMouseY - _dragLastMouseY2; // ie, 2 frames' worth
			_velocity *= 0.35; // magic numb
			var multiplier:Number = Math.log(Math.abs(_velocity)) // rem, log(10) = 2.3; log(100) = ~4.6; etc
			if (multiplier < 1) multiplier = 1;
			_velocity *= multiplier;
			
			// maybe don't need this
			var max:Number = _sizeHeight * 0.66; 
			if (_velocity > max) _velocity = max;
			if (_velocity < -max) _velocity = -max;
			
			if (_velocity == 0) {
				this.removeEventListener(Event.ENTER_FRAME, onEnterFrameDragOrFling);
				hideThumb();
			}
		}
		
		/*
		// works but unnecessary
		private function updateAll():void
		{
			trace('updateAll', _posY);
			
			// find topIndex 
			
			var i:int;
			for (i = 0; i < _offsets.length; i++) // xxx later start from topIndex-was and either increment or decrement
			{
				if (_offsets[i] > _posY) {
					_topIndex = i - 1;
					if (_topIndex == -1) _topIndex = 0;
					trace('topIndex is', _topIndex);
					break;
				}
			}
			
			// remove old items and replace them to their object-pools
			while (_holder.numChildren > 0) {
				var item:ListItem = _holder.removeChildAt(0) as ListItem; // remove from holder
				var itemClass:Class = Object(item).constructor; // add item back to its object-pool
				_pools[itemClass].push(item); 
			}
			
			// add items from _topIndex on:
			
			i = _topIndex;
			var bottom:Number = _posY + _sizeHeight;
			
			do
			{
				addItem(i, false);
				i++;
			}
			while (_offsets[i] < bottom && i < _data.length);
			
			_bottomIndex = i;
		}
		*/
	}
}

// xxx add clever logic to preload while queue is empty (maybe)

// xxx logic for when try to scroll past bounds - currently you have to drag back to starting point etc etc
// xxx or, do elastic actionn
