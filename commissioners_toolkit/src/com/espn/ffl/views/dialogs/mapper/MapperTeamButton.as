package com.espn.ffl.views.dialogs.mapper
{
	import com.espn.ffl.util.Assets;
	import com.espn.ffl.views.report_card.vos.TeamVo;
	import com.greensock.TweenLite;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLRequest;
	import flash.system.LoaderContext;
	import flash.text.TextField;
	
	import leelib.facebook.FbFriendVo;
	import leelib.graphics.GrUtil;
	import leelib.ui.ThreeStateButton;
	import leelib.util.Out;
	import leelib.util.TextFieldUtil;
	
	
	public class MapperTeamButton extends ThreeStateButton
	{
		public static const WIDTH:Number = 317;
		public static const HEIGHT:Number = 32;
		
		private var _over:Sprite;
		private var _on:Bitmap;

		private var _tfTeam:TextField;
		private var _friendBg:Bitmap; 
		private var _tfFriend:TextField;
		private var _friendX:Sprite;
		
		private var _teamVo:TeamVo;
		private var _friendVo:FbFriendVo;		
		
		
		public function MapperTeamButton($teamVo:TeamVo)
		{
			_teamVo = $teamVo;
			
			this.selectEventBubbles = true;
			
			this.graphics.beginFill(0xffffff);
			this.graphics.drawRect(0,0,WIDTH,HEIGHT);
			this.graphics.endFill();
			
			this.graphics.lineStyle(1, 0x0);
			this.graphics.drawRect(0,0,WIDTH-1,HEIGHT-1);
			
			// over - fully inside outline
			_over = GrUtil.makeRect(WIDTH-2,HEIGHT-2, 0xe5e5e5);
			_over.x = 1;
			_over.y = 1;
			this.addChild(_over);
			
			// on - overlaps just right side of outline
			_on = new Assets.GradientGreen();
			_on.width = WIDTH-1;
			_on.height = HEIGHT-2;
			_on.x = 1;
			_on.y = 1;
			this.addChild(_on);
			
			_tfTeam = TextFieldUtil.makeText(_teamVo.fullTeamName, ".dialogMapperTeamButton", 112+5);
			_tfTeam.x = 18;
			_tfTeam.y = 8;
			this.addChild(_tfTeam);

			TextFieldUtil.ellipsize(_tfTeam, _tfTeam.width-5);
			
			_friendBg = new Assets.MapperTeamInputBg();
			_friendBg.x = 136;
			_friendBg.y = 6;
			this.addChild(_friendBg);
			
			_tfFriend = TextFieldUtil.makeText(" ", ".dialogMapperTeamButton", 145);
			_tfFriend.x = 140;
			_tfFriend.y = 8;
			this.addChild(_tfFriend);
			
			_friendX = new Sprite();
			this.addChild(_friendX);
			_friendX.addChild( new Assets.MapperTeamInputX() );
			_friendX.x = 288;
			_friendX.y = 8;
			
			_friendX.addEventListener(MouseEvent.ROLL_OVER, onXOver);
			_friendX.addEventListener(MouseEvent.ROLL_OUT, onXOut);
			_friendX.addEventListener(MouseEvent.CLICK, onXClick, false, 10); // higher priority than general button-click
			_friendX.buttonMode = true;
						
			super();
			
			friendVo = null;
		}

		public function get teamVo():TeamVo
		{
			return _teamVo;
		}
		
		public function get friendVo():FbFriendVo
		{
			return _friendVo;
		}

		public function set friendVo($vo:FbFriendVo):void
		{
			_friendVo = $vo;
			
			if (_friendVo) {
				_tfFriend.text = _friendVo.name;
				TextFieldUtil.ellipsize(_tfFriend, _tfFriend.width-5);
				_friendX.visible = true;
			}
			else {
				_tfFriend.text = "";
				_friendX.visible = false;
			}
		}
		
		public override function kill():void
		{
			_tfFriend = null;
			_friendVo = null;
			
			super.kill();
		}
		
		public function get vo():FbFriendVo
		{
			return _friendVo;
		}
		
		protected override function showUnselectedOut():void
		{
			_over.visible = false;
			_on.visible = false;
		}
		
		protected override function showUnselectedOver():void
		{
			_over.visible = true;
			_on.visible = false;
		}
		
		protected override function showSelected():void
		{
			_on.alpha = 0;
			TweenLite.to(_on, 0.5, { autoAlpha:1 } );
			_over.visible = false;
		}
		
		private function onXOver(e:*):void
		{
			_friendX.alpha = 0.5;
		}
		private function onXOut(e:*):void
		{
			_friendX.alpha = 1.0;
		}
		private function onXClick($e:Event):void
		{
			// let click event also select the button...
			// $e.stopImmediatePropagation(); // stop this's button-click action from occurring
			
			this.dispatchEvent(new Event(Event.CLEAR, true));
		}
			
	}
}
