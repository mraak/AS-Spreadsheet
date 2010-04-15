package com.flextras.paintgrid
{
import com.flextras.calc.Utils;
import com.flextras.spreadsheet.context.LocalContextMenu;

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
import mx.core.UIComponent;
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
 * @includeExample PaintGridExample.txt
 */
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
	/**
	 * 
	 * @return 
	 * 
	 */	
	public var doubleClickToEdit : Boolean;
	
	/**
	 * Styling API
	 */
	
	[ArrayElementType("CellProperties")]
	
	/**
	 * @private
	 */	
	protected var cells : Array = [];
	
	[ArrayElementType("CellProperties")]
	
	/**
	 * @private
	 */	
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
	
	/**
	 * @private
	 */	
	protected var _selectedCell : CellProperties;
	
	[Bindable(event="selectedCellPropertiesChange")]
	
	/**
	 *
	 * Returns currently selected cell properties
	 * @return
	 * 
	 * @see com.flextras.paintgrid.CellProperties
	 */
	
	public function get lastSelectedCell () : CellProperties
	{
		return _selectedCell;
	}
	
	/**
	 * 
	 * @param cell
	 */	
	public function set lastSelectedCell (cell : CellProperties) : void
	{
		if (_selectedCell === cell)
			return;
		
		_selectedCell = cell;
		
		dispatchEvent(new Event("selectedCellPropertiesChange"));
	}
	
	/**
	 * 
	 * @param at
	 * @param modified
	 * @return 
	 * 
	 * @see com.flextras.paintgrid.CellLocation
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
	
	/**
	 * 
	 * @param value
	 * 
	 * @see com.flextras.paintgrid.CellProperties
	 */	
	public function setCellProperties (value : CellProperties) : void
	{
		if (!value || !value.valid)
			return;
		
		var cell : CellProperties;
		
		if ((cell = getCellProperties(value.location, false)))
			cell.assign(value);
		
		if(value.condition)
		{
			cell.conditionEnabled = true;
			cell.condition.assign(value.condition);
		}
	}
	
	/**
	 * wrappers
	 */
	
	/**
	 * @private
	 */	
	protected const _globalCellStyles : CellProperties = new CellProperties();
	
	[Bindable(event="globalCellStylesChanged")]
	/**
	 * 
	 * @return 
	 * 
	 * @see com.flextras.paintgrid.CellProperties
	 */	
	public function get globalCellStyles () : CellProperties
	{
		return _globalCellStyles;
	}
	
	/**
	 * 
	 * @param value
	 * 
	 * @see com.flextras.paintgrid.CellProperties
	 */	
	public function set globalCellStyles (value : CellProperties) : void
	{
		if (value === _globalCellStyles)
			return;
		
		_globalCellStyles.assign(value);
		
		dispatchEvent(new Event("globalCellStylesChanged"));
	}
	
	/**
	 * 
	 * @param at
	 * @param modified
	 * @return 
	 * 
	 * @see com.flextras.paintgrid.CellLocation
	 */	
	public function getCellStyles (at : CellLocation, modified : Boolean = true) : Object
	{
		var cell : CellProperties = getCellProperties(at, modified);
		
		if (!cell)
			return null;
		
		return cell.styles;
	}
	
	/**
	 * 
	 * @param location
	 * @param styles
	 * @param condition
	 * @param conditionalStyles
	 * 
	 * @see com.flextras.paintgrid.CellLocation
	 */	
	public function setCellStyles (location : CellLocation, styles : Object = null, condition : String = null, conditionalStyles : Object = null) : void
	{
		if (!location || !location.valid)
			return;
		
		var c:Condition, cell : CellProperties;
		
		if (condition)
		{
			var o : Object = Utils.breakComparisonInput(condition);
			
			c = new Condition(o.arg1, o.op, o.arg2, conditionalStyles);
			cell = getCellProperties(location, false);
			cell.conditionEnabled = true;
			cell.condition.assign(c);
			cell.styles = new ObjectProxy(styles);
		}
		
		cell ||= new CellProperties(location.row, location.column, styles, null, null, null, c);
		
		setCellProperties(cell);
	}
	
	/**
	 * 
	 * @param range
	 * @param modified
	 * @return 
	 * 
	 * @see com.flextras.paintgrid.CellRange
	 * @see com.flextras.paintgrid.CellProperties
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
	
	/**
	 * 
	 * @param range
	 * @param properties
	 * 
	 * @see com.flextras.paintgrid.CellRange
	 * @see com.flextras.paintgrid.CellProperties
	 */	
	public function setCellPropertiesInRange (range : CellRange, properties:CellProperties) : void
	{
		if (!range || !range.valid || !properties || !properties.valid)
			return;
		
		for each (var cell : CellProperties in cells)
			if (cell.location.inRange(range))
				cell.assign(properties);
	}
	
	/**
	 * Disabled Cells API
	 */
	
	/**
	 * Returns empty array or array of disabled cells.
	 *
	 * @return
	 *
	 * @see com.flextras.paintgrid.CellProperties
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
	 * @see com.flextras.paintgrid.CellLocation
	 * @see com.flextras.paintgrid.CellProperties
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
	/**
	 * 
	 * @param index
	 * @return 
	 * 
	 */	
	public function getColumnWidthAt (index : int) : Number
	{
		if (index < 0 || index >= columns.length)
			return -1;
		
		var col : DataGridColumn = columns[index];
		
		return col ? col.width : -1;
	}
	
	/**
	 * 
	 * @param index
	 * @param value
	 * 
	 */	
	public function setColumnWidthAt (index : int, value : Number) : void
	{
		if (index < 0 || index >= columns.length || value < 0)
			return;
		
		resizeColumn(index, value);
		
		callLater(dispatchEvent, [new Event("columnWidthChanged")]);
	}
	
	/**
	 * 
	 * @param index
	 * @return 
	 * 
	 */	
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
			cell.addEventListener(Event.CHANGE, cell_changeHandler);
			
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
	
	/**
	 * 
	 * @param index
	 * 
	 */	
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
			cell.removeEventListener(Event.CHANGE, cell_changeHandler);
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
	/**
	 * 
	 * @param index
	 * @return 
	 * 
	 */	
	public function getRowHeightAt (index : int) : Number
	{
		if (index < 0 || index >= collection.length)
			return -1;
		
		var info : Row = infos[index];
		
		return info ? info.height : -1;
	}
	
	/**
	 * 
	 * @param index
	 * @param value
	 * 
	 */	
	public function setRowHeightAt (index : int, value : Number) : void
	{
		if (index < 0 || index >= collection.length || value < 0)
			return;
		
		var info : Row = infos[index];
		
		if (!info)
			return;
		
		info.height = value;
		//rowInfo[index - verticalScrollPosition].height = value;
		
		itemsSizeChanged = true;
		invalidateDisplayList();
		
		callLater(dispatchEvent, [new Event("rowHeightChanged")]);
	}
	
	/**
	 * 
	 * @param value
	 * @param index
	 * 
	 */	
	public function insertRow (value : Object, index : int) : void
	{
		if (!value || index < 0 || index >= collection.length)
			return;
		
		ListCollectionView(collection).addItemAt(value, index);
	}
	
	/**
	 * 
	 * @param index
	 * 
	 */	
	public function removeRowAt (index : int) : void
	{
		if (index < 0 || index >= collection.length)
			return;
		
		ListCollectionView(collection).removeItemAt(index);
	}
	
	[ArrayElementType("Row")]
	/**
	 * @private
	 */	
	protected var infos : Array = [];
	
	/**
	 * @private
	 */	
	protected function getInfoByUID (value : String) : Row
	{
		if (!value || !value.length)
			return null;
		
		for each (var info : Row in infos)
			if (info.uid == value)
				return info;
		
		return null;
	}
	
	/**
	 * @private
	 */	
	protected var _selectedCells : Array = [];
	
	[Bindable(event="selectedCellsChanged")]
	/**
	 * 
	 * @return 
	 * 
	 * @see com.flextras.paintgrid.CellProperties
	 */	
	public function get selectedCells () : Array
	{
		return _selectedCells;
	}
	
	/**
	 * @private
	 */	
	protected var selectedRenderer : IPaintGridItemRenderer;
	
	/**
	 * @private
	 */	
	override protected function selectItem (item : IListItemRenderer, shiftKey : Boolean, ctrlKey : Boolean, transition : Boolean = true) : Boolean
	{
		var retval : Boolean = super.selectItem(item, shiftKey, ctrlKey, transition);
		
		if (isAlt)
			return retval;
		
		var currentCell : CellProperties, oldCell : CellProperties = lastSelectedCell;
		var i : int, arr : Array;
		var start : CellLocation, end : CellLocation;
		var cells : Array, cell : CellProperties;
		
		if (item is IPaintGridItemRenderer)
		{
			selectedRenderer = IPaintGridItemRenderer(item);
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
		if(selectedRenderer is UIComponent) UIComponent(selectedRenderer).invalidateDisplayList();
		dispatchEvent(new Event("selectedCellsChanged"));
		
		return retval;
	}
	
	/**
	 * @private
	 */	
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
	
	/**
	 * @private
	 */	
	override protected function setupColumnItemRenderer (c : DataGridColumn, contentHolder : ListBaseContentHolder, rowNum : int, colNum : int, data : Object, uid : String) : IListItemRenderer
	{
		var item : IListItemRenderer = super.setupColumnItemRenderer(c, contentHolder, rowNum, colNum, data, uid);
		
		if (!item)
			return null;
		
		item.styleName = this;
		
		if (item is IPaintGridItemRenderer)
		{
			var info : Row = getInfoByUID(uid);
			var r : IPaintGridItemRenderer = IPaintGridItemRenderer(item);
			
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
	
	override protected function drawHighlightIndicator(indicator:Sprite, x:Number, y:Number, width:Number, height:Number, color:uint, itemRenderer:IListItemRenderer):void
	{
		
	}
	
	/**
	 * @private
	 */	
	override protected function drawSelectionIndicator (indicator : Sprite, x : Number, y : Number, width : Number, height : Number, color : uint, itemRenderer : IListItemRenderer) : void
	{
	
	}
	
	/**
	 * @private
	 */	
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
		if (!(e.itemRenderer is IPaintGridItemRenderer))
			return;
		
		var r : IPaintGridItemRenderer = IPaintGridItemRenderer(e.itemRenderer);
		var cell : CellProperties = r.cell;
		
		if (!cell || !cell.enabled || !beginEdit)
			e.preventDefault();
		
		beginEdit = false;
	}
	
	/**
	 * @private
	 */	
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
	
	/**
	 * @private
	 */	
	mx_internal var preventFromEditing : Boolean;
	
	/**
	 * @private
	 */	
	protected var beginEdit : Boolean;
	
	/**
	 * @private
	 */	
	mx_internal var isCtrl : Boolean;
	
	/**
	 * @private
	 */	
	mx_internal var isAlt : Boolean;
	
	/**
	 * @private
	 */	
	override protected function keyDownHandler (event : KeyboardEvent) : void
	{
		super.keyDownHandler(event);
		
		isCtrl = event.ctrlKey;
		isAlt = event.altKey;
	}
	
	/**
	 * @private
	 */	
	override protected function keyUpHandler (event : KeyboardEvent) : void
	{
		super.keyUpHandler(event);
		
		isCtrl = event.ctrlKey;
		isAlt = event.altKey;
	}
	
	/**
	 * @private
	 */	
	mx_internal function get hScrollBar () : ScrollBar
	{
		return horizontalScrollBar;
	}
	
	/**
	 * @private
	 */	
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
	
	/**
	 * @private
	 */	
	protected function collectionChange_reset (rows : int, cols : int) : void
	{
		var row : int, col : int, info : Row, cell : CellProperties;
		
		while (infos.length)
		{
			info = infos.pop();
			
			while (info.cells.length)
			{
				cell = info.cells.pop();
				cell.removeEventListener(Event.CHANGE, cell_changeHandler);
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
				cell.addEventListener(Event.CHANGE, cell_changeHandler);
				info.cells[col] = cell;
				
				cells.push(cell);
			}
			
			infos.push(info);
		}
	}
	
	/**
	 * @private
	 */	
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
				cell.addEventListener(Event.CHANGE, cell_changeHandler);
				info.cells[col] = cell;
				
				cells.push(cell);
			}
			
			infos.splice(row + e.location, 0, info);
		}
	}
	
	/**
	 * @private
	 */	
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
				cell.removeEventListener(Event.CHANGE, cell_changeHandler);
				
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
	
	/**
	 * @private
	 */	
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
	
	/**
	 * 
	 * @param value
	 * 
	 */	
	public function fromXML(value:XML):void
	{
	}
	
	/**
	 * 
	 * @return 
	 * 
	 */	
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
	
	protected function cell_changeHandler(e:Event):void
	{
		var cell:CellProperties = e.target as CellProperties;
		
		if(!cell) return;
		
		if(modifiedCells && modifiedCells.indexOf(cell) < 0)
			modifiedCells.push(cell);
	}
}
}