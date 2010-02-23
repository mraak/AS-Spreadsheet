package com.flextras.paintgrid
{
import flash.display.Sprite;
import flash.events.Event;

import mx.controls.DataGrid;
import mx.controls.dataGridClasses.DataGridColumn;
import mx.controls.listClasses.BaseListData;
import mx.controls.listClasses.IListItemRenderer;
import mx.controls.listClasses.ListBaseContentHolder;
import mx.core.ClassFactory;
import mx.core.ScrollPolicy;
import mx.core.mx_internal;
import mx.events.CollectionEvent;
import mx.events.CollectionEventKind;
import mx.events.DataGridEvent;
import mx.events.TweenEvent;
import mx.utils.ObjectProxy;

use namespace mx_internal;

public class PaintGrid2 extends DataGrid
{
	public function PaintGrid2 ()
	{
		super();
		
		editable = true;
		variableRowHeight = true;
		allowMultipleSelection = true;
		horizontalScrollPolicy = ScrollPolicy.AUTO; // !!
		itemRenderer = new ClassFactory(PaintGrid2ColumnItemRenderer);
		
		addEventListener(DataGridEvent.ITEM_EDIT_BEGINNING, itemEditBeginningHandler);
	}
	
	protected var _selectedCells : Array = [];
	
	[Bindable(event="selectedCellsChanged")]
	public function get selectedCells () : Array
	{
		return _selectedCells;
	}
	
	override protected function selectItem (item : IListItemRenderer, shiftKey : Boolean, ctrlKey : Boolean, transition : Boolean = true) : Boolean
	{
		var retval : Boolean = super.selectItem(item, shiftKey, ctrlKey, transition);
		
		var currentCell : CellProperties, oldCell : CellProperties = selectedCellProperties;
		var i : int, arr : Array;
		var start : CellLocation, end : CellLocation;
		var cells : Array, cell : CellProperties;
		
		if (item is PaintGrid2ColumnItemRenderer)
			currentCell = PaintGrid2ColumnItemRenderer(item).cell;
		
		if (!currentCell)
			return retval;
		
		if (!ctrlKey && !shiftKey)
		{
			while (_selectedCells.length)
			{
				cell = _selectedCells.pop();
				cell.selected = false;
			}
			
			_selectedCells.push(currentCell);
			currentCell.selected = true;
		}
		else if (ctrlKey && shiftKey)
		{
			start = selectedCellProperties || new CellLocation(), end = currentCell;
			cells = getAllCellPropertiesInRangeBy(start, end);
			
			for each (cell in cells)
				if ((i = _selectedCells.indexOf(cell)) > -1)
				{
					arr = _selectedCells.splice(i, 1);
					
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
			{
				currentCell.selected = !currentCell.selected;
				
				if (!currentCell.selected && (i = _selectedCells.indexOf(currentCell)) > -1)
					arr = _selectedCells.splice(i, 1);
				else
					_selectedCells.push(currentCell);
			}
			else if ((i = _selectedCells.indexOf(currentCell)) > -1)
			{
				arr = _selectedCells.splice(i, 1);
				arr[0].selected = false;
			}
			else
			{
				_selectedCells.push(currentCell);
				currentCell.selected = true;
			}
		}
		else if (shiftKey && !ctrlKey)
		{
			start = selectedCellProperties || new CellLocation(), end = currentCell;
			cells = getAllCellPropertiesInRangeBy(start, end);
			
			for each (cell in cells)
				if ((i = _selectedCells.indexOf(cell)) < 0)
				{
					_selectedCells.push(cell);
					cell.selected = true;
				}
		}
		
		selectedCellProperties = currentCell;
		dispatchEvent(new Event("selectedCellsChanged"));
		
		return retval;
	}
	
	override protected function drawSelectionIndicator (indicator : Sprite, x : Number, y : Number, width : Number, height : Number, color : uint, itemRenderer : IListItemRenderer) : void
	{
	
	}
	
	/**
	 * Styling API
	 */
	
	[ArrayElementType("CellProperties")]
	protected var cells : Object = {};
	
	protected function getCell (at : CellLocation) : CellProperties
	{
		if (!at || !at.valid)
			return null;
		
		return cells[at.row + " " + at.column];
	}
	
	protected function addCell (value : CellProperties) : void
	{
		if (!value || !value.valid)
			return;
		
		cells[value.row + " " + value.column] = value;
	}
	
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
	
	public function set selectedCellsStyles (styles : Object) : void
	{
		for each (var cell : CellProperties in _selectedCells)
			cell.styles = new ObjectProxy(styles);
	}
	
	public function set selectedCellsRollOverStyles (styles : Object) : void
	{
		for each (var cell : CellProperties in _selectedCells)
			cell.rollOverStyles = new ObjectProxy(styles);
	}
	
	public function set selectedCellsSelectedStyles (styles : Object) : void
	{
		for each (var cell : CellProperties in _selectedCells)
			cell.selectedStyles = new ObjectProxy(styles);
	}
	
	public function set selectedCellsDisabledStyles (styles : Object) : void
	{
		for each (var cell : CellProperties in _selectedCells)
			cell.disabledStyles = new ObjectProxy(styles);
	}
	
	/**
	 * Instance of CellProperties
	 */
	
	public function getCellProperties (at : CellLocation) : CellProperties
	{
		var cell : CellProperties = getCell(at);
		
		if (cell)
			return cell;
		
		/*cell = new CellProperties(at.row, at.column);
		 addCell(cell);*/
		//cell.assign(globalCellStyles);
		
		return cell;
	}
	
	public function getCellPropertiesAt (row : int, column : int) : CellProperties
	{
		var location : CellLocation = new CellLocation(row, column);
		
		return getCellProperties(location);
	}
	
	public function setCellProperties (value : CellProperties) : void
	{
		if (!value || !value.valid)
			return;
		
		var cell : CellProperties = getCell(value);
		
		if (cell)
			cell.assign(value);
		else
			addCell(value);
	}
	
	public function setCellPropertiesAt (row : int, column : int, styles : Object = null, rollOverStyles : Object = null, selectedStyles : Object = null, disabledStyles : Object = null) : void
	{
		var cell : CellProperties = new CellProperties(row, column, styles, rollOverStyles, selectedStyles, disabledStyles);
		
		setCellProperties(cell);
	}
	
	/**
	 * wrappers
	 */
	
	protected const _globalCellStyles : CellProperties = new CellProperties();
	
	[Bindable(event="globalCellStylesChanged")]
	public function get globalCellStyles () : CellProperties
	{
		return _globalCellStyles;
	}
	
	public function set globalCellStyles (value : CellProperties) : void
	{
		if (value === _globalCellStyles)
			return;
		
		_globalCellStyles.assign(value);
		
		dispatchEvent(new Event("globalCellStylesChanged"));
	}
	
	public function getCellStyles (at : CellLocation) : Object
	{
		var cell : CellProperties = getCellProperties(at);
		
		if (!cell)
			return null;
		
		return cell.styles;
	}
	
	public function getCellStylesAt (row : int, column : int) : Object
	{
		var location : CellLocation = new CellLocation(row, column);
		
		return getCellStyles(location);
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
	
	public function getCellRollOverStyles (at : CellLocation) : Object
	{
		var cell : CellProperties = getCellProperties(at);
		
		if (!cell)
			return null;
		
		return cell.rollOverStyles;
	}
	
	public function getCellRollOverStylesAt (row : int, column : int) : Object
	{
		var location : CellLocation = new CellLocation(row, column);
		
		return getCellRollOverStyles(location);
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
	
	public function getCellSelectedStyles (at : CellLocation) : Object
	{
		var cell : CellProperties = getCellProperties(at);
		
		if (!cell)
			return null;
		
		return cell.selectedStyles;
	}
	
	public function getCellSelectedStylesAt (row : int, column : int) : Object
	{
		var location : CellLocation = new CellLocation(row, column);
		
		return getCellSelectedStyles(location);
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
	
	public function getCellDisabledStyles (at : CellLocation) : Object
	{
		var cell : CellProperties = getCellProperties(at);
		
		if (!cell)
			return null;
		
		return cell.disabledStyles;
	}
	
	public function getCellDisabledStylesAt (row : int, column : int) : Object
	{
		var location : CellLocation = new CellLocation(row, column);
		
		return getCellDisabledStyles(location);
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
	
	public function getAllCellPropertiesInRange (range : CellRange) : Array
	{
		if (!range || !range.valid)
			return null;
		
		var result : Array = [];
		
		for each (var cell : CellProperties in cells)
			if (cell.inRange(range))
				result.push(cell);
		
		return result;
	}
	
	public function getAllCellPropertiesInRangeBy (start : CellLocation, end : CellLocation) : Array
	{
		var range : CellRange = new CellRange(start, end);
		
		return getAllCellPropertiesInRange(range);
	}
	
	public function setAllCellPropertiesInRange (range : CellRange, styles : Object = null, rollOverStyles : Object = null, selectedStyles : Object = null, disabledStyles : Object = null) : void
	{
		if (!range || !range.valid)
			return;
		
		var minC : int = range.start.column < range.end.column ? range.start.column : range.end.column;
		var maxC : int = range.start.column > range.end.column ? range.start.column : range.end.column;
		var minR : int = range.start.row < range.end.row ? range.start.row : range.end.row;
		var maxR : int = range.start.row > range.end.row ? range.start.row : range.end.row;
		var cell : CellProperties;
		
		for (var r : int = minR, c : int; r < maxR /* + 1*/; ++r)
			for (c = minC; c < maxC; ++c)
			{
				cell = getCellPropertiesAt(r, c);
				
				if (!cell)
				{
					cell = new CellProperties(r, c, styles, rollOverStyles, selectedStyles, disabledStyles);
					
					addCell(cell);
				}
				else
				{
					cell.styles = new ObjectProxy(styles);
					cell.rollOverStyles = new ObjectProxy(rollOverStyles);
					cell.selectedStyles = new ObjectProxy(selectedStyles);
					cell.disabledStyles = new ObjectProxy(disabledStyles);
				}
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
		{
			if (o is CellLocation)
				cell = getCellProperties(o as CellLocation);
			else
				cell = getCellPropertiesAt(o.rowIndex, o.columnIndex);
			
			if (cell)
				cell.enabled = /*o is CellProperties ? CellProperties(o).enabled :*/ !cell.enabled;
		}
	}
	
	/**
	 * Column API
	 */
	
	[Bindable(event="columnWidthChanged")]
	public function getColumnWidthAt (index : int) : Number
	{
		if (index < 0)
			return -1;
		
		var col : DataGridColumn = columns[index];
		
		return col ? col.width : -1;
	}
	
	public function setColumnWidthAt (index : int, value : Number) : void
	{
		if (index < 0 || value < 0)
			return;
		
		resizeColumn(index, value);
		
		callLater(dispatchEvent, [new Event("columnWidthChanged")]);
	}
	
	public function addColumn (index : int = 0) : void
	{
	/*if (index < 0)
	   index = 0;
	   else if (index > columns.length)
	   index = columns.length;
	
	   var cols : Array = columns;
	
	   var column : DataGridColumn = new DataGridColumn();
	   column.headerText = "test";
	   column.dataField = "r0";
	
	   cols.splice(index, 0, column);
	
	   var i : int, j : int, cell : CellProperties;
	   var info : Row, n : int = cols.length;
	
	   for each (var row : Object in collection)
	   {
	   info = row.info;
	   cell = new CellProperties(info.cells[0].row, index);
	
	   info.cells.splice(index, 0, cell);
	   cells.push(cell);
	
	   for (i = index + 1; i < n; ++i)
	   {
	   cell = info.cells[i];
	
	   if (cell)
	   ++cell.column;
	   }
	   }
	
	 columns = cols;*/
	}
	
	public function removeColumn (index : int = 0) : void
	{
	/*if (index < 0)
	   index = 0;
	   else if (index > columns.length)
	   index = columns.length;
	
	   var cols : Array = columns;
	
	   var column : DataGridColumn = cols.splice(index, 1)[0];
	
	   var i : int, j : int, cell : CellProperties;
	   var info : Row, n : int = cols.length;
	
	   for each (var row : Object in collection)
	   {
	   info = row.info;
	
	   cell = info.cells.splice(index, 1)[0];
	   cell.release();
	
	   if (selectedCellProperties === cell)
	   {
	   selectedCellProperties = null;
	
	   i = selectedCells.indexOf(cell);
	   selectedCells.splice(i, 1);
	   }
	
	   cells.splice(cells.indexOf(cell), 1);
	
	   for (i = index; i < n; ++i)
	   {
	   cell = info.cells[i];
	
	   if (cell)
	   --cell.column;
	   }
	   }
	
	 columns = cols;*/
	}
	
	/**
	 * Row height API
	 */
	
	[Bindable(event="rowHeightChanged")]
	public function getRowHeightAt (index : int) : Number
	{
		if (value < 0)
			return -1;
		
		var info : Row = dataProvider.getItemAt(index).info;
		
		if (!info)
			return -1;
		
		return info.height;
	}
	
	public function setRowHeightAt (index : int, value : Number) : void
	{
		if (index < 0 || value < 0)
			return;
		
		var info : Row = super.dataProvider.getItemAt(index).info;
		
		if (!info)
			return;
		
		info.height = value;
		
		callLater(dispatchEvent, [new Event("rowHeightChanged")]);
	
	/*itemsNeedMeasurement = true;
	   itemsSizeChanged = true;
	   invalidateSize();
	   invalidateList();
	 invalidateDisplayList();*/
	}
	
	/*override mx_internal function shiftColumns (oldIndex : int, newIndex : int, trigger : Event = null) : void
	   {
	   super.shiftColumns(oldIndex, newIndex, trigger);
	
	   if (newIndex >= 0 && oldIndex != newIndex)
	   {
	   var incr : int = oldIndex < newIndex ? 1 : -1;
	   var i : int, j : int, cell : CellProperties;
	   var info : Row;
	
	   for each (var row : Object in collection)
	   {
	   info = row.info;
	
	   for (i = oldIndex; i != newIndex; i += incr)
	   {
	   j = i + incr;
	   cell = info.cells[i];
	   info.cells[i] = info.cells[j];
	   info.cells[j] = cell;
	   info.cells[i].column = i;
	   info.cells[j].column = j;
	   }
	   }
	   }
	 }*/
	
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
		var cells : Array;
		
		switch (ce.kind)
		{
			case CollectionEventKind.RESET:
				break;
			
			/*case CollectionEventKind.ADD:
			   for (rows = ce.items.length, cols = columns.length; row < rows; ++row)
			   {
			   info = new Row(20);
			
			   for (col = 0; col < cols; ++col)
			   {
			   cell = new CellProperties(ce.location, col);
			   info.cells[col] = cell;
			
			   cells.push(cell);
			   }
			
			   ce.items[row].info = info;
			   }
			 break;*/
			
			/*case CollectionEventKind.REMOVE:
			   for (rows = ce.items.length; row < rows; ++row)
			   {
			   info = ce.items[row].info;
			
			   while (info.cells.length)
			   {
			   info = ce.items[row].info;
			   cell = info.cells.pop();
			   cell.release();
			
			   col = cells.indexOf(cell);
			
			   if (col > -1)
			   cells.splice(col, 1);
			   }
			   }
			 break;*/
			
			case CollectionEventKind.REFRESH:
				for (rows = cache.length; row < rows; ++row)
				{
					cells = cache[row];
					
					for (col = 0, cols = cells.length; col < cols; ++col)
					{
						cell = cells[col];
						cell.row = row;
						cell.column = col;
					}
				}
				break;
		}
	}
	
	protected var currentRow : int;
	
	protected var currentColumn : int;
	
	override protected function setupColumnItemRenderer (c : DataGridColumn, contentHolder : ListBaseContentHolder, rowNum : int, colNum : int, data : Object, uid : String) : IListItemRenderer
	{
		currentRow = rowNum + verticalScrollPosition;
		currentColumn = colNum + horizontalScrollPosition;
		
		var item : IListItemRenderer = super.setupColumnItemRenderer(c, contentHolder, rowNum, colNum, data, uid);
		
		if (!item)
			return null;
		
		item.styleName = this;
		
		if (item is PaintGrid2ColumnItemRenderer)
		{
			var r : PaintGrid2ColumnItemRenderer = PaintGrid2ColumnItemRenderer(item);
			r.dataGrid = this;
			r.globalCell = _globalCellStyles;
			r.cell = cache[currentRow][currentColumn];
		}
		
		return item;
	}
	
	protected var cache : Array = [];
	
	override protected function makeListData (data : Object, uid : String, rowNum : int, columnNum : int, column : DataGridColumn) : BaseListData
	{
		var text : String;
		
		if (data is DataGridColumn)
			text = column.headerText ? column.headerText : column.dataField;
		else
		{
			cache[currentRow] ||= [];
			
			var cell : CellProperties = cache[currentRow][columnNum] as CellProperties;
			
			if (!cell)
			{
				var location : CellLocation = new CellLocation(currentRow, currentColumn);
				cell = getCellProperties(location);
				
				if (!cell)
				{
					cell = new CellProperties(location.row, location.column);
					addCell(cell);
				}
				
				cache[currentRow][currentColumn] = cell;
			}
			
			cell.column = currentColumn;
			cell.row = currentRow;
			
			text = column.itemToLabel(data);
		}
		
		return new PaintGridListData(cell, text, column.dataField, columnNum, uid, this, rowNum);
	}
	
	/**
	 * Unless selected cell is enabled prevent default behavior - prevent item from being edited.
	 *
	 * @param e
	 *
	 */
	
	protected function itemEditBeginningHandler (e : DataGridEvent) : void
	{
		var cell : CellProperties = getCellPropertiesAt(e.rowIndex + verticalScrollPosition, e.columnIndex + horizontalScrollPosition);
		
		if (!cell || !cell.enabled)
			e.preventDefault();
	}
}
}