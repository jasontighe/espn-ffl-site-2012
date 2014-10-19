package com.espn.ffl.views.header
{
	import com.espn.ffl.util.Assets;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.text.TextField;
	
	import leelib.ui.ThreeStateButton;
	import leelib.ui.TwoImageButton;
	import leelib.util.TextFieldUtil;
	
	public class SettingsButtn extends TwoImageButton
	{
		public function SettingsButtn()
		{
			var b:Bitmap;
			var tf:TextField;
			
			var off:Sprite = new Sprite();
			
				tf = TextFieldUtil.makeText("SHARE SETTINGS", ".settingsButton");
				tf.x = 0;
				tf.y = 4;
				off.addChild(tf);
			
				b = new Assets.SettingsButton();
				b.x = tf.width + 2;
				b.y = 0;
				off.addChild(b);
				
			var over:Sprite = new Sprite();
				
				tf = TextFieldUtil.makeText("SHARE SETTINGS", ".settingsButtonOver");
				tf.x = 0;
				tf.y = 4;
				over.addChild(tf);
				
				b = new Assets.SettingsButtonOver();
				b.x = tf.width + 2;
				b.y = 0;
				over.addChild(b);
				
			super(off, over, OVERTREATMENT_SWAP);
		}
	}
}