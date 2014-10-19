package com.espn.ffl.views.enforcer 
{
	import com.espn.ffl.constants.SiteConstants;
	import com.espn.ffl.model.ConfigModel;
	import com.espn.ffl.model.ContentModel;
	import com.espn.ffl.util.FacebookHelper;
	import com.espn.ffl.util.Metrics;
	import com.espn.ffl.views.AbstractView;
	import com.espn.ffl.views.FflButton;
	import com.espn.ffl.views.Main;
	import com.espn.ffl.views.UnderlineButton;
	import com.espn.ffl.views.enforcer.views.EnforcerVideo;
	import com.espn.ffl.views.enforcer.views.ThumbButton;
	import com.espn.ffl.views.enforcer.views.ThumbSelector;
	import com.espn.ffl.views.enforcer.vos.VideoVo;
	import com.jasontighe.managers.AssetManager;
	
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filters.DropShadowFilter;
	import flash.system.System;
	import flash.text.TextField;
	
	import leelib.util.Out;
	import leelib.util.TextFieldUtil;


	// Structured for flexibility based on not knowing final IA...
	//
	public class Enforcer extends AbstractView 
	{
		private var _bg:DisplayObject;
		private var _titling:DisplayObject;
		private var _tfSub:TextField;

		private var _plate:Sprite;
			private var _getUrlButton:Sprite;
			private var _shareButton:Sprite;
		
		private var _tfVideoTitle:TextField;
		
		private var _vid:EnforcerVideo;
		private var _thumbSelector:ThumbSelector;
		
		private var _cm:ContentModel = ContentModel.gi;
		private var _fb:FacebookHelper = FacebookHelper.instance;

		private var _videoVos:Array;
		private var _selectedVideoVo:VideoVo;
		private var _placementImageUrl:String;
		
		
		public function Enforcer() 
		{
			// init 'model'

			initVideoVos();
			
			// init views
			
			_bg = AssetManager.gi.getAsset( "enforcerBg", SiteConstants.LEE_ASSETS_ID);
			this.addChild(_bg);
			
			_titling = AssetManager.gi.getAsset( "enforcerTitling", SiteConstants.LEE_ASSETS_ID);
			_titling.x = 88;
			_titling.y = 28;
			this.addChild(_titling);
			
			_tfSub = TextFieldUtil.makeHtmlTextWithCopyDto(_cm.getCopyItemByName("enforcerSub"), 450, 90);
			this.addChild(_tfSub);
			
			_plate = new Sprite();
			_plate.x = 88;
			_plate.y = 157;
			this.addChild(_plate);
			
				var b:Bitmap = AssetManager.gi.getAsset( "enforcerPlate", SiteConstants.LEE_ASSETS_ID); 
				_plate.addChild(b);
				
				b = AssetManager.gi.getAsset( "enforcerThumbsBg", SiteConstants.LEE_ASSETS_ID);  
				b.x = 4;
				b.y = 435;
				_plate.addChild(b);

				_getUrlButton = new UnderlineButton(_cm.getCopyItemByName("enforcerGetUrlButton"), true, true);
				_getUrlButton.x = 544;
				_getUrlButton.y = 21;
				_plate.addChild(_getUrlButton);

				_shareButton = new FflButton(_cm.getCopyItemByName("enforcerShareButton").copy, 93,32, 17, FflButton.BACKGROUNDTYPE_GREEN, false);
				_shareButton.x = 623;
				_shareButton.y = 16;
				_plate.addChild(_shareButton);

				_tfVideoTitle = TextFieldUtil.makeText(" ", ".enforcerVideoTitle");
				_tfVideoTitle.filters = [ new DropShadowFilter(1,60,0x0,0.5,0,0,2,3, true) ];
				_tfVideoTitle.x = 74;
				_tfVideoTitle.y = 18;
				_plate.addChild(_tfVideoTitle);

				_vid = new EnforcerVideo(_placementImageUrl);
				_vid.x = 75;
				_vid.y = 63;
				_plate.addChild(_vid);
			
				_thumbSelector = new ThumbSelector();
				_thumbSelector.x = 75;
				_thumbSelector.y = 444;
				_plate.addChild(_thumbSelector);
			
			_thumbSelector.setThumbsUsingVideoVos(_videoVos);
		}
		
		private function initVideoVos():void
		{
			var i:int;
			
			// get all video vo's
			
			var xml:XML = ContentModel.gi.enforcerData;
			var allVideoVos:Array = [];
			for (i = 0; i < xml.videos[0].video.length(); i++)
			{
				var vo:VideoVo = VideoVo.fromXml( xml.videos[0].video[i]) ;
				allVideoVos.push(vo);
			}
			
			// get index of correct 'order' node by timestamp
			// 'order' nodes expected to be in reverse chronological order!

			/*
			var target:Date = new Date();
			target.setMonth(8-1);
			target.setDate(13);
			target.setFullYear(2012);
			target.setHours(0,0,0,0);
			trace('target', target.time);
			*/
			
			var nowEpochTime:Number = new Date().time;
			var orderIndex:int = -1;
			_videoVos = [];
			_placementImageUrl = "";

			for (i = 0; i < xml.orders[0].order.length(); i++)
			{
				var order:XML = xml.orders[0].order[i];
				var epochTime:Number = order.@startEpochTime; 
				
				// sanity check:
				var date:Date = new Date();
				date.setTime(epochTime);
				var diff:Number = date.time - nowEpochTime;
				Out.i("Enforcer.initVideoVos() - order node " + i + " - " + date.toString() + " - time from now in days: ", diff/(1000*60*60*24));

				var isInThePast:Boolean = (diff < 0); 
				if (isInThePast) // hit 
				{ 
					var s:String = order.@ids;
					var ids:Array = s.split(",");
					Out.i('Enforcer.initVideoVos() - HIT - ids:', ids, 'placementImageUrl', _placementImageUrl);
					_placementImageUrl = order.@placementImageUrl;

					// add the videovo's in order by id 
					for (i = 0; i < ids.length; i++) 
					{
						var videoVo:VideoVo;
						var id:String = ids[i];
						for each (var v:VideoVo in allVideoVos) {
							if (v.id == id) {
								videoVo = v;
								break;
							}
						}
						if (! videoVo) {
							Out.w("NO MATCH FOR ID " + id);
						}
						else {
							_videoVos.push(videoVo);
							Out.d('added', videoVo.id);
						}
					}
					
					break;
				}
			}
		}
		
		public override function show(duration:Number=0, delay:Number=0):void
		{
			super.show(duration,delay);

			_shareButton.addEventListener(Event.SELECT, onButtonShare);
			_getUrlButton.addEventListener(Event.SELECT, onGetUrlButton);
			this.addEventListener(Event.SELECT, onThumbButtonSelect); // bubbs
			
			_vid.activate();
			
			// select-but-don't-play #0
			selectVideoByVideoVo(_videoVos[0], true);
			_thumbSelector.reset();
			
			Metrics.pageView("enforcer");
		}
		
		public override function hide(duration:Number=0, delay:Number=0):void
		{
			super.hide(duration,delay);

			_shareButton.removeEventListener(Event.SELECT, onButtonShare);
			_getUrlButton.removeEventListener(Event.SELECT, onGetUrlButton);
			
			_vid.deactivate();
		}

		private function selectVideoByVideoVo($videoVo:VideoVo, $dontAutoPlay:Boolean=false):void
		{
			_selectedVideoVo = $videoVo;
			
			_thumbSelector.selectByVideoVo(_selectedVideoVo);
			
			_tfVideoTitle.text = _selectedVideoVo.topTitle;
			
			_vid.play(_selectedVideoVo, $dontAutoPlay); 
			
			Metrics.pageView("enforcerVideo", "[VIDEO_NUM]", (_videoVos.indexOf(_selectedVideoVo)+1).toString());
		}
		
		private function onGetUrlButton(e:*):void
		{
			if (ConfigModel.gi.isPressPreview) return;
			
			System.setClipboard(_selectedVideoVo.facebookShareUrl);
			Main.instance.showToastWithCopyDto(ContentModel.gi.getCopyItemByName("toastGetUrl"));
			
			Metrics.pageView("enforcerVideoGetUrlButton", "[VIDEO_NUM]", (_videoVos.indexOf(_selectedVideoVo)+1).toString());
		}
		
		private function onButtonShare(e:*):void
		{
			if (ConfigModel.gi.isPressPreview) return;
			
			Metrics.pageView("enforcerVideoShareButton", "[VIDEO_NUM]", (_videoVos.indexOf(_selectedVideoVo)+1).toString());
			
			var o:Object = { 
				link: _selectedVideoVo.facebookShareUrl,
				name: _selectedVideoVo.facebookShareTitle,
				caption: _selectedVideoVo.facebookShareCaption,
				description: _selectedVideoVo.facebookShareDescription
			};
			_fb.doEnforcerShare(o);
		}
		
		private function onThumbButtonSelect($e:Event):void
		{
			var thumbButton:ThumbButton = $e.target as ThumbButton;
			if (! thumbButton) return;
			
			selectVideoByVideoVo(thumbButton.videoVo);
		}
	}
}
