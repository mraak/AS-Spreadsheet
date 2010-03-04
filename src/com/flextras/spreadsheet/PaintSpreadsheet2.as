package com.flextras.spreadsheet
{
import com.flextras.calc.Calc;
import com.flextras.calc.ControlObject;
import com.flextras.calc.Utils;
import com.flextras.paintgrid.PaintGrid2;

import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;

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
public class PaintSpreadsheet2 extends PaintGrid2 implements ISpreadsheet
{
	private var _rowCount : int = 15;
	
	private var _columnCount : int = 10;
	
	private var _calc : Calc;
	
	private var _expressionTree : Array = new Array();
	
	private var _renderers : Object = new Object();
	
	private var _ctrlObjects : Object = new Object();
	
	protected const _expressions : ArrayCollection = new ArrayCollection();
	
	private var _cellResizePolicy : String = SpreadsheetCellResizePolicy.ALL;
	
	private var expressionsChanged : Boolean;
	
	public function PaintSpreadsheet2 ()
	{
		super();
		
		this.draggableColumns = false;
		this.sortableColumns = false;
		this.showHeaders = false;
		doubleClickToEdit = true;
		
		this.itemRenderer = new ClassFactory(PaintSpreadsheetItemRenderer);
		
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
		if (!cellId || !cellId.length || !expression || !expression.length || expression == " ")
			return;
		
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
	
	[Bindable(event="rowCountChanged")]
	override public function get rowCount () : int
	{
		return _rowCount;
	}
	
	override public function set rowCount (value : int) : void
	{
		if (_rowCount == value)
			return;
		
		_rowCount = value;
		
		dispatchEvent(new Event("rowCountChanged"));
	}
	
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
		for each (var o : Object in value)
			if (o)
				assignExpression(o.cell, o.expression);
	}
	
	public function get renderers () : Object
	{
		return _renderers;
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
	
	[Bindable(event="cellResizePolicyChanged")]
	public function get cellResizePolicy () : String
	{
		return _cellResizePolicy;
	}
	
	public function set cellResizePolicy (value : String) : void
	{
		if (_cellResizePolicy == value)
			return;
		
		_cellResizePolicy = value;
		
		dispatchEvent(new Event("cellResizePolicyChanged"));
	}
	
	override public function set columns (value : Array) : void
	{
		for each (var column : DataGridColumn in value)
			column.itemEditor = new ClassFactory(PaintSpreadsheetItemEditor);
		
		super.columns = value;
	}
	
	public function moveRange(range:Array, dx:int, dy:int, copy:Boolean = false):void
	{
		calc.moveRange(range, dx, dy, copy);
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
		var c : int = columns.length;
		var rowObject : Object = collection[index];
		
		for (var j : int = 0; j < c; ++j)
		{
			var prop : String = String(Utils.alphabet[j]).toLowerCase();
			var co : Object = ctrlObjects[prop + index.toString()];
			
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
	
	override protected function commitProperties () : void
	{
		super.commitProperties();
		
		if (expressionsChanged)
		{
			var usedCells : Array = new Array();
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
						
						if (o.expression)
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
				var co : Object = new ControlObject;
				
				prop = String(Utils.alphabet[col]).toLowerCase();
				
				co.id = prop + row;
				co.ctrl = rowObject;
				co.valueProp = prop;
				co.rowIndex = row;
				co.row = co.rowIndex.toString();
				co.col = prop;
				co.colIndex = col;
				co.grid = this;
				
				_ctrlObjects[co.id] = co;
			}
		}
	}
	
	override protected function collectionChange_add (row : int, rows : int, col : int, cols : int, e : CollectionEvent) : void
	{
		super.collectionChange_add(row, rows, col, cols, e);
		
		for (var i : int = collection.length - 2; i > 0; --i)
			updateRowObject(i, rows);
		
		var prop : String;
		
		for (; row < rows; ++row)
		{
			var rowObject : Object = e.items[row];
			
			for (col = 0; col < cols; ++col)
			{
				var co : ControlObject = new ControlObject;
				
				prop = String(Utils.alphabet[col]).toLowerCase();
				
				co.id = prop + row;
				co.ctrl = rowObject;
				co.valueProp = prop;
				co.rowIndex = row;
				co.row = co.rowIndex.toString();
				co.col = prop;
				co.colIndex = col;
				co.grid = this;
				
				_ctrlObjects[co.id] = co;
			}
		}
	}
	
	override protected function collectionChange_remove (row : int, rows : int, col : int, cols : int) : void
	{
		super.collectionChange_remove(row, rows, col, cols);
		
		var n : int = collection.length;
		
		for (var i : int; i < n; ++i)
			updateRowObject(i, -rows);
		
		var prop : String;
		
		for (; col < cols; ++col)
		{
			prop = String(Utils.alphabet[col]).toLowerCase();
			
			for (row = n - rows; row < n; ++row)
				delete _ctrlObjects[prop + row];
		}
	}
	
	override protected function collectionChange_refresh (row : int, rows : int, col : int, cols : int) : void
	{
		super.collectionChange_refresh(row, rows, col, cols);
	
	/*var co : ControlObject, id : String, prop : String;
	
	   for (; row < rows; ++row)
	   for (col = 0; col < cols; ++col)
	   {
	   prop = String(Utils.alphabet[col]).toLowerCase();
	
	   setRowObject(_ctrlObjects[prop + row], collection[row], row, 0, col, prop, false);
	 }*/
	}
	
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
		
		if (selectedRenderer is PaintSpreadsheetItemRenderer)
			PaintSpreadsheetItemRenderer(selectedRenderer).showSeparators = isCtrl && isAlt;
	}
	
	override protected function keyUpHandler (event : KeyboardEvent) : void
	{
		super.keyUpHandler(event);
		
		if (selectedRenderer is PaintSpreadsheetItemRenderer)
			PaintSpreadsheetItemRenderer(selectedRenderer).showSeparators = isCtrl && isAlt;
	}
	
	override protected function mouseUpHandler (event : MouseEvent) : void
	{
		var saved : Boolean = editable;
		editable = false;
		super.mouseUpHandler(event);
		editable = saved;
	
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
		
		if (itemEditorInstance is PaintSpreadsheetItemEditor)
			assignExpression(oid, PaintSpreadsheetItemEditor(itemEditorInstance).text);
		
		destroyItemEditor();
	}
}
}