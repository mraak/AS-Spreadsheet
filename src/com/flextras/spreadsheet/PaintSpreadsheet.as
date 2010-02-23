package com.flextras.spreadsheet
{
import com.flextras.calc.Calc;
import com.flextras.calc.ControlObject;
import com.flextras.calc.Utils;
import com.flextras.paintgrid.CellProperties;
import com.flextras.paintgrid.PaintGrid2;
import com.flextras.paintgrid.Row;

import flash.events.MouseEvent;

import mx.collections.ArrayCollection;
import mx.controls.TextInput;
import mx.controls.dataGridClasses.DataGridColumn;
import mx.core.ClassFactory;
import mx.events.CollectionEvent;
import mx.events.DataGridEvent;

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
public class PaintSpreadsheet extends PaintGrid2 /*DataGrid*/implements ISpreadsheet
{
	
	[Bindable]
	private var _gridDataProvider : ArrayCollection;
	
	private var _rowCount : int = 15;
	
	private var _columnCount : int = 10;
	
	private var _calc : Calc;
	
	private var _expressionTree : Array = new Array();
	
	private var _renderers : Object = new Object();
	
	private var _ctrlObjects : Object = new Object();
	
	private var _dataprovider : Object;
	
	private var _expressions : ArrayCollection = new ArrayCollection();
	
	private var _expressionsTemp : *;
	
	private var _cellResizePolicy : String = SpreadsheetCellResizePolicy.ALL;
	
	private var expressionsChanged : Boolean;
	
	private var expressionChangeEvent : CollectionEvent;
	
	private var calculatedWidth : Number;
	
	public function PaintSpreadsheet ()
	{
		super();
		init();
	
	}
	
	protected function init () : void
	{
		this.editable = true;
		this.draggableColumns = false;
		this.sortableColumns = false;
		this.variableRowHeight = true;
		this.showHeaders = false;
		
		this.itemRenderer = new ClassFactory(SpreadsheetItemRenderer2);
		
		this.addEventListener(DataGridEvent.ITEM_FOCUS_IN, onItemFocusIn);
		this.addEventListener(SpreadsheetEvent.CELL_REGISTER, onCellDataChange);
		this.addEventListener(SpreadsheetEvent.CELL_CLICK, onCellClick);
		this.addEventListener(SpreadsheetEvent.CELL_DOUBLE_CLICK, onCellDoubleClick);
	
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
		var dataSource : Array = new Array();
		var c : int = _columnCount; //4;
		var r : int = _rowCount; //100;
		var info : Row, cell : CellProperties;
		
		for (var i : int = 0; i < r; i++)
		{
			var rowObject : Object = new Object();
			info = new Row();
			info.uid = itemToUID(rowObject);
			
			for (var j : int = 0; j < c; j++)
			{
				var prop : String = String(Utils.alphabet[j]).toLowerCase();
				rowObject[prop] = ""; //i.toString();
				rowObject.rowIndex = i;
				rowObject.rowHeight = 20;
				
				cell = new CellProperties(i, j);
				info.cells[j] = cell;
				
				cells.push(cell);
				
				var co : ControlObject = new ControlObject();
				co.id = prop + i;
				co.exp = "";
				co.ctrl = rowObject;
				co.valueProp = prop;
				co.row = i.toString();
				co.rowIndex = i;
				co.col = prop;
				co.colIndex = j;
				co.grid = this;
				
				_ctrlObjects[co.id] = co;
			}
			infos.push(info);
			dataSource.push(rowObject);
		}
		
		_gridDataProvider = new ArrayCollection(dataSource);
		
		var cols : Array = new Array();
		
		for (j = 0; j < c; j++)
		{
			var dc : DataGridColumn = new DataGridColumn(Utils.alphabet[j]);
			dc.headerText = Utils.alphabet[j];
			dc.dataField = String(Utils.alphabet[j]).toLowerCase();
			dc.itemEditor = new ClassFactory(SpreadsheetItemEditor);
			dc.editorDataField = "actualValue";
			
			if (this.columnWidth)
				dc.width = this.columnWidth;
			cols.push(dc);
		}
		
		this.columns = cols;
		
		super.dataProvider = _gridDataProvider;
	
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
	
	private function onCellClick (e : SpreadsheetEvent) : void
	{
	
	}
	
	private function onCellDoubleClick (e : SpreadsheetEvent) : void
	{
		//trace(SpreadsheetItemRendererBase(e.target).cellId + ", " + _nonEditableCells.indexOf(SpreadsheetItemRendererBase(e.target).cellId));
		
		if (disabledCells.indexOf(SpreadsheetItemRendererBase(e.target).cellId) == -1)
		{
			super.mouseDownHandler(e.data);
			super.mouseUpHandler(e.data);
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
	
	private function onCellDataChange (e : SpreadsheetEvent) : void
	{
		//var renderer:SpreadsheetItemRenderer1 = e.target as SpreadsheetItemRenderer1;
		//_renderers[renderer.cellId] = renderer;
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
	
	[Bindable]
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
		return _gridDataProvider;
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

/*	override protected function collectionChangeHandler (event : Event) : void
   {
   super.collectionChangeHandler(event);

   if (!event is CollectionEvent)
   return;

   var ce : CollectionEvent = CollectionEvent(event);

   var cell : CellProperties, info : ControlObject, ctrl : ControlObject, row : Row;

   switch (ce.kind)
   {
   case CollectionEventKind.UPDATE:
   info = ce.items[0].source;

   for each (ctrl in info.ctrlOperands)
   {
   row = new Row(20);

   cell = new CellProperties(ctrl.rowIndex, ctrl.colIndex);
   row.cells[ctrl.colIndex] = cell;

   cells.push(cell);

   ctrl.info = row;
   }
   break;
   }
   }
 */
}
}