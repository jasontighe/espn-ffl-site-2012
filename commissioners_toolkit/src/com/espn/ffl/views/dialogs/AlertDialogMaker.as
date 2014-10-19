package com.espn.ffl.views.dialogs
{
	import com.espn.ffl.model.ContentModel;
	import com.espn.ffl.util.Assets;
	import com.espn.ffl.views.AbstractView;
	import com.espn.ffl.views.BubbleButton;
	import com.espn.ffl.views.FflButton;
	import com.espn.ffl.views.Main;
	
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	import leelib.graphics.GrUtil;
	import leelib.graphics.Scale9BitmapSprite;
	import leelib.ui.ThreeStateButton;
	import leelib.util.TextFieldUtil;

	
	public class AlertDialogMaker extends AbstractView 
	{
		public function AlertDialogMaker()
		{
		}
		
		// ugly signature
		//
		public static function make($useCloseButton:Boolean, $title:String, $copy:String, $yesLabel:String, $noLabel:String, 
									$yesButtonCallback:Function=null, $noButtonCallback:Function=null, $closeButtonCallback:Function=null,
									$width:Number=400, $extra:DisplayObject = null) : AbstractDialog
		{
			// Note, the created dialog's listeners are here, in AlertDialog! 
			
			// scale9-related offset logic here is a nightmare

			var dialog:AbstractDialog = new AbstractDialog();
			dialog.yesButtonCallback = $yesButtonCallback;
			dialog.noButtonCallback = $noButtonCallback;
			dialog.closeButtonCallback = $closeButtonCallback;

			var r:Rectangle = new Rectangle(22,29, 340,160);
			var b:BitmapData = $useCloseButton ? new Assets.DialogBgWithX().bitmapData : new Assets.DialogBg().bitmapData;
			var bg9:Scale9BitmapSprite = new Scale9BitmapSprite(b, r);
			dialog.addChild(bg9);
			
			b = $useCloseButton ? new Assets.DialogBgWithXRed9().bitmapData : new Assets.DialogBgRed().bitmapData; 
			var redBg9:Scale9BitmapSprite = new Scale9BitmapSprite(b, r);
			redBg9.visible = false;
			dialog.addChild(redBg9);
			
			dialog.redBackground = redBg9;

			var holder:Sprite = new Sprite();
			holder.x = 25;
			holder.y = 25;
			dialog.addChild(holder);

				var buttonYes:ThreeStateButton;
				var buttonNo:ThreeStateButton;
				var tfTitle:TextField;
				var tfCopy:TextField;
				var extra:DisplayObject;
	
				var y:Number = 10;
				
				tfTitle = TextFieldUtil.makeText($title.toUpperCase(), ".alertDialogTitle");
				tfTitle.x = 0;
				tfTitle.y = 10;
				holder.addChild(tfTitle);
				
				y += tfTitle.textHeight + 7;
				
				tfCopy = TextFieldUtil.makeHtmlText($copy, ".alertDialogCopy", $width - holder.x*2);
				tfCopy.x = 0;
				tfCopy.y = y;
				holder.addChild(tfCopy);
	
				y += tfCopy.textHeight + 20;
				
				if (extra) {
					extra.x = 10;
					extra.y = y;
					holder.addChild(extra);
					y += extra.height + 10;
				}

				if ($yesLabel || $noLabel)
				{
					var buttonHolder:Sprite = new Sprite();
					buttonHolder.y = y;
					holder.addChild(buttonHolder);
					
					if ($noLabel && $noLabel.length > 0)
					{
						buttonNo = new BubbleButton($noLabel, NaN, true); // note, no-button is gray; goes on left
						buttonNo.x = 0;
						buttonHolder.addChild(buttonNo);
					}
					
					buttonYes = new BubbleButton($yesLabel);
					buttonYes.x = buttonNo  ?  buttonNo.x + buttonNo.width + 25  :  0;
					buttonHolder.addChild(buttonYes);
					
					// center buttonholder
					buttonHolder.x = ($width - buttonHolder.width) * .5  -  27;
					
					y += buttonYes.height;
				}
				else
				{
					// no buttons at all, ie, a toast:

					if (! $title || $title.length == 0) {
						// center copy text
						tfCopy.styleSheet = null;
						var f:TextFormat = new TextFormat();
						f.align = "center";
						tfCopy.setTextFormat(f);
					}
					
					y -= 12;
				}
				
			var close:Sprite;
			if ($useCloseButton)
			{
				close = GrUtil.makeCircle(15, 0xff0000, 0.0);
				close.x = $width + 2;
				close.y = 17;
				close.buttonMode = true;
				dialog.addChild(close);
			}
			
			bg9.width = $width + 30;
			bg9.height = holder.y + y + holder.y + 15;

			redBg9.width = $width + 30;
			redBg9.height = holder.y + y + holder.y + 15;
			
			dialog.dialogWidth = $width;
			dialog.dialogHeight = y + 30;

			dialog.assignButtons(buttonYes, buttonNo, close);
			dialog.tfCopy = tfCopy;
			
			return dialog;
		}
		
		
		// Duplicates lots of stuff from make()
		// New requirements make this no longer necessary. But keeping it rather than refactoring.
		//
		public static function makeNotLoggedInPageDialog($title:String, $copy:String, $yesLabel:String,  
									$yesButtonCallback:Function=null, $width:Number=400) : AbstractDialog
		{
			var dialog:AbstractDialog = new AbstractDialog();
			dialog.yesButtonCallback = $yesButtonCallback;
			dialog.closeButtonCallback = null;
			
			var r:Rectangle = new Rectangle(22,29, 340,160);
			var b:BitmapData = new Assets.DialogBgWithX().bitmapData;
			var bg9:Scale9BitmapSprite = new Scale9BitmapSprite(b, r);
			dialog.addChild(bg9);
			
			b = new Assets.DialogBgWithXRed9().bitmapData; 
			var redBg9:Scale9BitmapSprite = new Scale9BitmapSprite(b, r);
			redBg9.visible = false;
			dialog.addChild(redBg9);
			
			dialog.redBackground = redBg9;
			
			var holder:Sprite = new Sprite();
			holder.x = 25;
			holder.y = 25;
			dialog.addChild(holder);
			
			var buttonYes:ThreeStateButton;
			var buttonNo:ThreeStateButton;
			var tfTitle:TextField;
			var tfCopy:TextField;
			
			var y:Number = 10;
			
			tfTitle = TextFieldUtil.makeText($title.toUpperCase(), ".alertDialogTitle");
			tfTitle.x = 0;
			tfTitle.y = 10;
			holder.addChild(tfTitle);
			
			y += tfTitle.textHeight + 7;
			
			tfCopy = TextFieldUtil.makeHtmlText($copy, ".alertDialogCopy", $width - holder.x*2);
			tfCopy.x = 0;
			tfCopy.y = y;
			holder.addChild(tfCopy);
			
			y += tfCopy.textHeight + 30;
			
			var buttonHolder:Sprite = new Sprite();
			buttonHolder.y = y;
			holder.addChild(buttonHolder);
			
			buttonYes = new BubbleButton($yesLabel);
			buttonYes.x = buttonNo  ?  buttonNo.x + buttonNo.width + 25  :  0;
			buttonHolder.addChild(buttonYes);
			
			// center buttonholder
			buttonHolder.x = ($width - buttonHolder.width) * .5  -  23;
			
			y += buttonYes.height + 8;

			/*
			var extraLink:Sprite = new Sprite();
			extraLink.buttonMode = true;
			extraLink.addEventListener(MouseEvent.CLICK, $extraLinkClickCallback, false,0,true);
			var s:String = ContentModel.gi.getCopyItemByName("alertNotLoggedInPageCommissionerText").copy;
			var tf:TextField = TextFieldUtil.makeText(s, ".alertDialogCommissionersClickHere");
			extraLink.addChild(tf);
			extraLink.graphics.lineStyle(1, 0x0, 0.33);
			extraLink.graphics.moveTo(0,tf.height+1);
			extraLink.graphics.lineTo(tf.width,tf.height+1);
			extraLink.x = ($width - extraLink.width) * .5  -  27;
			extraLink.y = y;
			holder.addChild(extraLink);
			
			y += extraLink.height;
			*/
			
			var close:Sprite;
			close = GrUtil.makeCircle(15, 0xff0000, 0.0);
			close.x = $width + 2;
			close.y = 17;
			close.buttonMode = true;
			dialog.addChild(close);
			
			bg9.width = $width + 30;
			bg9.height = holder.y + y + holder.y + 11;
			
			redBg9.width = $width + 30;
			redBg9.height = holder.y + y + holder.y + 11;
			
			dialog.dialogWidth = $width;
			dialog.dialogHeight = y + 30;
			
			dialog.assignButtons(buttonYes, null, close);
			dialog.tfCopy = tfCopy;
			
			return dialog;
		}
	}
}
