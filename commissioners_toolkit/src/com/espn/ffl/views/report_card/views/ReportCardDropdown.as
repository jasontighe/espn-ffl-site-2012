package com.espn.ffl.views.report_card.views
{
	import com.espn.ffl.util.Assets;
	import com.greensock.TweenLite;
	import com.greensock.TweenMax;
	
	import flash.events.Event;
	import flash.filters.DropShadowFilter;
	
	import leelib.ui.Dropdown;
	import leelib.util.StringUtil;

	
	public class ReportCardDropdown extends Dropdown
	{
		private var _savedValue:Object;
		
		
		public function ReportCardDropdown($dropdownItemClass:Class, $isEditable:Boolean, $dropdownItemsShowSelectedState:Boolean, $entireItemActivatesDropdown:Boolean, $maxBottom:Number=NaN)
		{
			super($dropdownItemClass, 
				new Assets.ReportCardRowDropdownArrow(),
				new Assets.ReportCardRowDropdownArrowOver(),
				new Assets.ReportCardRowDropdownArrowOpen(), 
				$isEditable, 
				$dropdownItemsShowSelectedState, 
				$entireItemActivatesDropdown,
				$maxBottom);
		}
		
		protected override function showOpen($now:Boolean):void
		{
			super.showOpen($now);
			
			_dropdownHolder.visible = true;
			TweenLite.killTweensOf(_dropdownHolder);
			TweenLite.to( _dropdownHolder, ($now ? 0 : 0.25), { alpha:1 } );
			
			this.filters = [ new DropShadowFilter(6, 45, 0x0, 0.01, 4,4,1.0,2) ];
			TweenMax.to(this, ($now ? 0 : 0.20), {dropShadowFilter:{alpha:.5}});
		}
		
		protected override function showClosed($now:Boolean):void
		{
			TweenLite.killTweensOf(_dropdownHolder);
			TweenLite.to( _dropdownHolder, ($now ? 0 : 0.25), { alpha:0, onComplete:function():void{_dropdownHolder.visible=false;} } );
			
			this.filters = null;
		}
		
		// Extra functionality...
		// If user clicks into input field, and value is a canned value, 
		// save that value and clear field. If field is still blank
		// on-lose-focus, restore value.
		
		protected override function onMainItemFocusIn($e:Event):void
		{
			var isCannedValue:Boolean;
			for each (var o:Object in dropdownData) {
				if (value == o) {
					isCannedValue = true;
					break;
				}
			}
			if (isCannedValue) {
				_savedValue = value;
				_mainItem.value = "";
			}
			else {
				_savedValue = null;
			}
			
			super.onMainItemFocusIn($e);
		}
		
		protected override function onMainItemFocusOut($e:Event):void
		{
			var inputEmpty:Boolean = ! _mainItem.text  ||  StringUtil.trim(_mainItem.text).length == 0;
		
			if (_savedValue && inputEmpty) {
				commitChange(_savedValue); // restore
			}
			else {
				commitChange(_mainItem.text);
			}
		}
	}
}