package com.flextras.spreadsheet
{
import com.flextras.calc.Calc;
import com.flextras.calc.ControlObject;
import com.flextras.calc.Utils;
import com.flextras.paintgrid.CellProperties;
import com.flextras.paintgrid.PaintGrid;

import flash.events.Event;
import flash.events.KeyboardEvent;

import mx.collections.ArrayCollection;
import mx.controls.dataGridClasses.DataGridColumn;
import mx.controls.dataGridClasses.DataGridListData;
import mx.controls.listClasses.IDropInListItemRenderer;
import mx.core.ClassFactory;
import mx.core.IIMESupport;
import mx.core.IInvalidating;
import mx.core.mx_internal;
import mx.events.CollectionEvent;
import mx.events.DataGridEvent;
import mx.events.DataGridEventReason;
import mx.managers.IFocusManager;
import mx.managers.IFocusManagerComponent;

use namespace mx_internal;

[Event(name="error", type="com.flextras.spreadsheet.SpreadsheetEvent")]
[Event(name="warning", type="com.flextras.spreadsheet.SpreadsheetEvent")]

/**
 * Spreadsheet allows you to visauly and programatically use features and calculations found in
 * Excel and other Spreadsheet programs. It is divided into rows and columns and can accept other
 * objects and collections as variables in the calculations.
 *
 * */
public class Spreadsheet extends PaintGrid implements ISpreadsheet
{
	private var _rowCount : int = 15;
	
	private var _columnCount : int = 7;
	
	private var _calc : Calc;
	
	private const _expressionTree : Array = [];
	
	private var _ctrlObjects : Object = {};
	
	protected var _expressions : ArrayCollection = new ArrayCollection();
	
	private var expressionsChanged : Boolean;
	
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
		
		addEventListener(DataGridEvent.ITEM_EDIT_BEGIN, itemEditBeginHandler);
		addEventListener(DataGridEvent.ITEM_EDIT_END, itemEditEndHandler);
		
		_expressions.addEventListener(CollectionEvent.COLLECTION_CHANGE, expressionsChangeHandler);
		
		createRowsAndColumns();
	}
	
	override protected function createChildren () : void
	{
		super.createChildren();
		
		if (!_calc)
			calc = new Calc();
	}
	
	/////////////////////////////////////
	// PUBLIC 
	/////////////////////////////////////
	
	public function updateExpressions () : void
	{
		expressionsChanged = true;
		invalidateProperties();
	}
	
	public function assignExpression (cellId : String, expression : String) : void
	{
		//if (!cellId || !cellId.length || !expression || !expression.length)
		//	return;
		
		var o : Object = getCell(cellId);
		
		var cellObj : Object = {cell: cellId, expression: expression};
		
		if (o)
			_expressions.setItemAt(cellObj, _expressions.getItemIndex(o));
		else if (_expressions)
			_expressions.addItem(cellObj);
	
	}
	
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
	
	protected var rowCountChanged : Boolean;
	
	[Bindable(event="rowCountChanged")]
	override public function get rowCount () : int
	{
		return _rowCount;
	}
	
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
	
	protected var columnCountChanged : Boolean;
	
	[Bindable(event="columnCountChanged")]
	override public function get columnCount () : int
	{
		return _columnCount;
	}
	
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
	public function get calc () : Calc
	{
		return _calc;
	}
	
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
	public function get expressions () : ArrayCollection
	{
		return _expressions;
	}
	
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
	
	public function get ctrlObjects () : Object
	{
		return _ctrlObjects;
	}
	
	public function get gridDataProvider () : ArrayCollection
	{
		return collection as ArrayCollection;
	}
	
	public function get expressionTree () : Array
	{
		return _expressionTree;
	}
	
	override public function set columns (value : Array) : void
	{
		for each (var column : DataGridColumn in value)
		{
			column.itemEditor = new ClassFactory(SpreadsheetItemEditor);
			column.editorDataField = "actualValue";
		}
		
		super.columns = value;
	}
	
	override public function addRow (value : Object, index : int) : void
	{
		if (!value || index < 0 || index >= collection.length)
			return;
		
		super.addRow(value, index);
	}
	
	override public function addColumn (index : int = 0) : int
	{
		if (index < 0 || index >= columns.length)
			return index;
		
		super.addColumn(index);
		
		updateExpressionsUponRowOrColumnChange("colIndex", index, 1, 0 /*, [index, null, null, null]*/);
		
		return index;
	}
	
	override public function removeColumn (index : int = 0) : int
	{
		if (index < 0 || index >= columns.length)
			return index;
		
		super.removeColumn(index);
		
		updateExpressionsUponRowOrColumnChange("colIndex", index, -1, 0 /*, [index, null, null, null]*/);
		
		return index;
	}
	
	override public function insertRowAt (index : int) : void
	{
		addRow(createRow, index);
	}
	
	override public function insertColumnAt (index : int) : void
	{
		addColumn(index);
	}
	
	// indexProp is either 'colIndex' or 'rowIndex'
	// index is an index where the insertion happened
	private function updateExpressionsUponRowOrColumnChange (indexProp : String, index : int, dx : int, dy : int /*, excludeRule : Array = null*/) : void
	{
		var oldCopy : Array = [];
		var newCopy : Array = [];
		
		for each (var co : ControlObject in expressionTree)
		{
			var nco : ControlObject = new ControlObject();
			var oco : ControlObject = new ControlObject();
			
			if (co[indexProp] >= index)
				nco.id = Utils.moveFieldId(co.id, dx, dy);
			else
				nco.id = co.id;
			
			nco.exp = co.exp ? Utils.moveExpression(co, dx, dy /*, null*/ /*, excludeRule*/) : co.ctrl[co.valueProp];
			
			oco.id = co.id;
			
			newCopy.push(nco);
			oldCopy.push(oco);
		}
		
		for each (co in oldCopy)
			this.assignExpression(co.id, "");
		
		for each (co in newCopy)
			this.assignExpression(co.id, co.exp);
	}
	
	public function getRowExpressions (index : int) : Array
	{
		var ra : Array = [];
		
		for each (var co : ControlObject in expressionTree)
			if (co.rowIndex == index)
				ra.push(co);
		
		return ra;
	}
	
	public function moveRange (range : Array, dx : int, dy : int, copy : Boolean = false) : void
	{
		moveRangeExpressions(range, dx, dy, copy);
		moveRangeStyles(range, dx, dy, copy);
	}
	
	public function moveRangeValues (range : Array, dx : int, dy : int, copy : Boolean = false) : void
	{
		calc.moveRangeValues(range, dx, dy, copy);
	}
	
	public function moveRangeExpressions (range : Array, dx : int, dy : int, copy : Boolean = false) : void
	{
		calc.moveRange(range, dx, dy, copy);
	}
	
	public function moveRangeStyles (range : Array, dx : int, dy : int, copy : Boolean = false) : void
	{
		var co : ControlObject, l : Array, oc : CellProperties, nc : CellProperties;
		
		for each (var ctrl : * in range)
		{
			co = calc.getCtrl(ctrl);
			
			if (!co.grid)
				throw(new Error("Only objects within ISpreadsheet can be moved"));
			
			l = Utils.gridFieldToIndexes(co.id);
			oc = getCellPropertiesAt(l[1], l[0], false);
			nc = getCellPropertiesAt(oc.row + dy, oc.column + dx, false);
			
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
	
	protected function createRowsAndColumns () : void
	{
		var arr : ArrayCollection = new ArrayCollection();
		
		for (var r : int; r < rowCount; ++r)
			arr.addItem(createRow);
		
		dataProvider = arr;
	}
	
	protected function get createRow () : Object
	{
		var o : Object = {};
		
		for (var c : int = 0; c < columnCount; ++c)
			o[String.fromCharCode(97 + c)] = "";
		
		return o;
	}
	
	protected function updateRowObject (index : int, amount : int) : void
	{
		return;
		var c : int = columns.length;
		var rowObject : Object = collection[index];
		
		for (var j : int = 0; j < c; ++j)
		{
			var prop : String = String(Utils.alphabet[j]).toLowerCase();
			var co : Object = ctrlObjects[prop + index.toString()] || new ControlObject();
			
			co.id = prop + (index + amount);
			co.ctrl = rowObject;
			co.valueProp = prop;
			co.rowIndex += amount;
			co.row = co.rowIndex.toString();
			co.col = prop;
			co.colIndex = j;
			co.grid = this;
			
			_ctrlObjects[co.id] = co;
		}
	}
	
	override protected function measure () : void
	{
		super.measure();
		
		if (isNaN(explicitHeight))
			measuredHeight = measureHeightOfItems(0, rowCount + 1);
	}
	
	override protected function updateDisplayList (w : Number, h : Number) : void
	{
		super.updateDisplayList(w, h);
	}
	
	override protected function commitProperties () : void
	{
		super.commitProperties();
		
		if (rowCountChanged)
		{
			for (var r : int = collection.length; r < rowCount; ++r)
				addRow(createRow, r - 1);
			
			for (r = collection.length; r > rowCount; --r)
				removeRow(r - 1);
			
			invalidateSize();
			
			rowCountChanged = false;
		}
		
		if (columnCountChanged)
		{
			for (var c : int = columns.length; c < columnCount; ++c)
			{
				addColumn(c - 1);
				updateRowObject(c - 1, 0);
			}
			
			for (c = columns.length; c > columnCount; --c)
			{
				removeColumn(c - 1);
				updateRowObject(c - 1, 0);
			}
			
			columnCountChanged = false;
		}
		
		if (expressionsChanged)
		{
			var usedCells : Array = [];
			var e : SpreadsheetEvent;
			
			for each (var o : Object in _expressions)
			{
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
							calc.assignControlExpression(co, o.expression);
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
				co.colIndex = col;
				co.grid = this;
				
				_ctrlObjects[co.id] = co;
			}
		}
	}
	
	override protected function collectionChange_add (row : int, rows : int, col : int, cols : int, e : CollectionEvent) : void
	{
		for (i = row; i < rows; ++i)
			updateExpressionsUponRowOrColumnChange("rowIndex", i, 0, 1 /*, [null, null, i, null]*/);
		
		super.collectionChange_add(row, rows, col, cols, e);
		
		var i : int;
	
	/*for (i = collection.length - 2; i > 0; --i)
	 updateRowObject(i, rows);*/
	
	/*var a : Array = [];
	
	   for each (var co : ControlObject in ctrlObjects)
	   if (co.rowIndex >= e.location)
	   a.push(co);
	
	   calc.moveRange(a, 0, rows);
	
	   var prop : String;
	
	   for (i = row; i < rows; ++i)
	   {
	   var rowObject : Object = e.items[i];
	
	   for (col = 0; col < cols; ++col)
	   {
	   co = new ControlObject;
	
	   prop = String(Utils.alphabet[col]).toLowerCase();
	
	   co.id = prop + i;
	   co.ctrl = rowObject;
	   co.valueProp = prop;
	   co.rowIndex = i;
	   co.row = co.rowIndex.toString();
	   co.col = prop;
	   co.colIndex = col;
	   co.grid = this;
	
	   _ctrlObjects[co.id] = co;
	   }
	 }*/
	}
	
	override protected function collectionChange_remove (row : int, rows : int, col : int, cols : int) : void
	{
		super.collectionChange_remove(row, rows, col, cols);
		
		var n : int = collection.length;
		
		/*for (var i : int = rows - n; i < n; ++i)
		 updateRowObject(i, n - rows);*/
		
		/*var a : Array = [];
		
		   for each (var co : ControlObject in ctrlObjects)
		   if (co.rowIndex >= row)
		   a.push(co);
		
		 calc.moveRange(a, 0, -rows + row);*/
		
		/*var prop : String;
		
		   for (; col < cols; ++col)
		   {
		   prop = String(Utils.alphabet[col]).toLowerCase();
		
		   for (row = n - rows; row < n; ++row)
		   delete _ctrlObjects[prop + row];
		 }*/
		
		for (row = n - rows; row < n; ++row)
			updateExpressionsUponRowOrColumnChange("rowIndex", rows, 0, -1 /*, [null, null, rows, null]*/);
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
	
	protected function expressionsChangeHandler (e : CollectionEvent) : void
	{
		updateExpressions();
		
		dispatchEvent(new Event("expressionsChanged"));
	}
	
	protected function onCalcError (event : SpreadsheetEvent) : void
	{
		this.dispatchEvent(event);
	}
	
	protected function onCalcWarning (event : SpreadsheetEvent) : void
	{
		this.dispatchEvent(event);
	}
	
	override protected function keyDownHandler (event : KeyboardEvent) : void
	{
		super.keyDownHandler(event);
		
		if (selectedRenderer is SpreadsheetItemRenderer)
			SpreadsheetItemRenderer(selectedRenderer).showSeparators = isCtrl && isAlt;
	}
	
	override protected function keyUpHandler (event : KeyboardEvent) : void
	{
		super.keyUpHandler(event);
		
		if (selectedRenderer is SpreadsheetItemRenderer)
			SpreadsheetItemRenderer(selectedRenderer).showSeparators = isCtrl && isAlt;
	}
	
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
					IDropInListItemRenderer(itemEditorInstance).listData.label = co.exp;
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
	
	protected function itemEditEndHandler (e : DataGridEvent) : void
	{
		return;
		
		e.preventDefault();
		
		if (itemEditorInstance && e.reason != DataGridEventReason.CANCELLED)
		{
			if (e.itemRenderer is IDropInListItemRenderer)
			{
				var listData : DataGridListData = DataGridListData(IDropInListItemRenderer(e.itemRenderer).listData);
				listData.label = columns[e.columnIndex].itemToLabel(data);
				IDropInListItemRenderer(e.itemRenderer).listData = listData;
			}
			e.itemRenderer.data = data;
		}
		
		var col : String = String(Utils.alphabet[e.columnIndex]).toLowerCase();
		var oid : String = col + e.rowIndex;
		
		if (itemEditorInstance is SpreadsheetItemEditor)
		{
			var t : String = SpreadsheetItemEditor(itemEditorInstance).text;
			var co : ControlObject = this.ctrlObjects[oid];
			var v : String = co.ctrl[col];
			var ex : String = co.exp;
			
			if (v != t && ex != t)
			{
				assignExpression(oid, t);
			}
		}
		
		destroyItemEditor();
	}
}
}