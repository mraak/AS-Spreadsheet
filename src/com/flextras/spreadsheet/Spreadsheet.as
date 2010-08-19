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
import com.flextras.spreadsheet.vos.MoveOptions;

import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.geom.Point;
import flash.geom.Rectangle;

import mx.collections.ArrayCollection;
import mx.events.CollectionEvent;
import mx.events.CollectionEventKind;
import mx.events.FlexEvent;
import mx.managers.IFocusManagerComponent;

import spark.components.List;
import spark.components.supportClasses.SkinnableComponent;

use namespace spreadsheet;

//----------------------------------
//  Events
//----------------------------------

/**
 * @private  
 */
[Event(name="cellsChanged", type="flash.events.Event")]

/**
 * @eventType com.flextras.spreadsheet.SpreadsheetEvent.EXPRESSIONS_CHANGE
 */
[Event(name="expressionsChange", type="com.flextras.spreadsheet.SpreadsheetEvent")]

/**
 * @eventType com.flextras.spreadsheet.SpreadsheetEvent.EXPRESSIONS_CHANGED
 */
[Event(name="expressionsChanged", type="com.flextras.spreadsheet.SpreadsheetEvent")]

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
//--JH To access cells you seem to use alot of different methods.  Sometimes it is the string (A1).  
// Sometimes it seems to be point objects and other times it seems to be rectangle objects. 
// We should be more consistent; either in always accessing cells using the same method or consistently supporting all methods
// for example there is no 'setCellStylesByID method, but there is a setCellStyles [by point] and setCellStylesAt which uses specific coordinates

public class Spreadsheet extends SkinnableComponent implements ISpreadsheet, IFocusManagerComponent
{
	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------
	
	/**
	 * Constructor.
	 */
	public function Spreadsheet ()
	{
		setStyle ("skinClass", Class (SpreadsheetSkin));
		
		addEventListener (CellEvent.RESIZE, resizeCellHandler);
		
		addEventListener (ColumnEvent.INSERT, insertColumnHandler);
		addEventListener (ColumnEvent.REMOVE, removeColumnHandler);
		addEventListener (ColumnEvent.RESIZE, resizeColumnHandler);
		addEventListener (ColumnEvent.CLEAR, clearColumnHandler);
		
		addEventListener (RowEvent.INSERT, insertRowHandler);
		addEventListener (RowEvent.REMOVE, removeRowHandler);
		addEventListener (RowEvent.RESIZE, resizeRowHandler);
		addEventListener (RowEvent.CLEAR, clearRowHandler);
		
		_cells.addEventListener (CollectionEvent.COLLECTION_CHANGE, cells_collectionChangeHandler);
		
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
	 * @private
	 */
	override protected function commitProperties () : void
	{
		super.commitProperties ();
		
		if (columnCountChanged)
		{
			columnCountChanged = false;
			
			for (var i : uint = oldColumnCount; i < _columnCount; ++i)
				addColumn (i, _columnCount, oldRowCount);
			
			for (i = oldColumnCount; i > _columnCount; --i)
				removeColumn (i - 1, _columnCount, oldRowCount);
			
			oldColumnCount = _columnCount;
		}
		
		if (rowCountChanged)
		{
			rowCountChanged = false;
			
			for (i = oldRowCount; i < _rowCount; ++i)
				addRow (i, oldColumnCount, _rowCount);
			
			for (i = oldRowCount; i > _rowCount; --i)
				removeRow (i - 1, oldColumnCount, _rowCount);
			
			oldRowCount = _rowCount;
		}
		
		notifyChildren = true;
		
		if (cellsChanged)
		{
			cellsChanged = false;
			
			if (doSort)
			{
				doSort = false;
				
				_cells.refresh ();
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
				
				column.push (cell);
				row.push (cell);
				
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
					
					_uniqueCells.push (cell);
					++i;
				}
			}
			
			dispatchEvent (new Event ("cellsChanged"));
			
			grid.dataProvider = new ArrayCollection (_uniqueCells);
		}
		
		if (expressionsChange)
		{
			expressionsChange = false;
			
			//var usedCells : Array = [];
			var e : SpreadsheetEvent;
			
			var c : uint;
			
			if (expCE.kind == "refresh")
			{
				// iterate through _expressions
			}
			
			if (_expressions)
				while (c < _expressions.length)
				{
					var o : Object = _expressions.getItemAt (c);
					
					var _cell : String = itemToCell (o).toLowerCase ();
					o[cellField] = _cell;
					
					/*if (usedCells.indexOf(_cell) != -1)
					   throw new Error("Cell ID already used in this collection: " + _cell + ". Use setItem() or itemUpdated() if you want to change existing cell's expression.");
					
					 usedCells.push(_cell);*/
					
					var cellIndex : int = Utils.gridFieldToIndexes (_cell)[0];
					var rowIndex : int = Utils.gridFieldToIndexes (_cell)[1];
					
					if (rowIndex <= _rowCount && cellIndex <= _columnCount)
					{
						if (_cell.indexOf ("!") == -1)
						{
							var co : Cell = getCellAt (cellIndex, rowIndex);
							
							//if (!co)
							//	continue;
							
							if (!itemToExpression (o) || itemToExpression (o) == "")
							{
								if (expressionTree.indexOf (co.controlObject) > -1)
									calc.assignControlExpression (co.controlObject, "");
								
								_expressions.removeItemAt (c);
								
								co.expressionObject = null;
							}
							else
							{
								co.expressionObject = o;
								
								//calc.assignControlExpression(co.controlObject, co.expression || "", expressionTree.indexOf(co.controlObject) > -1);
								calc.assignControlExpression (co.controlObject, co.expression || "");
								c++;
							}
						}
						else
						{
							e = new SpreadsheetEvent (SpreadsheetEvent.WARNING);
							e.message = _cell + " - cell ignored due to incorect id";
							this.dispatchEvent (e);
						}
					}
					else
					{
						e = new SpreadsheetEvent (SpreadsheetEvent.WARNING);
						e.message = _cell + " out of column or row bounds on Spreadsheet " + this.id;
						this.dispatchEvent (e);
					}
				}
			
			dispatchEvent (new SpreadsheetEvent (SpreadsheetEvent.EXPRESSIONS_CHANGED));
		}
		
		if (clearExpressionsDirty)
		{
			clearExpressionsDirty = false;
			
			dispatchEvent (new SpreadsheetEvent (SpreadsheetEvent.EXPRESSIONS_CLEARED));
		}
		
		if (addColumnDirty)
		{
			addColumnDirty = false;
			
			dispatchEvent (new ColumnEvent (ColumnEvent.INSERTED, addColumnInfo.index));
		}
		
		if (addRowDirty)
		{
			addRowDirty = false;
			
			dispatchEvent (new RowEvent (RowEvent.INSERTED, addRowInfo.index));
		}
		
		if (removeColumnDirty)
		{
			removeColumnDirty = false;
			
			dispatchEvent (new ColumnEvent (ColumnEvent.REMOVED, removeColumnInfo.index));
		}
		
		if (removeRowDirty)
		{
			removeRowDirty = false;
			
			dispatchEvent (new RowEvent (RowEvent.REMOVED, removeRowInfo.index));
		}
		
		if (clearColumnDirty)
		{
			clearColumnDirty = false;
			
			dispatchEvent (new ColumnEvent (ColumnEvent.CLEARED, clearColumnInfo.index));
		}
		
		if (clearRowDirty)
		{
			clearRowDirty = false;
			
			dispatchEvent (new RowEvent (RowEvent.CLEARED, clearRowInfo.index));
		}
	
	}
	
	/**
	 * @private
	 */
	override protected function createChildren () : void
	{
		super.createChildren ();
		
		if (!expressions)
			expressions = new ArrayCollection;
		
		if (!_calc)
			calc = new Calc;
	}
	
	/**
	 * @private
	 */
	override protected function partAdded (partName : String, instance : Object) : void
	{
		super.partAdded (partName, instance);
		
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
			
			grid.scroller.verticalScrollBar.addEventListener (FlexEvent.VALUE_COMMIT, function (e : FlexEvent) : void
			{
				rowHeader.scroller.verticalScrollBar.value = e.currentTarget.value;
			});
			
			grid.scroller.horizontalScrollBar.addEventListener (FlexEvent.VALUE_COMMIT, function (e : FlexEvent) : void
			{
				columnHeader.scroller.horizontalScrollBar.value = e.currentTarget.value;
			});
			
			grid.setFocus ();
		}
	}
	
	/**
	 * @private
	 */
	override protected function partRemoved (partName : String, instance : Object) : void
	{
		super.partRemoved (partName, instance);
		
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

	// --JH Is there a columnHeaderRenderer and/or rowHeaderRenderer ? 
	// --JH I strongly recommend turning these skin parts into get set methods; as get/set methods can be extended, properties can't.

	[SkinPart(required="false")]
	/**
	 *This property contains the column headers of the spreadsheet component.
	 */
	public var columnHeader : List;
	
	[SkinPart(required="false")]
	/**
	 * This property contains the row headers of the spreadsheet component.
	 */
	public var rowHeader : List;
	
	[SkinPart(required="true")]
	// --JH Does this really need to be Bindable? 
	[Bindable]
	/**
	 * This property contains the grid that makes up the bulk of the spreadsheet display.
	 */
	public var grid : GridList;
	
	//--------------------------------------------------------------------------
	//
	//  Variables
	//
	//--------------------------------------------------------------------------
	
	/**
	 */
	// ---JH add some documentation for this property ----
	protected var doSort : Boolean;
	
	/**
	 */
	// ---JH add some documentation for this property ----
	protected var notifyChildren : Boolean;
	
	/**
	 */
	// ---JH add some documentation for this property ----
	protected var shiftActive : Boolean;
	
	/**
	 */
	//---JH add some documentation for this property ----
	spreadsheet var columns : Array;
	
	/**
	 */
	// ---JH add some documentation for this property ----
	spreadsheet var rows : Array;
	
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
	 * @inheritDoc
	 *
	 * @see com.flextras.calc.Calc
	 */
	public function get calc () : Calc
	{
		return _calc;
	}
	
	/**
	 * @private
	 */
	public function set calc (value : Calc) : void
	{
		if (_calc === value)
			return;
		
		if (_calc)
		{
			_calc.removeEventListener (SpreadsheetEvent.ERROR, onCalcError);
			_calc.removeEventListener (SpreadsheetEvent.WARNING, onCalcWarning);
		}
		
		_calc = value;
		
		if (value)
		{
			value.addSpreadsheet (this);
			value.addEventListener (SpreadsheetEvent.ERROR, onCalcError);
			value.addEventListener (SpreadsheetEvent.WARNING, onCalcWarning);
		}
		
		dispatchEvent (new Event ("calcChanged"));
	}
	
	//----------------------------------
	//  cellField
	//----------------------------------
	
	/**
	 * @private
	 */
	protected var _cellField : String = "cell";
	
	[Bindable(event="cellFieldChanged")]
	/**
     *  The name of the field in the data provider items used to determine their location in the Spreadsheet. 
	 * 
	 *  By default the list looks for a property named <code>cell</code> 
     *  on each item and uses that to position your dataProvider elements on the spreadsheet.
	 * .
	 * The value of this property should be a string in the format The format for this property is "[column index in alphabetical form][row index in numerical form]".
	 * 
     *  However, if the data objects do not contain a <code>cell</code> 
     *  property, you can set the <code>cellField</code> property to
     *  use a different property in the data object. 
     *
     *  @default "cell"
	 * 
	 * @see #cellFunction
     *  
	 */
	public function get cellField () : String
	{
		return _cellField;
	}
	
	/**
	 * @private
	 */
	public function set cellField (value : String) : void
	{
		if (_cellField == value)
			return;
		
		_cellField = value;
		
		dispatchEvent (new Event ("cellFieldChanged"));
	}
	
	//----------------------------------
	//  cellFunction
	//----------------------------------
	
	/**
	 * @private
	 */
	protected var _cellFunction : Function;
	
	[Bindable(event="cellFunctionChanged")]
	/**
	 *  This is a user-supplied function to run on each item to determine its cell location.  By default, the list looks for a property named <code>cell</code> on each data provider item and uses that for positioning your dataProvider objects in the spreadsheet grid.
	 *
	 * However, some data sets do not have a <code>cell</code> property nor do they have another property that can be used for positioning your cells.  
	 * 
	 * <p>You can supply a <code>cellFunction</code> that finds the   appropriate fields and returns a celllocation string.  The   <code>cellFunction</code> is good for handling complicated data, such as XML. </p>
	 * 
	 * <p>The cellFunction takes a single argument which is the item in the data provider and returns a String.  The string should be in the format The format for this property is "[column index in alphabetical form][row index in numerical form]".</p>
	 * 
	 *  <pre>mycellFunction(item:Object):String</pre>
	 * 
	 *  @default null
	 */
	public function get cellFunction () : Function
	{
		return _cellFunction;
	}
	
	/**
	 * @private
	 */
	public function set cellFunction (value : Function) : void
	{
		if (_cellFunction === value)
			return;
		
		_cellFunction = value;
		
		dispatchEvent (new Event ("cellFunctionChanged"));
	}
	
	//----------------------------------
	//  cells
	//----------------------------------
	
	/**
	 */
	// ---JH Why is this a const? Constants are usually non-changing, but you do change this array in other spots of this component ----
	protected const _cells : ArrayCollection = new ArrayCollection;
	
	/**
	 * @private
	 */
	protected var cellsChanged : Boolean;
	
	[Bindable(event="cellsChanged")]
	/**
	 * This property contains all the cells of the spreadsheet.
	 */
	public function get cells () : ArrayCollection
	{
		return _cells;
	}
	
	//----------------------------------
	//  columnCount
	//----------------------------------
	
	/**
	 */
	// ---JH add some documentation for this property ----
	protected var oldColumnCount : uint;
	
	/**
	 * @private
	 */
	protected var _columnCount : uint = 10;
	
	/**
	 * @private
	 */
	protected var columnCountChanged : Boolean = true;
	
	[Bindable(event="columnCountChanged")]
	/**
	 * This property represents the number of columns in the spreadsheet.
	 *
	 * @default 10
	 */
	public function get columnCount () : uint
	{
		return _columnCount;
	}
	
	/**
	 * @private
	 */
	public function set columnCount (value : uint) : void
	{
		if (value < 0 || _columnCount == value)
			return;
		
		_columnCount = value;
		columnCountChanged = true;
		notifyChildren = false;
		
		dispatchEvent (new Event ("columnCountChanged"));
		
		invalidateProperties ();
	}
	
	//----------------------------------
	//  columnWidths
	//----------------------------------
	
	/**
	 * @private
	 */
	protected var _columnWidths : Array;
	
	/**
	 */
	 // ---JH add some documentation for this property; why is it a constant if you're going to be changing it? ----
	protected const columnWidthsCollection : ArrayCollection = new ArrayCollection;
	
	[Bindable(event="columnWidthsChanged")]
	/**
	 * This property contains an array of all the column widths.
	 */
	// ---JH Do we want to document the spreadsheet namespace? ----
	spreadsheet function get columnWidths () : Array
	{
		return _columnWidths;
	}
	
	/**
	 * @private
	 */
	spreadsheet function set columnWidths (value : Array) : void
	{
		if (_columnWidths === value)
			return;
		
		_columnWidths = value;
		
		var array : Array = [];
		
		for (var i : uint, n : uint = value.length; i < n; ++i)
			array.push (Utils.alphabet[i]);
		
		columnWidthsCollection.source = array;
		
		dispatchEvent (new Event ("columnWidthsChanged"));
	}
	
	//----------------------------------
	//  ctrlObjects
	//----------------------------------
	
	/**
	 * @private
	 */
	protected var _ctrlObjects : Object = {};
	
	/**
	 * @inheritDoc
	 */
	public function get ctrlObjects () : Object
	{
		return _ctrlObjects;
	}
	
	//----------------------------------
	//  disabledCells
	//----------------------------------
	
	/**
	 * @private
	 */
	protected var _disabledCells : Vector.<Cell>;
	
	[Bindable(event="disabledCellsChanged")]
	/**
	 * This property contains all the disabled cells.  Disabled cells are cells that cannot be edited.
	 */
	public function get disabledCells () : Vector.<Cell>
	{
		return _disabledCells;
	}
	
	/**
	 * @private
	 */
	public function set disabledCells (value : Vector.<Cell>) : void
	{
		if (_disabledCells === value)
			return;
		
		for each (var cell : Cell in _disabledCells)
			cell.enabled = true;
		
		_disabledCells = value;
		
		for each (cell in value)
			cell.enabled = false;
		
		dispatchEvent (new Event ("disabledCellsChanged"));
	}
	
	//----------------------------------
	//  expressionField
	//----------------------------------
	
	/**
	 * @private
	 */
	protected var _expressionField : String = "expression";
	
	[Bindable(event="expressionFieldChanged")]
	/**
	 * The name of the field in the data provider items used to determine the object’s expression.
	 * 
	 * By default the list looks for a property named <code>expression</code> each item and uses that to determine the value, and formula used on the spreadsheet.
	 * 
	 * However, if the data objects do not contain an <code>expression</code> property, you can set the <code>expressionField</code> property to use a different property in the data object.
	 * 
	 * @return 
	 * 
	 */
	// --JH What can we say about the value of the expression field? 
	public function get expressionField () : String
	{
		return _expressionField;
	}
	
	/**
	 * @private
	 */
	public function set expressionField (value : String) : void
	{
		if (_expressionField == value)
			return;
		
		_expressionField = value;
		
		dispatchEvent (new Event ("expressionFieldChanged"));
	}
	
	//----------------------------------
	//  expressionFunction
	//----------------------------------
	
	/**
	 * @private
	 */
	protected var _expressionFunction : Function;
	
	[Bindable(event="expressionFunctionChanged")]
	/**
	 * This is a user-supplied function to run on each item to determine the item’s expression.  By default, the list looks for a property named <code>expression</code> on each data provider item and uses that for determining the formula and value that should be used on the spreadsheet grid.
	 * 
	 * However, some data sets do not have a <code>expression</code> property nor do they have another property that can be used for giving a formula to your cells.  
	 * 
	 * <p>You can supply a <code>expressionFunction</code> that finds the  appropriate fields and returns a expression string.  The   <code>expressionFunction</code> is good for handling complicated data, such as XML. </p>
	 * 
	 * <p>The expressionFunction takes a single argument which is the item in the data provider and returns a String.  </p>
	 * 
	 *  <pre>myExpressionFunction(item:Object):String</pre>
	 */
	public function get expressionFunction () : Function
	{
		return _expressionFunction;
	}
	
	/**
	 * @private
	 */
	public function set expressionFunction (value : Function) : void
	{
		if (_expressionFunction === value)
			return;
		
		_expressionFunction = value;
		
		dispatchEvent (new Event ("expressionFunctionChanged"));
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
	protected var expressionsChange : Boolean;
	
	[Bindable(event="expressionsChange")]
	/**
	 * @inheritDoc
	 */
	public function get expressions () : ArrayCollection
	{
		return _expressions;
	}
	
	/**
	 * @private
	 */
	public function set expressions (value : ArrayCollection) : void
	{
		if (_expressions === value)
			return;
		
		var oldValue : ArrayCollection = _expressions;
		
		if (_expressions)
		{
			//_expressions.removeAll(); //replace with reset
			_expressions.dispatchEvent (new CollectionEvent (CollectionEvent.COLLECTION_CHANGE, false, false, CollectionEventKind.RESET));
			
			_expressions.removeEventListener (CollectionEvent.COLLECTION_CHANGE, expressionsChangeHandler);
		}
		
		_expressions = value || new ArrayCollection;
		
		if (_expressions)
		{
			_expressions.addEventListener (CollectionEvent.COLLECTION_CHANGE, expressionsChangeHandler);
			
			_expressions.refresh ();
				//updateExpressions();
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
	 * @inheritDoc
	 */
	public function get expressionTree () : Array
	{
		return _expressionTree;
	}
	
	//----------------------------------
	//  globalStyles
	//----------------------------------
	
	/**
	 * @private
	 */
	spreadsheet const globalCell : Cell = new Cell;
	
	[Bindable(event="globalStylesChanged")]
	/**
	 * This property stores the styles that apply to all cells in the spreadsheet.
	 * These styles can be overwritten on an individual cell basis.
	 */
	public function get globalStyles () : CellStyles
	{
		return globalCell.styles;
	}
	
	/**
	 * @private
	 */
	public function set globalStyles (value : CellStyles) : void
	{
		if (!value)
			return;
		
		globalCell.styles.assign (value);
		
		dispatchEvent (new Event ("globalStylesChanged"));
	}
	
	/**
	 * @private
	 */
	// ---JH should this really be public?  ----
	public function set globalStylesObject (value : Object) : void
	{
		if (!value)
			return;
		
		if (value is CellStyles)
			globalStyles = CellStyles (value);
		else
		{
			globalCell.styles.assignObject (value);
			
			dispatchEvent (new Event ("globalStylesChanged"));
		}
	}
	
	//----------------------------------
	//  gridDataProvider
	//----------------------------------
	
	/**
	 * @private
	 */
	// ---JH add some documentation for this property ----
	public function get gridDataProvider () : ArrayCollection
	{
		return _cells;
	}
	
	//----------------------------------
	//  id
	//----------------------------------
	
	protected static var idCounter : uint;
	
	/**
	 * @inheritDoc 
	 */
	override public function get id () : String
	{
		if (!super.id)
			id = "Spreadsheet" + ++idCounter;
		
		return super.id;
	}
	
	//----------------------------------
	//  indexedCells
	//----------------------------------
	
	/**
	 * @private
	 */
	protected var _indexedCells : Object;
	
	/**
	 */
	// ---JH add some documentation for this property ----
	spreadsheet function get indexedCells () : Object
	{
		return _indexedCells;
	}
	
	//----------------------------------
	//  preferredColumnWidths
	//----------------------------------
	
	/**
	 * @private
	 */
	protected var _preferredColumnWidths : Array = [];
	
	[Bindable(event="preferredColumnWidthsChanged")]
	/**
	 */
	// ---JH add some documentation for this property ----
	public function get preferredColumnWidths () : Array
	{
		return _preferredColumnWidths;
	}
	
	//----------------------------------
	//  preferredRowHeights
	//----------------------------------
	
	/**
	 * @private
	 */
	protected var _preferredRowHeights : Array = [];
	
	[Bindable(event="preferredRowHeightsChanged")]
	/**
	 */
	// ---JH add some documentation for this property ----
	public function get preferredRowHeights () : Array
	{
		return _preferredRowHeights;
	}
	
	//----------------------------------
	//  rowCount
	//----------------------------------
	
	/**
	 * @private
	 */
	// ---JH What is this used for? ----
	protected var oldRowCount : uint;
	
	/**
	 * @private
	 */
	protected var _rowCount : uint = 10;
	
	/**
	 * @private
	 */
	protected var rowCountChanged : Boolean = true;
	
	[Bindable(event="rowCountChanged")]
	/**
	 * This property represents the number of rows in the spreadsheet.
	 */
	public function get rowCount () : uint
	{
		return _rowCount;
	}
	
	/**
	 * @private
	 */
	public function set rowCount (value : uint) : void
	{
		if (value < 0 || _rowCount == value)
			return;
		
		_rowCount = value;
		rowCountChanged = true;
		notifyChildren = false;
		
		dispatchEvent (new Event ("rowCountChanged"));
		
		invalidateProperties ();
	}
	
	//----------------------------------
	//  rowHeights
	//----------------------------------
	
	/**
	 * @private
	 */
	protected var _rowHeights : Array;
	
	/**
	 */
	// ---JH add some documentation for this property; why is it a constant if you're going to be changing it? ----
	protected const rowHeightsCollection : ArrayCollection = new ArrayCollection;
	
	[Bindable(event="rowHeightsChanged")]
	/**
	 *This property contains an array of all the row heights.
	 */
	spreadsheet function get rowHeights () : Array
	{
		return _rowHeights;
	}
	
	/**
	 * @private
	 */
	spreadsheet function set rowHeights (value : Array) : void
	{
		if (_rowHeights === value)
			return;
		
		_rowHeights = value;
		
		var array : Array = [];
		
		for (var i : uint, n : uint = value.length; i < n; ++i)
			array.push (i);
		
		rowHeightsCollection.source = array;
		
		dispatchEvent (new Event ("rowHeightsChanged"));
	}
	
	//----------------------------------
	//  spans
	//----------------------------------
	
	/**
	 * @private
	 */
	protected var _spans : Array;
	
	/**
	 * This property contains information for all cells that span multiple rows or columns.
	 */
	// ---JH add some documentation for this property; be sure to specify what object is expected in the array ----
	spreadsheet function get spans () : Array
	{
		return _spans;
	}
	
	//----------------------------------
	//  startRowIndex
	//----------------------------------
	
	/**
	 * @private
	 */
	protected var _startRowIndex : uint = 1;
	
	[Bindable(event="startRowIndexChanged")]
	/**
	 */
	// --JH Add some documentation for this property  
	public function get startRowIndex () : uint
	{
		return _startRowIndex;
	}
	
	/**
	 * @private
	 */
	public function set startRowIndex (value : uint) : void
	{
		if (_startRowIndex == value)
			return;
		
		_startRowIndex = value;
		
		dispatchEvent (new Event ("startRowIndexChanged"));
	}
	
	//----------------------------------
	//  uniqueCells
	//----------------------------------
	
	/**
	 * @private
	 */
	protected var _uniqueCells : Array;
	
	/**
	 */
	//---JH add some documentation for this property; be sure to specify what object is expected in the array ----
	spreadsheet function get uniqueCells () : Array
	{
		return _uniqueCells;
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
	 * This method will add an empty cell to the spreadsheet.
	 *
	 * @param columnIndex This specifies the column location to add the cell.
	 * @param rowIndex This specifies the row location to add the cell
	 *
	 *
	 */
	// ---JH How does adding a cell with this method affect rows and columns?  Is it like an insert or a replace? ----
	protected function addCell (columnIndex : uint, rowIndex : uint) : void
	{
		var cell : Cell = new Cell (this, new Rectangle (columnIndex, rowIndex + startRowIndex));
		cell.globalStyles = globalCell.styles;
		
		_cells.addItem (cell);
	}
	
	//----------------------------------
	//  addColumn
	//----------------------------------
	
	/**
	 * @private 
	 */
	protected var addColumnDirty : Boolean;
	
	/**
	 * @private
	 *  
	 */
	// ---JH add documentation for this property 
	protected var addColumnInfo : Object;
	
	/**
	 * This method will add a column into the spreadsheet at the specified location.
	 *
	 *
	 * @param index
	 * @param columnCount
	 * @param rowCount
	 *
	 */
	// ---JH Define the arguments, as it is not obvious to me what they mean. ----
	// ---JH I assume dding a column will shift other columns, correct? ----
	protected function addColumn (index : uint, columnCount : uint, rowCount : uint) : void
	{
		// --JH Make this event cancelable
		if (notifyChildren && index < columnCount - 1)
			dispatchEvent (new ColumnEvent (ColumnEvent.BEFORE_INSERTED, index));
		
		// --JH document this object; possibly turning it into a VO
		addColumnInfo = {prop: "colIndex", index: index, x: 1, y: 0, exclude: [index, null, null, null]};
		
		for (var i : uint; i < rowCount; ++i)
		{
			if (notifyChildren)
				addColumnDirty = true;
			
			addCell (index, i);
		}
	}
	
	//----------------------------------
	//  addRow
	//----------------------------------
	
	/**
	 * @private
	 */
	// ---JH add some documentation for this property ----
	protected var addRowDirty : Boolean;
	
	/**
	 * @private
	 */
	// ---JH add some documentation for this property ----
	protected var addRowInfo : Object;
	
	/**
	 * This method will add a row into the spreadsheet at the specified location.
	 *
	 *
	 * @param index
	 * @param columnCount
	 * @param rowCount
	 *
	 */
	// ---JH Define the arguments, as it is not obvious to me what they mean. ----
	// ---JH I assume adding a row will shift other rows, correct? ----
	protected function addRow (index : uint, columnCount : uint, rowCount : uint) : void
	{

		// --JH make this event cancelable 
		if (notifyChildren && index < rowCount - 1)
			dispatchEvent (new RowEvent (RowEvent.BEFORE_INSERTED, index));
		
		// --JH Document this object; possibly turning it into a VO
		addRowInfo = {prop: "rowIndex", index: index, x: 0, y: 1, exclude: [null, null, index, null]};
		
		for (var i : uint; i < columnCount; ++i)
		{
			if (notifyChildren)
				addRowDirty = true;
			
			addCell (i, index);
		}
	}
	
	//----------------------------------
	//  assignExpression
	//----------------------------------
	
	/**
	 * This method will add a single expression to the cell at the specified location.
	 * If an expression already exists at the specified cell location, then it will be replaced.
	 *
	 *
	 * @param cellId This argument specifies the cell you want to assign the expression to.
	 * The format for address a cell is "[column index in alphabetical form][row index in numerical form]".
	 * For example, "a1", points to column 0 and row 1.
	 *
	 * @param expression This argument specifies the expression to put at the cell location.
	 * The result of this expression will be seen in the target cell.
	 * To remove an existing expression, specify null or an empty string.
	 *
	 */
	public function assignExpression (cellId : String, expression : String) : void
	{
		if (!cellId)
			return;
		
		cellId = cellId.toLowerCase ();
		
		if (expression != null)
			expression = expression.toLowerCase ();
		else
			expression = "";
		
		var o : Object = getExpressionObject (cellId);
		
		if (o)
		{
			o[cellField] = cellId;
			
			if (itemToExpression (o) != expression)
			{
				o[expressionField] = expression;
				
				_expressions.itemUpdated (o);
			}
		}
		else if (expression && expression.length > 0)
		{
			o = {value: ""};
			o[cellField] = cellId;
			o[expressionField] = expression;
			
			_expressions.addItem (o);
		}
	}
	
	//----------------------------------
	//  assignExpressions
	//----------------------------------
	
	/**
	 * Each object in the expressions array should include a cell property to specify the location and an expression property to specify the new expression.
	 *
	 * For more information on the cell and expression, see the expressions property.
	 *
	 * @param expressions An array of objects
	 *
	 * @see #assignExpression
	 * @see #expressions
	 */
	public function assignExpressions (expressions : Array) : void
	{
		for each (var o : Object in expressions)
			this.assignExpression (itemToCell (o), itemToExpression (o));
	}
	
	//----------------------------------
	//  getExpressionObject
	//----------------------------------
	
	/**
	 * @inheritDoc
	 */
	public function getExpressionObject (cellId : String) : Object
	{
		if (!cellId)
			return null;
		
		cellId = cellId.toLowerCase ();
		
		for each (var o : Object in _expressions)
			if (itemToCell (o) == cellId)
				return o;
		
		return null;
	}
	
	//----------------------------------
	//  getCell
	//----------------------------------
	
	/**
	 * This method retrieves the cell based on the given Point object.
	 *
	 * @param location A point that specifies the location of the cell to retrieve.
	 * @return An object representing the cell.
	 *
	 * @see com.flextras.vos.Cell
	 *
	 */
	// ---JH Suggested Name:  getCellByPoint; it is less ambigious ----
	// ---JH Should we consider using Point objects internally instead of the "a1" syntax? ----
	public function getCell (location : Point) : Cell
	{
		if (!location)
			return null;
		
		return getCellAt (location.x, location.y);
	}
	
	//----------------------------------
	//  getCellAt
	//----------------------------------
	/**
	 * This method retrieves the cell based on the specified coordinates.
	 *
	 * @param columnIndex This specifies the columnIndex of the cell we want to retrieve.
	 * @param rowIndex This specifies the rowIndex of the cell we want to retrieve.
	 * @return An object representing the cell.
	 *
	 * @see com.flextras.vos.Cell
	 * 
 	 */
	public function getCellAt (columnIndex : uint, rowIndex : uint) : Cell
	{
		if (isColumnIndexInvalid (columnIndex) || isRowIndexInvalid (rowIndex))
			return null;
		
		return _indexedCells[columnIndex + "|" + rowIndex];
	}
	
	//----------------------------------
	//  getCellById
	//----------------------------------
	/**
	 * This method retrieves the cell based on the specified coordinates.
	 * 
	 * @param value This specifies the ID of the cell to retrieve.  
	 * 
	 * @return This method returns the cell that exists at the specified location.  If no cell exists at the specified location, then null is returned.
	 * 
	 */
	// --JH What is the value argument?  The Cell location "A1"  OR something different? 
	public function getCellById (value : String) : Cell
	{
		// -- JH what happens if there are more than 26 columns? 
		if (!value || value.length != 2)
			return null;
		
		var id : Array = Utils.gridFieldToIndexes (value);
		var columnIndex : int = id[0];
		var rowIndex : int = id[1];
		
		if (isColumnIndexInvalid (columnIndex) || isRowIndexInvalid (rowIndex))
			return null;
		
		return _indexedCells[columnIndex + "|" + rowIndex];
	}
	
	//----------------------------------
	//  getCellCondition
	//----------------------------------
	
	/**
	 *  This method retrieves the condition object of the cell located at the given point.
	 *
	 * @param location A point that specifies the location of the cell, whose condition the method will retrieve.
	 * @return  An object representing the cell.
	 *
	 * @see com.flextras.vos.Condition
	 *
	 */
	//  --JH Suggested name: getCellConditionByPoint as it is less ambigious 
	public function getCellCondition (location : Point) : Condition
	{
		if (!location)
			return null;
		
		return getCellConditionAt (location.x, location.y);
	}
	
	//----------------------------------
	//  getCellConditionAt
	//----------------------------------
	/**
	 * This method retrieves the condition object of the cell located at the given coordinates.
	 *
	 * @param columnIndex This specifies the columnIndex of the cell whose condition the method will retrieve.
	 * @param rowIndex This specifies the rowIndex of the cell whose condition the method will retrieve.
	 * @return  An object representing the cell.
	 *
	 * @see com.flextras.vos.Condition
	 */
	public function getCellConditionAt (columnIndex : uint, rowIndex : uint) : Condition
	{
		if (isColumnIndexInvalid (columnIndex) || isRowIndexInvalid (rowIndex))
			return null;
		
		return getCellAt (columnIndex, rowIndex).condition;
	}
	
	//----------------------------------
	//  setCellCondition
	//----------------------------------
	/**
	 * This method sets the condition object of the cell located at the given Point.
	 *
	 * @param location A point that specifies the location of the cell, whose condition the method will retrieve.
	 * @param condition This property specifies the new Condition.
	 *
	 * 
	 * @see com.flextras.vos.Condition
	 */
	//  --JH Suggested name: setCellConditionByPoint as it is less ambigious 
	public function setCellCondition (location : Point, condition : Condition) : void
	{
		if (!location || !condition)
			return;
		
		setCellConditionAt (location.x, location.y, condition);
	}
	
	//----------------------------------
	//  setCellConditionAt
	//----------------------------------
	/**
	 *
	 * @param columnIndex This specifies the columnIndex of the cell whose condition the method will set.
	 * @param rowIndex This specifies the columnIndex of the cell whose condition the method will set.
	 * @param condition This property specifies the new Condition.
	 *
	 * @see com.flextras.vos.Condition
	 */
	public function setCellConditionAt (columnIndex : uint, rowIndex : uint, condition : Condition) : void
	{
		if (isColumnIndexInvalid (columnIndex) || isRowIndexInvalid (rowIndex) || !condition)
			return;
		
		getCellAt (columnIndex, rowIndex).condition = condition;
	}
	
	//----------------------------------
	//  setCellConditionObject
	//----------------------------------
	/**
	 * This method sets the condition object of the cell located at the given Point.
	 *
	 * @param location A point that specifies the location of the cell, whose condition the method will retrieve.
	 * @param condition This property specifies the new Condition.
	 *
	 * @see com.flextras.vos.Condition
	 * 
	 */
	 // --JH I'm not sure why these 'object' methods are needed or used. When will you use a genericObject instead of a Condition Object?
	 // --JH Suggested name: setCellConditionObjectByPoint as it is less ambigious 
	public function setCellConditionObject (location : Point, condition : Object) : void
	{
		if (!location || !condition)
			return;
		
		setCellConditionObjectAt (location.x, location.y, condition);
	}
	
	//----------------------------------
	//  setCellConditionObjectAt
	//----------------------------------
	/**
	 * This method sets the condition object of the cell located at the given coordinates.
	 *
	 * @param columnIndex This specifies the columnIndex of the cell whose condition the method will set.
	 * @param rowIndex specifies the rowIndex of the cell whose condition the method will set.
	 * @param condition This property specifies the new Condition.
	 *
	 * @see com.flextras.vos.Condition
	 */
	public function setCellConditionObjectAt (columnIndex : uint, rowIndex : uint, condition : Object) : void
	{
		if (isColumnIndexInvalid (columnIndex) || isRowIndexInvalid (rowIndex) || !condition)
			return;
		
		getCellAt (columnIndex, rowIndex).conditionObject = condition;
	}
	
	//----------------------------------
	//  getCellStyles
	//----------------------------------
	/**
	 * This method returns the cellStyles at the specified point.
	 *
	 * @param location A point that specifies the location of the cell, whose styles the method will process.
	 * @return An object representing the cell’s styles.
	 *
	 * @see com.flextras.vos.CellStyles
	 * 
	 */
	//  --JH Suggested name: getCellStylesByPoint as it is less ambigious 
	public function getCellStyles (location : Point) : CellStyles
	{
		if (!location)
			return null;
		
		return getCellStylesAt (location.x, location.y);
	}
	
	//----------------------------------
	//  getCellStylesAt
	//----------------------------------
	/**
	 * This method returns the cellStyles at the specified coordinates.
	 *
	 * @param columnIndex This specifies the columnIndex of the cell whose styles the method will process.
	 * @param rowIndex This specifies the rowIndex of the cell whose styles the method will process.
	 * @return An object representing the cell’s styles.
	 *
	 * @see com.flextras.vos.CellStyles
	 */
	public function getCellStylesAt (columnIndex : uint, rowIndex : uint) : CellStyles
	{
		if (isColumnIndexInvalid (columnIndex) || isRowIndexInvalid (rowIndex))
			return null;
		
		return getCellAt (columnIndex, rowIndex).styles;
	}
	
	//----------------------------------
	//  setCellStyles
	//----------------------------------
	/**
	 * This method set the cellStyles at the specified point.
	 *
	 * @param location A point that specifies the location of the cell, whose styles the method will process.
	 * @param styles An object representing the cell’s styles.
	 *
	 * @see com.flextras.vos.CellStyles
	 * 
	 */
	//  --JH Suggested name: setCellStylesByPoint as it is less ambigious 
	public function setCellStyles (location : Point, styles : CellStyles) : void
	{
		if (!location || !styles)
			return;
		
		setCellStylesAt (location.x, location.y, styles);
	}
	
	//----------------------------------
	//  setCellStylesAt
	//----------------------------------
	/**
	 * This method sets the cellStyles at the specified coordinates.
	 *
	 * @param columnIndex This specifies the columnIndex of the cell whose styles the method will process.
	 * @param rowIndex This specifies the rowIndex of the cell whose styles the method will process.
	 * @param styles An object representing the cell’s styles.
	 *
	 * @see com.flextras.vos.CellStyles
	 */
	public function setCellStylesAt (columnIndex : uint, rowIndex : uint, styles : CellStyles) : void
	{
		if (isColumnIndexInvalid (columnIndex) || isRowIndexInvalid (rowIndex) || !styles)
			return;
		
		getCellAt (columnIndex, rowIndex).styles = styles;
	}
	
	//----------------------------------
	//  setCellStylesObject
	//----------------------------------
	/**
	 * This method sets the cellStyles at the specified Point.
	 *
	 * @param location A point that specifies the location of the cell, whose styles the method will process.
	 * @param styles An object representing the cell’s styles.
	 *
	 * @see com.flextras.vos.CellStyles
	 * 
	 */
	//  --JH Suggested name: setCellStylesObjectByPoint as it is less ambigious 
	// --JH Why would we need to support a generic object as opposed to a specific CellStyles instance? 
	public function setCellStylesObject (location : Point, styles : Object) : void
	{
		if (!location || !styles)
			return;
		
		setCellStylesObjectAt (location.x, location.y, styles);
	}
	
	//----------------------------------
	//  setCellStylesObjectAt
	//----------------------------------
	/**
	 * This method sets the cellStyles at the specified coordinates.
	 *
	 * @param columnIndex This specifies the columnIndex of the cell whose styles the method will process.
	 * @param rowIndex This specifies the rowIndex of the cell whose styles the method will process.
	 * @param styles An object representing the cell’s styles.
	 *
	 * @see com.flextras.vos.CellStyles
	 * 
	 */
	//  --JH Why would we need to support a generic object as opposed to a specific CellStyles instance? 
	public function setCellStylesObjectAt (columnIndex : uint, rowIndex : uint, styles : Object) : void
	{
		if (isColumnIndexInvalid (columnIndex) || isRowIndexInvalid (rowIndex) || !styles)
			return;
		
		getCellAt (columnIndex, rowIndex).stylesObject = styles;
	}
	
	//----------------------------------
	//  clearCell
	//----------------------------------
	
	/**
	 * This method will clear all the cells properties at the specified location.
	 *
	 * @param location A point that specifies the location of the cell to clear.
	 *
	 */
	//  --JH Suggested name: clearCellByPoint as it is less ambigious 
	public function clearCell (location : Point) : void
	{
		if (!location)
			return;
		
		clearCellAt (location.x, location.y);
	}
	
	//----------------------------------
	//  clearCellAt
	//----------------------------------
	/**
	 * This method will clear all the cells properties at the specified coordinates.
	 *
	 * @param columnIndex This specifies the columnIndex of the cell to be processed.
	 * @param rowIndex This specifies the rowIndex the cell to be processed.
	 *
	 */
	public function clearCellAt (columnIndex : uint, rowIndex : uint) : void
	{
		if (isColumnIndexInvalid (columnIndex) || isRowIndexInvalid (rowIndex))
			return;
		
		var cell : Cell = getCellAt (columnIndex, rowIndex);
		
		if (!cell)
			return;
		
		cell.clear ();
	}
	
	//----------------------------------
	//  clearColumnAt
	//----------------------------------
	/**
	 * This method clears data and formulas from all cells in the specified column.
	 *
	 * @param index This specifies the index of the column to clear.
	 *
	 */
	public function clearColumnAt (index : uint) : void
	{
		if (isColumnIndexInvalid (index))
			return;
		
		dispatchEvent (new ColumnEvent (ColumnEvent.CLEAR, index));
	}
	
	//----------------------------------
	//  clearExpressions
	//----------------------------------
	
	/**
	 * @private
	 */
	// ---JH It is unusual to put a variable in the 'methods' section ----
	protected var clearExpressionsDirty : Boolean;
	
	/**
	 * @private
	 * 
	 */
	// ---JH add some documentation for this method; should it really be public if it will not be documented? ----
	// --JH If this deletes all expressions; should it really be public?  
	public function clearExpressions () : void
	{
		clearExpressionsDirty = true;
		
		expressions.removeAll ();
	}
	
	//----------------------------------
	//  clearRowAt
	//----------------------------------
	
	/**
	 * This method clears data and formulas from all cells in the specified row.
	 *
	 * @param index This specifies the index of the row  to clear.
	 *
	 *  before the work is done.
	 */
	// --JH This appears to dispatch an event, but doesn't do any of the 'row clearing' work.  Which is a bit odd to dispatch an event
	public function clearRowAt (index : uint) : void
	{
		if (isRowIndexInvalid (index))
			return;
		
		dispatchEvent (new RowEvent (RowEvent.CLEAR, index));
	}
	
	//----------------------------------
	//  getColumnWidthAt
	//----------------------------------
	
	[Bindable(event="columnWidthsChanged")]
	[Bindable(event="preferredColumnWidthsChanged")]
	/**
	 * This method returns the width of the column at the specified index.
	 *
	 * @param index This specifies the index of the column.
	 * @return This returns the column width.
	 *
	 */
	public function getColumnWidthAt (index : uint) : Number
	{
		if (isColumnIndexInvalid (index))
			return NaN;
		
		var value : Number = _preferredColumnWidths[index];
		
		if (isNaN (value))
		{
			if (_columnWidths)
			{
				var columnWidth : CellWidth = _columnWidths[index];
				
				if (columnWidth)
					value = columnWidth.value;
				else
					value = new CellWidth ().value;
			}
			else
				value = new CellWidth ().value;
		}
		
		return value;
	}
	
	//----------------------------------
	//  setColumnWidthAt
	//----------------------------------
	/**
	 * This method sets the column width at the specified index.
	 *
	 * @param index This specifies the index of the column.
	 * @param value This specifies the new width of the column.
	 *
	 */
	public function setColumnWidthAt (index : uint, value : Number) : void
	{
		if (isColumnIndexInvalid (index))
			return;
		
		_preferredColumnWidths[index] = value;
		
		grid.dataGroup.invalidateDisplayList ();
		
		dispatchEvent (new Event ("preferredColumnWidthsChanged"));
	}
	
	//----------------------------------
	//  getElementIndex
	//----------------------------------	
	
	/**
	 * @private
	 */
	// ---JH This would normally be put in the 'variables' section; not the methods section ----
	protected var _elementIndex : Object;
	
	/**
	 * This method returns the index of the element at the specified coordinates.
	 *
	 * @param columnIndex This specifies the columnIndex of the cell to be processed.
	 * @param rowIndex This specifies the rowIndex the cell to be processed.
	 * @return The element at the specified index.  If no element exists, -1 is returned.
	 *
	 */
	// -- JH What is an element in this case?  A cell?  Or something else?  this is a bit confusing 
	spreadsheet function getElementIndex (columnIndex : uint, rowIndex : int) : int
	{
		var index : Object = _elementIndex[columnIndex + "|" + rowIndex];
		
		return index == null ? -1 : int (index);
	}
	
	//----------------------------------
	//  getIdByIndex
	//----------------------------------	
	/**
	 * @private
	 */
	// ---JH This would normally be put in the 'variables' section; not the methods section ----
	protected var ids : Array;
	
	/**
	 * This method retrieves the id of a cell based on the cell’s index.
	 *
	 * @param index This specifies the index of the id to retrieve.
	 */
	spreadsheet function getIdByIndex (index : uint) : String
	{
		return ids[index];
	}
	
	//----------------------------------
	//  isColumnIndexInvalid
	//----------------------------------	
	/**
	 * This method verifies that the specified value represents a valid column index.
	 *
	 * @param value This specifies the index to validate.
	 * @return This method returns true if the specified index is valid, or false if not.
	 *
	 */
	protected function isColumnIndexInvalid (value : uint) : Boolean
	{
		return value < 0 || value >= _columnCount;
	}
	
	//----------------------------------
	//  isRowIndexInvalid
	//----------------------------------	
	/**
	 * This method verifies that the specified value represents a valid row index.
	 *
	 * @param value This specifies the index to validate.
	 * @return This method returns true if the specified index is valid, or false if not.
	 *
	 */
	protected function isRowIndexInvalid (value : uint) : Boolean
	{
		return value < 0 || value >= _rowCount;
	}
	
	//----------------------------------
	//  insertColumnAt
	//----------------------------------
	
	/**
	 * This method creates a new column at the specified index.
	 *
	 * @param index This specifies the location to create a new column
	 *
	 */
	// -- JH It is a bit weird that this dispatches an event, ut does nothing else.  Events are good for things like this
	// but usually to inform the user that something happened, not that is going to happen.  It is possible a user's listener 
	// will fire before your own listener; causing confusion
	public function insertColumnAt (index : uint) : void
	{
		if (isColumnIndexInvalid (index))
			return;
		
		dispatchEvent (new ColumnEvent (ColumnEvent.INSERT, index));
	}
	
	//----------------------------------
	//  insertRowAt
	//----------------------------------
	
	/**
	 * This method creates a new row at the location specified.
	 *
	 * @param index This specifies the location to create a new row.
	 *
	 */
	public function insertRowAt (index : uint) : void
	{
		if (isRowIndexInvalid (index))
			return;
		
		dispatchEvent (new RowEvent (RowEvent.INSERT, index));
	}
	
	//----------------------------------
	//  itemToCell
	//----------------------------------
	
	/**
	 * This method accepts an object from your dataProvider and returns the cell location string.
	 * 
	 * 
 	 * 
	 * @param value This specifics the object from your dataProvider.
	 * @return A String representing the cell.  The string will be in the format "[column index in alphabetical form][row index in numerical form]".  "a1" for example points to column 0 and row 1.
	 * 
	 */
	// ---JH What happens if the object has no cellField property?  This method should handle tat, either by throwing an error / returning an null / or returning the first "unusd" cell ----
	public function itemToCell (value : Object) : String
	{
		if (cellFunction != null)
			return cellFunction (value[cellField]);
		
		return value[cellField];
	}
	
	//----------------------------------
	//  itemToExpression
	//----------------------------------
	
	/**
	 * This method accepts an object from your dataProvider and returns a string representing that object's expression.
	 * 
	 * 
	 * @param value This specifics the object from your dataProvider.
	 * @return A String representing the object's expression.
	 * 
	 */
	// ---JH What happens if the object has no expressionField property?  This method should handle that, either by throwing an error / returning an null / or returning an empty string / or???  ----
	public function itemToExpression (value : Object) : String
	{
		if (expressionFunction != null)
			return expressionFunction (value[expressionField]);
		
		return value[expressionField];
	}
	
	//----------------------------------
	//  selectedCells
	//----------------------------------
	// --JH Most Flex Components have a selectedCell and selectedCells property.  The selectedCell property would return the first 
	// item in this vector.  
	//TODO: move and extend, make public
	/**
	 * This property returns a vector of selected Cells.  
	 */
	protected function get selectedCells () : Vector.<Cell>
	{
		var items : Vector.<Object> = grid.selectedItems;
		
		return Vector.<Cell> (items);
	}
	
	//----------------------------------
	//  moveCells
	//----------------------------------
	//TODO: improve
	/**
	 * This method will move a selection of cells from their current location to a new location.
	 * 
	 * @param cells This is a Vector containing the Cell objects to be copied. 
	 * @param to This is the point that refers to the top left location where the new cells will be placed.
	 * @param copy This is a Boolean value that specifies whether cells should be moved or copied.
	 * @param options 
	 * 
	 * 
	 * @see com.flextras.spreadsheet.vos.MoveOptions
	 * 
	 */
	// ---JH Not sure what the options argument is --
	// ---JH What happens if the Vector does not contain contiguous cells??  For example A1 and B12
	public function moveCells (cells : Vector.<Cell>, to : Point, copy : Boolean = false, options : String = MoveOptions.ALL) : void
	{
		if (!cells || !to || !options)
			return;
		
		var o : Object;
		
		var i : uint = 1, n : uint = cells.length;
		var target : Cell = cells[0];
		var startColumn : uint = target.columnIndex, startRow : uint = target.rowIndex;
		var endColumn : uint, endRow : uint;
		
		for (; i < n; ++i)
		{
			target = cells[i];
			
			startColumn = Math.min (startColumn, target.columnIndex);
			startRow = Math.min (startRow, target.rowIndex);
			
			endColumn = Math.max (endColumn, target.bounds.right);
			endRow = Math.max (endRow, target.bounds.bottom);
		}
		
		var offset : Point = new Point (to.x - startColumn, to.y - startRow);
		
		endColumn += startColumn + offset.x;
		endRow += startRow + offset.y + 1;
		
		if (endColumn > columnCount)
			columnCount = endColumn;
		
		if (endRow > rowCount)
			rowCount = endRow;
		
		validateProperties ();
		
		for (i = 0; i < n; ++i)
		{
			target = getCellAt (cells[i].bounds.x + offset.x, cells[i].bounds.y + offset.y);
			
			if (!target)
				continue;
			
			switch (options)
			{
				case MoveOptions.ALL:
					target.assign (cells[i]);
					
					if (copy)
						target.expression = cells[i].controlObject.exp ? Utils.moveExpression2 (cells[i].controlObject, offset.x, offset.y) : cells[i].value;
					else
						target.expression = cells[i].expression;
					
					break;
				
				case MoveOptions.EXPRESSIONS:
					
					if (copy)
						target.expression = cells[i].controlObject.exp ? Utils.moveExpression2 (cells[i].controlObject, offset.x, offset.y) : cells[i].value;
					else
						target.expression = cells[i].expression;
					
					break;
				
				case MoveOptions.STYLES:
					target.styles = cells[i].styles;
					break;
				
				case MoveOptions.CONDITIONS:
					target.condition = cells[i].condition;
					break;
				
				case MoveOptions.VALUES:
					target.expression = cells[i].value;
					break;
			}
			
			if (!copy)
				getCellAt (cells[i].columnIndex, cells[i].rowIndex).clear ();
		}
	}
	
	//----------------------------------
	//  getRangeCells
	//----------------------------------
	
	/**
	 * This method will return a group of cells based on the data in the specified Rectangle.
	 * 
	 * @param location This is a Rectangle object specifying the start coordinates as the x and y values of the rectangle.  The width and height values of the Rectangle specify number of columns or rows to span, respectively.
	 * @return This method returns a Vector of the cells at the location specified. 
	 *
	 */
	// -- JH Suggested Name: getRangeCellsByRectange as it is less ambigious 
	public function getRangeCells (location : Rectangle) : Vector.<Cell>
	{
		if (!location)
			return null;
		
		return getRangeCellsAt (location.x, location.y, location.width, location.height);
	}
	
	/**
	 * This method will return a group of cells that represent the specified coordinates.
	 * 
	 * @param columnIndex This specifies the integer location of the column to start the cell retrieval.  
	 * @param rowIndex This specifies the integer location of the row to start the cell retrieval.
	 * @param columnSpan This specifies the number of columns to retrieve.
	 * @param rowSpan This specifies the number of rows to retrieve.
	 * 
	 * @return This method returns a Vector of the cells at the location specified. 
	 *
	 */
	public function getRangeCellsAt (columnIndex : uint, rowIndex : uint, columnSpan : uint, rowSpan : uint) : Vector.<Cell>
	{
		if (isColumnIndexInvalid (columnIndex)
			|| isRowIndexInvalid (rowIndex)
			|| columnSpan < 0
			|| rowSpan < 0)
			return null;
		
		var result : Vector.<Cell> = new Vector.<Cell>;
		var c : uint = columnIndex, cs : uint = c + columnSpan - 1;
		var r : uint = rowIndex, rs : uint = r + rowSpan - 1;
		
		for (; c <= cs; ++c)
			for (r = rowIndex; r <= rs; ++r)
				result.push (getCellAt (c, r));
		
		return result;
	}
	
	//----------------------------------
	//  getRangeConditions
	//----------------------------------
	
	/**
	 * This method will return a group of range conditions that exist at the specified coordinates.
	 *
	 * @param location This is a Rectangle object specifying the start coordinates as the x and y values of the rectangle.  The width and height values of the Rectangle specify number of columns or rows to span, respectively.
	 * 
	 * @return This method returns a Vector of the condition that exist at the location specified. 
	 *
	 * @see com.flextras.spreadsheet.vos.Condition
	 * 
	 */
	// ---JH I'm unclear what Range Conditions are  ----
	// -- JH Suggested Name: getRangeConditionsByRectange as it is less ambigious 
	public function getRangeConditions (location : Rectangle) : Vector.<Condition>
	{
		if (!location)
			return null;
		
		return getRangeConditionsAt (location.x, location.y, location.width, location.height);
	}
	
	//----------------------------------
	//  getRangeConditionsAt
	//----------------------------------
	/**
	 * This method will return a group of range conditions that exist at the specified coordinates.
	 *
	 * @param columnIndex This specifies the integer location of the column to start the condition retrieval.  
	 * @param rowIndex This specifies the integer location of the row to start the condition retrieval.
	 * @param columnSpan This specifies the number of columns to retrieve.
	 * @param rowSpan This specifies the number of rows to retrieve.
	 * 
	 * @return This method returns a Vector of the condition that exist at the location specified. 
	 *
	 * @see com.flextras.spreadsheet.vos.Condition
	 */
	 // ---JH I'm unclear what Range Conditions are  ----
	public function getRangeConditionsAt (columnIndex : uint, rowIndex : uint, columnSpan : uint, rowSpan : uint) : Vector.<Condition>
	{
		if (isColumnIndexInvalid (columnIndex)
			|| isRowIndexInvalid (rowIndex)
			|| columnSpan < 0
			|| rowSpan < 0)
			return null;
		
		var result : Vector.<Condition> = new Vector.<Condition>;
		var c : uint = columnIndex, cs : uint = c + columnSpan;
		var r : uint = rowIndex, rs : uint = r + rowSpan;
		
		for (; c <= cs; ++c)
			for (r = rowIndex; r <= rs; ++r)
				result.push (getCellConditionAt (c, r));
		
		return result;
	}
	
	//----------------------------------
	//  setRangeCondition
	//----------------------------------
	/**
	 * This method will set the range condition at the specified location. 
	 * 
	 * @param location This is a Rectangle object specifying the start coordinates as the x and y values of the rectangle.  The width and height values of the Rectangle specify number of columns or rows to span, respectively.
	 * @param condition
	 *
	 * @see com.flextras.spreadsheet.vos.Condition
	 */
	// -- JH Suggested Name: setRangeConditionsByRectange as it is less ambigious 
	public function setRangeCondition (location : Rectangle, condition : Condition) : void
	{
		if (!location || !condition)
			return;
		
		setRangeConditionAt (location.x, location.y, location.width, location.height, condition);
	}
	
	//----------------------------------
	//  setRangeConditionAt
	//----------------------------------
	/**
	 * This method will set the range condition at the specified location. 
	 * 
	 * @param columnIndex specifies the integer location of the column to set the condition.  
	 * @param rowIndex This specifies the integer location of the row to set the condition.
	 * @param columnSpan This specifies the number of columns to set.
	 * @param rowSpan This specifies the number of rows to set.
	 * @param condition This specifies the condition to set at the specified location.
	 *
	 * @see com.flextras.spreadsheet.vos.Condition
	 */
	public function setRangeConditionAt (columnIndex : uint, rowIndex : uint, columnSpan : uint, rowSpan : uint, condition : Condition) : void
	{
		if (!condition)
			return;
		
		var result : Vector.<Condition> = getRangeConditionsAt (columnIndex, rowIndex, columnSpan, rowSpan);
		
		if (!result)
			return;
		
		for (var i : uint, n : uint = result.length; i < n; ++i)
			result[i].assign (condition);
	}
	
	//----------------------------------
	//  setRangeConditionObject
	//----------------------------------
	/**
	 * This method will set the range condition at the specified location to the specified object. 
	 * 
	 * @param location This is a Rectangle object specifying the start coordinates as the x and y values of the rectangle.  The width and height values of the Rectangle specify number of columns or rows to span, respectively.
	 * @param condition This specifies the condition to set at the specified location. 
	 *
	 * @see com.flextras.spreadsheet.vos.Condition
	 */
	// -- JH Suggested Name: setRangeConditionObjectByRectange as it is less ambigious 
	public function setRangeConditionObject (location : Rectangle, condition : Object) : void
	{
		if (!location || !condition)
			return;
		
		setRangeConditionObjectAt (location.x, location.y, location.width, location.height, condition);
	}

	//----------------------------------
	//  setRangeConditionObjectAt
	//----------------------------------
	/** 
	 * This method will set the range condition at the specified location to the specified object.  If rowSpan or columnSpan are greater than 1, then all cells in the area will be given the new condition.
	 * 
	 * @param columnIndex This specifies the integer location of the column to set the condition.  
	 * @param rowIndex This specifies the integer location of the row to set the condition.
	 * @param columnSpan This specifies the number of columns to set.
	 * @param rowSpan This specifies the number of rows to set.
	 * @param condition This specifies the condition to set at the specified location.
	 *
	 */
	public function setRangeConditionObjectAt (columnIndex : uint, rowIndex : uint, columnSpan : int, rowSpan : int, condition : Object) : void
	{
		if (!condition)
			return;
		
		var result : Vector.<Condition> = getRangeConditionsAt (columnIndex, rowIndex, columnSpan, rowSpan);
		
		if (!result)
			return;
		
		for (var i : uint, n : uint = result.length; i < n; ++i)
			result[i].assignObject (condition);
	}
	
	//----------------------------------
	//  getRangeStyles
	//----------------------------------
	
	/**
	 * This method retrieves all the styles in the specified range. 
	 * 
	 * @param location This is a Rectangle object specifying the start coordinates as the x and y values of the rectangle.  The width and height values of the Rectangle specify number of columns or rows to span, respectively.
	 * @return The method returns a vector of CellStyles objects.
	 *
	 *  @see com.flextras.spreadsheet.vos.CellStyles
	 */
	// -- JH Suggested Name: getRangeStylesByRectange as it is less ambigious 
	public function getRangeStyles (location : Rectangle) : Vector.<CellStyles>
	{
		if (!location)
			return null;
		
		return getRangeStylesAt (location.x, location.y, location.width, location.height);
	}
	
	/**
	 * This method retrieves all the styles in the specified range. 
	 * 
	 * @param columnIndex his specifies the integer location of the column to process.  
	 * @param rowIndex This specifies the integer location of the row to process.
	 * @param columnSpan This specifies the number of columns to process.
	 * @param rowSpan This specifies the number of rows to process.
	 * @return The method returns a vector of CellStyles objects.
	 *
	 *  @see com.flextras.spreadsheet.vos.CellStyles
	 */
	public function getRangeStylesAt (columnIndex : uint, rowIndex : uint, columnSpan : uint, rowSpan : uint) : Vector.<CellStyles>
	{
		if (isColumnIndexInvalid (columnIndex)
			|| isRowIndexInvalid (rowIndex)
			|| columnSpan < 0
			|| rowSpan < 0)
			return null;
		
		var result : Vector.<CellStyles> = new Vector.<CellStyles>;
		var c : uint = columnIndex, cs : uint = c + columnSpan;
		var r : uint = rowIndex, rs : uint = r + rowSpan;
		
		for (; c <= cs; ++c)
			for (r = rowIndex; r <= rs; ++r)
				result.push (getCellStylesAt (c, r));
		
		return result;
	}
	
	/**
	 * This method sill set the cell styles in the specified range. 
	 * 
	 * @param location This is a Rectangle object specifying the start coordinates as the x and y values of the rectangle.  The width and height values of the Rectangle specify number of columns or rows to span, respectively.
	 * @param styles This specifies the style object to set.
	 *
	 *  @see com.flextras.spreadsheet.vos.CellStyles
	 */
	// -- JH Suggested Name: setRangeStylesByRectange as it is less ambigious 
	public function setRangeStyles (location : Rectangle, styles : CellStyles) : void
	{
		if (!location || !styles)
			return;
		
		setRangeStylesAt (location.x, location.y, location.width, location.height, styles);
	}
	
	/**
	 * This method sill set the cell styles in the specified range. 
	 *
	 * @param columnIndex This specifies the integer location of the column to process.  
	 * @param rowIndex This specifies the integer location of the row to process.
	 * @param columnSpan This specifies the number of columns to process.
	 * @param rowSpan This specifies the number of rows to process.
	 * @param styles This specifies the style object to set.
	 *
	 */
	public function setRangeStylesAt (columnIndex : uint, rowIndex : uint, columnSpan : uint, rowSpan : uint, styles : CellStyles) : void
	{
		if (!styles)
			return;
		
		var result : Vector.<CellStyles> = getRangeStylesAt (columnIndex, rowIndex, columnSpan, rowSpan);
		
		if (!result)
			return;
		
		for (var i : uint, n : uint = result.length; i < n; ++i)
			result[i].assign (styles);
	}
	
	/**
	 * This method sill set the cell styles in the specified range. 
	 * 
	 * @param location This is a Rectangle object specifying the start coordinates as the x and y values of the rectangle.  The width and height values of the Rectangle specify number of columns or rows to span, respectively.
	 * @param styles This specifies the style object to set.
	 *
	 */
	// -- JH Suggested Name: setRangeStylesObjectByRectange as it is less ambigious 
	public function setRangeStylesObject (location : Rectangle, styles : Object) : void
	{
		if (!location || !styles)
			return;
		
		setRangeStylesObjectAt (location.x, location.y, location.width, location.height, styles);
	}
	
	/**
	 * This method sill set the cell styles in the specified range. 
	 *
	 * @param columnIndex This specifies the integer location of the column to process.  
	 * @param rowIndex This specifies the integer location of the row to process.
	 * @param columnSpan This specifies the number of columns to process.
	 * @param rowSpan This specifies the number of rows to process.
	 * @param styles This specifies the style object to set.
	 *
	 */
	public function setRangeStylesObjectAt (columnIndex : uint, rowIndex : uint, columnSpan : int, rowSpan : int, styles : Object) : void
	{
		if (!styles)
			return;
		
		var result : Vector.<CellStyles> = getRangeStylesAt (columnIndex, rowIndex, columnSpan, rowSpan);
		
		if (!result)
			return;
		
		for (var i : uint, n : uint = result.length; i < n; ++i)
			result[i].assignObject (styles);
	}
	
	//----------------------------------
	//  refresh
	//----------------------------------
	/**
	 * 
	 * This method will force a refresh of all displayed cells during the next render event. 
	 *
	 */
	// ---JH Should this be named invalidateCells ?  For consistenty with the Flex Framework lifecycle approach?  Should this be public? 
	protected function refresh () : void
	{
		cellsChanged = true;
		
		invalidateProperties ();
	}
	
	//----------------------------------
	//  removeCell
	//----------------------------------
	
	/**
	 *  This method will remove a cell at the specified coordinates. 
	 * 
	 * @param columnIndex This specifies the integer location of the column to process.  
	 * @param rowIndex This specifies the integer location of the row to process.
	 *
	 */
	protected function removeCell (columnIndex : uint, rowIndex : uint) : void
	{
		Cell (_cells.removeItemAt (_cells.getItemIndex (getCellAt (columnIndex, rowIndex)))).release ();
	}
	
	//----------------------------------
	//  removeColumn
	//----------------------------------
	
	/**
	 * @private 
	 */
	protected var removeColumnDirty : Boolean;
	
	/**
	 *  @private 
	 */
	//  --JH What is this property used for? 
	protected var removeColumnInfo : Object;
	
	/**
	 * This method will remove columns, at the specified coordinates.
	 * 
	 * @param index This specifies the integer location of the column to remove. 
	 * @param columnIndex This specifies the  number of columns to delete.
	 * @param rowCount This specifies the number of rows to process.
	 *
	 */
	// --JH Why does this method need both columnCount and rowCount?  
	protected function removeColumn (index : uint, columnCount : uint, rowCount : uint) : void
	{
		//--JH Let's make this a cancelable event! 
		if (notifyChildren)
			dispatchEvent (new ColumnEvent (ColumnEvent.BEFORE_REMOVED, index));
		
		// --?? I suggest defining the object type as a non-generic object. 
		removeColumnInfo = {prop: "colIndex", index: index, x: -1, y: 0, exclude: [index, null, null, null]};
		
		for (var i : uint; i < rowCount; ++i)
		{
			if (notifyChildren)
				removeColumnDirty = true;
			
			removeCell (index, i);
		}
	}
	
	//----------------------------------
	//  removeColumnAt
	//----------------------------------
	/**
	 * 
	 * This mehod will dispatch a remove event. 
	 * 
	 * @param index This specifies the integer location of the column to remove. 
	 *
	 */
	 // --JH This method doesn't actually do any removing, it just fires off an event.  Is it not implemented yet?  Or are youe xpecting an event handler to address the remove?  
	public function removeColumnAt (index : uint) : void
	{
		if (isColumnIndexInvalid (index))
			return;
		
		dispatchEvent (new ColumnEvent (ColumnEvent.REMOVE, index));
	}
	
	//----------------------------------
	//  removeRow
	//----------------------------------
	
	/**
	 * @private 
	 */
	protected var removeRowDirty : Boolean;
	
	/**
	 *    --JH What is this property used for? 
	 */
	//    --JH What is this property used for? 
	protected var removeRowInfo : Object;
	
	/**
	 * This method will remove the rows at the specified coordinates.
	 * 
	 * @param index This specifies the integer location of the first row to remove. 
	 * @param columnCount This specifies the  number of columns to process.
	 * @param rowCount This specifies number of rows to process.
	 *
	 */
	//--JH Why does this need a columnCount rowCount?  
	protected function removeRow (index : uint, columnCount : uint, rowCount : uint) : void
	{
		//--JH Let's make this a cancelable event! 
		if (notifyChildren)
			dispatchEvent (new RowEvent (RowEvent.BEFORE_REMOVED, index));
		
		// --?? I suggest defining the object type as a non-generic object. 
		removeRowInfo = {prop: "rowIndex", index: index, x: 0, y: -1, exclude: [null, null, index, null]};
		
		for (var i : uint; i < columnCount; ++i)
		{
			if (notifyChildren)
				removeRowDirty = true;
			
			removeCell (i, index);
		}
	}
	
	//----------------------------------
	//  removeRowAt
	//----------------------------------
	/**
	 * This method will dispatch a remove event. 
	 * 
	 * @param index This method will dispatch a remove event. 
	 *
	 * @see com.flextras.sreadsheet.events.RowEvent
	 * 
	 */
	public function removeRowAt (index : uint) : void
	{
		if (isRowIndexInvalid (index))
			return;
		
		dispatchEvent (new RowEvent (RowEvent.REMOVE, index));
	}
	
	//----------------------------------
	//  resizeCell
	//----------------------------------
	
	/**
	 * This method will resize the cell at the specified location.
	 * 
	 * @param bounds This is a Rectangle object.  The x and y values of the rectangle specify the cell to reize.  The height and width properties of the Rectangle specify new size of the cell.
	 *
	 */
	public function resizeCell (bounds : Rectangle) : void
	{
		if (!bounds)
			return;
		
		resizeCellAt (bounds.x, bounds.y, bounds.width, bounds.height);
	}
	
	//----------------------------------
	//  resizeCellAt
	//----------------------------------
	/**
	 * This method will resize the cells at the specified location.
	 * 
	 * @param columnIndex This specifies the integer location of the column to process.  
	 * @param rowIndex This specifies the integer location of the row to process.
	 * @param columnSpan  This specifies the number of columns to process.
	 * @param rowSpan This specifies the number of rows to process.
	 *
	 */
	public function resizeCellAt (columnIndex : uint, rowIndex : uint, columnSpan : uint = 0, rowSpan : uint = 0) : void
	{
		if (isColumnIndexInvalid (columnIndex) || isRowIndexInvalid (rowIndex))
			return;
		
		dispatchEvent (new CellEvent (CellEvent.RESIZE, new CellEventData (new Rectangle (columnIndex, rowIndex, columnSpan, rowSpan))));
	}
	
	//----------------------------------
	//  getRowHeightAt
	//----------------------------------
	
	// --JH Only properties can be made the source of binding through bindable metadata tag; but this is method, not a property.  To make it Bindable, change it to a get method. Doing that would not give you the ability to pass an argument, though
	// 
	[Bindable(event="rowHeightsChanged")]
	[Bindable(event="preferredRowHeightsChanged")]
	/**
	 * This method gets the row height at the specified index.
	 * 
	 * @param index This specifies the integer location of the row to process.
	 * @return The height of the requested row.
	 *
	 */
	public function getRowHeightAt (index : uint) : Number
	{
		if (isRowIndexInvalid (index))
			return NaN;
		
		var value : Number = _preferredRowHeights[index];
		
		if (isNaN (value))
		{
			if (_rowHeights)
			{
				var rowHeight : CellHeight = _rowHeights[index];
				
				if (rowHeight)
					value = rowHeight.value;
				else
					value = new CellHeight ().value;
			}
			else
				value = new CellHeight ().value;
		}
		
		return value;
	}
	
	//----------------------------------
	//  setRowHeightAt
	//----------------------------------
	/**
	 * This method sets the row height at the specified index.
	 * 
	 * @param index This specifies the integer location of the row to process.
	 * @param value This specifies the new height.
	 *
	 */
	public function setRowHeightAt (index : uint, value : Number) : void
	{
		if (isRowIndexInvalid (index))
			return;
		
		_preferredRowHeights[index] = value;
		
		grid.dataGroup.invalidateDisplayList ();
		
		dispatchEvent (new Event ("preferredRowHeightsChanged"));
	}
	
	//----------------------------------
	//  updateExpressions
	//----------------------------------
	/**
	 * @inheritDoc
	 */
	public function updateExpressions () : void
	{
		expressionsChange = true;
		
		invalidateProperties ();
	}
	
	//--------------------------------------------------------------------------
	//
	//  Event handlers
	//
	//--------------------------------------------------------------------------
	
	//----------------------------------
	//  cells_collectionChangeHandler
	//----------------------------------
	/**
	 * @private
	 * 
	 * This is the default collection change handler for internal cells property.  
	 */
	protected function cells_collectionChangeHandler (e : CollectionEvent) : void
	{
		switch (e.kind)
		{
			case CollectionEventKind.ADD:
				refresh ();
				break;
			
			case CollectionEventKind.MOVE:
				break;
			
			case CollectionEventKind.REFRESH:
				break;
			
			case CollectionEventKind.REMOVE:
				var index : int, cell : Cell;
				
				for (var i : int, n : int = e.items.length; i < n; ++i)
				{
					cell = e.items[i];
					cell.expression = "";
					
					if ((index = expressionTree.indexOf (cell.controlObject)) > -1)
						expressionTree.splice (index, 1);
					
						//if ((index = expressions.getItemIndex(cell.expressionObject)) > -1)
						//	expressions.removeItemAt(index); //expressions.getItemAt(index).expression = "";
				}
				
				refresh ();
				break;
			
			case CollectionEventKind.REPLACE:
				break;
			
			case CollectionEventKind.RESET:
				break;
			
			case CollectionEventKind.UPDATE:
				refresh ();
				break;
		}
	}
	
	//----------------------------------
	//  clearColumnHandler
	//----------------------------------
	/**
	 * @private 
	 */
	protected var clearColumnDirty : Boolean;
	
	/**
	 */
	// --JH What is this used for? 
	protected var clearColumnInfo : Object;
	
	/**
	 * @private 
	 * 
	 * This is the default handler for the ColumnEvent.CLEAR method.
	 * 
	 * @see com.flextras.spreadsheet.events.ColumnEvent
	 * @see com.flextras.spreadsheet.events.ColumnEvent#CLEAR
	 */
	protected function clearColumnHandler (e : ColumnEvent) : void
	{
		if (!e)
			return;
		
		var index : uint = e.index;
		
		if (isColumnIndexInvalid (index))
			return;
		
		if (notifyChildren)
			dispatchEvent (new RowEvent (ColumnEvent.BEFORE_CLEARED, index));
		
		clearColumnInfo = {index: index};
		
		var row : Array = columns[index];
		
		for each (var cell : Cell in row)
		{
			if (notifyChildren)
				clearColumnDirty = true;
			
			cell.clear ();
		}
	}
	
	//----------------------------------
	//  clearRowHandler
	//----------------------------------
	/**
	 * @private 
	 */
	protected var clearRowDirty : Boolean;
	
	/**
	 */
	//  --JH What is this used for? 
	protected var clearRowInfo : Object;
	
	/**
	 * @private
	 * This is the default handler for the RowEvent.CLEAR method.
	 * 
	 * @see com.flextras.spreadsheet.events.RowEvent
	 * @see com.flextras.spreadsheet.events.RowEvent#CLEAR
	 *
	 */
	protected function clearRowHandler (e : RowEvent) : void
	{
		if (!e)
			return;
		
		var index : uint = e.index;
		
		if (isRowIndexInvalid (index))
			return;
		
		if (notifyChildren)
			dispatchEvent (new RowEvent (RowEvent.BEFORE_CLEARED, index));
		
		clearRowInfo = {index: index};
		
		var column : Array = rows[index];
		
		for each (var cell : Cell in column)
		{
			if (notifyChildren)
				clearRowDirty = true;
			
			cell.clear ();
		}
	}
	

	
	
	//----------------------------------
	//  expressionsChangeHandler
	//----------------------------------	
	
	/**
	 * @private
	 */
	// --JH What is this for?  
	private var expCE : CollectionEvent;
	
	/**
	 * @private
	 * The default handler for expression change events.  
	 */
	protected function expressionsChangeHandler (e : CollectionEvent) : void
	{
		var items : Array;
		
		if (e.kind == CollectionEventKind.REMOVE)
			items = e.items;
		
		if (e.kind == CollectionEventKind.RESET)
			items = _expressions.source;
		
		for each (var item : Object in items)
			if (item.hasOwnProperty ("reference"))
				Cell (item.reference).expressionObject = null;
		
		expCE = e;
		updateExpressions ();
		
		dispatchEvent (new Event ("expressionsChange"));
	}
	
	//----------------------------------
	//  insertColumnHandler
	//----------------------------------	
	/**
	 * @private 
	 * 
	 * This is the default handler for the ColumnEvent.INSERT method.
	 * 
	 * @see com.flextras.spreadsheet.events.ColumnEvent
	 * @see com.flextras.spreadsheet.events.ColumnEvent#INSERT
	 */
	protected function insertColumnHandler (e : ColumnEvent) : void
	{
		if (!e)
			return;
		
		var index : uint = e.index;
		
		if (isColumnIndexInvalid (index))
			return;
		
		addColumn (index, _columnCount, _rowCount);
		
		var array : Array = [], i : int;
		
		for (var k : String in _preferredColumnWidths)
		{
			i = parseInt (k);
			
			if (!isNaN (i))
			{
				if (i >= index)
					array[i + 1] = _preferredColumnWidths[i];
				else
					array[i] = _preferredColumnWidths[i];
			}
		}
		
		_preferredColumnWidths = array;
		
		oldColumnCount = ++columnCount;
	}
	
	//----------------------------------
	//  insertRowHandler
	//----------------------------------	
	/**
	 * @private 
	 * 
	 * This is the default handler for the RowEvent.INSERT method.
	 * 
	 * @see com.flextras.spreadsheet.events.ColumnEvent
	 * @see com.flextras.spreadsheet.events.ColumnEvent#INSERT
	 */
	protected function insertRowHandler (e : RowEvent) : void
	{
		if (!e)
			return;
		
		var index : uint = e.index;
		
		if (isRowIndexInvalid (index))
			return;
		
		addRow (index, _columnCount, _rowCount);
		
		var array : Array = [], i : int;
		
		for (var k : String in _preferredRowHeights)
		{
			i = parseInt (k);
			
			if (!isNaN (i))
			{
				if (i >= index)
					array[i + 1] = _preferredRowHeights[i];
				else
					array[i] = _preferredRowHeights[i];
			}
		}
		
		_preferredRowHeights = array;
		
		oldRowCount = ++rowCount;
	}
	
	//----------------------------------
	//  keyDownHandler
	//----------------------------------	
	/**
	 * @private 
	 * 
	 * This is the default handler for the key dowm event of spreadsheet cells
	 */
	override protected function keyDownHandler (event : KeyboardEvent) : void
	{
		if (event.ctrlKey && event.shiftKey && String.fromCharCode (event.charCode) == "r")
		{
			if (!shiftActive)
			{
				shiftActive = true;
				
				ResizeManager.dispatcher.dispatchEvent (new Event (ResizeManager.SHOW_HANDLERS));
			}
			else
			{
				shiftActive = false;
				
				ResizeManager.dispatcher.dispatchEvent (new Event (ResizeManager.HIDE_HANDLERS));
			}
		}
	}
	
	//----------------------------------
	//  onCalcError
	//----------------------------------	
	/**
	 * @private 
	 * 
	 * This is the default handler for calc errors.  It just redispatches the event.
	 */
	protected function onCalcError (event : SpreadsheetEvent) : void
	{
		this.dispatchEvent (event);
	}
	
	//----------------------------------
	//  onCalcError
	//----------------------------------	
	/**
	 * @private 
	 * 
	 * This is the default handler for calc warnings.  It just redispatches the event.
	 */
	protected function onCalcWarning (event : SpreadsheetEvent) : void
	{
		this.dispatchEvent (event);
	}
	
	//----------------------------------
	//  removeColumnHandler
	//----------------------------------	
	/**
	 * @private 
	 * 
	 * This is the default handler for the ColumnEvent.REMOVE method.
	 * 
	 * @see com.flextras.spreadsheet.events.ColumnEvent
	 * @see com.flextras.spreadsheet.events.ColumnEvent#REMOVE
	 */
	protected function removeColumnHandler (e : ColumnEvent) : void
	{
		if (!e)
			return;
		
		var index : uint = e.index;
		
		if (isColumnIndexInvalid (index))
			return;
		
		removeColumn (index, _columnCount, _rowCount);
		
		var array : Array = [], i : int;
		
		for (var k : String in _preferredColumnWidths)
		{
			i = parseInt (k);
			
			if (!isNaN (i))
			{
				if (i > index)
					array[i - 1] = _preferredColumnWidths[i];
				else
					array[i] = _preferredColumnWidths[i];
			}
		}
		
		_preferredColumnWidths = array;
		
		oldColumnCount = --columnCount;
	}
	
	//----------------------------------
	//  removeRowHandler
	//----------------------------------	
	/**
	 * @private 
	 */
	// --JH What is this for? 
	protected var info : Object;
	
	/**
	 * @private 
	 * 
	 * This is the default handler for the RowEvent.REMOVE method.
	 * 
	 * @see com.flextras.spreadsheet.events.RowEvent
	 * @see com.flextras.spreadsheet.events.RowEvent#REMOVE
	 */
	protected function removeRowHandler (e : RowEvent) : void
	{
		if (!e)
			return;
		
		var index : uint = e.index;
		
		if (isRowIndexInvalid (index))
			return;
		
		removeRow (index, _columnCount, _rowCount);
		
		var array : Array = [], i : int;
		
		for (var k : String in _preferredRowHeights)
		{
			i = parseInt (k);
			
			if (!isNaN (i))
			{
				if (i > index)
					array[i - 1] = _preferredRowHeights[i];
				else
					array[i] = _preferredRowHeights[i];
			}
		}
		
		_preferredRowHeights = array;
		
		oldRowCount = --rowCount;
	}
	
	//----------------------------------
	//  resizeCellHandler
	//----------------------------------	
	/**
	 * @private 
	 * This is the default handler for the CellEvent.RESIZE event.
	 * 
	 * @see com.flextras.spreadsheet.events.CellEvent
	 * @see com.flextras.spreadsheet.events.CellEvent#RESIZE
	 */
	protected function resizeCellHandler (e : CellEvent) : void
	{
		if (!e || !e.data)
			return;
		
		var amount : Rectangle = e.data.resizeAmount;
		
		if (isColumnIndexInvalid (amount.x) || isRowIndexInvalid (amount.y))
			return;
		
		var cell : Cell = getCellAt (amount.x, amount.y);
		
		notifyChildren = false;
		
		if (cell.bounds.right + 1 > _columnCount)
			columnCount = cell.bounds.right + 1;
		
		if (cell.bounds.bottom + 1 > _rowCount)
			rowCount = cell.bounds.bottom + 1;
		
		doSort = true;
		
		refresh ();
	}
	
	//----------------------------------
	//  resizeColumnHandler
	//----------------------------------	
	/**
	 * @private 
	 * 
	 * This is the default handler for the ColumnEvent.RESIZE method.
	 * 
	 * @see com.flextras.spreadsheet.events.ColumnEvent
	 * @see com.flextras.spreadsheet.events.ColumnEvent#RESIZE
	 */
	protected function resizeColumnHandler (e : ColumnEvent) : void
	{
	
	}
	
	//----------------------------------
	//  resizeRowHandler
	//----------------------------------	
	/**
	 * @private 
	 * 
	 * This is the default handler for the RowEvent.RESIZE method.
	 * 
	 * @see com.flextras.spreadsheet.events.ColumnEvent
	 * @see com.flextras.spreadsheet.events.ColumnEvent#RESIZE
	 */
	protected function resizeRowHandler (e : RowEvent) : void
	{
	
	}
}
}