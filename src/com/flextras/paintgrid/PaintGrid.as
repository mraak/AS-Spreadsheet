package com.flextras.paintgrid
{
import flash.events.Event;

import mx.controls.DataGrid;
import mx.controls.dataGridClasses.DataGridColumn;
import mx.controls.listClasses.IListItemRenderer;
import mx.controls.listClasses.ListBaseContentHolder;
import mx.core.ClassFactory;
import mx.core.ScrollPolicy;
import mx.core.mx_internal;
import mx.events.CollectionEvent;
import mx.events.CollectionEventKind;
import mx.utils.ObjectProxy;

use namespace mx_internal;

public class PaintGrid extends DataGrid
{
	public function PaintGrid ()
	{
		super();
		
		variableRowHeight = true;
		horizontalScrollPolicy = ScrollPolicy.AUTO;
		itemRenderer = new ClassFactory(PaintGridItemRenderer);
	}
	
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
	
	public function getCellProperties (at : Location, fromUser : Boolean = true) : CellProperties
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
		var location : Location = new Location(row, column);
		
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
				cell.condition = value.condition;
				
				if (!cell in modifiedCells)
					modifiedCells.push(cell);
				
				return;
			}
	}
	
	public function setCellPropertiesAt (row : int, column : int, styles : Object = null, rollOverStyles : Object = null, selectedStyles : Object = null, disabledStyles : Object = null, condition : String = null) : void
	{
		var cell : CellProperties = new CellProperties(row, column, styles, rollOverStyles, selectedStyles, disabledStyles, condition);
		
		setCellProperties(cell);
	}
	
	/**
	 * wrappers
	 */
	
	public function getCellStyles (at : Location, fromUser : Boolean = true) : Object
	{
		var cell : CellProperties = getCellProperties(at, fromUser);
		
		if (!cell)
			return null;
		
		return cell.styles;
	}
	
	public function getCellStylesAt (row : int, column : int, fromUser : Boolean = true) : Object
	{
		var location : Location = new Location(row, column);
		
		return getCellStyles(location, fromUser);
	}
	
	public function setCellStyles (location : Location, styles : Object = null) : void
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
	
	public function getCellRollOverStyles (at : Location, fromUser : Boolean = true) : Object
	{
		var cell : CellProperties = getCellProperties(at, fromUser);
		
		if (!cell)
			return null;
		
		return cell.rollOverStyles;
	}
	
	public function getCellRollOverStylesAt (row : int, column : int, fromUser : Boolean = true) : Object
	{
		var location : Location = new Location(row, column);
		
		return getCellRollOverStyles(location, fromUser);
	}
	
	public function setCellRollOverStyles (location : Location, styles : Object = null) : void
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
	
	public function getCellSelectedStyles (at : Location, fromUser : Boolean = true) : Object
	{
		var cell : CellProperties = getCellProperties(at, fromUser);
		
		if (!cell)
			return null;
		
		return cell.selectedStyles;
	}
	
	public function getCellSelectedStylesAt (row : int, column : int, fromUser : Boolean = true) : Object
	{
		var location : Location = new Location(row, column);
		
		return getCellSelectedStyles(location, fromUser);
	}
	
	public function setCellSelectedStyles (location : Location, styles : Object = null) : void
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
	
	public function getCellDisabledStyles (at : Location, fromUser : Boolean = true) : Object
	{
		var cell : CellProperties = getCellProperties(at, fromUser);
		
		if (!cell)
			return null;
		
		return cell.disabledStyles;
	}
	
	public function getCellDisabledStylesAt (row : int, column : int, fromUser : Boolean = true) : Object
	{
		var location : Location = new Location(row, column);
		
		return getCellDisabledStyles(location, fromUser);
	}
	
	public function setCellDisabledStyles (location : Location, styles : Object = null) : void
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
	
	public function getAllCellPropertiesInRange (range : Range, fromUser : Boolean = true) : Array
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
	
	public function getAllCellPropertiesInRangeBy (start : Location, end : Location, fromUser : Boolean = true) : Array
	{
		var range : Range = new Range(start, end);
		
		return getAllCellPropertiesInRange(range, fromUser);
	}
	
	public function setAllCellPropertiesInRange (range : Range, styles : Object = null, rollOverStyles : Object = null, selectedStyles : Object = null, disabledStyles : Object = null, condition : String = null) : void
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
				cell.condition = condition;
				
				if (!cell in modifiedCells)
					modifiedCells.push(cell);
			}
	}
	
	public function setAllCellPropertiesInRangeBy (start : Location, end : Location, styles : Object = null, rollOverStyles : Object = null, selectedStyles : Object = null, disabledStyles : Object = null, condition : String = null) : void
	{
		var range : Range = new Range(start, end);
		
		setAllCellPropertiesInRange(range, styles, rollOverStyles, selectedStyles, disabledStyles, condition);
	}
	
	/**
	 * Column width API
	 */
	
	[ArrayElementType("Column")]
	protected var columnWidths : Array = [];
	
	protected var columnWidthsChanged : Boolean;
	
	public function getColumnWidthAt (index : int) : Number
	{
		if (value < 0)
			return -1;
		
		for each (var column : Column in columnWidths)
			if (column.index == index)
				return column.width;
		
		return -1;
	}
	
	public function setColumnWidthAt (index : int, value : Number) : void
	{
		if (index < 0 || value < 0)
			return;
		
		for each (var column : Column in columnWidths)
			if (column.index == index)
			{
				column.width = value;
				
				columnWidthsChanged = true;
				
				invalidateProperties();
				
				return;
			}
		
		columnWidths.push(new Column(index, value));
		
		columnWidthsChanged = true;
		
		invalidateProperties();
	}
	
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
		
		for each (var row : Row in rowHeights)
			if (row.index == index)
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
		
		invalidateSize();
	}
	
	override protected function commitProperties () : void
	{
		super.commitProperties();
		
		if (columnWidthsChanged)
		{
			for each (var column : Column in columnWidths)
				resizeColumn(column.index, column.width);
			
			columnWidthsChanged = false;
		}
		
		// TODO!!!
		if (rowHeightsChanged)
		{
			rowHeightsChanged = false;
		}
	}
	
	override protected function calculateRowHeight (data : Object, hh : Number, skipVisible : Boolean = false) : Number
	{
		return super.calculateRowHeight(data, hh, skipVisible);
		
		return 100;
	}
	
	override protected function setupColumnItemRenderer (c : DataGridColumn, contentHolder : ListBaseContentHolder, rowNum : int, colNum : int, data : Object, uid : String) : IListItemRenderer
	{
		var item : PaintGridItemRenderer = super.setupColumnItemRenderer(c, contentHolder, rowNum, colNum, data, uid) as PaintGridItemRenderer;
		
		if (!item)
			return null;
		
		if (data.hasOwnProperty("cells"))
			item.cell = data.cells[colNum + horizontalScrollPosition];
		
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
	
	override protected function collectionChangeHandler (event : Event) : void
	{
		super.collectionChangeHandler(event);
		
		if (!event is CollectionEvent)
			return;
		
		var ce : CollectionEvent = CollectionEvent(event);
		
		var row : int, rows : int, col : int, cols : int, cell : CellProperties;
		
		switch (ce.kind)
		{
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