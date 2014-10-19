package com.espn.ffl.views.report_card.views
{
	import com.espn.ffl.model.ContentModel;
	import com.espn.ffl.util.Assets;
	import com.espn.ffl.util.Metrics;
	import com.espn.ffl.views.report_card.ReportCardUtil;
	import com.espn.ffl.views.report_card.vos.TeamVo;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	import leelib.ui.Dropdown;
	import leelib.util.TextFieldUtil;
	
	public class ReportRow extends Sprite
	{
		public static const EVENT_SHOWDETAIL:String = "rr.eventShowDetail";
		public static const EVENT_GRADECHANGED:String = "rr.eventGradeChanged";
		public static const WIDTH:Number = 792;
		public static const HEIGHT:Number = 38+1;
		
		private var _detailButton:HelmetButton;
		private var _tfTeamName:TextField;
		private var _gradeDropdown:Dropdown;
		private var _commentDropdown:Dropdown;

		private var _vo:TeamVo;
		
		private var _gradeToDefaultIndex:Array;
		
		
		public function ReportRow($vo:TeamVo)
		{
			_vo = $vo;
			
			// too complicated and too late at night to document what this is doing
			_gradeToDefaultIndex = [];
			_gradeToDefaultIndex['A+'] = 0;
			_gradeToDefaultIndex['A'] = 1;
			_gradeToDefaultIndex['A-'] = 2;
			_gradeToDefaultIndex['B+'] = 0;
			_gradeToDefaultIndex['B'] = 1;
			_gradeToDefaultIndex['B-'] = 2;
			_gradeToDefaultIndex['C+'] = 0;
			_gradeToDefaultIndex['C'] = 1;
			_gradeToDefaultIndex['C-'] = 2;
			_gradeToDefaultIndex['D'] = 0;
			_gradeToDefaultIndex['F'] = 0;
			
			_detailButton = new HelmetButton();
			_detailButton.x = 0;
			_detailButton.y = 0;
			_detailButton.buttonMode = true;
			_detailButton.addEventListener(MouseEvent.CLICK, onDetailButton);
			this.addChild(_detailButton);
			
			var b:Bitmap = new Assets.ReportCardRowTeamCellBg() as Bitmap;
			b.x = _detailButton.width + 1;
			b.y = 0;
			this.addChild(b);
			
			_tfTeamName = TextFieldUtil.makeText(" ", ".reportCardTableTeam", 182);
			_tfTeamName.x = _detailButton.x + _detailButton.width + 8;
			_tfTeamName.y = 10;
			this.addChild(_tfTeamName);
			
			_gradeDropdown = new ReportCardDropdown(GradeDropdownItem, false, true, true);
			_gradeDropdown.dropdownData = GradeDropdownItem.LEGAL_VALUES;
			_gradeDropdown.x = b.x + b.width + 1;
			_gradeDropdown.y = 0;
			_gradeDropdown.addEventListener(Event.CHANGE, onGradeChanged);
			
			_commentDropdown = new ReportCardDropdown(CommentDropdownItem, true, true, false);
			_commentDropdown.x = _gradeDropdown.x + _gradeDropdown.itemPlusCaretWidth + 1;
			_commentDropdown.y = 0;
			_commentDropdown.addEventListener(Event.CHANGE, onCommentChanged);

			this.addChild(_commentDropdown);
			this.addChild(_gradeDropdown); // on top so dropshadow shows over commentdropdown
			
			update();
		}
		
		public function get vo():TeamVo
		{
			return _vo;
		}
		public function set vo($vo:TeamVo):void
		{
			_vo = $vo;
			
			update(); 
		}
		
		public function showFakeLoading1():void
		{
			_gradeDropdown.mainItem.text = "";
			_commentDropdown.mainItem.text = "";
		}
		public function showFakeLoading2():void
		{
			_gradeDropdown.mainItem.text = ContentModel.gi.getCopyItemByName("rcGradeLoadingPrompt").copy;
			_commentDropdown.mainItem.text = ContentModel.gi.getCopyItemByName("rcCommentLoadingPrompt").copy;
		}
		public function hideFakeLoading():void
		{
			_gradeDropdown.mainItem.value = _gradeDropdown.mainItem.value; 
			_commentDropdown.mainItem.value = _commentDropdown.mainItem.value;
		}
		
		public function get detailButton():HelmetButton
		{
			return _detailButton;
		}
		
		public function get commentDropdown():Dropdown
		{
			return _commentDropdown;
		}

		public function get gradeDropdown():Dropdown
		{
			return _gradeDropdown;
		}
		
		private function update():void
		{
			_tfTeamName.text = _vo.fullTeamName ? _vo.fullTeamName.toUpperCase() : " ";
			TextFieldUtil.ellipsize(_tfTeamName, _tfTeamName.width);

			_gradeDropdown.value = _vo.userGrade;
			
			_commentDropdown.dropdownData = ReportCardUtil.presetComments[ _vo.userGrade ];
			_commentDropdown.value = _vo.userComment;
		}

		public function kill():void
		{
			_detailButton.removeEventListener(MouseEvent.CLICK, onDetailButton);
			_gradeDropdown.kill();
			_commentDropdown.kill();
		}

		private function onDetailButton(e:*):void
		{
			this.dispatchEvent(new Event(EVENT_SHOWDETAIL, true));
		}
		
		private function onGradeChanged(e:*):void
		{
			if (_gradeDropdown.value == _vo.userGrade) return;
			
			_vo.userGrade = _gradeDropdown.value as String;
			
			// also update comment items based on selected letter-grade
			_commentDropdown.dropdownData = ReportCardUtil.presetComments[_vo.userGrade];
			
			// and update comment value to the mapped default comment for that grade
			// no: var index:int = _gradeToDefaultIndex[_vo.userGrade];
			_commentDropdown.value = _vo.userComment = _commentDropdown.dropdownData[0]; 
			
			this.dispatchEvent(new Event(EVENT_GRADECHANGED, true)); 
			// ... handled by ReportCard, to toggle visibility of 'set back to defaults'
		}
		
		private function onCommentChanged(e:*):void
		{
			_vo.userComment = _commentDropdown.value as String;
		}
	}
}
