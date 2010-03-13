package com.flextras.context
{
import com.flextras.paintgrid.PaintGrid2;
import com.flextras.paintgrid.PaintGrid2ColumnItemRenderer;

import flash.display.InteractiveObject;
import flash.events.Event;
import flash.ui.ContextMenu;

import mx.controls.IFlexContextMenu;

public class Menu implements IFlexContextMenu
{
	protected var _owner : PaintGrid2;
	
	public function get owner () : PaintGrid2
	{
		return _owner;
	}
	
	public function set owner (value : PaintGrid2) : void
	{
		if (_owner === value)
			return;
		
		if (_owner)
			_owner.removeEventListener("allowPasteAction", allowPasteActionHandler);
		
		_owner = value;
		
		if (value)
			value.addEventListener("allowPasteAction", allowPasteActionHandler);
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
		
		if (value is PaintGrid2)
			owner = PaintGrid2(value);
		else if (value is PaintGrid2ColumnItemRenderer)
			owner = PaintGrid2ColumnItemRenderer(value).dataGrid;
		
		menu = new ContextMenu();
		menu.hideBuiltInItems();
		
		value.contextMenu = menu;
	}
	
	protected var menu : ContextMenu;
	
	protected var _enabled : Boolean;
	
	public function get enabled () : Boolean
	{
		return _enabled;
	}
	
	public function set enabled (value : Boolean) : void
	{
		_enabled = value;
	}
	
	public function setContextMenu (component : InteractiveObject) : void
	{
		target = component;
	}
	
	public function unsetContextMenu (component : InteractiveObject) : void
	{
	
	}
	
	protected function allowPasteActionHandler (e : Event) : void
	{
	
	}
}
}