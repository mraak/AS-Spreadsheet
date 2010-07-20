package com.flextras.spreadsheet
{
import com.flextras.calc.Calc;
import com.flextras.calc.ControlObject;
import com.flextras.calc.Utils;
import com.flextras.spreadsheet.components.GridList;
import com.flextras.spreadsheet.core.spreadsheet;
import com.flextras.spreadsheet.events.CellEvent;
import com.flextras.spreadsheet.events.CellEventData;
import com.flextras.spreadsheet.events.ColumnEvent;
import com.flextras.spreadsheet.events.RowEvent;
import com.flextras.spreadsheet.skins.SpreadsheetSkin;
import com.flextras.spreadsheet.utils.ResizeManager;
import com.flextras.spreadsheet.vos.Cell;
import com.flextras.spreadsheet.vos.CellHeight;
import com.flextras.spreadsheet.vos.CellStyles;
import com.flextras.spreadsheet.vos.CellWidth;
import com.flextras.spreadsheet.vos.Condition;

import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.geom.Point;
import flash.geom.Rectangle;

import mx.collections.ArrayCollection;
import mx.events.CollectionEvent;
import mx.events.CollectionEventKind;
import mx.events.FlexEvent;
import mx.managers.IFocusManagerComponent;
import mx.utils.ObjectUtil;

import spark.components.List;
import spark.components.supportClasses.SkinnableComponent;

use namespace spreadsheet;

//----------------------------------
//  Events
//----------------------------------

/**
 * @eventType com.flextras.spreadsheet.SpreadsheetEvent.EXPRESSIONS_CLEARED
 */
[Event(name="expressionsCleared", type="com.flextras.spreadsheet.SpreadsheetEvent")]

/**
 * @eventType com.flextras.spreadsheet.SpreadsheetEvent.ERROR
 */
[Event(name="error", type="com.flextras.spreadsheet.SpreadsheetEvent")]

/**
 * @eventType com.flextras.spreadsheet.SpreadsheetEvent.WARNING
 */
[Event(name="warning", type="com.flextras.spreadsheet.SpreadsheetEvent")]

[DefaultProperty("expressions")]
/**
 * The Flextras Spreadsheet component allows you to develop spreadsheet style applications.
 * It supports basic arithmetic and many Excel-style formulas, such as the sum function.
 * You can easily populate it with your own data and the component can conform to your data source.
 * External components such as TextInputs and Sliders can be referenced inside cells and formulas to create a flexible approach.
 *
 * The Spreadsheet supports Flex 4, so <a href="http://www.flextras.com/?event=RegistrationForm">register to download our free developer edition today</a>.
 *
 * <h2>Uses in the Real World</h2>
 * <ul>
 * <li>Create a financial spreadsheet for things such as cash flow forecasts.</li>
 * <li>Create Applications similar to the Google Docs Spreadsheet or Adobe Tables. </li>
 * </ul>
 *
 * @mxml
 *
 *  <p>The <code>&lt;flextras:Calendar&gt;</code> tag inherits all the tag attributes
 *  of its superclass, and adds the following tag attributes:</p>
 *
 *  <pre>
 *  &lt;flextras:Spreadsheet
 *    <b>Properties</b>
 *
 *
 *    <b>Events</b>
 * 		error="<i>No default</i>"
 * 		warning="<i>No default</i>"
 *  /&gt;
 *  </pre>
 *
 *
 * @includeExample SpreadsheetExample.txt
 * @includeExample SpreadsheetExample.mxml
 *
 * @see com.flextras.paintgrid.PaintGrid
 * @see com.flextras.spreadsheet.ISpreadsheet
 */
public class Spreadsheet extends SkinnableComponent implements ISpreadsheet, IFocusManagerComponent
{
	//--------------------------------------------------------------------------
	//
	//  Class mixins
	//
	//--------------------------------------------------------------------------
	
	spreadsheet static var instance : Spreadsheet;
	
	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------
	
	/**
	 * Constructor.
	 *
	 */
	public function Spreadsheet()
	{
		setStyle("skinClass", Class(SpreadsheetSkin));
		
		addEventListener(CellEvent.RESIZE, resizeCellHandler);
		
		addEventListener(ColumnEvent.INSERT, insertColumnHandler);
		addEventListener(ColumnEvent.REMOVE, removeColumnHandler);
		addEventListener(ColumnEvent.RESIZE, resizeColumnHandler);
		addEventListener(ColumnEvent.CLEAR, clearColumnHandler);
		
		addEventListener(RowEvent.INSERT, insertRowHandler);
		addEventListener(RowEvent.REMOVE, removeRowHandler);
		addEventListener(RowEvent.RESIZE, resizeRowHandler);
		addEventListener(RowEvent.CLEAR, clearRowHandler);
		
		_cells.addEventListener(CollectionEvent.COLLECTION_CHANGE, cells_collectionChangeHandler);
		
		instance = this;
		
		expressions = new ArrayCollection;
		
		globalCell.styles.normal.backgroundColor = 0xF6F6F6;
		globalCell.styles.hovered.backgroundColor = 0xCCCCCC;
		globalCell.styles.selected.backgroundColor = 0xCCFF33;
		globalCell.styles.disabled.backgroundColor = 0xFF3333;
	}
	
	//--------------------------------------------------------------------------
	//
	//  Overridden methods
	//
	//--------------------------------------------------------------------------
	
	/**
	 *
	 *
	 */
	override protected function commitProperties() : void
	{
		super.commitProperties();
		
		if (columnCountChanged)
		{
			for (var i : uint = oldColumnCount; i < _columnCount; ++i)
				addColumn(i, _columnCount, oldRowCount);
			
			for (i = oldColumnCount; i > _columnCount; --i)
				removeColumn(i - 1, _columnCount, oldRowCount);
			
			oldColumnCount = _columnCount;
			
			columnCountChanged = false;
		}
		
		if (rowCountChanged)
		{
			for (i = oldRowCount; i < _rowCount; ++i)
				addRow(i, oldColumnCount, _rowCount);
			
			for (i = oldRowCount; i > _rowCount; --i)
				removeRow(i - 1, oldColumnCount, _rowCount);
			
			oldRowCount = _rowCount;
			
			rowCountChanged = false;
		}
		
		notifyChildren = true;
		
		if (cellsChanged)
		{
			if (doSort)
			{
				_cells.refresh();
				
				doSort = false;
			}
			
			var column : Array;
			var row : Array;
			var rowSpan : Array;
			
			columns = [];
			rows = [];
			_indexedCells = {};
			_spans = [];
			_uniqueCells = [];
			_ctrlObjects = {};
			ids = [];
			_elementIndex = {};
			
			var x : Number, y : Number;
			i = 0;
			
			for each (var cell : Cell in _cells)
			{
				column = columns[cell.bounds.x] || [];
				row = rows[cell.bounds.y] || [];
				
				column.push(cell);
				row.push(cell);
				
				columns[cell.bounds.x] = column;
				rows[cell.bounds.y] = row;
				
				_indexedCells[cell.bounds.x + "|" + cell.bounds.y] = cell;
				
				_ctrlObjects[cell.controlObject.id] = cell.controlObject;
				
				if (!_spans[cell.bounds.y] || !_spans[cell.bounds.y][cell.bounds.x])
				{
					for (y = cell.bounds.y; y <= cell.bounds.bottom; ++y)
					{
						rowSpan = _spans[y] || [];
						
						for (x = cell.bounds.x; x <= cell.bounds.right; ++x)
						{
							rowSpan[x] = cell;
							
							_elementIndex[x + "|" + y] = i;
						}
						
						_spans[y] = rowSpan;
					}
					
					ids[i] = cell.columnIndex + "|" + cell.rowIndex;
					
					_uniqueCells.push(cell);
					++i;
				}
			}
			
			grid.dataProvider = new ArrayCollection(_uniqueCells);
			
			dispatchEvent(new Event("cellsChanged"));
			
			cellsChanged = false;
		}
		
		if (expressionsChanged)
		{
			var usedCells : Array = [];
			var e : SpreadsheetEvent;
			
			var c : uint;
			
			if(_expressions)
			while (c < _expressions.length)
			{
				var o : Object = _expressions.getItemAt(c);
				
				var _cell : String = String(o.cell).toLowerCase();
				o.cell = _cell;
				
				if (usedCells.indexOf(_cell) != -1)
					throw new Error("Cell ID already used in this collection: " + _cell + ". Use setItem() or itemUpdated() if you want to change existing cell's expression.");
				
				usedCells.push(_cell);
				
				var cellIndex : int = Utils.gridFieldToIndexes(_cell)[0];
				var rowIndex : int = Utils.gridFieldToIndexes(_cell)[1];
				
				if (rowIndex <= _rowCount && cellIndex <= _columnCount)
				{
					if (_cell.indexOf("!") == -1)
					{
						var co : Cell = getCellAt(cellIndex, rowIndex);
						co.expression = o.expression;
						
						if (o.expression == "")
							_expressions.removeItemAt(c);
						else
							c++;
					}
					else
					{
						e = new SpreadsheetEvent(SpreadsheetEvent.WARNING);
						e.message = _cell + " - cell ignored due to incorect id";
						this.dispatchEvent(e);
					}
				}
				else
				{
					e = new SpreadsheetEvent(SpreadsheetEvent.WARNING);
					e.message = _cell + " out of column or row bounds on Spreadsheet " + this.id;
					this.dispatchEvent(e);
				}
			}
			
			if(clearExpressionsDirty)
			{
				dispatchEvent(new SpreadsheetEvent(SpreadsheetEvent.EXPRESSIONS_CLEARED));
				
				clearExpressionsDirty = false;
			}
			
			expressionsChanged = false;
		}
	}
	
	override protected function createChildren() : void
	{
		super.createChildren();
		
		calc = new Calc;
	}
	
	/**
	 *
	 * @param partName
	 * @param instance
	 *
	 */
	override protected function partAdded(partName : String, instance : Object) : void
	{
		super.partAdded(partName, instance);
		
		if (columnHeader === instance)
		{
			columnHeader.dataProvider = columnWidthsCollection;
		}
		
		if (rowHeader === instance)
		{
			rowHeader.dataProvider = rowHeightsCollection;
		}
		
		if (grid === instance)
		{
			//grid.dataProvider = _cells;
			
			grid.scroller.verticalScrollBar.addEventListener(FlexEvent.VALUE_COMMIT, function(e : FlexEvent) : void
				{
					rowHeader.scroller.verticalScrollBar.value = e.currentTarget.value;
				});
			
			grid.scroller.horizontalScrollBar.addEventListener(FlexEvent.VALUE_COMMIT, function(e : FlexEvent) : void
				{
					columnHeader.scroller.horizontalScrollBar.value = e.currentTarget.value;
				});
		}
	}
	
	/**
	 *
	 * @param partName
	 * @param instance
	 *
	 */
	override protected function partRemoved(partName : String, instance : Object) : void
	{
		super.partRemoved(partName, instance);
		
		if (columnHeader === instance)
		{
			
		}
		
		if (rowHeader === instance)
		{
			
		}
		
		if (grid === instance)
		{
			
		}
	}
	
	//--------------------------------------------------------------------------
	//
	//  Skin Parts
	//
	//--------------------------------------------------------------------------
	
	[SkinPart(required="false")]
	/**
	 *
	 */
	public var columnHeader : List;
	
	[SkinPart(required="false")]
	/**
	 *
	 */
	public var rowHeader : List;
	
	[SkinPart(required="true")]
	[Bindable]
	/**
	 *
	 * @return
	 *
	 */
	public var grid : GridList;
	
	//--------------------------------------------------------------------------
	//
	//  Variables
	//
	//--------------------------------------------------------------------------
	
	/**
	 *
	 */
	protected var doSort : Boolean;
	
	/**
	 *
	 */
	protected var notifyChildren : Boolean;
	
	/**
	 *
	 */
	protected var shiftActive : Boolean;
	
	/**
	 *
	 */
	protected var expressionTreeCopy : Array;
	
	/**
	 *
	 */
	protected var columns : Array;
	
	/**
	 *
	 */
	protected var rows : Array;
	
	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------
	
	//----------------------------------
	//  calc
	//----------------------------------
	
	/**
	 * @private
	 */
	protected var _calc : Calc;
	
	[Bindable(event="calcChanged")]
	/**
	 * @return
	 *
	 * @see com.flextras.calc.Calc
	 */
	public function get calc() : Calc
	{
		return _calc;
	}
	
	/**
	 *
	 * @param value
	 */
	public function set calc(value : Calc) : void
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
	
	//----------------------------------
	//  cells
	//----------------------------------
	
	/**
	 *
	 */
	protected const _cells : ArrayCollection = new ArrayCollection;
	
	/**
	 *
	 */
	protected var cellsChanged : Boolean;
	
	[Bindable(event="cellsChanged")]
	/**
	 *
	 * @return
	 *
	 */
	public function get cells() : ArrayCollection
	{
		return _cells;
	}
	
	//----------------------------------
	//  columnCount
	//----------------------------------
	
	/**
	 *
	 */
	protected var oldColumnCount : uint;
	
	/**
	 *
	 */
	protected var _columnCount : uint = 10;
	
	/**
	 *
	 */
	protected var columnCountChanged : Boolean = true;
	
	[Bindable(event="columnCountChanged")]
	/**
	 *
	 * @return
	 *
	 */
	public function get columnCount() : uint
	{
		return _columnCount;
	}
	
	/**
	 *
	 * @param value
	 *
	 */
	public function set columnCount(value : uint) : void
	{
		if (value < 0 || _columnCount == value)
			return;
		
		_columnCount = value;
		columnCountChanged = true;
		
		dispatchEvent(new Event("columnCountChanged"));
		
		invalidateProperties();
	}
	
	//----------------------------------
	//  columnWidths
	//----------------------------------
	
	/**
	 *
	 */
	protected var _columnWidths : Array;
	
	/**
	 *
	 */
	protected const columnWidthsCollection : ArrayCollection = new ArrayCollection;
	
	[Bindable(event="columnWidthsChanged")]
	/**
	 *
	 * @return
	 *
	 */
	spreadsheet function get columnWidths() : Array
	{
		return _columnWidths;
	}
	
	/**
	 *
	 * @param value
	 *
	 */
	spreadsheet function set columnWidths(value : Array) : void
	{
		if (_columnWidths === value)
			return;
		
		_columnWidths = value;
		
		var array : Array = [];
		
		for (var i : uint, n : uint = value.length; i < n; ++i)
			array.push(Utils.alphabet[i]);
		
		columnWidthsCollection.source = array;
		
		dispatchEvent(new Event("columnWidthsChanged"));
	}
	
	//----------------------------------
	//  ctrlObjects
	//----------------------------------
	
	/**
	 * @private
	 */
	protected var _ctrlObjects : Object = {};
	
	/**
	 * @private
	 */
	public function get ctrlObjects() : Object
	{
		return _ctrlObjects;
	}
	
	//----------------------------------
	//  disabledCells
	//----------------------------------
	
	/**
	 *
	 */
	protected var _disabledCells : Vector.<Cell>;
	
	[Bindable(event="disabledCellsChanged")]
	/**
	 *
	 * @return
	 *
	 */
	public function get disabledCells() : Vector.<Cell>
	{
		return _disabledCells;
	}
	
	/**
	 *
	 * @param value
	 *
	 */
	public function set disabledCells(value : Vector.<Cell>) : void
	{
		if (_disabledCells === value)
			return;
		
		for each (var cell : Cell in _disabledCells)
			cell.enabled = true;
		
		_disabledCells = value;
		
		for each (cell in value)
			cell.enabled = false;
		
		dispatchEvent(new Event("disabledCellsChanged"));
	}
	
	//----------------------------------
	//  expressions
	//----------------------------------
	
	/**
	 * @private
	 */
	protected var _expressions : ArrayCollection;
	
	/**
	 * @private
	 */
	protected var expressionsChanged : Boolean;
	
	[Bindable(event="expressionsChanged")]
	/**
	 *
	 * @return
	 *
	 */
	public function get expressions() : ArrayCollection
	{
		return _expressions;
	}
	
	/**
	 *
	 * @param value
	 *
	 */
	public function set expressions(value : ArrayCollection) : void
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
	
	//----------------------------------
	//  expressionTree
	//----------------------------------
	
	/**
	 * @private
	 */
	protected const _expressionTree : Array = [];
	
	/**
	 * @private
	 */
	public function get expressionTree() : Array
	{
		return _expressionTree;
	}
	
	//----------------------------------
	//  globalStyles
	//----------------------------------
	
	public const globalCell : Cell = new Cell;
	
	[Bindable(event="globalStylesChanged")]
	/**
	 *
	 * @return
	 *
	 */
	public function get globalStyles() : CellStyles
	{
		return globalCell.styles;
	}
	
	/**
	 *
	 * @param value
	 *
	 */
	public function set globalStyles(value : CellStyles) : void
	{
		if (!value)
			return;
		
		globalCell.styles.assign(value);
		
		dispatchEvent(new Event("globalStylesChanged"));
	}
	
	/**
	 *
	 * @param value
	 *
	 */
	public function set globalStylesObject(value : Object) : void
	{
		if (!value)
			return;
		
		if (value is CellStyles)
			globalStyles = CellStyles(value);
		else
		{
			globalCell.styles.assignObject(value);
			
			dispatchEvent(new Event("globalStylesChanged"));
		}
	}
	
	//----------------------------------
	//  gridDataProvider
	//----------------------------------
	
	/**
	 * @private
	 */
	public function get gridDataProvider() : ArrayCollection
	{
		return _cells;
	}
	
	//----------------------------------
	//  indexedCells
	//----------------------------------
	
	/**
	 *
	 */
	protected var _indexedCells : Object;
	
	/**
	 *
	 * @return
	 *
	 */
	spreadsheet function get indexedCells() : Object
	{
		return _indexedCells;
	}
	
	//----------------------------------
	//  preferredColumnWidths
	//----------------------------------
	
	/**
	 *
	 */
	protected var _preferredColumnWidths : Array = [];
	
	[Bindable(event="preferredColumnWidthsChanged")]
	/**
	 *
	 * @return
	 *
	 */
	public function get preferredColumnWidths() : Array
	{
		return _preferredColumnWidths;
	}
	
	//----------------------------------
	//  preferredRowHeights
	//----------------------------------
	
	/**
	 *
	 */
	protected var _preferredRowHeights : Array = [];
	
	[Bindable(event="preferredRowHeightsChanged")]
	/**
	 *
	 * @return
	 *
	 */
	public function get preferredRowHeights() : Array
	{
		return _preferredRowHeights;
	}
	
	//----------------------------------
	//  rowCount
	//----------------------------------
	
	/**
	 *
	 */
	protected var oldRowCount : uint;
	
	/**
	 *
	 */
	protected var _rowCount : uint = 10;
	
	/**
	 *
	 */
	protected var rowCountChanged : Boolean = true;
	
	[Bindable(event="rowCountChanged")]
	/**
	 *
	 * @return
	 *
	 */
	public function get rowCount() : uint
	{
		return _rowCount;
	}
	
	/**
	 *
	 * @param value
	 *
	 */
	public function set rowCount(value : uint) : void
	{
		if (value < 0 || _rowCount == value)
			return;
		
		_rowCount = value;
		rowCountChanged = true;
		
		dispatchEvent(new Event("rowCountChanged"));
		
		invalidateProperties();
	}
	
	//----------------------------------
	//  rowHeights
	//----------------------------------
	
	/**
	 *
	 */
	protected var _rowHeights : Array;
	
	/**
	 *
	 */
	protected const rowHeightsCollection : ArrayCollection = new ArrayCollection;
	
	[Bindable(event="rowHeightsChanged")]
	/**
	 *
	 * @return
	 *
	 */
	spreadsheet function get rowHeights() : Array
	{
		return _rowHeights;
	}
	
	/**
	 *
	 * @param value
	 *
	 */
	spreadsheet function set rowHeights(value : Array) : void
	{
		if (_rowHeights === value)
			return;
		
		_rowHeights = value;
		
		var array : Array = [];
		
		for (var i : uint, n : uint = value.length; i < n; ++i)
			array.push(i);
		
		rowHeightsCollection.source = array;
		
		dispatchEvent(new Event("rowHeightsChanged"));
	}
	
	//----------------------------------
	//  spans
	//----------------------------------
	
	/**
	 *
	 */
	protected var _spans : Array;
	
	/**
	 *
	 * @return
	 *
	 */
	spreadsheet function get spans() : Array
	{
		return _spans;
	}
	
	//----------------------------------
	//  uniqueCells
	//----------------------------------
	
	/**
	 *
	 */
	protected var _uniqueCells : Array;
	
	/**
	 *
	 * @return
	 *
	 */
	spreadsheet function get uniqueCells() : Array
	{
		return _uniqueCells;
	}
	
	//----------------------------------
	//  wordWrap
	//----------------------------------
	
	/**
	 *
	 */
	protected var _wordWrap : Boolean;
	
	[Bindable(event="wordWrapChanged")]
	/**
	 *
	 * @return
	 *
	 */
	public function get wordWrap() : Boolean
	{
		return _wordWrap;
	}
	
	/**
	 *
	 * @param value
	 *
	 */
	public function set wordWrap(value : Boolean) : void
	{
		if (_wordWrap == value)
			return;
		
		_wordWrap = value;
		
		dispatchEvent(new Event("wordWrapChanged"));
	}
	
	//--------------------------------------------------------------------------
	//
	//  Methods
	//
	//--------------------------------------------------------------------------
	
	//----------------------------------
	//  addCell
	//----------------------------------
	
	/**
	 *
	 * @param columnIndex
	 * @param rowIndex
	 *
	 */
	protected function addCell(columnIndex : uint, rowIndex : uint) : void
	{
		var cell : Cell = new Cell(this, new Rectangle(columnIndex, rowIndex));
		cell.globalStyles = globalCell.styles;
		
		_cells.addItem(cell);
	}
	
	//----------------------------------
	//  addColumn
	//----------------------------------
	
	/**
	 *
	 * @param index
	 * @param columnIndex
	 * @param rowIndex
	 *
	 */
	protected function addColumn(index : uint, columnCount : uint, rowCount : uint) : void
	{
		if (notifyChildren && index < columnCount - 1)
			dispatchEvent(new ColumnEvent(ColumnEvent.INSERTED, index));
		
		for (var i : uint; i < rowCount; ++i)
			addCell(index, i);
	}
	
	//----------------------------------
	//  addRow
	//----------------------------------
	
	/**
	 *
	 * @param index
	 * @param columnIndex
	 * @param rowIndex
	 *
	 */
	protected function addRow(index : uint, columnCount : uint, rowCount : uint) : void
	{
		if (notifyChildren && index < rowCount - 1)
			dispatchEvent(new RowEvent(RowEvent.INSERTED, index));
		
		for (var i : uint; i < columnCount; ++i)
			addCell(i, index);
	}
	
	//----------------------------------
	//  assignExpression
	//----------------------------------
	
	/**
	 *
	 * @param cellId Valid format is "[column index in alphabetical form][row index in numerical form]".
	 * "a1" for example points to column 0 and row 1.
	 *
	 * @param expression Actual expression of which result will be seen in the target cell.
	 * To remove existing expression type null | ""
	 *
	 */
	public function assignExpression(cellId : String, expression : String) : void
	{
		if (!cellId)
			return;
		
		cellId = cellId.toLowerCase();
		
		if (expression != null)
			expression = expression.toLowerCase();
		/*else
			expression = "";*/
		
		var o : Object = getCell(cellId);
		
		var cellObj : Object = {cell: cellId, expression: expression, value: ""};
		
		if (o)
			_expressions.setItemAt(cellObj, _expressions.getItemIndex(o));
		else
			_expressions.addItem(cellObj);
	}
	
	//----------------------------------
	//  assignExpressions
	//----------------------------------
	
	/**
	 * This method will add multiple expressions to the specified locations.
	 * Each object in the expressions array should include a cell property to specify the location and an expression property.
	 *
	 * For more information on the cell and expression, see the expressions property.
	 *
	 * @param expressions An array of objects
	 *
	 * @see #assignExpression
	 * @see #expressions
	 */
	public function assignExpressions(expressions : Array) : void
	{
		for each (var o : Object in expressions)
			this.assignExpression(o.cell, o.expression);
	}
	
	//----------------------------------
	//  expression cell
	//----------------------------------
	
	/**
	 * @private
	 */
	public function getCell(cellId : String) : Object
	{
		if (!cellId)
			return null;
		
		cellId = cellId.toLowerCase();
		
		for each (var o : Object in _expressions)
			if (o.cell == cellId)
				return o;
		
		return null;
	}
	
	//----------------------------------
	//  cell
	//----------------------------------
	
	/**
	 *
	 * @param location
	 * @return
	 *
	 */
	// TODO: rename!
	public function _getCell(location : Point) : Cell
	{
		if (!location)
			return null;
		
		return getCellAt(location.x, location.y);
	}
	
	/**
	 *
	 * @param columnIndex
	 * @param rowIndex
	 * @return
	 *
	 */
	public function getCellAt(columnIndex : uint, rowIndex : uint) : Cell
	{
		if (isColumnIndexInvalid(columnIndex) || isRowIndexInvalid(rowIndex))
			return null;
		
		return _indexedCells[columnIndex + "|" + rowIndex];
	}
	
	//----------------------------------
	//  cellCondition
	//----------------------------------
	
	/**
	 *
	 * @param location
	 * @return
	 *
	 */
	public function getCellCondition(location : Point) : Condition
	{
		if (!location)
			return null;
		
		return getCellConditionAt(location.x, location.y);
	}
	
	/**
	 *
	 * @param columnIndex
	 * @param rowIndex
	 * @return
	 *
	 */
	public function getCellConditionAt(columnIndex : uint, rowIndex : uint) : Condition
	{
		if (isColumnIndexInvalid(columnIndex) || isRowIndexInvalid(rowIndex))
			return null;
		
		return getCellAt(columnIndex, rowIndex).condition;
	}
	
	/**
	 *
	 * @param location
	 * @param condition
	 *
	 */
	public function setCellCondition(location : Point, condition : Condition) : void
	{
		if (!location || !condition)
			return;
		
		setCellConditionAt(location.x, location.y, condition);
	}
	
	/**
	 *
	 * @param columnIndex
	 * @param rowIndex
	 * @param condition
	 *
	 */
	public function setCellConditionAt(columnIndex : uint, rowIndex : uint, condition : Condition) : void
	{
		if (isColumnIndexInvalid(columnIndex) || isRowIndexInvalid(rowIndex) || !condition)
			return;
		
		getCellAt(columnIndex, rowIndex).condition = condition;
	}
	
	/**
	 *
	 * @param location
	 * @param condition
	 *
	 */
	public function setCellConditionObject(location : Point, condition : Object) : void
	{
		if (!location || !condition)
			return;
		
		setCellConditionObjectAt(location.x, location.y, condition);
	}
	
	/**
	 *
	 * @param columnIndex
	 * @param rowIndex
	 * @param condition
	 *
	 */
	public function setCellConditionObjectAt(columnIndex : uint, rowIndex : uint, condition : Object) : void
	{
		if (isColumnIndexInvalid(columnIndex) || isRowIndexInvalid(rowIndex) || !condition)
			return;
		
		getCellAt(columnIndex, rowIndex).conditionObject = condition;
	}
	
	//----------------------------------
	//  cellStyles
	//----------------------------------
	
	/**
	 *
	 * @param location
	 * @return
	 *
	 */
	public function getCellStyles(location : Point) : CellStyles
	{
		if (!location)
			return null;
		
		return getCellStylesAt(location.x, location.y);
	}
	
	/**
	 *
	 * @param columnIndex
	 * @param rowIndex
	 * @return
	 *
	 */
	public function getCellStylesAt(columnIndex : uint, rowIndex : uint) : CellStyles
	{
		if (isColumnIndexInvalid(columnIndex) || isRowIndexInvalid(rowIndex))
			return null;
		
		return getCellAt(columnIndex, rowIndex).styles;
	}
	
	/**
	 *
	 * @param location
	 * @param styles
	 *
	 */
	public function setCellStyles(location : Point, styles : CellStyles) : void
	{
		if (!location || !styles)
			return;
		
		setCellStylesAt(location.x, location.y, styles);
	}
	
	/**
	 *
	 * @param columnIndex
	 * @param rowIndex
	 * @param styles
	 *
	 */
	public function setCellStylesAt(columnIndex : uint, rowIndex : uint, styles : CellStyles) : void
	{
		if (isColumnIndexInvalid(columnIndex) || isRowIndexInvalid(rowIndex) || !styles)
			return;
		
		getCellAt(columnIndex, rowIndex).styles = styles;
	}
	
	/**
	 *
	 * @param location
	 * @param styles
	 *
	 */
	public function setCellStylesObject(location : Point, styles : Object) : void
	{
		if (!location || !styles)
			return;
		
		setCellStylesObjectAt(location.x, location.y, styles);
	}
	
	/**
	 *
	 * @param columnIndex
	 * @param rowIndex
	 * @param styles
	 *
	 */
	public function setCellStylesObjectAt(columnIndex : uint, rowIndex : uint, styles : Object) : void
	{
		if (isColumnIndexInvalid(columnIndex) || isRowIndexInvalid(rowIndex) || !styles)
			return;
		
		getCellAt(columnIndex, rowIndex).stylesObject = styles;
	}
	
	//----------------------------------
	//  clearCell
	//----------------------------------
	
	/**
	 *
	 * @param location
	 *
	 */
	public function clearCell(location : Point) : void
	{
		if (!location)
			return;
		
		clearCellAt(location.x, location.y);
	}
	
	/**
	 *
	 * @param columnIndex
	 * @param rowIndex
	 *
	 */
	public function clearCellAt(columnIndex : uint, rowIndex : uint) : void
	{
		if (isColumnIndexInvalid(columnIndex) || isRowIndexInvalid(rowIndex))
			return;
		
		var cell : Cell = getCellAt(columnIndex, rowIndex);
		
		if (!cell)
			return;
		
		cell.clear();
	}
	
	//----------------------------------
	//  clearColumn
	//----------------------------------
	
	/**
	 *
	 * @param index
	 *
	 */
	public function clearColumnAt(index : uint) : void
	{
		if (isColumnIndexInvalid(index))
			return;
		
		dispatchEvent(new ColumnEvent(ColumnEvent.CLEAR, index));
	}
	
	//----------------------------------
	//  clearExpressions
	//----------------------------------
	
	protected var clearExpressionsDirty:Boolean;
	
	/**
	 * @private
	 */
	public function clearExpressions() : void
	{
		clearExpressionsDirty = true;
		
		/*for each (var co : ControlObject in _ctrlObjects)
		 co.oldID = null;*/
		
		expressionTreeCopy = new Array();
		//expressionTreeCopy = ObjectUtil.copy(_expressionTree) as Array;
		
		for each(var co : ControlObject in expressionTree)
		{
			var nco : ControlObject = new ControlObject();
			nco.id = co.id;
			nco.exp = co.exp;
			nco.colIndex = co.colIndex;
			nco.rowIndex = co.rowIndex;
			nco.valueProp = co.valueProp;
			nco.ctrl = co.ctrl;
			nco.oldID = co.ctrl[co.valueProp];
			nco.grid = co.grid;
			nco.ctrlOperands = new Array();
			
			for each(var oco : ControlObject in co.ctrlOperands)
			{
				nco.ctrlOperands.push(oco);
			}
			
			expressionTreeCopy.push(nco);
		}
		
		
		for each (co in expressionTree)
			this.assignExpression(co.id, "");
		
		//callLater(_expressions.removeAll);
	}
	
	//----------------------------------
	//  clearRow
	//----------------------------------
	
	/**
	 *
	 * @param index
	 *
	 */
	public function clearRowAt(index : uint) : void
	{
		if (isRowIndexInvalid(index))
			return;
		
		dispatchEvent(new RowEvent(RowEvent.CLEAR, index));
	}
	
	//----------------------------------
	//  columnWidth
	//----------------------------------
	
	[Bindable(event="columnWidthsChanged")]
	[Bindable(event="preferredColumnWidthsChanged")]
	/**
	 *
	 * @param index
	 * @return
	 *
	 */
	public function getColumnWidthAt(index : uint) : Number
	{
		if (isColumnIndexInvalid(index))
			return NaN;
		
		var value : Number = _preferredColumnWidths[index];
		
		if (isNaN(value))
		{
			if (_columnWidths)
			{
				var columnWidth : CellWidth = _columnWidths[index];
				
				if (columnWidth)
					value = columnWidth.value;
				else
					value = new CellWidth().value;
			}
			else
				value = new CellWidth().value;
		}
		
		return value;
	}
	
	/**
	 *
	 * @param index
	 * @param value
	 *
	 */
	public function setColumnWidthAt(index : uint, value : Number) : void
	{
		if (isColumnIndexInvalid(index))
			return;
		
		_preferredColumnWidths[index] = value;
		
		grid.dataGroup.invalidateDisplayList();
		
		dispatchEvent(new Event("preferredColumnWidthsChanged"));
	}
	
	/**
	 *
	 */
	protected var _elementIndex : Object;
	
	/**
	 *
	 * @param columnIndex
	 * @param rowIndex
	 * @return
	 *
	 */
	spreadsheet function getElementIndex(columnIndex : uint, rowIndex : int) : int
	{
		return _elementIndex[columnIndex + "|" + rowIndex] || -1;
	}
	
	/**
	 *
	 */
	protected var ids : Array;
	
	/**
	 *
	 * @param index
	 * @return
	 *
	 */
	spreadsheet function getIdByIndex(index : uint) : String
	{
		return ids[index];
	}
	
	/**
	 *
	 * @param value
	 * @return
	 *
	 */
	protected function isColumnIndexInvalid(value : uint) : Boolean
	{
		return value < 0 || value >= _columnCount;
	}
	
	/**
	 *
	 * @param value
	 * @return
	 *
	 */
	protected function isRowIndexInvalid(value : uint) : Boolean
	{
		return value < 0 || value >= _rowCount;
	}
	
	//----------------------------------
	//  insertColumn
	//----------------------------------
	
	/**
	 *
	 * @param index
	 *
	 */
	public function insertColumnAt(index : uint) : void
	{
		if (isColumnIndexInvalid(index))
			return;
		
		dispatchEvent(new ColumnEvent(ColumnEvent.INSERT, index));
	}
	
	//----------------------------------
	//  insertRow
	//----------------------------------
	
	/**
	 *
	 * @param index
	 *
	 */
	public function insertRowAt(index : uint) : void
	{
		if (isRowIndexInvalid(index))
			return;
		
		dispatchEvent(new RowEvent(RowEvent.INSERT, index));
	}
	
	//----------------------------------
	//  rangeCondition
	//----------------------------------
	
	/**
	 *
	 * @param location
	 * @return
	 *
	 */
	public function getRangeConditions(location : Rectangle) : Vector.<Condition>
	{
		if (!location)
			return null;
		
		return getRangeConditionsAt(location.x, location.y, location.width, location.height);
	}
	
	/**
	 *
	 * @param columnIndex
	 * @param rowIndex
	 * @param columnSpan
	 * @param rowSpan
	 * @return
	 *
	 */
	public function getRangeConditionsAt(columnIndex : uint, rowIndex : uint, columnSpan : uint, rowSpan : uint) : Vector.<Condition>
	{
		if (isColumnIndexInvalid(columnIndex)
			|| isRowIndexInvalid(rowIndex)
			|| columnSpan < 0
			|| rowSpan < 0)
			return null;
		
		var result : Vector.<Condition> = new Vector.<Condition>;
		var c : uint = columnIndex, cs : uint = c + columnSpan;
		var r : uint = rowIndex, rs : uint = r + rowSpan;
		
		for (; c <= cs; ++c)
			for (r = rowIndex; r <= rs; ++r)
				result.push(getCellConditionAt(c, r));
		
		return result;
	}
	
	/**
	 *
	 * @param location
	 * @param styles
	 *
	 */
	public function setRangeCondition(location : Rectangle, condition : Condition) : void
	{
		if (!location || !condition)
			return;
		
		setRangeConditionAt(location.x, location.y, location.width, location.height, condition);
	}
	
	/**
	 *
	 * @param columnIndex
	 * @param rowIndex
	 * @param columnSpan
	 * @param rowSpan
	 * @param condition
	 *
	 */
	public function setRangeConditionAt(columnIndex : uint, rowIndex : uint, columnSpan : uint, rowSpan : uint, condition : Condition) : void
	{
		if (!condition)
			return;
		
		var result : Vector.<Condition> = getRangeConditionsAt(columnIndex, rowIndex, columnSpan, rowSpan);
		
		if (!result)
			return;
		
		for (var i : uint, n : uint = result.length; i < n; ++i)
			result[i].assign(condition);
	}
	
	/**
	 *
	 * @param location
	 * @param condition
	 *
	 */
	public function setRangeConditionObject(location : Rectangle, condition : Object) : void
	{
		if (!location || !condition)
			return;
		
		setRangeConditionObjectAt(location.x, location.y, location.width, location.height, condition);
	}
	
	/**
	 *
	 * @param columnIndex
	 * @param rowIndex
	 * @param columnSpan
	 * @param rowSpan
	 * @param condition
	 *
	 */
	public function setRangeConditionObjectAt(columnIndex : uint, rowIndex : uint, columnSpan : int, rowSpan : int, condition : Object) : void
	{
		if (!condition)
			return;
		
		var result : Vector.<Condition> = getRangeConditionsAt(columnIndex, rowIndex, columnSpan, rowSpan);
		
		if (!result)
			return;
		
		for (var i : uint, n : uint = result.length; i < n; ++i)
			result[i].assignObject(condition);
	}
	
	//----------------------------------
	//  rangeStyles
	//----------------------------------
	
	/**
	 *
	 * @param location
	 * @return
	 *
	 */
	public function getRangeStyles(location : Rectangle) : Vector.<CellStyles>
	{
		if (!location)
			return null;
		
		return getRangeStylesAt(location.x, location.y, location.width, location.height);
	}
	
	/**
	 *
	 * @param columnIndex
	 * @param rowIndex
	 * @param columnSpan
	 * @param rowSpan
	 * @return
	 *
	 */
	public function getRangeStylesAt(columnIndex : uint, rowIndex : uint, columnSpan : uint, rowSpan : uint) : Vector.<CellStyles>
	{
		if (isColumnIndexInvalid(columnIndex)
			|| isRowIndexInvalid(rowIndex)
			|| columnSpan < 0
			|| rowSpan < 0)
			return null;
		
		var result : Vector.<CellStyles> = new Vector.<CellStyles>;
		var c : uint = columnIndex, cs : uint = c + columnSpan;
		var r : uint = rowIndex, rs : uint = r + rowSpan;
		
		for (; c <= cs; ++c)
			for (r = rowIndex; r <= rs; ++r)
				result.push(getCellStylesAt(c, r));
		
		return result;
	}
	
	/**
	 *
	 * @param location
	 * @param styles
	 *
	 */
	public function setRangeStyles(location : Rectangle, styles : CellStyles) : void
	{
		if (!location || !styles)
			return;
		
		setRangeStylesAt(location.x, location.y, location.width, location.height, styles);
	}
	
	/**
	 *
	 * @param columnIndex
	 * @param rowIndex
	 * @param columnSpan
	 * @param rowSpan
	 * @param styles
	 *
	 */
	public function setRangeStylesAt(columnIndex : uint, rowIndex : uint, columnSpan : uint, rowSpan : uint, styles : CellStyles) : void
	{
		if (!styles)
			return;
		
		var result : Vector.<CellStyles> = getRangeStylesAt(columnIndex, rowIndex, columnSpan, rowSpan);
		
		if (!result)
			return;
		
		for (var i : uint, n : uint = result.length; i < n; ++i)
			result[i].assign(styles);
	}
	
	/**
	 *
	 * @param location
	 * @param styles
	 *
	 */
	public function setRangeStylesObject(location : Rectangle, styles : Object) : void
	{
		if (!location || !styles)
			return;
		
		setRangeStylesObjectAt(location.x, location.y, location.width, location.height, styles);
	}
	
	/**
	 *
	 * @param columnIndex
	 * @param rowIndex
	 * @param columnSpan
	 * @param rowSpan
	 * @param styles
	 *
	 */
	public function setRangeStylesObjectAt(columnIndex : uint, rowIndex : uint, columnSpan : int, rowSpan : int, styles : Object) : void
	{
		if (!styles)
			return;
		
		var result : Vector.<CellStyles> = getRangeStylesAt(columnIndex, rowIndex, columnSpan, rowSpan);
		
		if (!result)
			return;
		
		for (var i : uint, n : uint = result.length; i < n; ++i)
			result[i].assignObject(styles);
	}
	
	/**
	 *
	 *
	 */
	protected function refresh() : void
	{
		cellsChanged = true;
		
		invalidateProperties();
	}
	
	//----------------------------------
	//  removeCell
	//----------------------------------
	
	/**
	 *
	 * @param columnIndex
	 * @param rowIndex
	 *
	 */
	protected function removeCell(columnIndex : uint, rowIndex : uint) : void
	{
		Cell(_cells.removeItemAt(_cells.getItemIndex(getCellAt(columnIndex, rowIndex)))).release();
	}
	
	//----------------------------------
	//  removeColumn
	//----------------------------------
	
	/**
	 *
	 * @param index
	 * @param columnIndex
	 * @param rowIndex
	 *
	 */
	protected function removeColumn(index : uint, columnCount : uint, rowCount : uint) : void
	{
		if (notifyChildren)
			dispatchEvent(new ColumnEvent(ColumnEvent.REMOVED, index));
		
		for (var i : uint; i < rowCount; ++i)
			removeCell(index, i);
	}
	
	/**
	 *
	 * @param index
	 *
	 */
	public function removeColumnAt(index : uint) : void
	{
		if (isColumnIndexInvalid(index))
			return;
		
		dispatchEvent(new ColumnEvent(ColumnEvent.REMOVE, index));
	}
	
	//----------------------------------
	//  removeRow
	//----------------------------------
	
	/**
	 *
	 * @param index
	 * @param columnIndex
	 * @param rowIndex
	 *
	 */
	protected function removeRow(index : uint, columnCount : uint, rowCount : uint) : void
	{
		if (notifyChildren)
			dispatchEvent(new RowEvent(RowEvent.REMOVED, index));
		
		for (var i : uint; i < columnCount; ++i)
			removeCell(i, index);
	}
	
	/**
	 *
	 * @param index
	 *
	 */
	public function removeRowAt(index : uint) : void
	{
		if (isRowIndexInvalid(index))
			return;
		
		dispatchEvent(new RowEvent(RowEvent.REMOVE, index));
	}
	
	//----------------------------------
	//  resizeCell
	//----------------------------------
	
	/**
	 *
	 * @param bounds
	 *
	 */
	public function resizeCell(bounds : Rectangle) : void
	{
		if (!bounds)
			return;
		
		resizeCellAt(bounds.x, bounds.y, bounds.width, bounds.height);
	}
	
	/**
	 *
	 * @param columnIndex
	 * @param rowIndex
	 * @param columnSpan
	 * @param rowSpan
	 *
	 */
	public function resizeCellAt(columnIndex : uint, rowIndex : uint, columnSpan : uint = 0, rowSpan : uint = 0) : void
	{
		if (isColumnIndexInvalid(columnIndex) || isRowIndexInvalid(rowIndex))
			return;
		
		dispatchEvent(new CellEvent(CellEvent.RESIZE, new CellEventData(new Rectangle(columnIndex, rowIndex, columnSpan, rowSpan))));
	}
	
	//----------------------------------
	//  rowHeight
	//----------------------------------
	
	[Bindable(event="rowHeightsChanged")]
	[Bindable(event="preferredRowHeightsChanged")]
	/**
	 *
	 * @param index
	 * @return
	 *
	 */
	public function getRowHeightAt(index : uint) : Number
	{
		if (isRowIndexInvalid(index))
			return NaN;
		
		var value : Number = _preferredRowHeights[index];
		
		if (isNaN(value))
		{
			if (_rowHeights)
			{
				var rowHeight : CellHeight = _rowHeights[index];
				
				if (rowHeight)
					value = rowHeight.value;
				else
					value = new CellHeight().value;
			}
			else
				value = new CellHeight().value;
		}
		
		return value;
	}
	
	/**
	 *
	 * @param index
	 * @param value
	 *
	 */
	public function setRowHeightAt(index : uint, value : Number) : void
	{
		if (isRowIndexInvalid(index))
			return;
		
		_preferredRowHeights[index] = value;
		
		grid.dataGroup.invalidateDisplayList();
		
		dispatchEvent(new Event("preferredRowHeightsChanged"));
	}
	
	/**
	 * @private
	 */
	public function updateExpressions() : void
	{
		expressionsChanged = true;
		
		invalidateProperties();
	}
	
	protected function updateExpressionsUponRowOrColumnChange(indexProp : String, index : int, dx : int, dy : int, excludeRule : Array = null) : void
	{
		clearExpressions();
		//updateExpressionsUponRowOrColumnChange2(indexProp, index, dx, dy, excludeRule);
		callLater(updateExpressionsUponRowOrColumnChange2, [indexProp, index, dx, dy, excludeRule]);
	}
	
	public function updateExpressionsUponRowOrColumnChange2(indexProp : String, index : int, dx : int, dy : int, excludeRule : Array = null) : void
	{
		var newCopy : Array = [];
		var co : ControlObject;
		
		for each (co in expressionTreeCopy)
		{
			var cell : Object = new Object();
			cell.value = "";
			
			if (co[indexProp] >= index)
				cell.cell = Utils.moveFieldId(co.id, dx, dy);
			else
				cell.cell = co.id;
			
			//cell.expression = co.exp ? Utils.moveExpression3(co, dx, dy, null, excludeRule) : co.ctrl[co.valueProp];
			cell.expression = co.exp ? Utils.moveExpression(co, dx, dy, null, excludeRule) : co.oldID;
			
			newCopy.push(cell);
		}
		
		assignExpressions(newCopy);
	}
	
	//--------------------------------------------------------------------------
	//
	//  Event handlers
	//
	//--------------------------------------------------------------------------
	
	/**
	 *
	 * @param e
	 *
	 */
	protected function cells_collectionChangeHandler(e : CollectionEvent) : void
	{
		switch (e.kind)
		{
			case CollectionEventKind.ADD:
				refresh();
				break;
			
			case CollectionEventKind.MOVE:
				break;
			
			case CollectionEventKind.REFRESH:
				break;
			
			case CollectionEventKind.REMOVE:
				refresh();
				break;
			
			case CollectionEventKind.REPLACE:
				break;
			
			case CollectionEventKind.RESET:
				break;
			
			case CollectionEventKind.UPDATE:
				refresh();
				break;
		}
	}
	
	/**
	 *
	 * @param e
	 *
	 */
	protected function clearColumnHandler(e : ColumnEvent) : void
	{
		if (!e)
			return;
		
		var index : uint = e.index;
		
		if (isColumnIndexInvalid(index))
			return;
		
		var row : Array = columns[index];
		
		for each (var cell : Cell in row)
			cell.clear();
	}
	
	/**
	 *
	 * @param e
	 *
	 */
	protected function clearRowHandler(e : RowEvent) : void
	{
		if (!e)
			return;
		
		var index : uint = e.index;
		
		if (isRowIndexInvalid(index))
			return;
		
		var column : Array = rows[index];
		
		for each (var cell : Cell in column)
			cell.clear();
	}
	
	/**
	 *
	 * @param e
	 *
	 */
	protected function expressionsChangeHandler(e : CollectionEvent) : void
	{
		updateExpressions();
		
		dispatchEvent(new Event("expressionsChanged"));
	}
	
	/**
	 *
	 * @param e
	 *
	 */
	protected function insertColumnHandler(e : ColumnEvent) : void
	{
		if (!e)
			return;
		
		var index : uint = e.index;
		
		if (isColumnIndexInvalid(index))
			return;
		
		addColumn(index, _columnCount, _rowCount);
		
		updateExpressionsUponRowOrColumnChange("colIndex", index, 1, 0, [index, null, null, null]);
		
		var array : Array = [], i : Number;
		
		for (var k : String in _preferredColumnWidths)
		{
			i = parseInt(k);
			
			if (!isNaN(i) && index <= i)
				array[i + 1] = _preferredColumnWidths[i];
		}
		
		_preferredColumnWidths = array;
		
		oldColumnCount = ++columnCount;
	}
	
	/**
	 *
	 * @param e
	 *
	 */
	protected function insertRowHandler(e : RowEvent) : void
	{
		if (!e)
			return;
		
		var index : uint = e.index;
		
		if (isRowIndexInvalid(index))
			return;
		
		addRow(index, _columnCount, _rowCount);
		
		updateExpressionsUponRowOrColumnChange("rowIndex", index, 0, 1, [null, null, index, null]);
		
		var array : Array = [], i : Number;
		
		for (var k : String in _preferredRowHeights)
		{
			i = parseInt(k);
			
			if (!isNaN(i) && index <= i)
				array[i + 1] = _preferredRowHeights[i];
		}
		
		_preferredRowHeights = array;
		
		oldRowCount = ++rowCount;
	}
	
	override protected function keyDownHandler(event : KeyboardEvent) : void
	{
		if (event.ctrlKey && event.shiftKey && String.fromCharCode(event.charCode) == "r")
		{
			if (!shiftActive)
			{
				shiftActive = true;
				
				ResizeManager.dispatcher.dispatchEvent(new Event(ResizeManager.SHOW_HANDLERS));
			}
			else
			{
				shiftActive = false;
				
				ResizeManager.dispatcher.dispatchEvent(new Event(ResizeManager.HIDE_HANDLERS));
			}
		}
	}
	
	/**
	 * @private
	 */
	protected function onCalcError(event : SpreadsheetEvent) : void
	{
		this.dispatchEvent(event);
	}
	
	/**
	 * @private
	 */
	protected function onCalcWarning(event : SpreadsheetEvent) : void
	{
		this.dispatchEvent(event);
	}
	
	/**
	 *
	 * @param e
	 *
	 */
	protected function removeColumnHandler(e : ColumnEvent) : void
	{
		if (!e)
			return;
		
		var index : uint = e.index;
		
		if (isColumnIndexInvalid(index))
			return;
		
		removeColumn(index, _columnCount, _rowCount);
		
		updateExpressionsUponRowOrColumnChange("colIndex", index, -1, 0, [index, null, null, null]);
		
		var array : Array = [], i : Number;
		
		for (var k : String in _preferredColumnWidths)
		{
			i = parseInt(k);
			
			if (!isNaN(i) && index < i)
				array[i - 1] = _preferredColumnWidths[i];
		}
		
		_preferredColumnWidths = array;
		
		oldColumnCount = --columnCount;
	}
	
	/**
	 *
	 * @param e
	 *
	 */
	protected function removeRowHandler(e : RowEvent) : void
	{
		if (!e)
			return;
		
		var index : uint = e.index;
		
		if (isRowIndexInvalid(index))
			return;
		
		removeRow(index, _columnCount, _rowCount);
		
		updateExpressionsUponRowOrColumnChange("rowIndex", index, 0, -1, [null, null, index, null]);
		
		var array : Array = [], i : Number;
		
		for (var k : String in _preferredRowHeights)
		{
			i = parseInt(k);
			
			if (!isNaN(i) && index < i)
				array[i - 1] = _preferredRowHeights[i];
		}
		
		_preferredRowHeights = array;
		
		oldRowCount = --rowCount;
	}
	
	/**
	 *
	 * @param e
	 *
	 */
	protected function resizeCellHandler(e : CellEvent) : void
	{
		if (!e || !e.data)
			return;
		
		var amount : Rectangle = e.data.resizeAmount;
		
		if (isColumnIndexInvalid(amount.x) || isRowIndexInvalid(amount.y))
			return;
		
		var cell : Cell = getCellAt(amount.x, amount.y);
		
		notifyChildren = false;
		
		if (cell.bounds.right + 1 > _columnCount)
			columnCount = cell.bounds.right + 1;
		
		if (cell.bounds.bottom + 1 > _rowCount)
			rowCount = cell.bounds.bottom + 1;
		
		doSort = true;
		
		refresh();
	}
	
	/**
	 *
	 * @param e
	 *
	 */
	protected function resizeColumnHandler(e : ColumnEvent) : void
	{
	
	}
	
	/**
	 *
	 * @param e
	 *
	 */
	protected function resizeRowHandler(e : RowEvent) : void
	{
	
	}
}
}