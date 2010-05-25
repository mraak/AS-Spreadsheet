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

/**
 * This class represents the ContextMenu that is used on a cell of the Flextras Spreadsheet when that cell is in edit mode.
 * 
 * @see com.flextras.spreadsheet.Spreadsheet
 */
public class LocalContextMenu extends Menu
{
	
	/**
	 * This represents the context menu item which will bring up the popup for performing the cut operation on a cell.
	 */
	protected const cut : ContextMenuItem = new ContextMenuItem("Cut ");
	
	/**
	 * This represents the context menu item which will bring up the popup for performing the copy operation on a cell.
	 */
	protected const copy : ContextMenuItem = new ContextMenuItem("Copy ");
	
	/**
	 * This represents the context menu item which will bring up the popup for performing the paste operation on a cell. 
	 */
	protected const paste : ContextMenuItem = new ContextMenuItem("Paste ");
	
	/**
	 * This represents the context menu item which will bring up the popup for performing the paste special operation on a cell. 
	 */
	protected const pasteSpecial : ContextMenuItem = new ContextMenuItem("Paste Special");
	
	/**
	 * This represents the context menu item which will bring up the popup for preventing a cell from being edited.  
	 */
	protected const disable : ContextMenuItem = new ContextMenuItem("Disable Cell");
	
	/**
	 * This represents the context menu item which will bring up the popup for performing the paste operation on a cell. 
	 */
	protected const setCellStyles : ContextMenuItem = new ContextMenuItem("Cell Styles", true);
	
	/**
	 * @copy com.flextras.spreadsheet.context.GlobalContextMenu#setGlobalStyles
	 */
	protected const setGlobalStyles : ContextMenuItem = new ContextMenuItem("Global Styles");
	
	/**
	 * This represents the context menu item which will bring up the popup for setting the size of a cell. 
	 */
	protected const setSize : ContextMenuItem = new ContextMenuItem("Set Size", true);
	
	/**
	 * This represents the context menu item that will remove a row. 
	 */
	protected const removeRow : ContextMenuItem = new ContextMenuItem("Remove Row");
	
	/**
	 * This represents the context menu item that will clear all data in a row.
	 */
	protected const clearRow : ContextMenuItem = new ContextMenuItem("Clear Row");
	
	/**
	 * This represents the context menu item that will remove a column. 
	 */
	protected const removeColumn : ContextMenuItem = new ContextMenuItem("Remove Column");
	
	/**
	 * This represents the context menu item that will clear all data in a column.
	 */
	protected const clearColumn : ContextMenuItem = new ContextMenuItem("Clear Column");
	
	/**
	 * This represents the context menu item that will clear all data in a cell.
	 */
	protected const clearCell : ContextMenuItem = new ContextMenuItem("Clear Cell", true);
	
	/**
	 * @copy com.flextras.spreadsheet.context.GlobalContextMenu#popup
	 */
	protected var popup : BasePopup;
	
	/**
	 * @private  
	 */
	protected var _cell : CellProperties;
	
	/**
	 * @copy com.flextras.spreadsheet.context.GlobalContextMenu#cell 
	 */
	public function get cell () : CellProperties
	{
		return _cell;
	}
	
	/**
	 * @private  
	 */
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
	
	/**
	 * @inheritDoc
	 */
	override protected function addRowHandler (e : ContextMenuEvent) : void
	{
		var cells : Array = owner.selectedCells && owner.selectedCells.length > 0 ? owner.selectedCells : [cell];
		
		for each (var c : CellProperties in cells)
			owner.insertRowAt(c.location.row);
	}
	
	/**
	 * This is the default handler for the remove row context menu item.  
	 * It will call the removeRowAt method of the spreadsheet component defined as the owner.
	 */
	protected function removeRowHandler (e : ContextMenuEvent) : void
	{
		var cells : Array = owner.selectedCells && owner.selectedCells.length > 0 ? owner.selectedCells : [cell];
		
		for each (var c : CellProperties in cells)
			owner.removeRowAt(c.location.row);
	}
	
	/**
	 * 
	 */
	protected function clearRowHandler (e : ContextMenuEvent) : void
	{
		var cells : Array = owner.selectedCells && owner.selectedCells.length > 0 ? owner.selectedCells : [cell];
		
		for each (var c : CellProperties in cells)
			owner.clearRowAt(c.location.row);
	}
	
	/**
	 * This is the default handler for the clear row context menu item.  
	 * It will call the clearRowAt method of the spreadsheet component defined as the owner.
	 */
	override protected function addColumnHandler (e : ContextMenuEvent) : void
	{
		var cells : Array = owner.selectedCells && owner.selectedCells.length > 0 ? owner.selectedCells : [cell];
		
		for each (var c : CellProperties in cells)
			owner.insertColumnAt(c.location.column);
	}
	
	/**
	 * This is the default handler for the remove column context menu item.  
	 * It will call the removeColumnAt method of the spreadsheet component defined as the owner.
	 */
	protected function removeColumnHandler (e : ContextMenuEvent) : void
	{
		var cells : Array = owner.selectedCells && owner.selectedCells.length > 0 ? owner.selectedCells : [cell];
		
		for each (var c : CellProperties in cells)
			owner.removeColumnAt(c.location.column);
	}
	
	/**
	 *  This is the default handler for the clear column context menu item.  
	 * It will call the clearColumnAt method of the spreadsheet component defined as the owner.
	 */
	protected function clearColumnHandler (e : ContextMenuEvent) : void
	{
		var cells : Array = owner.selectedCells && owner.selectedCells.length > 0 ? owner.selectedCells : [cell];
		
		for each (var c : CellProperties in cells)
			owner.clearColumnAt(c.location.column);
	}
	
	/**
	 * This is the default handler for the clear cell context menu item.  
	 * It will call the assignExpression method of the spreadsheet component to clear all data from cells.
	 */
	protected function clearCellHandler (e : ContextMenuEvent) : void
	{
		var cells : Array = owner.selectedCells && owner.selectedCells.length > 0 ? owner.selectedCells : [cell];
		
		for each (var c : CellProperties in cells)
			owner.assignExpression(String(Utils.alphabet[c.location.column]).toLowerCase() + c.location.row, "");
	}
	
	/**
	 *  This is the default handler for the cut context menu item.  
	 */
	protected function cutHandler (e : ContextMenuEvent) : void
	{
		clipboard.range = setRange();
		clipboard.performCopy = false;
	}
	
	/**
	 * This is the default handler for the copy context menu item.  
	 */
	protected function copyHandler (e : ContextMenuEvent) : void
	{
		clipboard.range = setRange();
		clipboard.performCopy = true;
	}
	
	/**
	 * This is the default handler for the paste context menu item.  
	 */
	protected function pasteHandler (e : ContextMenuEvent) : void
	{
		pasteLogic("moveRange");
	}
	
	/**
	 * This is the default handler for the paste special context menu item.  
	 */
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
	
	/**
	 * This is the default handler for the disable context menu item.  
	 */
	protected function disableHandler (e : ContextMenuEvent) : void
	{
		var cells : Array = owner.selectedCells && owner.selectedCells.length > 0 ? owner.selectedCells : [cell];
		
		for each (var c : CellProperties in cells)
			c.menu.disable.caption = c.menu.disable.caption == "Disable Cell" ? "Enable Cell" : "Disable Cell";
		
		owner.disabledCells = cells;
	}
	
	/**
	 * This is the default handler for the set styles context menu item.  
	 * It will create a new instance of the StylesPopup and allow for editing of cell specific styles.
	 * @see com.flextras.spreadsheet.context.StylesPopup
	 */
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
		StylesPopup(popup).local = true;
	}
	
	/**
	 * This is the default handler for the set size context menu item.  
	 * It will create a new instance of the SizePopup and handle changes done within.
	 * 
	 * @see com.flextras.spreadsheet.context.SizePopup
	 */
	protected function setSizeHandler (e : ContextMenuEvent) : void
	{
		if (popup)
			PopUpManager.removePopUp(popup);
		
		popup = new SizePopup();
		popup.grid = owner;
		
		PopUpManager.addPopUp(popup, popup.grid);
		PopUpManager.centerPopUp(popup);
		
		if (owner.selectedCells && owner.selectedCells.length > 0)
			SizePopup(popup).cells = owner.selectedCells;
		
		SizePopup(popup).cell = cell;
	}
	
	/**
	 * 
	 */
	protected function cellSelectedHandler (e : Event) : void
	{
		var allow : Boolean = cell && cell.selected && enabled;
		cut.enabled = allow;
		copy.enabled = allow;
		
		allow &&= clipboard.allowPaste;
		
		paste.enabled = allow;
		pasteSpecial.enabled = allow;
	}
	
	/**
	 * @copy com.flextras.spreadsheet.context.GlobalContextMenu#setGlobalStylesHandler
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
	 * @private
	 */
	override public function set enabled (value : Boolean) : void
	{
		super.enabled = value;
		
		removeRow.enabled = value;
		clearRow.enabled = value;
		removeColumn.enabled = value;
		clearColumn.enabled = value;
		clearCell.enabled = value;
		setCellStyles.enabled = value;
		setSize.enabled = value;
		setGlobalStyles.enabled = value;
		
		cellSelectedHandler(null);
		
		disable.caption = !value ? "Enable Cell" : "Disable Cell";
	}
	
	/**
	 * @inheritDoc
	 */
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
		setSize.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, setSizeHandler);
		
		setGlobalStyles.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, setGlobalStylesHandler);
		
		menu.customItems = [cut, copy, paste, pasteSpecial,
							clearCell, disable, setCellStyles, setGlobalStyles, setSize,
							addRow, removeRow, clearRow, addColumn, removeColumn, clearColumn];
	}
	
	/**
	 * @inheritDoc
	 */
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
		setSize.removeEventListener(ContextMenuEvent.MENU_ITEM_SELECT, setSizeHandler);
		
		setGlobalStyles.removeEventListener(ContextMenuEvent.MENU_ITEM_SELECT, setGlobalStylesHandler);
		
		menu.customItems = null;
	}
	
	/**
	 * @inheritDoc
	 */
	override protected function allowPasteChangedHandler (e : Event) : void
	{
		cellSelectedHandler(null);
	}
	
	/**
	 * 
	 */
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
	
	/**
	 * 
	 */
	protected function setRange () : Array
	{
		var prop : String, id : String, co : ControlObject;
		var cells : Array = owner.selectedCells && owner.selectedCells.length > 0 ? owner.selectedCells : [cell];
		var range : Array = [];
		
		for each (var c : CellProperties in cells)
		{
			prop = String(Utils.alphabet[c.location.column]).toLowerCase();
			id = prop + c.location.row;
			
			co = owner.ctrlObjects[id];
			
			if (co)
				range.push(id);
		}
		
		return range.sort(Array.CASEINSENSITIVE);
	}
	
	/**
	 * 
	 */
	protected function pasteLogic (what : String) : void
	{
		var range : Array = getRange(clipboard.range);
		var o : ControlObject = range[0];
		var x : int = cell.location.column - o.colIndex;
		var y : int = cell.location.row - o.rowIndex;
		
		owner[what](range, x, y, clipboard.performCopy);
	}
}
}