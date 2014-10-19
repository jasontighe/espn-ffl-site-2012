package com.espn.ffl.views.dialogs.mapper
{
	import com.espn.ffl.views.report_card.views.FflScrollArea;
	
	import flash.display.Sprite;
	
	import leelib.util.Out;
	
	public class MapperFriendPanel extends Sprite
	{
		private var _scrollArea:FflScrollArea;
		
		private var _buttons:Array;

		private var _loadCounter:int;

		
		public function MapperFriendPanel($scrollAreaWidth:Number, $scrollAreaHeight:Number)
		{
			super();
			
			_scrollArea = new FflScrollArea($scrollAreaWidth, $scrollAreaHeight, true);
			_scrollArea.x = 0;
			_scrollArea.y = 0;
			this.addChild(_scrollArea);

			/*
			_scrollArea.graphics.beginFill(0xc0c0c0);
			_scrollArea.graphics.drawRect(0,0, 277,321);
			_scrollArea.graphics.endFill();
			*/
		}
		
		// $teamFriendMap used for MapperDialog only
		//
		public function initialize($friendVos:Array, $teamFriendMap:Object):void
		{
			// clear first
			while (_scrollArea.contentHolder.numChildren > 0) { 
				friendButton = _scrollArea.contentHolder.removeChildAt(0) as MapperFriendButton;
				friendButton.kill();
			}
			
			// make buttons inside scrollarea
			var friendButton:MapperFriendButton;
			
			_buttons = [];
			for (var i:int = 0; i < $friendVos.length; i++)
			{
				friendButton = new MapperFriendButton($friendVos[i], loadNextIcon);
				friendButton.x = 0;
				friendButton.y = i * (MapperFriendButton.HEIGHT + MapperFriendButton.MARGIN_V);
				
				_scrollArea.contentHolder.addChild(friendButton);
				_buttons.push(friendButton);
			}
			
			_scrollArea.updateAfterContentChange( $friendVos.length * (MapperFriendButton.HEIGHT + MapperFriendButton.MARGIN_V) );

			if ($teamFriendMap)
			{
				// update selectedness using map
				for each (var friendId:String in $teamFriendMap) 
				{
					if (friendId.length == 0) continue;
					
					var b:MapperFriendButton = getButtonById(friendId);
					if (! b) 
						Out.w("MapperFriendPanel.updateSelectedness() - NO MATCH FOR ID", friendId, "SHOULDN'T HAPPEN");
					else 
						b.isSelected = true;
				}
			}
		}
		
		public function enable():void
		{
			_scrollArea.contentHolder.mouseChildren = true;
			_scrollArea.contentHolder.alpha = 1;
		}
		public function disable():void
		{
			_scrollArea.contentHolder.mouseChildren = false;
			_scrollArea.contentHolder.alpha = 0.33;
		}

		public function startLoadingIcons():void
		{
			_loadCounter = 0;

			loadNextIcon();
			loadNextIcon(); 
			loadNextIcon(); // ie, 3 simultaneously
			
			// TODO: WHAT HAPPENS IF THIS IS CALLED A SECOND TIME WHILE OTHER IMAGES ARE STILL LOADING?
		}
		public function stopLoadingIcons():void
		{
			// ... 
		}
		
		
		public function getButtonById($id:String):MapperFriendButton 
		{
			for each (var fb:MapperFriendButton in _buttons) {
				if (fb.friendVo.id == $id) return fb;
			}
			return null;
		}

		private function loadNextIcon():void
		{
			if (_loadCounter >= _buttons.length) {
				// Out.i("FriendPickerDialog - done loading");
				return;
			}
			MapperFriendButton(_buttons[_loadCounter]).loadImage();
			_loadCounter += 1;
		}
	}
}