package com.flextras.spreadsheet
{
import com.flextras.calc.Calc;
import com.flextras.calc.Utils;
import com.flextras.spreadsheet.components.GridList;
import com.flextras.spreadsheet.core.spreadsheet;
import com.flextras.spreadsheet.events.CellEvent;
import com.flextras.spreadsheet.events.ColumnEvent;
import com.flextras.spreadsheet.events.RowEvent;
import com.flextras.spreadsheet.events.SpreadsheetEvent;
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
import mx.core.EventPriority;
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
 * @copy ColumnEvent#INSERT
 * @eventType com.flextras.spreadsheet.events.ColumnEvent.INSERT
 */
[Event(name="insertColumn", type="com.flextras.spreadsheet.events.ColumnEvent")]

/**
 * @copy ColumnEvent#REMOVE
 * @eventType com.flextras.spreadsheet.events.ColumnEvent.REMOVE
 */
[Event(name="removeColumn", type="com.flextras.spreadsheet.events.ColumnEvent")]

/**
 * @copy ColumnEvent#CLEAR
 * @eventType com.flextras.spreadsheet.events.ColumnEvent.CLEAR
 */
[Event(name="clearColumn", type="com.flextras.spreadsheet.events.ColumnEvent")]

/**
 * @copy ColumnEvent#INSERTED
 * @eventType com.flextras.spreadsheet.events.ColumnEvent.INSERTED
 */
[Event(name="columnInserted", type="com.flextras.spreadsheet.events.ColumnEvent")]

/**
 * @copy ColumnEvent#REMOVED
 * @eventType com.flextras.spreadsheet.events.ColumnEvent.REMOVED
 */
[Event(name="columnRemoved", type="com.flextras.spreadsheet.events.ColumnEvent")]

/**
 * @copy ColumnEvent#CLEARED
 * @eventType com.flextras.spreadsheet.events.ColumnEvent.CLEARED
 */
[Event(name="columnCleared", type="com.flextras.spreadsheet.events.ColumnEvent")]

/**
 * @copy RowEvent#INSERT
 * @eventType com.flextras.spreadsheet.events.RowEvent.INSERT
 */
[Event(name="insertRow", type="com.flextras.spreadsheet.events.RowEvent")]

/**
 * @copy RowEvent#REMOVE
 * @eventType com.flextras.spreadsheet.events.RowEvent.REMOVE
 */
[Event(name="removeRow", type="com.flextras.spreadsheet.events.RowEvent")]

/**
 * @copy RowEvent#CLEAR
 * @eventType com.flextras.spreadsheet.events.RowEvent.CLEAR
 */
[Event(name="clearRow", type="com.flextras.spreadsheet.events.RowEvent")]

/**
 * @copy RowEvent#INSERTED
 * @eventType com.flextras.spreadsheet.events.RowEvent.INSERTED
 */
[Event(name="rowInserted", type="com.flextras.spreadsheet.events.RowEvent")]

/**
 * @copy RowEvent#REMOVED
 * @eventType com.flextras.spreadsheet.events.RowEvent.REMOVED
 */
[Event(name="rowRemoved", type="com.flextras.spreadsheet.events.RowEvent")]

/**
 * @copy RowEvent#CLEARED
 * @eventType com.flextras.spreadsheet.events.RowEvent.CLEARED
 */
[Event(name="rowCleared", type="com.flextras.spreadsheet.events.RowEvent")]

/**
 * Dispatched when cells property gets changed.
 * @eventType "cellsChanged"
 */
[Event(name="cellsChanged", type="flash.events.Event")]

/**
 * Dispatched when calc property gets changed.
 * @eventType "calcChanged"
 */
[Event(name="calcChanged", type="flash.events.Event")]

/**
 * Dispatched when cellField property gets changed.
 * @eventType "cellFieldChanged"
 */
[Event(name="cellFieldChanged", type="flash.events.Event")]

/**
 * Dispatched when cellFunction property gets changed.
 * @eventType "cellFunctionChanged"
 */
[Event(name="cellFunctionChanged", type="flash.events.Event")]

/**
 * Dispatched when columnCount property gets changed.
 * @eventType "columnCountChanged"
 */
[Event(name="columnCountChanged", type="flash.events.Event")]

/**
 * Dispatched when columnWidths property gets changed.
 * @eventType "columnWidthsChanged"
 */
[Event(name="columnWidthsChanged", type="flash.events.Event")]

/**
 * Dispatched when disabledCells property gets changed.
 * @eventType "disabledCellsChanged"
 */
[Event(name="disabledCellsChanged", type="flash.events.Event")]

/**
 * Dispatched when expressionField property gets changed.
 * @eventType "expressionFieldChanged"
 */
[Event(name="expressionFieldChanged", type="flash.events.Event")]

/**
 * Dispatched when expressionFunction property gets changed.
 * @eventType "expressionFunctionChanged"
 */
[Event(name="expressionFunctionChanged", type="flash.events.Event")]

/**
 * Dispatched when globalStyles property gets changed.
 * @eventType "globalStylesChanged"
 */
[Event(name="globalStylesChanged", type="flash.events.Event")]

/**
 * Dispatched when rowCount property gets changed.
 * @eventType "rowCountChanged"
 */
[Event(name="rowCountChanged", type="flash.events.Event")]

/**
 * Dispatched when rowHeights property gets changed.
 * @eventType "rowHeightsChanged"
 */
[Event(name="rowHeightsChanged", type="flash.events.Event")]

/**
 * Dispatched when startRowIndex property gets changed.
 * @eventType "startRowIndexChanged"
 */
[Event(name="startRowIndexChanged", type="flash.events.Event")]

/**
 * Dispatched when preferredColumnWidths property gets changed.
 * @eventType "preferredColumnWidthsChanged"
 */
[Event(name="preferredColumnWidthsChanged", type="flash.events.Event")]

/**
 * Dispatched when selectedIndex property gets changed.
 * @eventType "selectedIndexChanged"
 */
[Event(name="selectedIndexChanged", type="flash.events.Event")]

/**
 * Dispatched when selectedIndices property gets changed.
 * @eventType "selectedIndicesChanged"
 */
[Event(name="selectedIndicesChanged", type="flash.events.Event")]

/**
 * Dispatched when expressions property gets changed.
 * @eventType com.flextras.spreadsheet.events.SpreadsheetEvent.EXPRESSIONS_CHANGE
 */
[Event(name="expressionsChange", type="com.flextras.spreadsheet.events.SpreadsheetEvent")]

/**
 * Dispatched after expressions property gets changed and processed.
 * @eventType com.flextras.spreadsheet.events.SpreadsheetEvent.EXPRESSIONS_CHANGED
 */
[Event(name="expressionsChanged", type="com.flextras.spreadsheet.events.SpreadsheetEvent")]

/**
 * Dispatched after clearExpressions method is called and expressions cleared.
 * @eventType com.flextras.spreadsheet.events.SpreadsheetEvent.EXPRESSIONS_CLEARED
 */
[Event(name="expressionsCleared", type="com.flextras.spreadsheet.events.SpreadsheetEvent")]

/**
 * Redispatched from Calc.
 * @eventType com.flextras.spreadsheet.events.SpreadsheetEvent.ERROR
 */
[Event(name="error", type="com.flextras.spreadsheet.events.SpreadsheetEvent")]

/**
 * Redispatched from Calc.
 * @eventType com.flextras.spreadsheet.events.SpreadsheetEvent.WARNING
 */
[Event(name="warning", type="com.flextras.spreadsheet.events.SpreadsheetEvent")]

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
 * @example
 *  <listing version="3.0">
 * &lt;spreadsheet:Spreadsheet id = "grid"&gt;
 *		&lt;s:ArrayCollection&gt;
 *			&lt;fx:Object cell = "a1"
 *					   expression = "=5+5" /&gt;
 *
 *			&lt;fx:Object cell = "b1"
 *					   expression = "=5+5" /&gt;
 *
 *			&lt;fx:Object cell = "c1"
 *					   expression = "=5+5" /&gt;
 *
 *			&lt;fx:Object cell = "d1"
 *					   expression = "=5+5" /&gt;
 *		&lt;/s:ArrayCollection&gt;
 *	&lt;/spreadsheet:Spreadsheet&gt;
 *  </listing>
 *
 * @includeExample SpreadsheetExample.txt
 * @includeExample SpreadsheetExample.mxml
 *
 * @see com.flextras.calc.Calc
 * @see com.flextras.spreadsheet.ISpreadsheet
 */
//--JH To access cells you seem to use alot of different methods.  Sometimes it is the string (A1).  
// Sometimes it seems to be point objects and other times it seems to be rectangle objects. 
// We should be more consistent; either in always accessing cells using the same method or consistently supporting all methods
// for example there is no 'setCellStylesByID method, but there is a setCellStyles [by point] and setCellStylesAt which uses specific coordinates

//--AB There are different "cell objects" in the spreadsheet, we have:
// - expressionObjects - these are anonymous objects passed through "expressions" dataprovider
// - Cell - these are objects autogenerated objects for representing the visual state of cells
// - ControlObject - these are used by Calc to calculate values for Cell objects
// Hence this API seems somewhat confusing. If we need to clear it out, please take above into consideration
// Regarding styling, this is all explained in the comments of every particular function.

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
		
		addEventListener (CellEvent.RESIZE, resizeCellHandler, false, EventPriority.DEFAULT_HANDLER);
		
		addEventListener (ColumnEvent.INSERT, insertColumnHandler, false, EventPriority.DEFAULT_HANDLER);
		addEventListener (ColumnEvent.REMOVE, removeColumnHandler, false, EventPriority.DEFAULT_HANDLER);
		addEventListener (ColumnEvent.CLEAR, clearColumnHandler, false, EventPriority.DEFAULT_HANDLER);
		
		addEventListener (RowEvent.INSERT, insertRowHandler, false, EventPriority.DEFAULT_HANDLER);
		addEventListener (RowEvent.REMOVE, removeRowHandler, false, EventPriority.DEFAULT_HANDLER);
		addEventListener (RowEvent.CLEAR, clearRowHandler, false, EventPriority.DEFAULT_HANDLER);
		
		cells.addEventListener (CollectionEvent.COLLECTION_CHANGE, cells_collectionChangeHandler);
		
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
			
			for (var i : uint = oldColumnCount; i < columnCount; ++i)
				addColumn (i, oldRowCount);
			
			for (i = oldColumnCount; i > columnCount; --i)
				removeColumn (i - 1, oldRowCount);
			
			oldColumnCount = columnCount;
		}
		
		if (rowCountChanged)
		{
			rowCountChanged = false;
			
			for (i = oldRowCount; i < rowCount; ++i)
				addRow (i, oldColumnCount);
			
			for (i = oldRowCount; i > rowCount; --i)
				removeRow (i - 1, oldColumnCount);
			
			oldRowCount = rowCount;
		}
		
		if (cellsChanged)
		{
			cellsChanged = false;
			
			if (doSort)
			{
				doSort = false;
				
				cells.refresh ();
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
			elementIndex = {};
			
			var x : Number, y : Number;
			i = 0;
			
			for (var c : uint, n : uint = cells.length, cell : Cell; c < n; ++c)
			{
				cell = Cell (cells.getItemAt (c));
				
				column = columns[cell.bounds.x] || [];
				row = rows[cell.bounds.y] || [];
				
				column.push (cell);
				row.push (cell);
				
				columns[cell.bounds.x] = column;
				rows[cell.bounds.y] = row;
				
				indexedCells[cell.bounds.x + "|" + cell.bounds.y] = cell;
				
				ctrlObjects[cell.controlObject.id] = cell.controlObject;
				
				if (!spans[cell.bounds.y] || !spans[cell.bounds.y][cell.bounds.x])
				{
					for (y = cell.bounds.y; y <= cell.bounds.bottom; ++y)
					{
						rowSpan = spans[y] || [];
						
						for (x = cell.bounds.x; x <= cell.bounds.right; ++x)
						{
							rowSpan[x] = cell;
							
							elementIndex[x + "|" + y] = i;
						}
						
						spans[y] = rowSpan;
					}
					
					ids[i] = cell.columnIndex + "|" + cell.rowIndex;
					
					uniqueCells.push (cell);
					++i;
				}
			}
			
			dispatchEvent (new Event ("cellsChanged"));
			
			grid.dataProvider = new ArrayCollection (uniqueCells);
		}
		
		if (expressionsChanged)
		{
			expressionsChanged = false;
			
			var e : SpreadsheetEvent;
			
			c = 0;
			
			/*if (expCE.kind == "invalidateCells")
			   {
			   // iterate through _expressions
			 }*/
			
			var o : Object, id : String, indexes : Array, columnIndex : int, rowIndex : int;
			
			var expression:String;
			
			if (expressions)
				while (c < expressions.length)
				{
					o = expressions.getItemAt (c);
					
					id = itemToCell (o).toLowerCase ();
					o[cellField] = id;
					
					indexes = Utils.gridFieldToIndexes (id);
					
					columnIndex = indexes[0];
					rowIndex = indexes[1];
					
					if (isColumnIndexInvalid (columnIndex) || isRowIndexInvalid (rowIndex))
					{
						e = new SpreadsheetEvent (SpreadsheetEvent.WARNING);
						e.message = id + " out of column or row bounds on Spreadsheet " + this.id;
						this.dispatchEvent (e);
						
						++c;
						continue;
					}
					
					//should be more robust
					if (id.indexOf ("!") > -1)
					{
						e = new SpreadsheetEvent (SpreadsheetEvent.WARNING);
						e.message = id + " - cell ignored due to incorect id";
						this.dispatchEvent (e);
						
						++c;
						continue;
					}
					
					cell = getCellAt (columnIndex, rowIndex);
					
					//if (!cell)
					//	continue;
					
					expression = itemToExpression (o);
					
					if (!expression || expression == "")
					{
						if (expressionTree.indexOf (cell.controlObject) > -1)
							calc.assignControlExpression (cell.controlObject, "");
						
						expressions.removeItemAt (c);
						
						cell.expressionObject = null;
					}
					else
					{
						cell.expressionObject = o;
						
						//calc.assignControlExpression(cell.controlObject, cell.expression || "", expressionTree.indexOf(cell.controlObject) > -1);
						calc.assignControlExpression (cell.controlObject, cell.expression || "");
						c++;
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
			
			dispatchEvent (new ColumnEvent (ColumnEvent.INSERTED, addColumnIndex));
		}
		
		if (addRowDirty)
		{
			addRowDirty = false;
			
			dispatchEvent (new RowEvent (RowEvent.INSERTED, addRowIndex));
		}
		
		if (columnRemovedirty)
		{
			columnRemovedirty = false;
			
			dispatchEvent (new ColumnEvent (ColumnEvent.REMOVED, removeColumnIndex));
		}
		
		if (rowRemovedirty)
		{
			rowRemovedirty = false;
			
			dispatchEvent (new RowEvent (RowEvent.REMOVED, removeRowIndex));
		}
		
		if (clearColumnDirty)
		{
			clearColumnDirty = false;
			
			dispatchEvent (new ColumnEvent (ColumnEvent.CLEARED, clearColumnIndex));
		}
		
		if (clearRowDirty)
		{
			clearRowDirty = false;
			
			dispatchEvent (new RowEvent (RowEvent.CLEARED, clearRowIndex));
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
		
		if (!calc)
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
			//grid.dataProvider = cells;
			
			grid.scroller.verticalScrollBar.addEventListener (FlexEvent.VALUE_COMMIT, function (e : FlexEvent) : void
			{
				rowHeader.scroller.verticalScrollBar.value = e.currentTarget.value;
			});
			
			grid.scroller.horizontalScrollBar.addEventListener (FlexEvent.VALUE_COMMIT, function (e : FlexEvent) : void
			{
				columnHeader.scroller.horizontalScrollBar.value = e.currentTarget.value;
			});
			
			grid.addEventListener ("selectedIndexChanged", selectionChangedHandler);
			grid.addEventListener ("selectedIndicesChanged", selectionChangedHandler);
			grid.addEventListener ("selectedItemChanged", selectionChangedHandler);
			grid.addEventListener ("selectedItemsChanged", selectionChangedHandler);
			
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
			grid.removeEventListener ("selectedIndexChanged", selectionChangedHandler);
			grid.removeEventListener ("selectedIndicesChanged", selectionChangedHandler);
			grid.removeEventListener ("selectedItemChanged", selectionChangedHandler);
			grid.removeEventListener ("selectedItemsChanged", selectionChangedHandler);
		}
	}
	
	//--------------------------------------------------------------------------
	//
	//  Skin Parts
	//
	//--------------------------------------------------------------------------
	
	// --JH Is there a columnHeaderRenderer and/or rowHeaderRenderer ? 
	// --JH I strongly recommend turning these skin parts into get set methods; as get/set methods can be extended, properties can't.
	
	// --AB This is I believe the way Adobe intended to support skinning 
	// --AB If you want to change skins you should create your own SpreadsheetSkin.mxml and simply assign it to Spreadsheet.skinClass (with setStyle from AS)
	
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
	// --AB yes, it is used in renderers this way, we need to have properties bindable
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
	 * @private
	 */
	// ---JH add some documentation for this property ----
	// --AB these should all be marked as @private in ASDoc, these are not important or ready for public API
	protected var doSort : Boolean;
	
	/**
	 *  @private
	 */
	// ---JH add some documentation for this property ----
	protected var shiftActive : Boolean;
	
	/**
	 *  @private
	 */
	//---JH add some documentation for this property ----
	spreadsheet var columns : Array;
	
	/**
	 *  @private
	 */
	// ---JH add some documentation for this property ----
	spreadsheet var rows : Array;
	
	/**
	 * @private
	 */
	private var elementIndex : Object;
	
	/**
	 * @private
	 */
	private var ids : Array;
	
	/**
	 * @private
	 */
	protected var addColumnDirty : Boolean;
	
	/**
	 * @private
	 */
	// ---JH add documentation for this property 
	protected var addColumnIndex : uint;
	
	/**
	 * @private
	 */
	// ---JH add some documentation for this property ----
	protected var addRowDirty : Boolean;
	
	/**
	 * @private
	 */
	// ---JH add some documentation for this property ----
	protected var addRowIndex : uint;
	
	/**
	 * @private
	 */
	// ---JH It is unusual to put a variable in the 'methods' section ----
	// ---AB already moved
	protected var clearExpressionsDirty : Boolean;
	
	/**
	 * @private
	 */
	protected var columnRemovedirty : Boolean;
	
	/**
	 * @private
	 */
	//  --JH What is this property used for? 
	// --AB this is internal for removing the column, when the event is dispatched this is set, on commitProperties this is used
	protected var removeColumnIndex : uint;
	
	/**
	 * @private
	 */
	protected var rowRemovedirty : Boolean;
	
	/**
	 *    --JH What is this property used for?
	 * @private
	 */
	//    --JH What is this property used for? 
	// --AB this is internal for removing the row, when the event is dispatched this is set, on commitProperties this is used
	protected var removeRowIndex : uint;
	
	/**
	 * @private
	 */
	protected var clearColumnDirty : Boolean;
	
	/**
	 *  @private
	 */
	// --JH What is this used for? 
	// --AB this is internal for clearing the column, when the event is dispatched this is set, on commitProperties this is used
	protected var clearColumnIndex : uint;
	
	/**
	 * @private
	 */
	protected var clearRowDirty : Boolean;
	
	/**
	 * @private
	 */
	//  --JH What is this used for? 
	// --AB this is internal for clearing the row, when the event is dispatched this is set, on commitProperties this is used
	protected var clearRowIndex : uint;
	
	/**
	 * @private
	 */
	// --JH What is this for?  
	// --AB will be used in future for optimization in commitProperties
	//private var expCE : CollectionEvent;
	
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
	private var _calc : Calc;
	
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
		if (calc === value)
			return;
		
		if (calc)
		{
			calc.removeEventListener (SpreadsheetEvent.ERROR, onCalcError);
			calc.removeEventListener (SpreadsheetEvent.WARNING, onCalcWarning);
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
	private var _cellField : String = "cell";
	
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
		if (cellField == value)
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
	private var _cellFunction : Function;
	
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
	 *  <listing version="3.0">mycellFunction(item:Object):String</listing>
	 *
	 * @default null
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
		if (cellFunction === value)
			return;
		
		_cellFunction = value;
		
		dispatchEvent (new Event ("cellFunctionChanged"));
	}
	
	//----------------------------------
	//  cells
	//----------------------------------
	
	/**
	 * @private
	 */
	// ---JH Why is this a const? Constants are usually non-changing, but you do change this array in other spots of this component ----
	// ---AB Not a const anymore
	private var _cells : ArrayCollection = new ArrayCollection;
	
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
	 * @private
	 */
	// ---JH add some documentation for this property ----
	// --AB internal property, not important for developer. Could be marked as @private
	protected var oldColumnCount : uint;
	
	/**
	 * @private
	 */
	private var _columnCount : uint = 10;
	
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
		if (value < 0 || columnCount == value)
			return;
		
		_columnCount = value;
		columnCountChanged = true;
		
		dispatchEvent (new Event ("columnCountChanged"));
		
		invalidateProperties ();
	}
	
	//----------------------------------
	//  columnWidths
	//----------------------------------
	
	/**
	 * @private
	 */
	private var _columnWidths : Array;
	
	/**
	 * @private
	 */
	// ---JH add some documentation for this property; why is it a constant if you're going to be changing it? ----
	// --AB internal for columnHeader and layout, should be marked @private
	private var columnWidthsCollection : ArrayCollection = new ArrayCollection;
	
	[Bindable(event="columnWidthsChanged")]
	/**
	 * This property contains an array of all the column widths.
	 */
	// ---JH Do we want to document the spreadsheet namespace? ----
	// --AB internal use only within Spreadheet package
	spreadsheet function get columnWidths () : Array
	{
		return _columnWidths;
	}
	
	/**
	 * @private
	 */
	spreadsheet function set columnWidths (value : Array) : void
	{
		if (columnWidths === value)
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
	private var _ctrlObjects : Object = {};
	
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
	private var _disabledCells : Vector.<Cell>;
	
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
		if (disabledCells === value)
			return;
		
		if (disabledCells)
			for (var i : uint, n : uint = disabledCells.length; i < n; ++i)
				disabledCells[i].enabled = true;
		
		_disabledCells = value;
		
		if (disabledCells)
			for (i = 0, n = disabledCells.length; i < n; ++i)
				disabledCells[i].enabled = false;
		
		dispatchEvent (new Event ("disabledCellsChanged"));
	}
	
	//----------------------------------
	//  expressionField
	//----------------------------------
	
	/**
	 * @private
	 */
	private var _expressionField : String = "expression";
	
	[Bindable(event="expressionFieldChanged")]
	/**
	 * The name of the field in the data provider items used to determine the object’s expression.
	 *
	 * By default the list looks for a property named <code>expression</code> each item and uses that to determine the value, and formula used on the spreadsheet.
	 *
	 * However, if the data objects do not contain an <code>expression</code> property, you can set the <code>expressionField</code> property to use a different property in the data object.
	 *
	 * @return Field name that contains the expression.
	 *
	 */
	// --JH What can we say about the value of the expression field? 
	// --AB Whatever, user can choose to have 'exp' or whatever as the property name for expression
	public function get expressionField () : String
	{
		return _expressionField;
	}
	
	/**
	 * @private
	 */
	public function set expressionField (value : String) : void
	{
		if (expressionField == value)
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
	private var _expressionFunction : Function;
	
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
	 *  <listing version="3.0">myExpressionFunction(item:Object):String</listing>
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
		if (expressionFunction === value)
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
	private var _expressions : ArrayCollection;
	
	/**
	 * @private
	 */
	private var oldExpressions : Array = [];
	
	/**
	 * @private
	 */
	protected var expressionsChanged : Boolean;
	
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
		if (expressions === value)
			return;
		
		if (expressions)
		{
			oldExpressions = expressions.source.concat ();
			//expressions.removeAll(); //replace with reset
			expressions.dispatchEvent (new CollectionEvent (CollectionEvent.COLLECTION_CHANGE, false, false, CollectionEventKind.RESET));
			
			expressions.removeEventListener (CollectionEvent.COLLECTION_CHANGE, expressionsChangeHandler);
		}
		
		_expressions = value || new ArrayCollection;
		
		if (expressions)
		{
			expressions.addEventListener (CollectionEvent.COLLECTION_CHANGE, expressionsChangeHandler);
			
			expressions.refresh ();
				//invalidateExpressions ();
		}
	}
	
	//----------------------------------
	//  expressionTree
	//----------------------------------
	
	/**
	 * @private
	 */
	private var _expressionTree : Array = [];
	
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
	// --AB yes, this is part of above globalStyles property, additional setter
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
	//  id
	//----------------------------------
	
	/**
	 * @private
	 */
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
	private var _indexedCells : Object;
	
	/**
	 * @private
	 */
	// ---JH add some documentation for this property ----
	// --AB this is @private
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
	private var _preferredColumnWidths : Array = [];
	
	[Bindable(event="preferredColumnWidthsChanged")]
	/**
	 * @private
	 */
	// ---JH add some documentation for this property ----
	// --AB this is private for now, could become feature in next releases
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
	private var _preferredRowHeights : Array = [];
	
	[Bindable(event="preferredRowHeightsChanged")]
	/**
	 */
	// ---JH add some documentation for this property ----
	// --AB this is private for now, could become feature in next releases
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
	// --AB internal use only, for calculations when rows get inserted, deleted, etc.
	protected var oldRowCount : uint;
	
	/**
	 * @private
	 */
	private var _rowCount : uint = 10;
	
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
		if (value < 0 || rowCount == value)
			return;
		
		_rowCount = value;
		rowCountChanged = true;
		
		dispatchEvent (new Event ("rowCountChanged"));
		
		invalidateProperties ();
	}
	
	//----------------------------------
	//  rowHeights
	//----------------------------------
	
	/**
	 * @private
	 */
	private var _rowHeights : Array;
	
	/**
	 * @private
	 */
	// ---JH add some documentation for this property; why is it a constant if you're going to be changing it? ----
	// --AB internal, not a constant anymore
	private var rowHeightsCollection : ArrayCollection = new ArrayCollection;
	
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
		if (rowHeights === value)
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
	private var _spans : Array;
	
	/**
	 * This property contains information for all cells that span multiple rows or columns.
	 * @private
	 */
	// ---JH add some documentation for this property; be sure to specify what object is expected in the array ----
	// --AB this is not yet complete and cannot be released but it's used ineternally now
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
	private var _startRowIndex : uint = 1;
	
	[Bindable(event="startRowIndexChanged")]
	/**
	 * Specifies how to start counting rows.
	 * By default the spreadsheet starts with 1, e.g. A1, B1, etc.
	 * You can change the default behavior by setting this property to any positive integer or zero.
	 * E.g.: startRowIndex = 0, will render the table as A0, A1,... B0, B1,...
	 * If you change this, you have to take this into account when constructing expressions.
	 *
	 * @return Integer by which you want to start indexing rows.
	 */
	// --JH Add some documentation for this property  
	// --AB added
	public function get startRowIndex () : uint
	{
		return _startRowIndex;
	}
	
	/**
	 * @private
	 */
	public function set startRowIndex (value : uint) : void
	{
		if (startRowIndex == value)
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
	private var _uniqueCells : Array;
	
	/**
	 * @private
	 */
	//---JH add some documentation for this property; be sure to specify what object is expected in the array ----
	// --AB internal, not visible in public API
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
	 * @private
	 */
	// ---JH How does adding a cell with this method affect rows and columns?  Is it like an insert or a replace? ----
	// --AB internal
	protected function addCell (columnIndex : uint, rowIndex : uint) : void
	{
		var cell : Cell = new Cell (this, new Rectangle (columnIndex, rowIndex + startRowIndex));
		cell.globalStyles = globalCell.styles;
		
		cells.addItem (cell);
	}
	
	//----------------------------------
	//  addColumn
	//----------------------------------
	
	/**
	 * This method will add a column into the spreadsheet at the specified location.
	 *
	 * @param index
	 * @param columnCount
	 * @param rowCount
	 *
	 * @private
	 */
	// ---JH Define the arguments, as it is not obvious to me what they mean. ----
	// ---JH I assume dding a column will shift other columns, correct? ----
	// --AB internal, public is insertColumnAt
	protected function addColumn (index : uint, rowCount : uint) : void
	{
		// --JH document this object; possibly turning it into a VO
		addColumnIndex = index;
		
		for (var i : uint; i < rowCount; ++i)
			addCell (index, i);
	}
	
	//----------------------------------
	//  addRow
	//----------------------------------
	
	/**
	 * This method will add a row into the spreadsheet at the specified location.
	 *
	 * @param index
	 * @param columnCount
	 * @param rowCount
	 *
	 * @private
	 */
	// ---JH Define the arguments, as it is not obvious to me what they mean. ----
	// ---JH I assume adding a row will shift other rows, correct? ----
	// --AB internal, public is insertRowAt
	protected function addRow (index : uint, columnCount : uint) : void
	{
		// --JH Document this object; possibly turning it into a VO
		// --AB no need to turn int into VO
		addRowIndex = index;
		
		for (var i : uint; i < columnCount; ++i)
			addCell (i, index);
	}
	
	//----------------------------------
	//  assignExpression
	//----------------------------------
	
	/**
	 * This method will add a single expression to the cell at the specified location.
	 * If an expression already exists at the specified cell location, then it will be replaced.
	 *
	 * @example
	 * <listing version="3.0">grid.assignExpression ("a0", "=5+5");</listing>
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
				
				expressions.itemUpdated (o);
			}
		}
		else if (expression && expression.length > 0)
		{
			o = {value: ""};
			o[cellField] = cellId;
			o[expressionField] = expression;
			
			expressions.addItem (o);
		}
	}
	
	//----------------------------------
	//  assignExpressions
	//----------------------------------
	
	/**
	 * Each object in the expressions array should include a cell property to specify the location and an expression property to specify the new expression.
	 *
	 * @example
	 * <listing version="3.0">grid.assignExpressions ([{cell:"a0", expression="=5+5"}]);</listing>
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
		for (var i : uint, n : uint = expressions.length, expression : Object; i < n; ++i)
		{
			expression = expressions.getItemAt (i);
			
			this.assignExpression (itemToCell (expression), itemToExpression (expression));
		}
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
		
		for (var i : uint, n : uint = expressions.length, expression : Object; i < n; ++i)
		{
			expression = expressions.getItemAt (i);
			
			if (itemToCell (expression) == cellId)
				return expression;
		}
		
		return null;
	}
	
	//----------------------------------
	//  getCellAt
	//----------------------------------
	/**
	 * This method retrieves the cell based on the specified coordinates.
	 *
	 * @example
	 * <listing version="3.0">var cell:Cell = grid.getCellAt (0, 0);</listing>
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
		
		return indexedCells[columnIndex + "|" + rowIndex];
	}
	
	//----------------------------------
	//  getCellByPoint
	//----------------------------------
	
	/**
	 * This method retrieves the cell based on the given Point object.
	 *
	 * @example
	 * <listing version="3.0">var cell:Cell = grid.getCellByPoint (new Point(0, 0));</listing>
	 *
	 * @param location A point that specifies the location of the cell to retrieve.
	 * @return An object representing the cell.
	 *
	 * @see com.flextras.vos.Cell
	 *
	 */
	// ---JH Suggested Name:  getCellByPoint; it is less ambigious ----
	// ---JH Should we consider using Point objects internally instead of the "a1" syntax? ----
	// ---AB changed as suggested. There is another method that uses "a1" syntax
	public function getCellByPoint (location : Point) : Cell
	{
		if (!location)
			return null;
		
		return getCellAt (location.x, location.y);
	}
	
	//----------------------------------
	//  getCellById
	//----------------------------------
	/**
	 * This method retrieves the cell based on the specified coordinates.
	 *
	 * @example
	 * <listing version="3.0">var cell:Cell = grid.getCellById ("a0");</listing>
	 *
	 * @param value This specifies the ID of the cell to retrieve.
	 *
	 * @return This method returns the cell that exists at the specified location.  If no cell exists at the specified location, then null is returned.
	 *
	 */
	// --JH What is the value argument?  The Cell location "A1"  OR something different? 
	// --AB yes, it's "a1", "B3", etc
	public function getCellById (value : String) : Cell
	{
		// -- JH what happens if there are more than 26 columns? 
		// --AB this will be expanded to unlimeted, now is 75. Or should we limit the size?
		if (!value || value.length != 2)
			return null;
		
		var id : Array = Utils.gridFieldToIndexes (value);
		var columnIndex : int = id[0];
		var rowIndex : int = id[1];
		
		return getCellAt (columnIndex, rowIndex);
	}
	
	//----------------------------------
	//  getCellConditionAt
	//----------------------------------
	/**
	 * This method retrieves the condition object of the cell located at the given coordinates.
	 *
	 * @example
	 * <listing version="3.0">var condition:Condition = grid.getCellConditionAt (0, 0);</listing>
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
	//  getCellConditionByPoint
	//----------------------------------
	
	/**
	 *  This method retrieves the condition object of the cell located at the given point.
	 *
	 * @example
	 * <listing version="3.0">var condition:Condition = grid.getCellConditionByPoint (new Point(0, 0));</listing>
	 *
	 * @param location A point that specifies the location of the cell, whose condition the method will retrieve.
	 * @return  An object representing the cell.
	 *
	 * @see com.flextras.vos.Condition
	 *
	 */
	//  --JH Suggested name: getCellConditionByPoint as it is less ambigious 
	// --AB changed as suggested
	public function getCellConditionByPoint (location : Point) : Condition
	{
		if (!location)
			return null;
		
		return getCellConditionAt (location.x, location.y);
	}
	
	//----------------------------------
	//  setCellConditionAt
	//----------------------------------
	/**
	 * This method sets the condition object of the cell located at the given columnIndex and rowIndex.
	 * This method will override all the previously set properties to the new properties in condition Condition.
	 * Those not set in condition paramater will override with default values.
	 *
	 * @example
	 * <listing version="3.0">grid.setCellConditionAt (0, 0, new Condition(5, ">", 4));</listing>
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
	//  setCellConditionByPoint
	//----------------------------------
	/**
	 * This method sets the condition object of the cell located at the given Point.
	 * This method will override all the previously set properties to the new properties in condition Condition.
	 * Those not set in condition paramater will override with default values.
	 *
	 * @example
	 * <listing version="3.0">grid.setCellConditionByPoint (new Point(0, 0), new Condition(5, ">", 4));</listing>
	 *
	 * @param location A point that specifies the location of the cell, whose condition the method will retrieve.
	 * @param condition This property specifies the new Condition.
	 *
	 *
	 * @see com.flextras.vos.Condition
	 */
	//  --JH Suggested name: setCellConditionByPoint as it is less ambigious
	// --AB changed as suggested
	public function setCellConditionByPoint (location : Point, condition : Condition) : void
	{
		if (!location || !condition)
			return;
		
		setCellConditionAt (location.x, location.y, condition);
	}
	
	//----------------------------------
	//  setCellConditionObjectAt
	//----------------------------------
	/**
	 * This method sets the condition object of the cell located at the given coordinates.
	 * This method allows you to modify only those properties that are specified in condition Object.
	 *
	 * @example
	 * <listing version="3.0">grid.setCellConditionObjectAt (0, 0, {operator:">", right:4});</listing>
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
	//  setCellConditionObjectByPoint
	//----------------------------------
	/**
	 * This method sets the condition object of the cell located at the given Point.
	 * This method allows you to modify only those properties that are specified in condition Object.
	 *
	 * @example
	 * <listing version="3.0">grid.setCellConditionObjectByPoint (new Point(0, 0), {operator:">", right:4});</listing>
	 *
	 * @param location A point that specifies the location of the cell, whose condition the method will retrieve.
	 * @param condition This property specifies the new Condition.
	 *
	 * @see com.flextras.vos.Condition
	 *
	 */
	// --JH I'm not sure why these 'object' methods are needed or used. When will you use a genericObject instead of a Condition Object?
	// --JH Suggested name: setCellConditionObjectByPoint as it is less ambigious 
	// --AB name changed as suggested
	// --AB these "object" param functions were added as convenience methods. They could be deleted accross the board, what do you suggest?
	// --ML These methods should stay. If user wants to change only choosen styles he can do that through these methods.
	//      Every "Object" method also accepts instance of appropriate Class (in this case Condition) - if this is the case it will override all existing styles
	//      (the same goes for all other methods which aren't containing "Object" word).
	public function setCellConditionObjectByPoint (location : Point, condition : Object) : void
	{
		if (!location || !condition)
			return;
		
		setCellConditionObjectAt (location.x, location.y, condition);
	}
	
	//----------------------------------
	//  getCellStylesAt
	//----------------------------------
	/**
	 * This method returns the cellStyles at the specified coordinates.
	 *
	 * @example
	 * <listing version="3.0">var cellStyles:CellStyles = grid.getCellStylesAt (0, 0);</listing>
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
	//  getCellStylesByPoint
	//----------------------------------
	/**
	 * This method returns the cellStyles at the specified point.
	 *
	 * @example
	 * <listing version="3.0">var cellStyles:CellStyles = grid.getCellStylesByPoint (new Point(0, 0));</listing>
	 *
	 * @param location A point that specifies the location of the cell, whose styles the method will process.
	 * @return An object representing the cell’s styles.
	 *
	 * @see com.flextras.vos.CellStyles
	 *
	 */
	//  --JH Suggested name: getCellStylesByPoint as it is less ambigious 
	// --AB changed as suggested
	public function getCellStylesByPoint (location : Point) : CellStyles
	{
		if (!location)
			return null;
		
		return getCellStylesAt (location.x, location.y);
	}
	
	//----------------------------------
	//  setCellStylesAt
	//----------------------------------
	/**
	 * This method sets the cellStyles at the specified coordinates.
	 * This method will override all the previously set properties to the new properties in styles CellStyles.
	 * Those not set in condition paramater will override with default values.
	 *
	 * @example
	 * <listing version="3.0">grid.setCellStylesAt (0, 0, new CellStyles(0xFF0000));</listing>
	 *
	 * @param columnIndex This specifies the columnIndex of the cell whose styles the method will process.
	 * @param rowIndex This specifies the rowIndex of the cell whose styles the method will process.
	 * @param styles An object representing the cell’s styles.
	 *
	 * @mxml
	 *
	 *  <listing version="3.0">
	 * &lt;spreadsheet:Spreadsheet id = "sheet"&gt;
	 *		&lt;s:ArrayCollection&gt;
	 *			&lt;fx:Object cell = "a1"
	 *					   expression = "=5+5" /&gt;
	 *
	 *			&lt;fx:Object cell = "b1"
	 *					   expression = "=5+5" /&gt;
	 *
	 *			&lt;fx:Object cell = "c1"
	 *					   expression = "=5+5" /&gt;
	 *
	 *			&lt;fx:Object cell = "d1"
	 *					   expression = "=5+5" /&gt;
	 *		&lt;/s:ArrayCollection&gt;
	 *	&lt;/spreadsheet:Spreadsheet&gt;
	 *  </listing>
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
	//  setCellStylesByPoint
	//----------------------------------
	/**
	 * This method set the cellStyles at the specified point.
	 * This method will override all the previously set properties to the new properties in styles CellStyles.
	 * Those not set in condition paramater will override with default values.
	 *
	 * @example
	 * <listing version="3.0">grid.setCellStylesByPoint (new Point(0, 0), new CellStyles(0xFF0000));</listing>
	 *
	 * @param location A point that specifies the location of the cell, whose styles the method will process.
	 * @param styles An object representing the cell’s styles.
	 *
	 * @see com.flextras.vos.CellStyles
	 *
	 */
	//  --JH Suggested name: setCellStylesByPoint as it is less ambigious 
	// --AB changed as suggested
	public function setCellStylesByPoint (location : Point, styles : CellStyles) : void
	{
		if (!location || !styles)
			return;
		
		setCellStylesAt (location.x, location.y, styles);
	}
	
	//----------------------------------
	//  setCellStylesObjectAt
	//----------------------------------
	/**
	 * This method sets the cellStyles at the specified coordinates.
	 * This method allows you to modify only those properties that are specified in styles Object.
	 *
	 * @example
	 * <listing version="3.0">grid.setCellStylesObjectAt (6, 0, {bold: true, backgroundColor: 0xFFFF00});</listing>
	 *
	 * @param columnIndex This specifies the columnIndex of the cell whose styles the method will process.
	 * @param rowIndex This specifies the rowIndex of the cell whose styles the method will process.
	 * @param styles An object representing the cell’s styles.
	 *
	 * @see com.flextras.vos.CellStyles
	 *
	 */
	//  --JH Why would we need to support a generic object as opposed to a specific CellStyles instance?
	// --AB this is commented already in the functions with generic vs value objects as parameters, for example setCellConditionObjectByPoint
	public function setCellStylesObjectAt (columnIndex : uint, rowIndex : uint, styles : Object) : void
	{
		if (isColumnIndexInvalid (columnIndex) || isRowIndexInvalid (rowIndex) || !styles)
			return;
		
		getCellAt (columnIndex, rowIndex).stylesObject = styles;
	}
	
	//----------------------------------
	//  setCellStylesObjectByPoint
	//----------------------------------
	/**
	 * This method sets the cellStyles at the specified Point.
	 * This method allows you to modify only those properties that are specified in styles Object.
	 *
	 * @example
	 * <listing version="3.0">grid.setCellStylesObjectByPoint (new Point(6, 0), {bold: true, backgroundColor: 0xFFFF00});</listing>
	 *
	 * @param location A point that specifies the location of the cell, whose styles the method will process.
	 * @param styles An object representing the cell’s styles.
	 *
	 * @see com.flextras.vos.CellStyles
	 * @see #setCellStyles
	 *
	 */
	//  --JH Suggested name: setCellStylesObjectByPoint as it is less ambigious 
	// --JH Why would we need to support a generic object as opposed to a specific CellStyles instance? 
	// --AB name changed as suggested
	// --AB this is commented already in the functions with generic vs value objects as parameters, for example setCellConditionObjectByPoint
	public function setCellStylesObjectByPoint (location : Point, styles : Object) : void
	{
		if (!location || !styles)
			return;
		
		setCellStylesObjectAt (location.x, location.y, styles);
	}
	
	//----------------------------------
	//  clearCellAt
	//----------------------------------
	/**
	 * This method will clear all the cells properties at the specified coordinates.
	 *
	 * @example
	 * <listing version="3.0">grid.clearCell (6, 1);</listing>
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
	//  clearCellByPoint
	//----------------------------------
	
	/**
	 * This method will clear all the cells properties at the specified location.
	 *
	 * @example
	 * <listing version="3.0">grid.clearCellByPoint (new Point(6, 1));</listing>
	 *
	 * @param location A point that specifies the location of the cell to clear.
	 *
	 */
	//  --JH Suggested name: clearCellByPoint as it is less ambigious 
	// --AB changed as suggested
	public function clearCellByPoint (location : Point) : void
	{
		if (!location)
			return;
		
		clearCellAt (location.x, location.y);
	}
	
	//----------------------------------
	//  clearColumnAt
	//----------------------------------
	/**
	 * This method clears data and formulas from all cells in the specified column.
	 *
	 * @example
	 * <listing version="3.0">grid.clearColumnAt (1);</listing>
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
	 * This method removes all previously defined expressions.
	 */
	// ---JH add some documentation for this method; should it really be public if it will not be documented? ----
	// --JH If this deletes all expressions; should it really be public?  
	// --AB it is the purpose of this method to provide functionality of clearing all expressions, it also dispathes an event
	public function clearExpressions () : void
	{
		clearExpressionsDirty = true;
		
		oldExpressions = expressions.source.concat ();
		expressions.removeAll ();
	}
	
	//----------------------------------
	//  clearRowAt
	//----------------------------------
	
	/**
	 * This method clears data and formulas from all cells in the specified row.
	 *
	 * @example
	 * <listing version="3.0">grid.clearRowAt (1);</listing>
	 *
	 * @param index This specifies the index of the row  to clear.
	 *
	 *  before the work is done.
	 */
	// --JH This appears to dispatch an event, but doesn't do any of the 'row clearing' work.  Which is a bit odd to dispatch an event
	// --AB this will become cancelable at some point
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
	 * @example
	 * <listing version="3.0">var columnWidth:Number = grid.getColumnWidthAt (1);</listing>
	 *
	 * @param index This specifies the index of the column.
	 * @return This returns the column width.
	 */
	public function getColumnWidthAt (index : uint) : Number
	{
		if (isColumnIndexInvalid (index))
			return NaN;
		
		var value : Number = preferredColumnWidths[index];
		
		if (isNaN (value))
		{
			if (columnWidths)
			{
				var columnWidth : CellWidth = columnWidths[index];
				
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
	 * @example
	 * <listing version="3.0">grid.setColumnWidthAt (1, 200);</listing>
	 *
	 * @param index This specifies the index of the column.
	 * @param value This specifies the new width of the column.
	 */
	public function setColumnWidthAt (index : uint, value : Number) : void
	{
		if (isColumnIndexInvalid (index))
			return;
		
		preferredColumnWidths[index] = value;
		
		grid.dataGroup.invalidateDisplayList ();
		
		dispatchEvent (new Event ("preferredColumnWidthsChanged"));
	}
	
	//----------------------------------
	//  getElementIndex
	//----------------------------------	
	
	/**
	 * This method returns the index of the element at the specified coordinates.
	 *
	 * @param columnIndex This specifies the columnIndex of the cell to be processed.
	 * @param rowIndex This specifies the rowIndex the cell to be processed.
	 * @return The element at the specified index.  If no element exists, -1 is returned.
	 */
	// -- JH What is an element in this case?  A cell?  Or something else?  this is a bit confusing 
	// --AB internal
	spreadsheet function getElementIndex (columnIndex : uint, rowIndex : int) : int
	{
		var index : Object = elementIndex[columnIndex + "|" + rowIndex];
		
		return index == null ? -1 : int (index);
	}
	
	//----------------------------------
	//  invalidateCells
	//----------------------------------
	/**
	 * This method will force a invalidateCells of all displayed cells during the next render event.
	 */
	// ---JH Should this be named invalidateCells ?  For consistenty with the Flex Framework lifecycle approach?  Should this be public?
	// --AB changed as suggested
	public function invalidateCells () : void
	{
		cellsChanged = true;
		
		invalidateProperties ();
	}
	
	//----------------------------------
	//  invalidateExpressions
	//----------------------------------
	/**
	 * @inheritDoc
	 */
	public function invalidateExpressions () : void
	{
		expressionsChanged = true;
		
		invalidateProperties ();
	}
	
	//----------------------------------
	//  getIdByIndex
	//----------------------------------	
	
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
	 */
	protected function isColumnIndexInvalid (value : uint) : Boolean
	{
		return value < 0 || value >= columnCount;
	}
	
	//----------------------------------
	//  isRowIndexInvalid
	//----------------------------------	
	/**
	 * This method verifies that the specified value represents a valid row index.
	 *
	 * @param value This specifies the index to validate.
	 * @return This method returns true if the specified index is valid, or false if not.
	 */
	protected function isRowIndexInvalid (value : uint) : Boolean
	{
		return value < 0 || value >= rowCount;
	}
	
	//----------------------------------
	//  insertColumnAt
	//----------------------------------
	
	/**
	 * This method creates a new column at the specified index.
	 *
	 * @example
	 * <listing version="3.0">grid.insertColumnAt (1);</listing>
	 *
	 * @param index This specifies the location to create a new column
	 */
	// -- JH It is a bit weird that this dispatches an event, ut does nothing else.  Events are good for things like this
	// but usually to inform the user that something happened, not that is going to happen.  It is possible a user's listener 
	// will fire before your own listener; causing confusion
	// --AB this will become cancelable at some point, there are other events to inform user of what and when is happening
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
	 * @example
	 * <listing version="3.0">grid.insertRowAt (1);</listing>
	 *
	 * @param index This specifies the location to create a new row.
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
	 * @param value This specifics the object from your dataProvider.
	 * @return A String representing the cell.  The string will be in the format "[column index in alphabetical form][row index in numerical form]".  "a1" for example points to column 0 and row 1.
	 */
	// ---JH What happens if the object has no cellField property?  This method should handle tat, either by throwing an error / returning an null / or returning the first "unusd" cell ----
	// ---AB It will throw an error here, because cellField is null
	public function itemToCell (value : Object) : String
	{
		if (cellFunction != null)
			return cellFunction (value);
		
		return value[cellField];
	}
	
	//----------------------------------
	//  itemToExpression
	//----------------------------------
	
	/**
	 * This method accepts an object from your dataProvider and returns a string representing that object's expression.
	 *
	 * @param value This specifics the object from your dataProvider.
	 * @return A String representing the object's expression.
	 */
	// ---JH What happens if the object has no expressionField property?  This method should handle that, either by throwing an error / returning an null / or returning an empty string / or???  ----
	// ---AB It will throw an error here, because expressionField is null
	public function itemToExpression (value : Object) : String
	{
		if (expressionFunction != null)
			return expressionFunction (value);
		
		return value[expressionField];
	}
	
	//----------------------------------
	//  selectedIndex
	//----------------------------------
	
	[Bindable(event="selectedIndexChanged")]
	/**
	 * @copy spark.components.supportClasses.ListBase#selectedIndex
	 */
	public function get selectedIndex () : int
	{
		return grid.selectedIndex;
	}
	
	/**
	 * @private
	 */
	public function set selectedIndex (value : int) : void
	{
		grid.selectedIndex = value;
		
		dispatchEvent (new Event ("selectedIndexChanged"));
	}
	
	//----------------------------------
	//  selectedIndices
	//----------------------------------
	
	[Bindable(event="selectedIndicesChanged")]
	/**
	 * @copy spark.components.List#selectedIndices
	 */
	public function get selectedIndices () : Vector.<int>
	{
		return grid.selectedIndices;
	}
	
	/**
	 * @private
	 */
	public function set selectedIndices (value : Vector.<int>) : void
	{
		grid.selectedIndices = value;
		
		dispatchEvent (new Event ("selectedIndicesChanged"));
	}
	
	//----------------------------------
	//  selectedItem
	//----------------------------------
	
	[Bindable(event="selectedItemChanged")]
	/**
	 * @copy spark.components.supportClasses.ListBase#selectedItem
	 */
	public function get selectedItem () : Cell
	{
		return grid.selectedItem;
	}
	
	/**
	 * @private
	 */
	public function set selectedItem (value : Cell) : void
	{
		grid.selectedItem = value;
		
		dispatchEvent (new Event ("selectedItemChanged"));
	}
	
	//----------------------------------
	//  selectedItems
	//----------------------------------
	
	[Bindable(event="selectedItemsChanged")]
	/**
	 * @copy spark.components.List#selectedItems
	 */
	public function get selectedItems () : Vector.<Cell>
	{
		return Vector.<Cell> (grid.selectedItems);
	}
	
	/**
	 * @private
	 */
	public function set selectedItems (value : Vector.<Cell>) : void
	{
		grid.selectedItems = Vector.<Object> (value);
		
		dispatchEvent (new Event ("selectedItemsChanged"));
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
	 * @see com.flextras.spreadsheet.vos.MoveOptions
	 */
	// ---JH Not sure what the options argument is --
	// --ML MoveOptions class now contains documentation.
	// ---JH What happens if the Vector does not contain contiguous cells??  For example A1 and B12
	// --AB it would move them by dx and dy based on the distnce between A1 and Point, i.e. the top left most cell determines how entire Vector will be moved
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
	
	/**
	 * This method will return a group of cells that represent the specified coordinates.
	 *
	 * @example
	 * <listing version="3.0">var cells:Vector.&lt;Cell> = grid.getCellsInRangeAt (1, 1, 4, 4);</listing>
	 *
	 * @param columnIndex This specifies the integer location of the column to start the cell retrieval.
	 * @param rowIndex This specifies the integer location of the row to start the cell retrieval.
	 * @param columnSpan This specifies the number of columns to retrieve.
	 * @param rowSpan This specifies the number of rows to retrieve.
	 *
	 * @return This method returns a Vector of the cells at the location specified.
	 */
	public function getCellsInRangeAt (columnIndex : uint, rowIndex : uint, columnSpan : uint, rowSpan : uint) : Vector.<Cell>
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
	//  getCellsInRangeByRectangle
	//----------------------------------
	
	/**
	 * This method will return a group of cells based on the data in the specified Rectangle.
	 *
	 * @example
	 * <listing version="3.0">var cells:Vector.&lt;Cell> = grid.getCellsInRangeByRectangle (new Rectangle(1, 1, 4, 4));</listing>
	 *
	 * @param location This is a Rectangle object specifying the start coordinates as the x and y values of the rectangle.  The width and height values of the Rectangle specify number of columns or rows to span, respectively.
	 * @return This method returns a Vector of the cells at the location specified.
	 */
	// -- JH Suggested Name: getCellsInRangeByRectange as it is less ambigious 
	public function getCellsInRangeByRectange (location : Rectangle) : Vector.<Cell>
	{
		if (!location)
			return null;
		
		return getCellsInRangeAt (location.x, location.y, location.width, location.height);
	}
	
	//----------------------------------
	//  getCellsConditionsInRangeAt
	//----------------------------------
	/**
	 * This method will return a group of range conditions that exist at the specified coordinates.
	 *
	 * @example
	 * <listing version="3.0">var conditions:Vector.&lt;Condition> = grid.getCellsConditionsInRangeAt (1, 1, 4, 4);</listing>
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
	// --AB Conditions are as styles, e.g. if a1>4 it should be red. This methods returns all of these objects for the cells within the range
	public function getCellsConditionsInRangeAt (columnIndex : uint, rowIndex : uint, columnSpan : uint, rowSpan : uint) : Vector.<Condition>
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
	//  getCellsConditionsInRangeByRectange
	//----------------------------------
	
	/**
	 * This method will return a group of range conditions that exist at the specified coordinates.
	 *
	 * @example
	 * <listing version="3.0">var conditions:Vector.&lt;Condition> = grid.getCellsConditionsInRangeByRectangle (new Rectangle(1, 1, 4, 4));</listing>
	 *
	 * @param location This is a Rectangle object specifying the start coordinates as the x and y values of the rectangle.  The width and height values of the Rectangle specify number of columns or rows to span, respectively.
	 *
	 * @return This method returns a Vector of the condition that exist at the location specified.
	 *
	 * @see com.flextras.spreadsheet.vos.Condition
	 */
	// ---JH I'm unclear what Range Conditions are  ----
	// -- JH Suggested Name: getCellsConditionsInRangeByRectange as it is less ambigious 
	// --AB name changed as suggested
	// --AB Conditions are as styles, e.g. if a1>4 it should be red. This methods returns all of these objects for the cells within the range
	public function getCellsConditionsInRangeByRectange (location : Rectangle) : Vector.<Condition>
	{
		if (!location)
			return null;
		
		return getCellsConditionsInRangeAt (location.x, location.y, location.width, location.height);
	}
	
	//----------------------------------
	//  setCellsConditionsInRangeAt
	//----------------------------------
	/**
	 * This method will set the range condition at the specified location.
	 * This method will override all the previously set properties to the new properties in condition Condition.
	 * Those not set in condition paramater will override with default values.
	 *
	 * @example
	 * <listing version="3.0">grid.setCellsConditionsInRangeAt (1, 1, 4, 4, new Condition(5, ">", 4));</listing>
	 *
	 * @param columnIndex specifies the integer location of the column to set the condition.
	 * @param rowIndex This specifies the integer location of the row to set the condition.
	 * @param columnSpan This specifies the number of columns to set.
	 * @param rowSpan This specifies the number of rows to set.
	 * @param condition This specifies the condition to set at the specified location.
	 *
	 * @see com.flextras.spreadsheet.vos.Condition
	 */
	public function setCellsConditionsInRangeAt (columnIndex : uint, rowIndex : uint, columnSpan : uint, rowSpan : uint, condition : Condition) : void
	{
		if (!condition)
			return;
		
		var result : Vector.<Condition> = getCellsConditionsInRangeAt (columnIndex, rowIndex, columnSpan, rowSpan);
		
		if (!result)
			return;
		
		for (var i : uint, n : uint = result.length; i < n; ++i)
			result[i].assign (condition);
	}
	
	//----------------------------------
	//  setCellsConditionsInRangeByRectangle
	//----------------------------------
	/**
	 * This method will set the range condition at the specified location.
	 * This method will override all the previously set properties to the new properties in condition Condition.
	 * Those not set in condition paramater will override with default values.
	 *
	 * @example
	 * <listing version="3.0">grid.setCellsConditionsInRangeByRectangle (new Rectangle(1, 1, 4, 4), new Condition(5, ">", 4));</listing>
	 *
	 * @param location This is a Rectangle object specifying the start coordinates as the x and y values of the rectangle.  The width and height values of the Rectangle specify number of columns or rows to span, respectively.
	 * @param condition
	 *
	 * @see com.flextras.spreadsheet.vos.Condition
	 */
	// -- JH Suggested Name: setCellsConditionsInRangeByRectange as it is less ambigious 
	// --AB name changed as suggested
	public function setCellsConditionsInRangeByRectangle (location : Rectangle, condition : Condition) : void
	{
		if (!location || !condition)
			return;
		
		setCellsConditionsInRangeAt (location.x, location.y, location.width, location.height, condition);
	}
	
	//----------------------------------
	//  setCellsConditionsInRangeObjectAt
	//----------------------------------
	/**
	 * This method will set the range condition at the specified location to the specified object.  If rowSpan or columnSpan are greater than 1, then all cells in the area will be given the new condition.
	 * This method allows you to modify only those properties that are specified in condition Object.
	 *
	 * @example
	 * <listing version="3.0">grid.setCellsConditionsInRangeObjectAt (1, 1, 4, 4, {operator:">", right:4});</listing>
	 *
	 * @param columnIndex This specifies the integer location of the column to set the condition.
	 * @param rowIndex This specifies the integer location of the row to set the condition.
	 * @param columnSpan This specifies the number of columns to set.
	 * @param rowSpan This specifies the number of rows to set.
	 * @param condition This specifies the condition to set at the specified location.
	 */
	public function setCellsConditionsInRangeObjectAt (columnIndex : uint, rowIndex : uint, columnSpan : int, rowSpan : int, condition : Object) : void
	{
		if (!condition)
			return;
		
		var result : Vector.<Condition> = getCellsConditionsInRangeAt (columnIndex, rowIndex, columnSpan, rowSpan);
		
		if (!result)
			return;
		
		for (var i : uint, n : uint = result.length; i < n; ++i)
			result[i].assignObject (condition);
	}
	
	//----------------------------------
	//  setCellsConditionsInRangeObjectByRectangle
	//----------------------------------
	/**
	 * This method will set the range condition at the specified location to the specified object.
	 * This method allows you to modify only those properties that are specified in condition Object.
	 *
	 * @example
	 * <listing version="3.0">grid.setCellsConditionsInRangeObjectByRectangle (new Rectangle(1, 1, 4, 4), {operator:">", right:4});</listing>
	 *
	 * @param location This is a Rectangle object specifying the start coordinates as the x and y values of the rectangle.  The width and height values of the Rectangle specify number of columns or rows to span, respectively.
	 * @param condition This specifies the condition to set at the specified location.
	 *
	 * @see com.flextras.spreadsheet.vos.Condition
	 */
	// -- JH Suggested Name: setCellsConditionsInRangeObjectByRectange as it is less ambigious 
	// --AB name changed as suggested
	public function setCellsConditionsInRangeObjectByRectangle (location : Rectangle, condition : Object) : void
	{
		if (!location || !condition)
			return;
		
		setCellsConditionsInRangeObjectAt (location.x, location.y, location.width, location.height, condition);
	}
	
	//----------------------------------
	//  getCellsStylesInRangeAt
	//----------------------------------
	
	/**
	 * This method retrieves all the styles in the specified range.
	 *
	 * @example
	 * <listing version="3.0">var styles:Vector.&lt;CellStyles> = grid.getCellsStylesInRangeAt (1, 1, 4, 4);</listing>
	 *
	 * @param columnIndex his specifies the integer location of the column to process.
	 * @param rowIndex This specifies the integer location of the row to process.
	 * @param columnSpan This specifies the number of columns to process.
	 * @param rowSpan This specifies the number of rows to process.
	 * @return The method returns a vector of CellStyles objects.
	 *
	 * @see com.flextras.spreadsheet.vos.CellStyles
	 */
	public function getCellsStylesInRangeAt (columnIndex : uint, rowIndex : uint, columnSpan : uint, rowSpan : uint) : Vector.<CellStyles>
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
	
	//----------------------------------
	//  getCellsStylesInRangeByRectange
	//----------------------------------
	
	/**
	 * This method retrieves all the styles in the specified range.
	 *
	 * @example
	 * <listing version="3.0">var styles:Vector.&lt;CellStyles> = grid.getCellsStylesInRangeByRectange (new Rectangle(1, 1, 4, 4));</listing>
	 *
	 * @param location This is a Rectangle object specifying the start coordinates as the x and y values of the rectangle.  The width and height values of the Rectangle specify number of columns or rows to span, respectively.
	 * @return The method returns a vector of CellStyles objects.
	 *
	 *  @see com.flextras.spreadsheet.vos.CellStyles
	 */
	// -- JH Suggested Name: getCellsStylesInRangeByRectange as it is less ambigious 
	// --AB name changed as suggested
	public function getCellsStylesInRangeByRectange (location : Rectangle) : Vector.<CellStyles>
	{
		if (!location)
			return null;
		
		return getCellsStylesInRangeAt (location.x, location.y, location.width, location.height);
	}
	
	//----------------------------------
	//  setCellsStylesInRangeAt
	//----------------------------------
	
	/**
	 * This method will set the cell styles in the specified range.
	 *
	 * @example
	 * <listing version="3.0">grid.setCellsStylesInRangeAt (1, 1, 4, 4, new CellStyles(0xFF0000));</listing>
	 *
	 * @param columnIndex This specifies the integer location of the column to process.
	 * @param rowIndex This specifies the integer location of the row to process.
	 * @param columnSpan This specifies the number of columns to process.
	 * @param rowSpan This specifies the number of rows to process.
	 * @param styles This specifies the style object to set.
	 */
	public function setCellsStylesInRangeAt (columnIndex : uint, rowIndex : uint, columnSpan : uint, rowSpan : uint, styles : CellStyles) : void
	{
		if (!styles)
			return;
		
		var result : Vector.<CellStyles> = getCellsStylesInRangeAt (columnIndex, rowIndex, columnSpan, rowSpan);
		
		if (!result)
			return;
		
		for (var i : uint, n : uint = result.length; i < n; ++i)
			result[i].assign (styles);
	}
	
	//----------------------------------
	//  setCellsStylesInRangeByRectange
	//----------------------------------
	
	/**
	 * This method will set the cell styles in the specified range.
	 * This method will override all the previously set properties to the new properties in styles CellStyles.
	 * Those not set in condition paramater will override with default values.
	 *
	 * @example
	 * <listing version="3.0">grid.setCellsStylesInRangeByRectangle (new Rectangle(1, 1, 4, 4), new CellStyles(0xFF0000));</listing>
	 *
	 * @param location This is a Rectangle object specifying the start coordinates as the x and y values of the rectangle.  The width and height values of the Rectangle specify number of columns or rows to span, respectively.
	 * @param styles This specifies the style object to set.
	 *
	 * @see com.flextras.spreadsheet.vos.CellStyles
	 */
	// -- JH Suggested Name: setCellsStylesInRangeByRectange as it is less ambigious 
	// --AB name changed as suggested
	public function setCellsStylesInRangeByRectangle (location : Rectangle, styles : CellStyles) : void
	{
		if (!location || !styles)
			return;
		
		setCellsStylesInRangeAt (location.x, location.y, location.width, location.height, styles);
	}
	
	//----------------------------------
	//  setCellsStylesObjectInRangeAt
	//----------------------------------
	
	/**
	 * This method will set the cell styles in the specified range.
	 * This method allows you to modify only those properties that are specified in styles Object.
	 *
	 * @example
	 * <listing version="3.0">grid.setCellsStylesObjectInRangeAt (0, 0, 6, 0, {bold: true, backgroundColor: 0xCC99FF});</listing>
	 *
	 * @param columnIndex This specifies the integer location of the column to process.
	 * @param rowIndex This specifies the integer location of the row to process.
	 * @param columnSpan This specifies the number of columns to process.
	 * @param rowSpan This specifies the number of rows to process.
	 * @param styles This specifies the style object to set.
	 *
	 */
	public function setCellsStylesObjectInRangeAt (columnIndex : uint, rowIndex : uint, columnSpan : int, rowSpan : int, styles : Object) : void
	{
		if (!styles)
			return;
		
		var result : Vector.<CellStyles> = getCellsStylesInRangeAt (columnIndex, rowIndex, columnSpan, rowSpan);
		
		if (!result)
			return;
		
		for (var i : uint, n : uint = result.length; i < n; ++i)
			result[i].assignObject (styles);
	}
	
	//----------------------------------
	//  setCellsStylesObjectInRangeByRectangle
	//----------------------------------
	
	/**
	 * This method will set the cell styles in the specified range.
	 * This method allows you to modify only those properties that are specified in styles Object.
	 *
	 * @example
	 * <listing version="3.0">grid.setCellsStylesObjectInRangeByRectangle (new Rectangle(0, 0, 6, 0), {bold: true, backgroundColor: 0xCC99FF});</listing>
	 *
	 * @param location This is a Rectangle object specifying the start coordinates as the x and y values of the rectangle.  The width and height values of the Rectangle specify number of columns or rows to span, respectively.
	 * @param styles This specifies the style object to set.
	 */
	// -- JH Suggested Name: setCellsStylesObjectInRangeByRectangle as it is less ambigious 
	// --AB name changed as suggested
	public function setCellsStylesObjectInRangeByRectangle (location : Rectangle, styles : Object) : void
	{
		if (!location || !styles)
			return;
		
		setCellsStylesObjectInRangeAt (location.x, location.y, location.width, location.height, styles);
	}
	
	//----------------------------------
	//  removeCell
	//----------------------------------
	
	/**
	 *  This method will remove a cell at the specified coordinates.
	 *
	 * @param columnIndex This specifies the integer location of the column to process.
	 * @param rowIndex This specifies the integer location of the row to process.
	 */
	protected function removeCell (columnIndex : uint, rowIndex : uint) : void
	{
		Cell (cells.removeItemAt (cells.getItemIndex (getCellAt (columnIndex, rowIndex)))).release ();
	}
	
	//----------------------------------
	//  removeColumn
	//----------------------------------
	
	/**
	 * This method will remove columns, at the specified coordinates.
	 *
	 * @param index This specifies the integer location of the column to remove.
	 * @param columnIndex This specifies the  number of columns to delete.
	 * @param rowCount This specifies the number of rows to process.
	 */
	// --JH Why does this method need both columnCount and rowCount?  
	// --AB it is internal hence a bit more complicated, it does need to know rowCount to physically remove that many cells
	protected function removeColumn (index : uint, rowCount : uint) : void
	{
		// --?? I suggest defining the object type as a non-generic object. 
		// this is purely internal to instruct calc and utils properly
		removeColumnIndex = index;
		
		for (var i : uint; i < rowCount; ++i)
			removeCell (index, i);
	}
	
	//----------------------------------
	//  removeColumnAt
	//----------------------------------
	/**
	 * This mehod will dispatch a remove event.
	 *
	 * @example
	 * <listing version="3.0">grid.removeColumnAt (1);</listing>
	 *
	 * @param index This specifies the integer location of the column to remove.
	 */
	// --JH This method doesn't actually do any removing, it just fires off an event.  Is it not implemented yet?  Or are youe xpecting an event handler to address the remove?  
	// --AB this will become cancelable at some point, there are other events to inform user of what and when is happening
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
	 * This method will remove the rows at the specified coordinates.
	 *
	 * @param index This specifies the integer location of the first row to remove.
	 * @param columnCount This specifies the  number of columns to process.
	 * @param rowCount This specifies number of rows to process.
	 */
	//--JH Why does this need a columnCount rowCount?  
	// --AB it is internal hence a bit more complicated, it does need to know columnCount to physically remove that many cells
	protected function removeRow (index : uint, columnCount : uint) : void
	{
		// --?? I suggest defining the object type as a non-generic object. 
		// --AB no need for int to be VO
		removeRowIndex = index;
		
		for (var i : uint; i < columnCount; ++i)
			removeCell (i, index);
	}
	
	//----------------------------------
	//  removeRowAt
	//----------------------------------
	/**
	 * This method will dispatch a remove event.
	 *
	 * @example
	 * <listing version="3.0">grid.removeRowAt (1);</listing>
	 *
	 * @param index This method will dispatch a remove event.
	 *
	 * @see com.flextras.sreadsheet.events.RowEvent
	 */
	public function removeRowAt (index : uint) : void
	{
		if (isRowIndexInvalid (index))
			return;
		
		dispatchEvent (new RowEvent (RowEvent.REMOVE, index));
	}
	
	//----------------------------------
	//  setCellSpanAt
	//----------------------------------
	/**
	 * This method will resize the cells at the specified location.
	 *
	 * @example
	 * <listing version="3.0">grid.setCellSpanAt (1, 1, 3, 2);</listing>
	 *
	 * @param columnIndex This specifies the integer location of the column to process.
	 * @param rowIndex This specifies the integer location of the row to process.
	 * @param columnSpan  This specifies the number of columns to process.
	 * @param rowSpan This specifies the number of rows to process.
	 */
	public function setCellSpanAt (columnIndex : uint, rowIndex : uint, columnSpan : uint = 0, rowSpan : uint = 0) : void
	{
		if (isColumnIndexInvalid (columnIndex) || isRowIndexInvalid (rowIndex))
			return;
		
		dispatchEvent (new CellEvent (CellEvent.RESIZE, new Rectangle (columnIndex, rowIndex, columnSpan, rowSpan)));
	}
	
	//----------------------------------
	//  setCellSpanByRectangle
	//----------------------------------
	
	/**
	 * This method will resize the cell at the specified location.
	 *
	 * @example
	 * <listing version="3.0">grid.setCellSpanByRectangle (new Rectangle(1, 1, 3, 2));</listing>
	 *
	 * @param bounds This is a Rectangle object.  The x and y values of the rectangle specify the cell to reize.  The height and width properties of the Rectangle specify new size of the cell.
	 */
	public function setCellSpanByRectangle (bounds : Rectangle) : void
	{
		if (!bounds)
			return;
		
		setCellSpanAt (bounds.x, bounds.y, bounds.width, bounds.height);
	}
	
	//----------------------------------
	//  getRowHeightAt
	//----------------------------------
	
	// --JH Only properties can be made the source of binding through bindable metadata tag; but this is method, not a property.  To make it Bindable, change it to a get method. Doing that would not give you the ability to pass an argument, though
	// --AB chenged as suggested, event does get dispatched
	[Bindable(event="rowHeightsChanged")]
	[Bindable(event="preferredRowHeightsChanged")]
	/**
	 * This method gets the row height at the specified index.
	 *
	 * @example
	 * <listing version="3.0">var rowHeight:Number = grid.getRowHeightAt (1);</listing>
	 *
	 * @param index This specifies the integer location of the row to process.
	 * @return The height of the requested row.
	 */
	public function getRowHeightAt (index : uint) : Number
	{
		if (isRowIndexInvalid (index))
			return NaN;
		
		var value : Number = preferredRowHeights[index];
		
		if (isNaN (value))
		{
			if (rowHeights)
			{
				var rowHeight : CellHeight = rowHeights[index];
				
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
	 * @example
	 * <listing version="3.0">grid.setRowHeightAt (1, 200);</listing>
	 *
	 * @param index This specifies the integer location of the row to process.
	 * @param value This specifies the new height.
	 */
	public function setRowHeightAt (index : uint, value : Number) : void
	{
		if (isRowIndexInvalid (index))
			return;
		
		preferredRowHeights[index] = value;
		
		grid.dataGroup.invalidateDisplayList ();
		
		dispatchEvent (new Event ("preferredRowHeightsChanged"));
	}
	
	/**
	 * @private
	 */
	protected function updatePreferredColumnWidths (index : uint, amount : int) : void
	{
		var array : Array = [], i : int;
		
		for (var k : String in preferredColumnWidths)
		{
			i = parseInt (k);
			
			if (!isNaN (i))
			{
				if (i > index)
					array[i + amount] = preferredColumnWidths[i];
				else
					array[i] = preferredColumnWidths[i];
			}
		}
		
		_preferredColumnWidths = array;
		
		columnCount += amount;
		oldColumnCount = columnCount;
	}
	
	/**
	 * @private
	 */
	protected function updatePreferredRowHeights (index : uint, amount : int) : void
	{
		var array : Array = [], i : int;
		
		for (var k : String in preferredRowHeights)
		{
			i = parseInt (k);
			
			if (!isNaN (i))
			{
				if (i > index)
					array[i + amount] = preferredRowHeights[i];
				else
					array[i] = preferredRowHeights[i];
			}
		}
		
		_preferredRowHeights = array;
		
		rowCount += amount;
		oldRowCount = rowCount;
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
				invalidateCells ();
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
				}
				
				invalidateCells ();
				break;
			
			case CollectionEventKind.REPLACE:
				break;
			
			case CollectionEventKind.RESET:
				break;
			
			case CollectionEventKind.UPDATE:
				invalidateCells ();
				break;
		}
	}
	
	//----------------------------------
	//  clearColumnHandler
	//----------------------------------
	
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
		if (!e || e.isDefaultPrevented ())
			return;
		
		var index : uint = e.index;
		
		if (isColumnIndexInvalid (index))
			return;
		
		clearColumnIndex = index;
		
		var row : Array = columns[index];
		
		for (var i : uint, n : uint = row.length; i < n; ++i)
			Cell (row[i]).clear ();
		
		clearColumnDirty = true;
	}
	
	//----------------------------------
	//  clearRowHandler
	//----------------------------------
	
	/**
	 * @private
	 * This is the default handler for the RowEvent.CLEAR method.
	 *
	 * @see com.flextras.spreadsheet.events.RowEvent
	 * @see com.flextras.spreadsheet.events.RowEvent#CLEAR
	 */
	protected function clearRowHandler (e : RowEvent) : void
	{
		if (!e || e.isDefaultPrevented ())
			return;
		
		var index : uint = e.index;
		
		if (isRowIndexInvalid (index))
			return;
		
		clearRowIndex = index;
		
		var column : Array = rows[index];
		
		for (var i : uint, n : uint = column.length; i < n; ++i)
			Cell (column[i]).clear ();
		
		clearRowDirty = true;
	}
	
	//----------------------------------
	//  expressionsChangeHandler
	//----------------------------------	
	
	/**
	 * @private
	 *
	 * The default handler for expression change events.
	 */
	protected function expressionsChangeHandler (e : CollectionEvent) : void
	{
		var items : Array;
		
		if (e.kind == CollectionEventKind.REMOVE)
			items = e.items;
		
		if (e.kind == CollectionEventKind.RESET)
			items = oldExpressions;
		
		if (items)
			for (var i : uint, n : uint = items.length, item : Object; i < n; ++i)
			{
				item = items[i];
				
				if (item.hasOwnProperty ("reference"))
					Cell (item.reference).expressionObject = null;
			}
		
		//expCE = e;
		invalidateExpressions ();
		
		dispatchEvent (new Event (SpreadsheetEvent.EXPRESSIONS_CHANGE));
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
		if (!e || e.isDefaultPrevented ())
			return;
		
		var index : uint = e.index;
		
		if (isColumnIndexInvalid (index))
			return;
		
		addColumn (index, rowCount);
		
		addColumnDirty = true;
		
		updatePreferredColumnWidths (index, 1);
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
		if (!e || e.isDefaultPrevented ())
			return;
		
		var index : uint = e.index;
		
		if (isRowIndexInvalid (index))
			return;
		
		addRow (index, columnCount);
		
		addRowDirty = true;
		
		updatePreferredRowHeights (index, 1);
	}
	
	//----------------------------------
	//  keyDownHandler
	//----------------------------------	
	/**
	 * @private
	 *
	 * This is the default handler for the key down event of spreadsheet cells
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
		if (!e || e.isDefaultPrevented ())
			return;
		
		var index : uint = e.index;
		
		if (isColumnIndexInvalid (index))
			return;
		
		removeColumn (index, rowCount);
		
		columnRemovedirty = true;
		
		updatePreferredColumnWidths (index, -1);
	}
	
	//----------------------------------
	//  removeRowHandler
	//----------------------------------	
	
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
		if (!e || e.isDefaultPrevented ())
			return;
		
		var index : uint = e.index;
		
		if (isRowIndexInvalid (index))
			return;
		
		removeRow (index, columnCount);
		
		rowRemovedirty = true;
		
		updatePreferredRowHeights (index, -1);
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
		if (!e || e.isDefaultPrevented ())
			return;
		
		var amount : Rectangle = e.amount;
		
		if (!amount || isColumnIndexInvalid (amount.x) || isRowIndexInvalid (amount.y))
			return;
		
		var cell : Cell = getCellAt (amount.x, amount.y);
		
		if (cell.bounds.right + 1 > columnCount)
			columnCount = cell.bounds.right + 1;
		
		if (cell.bounds.bottom + 1 > rowCount)
			rowCount = cell.bounds.bottom + 1;
		
		doSort = true;
		
		invalidateCells ();
	}
	
	//----------------------------------
	//  selectionChangedHandler
	//----------------------------------	
	/**
	 * @private
	 */
	protected function selectionChangedHandler (e : Event) : void
	{
		dispatchEvent (e);
	}
}
}