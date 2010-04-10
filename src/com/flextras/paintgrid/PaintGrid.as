package com.flextras.paintgrid
{
import com.flextras.calc.Utils;

import flash.display.Sprite;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.utils.IDataInput;
import flash.utils.IDataOutput;
import flash.utils.IExternalizable;

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
/**
 * You can use PaintGrid in the same way as you use DataGrid, with additional styling options and visual
 * formatting. 
 * <br/><br/>
 * 
 * To apply style to a particular cell:<br/>
 * setCellStylesAt(0, 0, {backgroundColor : 0xFF0000, color: 0x00FF00, size : 30});
 * <br/><br/>
 * 
 * To disable cells:<br/>
 * disabledCells = [new CellLocation(0,0), new CellLocation(1,0)];
 * <br/><br/>
 * 
 * To apply global styles (you can apply global styles through external CSS also):<br/>
 * setStyle("cellRollOverBackgroundColor", 0xFF0000);<br/>
 * setStyle("cellSelectedBackgroundColor", 0xCCFF33);<br/>
 * setStyle("cellDisabledBackgroundColor", 0xFF3333);<br/>
 * <br/><br/>
 * 
 * To set row height:<br>
 * setRowHeightAt(0, 50);
 * <br/><br/>
 * 
 * To set column width:<br>			
 * setColumnWidthAt(0, 200);
 *
 * 
 * 
 * */
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
	
	/*public function getAllCellProperties (modified : Boolean = true) : Array
	   {
	   return modified ? modifiedCells : cells;
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
	
	public function get lastSelectedCell () : CellProperties
	{
		return _selectedCell;
	}
	
	public function set lastSelectedCell (cell : CellProperties) : void
	{
		if (_selectedCell === cell)
			return;
		
		_selectedCell = cell;
		
		dispatchEvent(new Event("selectedCellPropertiesChange"));
	}
	
	/**
	 * Instance of CellProperties
	 */
	
	public function getCellProperties (at : CellLocation, modified : Boolean = true) : CellProperties
	{
		if (!at || !at.valid)
			return null;
		
		var cells : Array = modified ? modifiedCells : this.cells;
		
		for each (var cell : CellProperties in cells)
			if (cell.equalLocation(at))
				return cell;
		
		return null;
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
	
	public function getCellStyles (at : CellLocation, modified : Boolean = true) : Object
	{
		var cell : CellProperties = getCellProperties(at, modified);
		
		if (!cell)
			return null;
		
		return cell.styles;
	}
	
	public function setCellStyles (location : CellLocation, styles : Object = null, condition : String = null, conditionalStyles : Object = null) : void
	{
		if (!location || !location.valid)
			return;
		
		var c:Condition;
		
		if (condition)
		{
			var o : Object = Utils.breakComparisonInput(condition);
			
			c = new Condition(o.arg1, o.op, o.arg2, conditionalStyles);
		}
		
		var cell : CellProperties = new CellProperties(location.row, location.column, styles, null, null, null, c);
		
		setCellProperties(cell);
	}
	
	/**
	 * Array of CellProperties in Range
	 */
	
	public function getCellPropertiesInRange (range : CellRange, modified : Boolean = true) : Array
	{
		if (!range || !range.valid)
			return null;
		
		var result : Array = [];
		var cells : Array = modified ? modifiedCells : this.cells;
		
		for each (var cell : CellProperties in cells)
			if (cell.location.inRange(range))
				result.push(cell);
		
		return result;
	}
	
	public function setCellPropertiesInRange (range : CellRange, properties:CellProperties) : void
	{
		if (!range || !range.valid || !properties || !properties.valid)
			return;
		
		for each (var cell : CellProperties in cells)
			if (cell.location.inRange(range))
			{
				cell.assign(properties);
				
				updateCell(cell);
			}
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
		var cell : CellProperties;
		var cells:Array = disabledCells;
		
		for each (cell in cells)
			cell.enabled = true;
		
		for each (var o : Object in value)
		{
			if (o is CellProperties)
				cell = getCellProperties(CellProperties(o).location, false);
			else
				if (o is CellLocation)
					cell = getCellProperties(CellLocation(o), false);
				else
					cell = getCellProperties(new CellLocation(o.rowIndex, o.columnIndex), false);
			
			if (cell)
				cell.enabled = false;
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
			
			if (lastSelectedCell === cell)
			{
				lastSelectedCell = null;
				
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
		
		var currentCell : CellProperties, oldCell : CellProperties = lastSelectedCell;
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
			start = lastSelectedCell.location || new CellLocation();
			end = currentCell.location;
			cells = getCellPropertiesInRange(new CellRange(start, end), false);
			
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
			start = lastSelectedCell.location || new CellLocation(), end = currentCell.location;
			cells = getCellPropertiesInRange(new CellRange(start, end), false);
			
			for each (cell in cells)
				if ((i = _selectedCells.indexOf(cell)) < 0)
				{
					_selectedCells.push(cell);
					cell.selected = true;
				}
		}
		
		lastSelectedCell = currentCell;
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
				
				if (lastSelectedCell === cell)
				{
					lastSelectedCell = null;
					
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
				
				if (lastSelectedCell === cell)
				{
					lastSelectedCell = null;
					
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
	
	public function fromXML(value:XML):void
	{
	}
	
	public function toXML():XML
	{
		var result:XML = <PaintGrid/>;
		
		var cells : XMLList = new XMLList();
		
		for each(var cell:CellProperties in this.modifiedCells) cells += cell.toXML();
		
		var globalStyles:XML = globalCellStyles.toXML();
		
		if(cells.length())
			result.cells.* += cells;
		
		if(globalStyles.length())
			result.globalStyles.* += globalStyles;
		
		return result;
	}
}
}