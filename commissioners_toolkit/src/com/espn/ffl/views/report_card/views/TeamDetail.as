package com.espn.ffl.views.report_card.views
{
	import com.espn.ffl.constants.SiteConstants;
	import com.espn.ffl.model.ContentModel;
	import com.espn.ffl.util.Assets;
	import com.espn.ffl.views.report_card.vos.PlayerVo;
	import com.espn.ffl.views.report_card.vos.TeamVo;
	import com.greensock.TweenLite;
	import com.jasontighe.managers.AssetManager;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	import leelib.graphics.GrUtil;
	import leelib.ui.ScrollArea;
	import leelib.util.TextFieldUtil;
	
	public class TeamDetail extends Sprite
	{
		public static const EVENT_HIDE:String = "TeamDetail.eventHide";
		
		public static const WIDTH:Number = 393;
		public static const HEIGHT:Number = 356;
		
		public static const _contentAreaWidth:Number = 338;
		public static var _contentAreaHeight:Number;
		
		private var _bg:Bitmap;
		private var _caret:Bitmap;
		private var _tfTitle:TextField;
		private var _tfName:TextField;
		private var _closeButton:Sprite;
		private var _header:Sprite;
		private var _scrollArea:FflScrollArea;
			private var _rowPool:Array;
		
		private var _vo:TeamVo;

		
		public function TeamDetail()
		{
			_bg = AssetManager.gi.getAsset( "reportCardDetailBg", SiteConstants.LEE_ASSETS_ID); // new Assets.ReportCardTeamDetailBg()
			_bg.x = 0;
			_bg.y = -16;
			this.addChild(_bg);
			
			_caret = new Assets.ReportCardDetailCaret as Bitmap;
			_caret.x = -_caret.width + 6; 
			this.addChild(_caret);
			
			_tfTitle = TextFieldUtil.makeTextWithCopyDto(ContentModel.gi.getCopyItemByName("rcDetailTitle"));
			this.addChild(_tfTitle);

			_tfName = TextFieldUtil.makeText(" ", ".reportCardTeamDetailName");
			_tfName.x = 28;
			_tfName.y = 48;
			this.addChild(_tfName);
			
			_closeButton = new Sprite();
			_closeButton.graphics.beginFill(0xff0000, 0.0);
			_closeButton.graphics.drawCircle(0,0, 16);
			_closeButton.graphics.endFill();
			_closeButton.x = WIDTH - 2;
			_closeButton.y = 3;
			_closeButton.buttonMode = true;
			_closeButton.addEventListener(MouseEvent.CLICK, onCloseButton);
			this.addChild(_closeButton);
			
			addHeader();

			var y:Number = _header.y + _header.height + 3;
			_contentAreaHeight = HEIGHT - y - 26;
			
			_scrollArea = new FflScrollArea(_contentAreaWidth, _contentAreaHeight, false);
			_scrollArea.x = 19;
			_scrollArea.y = y;
			this.addChild(_scrollArea);

			_rowPool = [];
			for (var i:int = 0; i < 99; i++)
			{
				var row:TeamDetailRow = new TeamDetailRow();
				row.x = 0;
				row.y = TeamDetailRow.HEIGHT * i;
				_scrollArea.contentHolder.addChild(row);
				_rowPool.push(row);
			}
		}
		
		public function get caret():Bitmap
		{
			return _caret;
		}
		
		private function addHeader():void
		{
			_header = GrUtil.makeRect(_contentAreaWidth, 25, 0xe3e3e3);
			_header.x = 18;
			_header.y = 77;
			this.addChild(_header);
			
			var tf:TextField;
			
			tf = TextFieldUtil.makeTextWithCopyDto(ContentModel.gi.getCopyItemByName("rcDetailPick"));
			_header.addChild(tf);
			
			tf = TextFieldUtil.makeTextWithCopyDto(ContentModel.gi.getCopyItemByName("rcDetailPlayer"));
			_header.addChild(tf);
			
			tf = TextFieldUtil.makeTextWithCopyDto(ContentModel.gi.getCopyItemByName("rcDetailPos"));
			tf.x = 240;
			tf.y = 4;
			_header.addChild(tf);
			
			tf = TextFieldUtil.makeTextWithCopyDto(ContentModel.gi.getCopyItemByName("rcDetailTeam"));
			tf.x = 288;
			tf.y = 4;
			_header.addChild(tf);
		}
		
		public function show():void
		{
			TweenLite.killTweensOf(this);
			TweenLite.to(this, 0.25, { autoAlpha:1 } );
		}

		public function hide():void
		{
			_vo = null;
			
			TweenLite.killTweensOf(this);
			
			// FYI, YOU CAN DO THIS: var _this = this;
			
			TweenLite.to(this, 0.25, { alpha:0, onComplete:function():void{visible=false;} } );
		}
		
		public function get vo():TeamVo
		{
			return _vo;
		}
		
		public function set vo($vo:TeamVo):void
		{
			_vo = $vo;
			
			_tfName.text = $vo.fullTeamName.toUpperCase();
			
			var orderedPlayers:Array = [];
			for each (var pvo:PlayerVo in _vo.playersById) {
				orderedPlayers.push(pvo);
			}
			orderedPlayers.sortOn("draftNumber", Array.NUMERIC);

			var index:int;
			for (index = 0; index < orderedPlayers.length; index++)
			{
				var r:TeamDetailRow = _rowPool[index];
				r.vo = orderedPlayers[index];
				r.visible = true;
				r.strokeVisible = (index < orderedPlayers.length-1);
			}
			
			// hide rest
			for (var i:int = index; i < _rowPool.length; i++)
			{
				_rowPool[i].visible = false;
			}
			
			_scrollArea.updateAfterContentChange(index * TeamDetailRow.HEIGHT);
		}
		
		private function onCloseButton(e:*):void
		{
			this.dispatchEvent(new Event(EVENT_HIDE));
		}
	}
}
