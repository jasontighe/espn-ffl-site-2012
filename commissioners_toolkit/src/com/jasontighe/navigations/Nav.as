package com.jasontighe.navigations {	import com.jasontighe.containers.DisplayContainer;	public class Nav extends DisplayContainer implements INav	{				private static var _instance:Nav;		protected var _items : Array = new Array( );		protected var _activeIndex : int = -1;					protected var _activeItem : INavItem;							public function Nav()		{			_instance = this;		}				// eh heh		public static function get instance():Nav		{			return _instance;		}						public function enable () : void		{				var i : int = 0;			var l : int = _items.length;						for ( i; i < l ; i++ ) getItemAt( i ).enable( );		}		public function disable () : void		{				var i : int = 0;			var l : int = _items.length;						for ( i; i < l ; i++ ) getItemAt( i ).disable( );		}		public function reset () : void		{			if ( _activeIndex != -1 )			{				getItemAt( _activeIndex ).deactivate( );				_activeItem = null;				_activeIndex = -1;			}		}		public function add ( item : INavItem ) : void		{						_items.push( item );		}		public function setIndices () : void		{			var i : int = 0;			var l : int = _items.length;						for ( i; i < l ; i++ ) INavItem( getItemAt( i ) ).setIndex( i );		}		public function getItemAt ( index : uint ) : INavItem		{			return _items[ index ];		}		public function addItemAt ( item : INavItem, index : uint ) : void		{			_items.splice( index, 0, item );		}		public function removeItem ( item : INavItem ) : void		{			var i : int = 0;			var l : int = _items.length;						for ( i; i < l ; i++ ) if ( item == INavItem( _items[ i ] ) ) _items.splice( i, 1 );		}		public function setItemTop () : INavItem		{						var item : INavItem = _items.shift( );			_items.push( item );			return item;				}			public function setItemBottom () : INavItem		{						var item : INavItem = _items.pop( );			_items.unshift( item );				return item;				}			public function getItems () : Array		{			return _items.slice( );		}		public function setItems ( value : Array ) : void		{			_items = value;		}			public function getActiveItem ( ) : INavItem		{			return getItemAt( _activeIndex );		}			public function setActiveItem ( item : INavItem ) : void 		{			if ( _activeIndex != item.getIndex() && _activeIndex != -1 ) getItemAt(_activeIndex).deactivate();			_activeIndex = item.getIndex( );			getItemAt( _activeIndex ).activate( );					}		public function setActiveIndex ( index : int ) : void		{			setActiveItem( getItemAt( index ) );		}			public function getActiveIndex () : int		{			return _activeIndex;		}			public function get length () : uint		{			return _items.length;		}		}}