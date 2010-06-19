package com.flextras.spreadsheet.context
{
import com.flextras.calc.Utils;
import com.flextras.spreadsheet.Spreadsheet;
import com.flextras.spreadsheet.core.spreadsheet;
import com.flextras.spreadsheet.vos.Cell;

import flash.display.InteractiveObject;
import flash.events.ContextMenuEvent;
import flash.events.Event;
import flash.geom.Point;
import flash.ui.ContextMenu;
import flash.ui.ContextMenuItem;

import mx.controls.IFlexContextMenu;
import mx.managers.PopUpManager;
import mx.utils.ObjectUtil;

use namespace spreadsheet;

public class Menu implements IFlexContextMenu
{
	public const cut : ContextMenuItem = new ContextMenuItem("Cut ");
	public const copy : ContextMenuItem = new ContextMenuItem("Copy ");
	public const paste : ContextMenuItem = new ContextMenuItem("Paste ");
	public const pasteSpecial : ContextMenuItem = new ContextMenuItem("Paste special");
	
	public const disable : ContextMenuItem = new ContextMenuItem("Disable Cell");
	
	public const setCellStyles : ContextMenuItem = new ContextMenuItem("Formatting", true);
	public const setConditionalStyles : ContextMenuItem = new ContextMenuItem("Conditional Formatting");
	
	public const setGlobalStyles : ContextMenuItem = new ContextMenuItem("Global formatting", true);
	
	public const setSize : ContextMenuItem = new ContextMenuItem("Set size", true);
	
	public const addRow : ContextMenuItem = new ContextMenuItem("Insert row", true);
	public const removeRow : ContextMenuItem = new ContextMenuItem("Remove row");
	public const clearRow : ContextMenuItem = new ContextMenuItem("Clear row");
	
	public const addColumn : ContextMenuItem = new ContextMenuItem("Insert column", true);
	public const removeColumn : ContextMenuItem = new ContextMenuItem("Remove column");
	public const clearColumn : ContextMenuItem = new ContextMenuItem("Clear column");
	
	public const clearCell : ContextMenuItem = new ContextMenuItem("Clear cell", true);
	
	protected var menu : ContextMenu;
	
	protected var popup : BasePopup;
	
	protected var host : Spreadsheet = Spreadsheet.instance;
	
	public var cell : Cell;
	
	protected var clipboard : ClipboardData;
	
	public function Menu(cell : Cell)
	{
		this.cell = cell;
		
		clipboard = ClipboardData.instance;
		
		allowPasteHandler();
	}
	
	private var _target : InteractiveObject;
	
	public function get target() : InteractiveObject
	{
		return _target;
	}
	
	public function set target(value : InteractiveObject) : void
	{
		if (_target === value)
			return;
		
		_target = value;
		
		menu = new ContextMenu();
		menu.hideBuiltInItems();
		
		value.contextMenu = menu;
	}
	
	public function setContextMenu(component : InteractiveObject) : void
	{
		target = component;
		
		clipboard.addEventListener("allowPasteChanged", allowPasteHandler);
		
		addRow.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, addRowHandler);
		removeRow.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, removeRowHandler);
		clearRow.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, clearRowHandler);
		addColumn.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, addColumnHandler);
		removeColumn.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, removeColumnHandler);
		clearColumn.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, clearColumnHandler);
		clearCell.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, clearCellHandler);
		cut.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, cutHandler);
		copy.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, copyHandler);
		paste.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, pasteHandler);
		pasteSpecial.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, pasteSpecialHandler);
		disable.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, disableHandler);
		setCellStyles.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, setCellStylesHandler);
		setConditionalStyles.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, setConditionalStylesHandler);
		setGlobalStyles.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, setGlobalStylesHandler);
		setSize.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, setSizeHandler);
		
		menu.customItems = [cut, copy, paste, pasteSpecial,
							clearCell, disable, setCellStyles, setConditionalStyles, setGlobalStyles, setSize,
							addRow, removeRow, clearRow, addColumn, removeColumn, clearColumn];
	}
	
	public function unsetContextMenu(component : InteractiveObject) : void
	{
		clipboard.removeEventListener("allowPasteChanged", allowPasteHandler);
		
		addRow.removeEventListener(ContextMenuEvent.MENU_ITEM_SELECT, addRowHandler);
		removeRow.removeEventListener(ContextMenuEvent.MENU_ITEM_SELECT, removeRowHandler);
		clearRow.removeEventListener(ContextMenuEvent.MENU_ITEM_SELECT, clearRowHandler);
		addColumn.removeEventListener(ContextMenuEvent.MENU_ITEM_SELECT, addColumnHandler);
		removeColumn.removeEventListener(ContextMenuEvent.MENU_ITEM_SELECT, removeColumnHandler);
		clearColumn.removeEventListener(ContextMenuEvent.MENU_ITEM_SELECT, clearColumnHandler);
		clearCell.removeEventListener(ContextMenuEvent.MENU_ITEM_SELECT, clearCellHandler);
		cut.removeEventListener(ContextMenuEvent.MENU_ITEM_SELECT, cutHandler);
		copy.removeEventListener(ContextMenuEvent.MENU_ITEM_SELECT, copyHandler);
		paste.removeEventListener(ContextMenuEvent.MENU_ITEM_SELECT, pasteHandler);
		pasteSpecial.removeEventListener(ContextMenuEvent.MENU_ITEM_SELECT, pasteSpecialHandler);
		disable.removeEventListener(ContextMenuEvent.MENU_ITEM_SELECT, disableHandler);
		setCellStyles.removeEventListener(ContextMenuEvent.MENU_ITEM_SELECT, setCellStylesHandler);
		setConditionalStyles.removeEventListener(ContextMenuEvent.MENU_ITEM_SELECT, setConditionalStylesHandler);
		setGlobalStyles.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, setGlobalStylesHandler);
		setSize.removeEventListener(ContextMenuEvent.MENU_ITEM_SELECT, setSizeHandler);
		
		menu.customItems = null;
	}
	
	protected function addRowHandler(e : ContextMenuEvent) : void
	{
		var cells : Vector.<Cell> = this.cells;
		
		for each (var c : Cell in cells)
			if (c !== cell)
				host.insertRowAt(c.rowIndex);
		
		host.insertRowAt(cell.rowIndex);
	}
	
	protected function removeRowHandler(e : ContextMenuEvent) : void
	{
		var cells : Vector.<Cell> = this.cells;
		
		for each (var c : Cell in cells)
			if (c !== cell)
				host.removeRowAt(c.rowIndex);
		
		host.removeRowAt(cell.rowIndex);
	}
	
	protected function clearRowHandler(e : ContextMenuEvent) : void
	{
		var cells : Vector.<Cell> = this.cells;
		
		for each (var c : Cell in cells)
			if (c !== cell)
				host.clearRowAt(c.rowIndex);
		
		host.clearRowAt(cell.rowIndex);
	}
	
	protected function addColumnHandler(e : ContextMenuEvent) : void
	{
		var cells : Vector.<Cell> = this.cells;
		
		for each (var c : Cell in cells)
			if (c !== cell)
				host.insertColumnAt(c.columnIndex);
		
		host.insertColumnAt(cell.columnIndex);
	}
	
	protected function removeColumnHandler(e : ContextMenuEvent) : void
	{
		var cells : Vector.<Cell> = this.cells;
		
		for each (var c : Cell in cells)
			if (c !== cell)
				host.removeColumnAt(c.columnIndex);
		
		host.removeColumnAt(cell.columnIndex);
	}
	
	protected function clearColumnHandler(e : ContextMenuEvent) : void
	{
		var cells : Vector.<Cell> = this.cells;
		
		for each (var c : Cell in cells)
			if (c !== cell)
				host.clearColumnAt(c.columnIndex);
		
		host.clearColumnAt(cell.columnIndex);
	}
	
	protected function clearCellHandler(e : ContextMenuEvent) : void
	{
		var cells : Vector.<Cell> = this.cells;
		
		for (var i : int, n : int = cells.length; i < n; ++i)
			cells[i].clear();
		
		cell.clear();
	}
	
	public function cutHandler(e : ContextMenuEvent = null) : void
	{
		var cells : Vector.<Cell> = this.cells;
		
		clipboard.range = Vector.<Cell>(ObjectUtil.copy(cells));
		
		for (var i : int, n : int = cells.length; i < n; ++i)
			cells[i].clear();
		
		cell.clear();
	}
	
	public function copyHandler(e : ContextMenuEvent = null) : void
	{
		clipboard.range = Vector.<Cell>(ObjectUtil.copy(cells));
	}
	
	public function pasteHandler(e : ContextMenuEvent = null) : void
	{
		applyChanges(null, cell);
	}
	
	public function pasteSpecialHandler(e : ContextMenuEvent = null) : void
	{
		createPopup(PastePopup);
	}
	
	public function applyChanges(method : String, cell : Cell) : void
	{
		if (!cell)
			return;
		
		var cells : Vector.<Cell> = clipboard.range;
		
		if(!cells)
			return;
		
		var o : Object;
		
		var i : uint = 1, n : uint = cells.length;
		var target : Cell = cells[0];
		var startColumn : uint = target.columnIndex, startRow : uint = target.rowIndex;
		var endColumn : uint, endRow : uint;
		
		for (; i < n; ++i)
		{
			target = cells[i];
			
			startColumn = Math.min(startColumn, target.columnIndex);
			startRow = Math.min(startRow, target.rowIndex);
			
			endColumn = Math.max(endColumn, target.bounds.right);
			endRow = Math.max(endRow, target.bounds.bottom);
		}
		
		var offset : Point = new Point(cell.bounds.x - startColumn, cell.bounds.y - startRow);
		
		endColumn += startColumn + offset.x + 1;
		endRow += startRow + offset.y;
		
		if(endColumn > host.columnCount)
			host.columnCount = endColumn;
		
		if(endRow > host.rowCount)
			host.rowCount = endRow;
		
		host.validateProperties();
		
		for (i = 0; i < n; ++i)
		{
			target = host.getCellAt(cells[i].bounds.x + offset.x, cells[i].bounds.y + offset.y);
			
			if (target)
			{
				if (!method)
					target.assign(cells[i]);
				else
				{
					o = {};
					
					o[method] = cells[i][method];
					
					target.assignObject(o);
				}
				
				if (!method || method == "expression")
					target.expression = Utils.moveExpression(cells[i].controlObject, offset.x, offset.y);
			}
		}
	}
	
	protected function disableHandler(e : ContextMenuEvent) : void
	{
		host.disabledCells = cell.enabled ? cells : null;
	}
	
	protected function setCellStylesHandler(e : ContextMenuEvent) : void
	{
		var popup:StylesPopup = StylesPopup(createPopup(StylesPopup));
		popup.title = "Set cell styles";
	}
	
	protected function setConditionalStylesHandler(e : ContextMenuEvent) : void
	{
		createPopup(ConditionalStylesPopup);
	}
	
	protected function setGlobalStylesHandler(e : ContextMenuEvent) : void
	{
		var popup:StylesPopup = StylesPopup(createPopup(StylesPopup, false));
		popup.cell = host.globalCell;
		popup.title = "Set global styles";
	}
	
	protected function setSizeHandler(e : ContextMenuEvent) : void
	{
		createPopup(SizePopup);
	}
	
	protected function allowPasteHandler(e : Event = null) : void
	{
		paste.enabled = pasteSpecial.enabled = clipboard.allowPaste;
	}
	
	protected function createPopup(type : Class, populate:Boolean = true) : BasePopup
	{
		if (popup)
			PopUpManager.removePopUp(popup);
		
		popup = new type();
		popup.grid = host;
		
		if(populate)
		{
		popup.cells = cells;
		popup.cell = cell || cells[0];
		}
		
		PopUpManager.addPopUp(popup, popup.grid);
		PopUpManager.centerPopUp(popup);
		
		return popup;
	}
	
	protected function get cells() : Vector.<Cell>
	{
		var items : Vector.<Object> = host.grid.selectedItems;
		
		return items && items.length > 0
			? Vector.<Cell>(items)
			: new <Cell>[cell];
	}
}
}