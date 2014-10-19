package com.espn.ffl.views.report_card
{
	import com.espn.ffl.constants.SiteConstants;
	import com.espn.ffl.model.ContentModel;
	import com.espn.ffl.model.LeagueModel;
	import com.espn.ffl.util.Assets;
	import com.espn.ffl.util.FacebookHelper;
	import com.espn.ffl.views.Main;
	import com.espn.ffl.views.report_card.vos.PlayerVo;
	import com.espn.ffl.views.report_card.vos.TeamVo;
	import com.jasontighe.managers.AssetManager;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.IOErrorEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	import leelib.graphics.DashedLine;
	import leelib.util.FileRefUtil;
	import leelib.util.Out;
	import leelib.util.StringUtil;
	import leelib.util.TextFieldUtil;


	/**
	 * Static class
	 */
	public class ReportCardUtil
	{
		public static const COMMENT_WIDTH_THRESH:Number = 440;
		
		// Array of objects with properties "maxRank" and "numPoints".
		// Array elements expected to be in correct order. 
		// Comes from hardcoded internal JSON file.
		public static var rankToPoints:Array; 

		public static var berryRankings:Array;
		
		// Associative array - key = grade letter; value = array of Strings (comments)
		public static var presetComments:Object;
		
		private static var _lm:LeagueModel = LeagueModel.gi;
		
		

		public function ReportCardUtil()
		{
		}

		public static function getBerryRank($playerVo:PlayerVo):int
		{
			var indexOf:int = berryRankings.indexOf($playerVo.id);
			return (indexOf == -1) ? 9999 : (indexOf+1);
		}
		
		public static function getPointsFromRank($rank:int):int
		{
			for (var i:int = 0; i < rankToPoints.length; i++)
			{
				var maxRank:int = rankToPoints[i].maxRank;
				var numPoints:int = rankToPoints[i].numPoints;
				if ($rank <= maxRank) { 
					return numPoints; 
				} 
			}

			Out.w("getPoints - Shouldn't get here");
			return 1;
		}
		
		public static function parseDraftPicksJson($o:Object):void
		{
			// Docs: "The picks are returned in descending order from first overall pick to last"
			
			var a:Array = $o["draftResults"];
			for (var i:int = 0; i < a.length; i++)
			{
				var o:Object = a[i];
			}
		}
		
		public static function generateGrades():void
		{
			var teamVo:TeamVo;

			// [a] calc team's cumulative points
			for each (teamVo in _lm.teamsById)
			{
				var cumulative:int = 0;
				for each (var playerVo:PlayerVo in teamVo.playersById)
				{
					var rank:int = getBerryRank(playerVo);
					var points:int = getPointsFromRank(rank);
					cumulative += points;
					// trace(teamVo.fullTeamName + ", " + playerVo.name + ", " + rank + ", " + points);
				}
				teamVo.cumulativePoints = cumulative;
			}
			
			// [b] compare teams' cumulativepoints against each other to determine grade
			
			var teamsByPoints:Array = [];
			for each (teamVo in _lm.teamsById){
				teamsByPoints.push(teamVo);
			}
			teamsByPoints.sortOn("cumulativePoints", Array.DESCENDING | Array.NUMERIC);
			
			var numTeams:int = 0;
			for each (teamVo in _lm.teamsById) {
				numTeams++;
			}
			
			if (numTeams == 4)
			{
				teamsByPoints[0].assignedGrade = "A";
				teamsByPoints[1].assignedGrade = "B";
				teamsByPoints[2].assignedGrade = "C";
				teamsByPoints[3].assignedGrade = "D";
			}
			else if (numTeams == 5) // this shouldn't happen but just in case
			{
				teamsByPoints[0].assignedGrade = "A";
				teamsByPoints[1].assignedGrade = "B+";
				teamsByPoints[2].assignedGrade = "B";
				teamsByPoints[3].assignedGrade = "C";
				teamsByPoints[4].assignedGrade = "D";
			}
			else if (numTeams == 6)
			{
				teamsByPoints[0].assignedGrade = "A";
				teamsByPoints[1].assignedGrade = "B+";
				teamsByPoints[2].assignedGrade = "B";
				teamsByPoints[3].assignedGrade = "C+";
				teamsByPoints[4].assignedGrade = "C";
				teamsByPoints[5].assignedGrade = "D";
			}
			else if (numTeams == 7) // this shouldn't happen either
			{
				teamsByPoints[0].assignedGrade = "A+";
				teamsByPoints[1].assignedGrade = "A";
				teamsByPoints[2].assignedGrade = "B+";
				teamsByPoints[3].assignedGrade = "B";
				teamsByPoints[4].assignedGrade = "C+";
				teamsByPoints[5].assignedGrade = "C";
				teamsByPoints[6].assignedGrade = "D";
			}
			else if (numTeams == 8)
			{
				teamsByPoints[0].assignedGrade = "A+";
				teamsByPoints[1].assignedGrade = "A";
				teamsByPoints[2].assignedGrade = "B+";
				teamsByPoints[3].assignedGrade = "B";
				teamsByPoints[4].assignedGrade = "C+";
				teamsByPoints[5].assignedGrade = "C";
				teamsByPoints[6].assignedGrade = "D";
				teamsByPoints[7].assignedGrade = "D";
			}
			else if (numTeams == 9)
			{
				teamsByPoints[0].assignedGrade = "A+";
				teamsByPoints[1].assignedGrade = "A";
				teamsByPoints[2].assignedGrade = "B+";
				teamsByPoints[3].assignedGrade = "B";
				teamsByPoints[4].assignedGrade = "B-";
				teamsByPoints[5].assignedGrade = "C+";
				teamsByPoints[6].assignedGrade = "C";
				teamsByPoints[7].assignedGrade = "D";
				teamsByPoints[8].assignedGrade = "D";
			}
			else if (numTeams == 10)
			{
				teamsByPoints[0].assignedGrade = "A+";
				teamsByPoints[1].assignedGrade = "A";
				teamsByPoints[2].assignedGrade = "A-";
				teamsByPoints[3].assignedGrade = "B+";
				teamsByPoints[4].assignedGrade = "B";
				teamsByPoints[5].assignedGrade = "B-";
				teamsByPoints[6].assignedGrade = "C+";
				teamsByPoints[7].assignedGrade = "C";
				teamsByPoints[8].assignedGrade = "D";
				teamsByPoints[9].assignedGrade = "D";
			}
			else if (numTeams == 11)
			{
				teamsByPoints[0].assignedGrade = "A+";
				teamsByPoints[1].assignedGrade = "A";
				teamsByPoints[2].assignedGrade = "A-";
				teamsByPoints[3].assignedGrade = "B+";
				teamsByPoints[4].assignedGrade = "B";
				teamsByPoints[5].assignedGrade = "B-";
				teamsByPoints[7].assignedGrade = "C+";
				teamsByPoints[8].assignedGrade = "C";
				teamsByPoints[9].assignedGrade = "C-";
				teamsByPoints[10].assignedGrade= "D";
			}
			else if (numTeams == 12)
			{
				teamsByPoints[0].assignedGrade = "A+";
				teamsByPoints[1].assignedGrade = "A";
				teamsByPoints[2].assignedGrade = "A-";
				teamsByPoints[3].assignedGrade = "B+";
				teamsByPoints[4].assignedGrade = "B";
				teamsByPoints[5].assignedGrade = "B";
				teamsByPoints[6].assignedGrade = "B-";
				teamsByPoints[7].assignedGrade = "C+";
				teamsByPoints[8].assignedGrade = "C";
				teamsByPoints[9].assignedGrade = "C-";
				teamsByPoints[10].assignedGrade= "D";
				teamsByPoints[11].assignedGrade= "D";
			}
			
			for each (teamVo in teamsByPoints) {
				teamVo.userGrade = teamVo.assignedGrade;
			}
			
			// [c] grade comments
			
			var gradeCounter:Array = []; // used to prevent dupes; complicated
			gradeCounter['A+'] = 0;
			gradeCounter['A']  = 0;
			gradeCounter['A-'] = 0;
			gradeCounter['B+'] = 0;
			gradeCounter['B']  = 0;
			gradeCounter['B-'] = 0;
			gradeCounter['C+'] = 0;
			gradeCounter['C']  = 0;
			gradeCounter['C-'] = 0;
			gradeCounter['D']  = 0;
			gradeCounter['F']  = 0;
			
			for each (teamVo in _lm.teamsById)
			{
				var grade:String = teamVo.assignedGrade;
				
				var index:int = gradeCounter[grade];
				teamVo.assignedComment = teamVo.userComment = presetComments[grade][index];
				
				gradeCounter[grade]++;
				if (gradeCounter[grade] >= presetComments[grade].length) gradeCounter[grade] = 0;
			}
			
			for (var i:int = 0; i < teamsByPoints.length; i++)
			{
				teamVo = teamsByPoints[i];
				Out.i('ReportCardUtil.generateGrades() - team:', teamVo.fullTeamName, '- points:', teamVo.cumulativePoints, '- grade:', teamVo.assignedGrade);
				Out.i('ReportCardUtil.generateGrades() - default comment:', teamVo.assignedComment);
			}
		}
		
		public static function makeImage():BitmapData
		{
			var s:Sprite = new Sprite();

			var b:Bitmap;
			var bmd:BitmapData;
			var tf:TextField;
			
			var rowHeight:Number = 39;
			var gridTop:Number = 105;
			var gridBottom:Number = gridTop + (_lm.teamsByAlpha.length * rowHeight);
			var gridLeft:Number = 39;
			var gridRight:Number = 826;
			
			b = AssetManager.gi.getAsset( "reportCardPlaqueWhiteStars", SiteConstants.LEE_ASSETS_ID);
			s.addChild(b);
			
			var shape:Shape = new Shape();
			s.addChild(shape);

			// title graphic
			b = AssetManager.gi.getAsset( "reportCardFinalBug", SiteConstants.LEE_ASSETS_ID);
			b.x = 33;
			b.y = 8;
			s.addChild(b);
			
			// league name
			tf = TextFieldUtil.makeText(_lm.leagueName.toUpperCase(), ".reportCardFinalTitle");
			bmd = new BitmapData(tf.textWidth, tf.textHeight, true, 0x0);
			bmd.draw(tf);
			b = new Bitmap(bmd);
			b.x = s.width - b.width - 38;
			b.y = 10;
			s.addChild(b);

			if (b.width > 370)  // shrink to fit
			{
				b.width = 370;
				b.x = s.width - b.width - 38;
				b.scaleY = b.scaleX;
				b.smoothing = true;
				
				// also push downward proportionately a little
				b.y += 25 - (b.scaleY * 25);
			}

			// header

			shape.graphics.lineStyle(2, 0x0);
			shape.graphics.moveTo(gridLeft,68);
			shape.graphics.lineTo(gridRight,68);
			
			shape.graphics.lineStyle(2, 0x0);
			shape.graphics.moveTo(gridLeft,gridTop);
			shape.graphics.lineTo(gridRight,gridTop);

			tf = TextFieldUtil.makeText("TEAM NAME", ".reportCardFinalHeader");
			tf.x = 98;
			tf.y = 74;
			s.addChild(tf);

			tf = TextFieldUtil.makeText("GRADE", ".reportCardFinalHeader");
			tf.x = 293;
			tf.y = 74;
			s.addChild(tf);
			
			
			tf = TextFieldUtil.makeText(ContentModel.gi.getCopyItemByName("rcTableHeaderComment").copy, ".reportCardFinalHeader");
			tf.x = 490;
			tf.y = 74;
			s.addChild(tf);
			
			// grid elements 
			
			for (var i:int = 0; i < _lm.teamsByAlpha.length; i++)
			{
				var y:Number = gridTop + i * rowHeight;
				var vo:TeamVo = _lm.teamsByAlpha[i];
				
				// stroke
				var thik:Number = (i < _lm.teamsByAlpha.length-1) ? 1 : 3;
				shape.graphics.lineStyle(thik, 0x0);
				shape.graphics.moveTo(gridLeft, y+rowHeight);
				shape.graphics.lineTo(gridRight, y+rowHeight);
				
				tf = TextFieldUtil.makeText(vo.fullTeamName.toUpperCase(), ".reportCardTableTeam");
				tf.x = gridLeft;
				tf.y = y + 11;
				s.addChild(tf);

				tf = TextFieldUtil.makeText(vo.userGrade, ".reportCardTableGrade");
				tf.x = 295;
				tf.y = y + 2;
				s.addChild(tf);

				tf = TextFieldUtil.makeText(vo.userComment, ".reportCardFinalComment");
				tf.x = gridLeft+345;
				tf.y = y + 11;
				s.addChild(tf);

				TextFieldUtil.ellipsize(tf, COMMENT_WIDTH_THRESH);
			}
			
			// column dividers
			var dash:DashedLine = new DashedLine(1, 0x0, [6,2]);
			s.addChild(dash);
			dash.moveTo(gridLeft+240, gridTop);
			dash.lineTo(gridLeft+240, gridBottom) 

			dash = new DashedLine(1, 0x0, [6,2]);
			s.addChild(dash);
			dash.moveTo(gridLeft+323, gridTop);
			dash.lineTo(gridLeft+323, gridBottom) 
			
			// commit
			bmd = new BitmapData(s.width, s.height);
			bmd.draw(s);
			
			return bmd;
		}
		
		public static function saveFileToLocal($ba:ByteArray, $defaultFilename:String):void
		{
			var fru:FileRefUtil = new FileRefUtil();
			fru.save($ba, $defaultFilename, onSaveFileError, onSaveFileCancel, onSaveFileComplete);
		}
		private static function onSaveFileError($e:IOErrorEvent):void
		{
			Main.instance.showDialogWithCopyDtoId(false, "alertConnectionError");
		}
		private static function onSaveFileCancel(e:*=null):void
		{
			// ...	
		}
		private static function onSaveFileComplete(e:*=null):void
		{
			// no messaging here?
		}
	}
}
