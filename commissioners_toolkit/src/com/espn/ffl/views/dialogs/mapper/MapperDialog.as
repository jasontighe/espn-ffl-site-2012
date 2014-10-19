package com.espn.ffl.views.dialogs.mapper
{
	import com.espn.ffl.model.ContentModel;
	import com.espn.ffl.model.LeagueModel;
	import com.espn.ffl.util.Assets;
	import com.espn.ffl.util.FacebookHelper;
	import com.espn.ffl.views.AbstractView;
	import com.espn.ffl.views.BubbleButton;
	import com.espn.ffl.views.FflButton;
	import com.espn.ffl.views.Main;
	import com.espn.ffl.views.dialogs.AbstractDialog;
	import com.espn.ffl.views.dialogs.AlertDialogMaker;
	import com.espn.ffl.views.report_card.views.FflScrollArea;
	import com.espn.ffl.views.report_card.vos.TeamVo;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	
	import leelib.facebook.FbFriendVo;
	import leelib.facebook.FbResultEvent;
	import leelib.facebook.FbUtilWeb;
	import leelib.graphics.GrUtil;
	import leelib.graphics.Scale9BitmapSprite;
	import leelib.ui.ScrollArea;
	import leelib.ui.ThreeStateButton;
	import leelib.util.Out;
	import leelib.util.TextFieldUtil;


	public class MapperDialog extends AbstractDialog
	{
		public static const RESULT_OK:String = "ok";
		public static const RESULT_CANCEL:String = "cancel";
		
		public static const WIDTH:Number = 705;
		public static const HEIGHT:Number = 690;
		
		private var _chrome:Scale9BitmapSprite;

		private var _tfTitle:TextField;
		private var _tfCopy:TextField;
		
		private var _tfTeamsHeading:TextField;
		private var _tfFriendsHeading:TextField;

		private var _teamPanel:MapperTeamPanel;
		private var _friendPanel:MapperFriendPanel;

		private var _tfNoDraft:TextField;
		
		private var _closeButton:Sprite;
		private var _okButton:ThreeStateButton;
		
		
		public function MapperDialog()
		{
			this.dialogWidth = WIDTH;
			this.dialogHeight = HEIGHT;
			
			var b:BitmapData = new Assets.DialogBgWithX().bitmapData;
			_chrome = new Scale9BitmapSprite(b, new Rectangle(20,40,b.width-42-20,b.height-35-40));
			_chrome.width = WIDTH + 26;
			_chrome.height = HEIGHT + 12; // extra amounts are for dropshadow
			this.addChild(_chrome);
			
			_tfTitle = TextFieldUtil.makeText(ContentModel.gi.getCopyItemByName("dialogMapperTitle").copy, ".dialogMapperTitle");
			_tfTitle.x = 35;
			_tfTitle.y = 34;
			this.addChild(_tfTitle);

			_tfCopy = TextFieldUtil.makeHtmlText(ContentModel.gi.getCopyItemByName("dialogMapperCopy").copy, ".dialogMapperCopy", WIDTH-35-35);
			_tfCopy.x = 35;
			_tfCopy.y = 76;
			this.addChild(_tfCopy);
			
			_tfTeamsHeading = TextFieldUtil.makeText(ContentModel.gi.getCopyItemByName("dialogMapperTeamsHeading").copy, ".dialogMapperHeading");
			_tfTeamsHeading.x = 35;
			_tfTeamsHeading.y = 157;
			this.addChild(_tfTeamsHeading);

			_tfFriendsHeading = TextFieldUtil.makeText(ContentModel.gi.getCopyItemByName("dialogMapperFriendsHeading").copy, ".dialogMapperHeading");
			_tfFriendsHeading.x = 352;
			_tfFriendsHeading.y = 157;
			this.addChild(_tfFriendsHeading);

			// draw border rect + divider line
			var shape:Shape = new Shape();
			shape.x = 35;
			shape.y = 184;
			shape.graphics.lineStyle(1, 0x0);
			shape.graphics.beginFill(0xffffff);
			shape.graphics.drawRect(0,0, 645,380);
			shape.graphics.endFill();
			shape.graphics.moveTo(MapperTeamButton.WIDTH-1, 0);
			shape.graphics.lineTo(MapperTeamButton.WIDTH-1, 380);
			this.addChild(shape);

			_teamPanel = new MapperTeamPanel();
			_teamPanel.x = 35;
			_teamPanel.y = 184;
			this.addChild(_teamPanel);
			
			_friendPanel = new MapperFriendPanel(277, 321);
			_friendPanel.x = 368;
			_friendPanel.y = 213;
			this.addChild(_friendPanel);
			
			_tfNoDraft = TextFieldUtil.makeHtmlText(ContentModel.gi.getCopyItemByName("dialogMapperNoDraft").copy, ".dialogMapperNoDraft", 280);
			_tfNoDraft.x = 50;
			_tfNoDraft.y = 340;
			_tfNoDraft.visible = false;
			this.addChild(_tfNoDraft);
			
			_closeButton = GrUtil.makeCircle(15, 0xff0000, 0.0);
			_closeButton.x = _chrome.width - 29; // hardcoded placement
			_closeButton.y = 15;
			_closeButton.buttonMode = true;
			this.addChild(_closeButton);
			
			_okButton = new BubbleButton("SAVE", 128);
			_okButton.x = 550;
			_okButton.y = 603;
			this.addChild(_okButton);
			
			this.alpha = 0;
			
			this.assignButtons(_okButton, null, _closeButton);
		}

		public function initializeBeforeShow($teamVos:Array, $friendVos:Array, $teamFriendMap:Object):void
		{
			// make team buttons
			_teamPanel.initialize($teamVos, $teamFriendMap);
			
			// make friend buttons
			_friendPanel.initialize($friendVos, $teamFriendMap);

			// ORIGINAL
			// if ($teamVos && $teamVos.length > 0)

			if (LeagueModel.gi.teamsByAlpha && LeagueModel.gi.teamsByAlpha.length > 0)
			{
				_tfNoDraft.visible = false;
			}
			else 
			{
				_tfNoDraft.visible = true;
			}
		}
		
		public override function show(duration:Number = 0, delay:Number = 0):void
		{
			super.show(duration,delay);
			
			_teamPanel.addEventListener(Event.SELECT, onTeamButtonSelect);
			_teamPanel.addEventListener(Event.CLEAR, onTeamButtonClear);
			_friendPanel.addEventListener(Event.SELECT, onFriendButtonSelect);
			
			_friendPanel.startLoadingIcons();

			selectTeamButton(null);
		}
		
		public override function hide(duration:Number=0, delay:Number=0):void
		{
			super.hide(duration,delay);
			clearListeners();
			_friendPanel.stopLoadingIcons();
		}
		
		public function kill():void
		{
			clearListeners();
		}
		
		public function makeTeamFriendMapFromCurrentState():Object
		{
			return _teamPanel.makeTeamFriendMapFromCurrentState();
		}
		
		private function clearListeners():void
		{
			_teamPanel.removeEventListener(Event.SELECT, onTeamButtonSelect);
			_teamPanel.removeEventListener(Event.CLEAR, onTeamButtonClear);
			_friendPanel.removeEventListener(Event.SELECT, onFriendButtonSelect);
		}
		
		private function onFriendButtonSelect($e:Event):void
		{
			// turn friend button on
			var friendButton:MapperFriendButton = $e.target as MapperFriendButton;
			friendButton.isSelected = true;
			
			// unselect teambutton's old friend
			if (_teamPanel.selectedButton && _teamPanel.selectedButton.friendVo) {
				var oldFriendId:String = _teamPanel.selectedButton.friendVo.id;
				var oldFriendButton:MapperFriendButton = _friendPanel.getButtonById(oldFriendId);
				if (oldFriendButton) oldFriendButton.isSelected = false;
			}

			// set friend on team button
			_teamPanel.selectedButton.friendVo = friendButton.friendVo;
			
			// select next button on teampanel
			selectTeamButton( _teamPanel.getNextOpenButton() );
		}
		
		private function onTeamButtonSelect($e:Event):void
		{
			selectTeamButton( $e.target as MapperTeamButton );
		}
		
		private function onTeamButtonClear($e:Event):void
		{
			var tb:MapperTeamButton = $e.target as MapperTeamButton;
			
			// clear teambutton's friend
			var wasFriend:FbFriendVo = tb.friendVo;
			tb.friendVo = null;
			
			_friendPanel.getButtonById(wasFriend.id).isSelected = false;
		}
		
		private function selectTeamButton($b:MapperTeamButton):void
		{
			_teamPanel.selectedButton = $b;
			
			if (_teamPanel.selectedButton)
				_friendPanel.enable();
			else
				_friendPanel.disable();
		}
	}
}
