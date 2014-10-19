package leelib.facebook
{
	import com.adobe.serialization.json.JSONDecoder;
	import com.adobe.serialization.json.JSONEncoder;
	
	import flash.display.BitmapData;
	
	import leelib.util.Out;

	/**
	 * Stores most all user-account info as requested from FB via FbUtil.
	 * Parses various JSON data from Facebook service into various VO's, etc.
	 * 
	 * Designed for with just one instance in mind (the logged-in user of the app) 
	 */
	public class FbUserVo extends BaseVo
	{
		public var firstName:String;
		public var lastName:String;
		public var name:String; 		// TODO: Resolve issue of name, versus first+last
		
		public var gender:String; 		// male, female, ???
		
		public var location:String;
		public var locationWork:String;
		
		public var birthDayString:String;
		public var birthDayMonth:int = 0;
		public var birthDayDay:int = 0;
		public var birthDayYear:int = 0;

		public var musicNames:Array;
		
		public var friends:Array; // array of FbFriendVo's; leave uninstantiated until get-friends
		public var permissions:Array;
		public var albums:Array; // array of FbAlbumVo's
		
		public var profileImageSquare:BitmapData;
		public var profileImageLarge:BitmapData
		
		
		public function FbUserVo()
		{
		}
		
		public function getProfilePicturesAlbum():AlbumVo
		{
			if (! albums) return null;
			
			for each (var vo:AlbumVo in albums) {
				if (vo.name.toLowerCase() == "profile pictures") return vo;
			}
			
			trace('iffy...');
			return AlbumVo(albums[albums.length-1]);
		}
		
		public function getBiggestAlbum():AlbumVo
		{
			if (! albums) return null;
			
			var max:int = 0;
			var idx:int = -1;
			for (var i:int = 0; i < albums.length; i++)
			{
				var vo:AlbumVo = albums[i];
				if (vo.count > max){
					max = vo.count;
					idx = i;
				}
				
			}
			if (idx == -1) return null;
			if (max == 0) return null;
			
			return albums[idx];
		}
		
		public function parseUserInfoPretend():void
		{
			var s:String = '{ "id": ";100000259701025", "name": "Facebook Person", "first_name": "Imaginary", "last_name": "Facebook Person", "link": "http://www.facebook.com/profile.php?id=100000259701025", "location": { "id": 108424279189115, "name": "New York, New York" }, "work": [ { "employer": { "id": 109183755777829, "name": "Self Employed" }, "location": { "id": 109155499103263, "name": "Cebu City" }, "position": { "id": 125101890851047, "name": "head llama" }, "start_date": "0000-00", "end_date": "0000-00" } ], "education": [ { "school": { "id": 114410515242823, "name": "new highschool" }, "year": { "id": 124456560905888, "name": "2009" } }, { "school": { "id": 116553148355387, "name": "Mymensingh Medical College" }, "year": { "id": 124291087586019, "name": "2012" } } ], "gender": "male", "timezone": -4, "updated_time": "2010-05-25T22:35:17+0000" }';			
			var o:Object = new JSONDecoder(s, false).getValue();
			parseUserInfo(o);
		}

		public function parseUserInfo($o:Object):Boolean
		{
			if (!$o) return false;
			if (!$o.id) return false;
			
			if ($o.id) id = $o.id;
			if ($o.first_name) firstName = $o.first_name;
			if ($o.last_name) lastName = $o.last_name;
			if ($o.name) name = $o.name;
			if ($o.gender) gender = $o.gender;
			if ($o.location && $o.location.name) location = $o.location.name;
			
			if ($o.work) {
				// parse "work" for location
				for (var i:int = 0; i < $o.work.length; i++) {
					if ($o.work[i].location && $o.work[i].location.name) {
						locationWork = $o.work[i].location.name;
						break;
					}
				}
			}

			Out.d('FbUserVo.parseUserInfo() - USER INFO:', id, firstName, lastName, gender, location, locationWork);
			
			return true;
		}
		
		public function parseAlbumList($o:Object):void
		{
			if ($o && $o.data)
			{
				albums = [];
				for (var i:int = 0; i < $o.data.length; i++) 
				{
					var id:String = $o.data[i].id;
					var name:String = $o.data[i].name;
					var count:int = parseInt($o.data[i].count);
					var vo:AlbumVo = new AlbumVo(id,name,count);
					albums.push(vo);
				}			
			}
			trace('ALBUMS:', albums);
		}
		
		public function parseLikes($o:Object):void
		{
			// parse likes for music specifically
			
			if ($o && $o.data) 
			{
				musicNames = [];
				for (var i:int = 0; i < $o.data.length; i++) 
				{
					var cat:String = $o.data[i].category;
					var val:String = $o.data[i].name;
					if (cat && cat.toLowerCase().indexOf("music") > -1) musicNames.push(val);
				}
			}

			// trace('LIKEBANDS:', musicNames);
		}
		
		public function parseFriends($o:Object):Boolean
		{
			if (! $o|| ! $o.data) return false;
			
			friends = [];

			for (var i:int = 0; i < $o.data.length; i++) 
			{
				var name:String = $o.data[i].name;
				var id:String = $o.data[i].id;
				var vo:FbFriendVo = new FbFriendVo(id,name);
				friends.push(vo);
			}
			
			// sort, too
			friends.sortOn("name", Array.CASEINSENSITIVE);
			
			// trace('FRIENDS:', friends.length, friends);

			return true;
		}

		public function parsePermissions($o:Object):Boolean
		{
			// $o.data[0] - key == permissionName, value == 0|1)
			
			if (! $o || ! $o.data || ! $o.data[0]) return false;

			permissions = [];

			var o:Object = $o.data[0];
			for (var key:String in o)
			{
				if (o[key] == 1) permissions.push(key);
			}

			return true;
		}
		
		//
		
		public function parseFeedForFriendActivity($o:Object):void
		{
			// tally friend activity on user's wall by looking at 
			// item's from object, and also looking at 
			// comments/from inside of item
			
			if (! $o || ! $o.data) {
				trace('FbUserVo.parseFeedForFriendActivity() - NO DATA');	
				return;
			} 
			if ($o.data.length == 0) {
				trace('FbUserVo.parseFeedForFriendActivity() - NO ITEMS IN FEED');
				return;
			}
			
			var i:int;
			var id:String;
			var vo:FbFriendVo;
			for (i = 0; i < $o.data.length; i++) 
			{
				if (! $o.data[i].from) continue;
				
				id = $o.data[i].from.id;
				vo = getFriendById(id);
				if (vo) {
					vo.activityTally++;
				}
				
				if (! $o.data[i].comments || ! $o.data[i].comments.data) continue;
				
				for (var j:int = 0; j < $o.data[i].comments.data.length; j++)
				{
					if ($o.data[i].comments.data[j].from) {
						id = $o.data[i].comments.data[j].from.id;
						vo = getFriendById(id);
						if (vo) {
							vo.activityTally++;
						}
					}
				}
			}
			
			// * friends sorted by activity
			friends.sort(friendSort);
			
			var s:String = "MOST ACTIVE WALL FRIENDS: ";
			for (i = 0; i < Math.min(friends.length,10); i++) {
				vo = friends[i];
				s += vo.name + " " + vo.activityTally + ", ";
			}
			trace(s);
		}
		
		public function getFriendById($id:String):FbFriendVo
		{
			for each (var vo:FbFriendVo in friends) {
				if (vo.id == $id) return vo;
			}
			return null;
		}
		
		private function friendSort($a:FbFriendVo, $b:FbFriendVo):int
		{
			if ($a.activityTally > $b.activityTally)
				return -1;
			else if ($a.activityTally < $b.activityTally)
				return +1;
			else
				return 0;
		}
	}
}
