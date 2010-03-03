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
import mx.controls.TextInput;
import mx.controls.dataGridClasses.DataGridColumn;
import mx.core.ClassFactory;
import mx.core.mx_internal;
import mx.events.CollectionEvent;
import mx.events.DataGridEvent;

use namespace mx_internal;

[Event(name="error", type="com.flextras.spreadsheet.SpreadsheetEvent")]
[Event(name="warning", type="com.flextras.spreadsheet.SpreadsheetEvent")]
[Event(name="cellClick", type="com.flextras.spreadsheet.SpreadsheetEvent")]
[Event(name="cellDoubleClick", type="com.flextras.spreadsheet.SpreadsheetEvent")]
[Event(name="cellRollOver", type="com.flextras.spreadsheet.SpreadsheetEvent")]
[Event(name="cellRollOut", type="com.flextras.spreadsheet.SpreadsheetEvent")]
[Event(name="cellDataChange", type="com.flextras.spreadsheet.SpreadsheetEvent")]

/**
 * Spreadsheet allows you to visauly and programatically use features and calculations found in
 * Excel and other Spreadsheet programs. It is divided into rows and columns and can accept other
 * objects and collections as variables in the calculations.
 *
 * */
public class PaintSpreadsheet2 extends PaintGrid2 /*DataGrid*/implements ISpreadsheet
{
	
	[Bindable]
	private var _gridDataProvider : ArrayCollection;
	
	private var _rowCount : int = 15;
	
	private var _columnCount : int = 10;
	
	private var _calc : Calc;
	
	private var _expressionTree : Array = new Array();
	
	private var _renderers : Object = new Object();
	
	private var _ctrlObjects : Object = new Object();
	
	private var _expressions : ArrayCollection = new ArrayCollection();
	
	private var _expressionsTemp : *;
	
	private var _cellResizePolicy : String = SpreadsheetCellResizePolicy.ALL;
	
	private var expressionsChanged : Boolean;
	
	private var expressionChangeEvent : CollectionEvent;
	
	private var calculatedWidth : Number;
	
	public function PaintSpreadsheet2 ()
	{
		super();
		
		this.draggableColumns = false;
		this.sortableColumns = false;
		this.showHeaders = false;
		doubleClickToEdit = true;
		
		this.itemRenderer = new ClassFactory(PaintSpreadsheetItemRenderer);
		
		//this.addEventListener(DataGridEvent.ITEM_FOCUS_IN, onItemFocusIn);
		
		addEventListener(DataGridEvent.ITEM_EDIT_END, itemEditEndHandler);
	
	}
	
	////////////////////////////////////////////////////
	// OVERRIDES
	////////////////////////////////////////////////////
	
	override protected function createChildren () : void
	{
		super.createChildren();
		
		if (!calc)
			calc = new Calc();
		
		createRowsAndColumns();
	
	}
	
	override protected function commitProperties () : void
	{
		super.commitProperties();
		
		if (expressionsChanged)
		{
			expressionsChanged = false;
			
			if (_expressions is ArrayCollection)
			{
				var usedCells : Array = new Array();
				
				for each (var o : Object in _expressions)
				{
					var cell : String = o.cell as String;
					
					if (usedCells.indexOf(cell) != -1)
						throw(new Error("Cell ID already used in this collection: " + cell + ". Use setItem() or itemUpdated() if you want to change existing cell's expression."));
					
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
							var wEvt : SpreadsheetEvent = new SpreadsheetEvent(SpreadsheetEvent.WARNING);
							wEvt.message = cell + " - cell ignored due to incorect id";
							this.dispatchEvent(wEvt);
						}
					}
					else
					{
						var wEvt1 : SpreadsheetEvent = new SpreadsheetEvent(SpreadsheetEvent.WARNING);
						wEvt1.message = cell + " out of column or row bounds on Spreadsheet " + this.id;
						this.dispatchEvent(wEvt1);
					}
				}
				
				updateExpressions();
				dispatchEvent(new Event("expressionsChanged"));
			}
			
			var expEvt : SpreadsheetEvent = new SpreadsheetEvent(SpreadsheetEvent.EXPRESSIONS_INITIALIZED);
			this.dispatchEvent(expEvt);
		}
	
	}
	
	override protected function mouseUpHandler (event : MouseEvent) : void
	{
		var saved : Boolean = editable;
		editable = false;
		super.mouseUpHandler(event);
		editable = saved;
	
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
			o[String.fromCharCode(97 + c)] = null;
		
		return o;
	}
	
	///////////////////////////////////////////
	// LISTENERS
	///////////////////////////////////////////
	
	private function onItemFocusIn (evt : DataGridEvent) : void
	{
		var col : String = String(Utils.alphabet[evt.columnIndex]).toLowerCase();
		var oid : String = col + evt.rowIndex;
		
		var co : ControlObject = _ctrlObjects[oid];
		var t : String = TextInput(itemEditorInstance).text;
		var ce : String = co.exp;
		var cv : String = co.ctrl[col];
		
		if (ce != null && ce != "")
		{
			TextInput(evt.itemRenderer).text = ce;
		}
	}
	
	protected function onExpressionsChange (e : CollectionEvent) : void
	{
		
		expressionChangeEvent = e;
		expressionsChanged = true;
		invalidateProperties();
	}
	
	protected function onCalcError (event : SpreadsheetEvent) : void
	{
		var e : SpreadsheetEvent = new SpreadsheetEvent(SpreadsheetEvent.ERROR);
		e.message = event.message;
		this.dispatchEvent(e);
	}
	
	protected function onCalcWarning (event : SpreadsheetEvent) : void
	{
		var e : SpreadsheetEvent = new SpreadsheetEvent(SpreadsheetEvent.WARNING);
		e.message = event.message;
		this.dispatchEvent(e);
	}
	
	/////////////////////////////////////
	// PUBLIC 
	/////////////////////////////////////
	
	public function updateExpressions () : void
	{
		_expressions.source = expressions.source;
	}
	
	public function assignExpression (cellId : String, expression : String) : void
	{
		var co : ControlObject = _ctrlObjects[cellId.toLowerCase()];
		//calc.assignControlExpression(co, expression);
		
		var o : Object = getCell(cellId);
		
		var cellObj : Object = {cell: cellId, expression: expression}
		
		if (o)
		{
			var ind : int = _expressions.getItemIndex(o);
			_expressions.setItemAt(cellObj, ind);
		}
		else
		{
			if (_expressions)
				_expressions.addItem(cellObj);
		}
	
	}
	
	public function getCell (cellId : String) : Object
	{
		var ro : Object;
		
		if (_expressions is ArrayCollection)
		{
			for each (var o : Object in _expressions)
			{
				if (o.cell == cellId)
				{
					ro = o;
					break;
				}
			}
		}
		return ro;
	}
	
	/////////////////////////////
	// GETTERS SETTERS
	/////////////////////////////
	
	override public function set rowCount (value : int) : void
	{
		_rowCount = value;
		//super.rowCount = value;
	}
	
	override public function get rowCount () : int
	{
		return _rowCount;
	}
	
	override public function set columnCount (value : int) : void
	{
		_columnCount = value;
		//super.columnCount = value;
	
	}
	
	override public function get columnCount () : int
	{
		return _columnCount;
	}
	
	public function set calc (value : Calc) : void
	{
		_calc = value;
		_calc.addSpreadsheet(this);
		_calc.addEventListener(SpreadsheetEvent.ERROR, onCalcError);
		_calc.addEventListener(SpreadsheetEvent.WARNING, onCalcWarning);
	
	}
	
	public function get calc () : Calc
	{
		return _calc;
	}
	
	[Bindable(event="expressionsChanged")]
	public function set expressions (value : ArrayCollection) : void
	{
		_expressions = value;
		_expressions.addEventListener(CollectionEvent.COLLECTION_CHANGE, onExpressionsChange);
		expressionsChanged = true;
		invalidateProperties();
	}
	
	public function get expressions () : ArrayCollection
	{
		var ac : ArrayCollection = new ArrayCollection();
		var a : Array = new Array();
		
		for each (var co : ControlObject in _expressionTree)
		{
			a.push({cell: co.id, expression: co.exp, value: co.ctrl[co.valueProp]});
		}
		
		ac.source = a;
		
		return ac;
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
	
	public function get cellResizePolicy () : String
	{
		return _cellResizePolicy;
	}
	
	public function set cellResizePolicy (value : String) : void
	{
		_cellResizePolicy = value;
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
	
	override public function set columns (value : Array) : void
	{
		for each (var column : DataGridColumn in value)
		{
			column.itemEditor = new ClassFactory(SpreadsheetItemEditor);
			column.editorDataField = "actualValue";
		}
		
		super.columns = value;
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
		
		expressionsChanged = true;
		invalidateProperties();
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
		
		expressionsChanged = true;
		invalidateProperties();
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
	   }
	
	   expressionsChanged = true;
	 invalidateProperties();*/
	}
	
	protected function itemEditEndHandler (e : DataGridEvent) : void
	{
		var col : String = String(Utils.alphabet[e.columnIndex]).toLowerCase();
		var oid : String = col + e.rowIndex;
		
		var co : ControlObject = _ctrlObjects[oid];
		//var t : String = TextInput(itemEditorInstance).text;
		var ce : String = co.exp;
		var cv : String = co.ctrl[col];
		
		if (ce != null && ce != "")
		{
			//TextInput(evt.itemRenderer).text = ce;
			selectedRenderer.data = ce;
		}
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
}
}