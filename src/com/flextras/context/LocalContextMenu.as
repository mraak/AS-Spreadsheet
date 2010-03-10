package com.flextras.context
{
import com.flextras.calc.ControlObject;
import com.flextras.calc.Utils;
import com.flextras.paintgrid.CellProperties;
import com.flextras.paintgrid.PaintGrid2;
import com.flextras.spreadsheet.PaintSpreadsheet2;

import flash.events.ContextMenuEvent;
import flash.ui.ContextMenuItem;

import mx.managers.PopUpManager;

public class LocalContextMenu extends Menu
{

	
	protected const cut : ContextMenuItem = new ContextMenuItem("Cut ");
	
	protected const copy : ContextMenuItem = new ContextMenuItem("Copy ");
	
	protected const paste : ContextMenuItem = new ContextMenuItem("Paste ");
	
	protected const pasteValue : ContextMenuItem = new ContextMenuItem("Paste Value", true);
	
	protected const pasteStyles : ContextMenuItem = new ContextMenuItem("Paste Styles");
	
	protected const pasteExpressions : ContextMenuItem = new ContextMenuItem("Paste Expressions");
	
	protected const disable : ContextMenuItem = new ContextMenuItem("Disable Cell", true);
	
	protected const setCellStyles : ContextMenuItem = new ContextMenuItem("Cell Styles", true);
	
	protected const setColumnWidth : ContextMenuItem = new ContextMenuItem("Set Column Width", true);
	
	protected const setRowHeight : ContextMenuItem = new ContextMenuItem("Set Row Height");
	
	protected const removeRow : ContextMenuItem = new ContextMenuItem("Remove Row", true);
	
	protected const removeColumn : ContextMenuItem = new ContextMenuItem("Remove Column");
	
	public function LocalContextMenu (owner : PaintGrid2 = null)
	{
		super(owner);
		
		removeRow.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, removeRowHandler);
		removeColumn.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, removeColumnHandler);
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
		
		_menu.customItems = [cut, copy, paste, pasteValue, pasteStyles, pasteExpressions, disable, setCellStyles, setColumnWidth, setRowHeight, removeRow, removeColumn];
	}
	
	override public function reset () : void
	{
		disable.caption = "Disable Cell";
	}
	
	protected function removeRowHandler (e : ContextMenuEvent) : void
	{
		for each (var cell : CellProperties in owner.selectedCells)
			owner.removeRow(cell.row);
	}
	
	protected function removeColumnHandler (e : ContextMenuEvent) : void
	{
		for each (var cell : CellProperties in owner.selectedCells)
			owner.removeColumn(cell.column);
	}
	
	protected var range : Array;
	
	protected var dx : int, dy : int;
	
	protected var performCopy : Boolean;
	
	protected function cutHandler (e : ContextMenuEvent) : void
	{
		performCopy = false;
		dx = owner.selectedCellProperties.column;
		dy = owner.selectedCellProperties.row;
		
		setupRange();
	}
	
	protected function copyHandler (e : ContextMenuEvent) : void
	{
		performCopy = true;
		dx = owner.selectedCellProperties.column;
		dy = owner.selectedCellProperties.row;
		
		setupRange();
	}
	
	protected function setupRange () : void
	{
		if (!(owner is PaintSpreadsheet2))
			return;
		
		var pss : PaintSpreadsheet2 = PaintSpreadsheet2(owner);
		var prop : String, id : String, co : ControlObject;
		
		range = [];
		
		for each (var cell : CellProperties in owner.selectedCells)
		{
			prop = String(Utils.alphabet[cell.column]).toLowerCase();
			id = prop + cell.row;
			
			co = pss.ctrlObjects[id];
			
			if (co)
				range.push(co);
		}
	}
	
	protected function pasteHandler (e : ContextMenuEvent) : void
	{
		var x : int = owner.selectedCellProperties.column - dx;
		var y : int = owner.selectedCellProperties.row - dy;
		
		if (owner is PaintSpreadsheet2)
			PaintSpreadsheet2(owner).moveRange(range, x, y, performCopy);
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
		disable.caption = disable.caption == "Disable Cell" ? "Enable Cell" : "Disable Cell";
		
		owner.disabledCells = owner.selectedCells;
	}
	
	protected var popup : BasePopup;
	
	protected function setCellStylesHandler (e : ContextMenuEvent) : void
	{
		if (popup)
			PopUpManager.removePopUp(popup);
		
		popup = new StylesPopup();
		
		popup.grid = owner;
		
		PopUpManager.addPopUp(popup, popup.grid);
		PopUpManager.centerPopUp(popup);
		
		StylesPopup(popup).updateCell();
	}
	
	protected function setColumnWidthHandler (e : ContextMenuEvent) : void
	{
		if (popup)
			PopUpManager.removePopUp(popup);
		
		popup = new WidthPopup();
		
		popup.grid = owner;
		
		PopUpManager.addPopUp(popup, popup.grid);
		PopUpManager.centerPopUp(popup);
	}
	
	protected function setRowHeightHandler (e : ContextMenuEvent) : void
	{
		if (popup)
			PopUpManager.removePopUp(popup);
		
		popup = new HeightPopup();
		
		popup.grid = owner;
		
		PopUpManager.addPopUp(popup, popup.grid);
		PopUpManager.centerPopUp(popup);
	}
}
}