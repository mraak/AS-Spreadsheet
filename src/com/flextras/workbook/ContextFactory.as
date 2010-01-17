package com.flextras.workbook
{
	import flash.events.ContextMenuEvent;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	import com.flextras.workbook.IFlexcelGridContext;
	
	public class ContextFactory
	{
		public function ContextFactory()
		{
			

		}
		
		public static function getGridCM(owner: IFlexcelGridContext):ContextMenu
		{
			var cm:ContextMenu = new ContextMenu();
			//cm.hideBuiltInItems();
			cm.addEventListener(ContextMenuEvent.MENU_SELECT, owner.cmSelect);
			
			var cmi:ContextMenuItem = new ContextMenuItem("Insert Column", true);
			cmi.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, owner.cmInsertColumn);
			
			cm.customItems.push(cmi);
			
			cmi = new ContextMenuItem("Insert Row", false);
			cmi.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, owner.cmInsertRow);
			
			cm.customItems.push(cmi);
			
			cmi = new ContextMenuItem("Delete Column", true);
			cmi.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, owner.cmDeleteColumn);
			
			cm.customItems.push(cmi);
			
			cmi = new ContextMenuItem("Delete Row", false);
			cmi.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, owner.cmDeleteRow);
			
			cm.customItems.push(cmi);
			
			cmi = new ContextMenuItem("Clear Column", true);
			cmi.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, owner.cmClearColumn);
			
			cm.customItems.push(cmi);
			
			cmi = new ContextMenuItem("Clear Row", false);
			cmi.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, owner.cmClearRow);
			
			cm.customItems.push(cmi);
			
			return cm;
		}
			

	}
}