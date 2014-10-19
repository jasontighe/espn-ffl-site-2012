package com.espn.ffl.views.report_card.views
{
	import com.espn.ffl.views.report_card.vos.PlayerVo;
	
	import flash.display.Sprite;
	import flash.text.TextField;
	
	import leelib.graphics.DashedLine;
	import leelib.util.TextFieldUtil;
	
	public class TeamDetailRow extends Sprite
	{
		public static const HEIGHT:Number = 25;
		public static const WIDTH:Number = 338;
		
		private var _tfPick:TextField;
		private var _tfPlayer:TextField;
		private var _tfPosition:TextField;
		private var _tfProTeam:TextField;
		private var _dashedLine:DashedLine;
		
		private var _vo:PlayerVo;
		
		
		public function TeamDetailRow()
		{
			var y:Number = 3;
			
			_tfPick = TextFieldUtil.makeText(" ", ".reportCardTeamDetailTextCentered", 33);
			_tfPick.x = 10;
			_tfPick.y = y;
			this.addChild(_tfPick);

			_tfPlayer = TextFieldUtil.makeText(" ", ".reportCardTeamDetailText");
			_tfPlayer.x = 70;
			_tfPlayer.y = y;
			this.addChild(_tfPlayer);
			
			_tfPosition = TextFieldUtil.makeText(" ", ".reportCardTeamDetailTextCentered", 52);
			_tfPosition.x = 228;
			_tfPosition.y = y;
			this.addChild(_tfPosition);
			
			_tfProTeam = TextFieldUtil.makeText(" ", ".reportCardTeamDetailTextCentered", 65);
			_tfProTeam.x = 275;
			_tfProTeam.y = y;
			this.addChild(_tfProTeam);
			
			_dashedLine = new DashedLine(1, 0xbababa, [9,1]);
			_dashedLine.moveTo(0, 0);
			_dashedLine.lineTo(338, 0);
			_dashedLine.x = 0;
			_dashedLine.y = HEIGHT;
			this.addChild(_dashedLine);
		}
		
		public function get vo():PlayerVo
		{
			return _vo;
		}
		
		public function set vo($vo:PlayerVo):void
		{
			_vo = $vo;
			
			if (! _vo) {
				_tfPick.text = "";
				_tfPlayer.text = "";
				_tfPosition.text = "";
				_tfProTeam.text = "";
				return;
			}
			
			_tfPick.text = $vo.draftNumber.toString();
			_tfPlayer.text = $vo.name;
			_tfPosition.text = $vo.primaryPosition;
			_tfProTeam.text = $vo.proTeam.toUpperCase();
		}
		
		public function set strokeVisible($b:Boolean):void
		{
			_dashedLine.visible = $b;
		}
	}
}