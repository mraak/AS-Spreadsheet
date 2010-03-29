package com.flextras.spreadsheet.context
{
import com.flextras.calc.ControlObject;
import com.flextras.calc.Utils;
import com.flextras.paintgrid.CellProperties;

import flash.display.InteractiveObject;
import flash.events.ContextMenuEvent;
import flash.events.Event;
import flash.ui.ContextMenu;
import flash.ui.ContextMenuItem;

import mx.core.mx_internal;
import mx.managers.PopUpManager;

use namespace mx_internal;

public class LocalContextMenu extends Menu
{
	
	protected const cut : ContextMenuItem = new ContextMenuItem("Cut ");
	
	protected const copy : ContextMenuItem = new ContextMenuItem("Copy ");
	
	protected const paste : ContextMenuItem = new ContextMenuItem("Paste ");
	
	protected const pasteSpecial : ContextMenuItem = new ContextMenuItem("Paste Special");
	
	protected const disable : ContextMenuItem = new ContextMenuItem("Disable Cell");
	
	protected const setCellStyles : ContextMenuItem = new ContextMenuItem("Cell Styles", true);
	
	protected const setGlobalStyles : ContextMenuItem = new ContextMenuItem("Global Styles");
	
	protected const setColumnWidth : ContextMenuItem = new ContextMenuItem("Set Column Width", true);
	
	protected const setRowHeight : ContextMenuItem = new ContextMenuItem("Set Row Height");
	
	protected const removeRow : ContextMenuItem = new ContextMenuItem("Remove Row");
	
	protected const clearRow : ContextMenuItem = new ContextMenuItem("Clear Row");
	
	protected const removeColumn : ContextMenuItem = new ContextMenuItem("Remove Column");
	
	protected const clearColumn : ContextMenuItem = new ContextMenuItem("Clear Column");
	
	protected const clearCell : ContextMenuItem = new ContextMenuItem("Clear Cell", true);
	
	protected var popup : BasePopup;
	
	protected var _cell : CellProperties;
	
	public function get cell () : CellProperties
	{
		return _cell;
	}
	
	public function set cell (value : CellProperties) : void
	{
		if (_cell === value)
			return;
		
		if (_cell)
			_cell.removeEventListener("selectedChanged", cellSelectedHandler);
		
		_cell = value;
		
		if (value)
			value.addEventListener("selectedChanged", cellSelectedHandler);
	}
	
	override protected function addRowHandler (e : ContextMenuEvent) : void
	{
		var cells : Array = owner.selectedCells && owner.selectedCells.length > 0 ? owner.selectedCells : [cell];
		
		for each (var c : CellProperties in cells)
			owner.insertRowAt(c.row);
	}
	
	protected function removeRowHandler (e : ContextMenuEvent) : void
	{
		var cells : Array = owner.selectedCells && owner.selectedCells.length > 0 ? owner.selectedCells : [cell];
		
		for each (var c : CellProperties in cells)
			owner.removeRowAt(c.row);
	}
	
	protected function clearRowHandler (e : ContextMenuEvent) : void
	{
		var cells : Array = owner.selectedCells && owner.selectedCells.length > 0 ? owner.selectedCells : [cell];
		
		for each (var c : CellProperties in cells)
			owner.clearRowAt(c.row);
	}
	
	override protected function addColumnHandler (e : ContextMenuEvent) : void
	{
		var cells : Array = owner.selectedCells && owner.selectedCells.length > 0 ? owner.selectedCells : [cell];
		
		for each (var c : CellProperties in cells)
			owner.insertColumnAt(c.column);
	}
	
	protected function removeColumnHandler (e : ContextMenuEvent) : void
	{
		var cells : Array = owner.selectedCells && owner.selectedCells.length > 0 ? owner.selectedCells : [cell];
		
		for each (var c : CellProperties in cells)
			owner.removeColumnAt(c.column);
	}
	
	protected function clearColumnHandler (e : ContextMenuEvent) : void
	{
		var cells : Array = owner.selectedCells && owner.selectedCells.length > 0 ? owner.selectedCells : [cell];
		
		for each (var c : CellProperties in cells)
			owner.clearColumnAt(c.column);
	}
	
	protected function clearCellHandler (e : ContextMenuEvent) : void
	{
		var cells : Array = owner.selectedCells && owner.selectedCells.length > 0 ? owner.selectedCells : [cell];
		
		for each (var c : CellProperties in cells)
			owner.assignExpression(Utils.alphabet[c.column] + c.row, "");
	}
	
	protected function cutHandler (e : ContextMenuEvent) : void
	{
		clipboard.range = setRange();
		clipboard.performCopy = false;
	}
	
	protected function copyHandler (e : ContextMenuEvent) : void
	{
		clipboard.range = setRange();
		clipboard.performCopy = true;
	}
	
	protected function pasteHandler (e : ContextMenuEvent) : void
	{
		pasteLogic("moveRange");
	}
	
	protected function pasteSpecialHandler (e : ContextMenuEvent) : void
	{
		if (popup)
			PopUpManager.removePopUp(popup);
		
		popup = new PastePopup();
		popup.grid = owner;
		
		PopUpManager.addPopUp(popup, popup.grid);
		PopUpManager.centerPopUp(popup);
		
		PastePopup(popup).pasteFunction = pasteLogic;
	}
	
	protected function disableHandler (e : ContextMenuEvent) : void
	{
		var cells : Array = owner.selectedCells && owner.selectedCells.length > 0 ? owner.selectedCells : [cell];
		
		for each (var c : CellProperties in cells)
			c.menu.disable.caption = c.menu.disable.caption == "Disable Cell" ? "Enable Cell" : "Disable Cell";
		
		owner.disabledCells = cells;
	}
	
	protected function setCellStylesHandler (e : ContextMenuEvent) : void
	{
		if (popup)
			PopUpManager.removePopUp(popup);
		
		popup = new StylesPopup();
		popup.grid = owner;
		
		PopUpManager.addPopUp(popup, owner);
		PopUpManager.centerPopUp(popup);
		
		if (owner.selectedCells && owner.selectedCells.length > 0)
			StylesPopup(popup).cells = owner.selectedCells;
		
		StylesPopup(popup).cell = cell;
	}
	
	protected function setColumnWidthHandler (e : ContextMenuEvent) : void
	{
		if (popup)
			PopUpManager.removePopUp(popup);
		
		popup = new WidthPopup();
		popup.grid = owner;
		
		PopUpManager.addPopUp(popup, popup.grid);
		PopUpManager.centerPopUp(popup);
		
		if (owner.selectedCells && owner.selectedCells.length > 0)
			WidthPopup(popup).cells = owner.selectedCells;
		
		WidthPopup(popup).cell = cell;
	}
	
	protected function setRowHeightHandler (e : ContextMenuEvent) : void
	{
		if (popup)
			PopUpManager.removePopUp(popup);
		
		popup = new HeightPopup();
		popup.grid = owner;
		
		PopUpManager.addPopUp(popup, popup.grid);
		PopUpManager.centerPopUp(popup);
		
		if (owner.selectedCells && owner.selectedCells.length > 0)
			HeightPopup(popup).cells = owner.selectedCells;
		
		HeightPopup(popup).cell = cell;
	}
	
	protected function cellSelectedHandler (e : Event) : void
	{
		var allow : Boolean = cell && cell.selected && enabled;
		cut.enabled = allow;
		copy.enabled = allow;
		
		allow &&= clipboard.allowPaste;
		
		paste.enabled = allow;
		pasteSpecial.enabled = allow;
	}
	
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
		
		removeRow.enabled = value;
		clearRow.enabled = value;
		removeColumn.enabled = value;
		clearColumn.enabled = value;
		clearCell.enabled = value;
		setCellStyles.enabled = value;
		setColumnWidth.enabled = value;
		setRowHeight.enabled = value;
		setGlobalStyles.enabled = value;
		
		cellSelectedHandler(null);
		
		disable.caption = !value ? "Enable Cell" : "Disable Cell";
	}
	
	override public function setContextMenu (component : InteractiveObject) : void
	{
		super.setContextMenu(component);
		
		removeRow.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, removeRowHandler);
		clearRow.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, clearRowHandler);
		removeColumn.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, removeColumnHandler);
		clearColumn.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, clearColumnHandler);
		clearCell.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, clearCellHandler);
		cut.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, cutHandler);
		copy.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, copyHandler);
		paste.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, pasteHandler);
		pasteSpecial.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, pasteSpecialHandler);
		disable.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, disableHandler);
		setCellStyles.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, setCellStylesHandler);
		setColumnWidth.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, setColumnWidthHandler);
		setRowHeight.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, setRowHeightHandler);
		
		setGlobalStyles.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, setGlobalStylesHandler);
		
		menu.customItems = [cut, copy, paste, pasteSpecial,
							clearCell, disable, setCellStyles, setGlobalStyles, setColumnWidth, setRowHeight,
							addRow, removeRow, clearRow, addColumn, removeColumn, clearColumn];
	}
	
	override public function unsetContextMenu (component : InteractiveObject) : void
	{
		super.unsetContextMenu(component);
		
		removeRow.removeEventListener(ContextMenuEvent.MENU_ITEM_SELECT, removeRowHandler);
		clearRow.removeEventListener(ContextMenuEvent.MENU_ITEM_SELECT, clearRowHandler);
		removeColumn.removeEventListener(ContextMenuEvent.MENU_ITEM_SELECT, removeColumnHandler);
		clearColumn.removeEventListener(ContextMenuEvent.MENU_ITEM_SELECT, clearColumnHandler);
		clearCell.removeEventListener(ContextMenuEvent.MENU_ITEM_SELECT, clearCellHandler);
		cut.removeEventListener(ContextMenuEvent.MENU_ITEM_SELECT, cutHandler);
		copy.removeEventListener(ContextMenuEvent.MENU_ITEM_SELECT, copyHandler);
		paste.removeEventListener(ContextMenuEvent.MENU_ITEM_SELECT, pasteHandler);
		pasteSpecial.removeEventListener(ContextMenuEvent.MENU_ITEM_SELECT, pasteSpecialHandler);
		disable.removeEventListener(ContextMenuEvent.MENU_ITEM_SELECT, disableHandler);
		setCellStyles.removeEventListener(ContextMenuEvent.MENU_ITEM_SELECT, setCellStylesHandler);
		setColumnWidth.removeEventListener(ContextMenuEvent.MENU_ITEM_SELECT, setColumnWidthHandler);
		setRowHeight.removeEventListener(ContextMenuEvent.MENU_ITEM_SELECT, setRowHeightHandler);
		setGlobalStyles.removeEventListener(ContextMenuEvent.MENU_ITEM_SELECT, setGlobalStylesHandler);
		
		menu.customItems = null;
	}
	
	override protected function allowPasteChangedHandler (e : Event) : void
	{
		cellSelectedHandler(null);
	}
	
	protected function getRange (keys : Array) : Array
	{
		var co : ControlObject;
		var range : Array = [];
		
		for each (var key : String in keys)
		{
			co = owner.ctrlObjects[key];
			
			if (co)
				range.push(co);
		}
		
		return range;
	}
	
	protected function setRange () : Array
	{
		var prop : String, id : String, co : ControlObject;
		var cells : Array = owner.selectedCells && owner.selectedCells.length > 0 ? owner.selectedCells : [cell];
		var range : Array = [];
		
		for each (var c : CellProperties in cells)
		{
			prop = String(Utils.alphabet[c.column]).toLowerCase();
			id = prop + c.row;
			
			co = owner.ctrlObjects[id];
			
			if (co)
				range.push(id);
		}
		
		return range.sort(Array.CASEINSENSITIVE);
	}
	
	protected function pasteLogic (what : String) : void
	{
		var range : Array = getRange(clipboard.range);
		var o : ControlObject = range[0];
		var x : int = cell.column - o.colIndex;
		var y : int = cell.row - o.rowIndex;
		
		owner[what](range, x, y, clipboard.performCopy);
	}
}
}