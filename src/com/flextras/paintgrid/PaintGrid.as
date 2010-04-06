package com.flextras.paintgrid
{
import flash.display.Sprite;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;

import mx.collections.ListCollectionView;
import mx.controls.DataGrid;
import mx.controls.dataGridClasses.DataGridColumn;
import mx.controls.listClasses.IDropInListItemRenderer;
import mx.controls.listClasses.IListItemRenderer;
import mx.controls.listClasses.ListBaseContentHolder;
import mx.controls.scrollClasses.ScrollBar;
import mx.core.ClassFactory;
import mx.core.ScrollPolicy;
import mx.core.mx_internal;
import mx.events.CollectionEvent;
import mx.events.CollectionEventKind;
import mx.events.DataGridEvent;
import mx.events.TweenEvent;
import mx.utils.ObjectProxy;

use namespace mx_internal;

public class PaintGrid extends DataGrid
{
	public function PaintGrid ()
	{
		super();
		
		setStyle("paddingLeft", 0);
		setStyle("paddingRight", 0);
		setStyle("paddingTop", 0);
		setStyle("paddingBottom", 0);
		//setStyle("useRollOver", false);
		
		editable = true;
		doubleClickEnabled = true;
		variableRowHeight = true;
		allowMultipleSelection = true;
		horizontalScrollPolicy = ScrollPolicy.AUTO;
		itemRenderer = new ClassFactory(PaintGridItemRenderer);
		
		addEventListener(DataGridEvent.ITEM_EDIT_BEGINNING, itemEditBeginningHandler);
	}
	
	[Bindable]
	public var doubleClickToEdit : Boolean;
	
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
		
		var cell : CellProperties;
		
		if ((cell = getCellProperties(value.location, false)))
			cell.assign(value);
		
		updateCell(cell);
	}
	
	protected function updateCell (value : CellProperties) : void
	{
		var cell : CellProperties;
		
		if (!(cell = getCellProperties(value.location, true)))
			modifiedCells.push(value);
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
		
		var result : Array = [];
		var cells : Array = fromUser ? modifiedCells : this.cells;
		
		for each (var cell : CellProperties in cells)
			if (cell.location.inRange(range))
				result.push(cell);
		
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
			if (cell.location.inRange(range))
			{
				cell.styles = new ObjectProxy(styles);
				cell.rollOverStyles = new ObjectProxy(rollOverStyles);
				cell.selectedStyles = new ObjectProxy(selectedStyles);
				cell.disabledStyles = new ObjectProxy(disabledStyles);
				
				updateCell(cell);
			}
	}
	
	public function setAllCellPropertiesInRangeBy (start : CellLocation, end : CellLocation, styles : Object = null, rollOverStyles : Object = null, selectedStyles : Object = null, disabledStyles : Object =
												   null) : void
	{
		var range : CellRange = new CellRange(start, end);
		
		setAllCellPropertiesInRange(range, styles, rollOverStyles, selectedStyles, disabledStyles);
	}
	
	/**
	 * Conditions API
	 */
	
	// TODO :  remove Conditions API
	
	/*protected var _condition : Condition;
	
	protected var _conditionString : String;
	
	[Bindable(event="conditionChanged")]
	public function get condition () : String
	{
		return _conditionString;
	}
	
	public function set condition (value : String) : void
	{
		if (_conditionString == value)
			return;
		
		_conditionString = value;
		
		//_condition = null;
		
		if (value)
		{
			var o : Object = Utils.breakComparisonInput(value);
			
			if (_condition)
			{
				_condition.left = o.arg1;
				_condition.operator = o.op;
				_condition.right = o.arg2;
			}
			else
				_condition = new Condition(o.op, o.arg2);
		}
		else if (_condition)
		{
			_condition.left = null;
			_condition.operator = null;
			_condition.right = null;
		}
		else
			_condition = new Condition();
		
		dispatchEvent(new Event("conditionChanged"));
	}*/
	
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
				cell = getCellProperties(o as CellLocation, false);
			else
				cell = getCellPropertiesAt(o.rowIndex, o.columnIndex, false);
			
			if (cell)
				cell.enabled = !cell.enabled;
		}
	}
	
	/**
	 * Column API
	 */
	
	[Bindable(event="columnWidthChanged")]
	public function getColumnWidthAt (index : int) : Number
	{
		if (index < 0 || index >= columns.length)
			return -1;
		
		var col : DataGridColumn = columns[index];
		
		return col ? col.width : -1;
	}
	
	public function setColumnWidthAt (index : int, value : Number) : void
	{
		if (index < 0 || index >= columns.length || value < 0)
			return;
		
		resizeColumn(index, value);
		
		callLater(dispatchEvent, [new Event("columnWidthChanged")]);
	}
	
	public function insertColumnAt (index : int = 0) : int
	{
		if (index < 0 || index >= columns.length)
			return index;
		
		var cols : Array = columns;
		
		var column : DataGridColumn = new DataGridColumn();
		column.headerText = "test";
		column.dataField = "r0";
		
		cols.splice(index, 0, column);
		
		var i : int, j : int, cell : CellProperties;
		var n : int = cols.length;
		
		for each (var info : Row in infos)
		{
			cell = new CellProperties(info.cells[0].row, index);
			
			info.cells.splice(index, 0, cell);
			cells.push(cell);
			
			for (i = index + 1; i < n; ++i)
			{
				cell = info.cells[i];
				
				if (cell)
					++cell.location.column;
			}
		}
		
		columns = cols;
		
		return index;
	}
	
	public function removeColumnAt (index : int = 0) : void
	{
		if (index < 0 || index >= columns.length)
			return;
		
		var cols : Array = columns;
		
		var column : DataGridColumn = cols.splice(index, 1)[0];
		
		var i : int, j : int, cell : CellProperties;
		var n : int = cols.length;
		
		for each (var info : Row in infos)
		{
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
					--cell.location.column;
			}
		}
		
		columns = cols;
	}
	
	/**
	 * Row height API
	 */
	
	[Bindable(event="rowHeightChanged")]
	public function getRowHeightAt (index : int) : Number
	{
		if (index < 0 || index >= collection.length)
			return -1;
		
		var info : Row = infos[index];
		
		return info ? info.height : -1;
	}
	
	public function setRowHeightAt (index : int, value : Number) : void
	{
		if (index < 0 || index >= collection.length || value < 0)
			return;
		
		var info : Row = infos[index];
		
		if (!info)
			return;
		
		info.height = value;
		rowInfo[index - verticalScrollPosition].height = value;
		
		itemsSizeChanged = true;
		invalidateDisplayList();
		
		callLater(dispatchEvent, [new Event("rowHeightChanged")]);
	}
	
	public function insertRow (value : Object, index : int) : void
	{
		if (!value || index < 0 || index >= collection.length)
			return;
		
		ListCollectionView(collection).addItemAt(value, index);
	}
	
	public function removeRowAt (index : int) : void
	{
		if (index < 0 || index >= collection.length)
			return;
		
		ListCollectionView(collection).removeItemAt(index);
	}
	
	[ArrayElementType("Row")]
	protected var infos : Array = [];
	
	protected function getInfoByUID (value : String) : Row
	{
		if (!value || !value.length)
			return null;
		
		for each (var info : Row in infos)
			if (info.uid == value)
				return info;
		
		return null;
	}
	
	protected var _selectedCells : Array = [];
	
	[Bindable(event="selectedCellsChanged")]
	public function get selectedCells () : Array
	{
		return _selectedCells;
	}
	
	protected var selectedRenderer : PaintGridItemRenderer;
	
	override protected function selectItem (item : IListItemRenderer, shiftKey : Boolean, ctrlKey : Boolean, transition : Boolean = true) : Boolean
	{
		var retval : Boolean = super.selectItem(item, shiftKey, ctrlKey, transition);
		
		if (isAlt)
			return retval;
		
		var currentCell : CellProperties, oldCell : CellProperties = selectedCellProperties;
		var i : int, arr : Array;
		var start : CellLocation, end : CellLocation;
		var cells : Array, cell : CellProperties;
		
		if (item is PaintGridItemRenderer)
		{
			selectedRenderer = PaintGridItemRenderer(item);
			currentCell = selectedRenderer.cell;
		}
		
		if (!currentCell)
			return retval;
		
		if (!ctrlKey && !shiftKey)
		{
			while (_selectedCells.length)
			{
				cell = _selectedCells.pop();
				cell.selected = false;
			}
			
			beginEdit = oldCell == currentCell && doubleClickToEdit || !doubleClickToEdit;
			
			_selectedCells.push(currentCell);
			currentCell.selected = true;
		}
		else if (ctrlKey && shiftKey)
		{
			start = selectedCellProperties.location || new CellLocation();
			end = currentCell.location;
			cells = getAllCellPropertiesInRangeBy(start, end, false);
			
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
			start = selectedCellProperties.location || new CellLocation(), end = currentCell.location;
			cells = getAllCellPropertiesInRangeBy(start, end, false);
			
			for each (cell in cells)
				if ((i = _selectedCells.indexOf(cell)) < 0)
				{
					_selectedCells.push(cell);
					cell.selected = true;
				}
		}
		
		selectedCellProperties = currentCell;
		selectedRenderer.invalidateDisplayList();
		dispatchEvent(new Event("selectedCellsChanged"));
		
		return retval;
	}
	
	override mx_internal function shiftColumns (oldIndex : int, newIndex : int, trigger : Event = null) : void
	{
		super.shiftColumns(oldIndex, newIndex, trigger);
		
		if (newIndex >= 0 && oldIndex != newIndex)
		{
			var incr : int = oldIndex < newIndex ? 1 : -1;
			var i : int, j : int, cell : CellProperties;
			
			for each (var info : Row in infos)
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
	
	override protected function setupColumnItemRenderer (c : DataGridColumn, contentHolder : ListBaseContentHolder, rowNum : int, colNum : int, data : Object, uid : String) : IListItemRenderer
	{
		var item : IListItemRenderer = super.setupColumnItemRenderer(c, contentHolder, rowNum, colNum, data, uid);
		
		if (!item)
			return null;
		
		item.styleName = this;
		
		if (item is PaintGridItemRenderer)
		{
			var info : Row = getInfoByUID(uid);
			var r : PaintGridItemRenderer = PaintGridItemRenderer(item);
			
			r.dataGrid = this;
			r.globalCell = _globalCellStyles;
			
			if (info)
			{
				r.cell = info.cells[colNum + horizontalScrollPosition];
				r.info = info;
			}
		}
		
		return item;
	}
	
	override protected function drawSelectionIndicator (indicator : Sprite, x : Number, y : Number, width : Number, height : Number, color : uint, itemRenderer : IListItemRenderer) : void
	{
	
	}
	
	override mx_internal function selectionTween_updateHandler (event : TweenEvent) : void
	{
	
	}
	
	/**
	 * Unless selected cell is enabled prevent default behavior - prevent item from being edited.
	 *
	 * @param e
	 *
	 */
	
	protected function itemEditBeginningHandler (e : DataGridEvent) : void
	{
		if (!(e.itemRenderer is PaintGridItemRenderer))
			return;
		
		var r : PaintGridItemRenderer = PaintGridItemRenderer(e.itemRenderer);
		var cell : CellProperties = r.cell;
		
		if (!cell || !cell.enabled || !beginEdit)
			e.preventDefault();
		
		beginEdit = false;
	}
	
	override protected function mouseDoubleClickHandler (event : MouseEvent) : void
	{
		var dataGridEvent : DataGridEvent;
		var r : IListItemRenderer;
		var dgColumn : DataGridColumn;
		
		r = mouseEventToItemRenderer(event);
		
		if (r && r != itemEditorInstance)
		{
			var dilr : IDropInListItemRenderer = IDropInListItemRenderer(r);
			
			if (columns[dilr.listData.columnIndex].editable && doubleClickToEdit && !isCtrl && !isAlt)
			{
				beginEdit = true;
				
				dgColumn = columns[dilr.listData.columnIndex];
				dataGridEvent = new DataGridEvent(DataGridEvent.ITEM_EDIT_BEGINNING, false, true);
				// ITEM_EDIT events are cancelable
				dataGridEvent.columnIndex = dilr.listData.columnIndex;
				dataGridEvent.dataField = dgColumn.dataField;
				dataGridEvent.rowIndex = dilr.listData.rowIndex + verticalScrollPosition;
				dataGridEvent.itemRenderer = r;
				
				dispatchEvent(dataGridEvent);
			}
		}
		
		super.mouseDoubleClickHandler(event);
	}
	
	mx_internal var preventFromEditing : Boolean;
	
	protected var beginEdit : Boolean;
	
	mx_internal var isCtrl : Boolean;
	
	mx_internal var isAlt : Boolean;
	
	override protected function keyDownHandler (event : KeyboardEvent) : void
	{
		super.keyDownHandler(event);
		
		isCtrl = event.ctrlKey;
		isAlt = event.altKey;
	}
	
	override protected function keyUpHandler (event : KeyboardEvent) : void
	{
		super.keyUpHandler(event);
		
		isCtrl = event.ctrlKey;
		isAlt = event.altKey;
	}
	
	mx_internal function get hScrollBar () : ScrollBar
	{
		return horizontalScrollBar;
	}
	
	override protected function collectionChangeHandler (event : Event) : void
	{
		super.collectionChangeHandler(event);
		
		if (!event is CollectionEvent)
			return;
		
		var ce : CollectionEvent = CollectionEvent(event);
		
		switch (ce.kind)
		{
			case CollectionEventKind.RESET:
				collectionChange_reset(collection.length, columns.length);
				break;
			
			case CollectionEventKind.ADD:
				collectionChange_add(ce.items.length, columns.length, ce);
				break;
			
			case CollectionEventKind.REMOVE:
				collectionChange_remove(ce.items.length, columns.length, ce);
				break;
			
			case CollectionEventKind.REFRESH:
				collectionChange_refresh(collection.length, columns.length);
				break;
		}
	}
	
	protected function collectionChange_reset (rows : int, cols : int) : void
	{
		var row : int, col : int, info : Row, cell : CellProperties;
		
		while (infos.length)
		{
			info = infos.pop();
			
			while (info.cells.length)
			{
				cell = info.cells.pop();
				cell.release();
				
				if (selectedCellProperties === cell)
				{
					selectedCellProperties = null;
					
					col = selectedCells.indexOf(cell);
					selectedCells.splice(col, 1);
				}
				
				col = cells.indexOf(cell);
				
				if (col > -1)
					cells.splice(col, 1);
				
				col = modifiedCells.indexOf(cell);
				
				if (col > -1)
					modifiedCells.splice(col, 1);
			}
		}
		
		for (; row < rows; ++row)
		{
			info = new Row();
			info.uid = itemToUID(collection[row]);
			
			for (col = 0; col < cols; ++col)
			{
				cell = new CellProperties(row, col);
				info.cells[col] = cell;
				
				cells.push(cell);
			}
			
			infos.push(info);
		}
	}
	
	protected function collectionChange_add (rows : int, cols : int, e : CollectionEvent) : void
	{
		var info : Row, cell : CellProperties;
		var row : int, col : int;
		
		for (; row < rows; ++row)
		{
			info = new Row();
			info.uid = itemToUID(e.items[row]);
			
			for (col = 0; col < cols; ++col)
			{
				cell = new CellProperties(row + e.location, col);
				info.cells[col] = cell;
				
				cells.push(cell);
			}
			
			infos.splice(row + e.location, 0, info);
		}
	}
	
	protected function collectionChange_remove (rows : int, cols : int, e : CollectionEvent) : void
	{
		var info : Row, cell : CellProperties;
		var row : int = e.location, col : int;
		
		rows += e.location;
		
		for (; row < rows; ++row)
		{
			info = infos.splice(row, 1)[0];
			
			while (info.cells.length)
			{
				cell = info.cells.pop();
				cell.release();
				
				if (selectedCellProperties === cell)
				{
					selectedCellProperties = null;
					
					col = selectedCells.indexOf(cell);
					selectedCells.splice(col, 1);
				}
				
				col = cells.indexOf(cell);
				
				if (col > -1)
					cells.splice(col, 1);
				
				col = modifiedCells.indexOf(cell);
				
				if (col > -1)
					modifiedCells.splice(col, 1);
			}
		}
	}
	
	protected function collectionChange_refresh (rows : int, cols : int) : void
	{
		var info : Row, cell : CellProperties;
		var row : int, col : int;
		
		for (; row < rows; ++row)
		{
			info = infos[row];
			
			for (col = 0; col < cols; ++col)
			{
				cell = info.cells[col];
				cell.location.row = row;
				cell.location.column = col;
			}
		}
	}
}
}