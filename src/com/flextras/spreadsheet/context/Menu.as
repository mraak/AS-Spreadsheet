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

/**
 * Custom context menu used both by Spreadsheet and its cells.
 */
public class Menu implements IFlexContextMenu
{
	//--------------------------------------------------------------------------
	//
	//  Constants
	//
	//--------------------------------------------------------------------------
	
	/**
	 * @private
	 */
	public const cut : ContextMenuItem = new ContextMenuItem ("Cut ");
	
	/**
	 * @private
	 */
	public const copy : ContextMenuItem = new ContextMenuItem ("Copy ");
	
	/**
	 * @private
	 */
	public const paste : ContextMenuItem = new ContextMenuItem ("Paste ");
	
	/**
	 * @private
	 */
	public const pasteSpecial : ContextMenuItem = new ContextMenuItem ("Paste special");
	
	/**
	 * @private
	 */
	public const disable : ContextMenuItem = new ContextMenuItem ("Disable Cell");
	
	/**
	 * @private
	 */
	public const setCellStyles : ContextMenuItem = new ContextMenuItem ("Formatting", true);
	
	/**
	 * @private
	 */
	public const setConditionalStyles : ContextMenuItem = new ContextMenuItem ("Conditional Formatting");
	
	/**
	 * @private
	 */
	public const setGlobalStyles : ContextMenuItem = new ContextMenuItem ("Global formatting", true);
	
	/**
	 * @private
	 */
	public const setSize : ContextMenuItem = new ContextMenuItem ("Set size", true);
	
	/**
	 * @private
	 */
	public const addRow : ContextMenuItem = new ContextMenuItem ("Insert row", true);
	
	/**
	 * @private
	 */
	public const removeRow : ContextMenuItem = new ContextMenuItem ("Remove row");
	
	/**
	 * @private
	 */
	public const clearRow : ContextMenuItem = new ContextMenuItem ("Clear row");
	
	/**
	 * @private
	 */
	public const addColumn : ContextMenuItem = new ContextMenuItem ("Insert column", true);
	
	/**
	 * @private
	 */
	public const removeColumn : ContextMenuItem = new ContextMenuItem ("Remove column");
	
	/**
	 * @private
	 */
	public const clearColumn : ContextMenuItem = new ContextMenuItem ("Clear column");
	
	/**
	 * @private
	 */
	public const clearCell : ContextMenuItem = new ContextMenuItem ("Clear cell", true);
	
	//--------------------------------------------------------------------------
	//
	//  Variables
	//
	//--------------------------------------------------------------------------
	
	/**
	 * @private
	 */
	protected var menu : ContextMenu;
	
	/**
	 * @private
	 */
	protected var popup : BasePopup;
	
	/**
	 * @private
	 */
	protected var clipboard : ClipboardData;
	
	/**
	 * @private
	 */
	public var cell : Cell;
	
	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------
	
	/**
	 * Constructor.
	 *
	 * @param cell Reference to selected cell.
	 */
	public function Menu (cell : Cell)
	{
		this.cell = cell;
		
		clipboard = ClipboardData.instance;
		
		allowPasteHandler ();
	}
	
	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------
	
	//----------------------------------
	//  target
	//----------------------------------
	
	/**
	 * @private
	 */
	private var _target : InteractiveObject;
	
	/**
	 * Reference to selected item renderer
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
		if (target === value)
			return;
		
		if (target)
		{
			clipboard.removeEventListener ("allowPasteChanged", allowPasteHandler);
			
			addRow.removeEventListener (ContextMenuEvent.MENU_ITEM_SELECT, addRowHandler);
			removeRow.removeEventListener (ContextMenuEvent.MENU_ITEM_SELECT, removeRowHandler);
			clearRow.removeEventListener (ContextMenuEvent.MENU_ITEM_SELECT, clearRowHandler);
			addColumn.removeEventListener (ContextMenuEvent.MENU_ITEM_SELECT, addColumnHandler);
			removeColumn.removeEventListener (ContextMenuEvent.MENU_ITEM_SELECT, removeColumnHandler);
			clearColumn.removeEventListener (ContextMenuEvent.MENU_ITEM_SELECT, clearColumnHandler);
			clearCell.removeEventListener (ContextMenuEvent.MENU_ITEM_SELECT, clearCellHandler);
			cut.removeEventListener (ContextMenuEvent.MENU_ITEM_SELECT, cutHandler);
			copy.removeEventListener (ContextMenuEvent.MENU_ITEM_SELECT, copyHandler);
			paste.removeEventListener (ContextMenuEvent.MENU_ITEM_SELECT, pasteHandler);
			pasteSpecial.removeEventListener (ContextMenuEvent.MENU_ITEM_SELECT, pasteSpecialHandler);
			disable.removeEventListener (ContextMenuEvent.MENU_ITEM_SELECT, disableHandler);
			setCellStyles.removeEventListener (ContextMenuEvent.MENU_ITEM_SELECT, setCellStylesHandler);
			setConditionalStyles.removeEventListener (ContextMenuEvent.MENU_ITEM_SELECT, setConditionalStylesHandler);
			setGlobalStyles.addEventListener (ContextMenuEvent.MENU_ITEM_SELECT, setGlobalStylesHandler);
			setSize.removeEventListener (ContextMenuEvent.MENU_ITEM_SELECT, setSizeHandler);
		}
		
		_target = value;
		
		if (value)
		{
			clipboard.addEventListener ("allowPasteChanged", allowPasteHandler);
			
			addRow.addEventListener (ContextMenuEvent.MENU_ITEM_SELECT, addRowHandler);
			removeRow.addEventListener (ContextMenuEvent.MENU_ITEM_SELECT, removeRowHandler);
			clearRow.addEventListener (ContextMenuEvent.MENU_ITEM_SELECT, clearRowHandler);
			addColumn.addEventListener (ContextMenuEvent.MENU_ITEM_SELECT, addColumnHandler);
			removeColumn.addEventListener (ContextMenuEvent.MENU_ITEM_SELECT, removeColumnHandler);
			clearColumn.addEventListener (ContextMenuEvent.MENU_ITEM_SELECT, clearColumnHandler);
			clearCell.addEventListener (ContextMenuEvent.MENU_ITEM_SELECT, clearCellHandler);
			cut.addEventListener (ContextMenuEvent.MENU_ITEM_SELECT, cutHandler);
			copy.addEventListener (ContextMenuEvent.MENU_ITEM_SELECT, copyHandler);
			paste.addEventListener (ContextMenuEvent.MENU_ITEM_SELECT, pasteHandler);
			pasteSpecial.addEventListener (ContextMenuEvent.MENU_ITEM_SELECT, pasteSpecialHandler);
			disable.addEventListener (ContextMenuEvent.MENU_ITEM_SELECT, disableHandler);
			setCellStyles.addEventListener (ContextMenuEvent.MENU_ITEM_SELECT, setCellStylesHandler);
			setConditionalStyles.addEventListener (ContextMenuEvent.MENU_ITEM_SELECT, setConditionalStylesHandler);
			setGlobalStyles.addEventListener (ContextMenuEvent.MENU_ITEM_SELECT, setGlobalStylesHandler);
			setSize.addEventListener (ContextMenuEvent.MENU_ITEM_SELECT, setSizeHandler);
			
			menu = new ContextMenu ();
			menu.hideBuiltInItems ();
			
			menu.customItems = [cut, copy, paste, pasteSpecial,
				clearCell, disable, setCellStyles, setConditionalStyles, setGlobalStyles, setSize,
				addRow, removeRow, clearRow, addColumn, removeColumn, clearColumn];
			
			value.contextMenu = menu;
		}
	}
	
	//----------------------------------
	//  cells
	//----------------------------------
	
	/**
	 * @private
	 */
	protected function get cells () : Vector.<Cell>
	{
		var items : Vector.<Object> = cell.owner.grid.selectedItems;
		
		return items && items.length > 0
			? Vector.<Cell> (items)
			: new <Cell>[cell];
	}
	
	//--------------------------------------------------------------------------
	//
	//  Methods
	//
	//--------------------------------------------------------------------------
	
	//----------------------------------
	//  setContextMenu
	//----------------------------------
	
	/**
	 * @inheritDoc
	 */
	public function setContextMenu (component : InteractiveObject) : void
	{
		target = component;
	}
	
	//----------------------------------
	//  unsetContextMenu
	//----------------------------------
	
	/**
	 * @inheritDoc
	 */
	public function unsetContextMenu (component : InteractiveObject) : void
	{
		//target = null;
	}
	
	//----------------------------------
	//  createPopup
	//----------------------------------
	
	/**
	 * @private
	 */
	protected function createPopup (type : Class, populate : Boolean = true) : BasePopup
	{
		if (popup)
			PopUpManager.removePopUp (popup);
		
		popup = new type ();
		popup.grid = cell.owner;
		
		if (populate)
		{
			popup.cells = cells;
			popup.cell = cell || cells[0];
		}
		
		PopUpManager.addPopUp (popup, popup.grid);
		PopUpManager.centerPopUp (popup);
		
		return popup;
	}
	
	//--------------------------------------------------------------------------
	//
	//  Event handlers
	//
	//--------------------------------------------------------------------------
	
	//----------------------------------
	//  addRowHandler
	//----------------------------------
	
	/**
	 * @private
	 */
	protected function addRowHandler (e : ContextMenuEvent) : void
	{
		var cells : Vector.<Cell> = this.cells;
		
		for (var i : uint, n : uint = cells.length, c : Cell; i < n; ++i)
		{
			c = cells[i];
			
			if (!c.bounds.equals (cell.bounds))
				cell.owner.insertRowAt (c.rowIndex);
		}
		
		cell.owner.insertRowAt (cell.rowIndex);
	}
	
	//----------------------------------
	//  removeRowHandler
	//----------------------------------
	
	/**
	 * @private
	 */
	protected function removeRowHandler (e : ContextMenuEvent) : void
	{
		var cells : Vector.<Cell> = this.cells;
		
		for (var i : uint, n : uint = cells.length, c : Cell; i < n; ++i)
		{
			c = cells[i];
			
			if (!c.bounds.equals (cell.bounds))
				cell.owner.removeRowAt (c.rowIndex);
		}
		
		cell.owner.removeRowAt (cell.rowIndex);
	}
	
	//----------------------------------
	//  clearRowHandler
	//----------------------------------
	
	/**
	 * @private
	 */
	protected function clearRowHandler (e : ContextMenuEvent) : void
	{
		var cells : Vector.<Cell> = this.cells;
		
		for (var i : uint, n : uint = cells.length, c : Cell; i < n; ++i)
		{
			c = cells[i];
			
			if (!c.bounds.equals (cell.bounds))
				cell.owner.clearRowAt (c.rowIndex);
		}
		
		cell.owner.clearRowAt (cell.rowIndex);
	}
	
	//----------------------------------
	//  addColumnHandler
	//----------------------------------
	
	/**
	 * @private
	 */
	protected function addColumnHandler (e : ContextMenuEvent) : void
	{
		var cells : Vector.<Cell> = this.cells;
		
		for (var i : uint, n : uint = cells.length, c : Cell; i < n; ++i)
		{
			c = cells[i];
			
			if (!c.bounds.equals (cell.bounds))
				cell.owner.insertColumnAt (c.columnIndex);
		}
		
		cell.owner.insertColumnAt (cell.columnIndex);
	}
	
	//----------------------------------
	//  removeColumnHandler
	//----------------------------------
	
	/**
	 * @private
	 */
	protected function removeColumnHandler (e : ContextMenuEvent) : void
	{
		var cells : Vector.<Cell> = this.cells;
		
		for (var i : uint, n : uint = cells.length, c : Cell; i < n; ++i)
		{
			c = cells[i];
			
			if (!c.bounds.equals (cell.bounds))
				cell.owner.removeColumnAt (c.columnIndex);
		}
		
		cell.owner.removeColumnAt (cell.columnIndex);
	}
	
	//----------------------------------
	//  clearColumnHandler
	//----------------------------------
	
	/**
	 * @private
	 */
	protected function clearColumnHandler (e : ContextMenuEvent) : void
	{
		var cells : Vector.<Cell> = this.cells;
		
		for (var i : uint, n : uint = cells.length, c : Cell; i < n; ++i)
		{
			c = cells[i];
			
			if (!c.bounds.equals (cell.bounds))
				cell.owner.clearColumnAt (c.columnIndex);
		}
		
		cell.owner.clearColumnAt (cell.columnIndex);
	}
	
	//----------------------------------
	//  clearCellHandler
	//----------------------------------
	
	/**
	 * @private
	 */
	protected function clearCellHandler (e : ContextMenuEvent) : void
	{
		var cells : Vector.<Cell> = this.cells;
		
		for (var i : int, n : int = cells.length; i < n; ++i)
			cells[i].clear ();
		
		cell.clear ();
	}
	
	//----------------------------------
	//  cutHandler
	//----------------------------------
	
	/**
	 * @private
	 */
	public function cutHandler (e : ContextMenuEvent = null) : void
	{
		var cells : Vector.<Cell> = this.cells;
		
		clipboard.range = Vector.<Cell> (ObjectUtil.copy (cells));
		clipboard.copy = false;
		
		for (var i : int, n : int = cells.length; i < n; ++i)
			cells[i].clear ();
		
		cell.clear ();
	}
	
	//----------------------------------
	//  copyHandler
	//----------------------------------
	
	/**
	 * @private
	 */
	public function copyHandler (e : ContextMenuEvent = null) : void
	{
		clipboard.range = Vector.<Cell> (ObjectUtil.copy (cells));
		clipboard.copy = true;
	}
	
	//----------------------------------
	//  pasteHandler
	//----------------------------------
	
	/**
	 * @private
	 */
	public function pasteHandler (e : ContextMenuEvent = null) : void
	{
		cell.owner.moveCells (clipboard.range, new Point (cell.columnIndex, cell.rowIndex), clipboard.copy);
	}
	
	//----------------------------------
	//  pasteSpecialHandler
	//----------------------------------
	
	/**
	 * @private
	 */
	public function pasteSpecialHandler (e : ContextMenuEvent = null) : void
	{
		createPopup (PastePopup);
	}
	
	//----------------------------------
	//  disableHandler
	//----------------------------------
	
	/**
	 * @private
	 */
	protected function disableHandler (e : ContextMenuEvent) : void
	{
		cell.owner.disabledCells = cell.enabled ? cells : null;
	}
	
	//----------------------------------
	//  setCellStylesHandler
	//----------------------------------
	
	/**
	 * @private
	 */
	protected function setCellStylesHandler (e : ContextMenuEvent) : void
	{
		var popup : StylesPopup = StylesPopup (createPopup (StylesPopup));
		popup.title = "Set cell styles";
	}
	
	//----------------------------------
	//  setConditionalStylesHandler
	//----------------------------------
	
	/**
	 * @private
	 */
	protected function setConditionalStylesHandler (e : ContextMenuEvent) : void
	{
		createPopup (ConditionalStylesPopup);
	}
	
	//----------------------------------
	//  setGlobalStylesHandler
	//----------------------------------
	
	/**
	 * @private
	 */
	protected function setGlobalStylesHandler (e : ContextMenuEvent) : void
	{
		var popup : StylesPopup = StylesPopup (createPopup (StylesPopup, false));
		popup.cell = cell.owner.globalCell;
		popup.title = "Set global styles";
	}
	
	//----------------------------------
	//  setSizeHandler
	//----------------------------------
	
	/**
	 * @private
	 */
	protected function setSizeHandler (e : ContextMenuEvent) : void
	{
		createPopup (SizePopup);
	}
	
	//----------------------------------
	//  allowPasteHandler
	//----------------------------------
	
	/**
	 * @private
	 */
	protected function allowPasteHandler (e : Event = null) : void
	{
		paste.enabled = pasteSpecial.enabled = clipboard.allowPaste;
	}
}
}