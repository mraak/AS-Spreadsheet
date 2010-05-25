package com.flextras.spreadsheet.context
{
import com.flextras.paintgrid.CellProperties;

import flash.display.InteractiveObject;
import flash.events.ContextMenuEvent;
import flash.ui.ContextMenuItem;

import mx.managers.PopUpManager;

/**
 * This is the default context menu for the Flextras Spreadsheet.  It is used on a cell when the cell is not in edit mode. 
 * 
 * @see com.flextras.spreadsheet.Spreadsheet
 */
public class GlobalContextMenu extends Menu
{

	/**
	 * This represents the context menu item which will bring up the popup for editing Global Styles. 
	 */
	protected const setGlobalStyles : ContextMenuItem = new ContextMenuItem("Global Styles", true);
	
	/**
	 * This represents a popup window that is displayed based on certain selections.
	 */
	protected var popup : BasePopup;
	
	/**
	 * This property represents the cell in question.
	 */
	public var cell : CellProperties;
	
	/**
	 * This is the default handler for setting styles returned from the Global Styles popup.  
	 * @see com.flextras.spreadsheet.context.StylesPopup 
	 */
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
	
	/**
	 * @inheritDoc
	 */
	override public function set enabled (value : Boolean) : void
	{
		super.enabled = value;
		
		setGlobalStyles.enabled = value;
	}
	
	/**
	 * @inheritDoc
	 */
	override public function setContextMenu (component : InteractiveObject) : void
	{
		super.setContextMenu(component);
		
		setGlobalStyles.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, setGlobalStylesHandler);
		
		menu.customItems = [setGlobalStyles, addRow, addColumn];
	}
	
	/**
	 * @inheritDoc
	 */
	override public function unsetContextMenu (component : InteractiveObject) : void
	{
		super.unsetContextMenu(component);
		
		setGlobalStyles.removeEventListener(ContextMenuEvent.MENU_ITEM_SELECT, setGlobalStylesHandler);
	}
}
}