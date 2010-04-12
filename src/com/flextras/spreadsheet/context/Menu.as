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

public class Menu implements IFlexContextMenu
{
	protected var menu : ContextMenu;
	
	protected static const defaultMenu : ContextMenu = new ContextMenu;
	
	protected var clipboard : ClipboardData;
	
	protected const addRow : ContextMenuItem = new ContextMenuItem("Insert Row", true);
	
	protected const addColumn : ContextMenuItem = new ContextMenuItem("Insert Column", true);
	
	public function Menu ()
	{
		defaultMenu.hideBuiltInItems();
		
		clipboard = ClipboardData.instance;
	}
	
	protected var _owner : Spreadsheet;
	
	public function get owner () : Spreadsheet
	{
		return _owner;
	}
	
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
	
	private var _target : InteractiveObject;
	
	public function get target () : InteractiveObject
	{
		return _target;
	}
	
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
	
	protected function addRowHandler (e : ContextMenuEvent) : void
	{
		owner.insertRowAt(0);
	}
	
	protected function addColumnHandler (e : ContextMenuEvent) : void
	{
		owner.insertColumnAt(0);
	}
	
	protected var _enabled : Boolean;
	
	public function get enabled () : Boolean
	{
		return _enabled;
	}
	
	public function set enabled (value : Boolean) : void
	{
		_enabled = value;
		
		addRow.enabled = value;
		addColumn.enabled = value;
	}
	
	public function setContextMenu (component : InteractiveObject) : void
	{
		target = component;
		
		addRow.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, addRowHandler);
		addColumn.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, addColumnHandler);
		clipboard.addEventListener("allowPasteChanged", allowPasteChangedHandler);
	}
	
	public function unsetContextMenu (component : InteractiveObject) : void
	{
		menu.customItems = null;
		
		addRow.removeEventListener(ContextMenuEvent.MENU_ITEM_SELECT, addRowHandler);
		addColumn.removeEventListener(ContextMenuEvent.MENU_ITEM_SELECT, addColumnHandler);
		clipboard.removeEventListener("allowPasteChanged", allowPasteChangedHandler);
	}
	
	protected function allowPasteChangedHandler (e : Event) : void
	{
	
	}
	
	protected function contextMenuEnabledHandler (e : Event) : void
	{
		if (target && owner)
			target.contextMenu = owner.contextMenuEnabled ? menu : defaultMenu;
	}
}
}