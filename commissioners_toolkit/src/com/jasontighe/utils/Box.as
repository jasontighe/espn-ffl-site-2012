package com.jasontighe.utils {
	import flash.display.Shape;
	import flash.display.Sprite;

	/**
	 * @author jsuntai
	 */
	public class Box 
	extends Sprite 
	{
		
		//----------------------------------------------------------------------------
		// protected constants
		//----------------------------------------------------------------------------
		protected static const	DEFAULT_WIDTH		: uint = 100;
		protected static const	DEFAULT_HEIGHT		: uint = 100;
		protected static const	DEFAULT_COLOR		: uint = 0xFF0032;
		
		//----------------------------------------------------------------------------
		// protected variables
		//----------------------------------------------------------------------------
		protected var _w							: uint;
		protected var _h							: uint;
		protected var _id							: uint;
		
		//----------------------------------------------------------------------------
		// public variables
		//----------------------------------------------------------------------------
		public var _shape							: Shape;
		
		
		//----------------------------------------------------------------------------
		// constructor
		//----------------------------------------------------------------------------
		public function Box(	w : uint = DEFAULT_WIDTH,
							 	h : uint = DEFAULT_HEIGHT,
							 	color : uint = DEFAULT_COLOR ) 
		{
			buttonMode = false;
			mouseEnabled = false;
			useHandCursor = false;
			
			setW( w );
			setH( h );
			
			_shape = getShape( w, h, color);
			addChild( _shape );
		}
		
		
		//----------------------------------------------------------------------------
		// protected methods
		//----------------------------------------------------------------------------
		protected function getShape( w : uint, h : uint, color : uint ) : Shape
		{
			var shape : Shape = new Shape();
			shape.graphics.beginFill( color );
			shape.graphics.drawRect( 0, 0, w, h );
			shape.graphics.endFill();
			return shape;
		}
		
		
		//----------------------------------------------------------------------------
		// getters / setters
		//----------------------------------------------------------------------------
		public function getW( ) : uint
		{
			return _w;
		}
		
		public function setW( n : uint ) : void
		{
			_w = n;
		}

		public function getH( ) : uint
		{
			return _h;
		}
		
		public function setH( n : uint ) : void
		{
			_h = n;
		}

		public function get id( ) : uint
		{
			return _id;
		}
		public function set id( n : uint ) : void
		{
			_id = n;
		}
	}
}