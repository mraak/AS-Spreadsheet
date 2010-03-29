package com.flextras.spreadsheet.context
{
import com.flextras.paintgrid.CellProperties;

import flash.display.InteractiveObject;
import flash.events.ContextMenuEvent;
import flash.ui.ContextMenuItem;

import mx.managers.PopUpManager;

public class GlobalContextMenu extends Menu
{
	protected const setGlobalStyles : ContextMenuItem = new ContextMenuItem("Global Styles", true);
	
	protected var popup : BasePopup;
	
	public var cell : CellProperties;
	
	protected function setGlobalStylesHandler (e : ContextMenuEvent) : void
	{
		if (popup)
			PopUpManager.removePopUp(popup);
		
		popup = new StylesPopup();
		popup.grid = owner;
		
		PopUpManager.addPopUp(popup, owner);
		PopUpManager.centerPopUp(popup);
		
		StylesPopup(popup).cell = owner.globalCellStyles;
	}
	
	override public function set enabled (value : Boolean) : void
	{
		super.enabled = value;
		
		setGlobalStyles.enabled = value;
	}
	
	override public function setContextMenu (component : InteractiveObject) : void
	{
		super.setContextMenu(component);
		
		setGlobalStyles.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, setGlobalStylesHandler);
		
		menu.customItems = [setGlobalStyles, addRow, addColumn];
	}
	
	override public function unsetContextMenu (component : InteractiveObject) : void
	{
		super.unsetContextMenu(component);
		
		setGlobalStyles.removeEventListener(ContextMenuEvent.MENU_ITEM_SELECT, setGlobalStylesHandler);
	}
}
}