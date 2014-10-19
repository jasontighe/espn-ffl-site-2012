package com.jasontighe.managers {
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.utils.Dictionary;

	/**
	 * @author jason.tighe
	 */
	public class AssetManager 
	{
		//----------------------------------------------------------------------------
		// private static variables
		//----------------------------------------------------------------------------
		private static var _instance 						: AssetManager;
		//----------------------------------------------------------------------------
		// private variables
		//----------------------------------------------------------------------------
		private var _d : Dictionary;
		//----------------------------------------------------------------------------
		// constructor
		//----------------------------------------------------------------------------
		public function AssetManager( e : AssetManagerEnforcer ) { }
		
		//----------------------------------------------------------------------------
		// public methods
		//----------------------------------------------------------------------------
		public function add( id : String, asset : MovieClip) : void
		{
			if( !_d) _d = new Dictionary();
			if( !_d[ id ] )
			{
				_d[ id ] = asset;
			}
			else new Error( "THIS ASSET HAS ALREADY BEEN ADDED" );
		}
		
		//----------------------------------------------------------------------------
		// getters/setters
		//----------------------------------------------------------------------------
		public static function get gi() : AssetManager
		{
			if( !_instance ) _instance = new AssetManager( new AssetManagerEnforcer() );
			return _instance;
		}
		
		// ORIGINAL:
		/*
		public function getAsset( linkage : String, assetId : String = "assets" ) : Sprite
		{
			var c : Class = ( _d[ assetId ] as MovieClip ).loaderInfo.applicationDomain.getDefinition( linkage ) as Class;
			return Sprite( new c() );
		}
		*/
	
		public function getAsset( linkage : String, assetId : String = "assets" ) : *
		{
			var c : Class = ( _d[ assetId ] as MovieClip ).loaderInfo.applicationDomain.getDefinition( linkage ) as Class;
			
			var o : Object = new c();

			if (o is BitmapData) 
				return new Bitmap(o as BitmapData); 
			else
				return o;
		}
	}
}

class AssetManagerEnforcer{}