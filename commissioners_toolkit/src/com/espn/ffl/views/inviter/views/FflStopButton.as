package com.espn.ffl.views.inviter.views {
	import com.espn.ffl.constants.SiteConstants;
	import com.espn.ffl.util.Assets;
	import com.espn.ffl.util.FflButtonText;
	import com.espn.ffl.util.FflDropShadow;
	import com.greensock.TweenLite;
	import com.jasontighe.managers.AssetManager;
	import com.jasontighe.utils.Box;
	
	import flash.display.Bitmap;
	import flash.display.GradientType;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
	import flash.text.TextField;
	import flash.utils.setTimeout;
	
	import leelib.ui.ThreeStateButton;

	public class FflStopButton 
	extends ThreeStateButton
	{
		public static const BACKGROUNDTYPE_GREEN:uint = 0;
		public static const BACKGROUNDTYPE_GRAY:uint = 1;
		public static const BACKGROUNDTYPE_RED:uint = 2;
		public static const BACKGROUNDTYPE_BLUE:uint = 3;

		private static const OUTERRECT_THICKNESS:Number = 3.0;
		
		private var _gradient:Bitmap;
		private var _gradientOver:Bitmap;
		
		private var _over : MovieClip;
		private var _out : MovieClip;
		private var _background : MovieClip;
		
		private var _overHolder : MovieClip;
		
		private var _blinker:Bitmap;
		
		private var _tf:TextField;
		
		private var _isEnabled : Boolean;

		
		
		public function FflStopButton( $label:String, $width:Number, $height:Number )
		{
			_background = MovieClip( AssetManager.gi.getAsset( "GrayButtonAsset", SiteConstants.ASSETS_ID ) );
			_over = _background._over;
			_out = _background._out;
			_over.width = _out.width = $width;
			_over.height = _out.height = $height;
			addChild( _background );
			
			_overHolder = new MovieClip();
			_overHolder.addChild( _over );
			_overHolder.alpha = 0;
			
			var tf : TextField
			// This is out text
			tf = FflButtonText.makeText( $label, ".redButtonText", 26);
			var x_offset : uint = 11;
			var y_offset : uint = 1;
			tf.x = int( ($width - tf.width) * 0.5 ) + x_offset;
			tf.y = int( ($height - tf.height) * 0.5 ) + y_offset;
			addChild( tf );
			
			// This is over text
			tf = FflButtonText.makeText( $label, ".whiteButtonText", 26 );
			tf.x = int( ($width - tf.width) * 0.5 ) + x_offset;
			tf.y = int( ($height - tf.height) * 0.5 ) + y_offset;
			_overHolder.addChild( tf );
			
			/*
			var box : Shape;
			var colorTop : uint;
			var colorBottom : uint;
			var matrix : Matrix;
			// This is out box
			blinkingBox = new Shape();
			var size : uint = 16;
			matrix = new Matrix();
			
			var b : Box = new Box( size, size, 0x515151 );
			b.x = 36;
			b.y = 16;
			addChild( b );
			
			
			matrix.createGradientBox( size, size, -90) ;
			blinkingBox.graphics.lineStyle();			
			blinkingBox.graphics.beginGradientFill( GradientType.LINEAR,[ 0xb63836, 0xe76d6a ], [ 1, 1 ], [ 0, 255 ], matrix );
			blinkingBox.graphics.drawRect( 0, 0, size ,size );
			blinkingBox.graphics.endFill();		
			blinkingBox.x = 36;
			blinkingBox.y = 16;
			addChild( blinkingBox );
			blinkingBox.filters = [ new GlowFilter( 0xe9452e, .75, 6.0, 6.0, 2, 3, false, false ) ];
			
			// This is over box
			b = new Box( size, size, 0xFFFFFF );
			b.x = 36;
			b.y = 16;
			_overHolder.addChild( b );
			*/
			
			var b:Bitmap = new Assets.RedLightOff();
			b.x = 10;
			b.y = 5;
			this.addChild(b);
			
			b = new Assets.RedLightOff();
			b.x = 10;
			b.y = 5;
			b.alpha = 1;
			_overHolder.addChild(b);
			
			addChild( _overHolder );

			
			_blinker = new Assets.RedLightOn();
			_blinker.x = 10;
			_blinker.y = 5;
			_blinker.alpha = 0;
			this.addChild(_blinker);
			
			
			filters = [ FflDropShadow.getDefault() ];

			super();
			
//			isSelected = true;
//			startBlinking();
		}
		
//		public function doActive() : void
//		{
//			startBlinking();
//		}
//		
//		public function doDeactive() : void
//		{
//			stopBlinking();
//		}

		public function startBlinking():void
		{
//			trace( "FFLSTOPBUTTON : startBlinking() : _isSelected is "+_isSelected)
			if( !_isSelected )
			{
				var time : uint = 1000;
//				if( !blinkingBox.visible)	time = 500;
				var to : uint = setTimeout( blink, time );
			}
		}


		protected function blink():void
		{
			var a :uint = 0;
			var time :Number = SiteConstants.TIME_OVER;
			
			if( _blinker.alpha == 0 )
			{
				a = 1;
				time = SiteConstants.TIME_OUT;
			}
			
			TweenLite.to( _blinker, time, { alpha: a } );
			startBlinking();
		}

		protected override function showUnselectedOut():void
		{
//			_tf.filters = [ new DropShadowFilter(1.0,45,0x0,0.33,1.0,1.0,2,2) ];
			TweenLite.to( _overHolder, SiteConstants.TIME_OUT, { alpha:0 } );
		}
		
		protected override function showUnselectedOver():void
		{
//			_tf.filters = [ new DropShadowFilter(1.0,33,0x0,0.33,0,0,1,2,  true) ];
			TweenLite.to( _overHolder, SiteConstants.TIME_OVER, { alpha:1 } );
		}
		
		protected override function showSelected():void
		{
			showUnselectedOver();
//			isSelected = true;
		}
	}
}
