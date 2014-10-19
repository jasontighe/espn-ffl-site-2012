package com.espn.ffl.views.report_card.views
{
	import com.espn.ffl.constants.SiteConstants;
	import com.espn.ffl.model.ContentModel;
	import com.espn.ffl.util.Assets;
	import com.greensock.TweenLite;
	import com.greensock.easing.Quad;
	import com.greensock.easing.Quart;
	import com.greensock.easing.Quint;
	import com.jasontighe.managers.AssetManager;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.filters.DropShadowFilter;
	import flash.text.TextField;
	
	import leelib.graphics.GrUtil;
	import leelib.util.TextFieldUtil;
	
	/**
	 * Includes 
	 * - text "I'm giving you a head start..."
	 * - text "MATTHEW BERRY'S GRADE" below that
	 * - talk bubble graphic to the right of that
	 */
	public class TalkBubble extends Sprite
	{
		private var _tfQuote:TextField;
		private var _tfGrade:TextField;
		
		private var _bubbleHolder:Sprite;
			private var _circle:Bitmap;
			private var _photo:Bitmap;		
	
		
		public function TalkBubble()
		{
			_tfQuote = TextFieldUtil.makeTextWithCopyDto(ContentModel.gi.getCopyItemByName("rcHeadStart"));
			this.addChild(_tfQuote);

			_tfGrade = TextFieldUtil.makeHtmlTextWithCopyDto(ContentModel.gi.getCopyItemByName("rcMbGrade"), 700);
			//_tfGrade.filters = [ new DropShadowFilter(1,270,0x0,.40,1,1,1,2) ];
			_tfGrade.x = 83;
			_tfGrade.y = 154;
			this.addChild(_tfGrade);
			
			_bubbleHolder = new Sprite();
			_bubbleHolder.x = 297;
			_bubbleHolder.y = _tfGrade.y + 8;
			_bubbleHolder.visible = false;
			_bubbleHolder.alpha = 0;
			this.addChild(_bubbleHolder);
			
				_circle = AssetManager.gi.getAsset( "talkBubbleRed", SiteConstants.LEE_ASSETS_ID);// ReportCardTalkBubbleCircle();
				_circle.smoothing = true;
				_circle.y = -122;
				_bubbleHolder.addChild(_circle);
			
				_photo = AssetManager.gi.getAsset( "talkBubblePhoto", SiteConstants.LEE_ASSETS_ID);// new Assets.ReportCardTalkBubblePhoto();
				_photo.smoothing = true;
				_photo.y = -122;
				_bubbleHolder.addChild(_photo);
		}
		
		public function showAll():void
		{
			_tfQuote.visible = true;
			_tfQuote.alpha = 1;
			_tfGrade.visible = true;
			_tfGrade.alpha = 1;
			
			_bubbleHolder.alpha = 0;
			_bubbleHolder.visible = true;
			_bubbleHolder.scaleX = _bubbleHolder.scaleY = 0.5;
			
			TweenLite.to(_bubbleHolder, .66, { alpha:1, scaleX:1, scaleY:1, ease:Quad.easeIn } );
			
		}

		public function hideAfterShow():void
		{
			var f:Function = function():void 
			{
				_bubbleHolder.visible = false;
				_tfQuote.visible = false;
				// tfGrade never goes invisible
			}
			
			TweenLite.to(_bubbleHolder, .75, { alpha:0, scaleX:.25, scaleY:.25, ease:Quint.easeOut, onComplete:f } );
			TweenLite.to(_tfQuote, .75, { alpha:0 } );
		}
		
		public function showGradeHeader():void
		{
			TweenLite.killTweensOf(_tfQuote);
			TweenLite.to( _tfGrade, 0.33, { alpha:1 } );
		}
		public function hideGradeHeader():void
		{
			TweenLite.killTweensOf(_tfQuote);
			TweenLite.to( _tfGrade, 0.33, { alpha:0 } );
		}
	}
}