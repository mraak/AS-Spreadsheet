package com.flextras.context
{
import com.flextras.paintgrid.PaintGrid;
import com.flextras.paintgrid.PaintGridItemRenderer;

import flash.display.InteractiveObject;
import flash.events.ContextMenuEvent;
import flash.events.Event;
import flash.ui.ContextMenu;
import flash.ui.ContextMenuItem;

import mx.controls.IFlexContextMenu;

public class Menu implements IFlexContextMenu
{
	protected var menu : ContextMenu;
	
	protected var clipboard : ClipboardData;
	
	protected const addRow : ContextMenuItem = new ContextMenuItem("Add Row", true);
	
	protected const addColumn : ContextMenuItem = new ContextMenuItem("Add Column");
	
	public function Menu ()
	{
		clipboard = ClipboardData.instance;
	}
	
	protected var _owner : PaintGrid;
	
	public function get owner () : PaintGrid
	{
		return _owner;
	}
	
	public function set owner (value : PaintGrid) : void
	{
		if (_owner === value)
			return;
		
		_owner = value;
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
		
		if (value is PaintGrid)
			owner = PaintGrid(value);
		else if (value is PaintGridItemRenderer)
			owner = PaintGridItemRenderer(value).dataGrid;
		
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
}
}