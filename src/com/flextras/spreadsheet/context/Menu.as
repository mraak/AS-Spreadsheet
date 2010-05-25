package com.flextras.spreadsheet.context
{
import com.flextras.paintgrid.IPaintGridItemRenderer;
import com.flextras.spreadsheet.Spreadsheet;
import com.flextras.spreadsheet.SpreadsheetItemRenderer;

import flash.display.InteractiveObject;
import flash.events.ContextMenuEvent;
import flash.events.Event;
import flash.ui.ContextMenu;
import flash.ui.ContextMenuItem;

import mx.controls.IFlexContextMenu;

/**
 * This is a base class for context menu's of the Flextras Spreadsheet. 
 * @see com.flextras.spreadsheet.Spreadsheet
 */
public class Menu implements IFlexContextMenu
{
	/**
	 * 
	 */
	protected var menu : ContextMenu;
	
	/**
	 * 
	 */
	protected static const defaultMenu : ContextMenu = new ContextMenu;
	
	/**
	 * 
	 */
	protected var clipboard : ClipboardData;
	
	/**
	 * This is an internal variable for the context menu item that will add a row to the Spreadsheet.
	 */
	protected const addRow : ContextMenuItem = new ContextMenuItem("Insert Row", true);
	
	/**
	 * This is an internal variable for the context menu item that will add a column to the Spreadsheet.
	 */
	protected const addColumn : ContextMenuItem = new ContextMenuItem("Insert Column", true);
	
	/**
	 * Constructor.
	 */
	public function Menu ()
	{
		defaultMenu.hideBuiltInItems();
		
		clipboard = ClipboardData.instance;
	}
	
	/**
	 * @private
	 */
	protected var _owner : Spreadsheet;
	
	/**
	 * @copy mx.core.IVisualElement#owner
	 */
	public function get owner () : Spreadsheet
	{
		return _owner;
	}
	
	/**
	 * @private  
	 */
	public function set owner (value : Spreadsheet) : void
	{
		if (_owner === value)
			return;
		
		if (_owner)
			_owner.removeEventListener("contextMenuEnabledChanged", contextMenuEnabledHandler);
		
		_owner = value;
		
		if (value)
			_owner.addEventListener("contextMenuEnabledChanged", contextMenuEnabledHandler);
	}
	
	/**
	 * @private
	 */
	private var _target : InteractiveObject;
	
	/**
	 * This is the object will contain the ContextMenu.  
	 */
	public function get target () : InteractiveObject
	{
		return _target;
	}
	
	/**
	 * @private  
	 */
	public function set target (value : InteractiveObject) : void
	{
		if (_target === value)
			return;
		
		_target = value;
		
		if (value is Spreadsheet)
			owner = Spreadsheet(value);
		else if (value is IPaintGridItemRenderer)
			owner = Spreadsheet(IPaintGridItemRenderer(value).dataGrid);
		
		menu = new ContextMenu();
		menu.hideBuiltInItems();
		
		value.contextMenu = menu;
	}
	
	/**
	 * This is the default handler for the add row context menu item.
	 */
	protected function addRowHandler (e : ContextMenuEvent) : void
	{
		owner.insertRowAt(0);
	}
	
	/**
	 * This is the default handler for the add column context menu item.
	 */
	protected function addColumnHandler (e : ContextMenuEvent) : void
	{
		owner.insertColumnAt(0);
	}
	
	/**
	 * @private
	 */
	protected var _enabled : Boolean;
	
	/**
	 * @copy mx.core.IUIComponent#enabled
	 */
	public function get enabled () : Boolean
	{
		return _enabled;
	}
	
	/**
	 * @private  
	 */
	public function set enabled (value : Boolean) : void
	{
		_enabled = value;
		
		addRow.enabled = value;
		addColumn.enabled = value;
	}
	
	/**
	 * @inheritDoc
	 */
	public function setContextMenu (component : InteractiveObject) : void
	{
		target = component;
		
		addRow.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, addRowHandler);
		addColumn.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, addColumnHandler);
		clipboard.addEventListener("allowPasteChanged", allowPasteChangedHandler);
	}
	
	/**
	 * @inheritDoc
	 */
	public function unsetContextMenu (component : InteractiveObject) : void
	{
		menu.customItems = null;
		
		addRow.removeEventListener(ContextMenuEvent.MENU_ITEM_SELECT, addRowHandler);
		addColumn.removeEventListener(ContextMenuEvent.MENU_ITEM_SELECT, addColumnHandler);
		clipboard.removeEventListener("allowPasteChanged", allowPasteChangedHandler);
	}
	
	/**
	 * 
	 */
	protected function allowPasteChangedHandler (e : Event) : void
	{
	
	}
	
	/**
	 * 
	 */
	protected function contextMenuEnabledHandler (e : Event) : void
	{
		if (target && owner)
			target.contextMenu = owner.contextMenuEnabled ? menu : defaultMenu;
	}
}
}