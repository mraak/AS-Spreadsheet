package com.flextras.context
{
import com.flextras.calc.ControlObject;
import com.flextras.calc.Utils;
import com.flextras.paintgrid.CellProperties;
import com.flextras.spreadsheet.Spreadsheet;

import flash.display.InteractiveObject;
import flash.events.ContextMenuEvent;
import flash.events.Event;
import flash.geom.Point;
import flash.net.SharedObject;
import flash.ui.ContextMenuItem;
import flash.utils.ByteArray;

import mx.core.mx_internal;
import mx.managers.PopUpManager;

use namespace mx_internal;

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
	
	protected const setGlobalStyles : ContextMenuItem = new ContextMenuItem("Global Styles");
	
	protected const setColumnWidth : ContextMenuItem = new ContextMenuItem("Set Column Width", true);
	
	protected const setRowHeight : ContextMenuItem = new ContextMenuItem("Set Row Height");
	
	protected const removeRow : ContextMenuItem = new ContextMenuItem("Remove Row", true);
	
	protected const removeColumn : ContextMenuItem = new ContextMenuItem("Remove Column");
	
	protected var popup : BasePopup;
	
	public function LocalContextMenu ()
	{
		super();
	}
	
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
	
	protected function removeRowHandler (e : ContextMenuEvent) : void
	{
		if (owner.selectedCells && owner.selectedCells.length > 0)
			for each (var c : CellProperties in owner.selectedCells)
				owner.removeRow(c.row);
		else
			owner.removeRow(cell.row);
	}
	
	protected function removeColumnHandler (e : ContextMenuEvent) : void
	{
		if (owner.selectedCells && owner.selectedCells.length > 0)
			for each (var c : CellProperties in owner.selectedCells)
				owner.removeColumn(c.column);
		else
			owner.removeColumn(cell.column);
	}
	
	protected function cutHandler (e : ContextMenuEvent) : void
	{
		var c : ClipboardData = new ClipboardData();
		c.location = new Point(cell.column, cell.row);
		c.range = setRange();
		
		var ba : ByteArray = new ByteArray();
		ba.writeObject(c);
		ba.compress();
		
		var so : SharedObject = SharedObject.getLocal("spreadsheetClipboard");
		so.data.content = ba;
		so.flush();
	}
	
	protected function copyHandler (e : ContextMenuEvent) : void
	{
		var c : ClipboardData = new ClipboardData();
		c.location = new Point(cell.column, cell.row);
		c.range = setRange();
		c.performCopy = true;
		
		var ba : ByteArray = new ByteArray();
		ba.writeObject(c);
		ba.compress();
		
		var so : SharedObject = SharedObject.getLocal("spreadsheetClipboard");
		so.data.content = ba;
		so.flush();
	}
	
	protected function pasteHandler (e : ContextMenuEvent) : void
	{
		var so : SharedObject = SharedObject.getLocal("spreadsheetClipboard");
		var ba : ByteArray = so.data.content;
		ba.uncompress();
		var c : ClipboardData = ba.readObject() as ClipboardData;
		var range : Array = getRange(c.range);
		
		if (owner is Spreadsheet && c)
		{
			var pss : Spreadsheet = Spreadsheet(owner);
			
			var x : int = cell.column - c.location.x;
			var y : int = cell.row - c.location.y;
			
			pss.moveRange(range, x, y, c.performCopy);
		}
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
		if (owner.selectedCells && owner.selectedCells.length > 0)
		{
			for each (var c : CellProperties in owner.selectedCells)
				c.menu.disable.caption = c.menu.disable.caption == "Disable Cell" ? "Enable Cell" : "Disable Cell";
			
			owner.disabledCells = [owner.selectedCells];
		}
		else
		{
			disable.caption = disable.caption == "Disable Cell" ? "Enable Cell" : "Disable Cell";
			owner.disabledCells = [cell];
		}
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
		var allow : Boolean = cell && cell.selected;
		cut.enabled = allow;
		copy.enabled = allow;
		
		/*if (owner is Spreadsheet)
		   {
		   var pss : Spreadsheet = Spreadsheet(owner);
		   allow = pss.dx > -1 && pss.dy > -1 && pss.allowPaste;
		   }
		 else*/
		//allow = false;
		
		paste.enabled = allow;
		pasteValue.enabled = allow;
		pasteStyles.enabled = allow;
		pasteExpressions.enabled = allow;
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
		removeColumn.enabled = value;
		/*cut.enabled = value;
		   copy.enabled = value;
		   paste.enabled = value;
		   pasteValue.enabled = value;
		   pasteStyles.enabled = value;
		   pasteExpressions.enabled = value;
		 disable.enabled = value;*/
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
		
		setGlobalStyles.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, setGlobalStylesHandler);
		
		menu.customItems = [cut, copy, paste, pasteValue, pasteStyles, pasteExpressions,
							disable, setCellStyles, setGlobalStyles, setColumnWidth, setRowHeight, removeRow, removeColumn];
	}
	
	override public function unsetContextMenu (component : InteractiveObject) : void
	{
		super.unsetContextMenu(component);
		
		removeRow.removeEventListener(ContextMenuEvent.MENU_ITEM_SELECT, removeRowHandler);
		removeColumn.removeEventListener(ContextMenuEvent.MENU_ITEM_SELECT, removeColumnHandler);
		cut.removeEventListener(ContextMenuEvent.MENU_ITEM_SELECT, cutHandler);
		copy.removeEventListener(ContextMenuEvent.MENU_ITEM_SELECT, copyHandler);
		paste.removeEventListener(ContextMenuEvent.MENU_ITEM_SELECT, pasteHandler);
		pasteValue.removeEventListener(ContextMenuEvent.MENU_ITEM_SELECT, pasteValueHandler);
		pasteStyles.removeEventListener(ContextMenuEvent.MENU_ITEM_SELECT, pasteStylesHandler);
		pasteExpressions.removeEventListener(ContextMenuEvent.MENU_ITEM_SELECT, pasteExpressionsHandler);
		disable.removeEventListener(ContextMenuEvent.MENU_ITEM_SELECT, disableHandler);
		setCellStyles.removeEventListener(ContextMenuEvent.MENU_ITEM_SELECT, setCellStylesHandler);
		setColumnWidth.removeEventListener(ContextMenuEvent.MENU_ITEM_SELECT, setColumnWidthHandler);
		setRowHeight.removeEventListener(ContextMenuEvent.MENU_ITEM_SELECT, setRowHeightHandler);
		setGlobalStyles.removeEventListener(ContextMenuEvent.MENU_ITEM_SELECT, setGlobalStylesHandler);
		
		menu.customItems = null;
	}
	
	protected function getRange (keys : Array) : Array
	{
		if (!(owner is Spreadsheet))
			return null;
		
		var ss : Spreadsheet = Spreadsheet(owner);
		
		var co : ControlObject;
		var range : Array = [];
		
		for each (var key : String in keys)
		{
			co = ss.ctrlObjects[key];
			
			if (co)
				range.push(co);
		}
		
		return range;
	}
	
	protected function setRange () : Array
	{
		if (!(owner is Spreadsheet))
			return null;
		
		var prop : String, id : String, co : ControlObject;
		var cells : Array = owner.selectedCells || [cell];
		var ss : Spreadsheet = Spreadsheet(owner);
		var range : Array = [];
		
		for each (var cell : CellProperties in cells)
		{
			prop = String(Utils.alphabet[cell.column]).toLowerCase();
			id = prop + cell.row;
			
			co = ss.ctrlObjects[id];
			
			if (co)
				range.push(id);
		}
		
		return range;
	}
}
}