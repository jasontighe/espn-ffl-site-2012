package com.espn.ffl.views.report_card {
	import com.adobe.serialization.json.JSON;
	import com.espn.ffl.constants.SiteConstants;
	import com.espn.ffl.model.ConfigModel;
	import com.espn.ffl.model.ContentModel;
	import com.espn.ffl.model.LeagueModel;
	import com.espn.ffl.model.StateModel;
	import com.espn.ffl.model.dto.CopyDTO;
	import com.espn.ffl.util.Assets;
	import com.espn.ffl.util.FacebookHelper;
	import com.espn.ffl.util.Metrics;
	import com.espn.ffl.views.AbstractView;
	import com.espn.ffl.views.FflButton;
	import com.espn.ffl.views.Main;
	import com.espn.ffl.views.UnderlineButton;
	import com.espn.ffl.views.dialogs.AbstractDialog;
	import com.espn.ffl.views.dialogs.AlertDialogMaker;
	import com.espn.ffl.views.report_card.views.ReportRow;
	import com.espn.ffl.views.report_card.views.ReportTable;
	import com.espn.ffl.views.report_card.views.TalkBubble;
	import com.espn.ffl.views.report_card.views.TeamDetail;
	import com.espn.ffl.views.report_card.vos.TeamVo;
	import com.greensock.TweenLite;
	import com.jasontighe.managers.AssetManager;
	import com.jasontighe.navigations.Nav;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.TextEvent;
	import flash.filters.DropShadowFilter;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.utils.ByteArray;
	import flash.utils.setTimeout;
	
	import leelib.appropriated.JPEGEncoder;
	import leelib.util.Out;
	import leelib.util.TextFieldUtil;
	import leelib.util.Util;

	public class ReportCard extends AbstractView
	{
		public static const WIDTH:Number = 970;
		public static const HEIGHT:Number = 770;
		
		private var _fb:FacebookHelper = FacebookHelper.instance;
		private var _main:Main;
		private var _cm:ContentModel = ContentModel.gi;
		
		private var _isFullyInitialized:Boolean;
		private var _confirmationDialogStateIsDefault:Boolean;

		//

		private var _view1:Sprite;
		
			private var _plaque:Bitmap;
			private var _noDraftImage:Bitmap;
			private var _tfCopy1:TextField;
			private var _tfCopy2:TextField;
			private var _buttonGenerate:Sprite;
			private var _buttonDefault:UnderlineButton;
			private var _tfFinePrint:TextField;
		
			private var _table:ReportTable;
		
			private var _talkBubble:TalkBubble;
			
			private var _teamDetail:TeamDetail;
			
		private var _view2:Sprite;
			
			private var _tfShare:TextField;
			private var _image:Bitmap;
			private var _jpeg:ByteArray;
			private var _buttonSave:Sprite;
			private var _buttonShare:Sprite;
			private var _buttonBack:Sprite;
			
		
		public function ReportCard()
		{
			_main = Main.instance;

			// 'view1'
			
			_view1 = new Sprite();
			this.addChild(_view1);

				var bg:Bitmap = AssetManager.gi.getAsset( "reportCardBg", SiteConstants.LEE_ASSETS_ID);
				_view1.addChild(bg);
			
				var titling:Bitmap = new Assets.ReportCardTitling() as Bitmap;
				titling.x = 50;
				titling.y = 30;
				_view1.addChild(titling);
			
				_plaque = AssetManager.gi.getAsset( "reportCardPlaqueRedStars", SiteConstants.LEE_ASSETS_ID); 
				_plaque.x = 50;
				_plaque.y = 130;
				_view1.addChild(_plaque);
				
				_buttonGenerate = new FflButton(_cm.getCopyItemByName("rcButtonGenerate").copy, 242,31, 18, FflButton.BACKGROUNDTYPE_GREEN, true);
				_buttonGenerate.x = WIDTH - _buttonGenerate.width - 50;
				_buttonGenerate.y = 33;
				_buttonGenerate.addEventListener(Event.SELECT, onButtonGenerate);
				_view1.addChild(_buttonGenerate);
				
				_buttonDefault = new UnderlineButton(ContentModel.gi.getCopyItemByName("rcButtonDefault"), false, false); 
				_buttonDefault.x = 814;
				_buttonDefault.y = 155;
				_buttonDefault.addEventListener(MouseEvent.CLICK, onButtonReset);
				_buttonDefault.visible = false;
				_buttonDefault.alpha = 0;
				_view1.addChild(_buttonDefault);
				
				_tfCopy1 = TextFieldUtil.makeTextWithCopyDto(_cm.getCopyItemByName("rcView1Sub1"));
				_tfCopy1.x = WIDTH - _tfCopy1.width - 50;
				_tfCopy1.y = 82;
				_view1.addChild(_tfCopy1);
				
				_tfCopy2 = TextFieldUtil.makeTextWithCopyDto(_cm.getCopyItemByName("rcView1Sub2"));
				_tfCopy2.x = WIDTH - _tfCopy2.width - 50;
				_tfCopy2.y = 102;
				_view1.addChild(_tfCopy2);
				
				_tfCopy1.filters = _tfCopy2.filters = [ new DropShadowFilter(5,45,0x0,0.5,9,9,1,1) ];
				
				_table = new ReportTable();
				_table.x = 80;
				_table.y = 190;
				_view1.addChild(_table);
				
				_talkBubble = new TalkBubble();
				_talkBubble.x = 0;
				_talkBubble.y = 0;
				_view1.addChild(_talkBubble);
				
				_tfFinePrint = TextFieldUtil.makeTextWithCopyDto(_cm.getCopyItemByName("rcFinePrint"));
				_tfFinePrint.y = 721;
				_tfFinePrint.x = int(((ConfigModel.gi.stageW - 20) - _tfFinePrint.textWidth)/2 - 2);
				_view1.addChild(_tfFinePrint);
				
				_teamDetail = new TeamDetail();
				_teamDetail.visible = false;
				_teamDetail.alpha = 0;
				_view1.addChild(_teamDetail);

			// 'view2'
				
			_view2 = new Sprite();
			_view2.blendMode = BlendMode.LAYER;
			this.addChild(_view2);
			
				// note how view2 adds its own background and titling, for better crossfade
				bg = AssetManager.gi.getAsset( "reportCardBg", SiteConstants.LEE_ASSETS_ID);
				_view2.addChild(bg);
				
				titling = new Assets.ReportCardTitling() as Bitmap;
				titling.x = 50;
				titling.y = 30;
				_view2.addChild(titling);

				_image = new Bitmap();
				_image.x = 50;
				_image.y = 132;
				_view2.addChild(_image);
				
				_tfShare = TextFieldUtil.makeTextWithCopyDto( _cm.getCopyItemByName("rcPreviewYour") );
				_view2.addChild(_tfShare);
			
				_buttonShare = new FflButton(_cm.getCopyItemByName("rcButtonPost").copy, 95,31, 18, FflButton.BACKGROUNDTYPE_GREEN, true);
				_buttonShare.x = 822;
				_buttonShare.y = 90;
				_buttonShare.addEventListener(MouseEvent.CLICK, onButtonShare);
				_view2.addChild(_buttonShare);
			
				_buttonSave = new FflButton(_cm.getCopyItemByName("rcButtonDownload").copy, 192,31, 18, FflButton.BACKGROUNDTYPE_RED, true);
				_buttonSave.x = 613;
				_buttonSave.y = 90;
				_buttonSave.addEventListener(MouseEvent.CLICK, onButtonSave);
				_view2.addChild(_buttonSave);
				
				_buttonBack = new FflButton(_cm.getCopyItemByName("rcButtonBack").copy, 86,31, 18, FflButton.BACKGROUNDTYPE_GRAY, true);
				_buttonBack.x = 510;
				_buttonBack.y = 90;
				_buttonBack.addEventListener(MouseEvent.CLICK, onButtonBack);
				_view2.addChild(_buttonBack);
				
			this.addEventListener(ReportRow.EVENT_SHOWDETAIL, onShowTeamDetail);
			_teamDetail.addEventListener(TeamDetail.EVENT_HIDE, onHideTeamDetail);
			this.addEventListener(ReportRow.EVENT_GRADECHANGED, onGradeChanged);
		}

		public override function hide ( duration : Number = 0, delay : Number = 0 ) : void
		{
			super.hide(duration, delay);
		}

		public override function show ( duration : Number = 0, delay : Number = 0 ) : void
		{
			super.show(duration, delay);
			
			_view1.visible = true;

			TweenLite.killTweensOf(_view2);
			_view2.visible = false;
			_view2.alpha = 0;

			_table.mouseEnabled = _table.mouseChildren = true;
			
			if (LeagueModel.gi.numTeams < 4)
			{
				denyEntry();
				return;
			}

			if (! _isFullyInitialized) {
				loadStaticModelData();
			}
			else {
				// done
			}
			
			Metrics.pageView("reportCard");
		}
		
		private function denyEntry():void
		{
			if (! _noDraftImage) 
			{
				_noDraftImage = AssetManager.gi.getAsset( "reportCardSample", SiteConstants.LEE_ASSETS_ID);
				_noDraftImage.x = _plaque.x;
				_noDraftImage.y = _plaque.y;
				_view1.addChild(_noDraftImage);
			}
			var id:String = "alertReportCardNoDraft";
			Main.instance.showDialogWithCopyDtoId(true, id, onDenyEntryDialogButton,onDenyEntryDialogButton,onDenyEntryDialogButton );
			
			Metrics.pageView("reportCardNoDraftDialog");
		}
		private function onDenyEntryDialogButton():void
		{
			Main.instance.hideDialog();
			
			Metrics.pageView("reportCardNoDraftDialogBackButton");
			
			StateModel.gi.state = StateModel.STATE_TOUTS;
			Nav.instance.reset();
		}

		private function loadStaticModelData():void
		{
			var url:String = ConfigModel.gi.reportCardURL + "?" + int( Math.random() * 999999 ); // cache bustr
			var urlLoader:URLLoader = new URLLoader(new URLRequest(url));
			urlLoader.addEventListener(Event.COMPLETE, parseStaticModelData);
			urlLoader.addEventListener(IOErrorEvent.IO_ERROR, parseStaticModelData);
		}
		private function onStaticModelDataError(e:*):void
		{
			Out.e("ReportCard.parseStaticModelData() - IO ERROR");
			_main.hidePinwheel();
			_main.showDialogWithCopyDtoId(false, "alertConnectionError");
		}
		private function parseStaticModelData($e:Event):void
		{
			var s:String = $e.target.data;
			var o:Object;
			try {
				o = JSON.decode(s, false);
			}
			catch (e:Error) {
				Out.e("ReportCard.parseStaticModelData() - JSON PARSE ERROR");
				_main.hidePinwheel();
				_main.showDialogWithCopyDtoId(false, "alertConnectionError");
				return;
			}

			// [a] rank-to-points mapping
			ReportCardUtil.rankToPoints = o["rankToPoints"];
			Out.i("ReportCard.parseStaticModelData() - rankToPoints num elements:", ReportCardUtil.rankToPoints.length); 
			
			// [b] playerId-to-Berry rankings mapping 
			var cds:String = o["berryRankings"];
			ReportCardUtil.berryRankings = cds.split(",");
			Out.i("ReportCard.parseStaticModelData() - berryRankings num elements:", ReportCardUtil.berryRankings.length); 
			
			// [c] grade comments list
			ReportCardUtil.presetComments = o["gradeComments"];
			
			generateGradesAndUpdateView();
		}
		
		private function generateGradesAndUpdateView():void
		{
			ReportCardUtil.generateGrades();
			
			if (ConfigModel.gi.isPressPreview)
			{
				for (var i:int = 0; i < LeagueModel.gi.teamsByAlpha.length; i++) { // make team names generic
					var vo:TeamVo = LeagueModel.gi.teamsByAlpha[i];
					vo.teamLocation = "TEAM";
					vo.teamNickname = (i+1).toString();
				}
			}
			
			_isFullyInitialized = true;

			// update view...
			_table.update(true);
			
			setTimeout( _talkBubble.showAll, 500);
			
			setTimeout( _talkBubble.hideAfterShow, 5500);
		}
		
		private function onShowTeamDetail($e:Event):void
		{
			var rr:ReportRow = $e.target as ReportRow;
			var vo:TeamVo = rr.vo;
			
			for each (var r:ReportRow in _table.rows) {
				r.detailButton.showOff();
				r.detailButton.enable(); // meh
			}
			
			if (vo == _teamDetail.vo) 
			{
				onHideTeamDetail(null);
				return;
			}

			var rowCenterY:Number = Util.localToLocal(rr, this).y  +  ReportRow.HEIGHT * 0.5;
			
			var detailY:Number = rowCenterY - 79;
			var caretMiddleY:Number = 79;
			var overBy:Number = (detailY + TeamDetail.HEIGHT) - (HEIGHT - 10);
			if (overBy > 0) {
				detailY -= overBy;
				caretMiddleY += overBy;
			}
			
			_teamDetail.y = detailY;
			_teamDetail.caret.y = caretMiddleY - 20; // hardcoded
			
			_table.dimmerOn();
			_teamDetail.vo = vo;
			_teamDetail.x = 165;
			_teamDetail.show();
			
			rr.detailButton.disable();
			rr.detailButton.showOver(); // keep it on while the overlay is showing
			
			Metrics.pageView("reportCardTeamDetail");
		}

		private function onHideTeamDetail(e:*):void
		{
			_table.dimmerOff();
			
			_teamDetail.hide();
			_teamDetail.visible = false;
			
			
			for each (var row:ReportRow in _table.rows) {
				row.detailButton.showOff();
				row.detailButton.enable();
			}
		}

		private function onButtonReset(e:*):void
		{
			_table.resetToDefaults();
			
			_buttonDefault.hide();
			
			// grade header and fineprint show and hide together

			_talkBubble.showGradeHeader();
			
			TweenLite.killTweensOf(_tfFinePrint);
			TweenLite.to( _tfFinePrint, 0.33, { alpha:1 } );
			
			Metrics.pageView("reportCardDefaultButton");
		}

		private function onButtonGenerate(e:*):void
		{
			_main.showPinwheel();
			setTimeout(onButtonGenerate_2, 300); // allow time for pinwheel to show before jpeg encode locks ui
			
			Metrics.pageView("reportCardGenerateButton");
		}
		private function onButtonGenerate_2():void
		{
			var b:BitmapData = ReportCardUtil.makeImage();
			_image.bitmapData = b;
			var jpegEnc:JPEGEncoder = new JPEGEncoder(85);
			_jpeg = jpegEnc.encode(b);

			_main.hidePinwheel();
			
			setTimeout(onButtonGenerate_3, 200); // accounts for flash stutter!
		}
		private function onButtonGenerate_3():void
		{
			// show view2
			TweenLite.killTweensOf(_view2);
			TweenLite.to(_view2, 0.5, { autoAlpha:1.0 } );
		}
		
		// =========================================
		// SHARE SEQUENCE START (COMPLICATED)
		//
		private var _confirmationDialog:AbstractDialog;

		private function onButtonShare(e:*):void
		{
			if (ConfigModel.gi.isPressPreview) return;
			
			Metrics.pageView("reportCardShareButton");
			
			// if not logged in, log in. if login successful, show popoup
			if (! _fb.isFullyLoggedIn) {
				_fb.login( "no", showConfirmationDialog );
			}
			else {
				showConfirmationDialog();
			}
		}
		private function showConfirmationDialog():void
		{	
			var dto:CopyDTO = ContentModel.gi.getCopyItemByName("alertReportCardShare");
			_confirmationDialog = AlertDialogMaker.make(true, dto.title, dto.copy, dto.yesLabel, dto.noLabel, onConfirmationDialogYes,onConfirmationDialogNo,onConfirmationDialogClose, 550);
			_confirmationDialog.addEventListener(TextEvent.LINK, onConfirmationDialogLink, false,0,true);
			
			setConfirmationDialogState(_fb.getFriendIdsFromMap().length > 0);
			
			Main.instance.showDialog(_confirmationDialog);
			
			Metrics.pageView(_confirmationDialogStateIsDefault ? "reportCardShareDialog" : "reportCardNoFriendsDialog");
		}
		private function onConfirmationDialogYes():void
		{
			Main.instance.hideDialog();
			doTheShare();
			
			Metrics.pageView("reportCardShareDialogPublishButton");
		}
		private function onConfirmationDialogNo():void
		{
			_fb.doMapperDialog( onMapperDialogDone );

			Metrics.pageView(_confirmationDialogStateIsDefault ? "reportCardShareDialogSettingsButton" : "reportCardNoFriendsDialogSettingsButton");
		}
		private function onConfirmationDialogLink($e:TextEvent):void
		{
			Metrics.pageView("reportCardNoFriendsDialogSettingsLink");
			
			Out.i("onConfirmationDialogLink() - " + $e.text);
			_fb.doMapperDialog( onMapperDialogDone );
		}
		private function onConfirmationDialogClose():void
		{
			Main.instance.hideDialog();
			Metrics.pageView(_confirmationDialogStateIsDefault ? "reportCardShareDialogCloseButton" : "reportCardNoFriendsDialogCloseButton");
		}
		private function onMapperDialogDone():void
		{
			setConfirmationDialogState( _fb.getFriendIdsFromMap().length > 0 );
		}
		private function doTheShare():void
		{
			_fb.doReportCardShare(_jpeg);
		}
		
		private function setConfirmationDialogState($hasSelectedFriends:Boolean):void
		{
			_confirmationDialogStateIsDefault = $hasSelectedFriends;
			
			if ($hasSelectedFriends)
			{
				var dto:CopyDTO = ContentModel.gi.getCopyItemByName("alertReportCardShare");
				_confirmationDialog.tfCopy.htmlText = dto.copy;
				TextFieldUtil.applyAndMakeDefaultStyle(_confirmationDialog.tfCopy, ".alertDialogCopy");
				_confirmationDialog.yesButton.alpha = 1;
				_confirmationDialog.yesButton.mouseEnabled = _confirmationDialog.yesButton.mouseChildren = true;
				_confirmationDialog.redBackgroundVisible = false;
			}
			else
			{
				_confirmationDialog.tfCopy.htmlText = ContentModel.gi.getCopyItemByName("alertReportCardShareNoFriends").copy;
				TextFieldUtil.applyAndMakeDefaultStyle(_confirmationDialog.tfCopy, ".alertDialogCopyRed");
				_confirmationDialog.yesButton.alpha = 0.5;
				_confirmationDialog.yesButton.mouseEnabled = _confirmationDialog.yesButton.mouseChildren = false;
				_confirmationDialog.redBackgroundVisible = true;
			}
		}
		
		//
		// =========================================


		private function onButtonSave(e:*):void
		{
			ReportCardUtil.saveFileToLocal(_jpeg, "Draft Report Card.jpg");
			
			Metrics.pageView("reportCardDownloadButton");			
		}
		
		private function onButtonBack(e:*):void
		{
			// hide view 2
			TweenLite.killTweensOf(_view2);
			TweenLite.to(_view2, 0.25, { alpha:0, onComplete:function():void{_view2.visible=false;} } );
			
			Metrics.pageView("reportCardBackButton");
		}
		
		private function onGradeChanged(e:*):void
		{
			if (_buttonDefault.alpha < 1) 
			{
				_buttonDefault.show();
			
				// grade header and fineprint show and hide together
				
				_talkBubble.hideGradeHeader();
				
				TweenLite.killTweensOf(_tfFinePrint);
				TweenLite.to( _tfFinePrint, 0.33, { alpha:0 } );
			}
		}
	}
}
