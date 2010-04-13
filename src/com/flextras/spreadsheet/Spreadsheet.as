package com.flextras.spreadsheet
{
import com.flextras.calc.Calc;
import com.flextras.calc.ControlObject;
import com.flextras.calc.Utils;
import com.flextras.paintgrid.CellLocation;
import com.flextras.paintgrid.CellProperties;
import com.flextras.paintgrid.PaintGrid;
import com.flextras.paintgrid.Row;
import com.flextras.spreadsheet.context.GlobalContextMenu;
import com.flextras.spreadsheet.context.LocalContextMenu;

import flash.display.InteractiveObject;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.utils.describeType;

import mx.collections.ArrayCollection;
import mx.collections.ListCollectionView;
import mx.controls.dataGridClasses.DataGridColumn;
import mx.controls.dataGridClasses.DataGridListData;
import mx.controls.listClasses.IDropInListItemRenderer;
import mx.controls.listClasses.IListItemRenderer;
import mx.controls.listClasses.ListBaseContentHolder;
import mx.core.ClassFactory;
import mx.core.IIMESupport;
import mx.core.IInvalidating;
import mx.core.IPropertyChangeNotifier;
import mx.core.UIComponent;
import mx.core.mx_internal;
import mx.events.CollectionEvent;
import mx.events.DataGridEvent;
import mx.events.DataGridEventReason;
import mx.managers.IFocusManager;
import mx.managers.IFocusManagerComponent;

use namespace mx_internal;

/**
 * @eventType com.flextras.spreadsheet.SpreadsheetEvent.ERROR
 */
[Event(name="error", type="com.flextras.spreadsheet.SpreadsheetEvent")]

/**
 * @eventType com.flextras.spreadsheet.SpreadsheetEvent.WARNING
 */
[Event(name="warning", type="com.flextras.spreadsheet.SpreadsheetEvent")]

/**
 * Spreadsheet allows you to visauly and programatically use features and calculations found in
 * Excel and other Spreadsheet programs. It is divided into rows and columns and can accept other
 * objects and collections as variables in the calculations.
 * 
 * @includeExample SpreadsheetExample.txt
 * @includeExample SpreadsheetExample.mxml
 * 
 * @see com.flextras.paintgrid.PaintGrid
 * @see com.flextras.spreadsheet.ISpreadsheet
 */
public class Spreadsheet extends PaintGrid implements ISpreadsheet
{
	/**
	 * @private
	 */	
	protected var _rowCount : int = 15;
	
	/**
	 * @private
	 */	
	protected var _columnCount : int = 7;
	
	/**
	 * @private
	 */	
	protected var _calc : Calc;
	
	/**
	 * @private
	 */	
	protected const _expressionTree : Array = [];
	
	/**
	 * @private
	 */	
	protected var _ctrlObjects : Object = {};
	
	/**
	 * @private
	 */	
	protected var _expressions : ArrayCollection = new ArrayCollection();
	
	/**
	 * @private
	 */	
	protected var expressionsChanged : Boolean;
	
	/**
	 * @private
	 */	
	protected var ignoreExpressionUpdate : Boolean;
	
	public function Spreadsheet ()
	{
		super();
		
		this.draggableColumns = false;
		this.sortableColumns = false;
		this.showHeaders = false;
		
		doubleClickToEdit = true;
		
		this.itemRenderer = new ClassFactory(SpreadsheetItemRenderer);
		
		this.setStyle("horizontalGridLines", true);
		this.setStyle("horizontalGridLineColor", 0x666666);
		
		this.setStyle("cellRollOverBackgroundColor", 0xCCCCCC);
		this.setStyle("cellSelectedBackgroundColor", 0xCCFF33);
		this.setStyle("cellDisabledBackgroundColor", 0xFF3333);
		
		flexContextMenu = new GlobalContextMenu();
		
		addEventListener(DataGridEvent.ITEM_EDIT_BEGIN, itemEditBeginHandler);
		
		addEventListener(DataGridEvent.ITEM_EDIT_END, itemEditorItemEditEndHandler);
		
		_expressions.addEventListener(CollectionEvent.COLLECTION_CHANGE, expressionsChangeHandler);
		
		createRowsAndColumns();
	}
	
	/**
	 * @private
	 */	
	protected var _contextMenuEnabled : Boolean = true;
	
	[Bindable(event="contextMenuEnabledChanged")]
	/**
	 * Enables custom context menu
	 * 
	 * @return true if enabled, otherwise false
	 * 
	 * @default true
	 */	
	public function get contextMenuEnabled () : Boolean
	{
		return _contextMenuEnabled;
	}
	
	/**
	 * 
	 * @param value
	 * 
	 */	
	public function set contextMenuEnabled (value : Boolean) : void
	{
		if (_contextMenuEnabled == value)
			return;
		
		_contextMenuEnabled = value;
		
		dispatchEvent(new Event("contextMenuEnabledChanged"));
	}
	
	/**
	 * @private
	 */	
	override protected function createChildren () : void
	{
		super.createChildren();
		
		if (!_calc)
			calc = new Calc();
	}
	
	/////////////////////////////////////
	// PUBLIC 
	/////////////////////////////////////
	
	/**
	 * @private
	 */	
	public function updateExpressions () : void
	{
		
		expressionsChanged = true;
		invalidateProperties();
		ignoreExpressionUpdate = false;
	
	}
	
	/**
	 * 
	 * 
	 * @param cellId Valid format is "[column index in alphabetical form][row index in numerical form]".
	 * "a1" for example points to column 0 and row 1.
	 * 
	 * @param expression Actual expression of which result will be seen in the target cell.
	 * To remove existing expression type null | ""
	 * 
	 */	
	public function assignExpression (cellId : String, expression : String) : void
	{
		var o : Object = getCell(cellId);
		
		var cellObj : Object = {cell: cellId, expression: expression, value: ""};
		
		if (o)
			_expressions.setItemAt(cellObj, _expressions.getItemIndex(o));
		else
			_expressions.addItem(cellObj);
	}
	
	/**
	 * @private
	 */	
	public function getCell (cellId : String) : Object
	{
		for each (var o : Object in _expressions)
			if (o.cell == cellId)
				return o;
		
		return null;
	}
	
	/////////////////////////////
	// GETTERS SETTERS
	/////////////////////////////
	
	/**
	 * @private
	 */	
	protected var rowCountChanged : Boolean;
	
	[Bindable(event="rowCountChanged")]
	/**
	 * @inheritDoc
	 */	
	override public function get rowCount () : int
	{
		return _rowCount;
	}
	
	/**
	 * @inheritDoc
	 */	
	override public function set rowCount (value : int) : void
	{
		super.rowCount = value;
		
		if (_rowCount == value)
			return;
		
		_rowCount = value;
		
		rowCountChanged = true;
		invalidateProperties();
		
		dispatchEvent(new Event("rowCountChanged"));
	}
	
	/**
	 * @private
	 */	
	protected var columnCountChanged : Boolean;
	
	[Bindable(event="columnCountChanged")]
	/**
	 * @inheritDoc
	 */	
	override public function get columnCount () : int
	{
		return _columnCount;
	}
	
	/**
	 * @inheritDoc
	 */	
	override public function set columnCount (value : int) : void
	{
		if (_columnCount == value)
			return;
		
		_columnCount = value;
		
		columnCountChanged = true;
		invalidateProperties();
		
		dispatchEvent(new Event("columnCountChanged"));
	}
	
	[Bindable(event="calcChanged")]
	/**
	 * @return 
	 * 
	 * @see com.flextras.calc.Calc
	 */	
	public function get calc () : Calc
	{
		return _calc;
	}
	
	/**
	 * 
	 * @param value
	 */	
	public function set calc (value : Calc) : void
	{
		if (_calc === value)
			return;
		
		if (_calc)
		{
			_calc.removeEventListener(SpreadsheetEvent.ERROR, onCalcError);
			_calc.removeEventListener(SpreadsheetEvent.WARNING, onCalcWarning);
		}
		
		_calc = value;
		
		if (value)
		{
			value.addSpreadsheet(this);
			value.addEventListener(SpreadsheetEvent.ERROR, onCalcError);
			value.addEventListener(SpreadsheetEvent.WARNING, onCalcWarning);
		}
		
		dispatchEvent(new Event("calcChanged"));
	}
	
	[Bindable(event="expressionsChanged")]
	/**
	 * 
	 * @return 
	 * 
	 */	
	public function get expressions () : ArrayCollection
	{
		return _expressions;
	}
	
	/**
	 * 
	 * @param value
	 * 
	 */	
	public function set expressions (value : ArrayCollection) : void
	{
		if (_expressions === value)
			return;
		
		var oldValue : ArrayCollection = _expressions;
		
		if (_expressions)
			_expressions.removeEventListener(CollectionEvent.COLLECTION_CHANGE, expressionsChangeHandler);
		
		_expressions = value;
		
		if (value)
		{
			var ov : Object, o : Object, found : Boolean;
			
			for each (ov in oldValue)
			{
				found = false;
				
				for each (o in value)
					if (ov.cell == o.cell)
						found = true;
				
				if (!found)
					value.addItem(ov);
			}
			
			value.addEventListener(CollectionEvent.COLLECTION_CHANGE, expressionsChangeHandler);
			
			value.refresh();
		}
	}
	
	/**
	 * @private
	 */	
	public function get ctrlObjects () : Object
	{
		return _ctrlObjects;
	}
	
	/**
	 * @private
	 */	
	public function get gridDataProvider () : ArrayCollection
	{
		return collection as ArrayCollection;
	}
	
	/**
	 * @private
	 */	
	public function get expressionTree () : Array
	{
		return _expressionTree;
	}
	
	/**
	 * @protected
	 */	
	override public function set columns (value : Array) : void
	{
		for each (var column : DataGridColumn in value)
		{
			column.itemEditor = new ClassFactory(SpreadsheetItemEditor);
			column.editorDataField = "actualValue";
		}
		
		super.columns = value;
	}
	
	/**
	 * 
	 * @param index
	 * 
	 */	
	public function insertRowAt (index : int) : void
	{
		if (index < 0 || index >= collection.length)
			return;
		
		location = index;
		
		ListCollectionView(collection).addItemAt(createRow, collection.length);
	}
	
	/**
	 * @inheritDoc
	 */	
	override public function insertRow (value : Object, index : int) : void
	{
		throw new Error("Method insertRow is not supported in Spreadsheet, use instead insertRowAt");
	}
	
	/**
	 * @inheritDoc
	 */	
	override public function removeRowAt (index : int) : void
	{
		if (index < 0 || index >= collection.length)
			return;
		
		location = index;
		clearRowAt(index);
		
		callLater(removeLastCollectionItem);
	}
	
	/**
	 * @private
	 */	
	protected function removeLastCollectionItem () : void
	{
		ListCollectionView(collection).removeItemAt(collection.length - 1);
	}
	
	/**
	 * 
	 * @param index
	 * 
	 */	
	public function clearRowAt (index : int) : void
	{
		var arr : Array = getRowExpressions(index);
		
		for each (var co : ControlObject in arr)
			assignExpression(co.id, "");
	}
	
	/**
	 * @inheritDoc
	 */	
	override public function insertColumnAt (index : int = 0) : int
	{
		if (index < 0 || index >= columns.length)
			return index;
		
		var cols : Array = columns;
		var row : int, rows : int = collection.length, n : int = cols.length;
		var prop : String = String(Utils.alphabet[n]).toLowerCase();
		
		var column : DataGridColumn = new DataGridColumn();
		column.headerText = prop;
		column.dataField = prop;
		
		cols.push(column);
		
		var i : int, j : int, cell : CellProperties;
		
		for each (var info : Row in infos)
		{
			cell = new CellProperties(info.cells[0].location.row, index);
			
			info.cells.splice(index, 0, cell);
			cells.push(cell);
			
			for (i = index + 1; i <= n; ++i)
			{
				cell = info.cells[i];
				
				if (cell)
					++cell.location.column;
			}
		}
		
		prop = String(Utils.alphabet[n]).toLowerCase();
		var co : ControlObject;
		
		for (; row < rows; ++row)
		{
			co = new ControlObject;
			
			var rowObject : Object = ListCollectionView(collection).getItemAt(row);
			
			co.id = prop + row;
			co.ctrl = rowObject;
			co.valueProp = prop;
			co.rowIndex = row;
			co.row = co.rowIndex.toString();
			co.colIndex = n;
			co.col = prop;
			co.grid = this;
			
			_ctrlObjects[co.id] = co;
		}
		
		columns = cols;
		
		updateExpressionsUponRowOrColumnChange("colIndex", index, 1, 0, [index, null, null, null]);
		
		return index;
	}
	
	/**
	 * @inheritDoc
	 */	
	override public function removeColumnAt (index : int = 0) : void
	{
		if (index < 0 || index >= columns.length)
			return;
		
		location = index;
		
		clearColumnAt(index);
		
		removeLastColumn();
		
		callLater(updateExpressionsUponRowOrColumnChange,["colIndex", location, -1, 0, [location + 1, null, null, null]]);
		
		//updateExpressionsUponRowOrColumnChange("colIndex", location, -1, 0, [location + 1, null, null, null]);
	}
	
	/**
	 * @private
	 */	
	protected function removeLastColumn () : void
	{
		var cols : Array = columns;
		
		cols.pop();
		
		var i : int, j : int, cell : CellProperties;
		var n : int = cols.length;
		
		for each (var info : Row in infos)
		{
			cell = info.cells.splice(location, 1)[0];
			cell.release();
			
			if (lastSelectedCell === cell)
			{
				lastSelectedCell = null;
				
				i = selectedCells.indexOf(cell);
				selectedCells.splice(i, 1);
			}
			
			cells.splice(cells.indexOf(cell), 1);
			
			for (i = location; i < n; ++i)
			{
				cell = info.cells[i];
				
				if (cell)
					--cell.location.column;
			}
		}
		
		columns = cols;
		
		
	}
	
	/**
	 * 
	 * @param index
	 * 
	 */	
	public function clearColumnAt (index : int) : void
	{
		if (index < 0 || index >= columns.length)
			return;
		
		var prop : String = String(Utils.alphabet[index]).toLowerCase();
		
		for (var row : int, rows : int = collection.length; row < rows; ++row)
			assignExpression(prop + row, "");
	}
	
	// indexProp is either 'colIndex' or 'rowIndex'
	// index is an index where the insertion happened
	/**
	 * @private
	 */	
	protected function updateExpressionsUponRowOrColumnChange (indexProp : String, index : int, dx : int, dy : int, excludeRule : Array = null) : void
	{
		var newCopy : Array = [];
		var co : ControlObject;
		
		for each (co in expressionTree)
		{
			var cell : Object = new Object();
			cell.value = "";
			
			if (co[indexProp] >= index)
				cell.cell = Utils.moveFieldId(co.id, dx, dy);
			else
				cell.cell = co.id;
			
			cell.expression = co.exp ? Utils.moveExpression(co, dx, dy, null, excludeRule) : co.ctrl[co.valueProp];
			
			newCopy.push(cell);
		}
		
		clearExpressions();
		
		callLater(assignExpressions, [newCopy]);
	}
	
	/**
	 * 
	 * @param expressions
	 * 
	 */	
	public function assignExpressions (expressions : Array) : void
	{
		for each (var o : Object in expressions)
			this.assignExpression(o.cell, o.expression);
	}
	
	/**
	 * @private
	 */	
	public function clearExpressions () : void
	{
		for each (var co : ControlObject in expressionTree)
			this.assignExpression(co.id, "");
	}
	
	/**
	 * @private
	 */	
	public function getRowExpressions (index : int) : Array
	{
		var ra : Array = [];
		
		for each (var co : ControlObject in expressionTree)
			if (co.rowIndex == index)
				ra.push(co);
		
		return ra;
	}
	
	/**
	 * @private
	 */	
	public function moveRange (range : Array, dx : int, dy : int, copy : Boolean = false) : void
	{
		moveRangeExpressions(range, dx, dy, copy);
		moveRangeStyles(range, dx, dy, copy);
	}
	
	/**
	 * @private
	 */	
	public function moveRangeValues (range : Array, dx : int, dy : int, copy : Boolean = false) : void
	{
		calc.moveRangeValues(range, dx, dy, copy);
	}
	
	/**
	 * @private
	 */	
	public function moveRangeExpressions (range : Array, dx : int, dy : int, copy : Boolean = false) : void
	{
		calc.moveRange(range, dx, dy, copy);
	}
	
	/**
	 * @private
	 */	
	public function moveRangeStyles (range : Array, dx : int, dy : int, copy : Boolean = false) : void
	{
		var co : ControlObject, l : Array, oc : CellProperties, nc : CellProperties;
		
		for each (var ctrl : * in range)
		{
			co = calc.getCtrl(ctrl);
			
			if (!co.grid)
				throw new Error("Only objects within ISpreadsheet can be moved");
			
			l = Utils.gridFieldToIndexes(co.id);
			oc = getCellProperties(new CellLocation(l[1], l[0]), false);
			nc = getCellProperties(new CellLocation(oc.location.row + dy, oc.location.column + dx), false);
			
			if (!nc)
				continue;
			
			nc.assign(oc);
			
			if (!copy)
				oc.assign(globalCellStyles);
		}
	}
	
	///////////////////////////////////////////////////////////
	// PRIVATE && PROTECTED
	///////////////////////////////////////////////////////////
	
	/**
	 * @private
	 */	
	protected function createRowsAndColumns () : void
	{
		var arr : ArrayCollection = new ArrayCollection();
		
		for (var r : int; r < rowCount; ++r)
			arr.addItem(createRow);
		
		dataProvider = arr;
	}
	
	/**
	 * @private
	 */	
	protected function get createRow () : Object
	{
		var o : Object = {};
		
		for (var c : int = 0; c < columnCount; ++c)
			o[String.fromCharCode(97 + c)] = "";
		
		return o;
	}
	
	/**
	 * @private
	 */	
	override protected function measure () : void
	{
		super.measure();
		
		if (isNaN(explicitHeight))
			measuredHeight = measureHeightOfItems(0, rowCount + 1);
	}
	
	/**
	 * @private
	 */	
	override protected function updateDisplayList (w : Number, h : Number) : void
	{
		super.updateDisplayList(w, h);
	}
	
	/**
	 * @private
	 */	
	override protected function commitProperties () : void
	{
		super.commitProperties();
		
		if (rowCountChanged)
		{
			for (var r : int = collection.length; r < rowCount; ++r)
				insertRowAt(r - 1);
			
			for (r = collection.length; r > rowCount; --r)
				removeRowAt(r - 1);
			
			invalidateSize();
			
			rowCountChanged = false;
		}
		
		if (columnCountChanged)
		{
			for (var c : int = columns.length; c < columnCount; ++c)
				insertColumnAt(c - 1);
			
			for (c = columns.length; c > columnCount; --c)
				removeColumnAt(c - 1);
			
			columnCountChanged = false;
		}
		
		if (expressionsChanged)
		{
			var usedCells : Array = [];
			var e : SpreadsheetEvent;
			
			c = 0;
			
			while (c < _expressions.length)
			{
				var o : Object = _expressions.getItemAt(c);
				
				var cell : String = o.cell as String;
				
				if (usedCells.indexOf(cell) != -1)
					throw new Error("Cell ID already used in this collection: " + cell + ". Use setItem() or itemUpdated() if you want to change existing cell's expression.");
				
				usedCells.push(cell);
				
				var cellIndex : int = Utils.gridFieldToIndexes(cell)[0];
				var rowIndex : int = Utils.gridFieldToIndexes(cell)[1];
				
				if (rowIndex <= _rowCount && cellIndex <= _columnCount)
				{
					if (cell.indexOf("!") == -1)
					{
						var co : ControlObject = _ctrlObjects[cell];
						
						if (o.expression != null)
						{
							calc.assignControlExpression(co, o.expression);
							
							if (o.expression == "")
							{
								_expressions.removeItemAt(c);
							}
							else
							{
								c++;
							}
						}
					}
					else
					{
						e = new SpreadsheetEvent(SpreadsheetEvent.WARNING);
						e.message = cell + " - cell ignored due to incorect id";
						this.dispatchEvent(e);
					}
				}
				else
				{
					e = new SpreadsheetEvent(SpreadsheetEvent.WARNING);
					e.message = cell + " out of column or row bounds on Spreadsheet " + this.id;
					this.dispatchEvent(e);
				}
			}
			
			expressionsChanged = false;
		}
	}
	
	/**
	 * @private
	 */	
	override protected function collectionChange_reset (rows : int, cols : int) : void
	{
		super.collectionChange_reset(rows, cols);
		
		var row : int, col : int, prop : String;
		
		_ctrlObjects = {};
		
		for (; row < rows; ++row)
		{
			var rowObject : Object = collection[row];
			
			for (col = 0; col < cols; ++col)
			{
				var co : ControlObject = new ControlObject;
				
				prop = String(Utils.alphabet[col]).toLowerCase();
				
				co.id = prop + row;
				co.ctrl = rowObject;
				co.valueProp = prop;
				co.rowIndex = row;
				co.row = co.rowIndex.toString();
				co.colIndex = col;
				co.col = prop;
				co.grid = this;
				
				_ctrlObjects[co.id] = co;
			}
		}
	}
	
	/**
	 * @private
	 */	
	protected var location : int;
	
	/**
	 * @private
	 */	
	override protected function collectionChange_add (rows : int, cols : int, e : CollectionEvent) : void
	{
		super.collectionChange_add(rows, cols, e);
		
		var co : ControlObject, prop : String;
		var row : int, col : int;
		
		for (; row < rows; ++row)
		{
			var rowObject : Object = e.items[row];
			
			for (col = 0; col < cols; ++col)
			{
				co = new ControlObject;
				
				prop = String(Utils.alphabet[col]).toLowerCase();
				
				co.id = prop + (row + e.location);
				co.ctrl = rowObject;
				co.valueProp = prop;
				co.rowIndex = row + e.location;
				co.row = co.rowIndex.toString();
				co.colIndex = col;
				co.col = prop;
				co.grid = this;
				
				_ctrlObjects[co.id] = co;
			}
		}
		
		updateExpressionsUponRowOrColumnChange("rowIndex", location, 0, rows, [null, null, location, null]);
	}
	
	/**
	 * @private
	 */	
	override protected function collectionChange_remove (rows : int, cols : int, e : CollectionEvent) : void
	{
		super.collectionChange_remove(rows, cols, e);
		
		var row : int, col : int;
		
		var n : int = collection.length;
		
		var prop : String, co : ControlObject;
		
		for (row = e.location; row < rows; ++row)
		{
			for (; col < cols; ++col)
			{
				prop = String(Utils.alphabet[col]).toLowerCase();
				
				//co = _ctrlObjects[prop + (row + location)];
				delete _ctrlObjects[prop + (row + location)];
					//expressionTree.splice(expressionTree.indexOf(co), 1);
			}
		}
		
		updateExpressionsUponRowOrColumnChange("rowIndex", location, 0, -rows, [null, null, location, null]);
	}
	
	/*
	   override protected function collectionChange_refresh (row : int, rows : int, col : int, cols : int) : void
	   {
	   super.collectionChange_refresh(row, rows, col, cols);
	
	   var co : ControlObject, id : String, prop : String;
	
	   for (; row < rows; ++row)
	   for (col = 0; col < cols; ++col)
	   {
	   prop = String(Utils.alphabet[col]).toLowerCase();
	
	   setRowObject(_ctrlObjects[prop + row], collection[row], row, 0, col, prop, false);
	   }
	   }
	 */
	
	///////////////////////////////////////////
	// LISTENERS
	///////////////////////////////////////////
	
	/**
	 * @private
	 */	
	protected function expressionsChangeHandler (e : CollectionEvent) : void
	{
		updateExpressions();
		
		dispatchEvent(new Event("expressionsChanged"));
	}
	
	/**
	 * @private
	 */	
	protected function onCalcError (event : SpreadsheetEvent) : void
	{
		this.dispatchEvent(event);
	}
	
	/**
	 * @private
	 */	
	protected function onCalcWarning (event : SpreadsheetEvent) : void
	{
		this.dispatchEvent(event);
	}
	
	/**
	 * @private
	 */	
	override protected function keyDownHandler (event : KeyboardEvent) : void
	{
		super.keyDownHandler(event);
		
		if (selectedRenderer is ISpreadsheetItemRenderer)
			ISpreadsheetItemRenderer(selectedRenderer).showSeparators = isCtrl && isAlt;
	}
	
	/**
	 * @private
	 */	
	override protected function keyUpHandler (event : KeyboardEvent) : void
	{
		super.keyUpHandler(event);
		
		if (selectedRenderer is ISpreadsheetItemRenderer)
			ISpreadsheetItemRenderer(selectedRenderer).showSeparators = isCtrl && isAlt;
	}
	
	/**
	 * @private
	 */	
	protected function itemEditBeginHandler (e : DataGridEvent) : void
	{
		e.preventDefault();
		
		createItemEditor(e.columnIndex, e.rowIndex);
		
		if (editedItemRenderer is IDropInListItemRenderer && itemEditorInstance is IDropInListItemRenderer)
		{
			IDropInListItemRenderer(itemEditorInstance).listData = IDropInListItemRenderer(editedItemRenderer).listData;
			
			if (calc)
			{
				var col : String = String(Utils.alphabet[e.columnIndex]).toLowerCase();
				var oid : String = col + e.rowIndex;
				
				var co : ControlObject = ctrlObjects[oid];
				
				if (co && co.exp && co.exp.length > 0)
					IDropInListItemRenderer(itemEditorInstance).listData.label = co.exp; //co ? co.exp : "";
			}
		}
		
		if (!columns[e.columnIndex].rendererIsEditor)
			itemEditorInstance.data = editedItemRenderer.data;
		
		if (itemEditorInstance is IInvalidating)
			IInvalidating(itemEditorInstance).validateNow();
		
		if (itemEditorInstance is IIMESupport)
			IIMESupport(itemEditorInstance).imeMode = (columns[e.columnIndex].imeMode == null) ? imeMode : columns[e.columnIndex].imeMode;
		
		var fm : IFocusManager = focusManager;
		
		if (itemEditorInstance is IFocusManagerComponent)
			fm.setFocus(IFocusManagerComponent(itemEditorInstance));
		
		var event : DataGridEvent = new DataGridEvent(DataGridEvent.ITEM_FOCUS_IN);
		event.columnIndex = editedItemPosition.columnIndex;
		event.rowIndex = editedItemPosition.rowIndex;
		event.itemRenderer = itemEditorInstance;
		
		dispatchEvent(event);
	}
	
	/**
	 * @private
	 */	
	protected function itemEditorItemEditEndHandler(event:DataGridEvent):void
	{
		event.stopImmediatePropagation();
		
		if (!event.isDefaultPrevented())
		{
			var bChanged:Boolean = false;
			
			/*if (event.reason == DataGridEventReason.NEW_COLUMN)
			{
				if (!collectionUpdatesDisabled)
				{
					collection.disableAutoUpdate();
					collectionUpdatesDisabled = true;
				}
			}
			else
			{
				if (collectionUpdatesDisabled)
				{
					collection.enableAutoUpdate();
					collectionUpdatesDisabled = false;
				}
			}*/
			
			if (itemEditorInstance && event.reason != DataGridEventReason.CANCELLED)
			{
				var newData:Object = itemEditorInstance[columns[event.columnIndex].editorDataField];
				var property:String = columns[event.columnIndex].dataField;
				var data:Object = event.itemRenderer.data;
				var typeInfo:String = "";
				for each(var variable:XML in describeType(data).variable)
				{
					if (property == variable.@name.toString())
					{
						typeInfo = variable.@type.toString();
						break;
					}
				}
				
				if (typeInfo == "String")
				{
					if (!(newData is String))
						newData = newData.toString();
				}
				else if (typeInfo == "uint")
				{
					if (!(newData is uint))
						newData = uint(newData);
				}
				else if (typeInfo == "int")
				{
					if (!(newData is int))
						newData = int(newData);
				}
				else if (typeInfo == "Number")
				{
					if (!(newData is int))
						newData = Number(newData);
				}
				/** Old code assumed that the property would be a simply name that could be dereferenced
				 * through array notation. Using a method call here provides, minimally, an override
				 * point where developers could extend this functionality in their own datagrid subclass **/
				if (property != null && getCurrentDataValue( data, property ) !== newData)
				{
					bChanged = setNewValue( data, property, newData, event.columnIndex );
				}
				if (bChanged && !(data is IPropertyChangeNotifier || data is XML))
				{
					collection.itemUpdated(data, property);
				}
				if (event.itemRenderer is IDropInListItemRenderer)
				{
					var listData:DataGridListData = DataGridListData(IDropInListItemRenderer(event.itemRenderer).listData);
					listData.label = columns[event.columnIndex].itemToLabel(data);
					IDropInListItemRenderer(event.itemRenderer).listData = listData;
				}
				event.itemRenderer.data = data;
			}
		}
		else
		{
			if (event.reason != DataGridEventReason.OTHER)
			{
				if (itemEditorInstance && editedItemPosition)
				{
					// edit session is continued so restore focus and selection
					if (selectedIndex != editedItemPosition.rowIndex)
						selectedIndex = editedItemPosition.rowIndex;
					var fm:IFocusManager = focusManager;
					// trace("setting focus to itemEditorInstance", selectedIndex);
					if (itemEditorInstance is IFocusManagerComponent)
						fm.setFocus(IFocusManagerComponent(itemEditorInstance));
				}
			}
		}
		
		if (event.reason == DataGridEventReason.OTHER || !event.isDefaultPrevented())
		{
			destroyItemEditor();
		}
	}
	
	/**
	 * @private
	 */	
	override protected function setupColumnItemRenderer (c : DataGridColumn, contentHolder : ListBaseContentHolder, rowNum : int, colNum : int, data : Object, uid : String) : IListItemRenderer
	{
		var item : IListItemRenderer = super.setupColumnItemRenderer(c, contentHolder, rowNum, colNum, data, uid);
		
		if (item is ISpreadsheetItemRenderer)
		{
			var r : ISpreadsheetItemRenderer = ISpreadsheetItemRenderer(item);
			
			var menu : LocalContextMenu = r.cell.menu;
			
			if (menu)
				menu.unsetContextMenu(null);
			
			menu = new LocalContextMenu;
			menu.setContextMenu(InteractiveObject(r));
			
			r.cell.menu = menu;
			menu.cell = r.cell;
			
			if(r is UIComponent)
			{
				UIComponent(r).flexContextMenu = menu;
				
				UIComponent(r).invalidateDisplayList();
			}
		}
		
		return item;
	}
	
	/**
	 * @inheritDoc
	 */	
	override public function fromXML(value:XML):void
	{
		super.fromXML(value);
	}
	
	/**
	 * @inheritDoc
	 */	
	override public function toXML():XML
	{
		return super.toXML();
	}
}
}