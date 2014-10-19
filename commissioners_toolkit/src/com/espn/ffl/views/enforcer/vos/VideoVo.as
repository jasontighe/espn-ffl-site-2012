package com.espn.ffl.views.enforcer.vos
{
	import com.espn.ffl.model.ConfigModel;

	public class VideoVo
	{
		public var id:String;
		public var topTitle:String;
		public var thumbTitle:String;
		public var thumbPath:String;
		public var videoFile:String;
		public var facebookShareUrl:String;
		public var facebookShareTitle:String;
		public var facebookShareCaption:String;
		public var facebookShareDescription:String;
		
		
		public function VideoVo()
		{
		}
		
		public function toString():String
		{
			return "[VideoVo]" + 
				"\rid: " + id + 
				"\rtopTitle: " + topTitle + 
				"\rthumbTitle: " + thumbTitle +
				"\rthumbImage: " + thumbPath +
				"\rthumbTitle: " + thumbTitle +
				"\rvideoFile: " + videoFile + 
				"\rfacebookShareUrl: " + facebookShareUrl + 
				"\rfacebookShareTitle: " + facebookShareTitle +
				"\rfacebookShareCaption: " + facebookShareCaption +
				"\rfacebookShareDescription: " + facebookShareDescription;
		}

		public function get videoFullPath():String
		{
			return ConfigModel.gi.enforcerBaseUrlVideos + videoFile;
		}

		public static function fromXml($x:XML):VideoVo
		{
			var vo:VideoVo = new VideoVo();
			vo.id = $x.@id;
			vo.topTitle = $x.@topTitle;
			vo.thumbPath = $x.@thumbPath;
			vo.thumbTitle = $x.@thumbTitle;
			vo.thumbTitle = vo.thumbTitle.replace("\\r", "\r"); // * replace string literal "\r" with hardreturn
			vo.videoFile = $x.@videoFile;
			vo.facebookShareUrl = $x.@facebookShareUrl;
			vo.facebookShareTitle = $x.@facebookShareTitle;
			vo.facebookShareCaption = $x.@facebookShareCaption;
			vo.facebookShareDescription = $x.@facebookShareDescription;
			return vo;
		}
	}
}
