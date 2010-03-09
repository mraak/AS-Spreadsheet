package com.flextras.paintgrid
{
import com.flextras.context.GlobalContextMenu;
import com.flextras.context.LocalContextMenu;

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

public class PaintGrid2 extends DataGrid
{
	public function PaintGrid2 ()
	{
		super();
		
		setStyle("paddingLeft", 0);
		setStyle("paddingRight", 0);
		setStyle("paddingTop", 0);
		setStyle("paddingBottom", 0);
		
		editable = true;
		doubleClickEnabled = true;
		variableRowHeight = true;
		allowMultipleSelection = true;
		horizontalScrollPolicy = ScrollPolicy.AUTO;
		itemRenderer = new ClassFactory(PaintGrid2ColumnItemRenderer);
		
		addEventListener(DataGridEvent.ITEM_EDIT_BEGINNING, itemEditBeginningHandler);
	}
	
	protected const globalMenu : GlobalContextMenu = new GlobalContextMenu(this as PaintGrid2);
	
	protected const cellMenu : LocalContextMenu = new LocalContextMenu();
	
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
		
		if ((cell = getCellProperties(value, false)))
			cell.assign(value);
		
		updateCell(cell);
	}
	
	protected function updateCell (value : CellProperties) : void
	{
		var cell : CellProperties;
		
		if (!(cell = getCellProperties(value, true)))
			modifiedCells.push(value);
	
	/*if (!cell in modifiedCells)
	 modifiedCells.push(cell);*/
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
			if (cell.inRange(range))
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
			if (cell.inRange(range))
			{
				cell.styles = new ObjectProxy(styles);
				cell.rollOverStyles = new ObjectProxy(rollOverStyles);
				cell.selectedStyles = new ObjectProxy(selectedStyles);
				cell.disabledStyles = new ObjectProxy(disabledStyles);
				
				updateCell(cell);
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
				cell = getCellProperties(o as CellLocation, false);
			else
				cell = getCellPropertiesAt(o.rowIndex, o.columnIndex, false);
			
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
	
	public function addColumn (index : int = 0) : int
	{
		if (index < 0)
			index = 0;
		else if (index > columns.length)
			index = columns.length;
		
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
					++cell.column;
			}
		}
		
		columns = cols;
		
		return index;
	}
	
	public function removeColumn (index : int = 0) : int
	{
		if (index < 0)
			index = 0;
		else if (index > columns.length)
			index = columns.length;
		
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
					--cell.column;
			}
		}
		
		columns = cols;
		
		return index;
	}
	
	/**
	 * Row height API
	 */
	
	[Bindable(event="rowHeightChanged")]
	public function getRowHeightAt (index : int) : Number
	{
		if (value < 0)
			return -1;
		
		var info : Row = infos[index];
		
		if (!info)
			return -1;
		
		return info.height;
	}
	
	public function setRowHeightAt (index : int, value : Number) : void
	{
		if (index < 0 || value < 0)
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
	
	public function addRow (value : Object, index : int) : void
	{
		if (!value || index < 0 || index >= collection.length)
			return;
		
		ListCollectionView(collection).addItemAt(value, index);
	}
	
	public function removeRow (index : int) : void
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
	
	protected var selectedRenderer : PaintGrid2ColumnItemRenderer;
	
	override protected function selectItem (item : IListItemRenderer, shiftKey : Boolean, ctrlKey : Boolean, transition : Boolean = true) : Boolean
	{
		var retval : Boolean = super.selectItem(item, shiftKey, ctrlKey, transition);
		
		if (isAlt)
			return retval;
		
		var currentCell : CellProperties, oldCell : CellProperties = selectedCellProperties;
		var i : int, arr : Array;
		var start : CellLocation, end : CellLocation;
		var cells : Array, cell : CellProperties;
		
		if (item is PaintGrid2ColumnItemRenderer)
		{
			if (selectedRenderer)
				selectedRenderer.contextMenu = null;
			
			selectedRenderer = PaintGrid2ColumnItemRenderer(item);
			currentCell = selectedRenderer.cell;
			
			cellMenu.owner = selectedRenderer;
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
			start = selectedCellProperties || new CellLocation();
			end = currentCell;
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
			start = selectedCellProperties || new CellLocation(), end = currentCell;
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
		
		if (item is PaintGrid2ColumnItemRenderer)
		{
			var info : Row = getInfoByUID(uid);
			var r : PaintGrid2ColumnItemRenderer = PaintGrid2ColumnItemRenderer(item);
			
			r.dataGrid = this;
			r.globalCell = _globalCellStyles;
			
			if (info)
			{
				r.cell = info.cells[colNum + horizontalScrollPosition];
				r.info = info;
			}
			
			r.invalidateDisplayList();
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
		if (!(e.itemRenderer is PaintGrid2ColumnItemRenderer))
			return;
		
		var r : PaintGrid2ColumnItemRenderer = PaintGrid2ColumnItemRenderer(e.itemRenderer);
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
	
	/*override protected function mouseUpHandler (event : MouseEvent) : void
	   {
	   var r : IListItemRenderer;
	   var dgColumn : DataGridColumn;
	
	   r = mouseEventToItemRenderer(event);
	
	   if (r)
	   {
	   if (beginEdit)
	   mouseDoubleClickHandler(event);
	
	   var dilr : IDropInListItemRenderer = IDropInListItemRenderer(r);
	
	   if (columns[dilr.listData.columnIndex].editable)
	   {
	   dgColumn = columns[dilr.listData.columnIndex];
	   dgColumn.editable = false;
	   }
	   }
	
	   super.mouseUpHandler(event);
	
	   if (dgColumn)
	   dgColumn.editable = true;
	 }*/
	
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
	
	/*override protected function moveSelectionHorizontally (code : uint, shiftKey : Boolean, ctrlKey : Boolean) : void
	   {
	   var newHorizontalScrollPosition : Number;
	   var listItem : IListItemRenderer;
	   var uid : String;
	   var len : int;
	   var bSelChanged : Boolean = false;
	
	   showCaret = true;
	
	   var rowCount : int = listItems.length;
	   var onscreenRowCount : int = listItems.length - offscreenExtraRowsTop - offscreenExtraRowsBottom;
	   var partialRow : int = (rowInfo[rowCount - offscreenExtraRowsBottom - 1].y + rowInfo[rowCount - offscreenExtraRowsBottom - 1].height > listContent.heightExcludingOffsets - listContent.topOffset) ? 1 : 0;
	   var bUpdateHorizontalScrollPosition : Boolean = false;
	   bSelectItem = false;
	
	   switch (code)
	   {
	   case Keyboard.UP:
	   {
	   if (caretIndex > 0)
	   {
	   caretIndex--;
	   bSelectItem = true;
	
	   if (caretIndex >= lockedRowCount)
	   bUpdateHorizontalScrollPosition = true;
	   }
	   break;
	   }
	
	   case Keyboard.DOWN:
	   {
	   if (caretIndex >= lockedRowCount - 1)
	   {
	   if (caretIndex < collection.length - 1)
	   {
	   caretIndex++;
	   bUpdateHorizontalScrollPosition = true;
	   bSelectItem = true;
	   }
	   else if ((caretIndex == collection.length - 1) && partialRow)
	   {
	   if (verticalScrollPosition < maxHorizontalScrollPosition)
	   newHorizontalScrollPosition = verticalScrollPosition + 1;
	   }
	   }
	   else if (caretIndex < collection.length - 1)
	   {
	   caretIndex++;
	   bSelectItem = true;
	   }
	   break;
	   }
	
	   case Keyboard.PAGE_UP:
	   {
	   if (caretIndex > lockedRowCount)
	   {
	   // if the caret is on-screen, but not at the top row
	   // just move the caret to the top row
	   if (caretIndex > verticalScrollPosition + lockedRowCount && caretIndex < verticalScrollPosition + lockedRowCount + onscreenRowCount)
	   {
	   caretIndex = verticalScrollPosition + lockedRowCount;
	   }
	   else
	   {
	   // paging up is really hard because we don't know how many
	   // rows to move because of variable row height.  We would have
	   // to double-buffer a previous screen in order to get this exact
	   // so we just guess for now based on current rowCount
	   caretIndex = Math.max(caretIndex - Math.max(onscreenRowCount - partialRow, 1), lockedRowCount);
	   newHorizontalScrollPosition = Math.max(caretIndex, lockedRowCount) - lockedRowCount;
	   }
	   bSelectItem = true;
	   }
	   else
	   {
	   caretIndex = 0;
	   bSelectItem = true;
	   }
	   break;
	   }
	
	   case Keyboard.PAGE_DOWN:
	   {
	   // if the caret is on-screen, but not at the bottom row
	   // just move the caret to the bottom row (not partial row)
	   if (caretIndex >= verticalScrollPosition + lockedRowCount && caretIndex < verticalScrollPosition + lockedRowCount + onscreenRowCount - partialRow - 1)
	   {
	   }
	   else
	   {
	   // With edge case involving very large rows
	   // make sure we move forward.
	   if ((caretIndex - lockedRowCount == verticalScrollPosition) && (onscreenRowCount - partialRow <= 1))
	   caretIndex++;
	   newHorizontalScrollPosition = Math.min(Math.max(caretIndex - lockedRowCount, 0), maxHorizontalScrollPosition);
	   }
	   bSelectItem = true;
	   break;
	   }
	
	   case Keyboard.HOME:
	   {
	   if (caretIndex > 0)
	   {
	   caretIndex = 0;
	   bSelectItem = true;
	   newHorizontalScrollPosition = 0;
	   }
	   break;
	   }
	
	   case Keyboard.END:
	   {
	   if (lockedRowCount >= collection.length)
	   {
	   caretIndex = collection.length - 1;
	   bSelectItem = true;
	   }
	   else
	   {
	   if (caretIndex < collection.length - 1)
	   {
	   caretIndex = collection.length - 1;
	   bSelectItem = true;
	   newHorizontalScrollPosition = maxHorizontalScrollPosition;
	   }
	   }
	   break;
	   }
	   case Keyboard.SPACE:
	   {
	   bUpdateHorizontalScrollPosition = true;
	   bSelectItem = true;
	   break;
	   }
	   }
	
	   if (bUpdateHorizontalScrollPosition)
	   {
	   if (caretIndex >= verticalScrollPosition + lockedRowCount + onscreenRowCount - partialRow)
	   {
	   if (onscreenRowCount - partialRow == 0)
	   newHorizontalScrollPosition = Math.min(maxHorizontalScrollPosition, Math.max(caretIndex - lockedRowCount, 0));
	   else
	   newHorizontalScrollPosition = Math.min(maxHorizontalScrollPosition, caretIndex - lockedRowCount - onscreenRowCount + partialRow + 1);
	   }
	   else if (caretIndex < verticalScrollPosition + lockedRowCount)
	   newHorizontalScrollPosition = Math.max(caretIndex - lockedRowCount, 0);
	   }
	
	   if (!isNaN(newHorizontalScrollPosition))
	   {
	   if (verticalScrollPosition != newHorizontalScrollPosition)
	   {
	   var se : ScrollEvent = new ScrollEvent(ScrollEvent.SCROLL);
	   se.detail = ScrollEventDetail.THUMB_POSITION;
	   se.direction = ScrollEventDirection.VERTICAL;
	   se.delta = newHorizontalScrollPosition - verticalScrollPosition;
	   se.position = newHorizontalScrollPosition;
	   verticalScrollPosition = newHorizontalScrollPosition;
	   dispatchEvent(se);
	   }
	
	   // bail if we page faulted
	   if (!iteratorValid)
	   {
	   keySelectionPending = true;
	   return;
	   }
	   }
	
	   bShiftKey = shiftKey;
	   bCtrlKey = ctrlKey;
	
	   lastKey = code;
	
	   finishKeySelection();
	   }
	
	   override protected function finishKeySelection () : void
	   {
	   var uid : String;
	   var rowCount : int = listItems.length;
	   var onscreenRowCount : int = listItems.length - offscreenExtraRowsTop - offscreenExtraRowsBottom;
	   var partialRow : int = (rowInfo[rowCount - offscreenExtraRowsBottom - 1].y + rowInfo[rowCount - offscreenExtraRowsBottom - 1].height > listContent.heightExcludingOffsets - listContent.topOffset) ? 1 : 0;
	
	   if (lastKey == Keyboard.PAGE_DOWN)
	   {
	   // set caret to last full row of new screen
	   // partial rows take what you can get
	   if (onscreenRowCount - partialRow == 0)
	   {
	   caretIndex = Math.min(verticalScrollPosition + lockedRowCount + onscreenRowCount - partialRow, collection.length - 1);
	   }
	   else
	   {
	   caretIndex = Math.min(verticalScrollPosition + lockedRowCount + onscreenRowCount - partialRow - 1, collection.length - 1);
	   }
	   }
	
	   var listItem : IListItemRenderer;
	   var bSelChanged : Boolean = false;
	
	   if (bSelectItem && ((caretIndex - verticalScrollPosition >= 0) || (caretIndex < lockedRowCount)))
	   {
	   if (caretIndex - lockedRowCount - verticalScrollPosition > Math.max(onscreenRowCount - partialRow - 1, 0))
	   {
	   // If we've tried to jump to the end of the list but find that
	   // maxVerticalScrollPosition was off...try again.
	   if ((lastKey == Keyboard.END) && (maxVerticalScrollPosition > verticalScrollPosition))
	   {
	   caretIndex = caretIndex - 1;
	   moveSelectionVertically(lastKey, bShiftKey, bCtrlKey);
	   return;
	   }
	   caretIndex = lockedRowCount + onscreenRowCount - partialRow - 1 + verticalScrollPosition;
	   }
	
	   if (caretIndex < lockedRowCount)
	   listItem = lockedRowContent.listItems[caretIndex][0];
	   else
	   listItem = listItems[caretIndex - lockedRowCount - verticalScrollPosition + offscreenExtraRowsTop][0];
	
	   if (listItem)
	   {
	   uid = itemToUID(listItem.data);
	
	   listItem = UIDToItemRenderer(uid);
	
	   if (!bCtrlKey || lastKey == Keyboard.SPACE)
	   {
	   selectItem(listItem, bShiftKey, bCtrlKey);
	   bSelChanged = true;
	   }
	
	   if (bCtrlKey)
	   {
	   drawItem(listItem, selectedData[uid] != null, uid == highlightUID, true);
	   }
	   }
	   }
	
	   if (bSelChanged)
	   {
	   var pt : Point = itemRendererToIndices(listItem);
	   var evt : ListEvent = new ListEvent(ListEvent.CHANGE);
	
	   if (pt)
	   {
	   evt.columnIndex = pt.x;
	   evt.rowIndex = pt.y;
	   }
	   evt.itemRenderer = listItem;
	   dispatchEvent(evt);
	   }
	 }*/
	
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
				collectionChange_add(0, ce.items.length, 0, columns.length, ce);
				break;
			
			case CollectionEventKind.REMOVE:
				collectionChange_remove(ce.location, ce.items.length + ce.location, 0, columns.length);
				break;
			
			case CollectionEventKind.REFRESH:
				collectionChange_refresh(0, collection.length, 0, columns.length);
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
	
	protected function collectionChange_add (row : int, rows : int, col : int, cols : int, e : CollectionEvent) : void
	{
		var info : Row, cell : CellProperties;
		
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
	
	protected function collectionChange_remove (row : int, rows : int, col : int, cols : int) : void
	{
		var info : Row, cell : CellProperties;
		
		for (; row < rows; ++row)
		{
			info = infos.splice(row, 1)[0];
			
			while (info.cells.length)
			{
				cell = info.cells.pop();
				cell.release();
				
				col = cells.indexOf(cell);
				
				if (col > -1)
					cells.splice(col, 1);
				
				col = modifiedCells.indexOf(cell);
				
				if (col > -1)
					modifiedCells.splice(col, 1);
			}
		}
	}
	
	protected function collectionChange_refresh (row : int, rows : int, col : int, cols : int) : void
	{
		var info : Row, cell : CellProperties;
		
		for (; row < rows; ++row)
		{
			info = infos[row];
			
			for (col = 0; col < cols; ++col)
			{
				cell = info.cells[col];
				cell.row = row;
				cell.column = col;
			}
		}
	}
}
}