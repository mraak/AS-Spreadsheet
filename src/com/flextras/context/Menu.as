package com.flextras.context
{
import com.flextras.paintgrid.PaintGrid2;

import flash.display.InteractiveObject;
import flash.events.ContextMenuEvent;
import flash.ui.ContextMenu;
import flash.ui.ContextMenuItem;

public class Menu
{
	protected const _menu : ContextMenu = new ContextMenu();
	
	public function Menu (owner : PaintGrid2 = null)
	{
		_menu.hideBuiltInItems();
		
		this.owner = owner;
	}
	
	public function get menu () : ContextMenu
	{
		return _menu;
	}
	
	protected var _owner : InteractiveObject;
	
	public function get owner () : InteractiveObject
	{
		return _owner;
	}
	
	public function set owner (value : InteractiveObject) : void
	{
		if (_owner === value)
			return;
		
		_owner = value;
		
		if (value)
			value.contextMenu = _menu;
	}
	
	public function addItem (description : String, callBack : Function, separator : Boolean = false, enabled : Boolean = true, visible : Boolean = true) : void
	{
		var item : ContextMenuItem = new ContextMenuItem(description, separator, enabled, visible);
		item.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, callBack);
		
		_menu.customItems = _menu.customItems.concat(item);
	}
	
	public function getItem (description : String) : ContextMenuItem
	{
		for each (var item : ContextMenuItem in _menu.customItems)
			if (item.caption == description)
				return item;
		
		return null;
	}
	
	public function updateItem (description : String, newDescription : String, separator : Boolean = false, enabled : Boolean = true, visible : Boolean = true) : void
	{
		for each (var item : ContextMenuItem in _menu.customItems)
			if (item.caption == description)
			{
				item.caption = newDescription;
				item.enabled = enabled;
				item.separatorBefore = separator;
				item.visible = visible;
			}
	}
	
	public function removeItem (description : String) : void
	{
		for each (var item : ContextMenuItem in _menu.customItems)
			if (item.caption == description)
				_menu.customItems = _menu.customItems.splice(item, 1);
	}
}
}