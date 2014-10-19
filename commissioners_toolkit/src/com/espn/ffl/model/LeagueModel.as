package com.espn.ffl.model 
{
	import com.espn.ffl.views.report_card.vos.PlayerVo;
	import com.espn.ffl.views.report_card.vos.TeamVo;
	
	import flash.events.EventDispatcher;
	import flash.external.ExternalInterface;
	import flash.utils.Dictionary;
	
	import leelib.util.Out;
	import leelib.util.StringUtil;

	public class LeagueModel extends EventDispatcher 
	{
		private static var _instance:LeagueModel;
		
		private var _leagueId:String;
		private var _seasonId:String;

		private var _isCommissioner:Boolean;
		private var _leagueJson:Object;
		private var _leagueName:String;
		private var _userProfileId:String;
		private var _firstName:String;
		private var _lastName:String;
		private var _draftResultsUrl:String;
		
		private var _teamsById:Dictionary;
		private var _teamsByAlpha:Array;

		
		public function LeagueModel( e : LeagueModelEnforcer ) 
		{
			trace( "LEAGUEMODEL : Constr" );
			
			var url:String = ExternalInterface.call("window.location.href.toString");
			var o:Object = StringUtil.getQueryStringObject(url);
			
			_leagueId = o["leagueId"];
			if (! _leagueId)
			{
				if (! ConfigModel.gi.isEspnEnvironment) 
				{
					_leagueId = "323"; 
					Out.w("LeagueModel - IS NOT ESPN ENVIRONMENT, USING THIS LEAGUEID", _leagueId);

					// sean league on qa: 333; league with no teams: 323 
					// customer's problem league 325859
					// riley qa problem league 328; riley qa problem league 353; riley qa league ok 351 
					// espn prod environment sample leagueids: 16260; 122262; 122280
				}
				else 
				{
					Out.w("LeagueModel - NO LEAGUEID IN URL PARAMS!");
				}
			}
			
			_seasonId = o["seasonId"];
			if (! _seasonId)
			{
				_seasonId = ConfigModel.gi.defaultSeason;

				if (! ConfigModel.gi.isEspnEnvironment) 
					Out.w("LeagueModel - IS NOT ESPN ENVIRONMENT, USING 'DEFAULT' SEASONID", _seasonId );
				else 
					Out.w("LeagueModel - NO SEASONID IN URL PARAMS! USING 'DEFAULT' SEASONID", _seasonId );
			}

			// init as empty collections to avoid null ref errors
			_teamsById = new Dictionary();
			_teamsByAlpha = [];
		}
		
		public function parseLeagueServiceData(o:Object) : void
		{
			// isLeagueManager
			
			if (o["isLeagueManager"] == undefined) {
				Out.w("LeagueModel - ISLEAGUEMANAGER PROPERTY IS MISSING, SETTING TO FALSE");
				_isCommissioner = false;
			}
			else
			{
				_isCommissioner = o["isLeagueManager"];

				if (! _isCommissioner && ! ConfigModel.gi.isEspnEnvironment) {
					_isCommissioner = true;
					Out.w("LeagueModel - IS NOT ESPN ENVIRONMENT, SETTING ISCOMMISSIONER TO TRUE");
				}
			}
			
			// leagueName
			
			_leagueName = o["leagueName"];

			// TEST ONLY (32 CHAR MAX): _leagueName = "01234567890123456789012345678901"; 
			
			if (! _leagueName) {
				Out.w("LeagueMode.addData() - NO LEAGUE NAME! SETTING TO BLANK");
				_leagueName = " ";
			}
	
			// userProfileId
			
			_userProfileId = o["userProfileId"];

			if (! _userProfileId && ! ConfigModel.gi.isEspnEnvironment) {
				_userProfileId = "29105673"; // sean's qa account
				Out.w("LeagueModel - IS NOT ESPN ENVIRONMENT, SETTING USERPROFILEID TO", _userProfileId);
			}


			// user first last
			
			_firstName = o["firstName"];
			_lastName = o["lastName"];
			
			// draftResultsUrl
			
			if (o["links"] && o["links"]["draft-results"] && o["links"]["draft-results"]["href"]) 
			{
				_draftResultsUrl = o["links"]["draft-results"]["href"];

				// _draftResultsUrl = "http://games.espn.go.com/ffl/api/v2/draftResults?leagueId=325859";
				// Out.i("USING TEST DRAFT RESULTS URL", _draftResultsUrl); 
			}
			else {
				Out.w("LeagueMode.addData() - DRAFTRESULTSURL IS MISSING");
			}
			
			_leagueJson = o;

			Out.i("");
			Out.i("LEAGUEMODEL SUMMARY");
			Out.i("");
			Out.i("leagueId           ", _leagueId);
			Out.i("seasonId           ", _seasonId);
			Out.i("isCommissioner     ", _isCommissioner);
			Out.i("leagueName         ", _leagueName);
			Out.i("userProfileId      ", _userProfileId);
			Out.i("firstName          ", _firstName);
			Out.i("lastName           ", _lastName);
			Out.i("draftResultsUrl    ", _draftResultsUrl);
			Out.i("");
		}

		// Rem, team list only gets constructed here, due to the unfortunate way   
		// data is organized in the commissioner webservice.
		//
		public function parseDraftServiceData($o:Object):void
		{
			_teamsById = new Dictionary();

			if (! $o.draftResults) {
				Out.w("parseDraftResults() - NO DRAFTRESULTS PROPERTY");
				return;
			}
			if ($o.draftResults.length == 0) {
				Out.w("parseDraftResults() - NOTE THAT DRAFT RESULTS ARE EMPTY");
				return;
			}
			
			// Note how service data structure is less than ideal..
			
			var numTeams:int = 0;
			
			var length:int = $o.draftResults.length;
			
			// FOR DEBUGGING ONLY:
			// length = 4;
			
			for (var i:int = 0; i < length; i++)
			{
				var dro:Object = $o.draftResults[i];
				
				if (! dro.teamId) {
					Out.w("parseDraftResults - NO TEAM ID, SKIPPING!");
					continue;
				}
				
				var teamVo:TeamVo = _teamsById[dro.teamId];
				
				if (! teamVo) {
					// is first time encountering this team. make vo for it.
					teamVo = TeamVo.makeFromDraftResultObject(dro);
					if (! teamVo) {
						Out.w("LeagueMode.parseDraftServiceData() - IGNORING BAD DRAFT OBJECT");
						continue;
					}
					_teamsById[dro.teamId] = teamVo;
					numTeams++;
				}
				
				var playerVo:PlayerVo = PlayerVo.makeFromDraftResultObject( dro, (i+1) );
				if (! teamVo.playersById) teamVo.playersById = new Dictionary();
				teamVo.playersById[playerVo.id] = playerVo;
			}
			
			// At this point, we have all players

			Out.w("LeagueModel.parseDraftResults() - FINAL NUMBER OF TEAMS (DERIVED):", numTeams);

			// finally, order teams by alpha
			
			_teamsByAlpha = [];
			for each (teamVo in LeagueModel.gi.teamsById)
			{
				_teamsByAlpha.push(teamVo);
				_teamsByAlpha.sortOn("fullTeamName", Array.CASEINSENSITIVE); // TODO: THIS IS WRONG RIGHT?
			}
			
			// WE'RE NOT USING THESE FIELDS:
			// teamVo.managerFirstName = "FpoFirst";
			// teamVo.managerFirstName = "FpoLast" + teamVo.id;
			// teamVo.managerUserName = "fpo_000" + teamVo.id
		}

		//----------------------------------------------------------------------------
		// getters (read-only...)
		//----------------------------------------------------------------------------
		public static function get gi() : LeagueModel
		{
			if(!_instance) _instance = new LeagueModel(new LeagueModelEnforcer());
			return _instance;
		}
		
		public function get isCommissioner():Boolean
		{
//			return _isCommissioner;
			return true;
		}
		
		public function get leagueId():String
		{
			return _leagueId;
		}
		
		// FOR TESTING USE ONLY
		public function set leagueId($s:String):void
		{
			_leagueId = $s;
		}
		
		public function get seasonId():String
		{
			return _seasonId;
		}
		
		public function get leagueJson():Object
		{
			return _leagueJson;
		}
		
		public function get leagueName():String
		{
			return _leagueName;
		}
		
		public function get userProfileId():String
		{
			return _userProfileId;
		}
		
		public function get firstName():String
		{
			return _firstName;
		}
		
		public function get lastName():String
		{
			return _lastName;
		}
		
		public function get draftResultsUrl():String
		{
			return _draftResultsUrl;
		}
		
		public function get teamsById():Dictionary
		{
			return _teamsById;
		}
		
		public function get teamsByAlpha():Array
		{
			return _teamsByAlpha;
		}
		
		public function get numTeams():int
		{
			return _teamsByAlpha.length;
		}
		
		public function getTeamVoById($id:String):TeamVo
		{
			for each (var teamVo:TeamVo in _teamsByAlpha) {
				if (teamVo.id == $id) return teamVo;
			}
			return null;
		}

	}
}

class LeagueModelEnforcer{}
