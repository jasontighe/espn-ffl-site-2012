package com.espn.ffl.views.inviter.views {
	import com.espn.ffl.constants.SiteConstants;
	import com.espn.ffl.util.Assets;
	import com.espn.ffl.util.FflButtonText;
	import com.espn.ffl.util.FflDropShadow;
	import com.greensock.TweenLite;
	import com.jasontighe.managers.AssetManager;
	
	import flash.display.Bitmap;
	import flash.display.GradientType;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filters.GlowFilter;
	import flash.geom.Matrix;
	import flash.text.TextField;
	
	import leelib.ui.ThreeStateButton;

	public class FflRecordButton 
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
		
		private var _overHolder :  Sprite;
		
		private var _tf:TextField;
		
		private var _isEnabled:Boolean;

		public function FflRecordButton( $label:String, $width:Number, $height:Number )
		{
			_background = MovieClip( AssetManager.gi.getAsset( "GrayButtonAsset", SiteConstants.ASSETS_ID ) );
			_over = _background._over;
			_out = _background._out;
			_over.width = _out.width = $width;
			_over.height = _out.height = $height;
			addChild( _background );
			
			_overHolder = new Sprite();
			_overHolder.addChild( _over );
			_overHolder.alpha = 0;
			
			var tf : TextField
			// This is out text
			tf = FflButtonText.makeText( $label, ".redButtonText", 26);
			var x_offset : uint = 14;
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
			var circle : MovieClip;
			var colorTop : uint;
			var colorBottom : uint;
			var matrix : Matrix;
			
			// This is out circle
			circle = new MovieClip();
			var radius : uint = 8;
			colorTop = 0xb63836;
			colorBottom = 0xe76d6a;
			matrix = new Matrix();
			matrix.createGradientBox( radius * 2, radius *2, -90, -radius, -radius );
			circle.graphics.beginGradientFill( GradientType.LINEAR, [ colorTop, colorBottom ], [ 1, 1 ], [ 0, 255 ], matrix );
			circle.graphics.drawCircle( 0, 0, radius );
			circle.x = 30;
			circle.y = 23;
			addChild( circle );
			circle.filters = [ new GlowFilter( 0xe9452e, .75, 6.0, 6.0, 2, 3, false, false ) ];
			
			// This is over circle
			circle = new MovieClip();
			colorTop = 0xFFFFFF;
			colorBottom = 0xFFFFFF;
			matrix = new Matrix();
			matrix.createGradientBox( radius * 2, radius *2, -90, -radius, -radius );
			circle.graphics.beginGradientFill( GradientType.LINEAR, [ colorTop, colorBottom ], [ 1, 1 ], [ 0, 255 ], matrix );
			circle.graphics.drawCircle( 0, 0, radius );
			circle.x = 30;
			circle.y = 23;
			_overHolder.addChild( circle );
			*/
			
			var b:Bitmap = new Assets.RedLightOff();
			b.x = 10;
			b.y = 5;
			this.addChild(b);
			
			b = new Assets.RedLightOn();
			b.x = 10;
			b.y = 5;
			_overHolder.addChild(b);
			
			addChild( _overHolder );
			
			filters = [ FflDropShadow.getDefault() ];
			
			super();
		}

		protected override function showUnselectedOut():void
		{
			TweenLite.to( _overHolder, SiteConstants.TIME_OUT, { alpha:0 } );
		}
		
		protected override function showUnselectedOver():void
		{
			TweenLite.to( _overHolder, SiteConstants.TIME_OVER, { alpha:1 } );
		}
		
		protected override function showSelected():void
		{
			showUnselectedOver();
		}
	}
}
