package com.flextras.paintgrid
{
import flash.display.Sprite;
import flash.events.Event;

import mx.controls.DataGrid;
import mx.controls.dataGridClasses.DataGridColumn;
import mx.controls.listClasses.IListItemRenderer;
import mx.controls.listClasses.ListBaseContentHolder;
import mx.controls.listClasses.ListRowInfo;
import mx.core.ClassFactory;
import mx.core.ScrollPolicy;
import mx.core.mx_internal;
import mx.events.CollectionEvent;
import mx.events.CollectionEventKind;
import mx.events.TweenEvent;
import mx.utils.ObjectProxy;

use namespace mx_internal;

public class PaintGrid extends DataGrid
{
	public function PaintGrid ()
	{
		super();
		
		//headerClass = PaintGridEmptyColumnHeader;
		//lockedColumnCount = 1;
		variableRowHeight = true;
		allowMultipleSelection = true;
		horizontalScrollPolicy = ScrollPolicy.AUTO; // !!
		itemRenderer = new ClassFactory(PaintGridColumnItemRenderer);
	}
	
	protected var lockedColumnCountChanged : Boolean;
	
	override public function set lockedColumnCount (value : int) : void
	{
		super.lockedColumnCount = value;
		lockedColumnCountChanged = true;
		
		invalidateDisplayList();
	}
	
	override protected function moveSelectionVertically (code : uint, shiftKey : Boolean, ctrlKey : Boolean) : void
	{
		super.moveSelectionVertically(code, shiftKey, ctrlKey);
	}
	
	override protected function moveSelectionHorizontally (code : uint, shiftKey : Boolean, ctrlKey : Boolean) : void
	{
		super.moveSelectionHorizontally(code, shiftKey, ctrlKey);
	}
	
	protected var selectedCells : Array = [];
	
	override protected function selectItem (item : IListItemRenderer, shiftKey : Boolean, ctrlKey : Boolean, transition : Boolean = true) : Boolean
	{
		var retval : Boolean = super.selectItem(item, shiftKey, ctrlKey, transition);
		
		var currentCell : CellProperties, oldCell : CellProperties = selectedCellProperties;
		var i : int, arr : Array;
		var start : CellLocation, end : CellLocation;
		var cells : Array, cell : CellProperties;
		
		if (item is PaintGridColumnItemRenderer)
			currentCell = PaintGridColumnItemRenderer(item).cell;
		
		if (!currentCell)
			return retval;
		
		if (!ctrlKey && !shiftKey)
		{
			/*if (oldCell && oldCell.owner)
			 oldCell.selected = false;*/
			
			while (selectedCells.length)
			{
				cell = selectedCells.pop();
				cell.selected = false;
			}
			
			selectedCells.push(currentCell);
			currentCell.selected = true;
		}
		else if (ctrlKey && shiftKey)
		{
			start = selectedCellProperties || new CellLocation(), end = currentCell;
			cells = getAllCellPropertiesInRangeBy(start, end, false);
			
			for each (cell in cells)
				if ((i = selectedCells.indexOf(cell)) > -1)
				{
					arr = selectedCells.splice(i, 1);
					
					while (arr.length)
					{
						cell = arr.pop();
						cell.selected = false;
					}
				}
		}
		else if (ctrlKey && !shiftKey)
		{
			if (oldCell === currentCell)
				currentCell.selected = !currentCell.selected;
			else if ((i = selectedCells.indexOf(currentCell)) > -1)
			{
				arr = selectedCells.splice(i, 1);
				arr[0].selected = false;
			}
			else
			{
				selectedCells.push(currentCell);
				currentCell.selected = true;
			}
		}
		else if (shiftKey && !ctrlKey)
		{
			start = selectedCellProperties || new CellLocation(), end = currentCell;
			cells = getAllCellPropertiesInRangeBy(start, end, false);
			
			for each (cell in cells)
				if ((i = selectedCells.indexOf(cell)) < 0)
				{
					selectedCells.push(cell);
					cell.selected = true;
				}
		}
		
		selectedCellProperties = currentCell;
		
		return retval;
	}
	
	/*override protected function updateDisplayList (unscaledWidth : Number, unscaledHeight : Number) : void
	   {
	   if (headerVisible && header)
	   {
	   header.visibleColumns = visibleColumns;
	   header.headerItemsChanged = true;
	   header.invalidateSize();
	   header.validateNow();
	   }
	
	   if (lockedColumnCountChanged)
	   {
	   lockedColumnCountChanged = false;
	
	   if (lockedColumnCount > 0 && !lockedColumnContent)
	   {
	   lockedColumnHeader = new PaintGridEmptyColumnHeader();
	   lockedColumnHeader.styleName = this;
	   addChild(lockedColumnHeader);
	   lockedColumnAndRowContent = new DataGridLockedRowContentHolder(this);
	   lockedColumnAndRowContent.styleName = this;
	   addChild(lockedColumnAndRowContent)
	   lockedColumnContent = new ListBaseContentHolder(this);
	   lockedColumnContent.styleName = this;
	   addChild(lockedColumnContent);
	   }
	   }
	
	   super.updateDisplayList(unscaledWidth, unscaledHeight);
	 }*/
	
	override protected function drawSelectionIndicator (indicator : Sprite, x : Number, y : Number, width : Number, height : Number, color : uint, itemRenderer : IListItemRenderer) : void
	{
	
	}
	
	/*override protected function makeRowsAndColumns (left : Number, top : Number, right : Number, bottom : Number, firstColumn : int, firstRow : int, byCount : Boolean = false, rowsNeeded : uint = 0) : Point
	   {
	   return super.makeRowsAndColumns(left, top, right, bottom, firstColumn, firstRow, byCount, rowsNeeded);
	 }*/
	
	/**
	 * Styling API
	 */
	
	[ArrayElementType("CellProperties")]
	protected var cells : Array = [];
	
	[ArrayElementType("CellProperties")]
	protected var modifiedCells : Array = [];
	
	/**
	 * Array of CellProperties
	 */
	
	/*public function getAllCellProperties (fromUser : Boolean = true) : Array
	   {
	   return fromUser ? modifiedCells : cells;
	   }
	
	   public function setAllCellProperties (cells : Array) : void
	   {
	   for each (var cell : CellProperties in cells)
	   setCellProperties(cell);
	 }*/
	
	protected var _selectedCell : CellProperties;
	
	[Bindable(event="selectedCellPropertiesChange")]
	
	/**
	 *
	 * Returns currently selected cell properties
	 *
	 * @return
	 *
	 */
	
	public function get selectedCellProperties () : CellProperties
	{
		return _selectedCell;
	}
	
	public function set selectedCellProperties (cell : CellProperties) : void
	{
		if (_selectedCell === cell)
			return;
		
		_selectedCell = cell;
		
		dispatchEvent(new Event("selectedCellPropertiesChange"));
	}
	
	/**
	 * Instance of CellProperties
	 */
	
	public function getCellProperties (at : CellLocation, fromUser : Boolean = true) : CellProperties
	{
		if (!at || !at.valid)
			return null;
		
		var cells : Array = fromUser ? modifiedCells : this.cells;
		
		for each (var cell : CellProperties in cells)
			if (cell.equalLocation(at))
				return cell;
		
		return null;
	}
	
	public function getCellPropertiesAt (row : int, column : int, fromUser : Boolean = true) : CellProperties
	{
		var location : CellLocation = new CellLocation(row, column);
		
		return getCellProperties(location, fromUser);
	}
	
	public function setCellProperties (value : CellProperties) : void
	{
		if (!value || !value.valid)
			return;
		
		for each (var cell : CellProperties in cells)
			if (cell.equalLocation(value))
			{
				cell.styles = value.styles;
				cell.rollOverStyles = value.rollOverStyles;
				cell.selectedStyles = value.selectedStyles;
				cell.disabledStyles = value.disabledStyles;
				
				if (!cell in modifiedCells)
					modifiedCells.push(cell);
				
				return;
			}
	}
	
	public function setCellPropertiesAt (row : int, column : int, styles : Object = null, rollOverStyles : Object = null, selectedStyles : Object = null, disabledStyles : Object = null) : void
	{
		var cell : CellProperties = new CellProperties(row, column, styles, rollOverStyles, selectedStyles, disabledStyles);
		
		setCellProperties(cell);
	}
	
	/**
	 * wrappers
	 */
	
	public function getCellStyles (at : CellLocation, fromUser : Boolean = true) : Object
	{
		var cell : CellProperties = getCellProperties(at, fromUser);
		
		if (!cell)
			return null;
		
		return cell.styles;
	}
	
	public function getCellStylesAt (row : int, column : int, fromUser : Boolean = true) : Object
	{
		var location : CellLocation = new CellLocation(row, column);
		
		return getCellStyles(location, fromUser);
	}
	
	public function setCellStyles (location : CellLocation, styles : Object = null) : void
	{
		if (!location || !location.valid)
			return;
		
		setCellStylesAt(location.row, location.column, styles);
	}
	
	public function setCellStylesAt (row : int, column : int, styles : Object = null) : void
	{
		var cell : CellProperties = new CellProperties(row, column, styles);
		
		setCellProperties(cell);
	}
	
	public function getCellRollOverStyles (at : CellLocation, fromUser : Boolean = true) : Object
	{
		var cell : CellProperties = getCellProperties(at, fromUser);
		
		if (!cell)
			return null;
		
		return cell.rollOverStyles;
	}
	
	public function getCellRollOverStylesAt (row : int, column : int, fromUser : Boolean = true) : Object
	{
		var location : CellLocation = new CellLocation(row, column);
		
		return getCellRollOverStyles(location, fromUser);
	}
	
	public function setCellRollOverStyles (location : CellLocation, styles : Object = null) : void
	{
		if (!location || !location.valid)
			return;
		
		setCellRollOverStylesAt(location.row, location.column, styles);
	}
	
	public function setCellRollOverStylesAt (row : int, column : int, styles : Object = null) : void
	{
		var cell : CellProperties = new CellProperties(row, column, null, styles);
		
		setCellProperties(cell);
	}
	
	public function getCellSelectedStyles (at : CellLocation, fromUser : Boolean = true) : Object
	{
		var cell : CellProperties = getCellProperties(at, fromUser);
		
		if (!cell)
			return null;
		
		return cell.selectedStyles;
	}
	
	public function getCellSelectedStylesAt (row : int, column : int, fromUser : Boolean = true) : Object
	{
		var location : CellLocation = new CellLocation(row, column);
		
		return getCellSelectedStyles(location, fromUser);
	}
	
	public function setCellSelectedStyles (location : CellLocation, styles : Object = null) : void
	{
		if (!location || !location.valid)
			return;
		
		setCellSelectedStylesAt(location.row, location.column, styles);
	}
	
	public function setCellSelectedStylesAt (row : int, column : int, styles : Object = null) : void
	{
		var cell : CellProperties = new CellProperties(row, column, null, null, styles);
		
		setCellProperties(cell);
	}
	
	public function getCellDisabledStyles (at : CellLocation, fromUser : Boolean = true) : Object
	{
		var cell : CellProperties = getCellProperties(at, fromUser);
		
		if (!cell)
			return null;
		
		return cell.disabledStyles;
	}
	
	public function getCellDisabledStylesAt (row : int, column : int, fromUser : Boolean = true) : Object
	{
		var location : CellLocation = new CellLocation(row, column);
		
		return getCellDisabledStyles(location, fromUser);
	}
	
	public function setCellDisabledStyles (location : CellLocation, styles : Object = null) : void
	{
		if (!location || !location.valid)
			return;
		
		setCellDisabledStylesAt(location.row, location.column, styles);
	}
	
	public function setCellDisabledStylesAt (row : int, column : int, styles : Object = null) : void
	{
		var cell : CellProperties = new CellProperties(row, column, null, null, null, styles);
		
		setCellProperties(cell);
	}
	
	/**
	 * Array of CellProperties in Range
	 */
	
	public function getAllCellPropertiesInRange (range : CellRange, fromUser : Boolean = true) : Array
	{
		if (!range || !range.valid)
			return null;
		
		var result : Array;
		
		for each (var cell : CellProperties in cells)
			if (cell.inRange(range) && (fromUser || getCellProperties(cell, fromUser)))
			{
				if (!result)
					result = [];
				
				result.push(cell);
			}
		
		return result;
	}
	
	public function getAllCellPropertiesInRangeBy (start : CellLocation, end : CellLocation, fromUser : Boolean = true) : Array
	{
		var range : CellRange = new CellRange(start, end);
		
		return getAllCellPropertiesInRange(range, fromUser);
	}
	
	public function setAllCellPropertiesInRange (range : CellRange, styles : Object = null, rollOverStyles : Object = null, selectedStyles : Object = null, disabledStyles : Object = null) : void
	{
		if (!range || !range.valid)
			return;
		
		for each (var cell : CellProperties in cells)
			if (cell.inRange(range))
			{
				cell.styles = new ObjectProxy(styles);
				cell.rollOverStyles = new ObjectProxy(rollOverStyles);
				cell.selectedStyles = new ObjectProxy(selectedStyles);
				cell.disabledStyles = new ObjectProxy(disabledStyles);
				
				if (!cell in modifiedCells)
					modifiedCells.push(cell);
			}
	}
	
	public function setAllCellPropertiesInRangeBy (start : CellLocation, end : CellLocation, styles : Object = null, rollOverStyles : Object = null, selectedStyles : Object = null, disabledStyles : Object = null) : void
	{
		var range : CellRange = new CellRange(start, end);
		
		setAllCellPropertiesInRange(range, styles, rollOverStyles, selectedStyles, disabledStyles);
	}
	
	/**
	 * Disabled Cells API
	 */
	
	/**
	 * Returns empty array or array of disabled cells.
	 *
	 * @return
	 *
	 */
	
	public function get disabledCells () : Array
	{
		var result : Array = [];
		
		for each (var cell : CellProperties in cells)
			if (!cell.enabled)
				result.push(cell);
		
		return result;
	}
	
	/**
	 * value param can hold items of type Object, CellLocation, CellProperties
	 * If an item is of type Object it must contain both rowIndex and columnIndex.
	 *
	 * #Unless we're setting cell's enabled property via item of type CellProperties
	 * the value will toggle between true or false each time a match is found.
	 *
	 * @param value
	 *
	 */
	
	public function set disabledCells (value : Array) : void
	{
		if (!value || !value.length)
			return;
		
		var cell : CellProperties;
		
		for each (var o : Object in value)
			if ((cell = getCellProperties(o as CellLocation, false)) || (cell = getCellPropertiesAt(o.rowIndex, o.columnIndex, false)))
				cell.enabled = /*o is CellProperties ? CellProperties(o).enabled :*/ !cell.enabled;
	}
	
	/**
	 * Column width API
	 */
	
	[ArrayElementType("Column")]
	protected var columnWidths : Array = [];
	
	protected var columnWidthsChanged : Boolean;
	
	[Bindable(event="columnWidthChanged")]
	public function getColumnWidthAt (index : int) : Number
	{
		if (index < 0)
			return -1;
		
		/*for each (var column : Column in columnWidths)
		   if (column.index == index)
		 return column.width;*/
		
		var col : DataGridColumn = columns[index];
		
		return col ? col.width : -1;
	}
	
	public function setColumnWidthAt (index : int, value : Number) : void
	{
		if (index < 0 || value < 0)
			return;
		
		resizeColumn(index, value);
		
		dispatchEvent(new Event("columnWidthChanged"));
	
	/*for each (var column : Column in columnWidths)
	   if (column.index == index)
	   {
	   column.width = value;
	
	   columnWidthsChanged = true;
	
	   invalidateProperties();
	
	   return;
	   }
	
	   columnWidths.push(new Column(index, value));
	
	   columnWidthsChanged = true;
	
	 invalidateProperties();*/
	}
	
	/*override mx_internal function resizeColumn (col : int, w : Number) : void
	   {
	   super.resizeColumn(col, w);
	
	   dispatchEvent(new Event("columnWidthChanged"));
	 }*/
	
	/**
	 * Row height API
	 */
	
	[ArrayElementType("Row")]
	protected var rowHeights : Array = [];
	
	protected var rowHeightsChanged : Boolean;
	
	public function getRowHeightAt (index : int) : Number
	{
		if (value < 0)
			return -1;
		
		return measureHeightOfItems(index, 1);
		
		for each (var row : ListRowInfo in rowInfo)
			if (y == 0 && 0 == index || y > 0 && y / rowHeight == index)
				return row.height;
		
		return -1;
	}
	
	public function setRowHeightAt (index : int, value : Number) : void
	{
		if (index < 0 || value < 0)
			return;
		
		for each (var row : Row in rowHeights)
			if (row.index == index)
			{
				row.height = value;
				
				rowHeightsChanged = true;
				
				invalidateProperties();
				
				return;
			}
		
		rowHeights.push(new Row(index, value));
		
		rowHeightsChanged = true;
		
		invalidateProperties();
	}
	
	override protected function commitProperties () : void
	{
		super.commitProperties();
		
		/*if (columnWidthsChanged)
		   {
		   for each (var column : Column in columnWidths)
		   resizeColumn(column.index, column.width);
		
		   columnWidthsChanged = false;
		 }*/
		
		// TODO!!!
		if (rowHeightsChanged)
		{
			rowHeightsChanged = false;
		}
	}
	
	override protected function calculateRowHeight (data : Object, hh : Number, skipVisible : Boolean = false) : Number
	{
		return super.calculateRowHeight(data, hh, skipVisible);
	}
	
	override protected function setupColumnItemRenderer (c : DataGridColumn, contentHolder : ListBaseContentHolder, rowNum : int, colNum : int, data : Object, uid : String) : IListItemRenderer
	{
		var item : IListItemRenderer = super.setupColumnItemRenderer(c, contentHolder, rowNum, colNum, data, uid);
		
		if (!item)
			return null;
		
		item.styleName = this;
		
		if (item is PaintGridColumnItemRenderer)
		{
			PaintGridColumnItemRenderer(item).dataGrid = this;
			
			if (data.hasOwnProperty("cells"))
			{
				PaintGridColumnItemRenderer(item).cell = data.cells[colNum + horizontalScrollPosition];
				PaintGridColumnItemRenderer(item).cell.owner = item as PaintGridColumnItemRenderer;
			}
		}
		
		return item;
	}
	
	override mx_internal function shiftColumns (oldIndex : int, newIndex : int, trigger : Event = null) : void
	{
		super.shiftColumns(oldIndex, newIndex, trigger);
		
		if (newIndex >= 0 && oldIndex != newIndex)
		{
			var incr : int = oldIndex < newIndex ? 1 : -1;
			var i : int, j : int, cell : CellProperties;
			
			for each (var row : Object in collection)
			{
				for (i = oldIndex; i != newIndex; i += incr)
				{
					j = i + incr;
					cell = row.cells[i];
					row.cells[i] = row.cells[j];
					row.cells[j] = cell;
					row.cells[i].column = i;
					row.cells[j].column = j;
				}
			}
		}
	}
	
	override mx_internal function selectionTween_updateHandler (event : TweenEvent) : void
	{
	
	}
	
	override protected function collectionChangeHandler (event : Event) : void
	{
		super.collectionChangeHandler(event);
		
		if (!event is CollectionEvent)
			return;
		
		var ce : CollectionEvent = CollectionEvent(event);
		
		var row : int, rows : int, col : int, cols : int, cell : CellProperties;
		
		switch (ce.kind)
		{
			case CollectionEventKind.RESET:
				break;
			
			case CollectionEventKind.ADD:
				for (rows = ce.items.length, cols = columns.length; row < rows; ++row)
				{
					ce.items[row].cells = [];
					
					for (col = 0; col < cols; ++col)
					{
						cell = new CellProperties(ce.location, col);
						ce.items[row].cells[col] = cell;
						
						cells.push(cell);
					}
				}
				break;
			
			case CollectionEventKind.REMOVE:
				for (rows = ce.items.length; row < rows; ++row)
				{
					while (ce.items[row].cells.length)
					{
						cell = ce.items[row].cells.pop();
						
						col = cells.indexOf(cell);
						
						if (col > -1)
							cells.splice(col, 1);
					}
				}
				break;
			
			case CollectionEventKind.REFRESH:
				for (rows = collection.length, cols = collection[row].cells.length; row < rows; ++row)
				{
					for (col = 0; col < cols; ++col)
					{
						cell = collection[row].cells[col];
						cell.row = row;
						cell.column = col;
					}
				}
				break;
		}
	}
}
}