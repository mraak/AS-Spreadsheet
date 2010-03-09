package com.flextras.context
{
import com.flextras.paintgrid.PaintGrid2;
import com.flextras.paintgrid.PaintGrid2ColumnItemRenderer;

import flash.events.ContextMenuEvent;
import flash.ui.ContextMenuItem;

import mx.managers.PopUpManager;

public class LocalContextMenu extends Menu
{
	protected const cut : ContextMenuItem = new ContextMenuItem("cut");
	
	protected const copy : ContextMenuItem = new ContextMenuItem("copy");
	
	protected const paste : ContextMenuItem = new ContextMenuItem("paste");
	
	protected const pasteValue : ContextMenuItem = new ContextMenuItem("paste value");
	
	protected const pasteStyles : ContextMenuItem = new ContextMenuItem("paste styles");
	
	protected const pasteExpressions : ContextMenuItem = new ContextMenuItem("paste expressions");
	
	protected const disable : ContextMenuItem = new ContextMenuItem("disable");
	
	protected const setCellStyles : ContextMenuItem = new ContextMenuItem("set cell styles");
	
	protected const setColumnWidth : ContextMenuItem = new ContextMenuItem("set column width");
	
	protected const setRowHeight : ContextMenuItem = new ContextMenuItem("set row height");
	
	public function LocalContextMenu (owner : PaintGrid2 = null)
	{
		super(owner);
		
		cut.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, cutHandler);
		copy.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, copyHandler);
		paste.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, pasteHandler);
		pasteValue.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, pasteValueHandler);
		pasteStyles.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, pasteStylesHandler);
		pasteExpressions.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, pasteExpressionsHandler);
		disable.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, disableHandler);
		setCellStyles.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, setCellStylesHandler);
		setColumnWidth.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, setColumnWidthHandler);
		setRowHeight.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, setRowHeightHandler);
		
		_menu.customItems = [cut, copy, paste, pasteValue, pasteStyles, pasteExpressions, disable, setCellStyles, setColumnWidth, setRowHeight];
	}
	
	override public function reset () : void
	{
		disable.caption = "disable";
	}
	
	protected function cutHandler (e : ContextMenuEvent) : void
	{
		trace(e);
	}
	
	protected function copyHandler (e : ContextMenuEvent) : void
	{
		trace(e);
	}
	
	protected function pasteHandler (e : ContextMenuEvent) : void
	{
		trace(e);
	}
	
	protected function pasteValueHandler (e : ContextMenuEvent) : void
	{
		trace(e);
	}
	
	protected function pasteStylesHandler (e : ContextMenuEvent) : void
	{
		trace(e);
	}
	
	protected function pasteExpressionsHandler (e : ContextMenuEvent) : void
	{
		trace(e);
	}
	
	protected function disableHandler (e : ContextMenuEvent) : void
	{
		disable.caption = disable.caption == "disable" ? "enable" : "disable";
	}
	
	var popup : StylesPopup;
	
	protected function setCellStylesHandler (e : ContextMenuEvent) : void
	{
		if (popup)
			PopUpManager.removePopUp(popup);
		
		popup = new StylesPopup();
		
		popup.grid = PaintGrid2ColumnItemRenderer(owner).dataGrid;
		
		PopUpManager.addPopUp(popup, popup.grid);
		PopUpManager.centerPopUp(popup);
		
		popup.updateCell();
	}
	
	protected function setColumnWidthHandler (e : ContextMenuEvent) : void
	{
		trace(e);
	}
	
	protected function setRowHeightHandler (e : ContextMenuEvent) : void
	{
		trace(e);
	}
}
}