package com.jasontighe.utils 
{
	import flash.display.MovieClip;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;

	/**
	 * @author agorskiy
	 */
	public class RightClickVersion 
	{
		private var version_menu					: ContextMenu;
		private var version_menu_item				: ContextMenuItem;
		
		public function RightClickVersion( theThis : MovieClip, str : String )
		{
			version_menu = new ContextMenu();
			version_menu_item = new ContextMenuItem(""+str);
			
			version_menu.hideBuiltInItems();
			version_menu.customItems.push(version_menu_item);
			
			theThis.contextMenu = version_menu;
		}
		
	}
}