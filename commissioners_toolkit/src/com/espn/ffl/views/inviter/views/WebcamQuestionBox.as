package com.espn.ffl.views.inviter.views {
	import leelib.util.TextFieldUtil;

	import com.espn.ffl.constants.SiteConstants;
	import com.espn.ffl.model.ContentModel;
	import com.espn.ffl.model.PersonalizedModel;
	import com.greensock.TweenLite;
	import com.greensock.easing.Quad;
	import com.jasontighe.containers.DisplayContainer;
	import com.jasontighe.managers.AssetManager;

	import flash.display.MovieClip;
	import flash.text.TextField;

	/**
	 * @author jason.tighe
	 */
	public class WebcamQuestionBox 
	extends DisplayContainer 
	{
		//----------------------------------------------------------------------------
		// private static constants
		//----------------------------------------------------------------------------
		private static const BG_ALPHA						: Number = .65;
		//----------------------------------------------------------------------------
		// private variables
		//----------------------------------------------------------------------------
		private var _cm										: ContentModel = ContentModel.gi;
		private var _pm										: PersonalizedModel = PersonalizedModel.gi;
		//----------------------------------------------------------------------------
		// public variables
		//----------------------------------------------------------------------------
		public var background		 						: MovieClip;
		public var question				 					: TextField;
		//----------------------------------------------------------------------------
		// constructor
		//----------------------------------------------------------------------------
		public function WebcamQuestionBox() 
		{
			super();
			
			background = MovieClip( AssetManager.gi.getAsset( "InviterWebcamQuestionBoxAsset", SiteConstants.ASSETS_ID ) );
			background.alpha = BG_ALPHA;
			addChild( background );
			
			alpha = 0;
		}
		
		public function showQuestion() : void
		{
			alpha = 0;
			
			var questionCount : uint = _pm.questionCount;
			question = TextFieldUtil.makeTextWithEncodingDto( _cm.getInterviewVideoItemAt( questionCount ));
			var xoffset : int = -1;
			var yoffset : int = 0;
			question.x = int( ( background.width -  question.textWidth ) * .5 ) + xoffset;
			question.y = int( ( background.height -  question.textHeight ) * .5 ) + yoffset;
			addChild( question );
			
			var offset : uint = 10;
			TweenLite.to( this, SiteConstants.TIME_OUT, { alpha: 1 } );
			TweenLite.from( question, SiteConstants.TIME_OVER, { x: question.x - offset, ease: Quad.easeOut } );
		}
		
		public function cleanUp() : void
		{
			if( question && contains( question ) )
			{
				removeChild( question );
				question = null;
			}
		}
	}
}
