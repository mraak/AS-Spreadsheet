package com.flextras.paintgrid
{
import flash.display.Sprite;
import flash.events.Event;

import mx.collections.ArrayList;
import mx.collections.ListCollectionView;
import mx.controls.DataGrid;
import mx.controls.dataGridClasses.DataGridColumn;
import mx.controls.listClasses.IListItemRenderer;
import mx.controls.listClasses.ListBaseContentHolder;
import mx.core.ClassFactory;
import mx.core.ScrollPolicy;
import mx.core.mx_internal;
import mx.events.CollectionEvent;
import mx.events.CollectionEventKind;
import mx.events.TweenEvent;
import mx.utils.ObjectProxy;
import mx.utils.ObjectUtil;

use namespace mx_internal;

public class PaintGrid extends DataGrid
{
	public function PaintGrid ()
	{
		super();
		
		variableRowHeight = true;
		allowMultipleSelection = true;
		horizontalScrollPolicy = ScrollPolicy.AUTO; // !!
		itemRenderer = new ClassFactory(PaintGridColumnItemRenderer);
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
		
		/*else if (!currentCell.enabled)
		 return retval;*/
		
		if (!ctrlKey && !shiftKey)
		{
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
	
	override protected function drawSelectionIndicator (indicator : Sprite, x : Number, y : Number, width : Number, height : Number, color : uint, itemRenderer : IListItemRenderer) : void
	{
	
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
		
		_globalCellStyles.styles = value.styles || null;
		_globalCellStyles.rollOverStyles = value.rollOverStyles || null;
		_globalCellStyles.selectedStyles = value.selectedStyles || null;
		_globalCellStyles.disabledStyles = value.disabledStyles || null;
		
		dispatchEvent(new Event("globalCellStylesChanged"));
	}
	
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
		
		dispatchEvent(new Event("columnWidthChanged"));
	}
	
	/**
	 * Row height API
	 */
	
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
	
	/*itemsNeedMeasurement = true;
	   itemsSizeChanged = true;
	   invalidateSize();
	   invalidateList();
	 invalidateDisplayList();*/
	}
	
	/**
	 *
	 * For performance reasons it's best to keep them separated.
	 *
	 */
	
	public function get cleanDataProvider () : ListCollectionView
	{
		// Very expensive operation...
		var result : ListCollectionView = ObjectUtil.copy(super.dataProvider) as ListCollectionView;
		
		for each (var item : Object in result)
			if (item.hasOwnProperty("info"))
				delete item.info;
		
		return result;
	}
	
	override protected function setupColumnItemRenderer (c : DataGridColumn, contentHolder : ListBaseContentHolder, rowNum : int, colNum : int, data : Object, uid : String) : IListItemRenderer
	{
		var item : IListItemRenderer = super.setupColumnItemRenderer(c, contentHolder, rowNum, colNum, data, uid);
		
		if (!item)
			return null;
		
		item.styleName = this;
		
		if (item is PaintGridColumnItemRenderer)
		{
			var r : PaintGridColumnItemRenderer = PaintGridColumnItemRenderer(item);
			r.dataGrid = this;
			r.globalCell = _globalCellStyles;
			
			if (data.hasOwnProperty("info"))
			{
				var info : Row = data.info;
				
				r.cell = info.cells[colNum + horizontalScrollPosition];
				r.info = info;
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
		var info : Row;
		
		switch (ce.kind)
		{
			case CollectionEventKind.RESET:
				break;
			
			case CollectionEventKind.ADD:
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
				break;
			
			case CollectionEventKind.REMOVE:
				for (rows = ce.items.length; row < rows; ++row)
				{
					while (ce.items[row].cells.length)
					{
						info = ce.items[row].info;
						cell = info.cells.pop();
						cell.release();
						
						col = cells.indexOf(cell);
						
						if (col > -1)
							cells.splice(col, 1);
					}
				}
				break;
			
			case CollectionEventKind.REFRESH:
				for (rows = collection.length, cols = collection[row].cells.length; row < rows; ++row)
				{
					info = collection[row].info;
					
					for (col = 0; col < cols; ++col)
					{
						cell = info.cells[col];
						cell.row = row;
						cell.column = col;
					}
				}
				break;
		}
	}
}
}