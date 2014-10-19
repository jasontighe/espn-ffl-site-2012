package com.espn.ffl.views.dialogs.mapper
{
	import com.espn.ffl.util.FacebookHelper;
	
	import flash.display.Sprite;
	import flash.events.Event;
	
	import leelib.facebook.FbFriendVo;
	import leelib.util.Out;
	
	
	public class MapperTeamPanel extends Sprite
	{
		private var _buttons:Array;
		
		private var _selectedButton:MapperTeamButton;
		
		
		public function MapperTeamPanel()
		{
			super();
		}
		
		public function initialize($teamVos:Array, $teamFriendMap:Object):void
		{
			// clear first
			while (this.numChildren > 0) { 
				teamButton = this.removeChildAt(0) as MapperTeamButton;
				teamButton.kill();
			}
			
			// make buttons
			var teamButton:MapperTeamButton;
			
			_buttons = [];
			for (var i:int = 0; i < $teamVos.length; i++)
			{
				teamButton = new MapperTeamButton($teamVos[i]);
				teamButton.x = 0;
				teamButton.y = i * (MapperTeamButton.HEIGHT - 1); // "-1" b/c overlaps each other by 1px
				
				this.addChild(teamButton);
				_buttons.push(teamButton);
			}

			// set friends on buttons with map
			for each (var button:MapperTeamButton in _buttons) 
			{
				var fbId:String = $teamFriendMap[button.teamVo.id];
				if (fbId) 
				{
					var friendVo:FbFriendVo = FacebookHelper.instance.user.getFriendById(fbId);
					if (friendVo) 
						button.friendVo = friendVo;
					else
						Out.w("MapperTeamButtonPanel.setTeamFriendMap - No match for friend id");
				}
			}
		}
		
		public function kill():void
		{
			for each (var b:MapperTeamButton in _buttons) {
				b.kill();
			}
		}
		
		public function get selectedButton():MapperTeamButton
		{
			return _selectedButton;
		}
		
		public function set selectedButton($button:MapperTeamButton):void
		{
			_selectedButton = $button;
			
			for each (var b:MapperTeamButton in _buttons) {
				b.isSelected = (b == _selectedButton);
			}
		}

		public function getNextOpenButton():MapperTeamButton
		{
			var startIndex:int = _selectedButton ? _buttons.indexOf(_selectedButton) : -1;
			
			var index:int = startIndex;
			do
			{
				index++;
				if (index >= _buttons.length) index = 0;
				var b:MapperTeamButton = _buttons[index];
				if (! b.friendVo) return b;
			}
			while (index != startIndex) 
			
			return null;
		}
		
		public function makeTeamFriendMapFromCurrentState():Object
		{
			trace('makeTeamFriendMapFromCurrentState...')
			
			var map:Object = {};
			for each (var teamButton:MapperTeamButton in _buttons)
			{
				var teamId:String = teamButton.teamVo.id;
				var friendId:String = teamButton.friendVo ? teamButton.friendVo.id : "";
				map[teamId] = friendId;
				
				trace('teampanel - teamId', teamId, 'friendId', friendId);
			}
			return map;
		}
	}
}
