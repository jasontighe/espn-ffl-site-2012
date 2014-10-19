package com.espn.ffl.views.report_card.views
{
	import com.espn.ffl.constants.SiteConstants;
	import com.espn.ffl.model.ContentModel;
	import com.espn.ffl.model.LeagueModel;
	import com.espn.ffl.util.Assets;
	import com.espn.ffl.views.report_card.ReportCard;
	import com.espn.ffl.views.report_card.ReportCardUtil;
	import com.espn.ffl.views.report_card.vos.TeamVo;
	import com.greensock.TweenLite;
	import com.greensock.easing.Cubic;
	import com.greensock.easing.Quad;
	import com.jasontighe.managers.AssetManager;
	
	import flash.display.Bitmap;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import flash.utils.Dictionary;
	import flash.utils.setTimeout;
	
	import leelib.graphics.GrUtil;
	import leelib.ui.Dropdown;
	import leelib.util.TextFieldUtil;
	
	
	public class ReportTable extends Sprite
	{
		public static const EVENT_SHOWDEFAULTBUTTON:String = "rt.eventShowDefaultButton";
		public static const EVENT_SHOWBERRYLABEL:String = "rt.eventShowBerryLabel";
		
		private static var _instance:ReportTable;

		private var _cm:ContentModel = ContentModel.gi;
		private var _lm:LeagueModel = LeagueModel.gi;

		private var _bg:Bitmap;
		
		private var _header:Sprite;
		private var _rowsHolder:Sprite;
			private var _rows:Array;
		private var _dimmer:Sprite;

		private var _areGradesDefault:Boolean;
		
		private var _isEditingComment:Boolean;
		
		private var _tooltip:Sprite;


		public function ReportTable()
		{
			_instance = this;
			
			_bg = AssetManager.gi.getAsset( "reportCardPlaqueMatte", SiteConstants.LEE_ASSETS_ID); // new Assets.ReportCardPlaqueMatte();
			_bg.filters = [ new GlowFilter(0x0, 0.40, 12,12, 2, 2) ];
			this.addChild(_bg);
			
			addHeader();
			
			_rowsHolder = new Sprite();
			_rowsHolder.x = 6;
			_rowsHolder.y = 43;
			this.addChild(_rowsHolder);
			
			_tooltip = new Sprite();
			_tooltip.x = 550;
			_tooltip.y = 58;
			_tooltip.mouseEnabled = _tooltip.mouseChildren = false;
			_tooltip.visible = false;
			this.addChild(_tooltip);
			
				var b:Bitmap = new Assets.ReportCardTooltipBg()
				b.x = -150;
				b.y = (b.height - 10) * -1;
				_tooltip.addChild(b);
				
				var tf:TextField = TextFieldUtil.makeText(ContentModel.gi.getCopyItemByName("rcCommentTooltip").copy, ".reportCardCommentTooltip", 322);
				tf.x = b.x + 5;
				tf.y = b.y + 9;
				_tooltip.addChild(tf);
			
			_dimmer = GrUtil.makeRect(50,50, 0x0, 0.5);
			_dimmer.visible = false;
			_dimmer.alpha = 0;
			this.addChild(_dimmer);

			this.addEventListener(Dropdown.EVENT_OPENED, onDropdownOpened);
			this.addEventListener(FocusEvent.FOCUS_IN, onAnyFocusIn);
			this.addEventListener(FocusEvent.FOCUS_OUT, onAnyFocusOut);
			
			this.addEventListener(CommentDropdownItem.EVENT_OVER_INPUT, onCommentOver);

		}
		
		public static function get instance():ReportTable
		{
			return _instance;
		}
		
		public function get isEditingComment():Boolean
		{
			return _isEditingComment;
		}
		
		private function addHeader():void
		{
			_header = new Sprite();
			_header.x = 0;
			_header.y = 0;
			this.addChild(_header);
			
			var tf:TextField;
			
			tf = TextFieldUtil.makeTextWithCopyDto(_cm.getCopyItemByName("rcTableHeaderPicks"));
			_header.addChild(tf);
			
			tf = TextFieldUtil.makeTextWithCopyDto(_cm.getCopyItemByName("rcTableHeaderTeamName"));
			_header.addChild(tf);
			
			tf = TextFieldUtil.makeTextWithCopyDto(_cm.getCopyItemByName("rcTableHeaderGrade"));
			_header.addChild(tf);
			
			tf = TextFieldUtil.makeTextWithCopyDto(_cm.getCopyItemByName("rcTableHeaderComment"));
			_header.addChild(tf);
		}
		
		public function get rows():Array
		{
			return _rows;
		}
		
		public function resetToDefaults():void
		{
			for (var i:int = 0; i < _rows.length; i++)
			{
				var row:ReportRow = _rows[i];
				
				row.gradeDropdown.value = row.vo.userGrade = row.vo.assignedGrade as String; 
				
				row.commentDropdown.dropdownData = ReportCardUtil.presetComments[ row.gradeDropdown.value ]; 
				row.commentDropdown.value = row.vo.userComment = row.vo.assignedComment as String;
			}
			_areGradesDefault = true;
		}

		public function update($showAndHideFakeLoadingState:Boolean):void
		{
			// remove old first
			while (_rowsHolder.numChildren > 0) {
				var row:ReportRow = _rowsHolder.removeChildAt(0) as ReportRow;
				row.kill();
			}

			// make rows
			var bottomThresh:Number = this.stage.stageHeight - 10; 
			_rows = [];
			for (var i:int = 0; i < _lm.teamsByAlpha.length; i++)
			{
				var r:ReportRow = new ReportRow( _lm.teamsByAlpha[i] );
				r.x = 0;
				r.y = _rows.length * ReportRow.HEIGHT;
				r.gradeDropdown.bottomThresholdGlobal = r.commentDropdown.bottomThresholdGlobal = bottomThresh;
				
				_rows.push(r);
				_rowsHolder.addChild(r);
			}
			
			_dimmer.x = _rowsHolder.x + 69;
			_dimmer.y = _rowsHolder.y;
			_dimmer.width = 723
			_dimmer.height = _rows.length * ReportRow.HEIGHT;
			
			// 

			if ($showAndHideFakeLoadingState)
			{
				this.mouseEnabled = this.mouseChildren = false;
				
				for (i = 0; i < _rows.length; i++)
				{
					row = _rows[i];
					// [a] 
					// row.showFakeLoading1();
					row.showFakeLoading2();
					// [b]
					// setTimeout(row.showFakeLoading2, 333 + i * 50);
					// [c]
					setTimeout(row.hideFakeLoading, 2000 + i * 75);
				}
				
				setTimeout(update_2, 2000 + _rows.length * 75); 
			}
		}
		private function update_2():void
		{
			this.mouseEnabled = this.mouseChildren = true;
		}
		
		public function dimmerOn():void
		{
			TweenLite.killTweensOf(_dimmer);
			TweenLite.to(_dimmer, 0.25, { autoAlpha:1 } );
		}
		public function dimmerOff():void
		{
			TweenLite.killTweensOf(_dimmer);
			TweenLite.to(_dimmer, 0.25, { alpha:0, onComplete:function():void{_dimmer.visible=false;} } );
		}

		private function showTooltip():void
		{
			_tooltip.alpha = 0;
			_tooltip.scaleX = 0.5;
			_tooltip.scaleY = 0.25;
			TweenLite.to(_tooltip, 0.4, { autoAlpha:1, scaleX:1, scaleY:1, ease:Cubic.easeIn } );
		}
		private function hideTooltip():void
		{
			TweenLite.to(_tooltip, 0.2, { alpha:0, scaleX:0.5, scaleY:0.25, ease:Cubic.easeOut, onComplete:function():void{_tooltip.visible=false;} } );
		}
		
		private function onDropdownOpened($e:Event):void
		{
			var targetDropdown:Dropdown = $e.target as Dropdown;

			var targetRow:ReportRow = $e.target.parent;
			_rowsHolder.addChild(targetRow); // put on top
			
			// close any others
			for each (var r:ReportRow in _rows)
			{
				if (r.commentDropdown.isOpen && r.commentDropdown != targetDropdown) r.commentDropdown.close();
				if (r.gradeDropdown.isOpen && r.gradeDropdown != targetDropdown) r.gradeDropdown.close(); 
			}
		}
		
		private function onAnyFocusIn($e:Event):void
		{
			if (true) { // should be: if $e comes from CommentDropdown...
				_isEditingComment = true;
			}
		}
		private function onAnyFocusOut($e:Event):void
		{
			_isEditingComment = false;
		}
		
		private function onRowsBlockerClick($e:Event):void
		{
			for each (var r:ReportRow in _rows)
			{
				if (r.commentDropdown.isOpen) r.commentDropdown.close(); 
			}
		}
		
		private function onCommentOver(e:*):void
		{
			this.removeEventListener(CommentDropdownItem.EVENT_OVER_INPUT, onCommentOver);
			
			showTooltip();
			setTimeout(hideTooltip, 3000);
		}
	}
}
