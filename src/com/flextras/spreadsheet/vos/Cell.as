package com.flextras.spreadsheet.vos
{
import com.flextras.calc.ControlObject;
import com.flextras.calc.FormulaLogic;
import com.flextras.calc.Utils;
import com.flextras.spreadsheet.Spreadsheet;
import com.flextras.spreadsheet.context.Menu;
import com.flextras.spreadsheet.core.spreadsheet;
import com.flextras.spreadsheet.events.CellEvent;
import com.flextras.spreadsheet.events.ColumnEvent;
import com.flextras.spreadsheet.events.RowEvent;

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.geom.Rectangle;
import flash.utils.IDataInput;
import flash.utils.IDataOutput;
import flash.utils.IExternalizable;

use namespace spreadsheet;

//----------------------------------
//  Events
//----------------------------------

/**
 *
 */
[Event(name="stylesChanged", type="flash.events.Event")]

/**
 *
 */
[Event(name="conditionChanged", type="flash.events.Event")]

/**
 *
 */
[Event(name="contextMenuEnabledChanged", type="flash.events.Event")]

/**
 *
 */
[Event(name="enabledChanged", type="flash.events.Event")]

/**
 *
 */
[Event(name="valueChanged", type="flash.events.Event")]

/**
 *
 */
[Event(name="wordWrapChanged", type="flash.events.Event")]

/**
 *
 */
[Event(name="expressionChanged", type="flash.events.Event")]

[RemoteClass]
/**
 * Whenever you want to apply some cell specific properties this is the right place to do it.
 * You can modify almost any style supported by older Flash Text Engine or modify background related styles
 * and thats true for all four states (normal, over, selected, disabled), but there's a catch:
 * font related styles (kerning, spacing, ...) can only be set in "styles" property - which is for "normal" state
 * every other state will be ignored.
 */
public class Cell extends EventDispatcher implements IExternalizable
{
	//--------------------------------------------------------------------------
	//
	//  Constants
	//
	//--------------------------------------------------------------------------
	
	/**
	 *
	 */
	public const menu : Menu = new Menu (Cell (this));
	
	/**
	 *
	 */
	spreadsheet const controlObject : ControlObject = new ControlObject (Cell (this));
	
	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------
	
	/**
	 * Constructor.
	 *
	 * @param owner
	 * @param bounds
	 *
	 */
	public function Cell (owner : Spreadsheet = null, bounds : Rectangle = null)
	{
		this.owner = owner;
		
		controlObject.grid = owner;
		controlObject.ctrl = this;
		controlObject.valueProp = "value";
		
		setBounds (bounds);
		
		if (owner)
		{
			owner.addEventListener (CellEvent.RESIZE, resizeCellHandler, false);
			
			owner.addEventListener (ColumnEvent.INSERT, columnInsertHandler, false);
			owner.addEventListener (ColumnEvent.REMOVE, columnRemoveHandler, false);
			
			owner.addEventListener (RowEvent.INSERT, rowInsertHandler, false);
			owner.addEventListener (RowEvent.REMOVE, rowRemoveHandler, false);
			
			owner.addEventListener (ColumnEvent.INSERTED, removeTemporaryOldID, false);
			owner.addEventListener (ColumnEvent.REMOVED, removeTemporaryOldID, false);
			
			owner.addEventListener (RowEvent.INSERTED, removeTemporaryOldID, false);
			owner.addEventListener (RowEvent.REMOVED, removeTemporaryOldID, false);
		}
		
		//_condition.addEventListener("leftChanged", conditionChanged);
		_condition.addEventListener ("operatorChanged", conditionChanged);
		_condition.addEventListener ("rightChanged", conditionChanged);
	
		//controlObject.addEventListener("expressionChanged", controlObject_expressionChanged);
	}
	
	//--------------------------------------------------------------------------
	//
	//  Variables
	//
	//--------------------------------------------------------------------------
	
	/**
	 *
	 */
	spreadsheet var owner : Spreadsheet;
	
	/**
	 *
	 */
	spreadsheet var width : Number, height : Number;
	
	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------
	
	//----------------------------------
	//  bounds
	//----------------------------------
	
	/**
	 *
	 */
	protected var _bounds : Rectangle;
	
	/**
	 *
	 * @return
	 *
	 */
	spreadsheet function get bounds () : Rectangle
	{
		return _bounds;
	}
	
	//----------------------------------
	//  columnIndex
	//----------------------------------
	
	[Transient]
	/**
	 *
	 * @return
	 *
	 */
	public function get columnIndex () : uint
	{
		return _bounds.x;
	}
	
	//----------------------------------
	//  columnSpan
	//----------------------------------
	
	[Transient]
	/**
	 *
	 * @return
	 *
	 */
	public function get columnSpan () : uint
	{
		return _bounds.width;
	}
	
	//----------------------------------
	//  condition
	//----------------------------------
	
	/**
	 *
	 */
	protected const _condition : Condition = new Condition;
	
	[Bindable(event="conditionChanged")]
	/**
	 * Operator and right side of expression are required
	 * (example '= 1 + 2' -
	 * '1' is left side of expression,
	 * '+' is an operator,
	 * '2' is right side of expression)
	 *
	 * left side of expression is optional (if provided condition will take its value instead of cell's)
	 */
	public function get condition () : Condition
	{
		return _condition;
	}
	
	public function set condition (value : Condition) : void
	{
		if (!value || _condition === value)
			return;
		
		_condition.assign (value);
		
		dispatchEvent (new Event ("conditionChanged"));
	}
	
	[Transient]
	/**
	 *
	 * @param value
	 *
	 */
	public function set conditionObject (value : Object) : void
	{
		if (!value)
			return;
		
		if (value is Condition)
			condition = Condition (value);
		else
		{
			_condition.assignObject (value);
			
			dispatchEvent (new Event ("conditionChanged"));
		}
	}
	
	//----------------------------------
	//  contextMenuEnabled
	//----------------------------------
	
	/**
	 *
	 */
	protected var _contextMenuEnabled : Boolean;
	
	[Bindable(event="contextMenuEnabledChanged")]
	/**
	 *
	 * @return
	 *
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
		
		dispatchEvent (new Event ("contextMenuEnabledChanged"));
	}
	
	//----------------------------------
	//  enabled
	//----------------------------------
	
	/**
	 *
	 */
	protected var _enabled : Boolean = true;
	
	[Bindable(event="enabledChanged")]
	/**
	 *
	 * @return
	 *
	 */
	public function get enabled () : Boolean
	{
		return _enabled;
	}
	
	/**
	 *
	 * @param value
	 *
	 */
	public function set enabled (value : Boolean) : void
	{
		if (_enabled == value)
			return;
		
		_enabled = value;
		
		menu.disable.caption = value ? "Disable Cell" : "Enable Cell";
		
		dispatchEvent (new Event ("enabledChanged"));
	}
	
	//----------------------------------
	//  expression
	//----------------------------------
	
	/**
	 *
	 */
	protected var _expression : String;
	
	[Bindable(event="expressionChanged")]
	[Bindable(event="valueChanged")]
	/**
	 *
	 * @return
	 *
	 */
	public function get expression () : String
	{
		var value : String = _expression || this.value;
		
		return owner && owner.expressionFunction != null ? owner.expressionFunction (value) : value;
	}
	
	/**
	 *
	 * @param value
	 *
	 */
	public function set expression (value : String) : void
	{
		if (owner && owner.expressionFunction == null && _expression == value)
			return;
		
		_expression = value;
		
		controlObject.exp = value;
		
		if (owner)
		{
			//owner.calc.assignControlExpression(controlObject, value || "");
			owner.assignExpression (controlObject.id, value);
		}
		
		/*if(!expressionObject)
		 owner.assignExpression(id, expression);*/
		
		if (expressionObject)
			expressionObject.expression = value;
		
		dispatchEvent (new Event ("expressionChanged"));
	}
	
	protected var _expressionObject : Object;
	
	spreadsheet function get expressionObject () : Object
	{
		if (!_expressionObject && owner)
			expressionObject = owner.getExpressionObject (id);
		
		return _expressionObject;
	}
	
	spreadsheet function get expressionObjectByOldID () : Object
	{
		if (!_expressionObject && owner)
			expressionObject = owner.getExpressionObject (controlObject.temporaryOldID);
		
		return _expressionObject;
	}
	
	spreadsheet function set expressionObject (value : Object) : void
	{
		//trace(value ? value.cell : "id", value ? value.reference : "ref", value ? value.expression : "exp", controlObject.oldID, id, expression);
		
		if (_expressionObject === value)
			return;
		
		_expressionObject = value;
		
		if (value)
		{
			if (!value.hasOwnProperty ("reference"))
				value.reference = this;
			
			if (value.reference === this)
				expression = value[owner.expressionField];
		}
		else
			_expression = controlObject.exp = this.value = null;
	}
	
	//----------------------------------
	//  globalStyles
	//----------------------------------
	
	/**
	 *
	 * @param value
	 *
	 */
	spreadsheet function set globalStyles (value : CellStyles) : void
	{
		_styles.global = value;
	}
	
	//----------------------------------
	//  globalCondition
	//----------------------------------
	
	/**
	 *
	 * @param value
	 *
	 */
	spreadsheet function set globalCondition (value : Condition) : void
	{
		_condition.global = value;
	}
	
	//----------------------------------
	//  id
	//----------------------------------
	
	[Transient]
	/**
	 *
	 * @return
	 *
	 */
	public function get id () : String
	{
		return controlObject.id;
	}
	
	//----------------------------------
	//  rowIndex
	//----------------------------------
	
	[Transient]
	/**
	 *
	 * @return
	 *
	 */
	public function get rowIndex () : uint
	{
		return _bounds.y;
	}
	
	//----------------------------------
	//  rowSpan
	//----------------------------------
	
	[Transient]
	/**
	 *
	 * @return
	 *
	 */
	public function get rowSpan () : uint
	{
		return _bounds.height;
	}
	
	//----------------------------------
	//  styles
	//----------------------------------
	
	/**
	 *
	 */
	protected const _styles : CellStyles = new CellStyles;
	
	[Bindable(event="stylesChanged")]
	/**
	 *
	 * @return
	 *
	 */
	public function get styles () : CellStyles
	{
		return _styles;
	}
	
	/**
	 *
	 * @param value
	 *
	 */
	public function set styles (value : CellStyles) : void
	{
		if (!value || _styles === value)
			return;
		
		_styles.assign (value);
		
		dispatchEvent (new Event ("stylesChanged"));
	}
	
	[Transient]
	/**
	 *
	 * @param value
	 *
	 */
	public function set stylesObject (value : Object) : void
	{
		if (!value)
			return;
		
		if (value is CellStyles)
			styles = CellStyles (value);
		else
		{
			_styles.assignObject (value);
			
			dispatchEvent (new Event ("stylesChanged"));
		}
	}
	
	//----------------------------------
	//  value
	//----------------------------------
	
	/**
	 *
	 */
	protected var _value : String;
	
	[Bindable(event="valueChanged")]
	/**
	 *
	 * @return
	 *
	 */
	public function get value () : String
	{
		return _value;
	}
	
	/**
	 *
	 * @param value
	 *
	 */
	public function set value (value : String) : void
	{
		if (_value == value)
			return;
		
		_value = value;
		
		conditionChanged ();
		
		dispatchEvent (new Event ("valueChanged"));
	}
	
	//----------------------------------
	//  wordWrap
	//----------------------------------
	
	/**
	 * @private
	 */
	protected var _wordWrap : Boolean;
	
	[Bindable(event="wordWrapChanged")]
	/**
	 * This property is a flag that indicates whether text in the cells should be word wrapped.
	 *  If <code>true</code>, enables word wrapping for text in the spreadsheet cells.
	 */
	public function get wordWrap () : Boolean
	{
		return _wordWrap;
	}
	
	/**
	 * @private
	 */
	public function set wordWrap (value : Boolean) : void
	{
		if (_wordWrap == value)
			return;
		
		_wordWrap = value;
		
		dispatchEvent (new Event ("wordWrapChanged"));
	}
	
	//--------------------------------------------------------------------------
	//
	//  Methods
	//
	//--------------------------------------------------------------------------
	
	/**
	 *
	 * @param value
	 *
	 */
	public function assign (value : Cell) : void
	{
		if (!value)
			return;
		
		styles = value.styles;
		condition = value.condition;
		
		contextMenuEnabled = value.contextMenuEnabled;
		enabled = value.enabled;
		this.value = value.value;
		expression = value.expression;
		bounds.width = value.bounds.width;
		bounds.height = value.bounds.height;
	}
	
	/**
	 *
	 * @param value
	 *
	 */
	public function assignObject (value : Object) : void
	{
		if (!value)
			return;
		
		if (value is Cell)
		{
			assign (Cell (value));
			
			return;
		}
		
		if (value.hasOwnProperty ("styles"))
			stylesObject = value.styles;
		
		if (value.hasOwnProperty ("condition"))
			conditionObject = value.condition;
		
		if (value.hasOwnProperty ("contextMenuEnabled"))
			contextMenuEnabled = Boolean (value.contextMenuEnabled);
		
		if (value.hasOwnProperty ("enabled"))
			enabled = Boolean (value.enabled);
		
		if (value.hasOwnProperty ("value"))
			this.value = String (value.value);
		
		if (value.hasOwnProperty ("expression"))
			expression = String (value.expression);
		
		if (value.hasOwnProperty ("bounds"))
		{
			if (value.hasOwnProperty ("width"))
				bounds.width = uint (value.bounds.width);
			
			if (value.hasOwnProperty ("height"))
				bounds.height = uint (value.bounds.height);
		}
		else
		{
			if (value.hasOwnProperty ("columnSpan"))
				bounds.width = uint (value.columnSpan);
			
			if (value.hasOwnProperty ("rowSpan"))
				bounds.width = uint (value.rowSpan);
		}
	}
	
	public function clear () : void
	{
		expression = "";
		value = null;
		enabled = true;
		
		styles = new CellStyles;
		condition = new Condition;
	}
	
	/**
	 *
	 * @param amount
	 * @param excludeRule
	 *
	 */
	protected function moveExpressionHorizontally (amount : int, index : int) : void
	{
		expression = controlObject.exp ? Utils.moveExpression2 (controlObject, amount, 0, null, [index, null, null, null]) : value;
	}
	
	/**
	 *
	 * @param amount
	 * @param excludeRule
	 *
	 */
	protected function moveExpressionVertically (amount : int, index : int) : void
	{
		expression = controlObject.exp ? Utils.moveExpression2 (controlObject, 0, amount, null, [null, null, index, null]) : value;
	}
	
	/**
	 *
	 * @param amount
	 *
	 */
	protected function moveHorizontally (amount : uint) : void
	{
		_bounds.x = amount; //.offset(amount, 0);
		
		controlObject.colIndex = amount;
		controlObject.col = String (Utils.alphabet[amount]).toLowerCase ();
		
		var id : String = controlObject.col + controlObject.row;
		
		if (expressionObjectByOldID && expressionObjectByOldID.hasOwnProperty ("reference") && expressionObjectByOldID.reference === this)
			expressionObjectByOldID[owner.cellField] = id;
		
		controlObject.id = id;
	}
	
	/**
	 *
	 * @param amount
	 *
	 */
	protected function moveVertically (amount : uint) : void
	{
		_bounds.y = amount; //.offset(0, amount);
		
		controlObject.rowIndex = amount;
		controlObject.row = String (amount);
		
		var id : String = controlObject.col + controlObject.row;
		
		if (expressionObjectByOldID && expressionObjectByOldID.hasOwnProperty ("reference") && expressionObjectByOldID.reference === this)
			expressionObjectByOldID[owner.cellField] = id;
		
		controlObject.id = id;
	}
	
	/**
	 *
	 * @param input
	 *
	 */
	public function readExternal (input : IDataInput) : void
	{
		styles = input.readObject ();
		condition = input.readObject ();
		var co : ControlObject = input.readObject ();
		controlObject.children = co.children;
		controlObject.collection = co.collection;
		controlObject.ctrlOperands = co.ctrlOperands;
		controlObject.dependants = co.dependants;
		contextMenuEnabled = input.readBoolean ();
		enabled = input.readBoolean ();
		setBoundsObject (input.readObject ());
		
		var length : uint = input.readUnsignedInt ();
		
		expression = length > 0 ? input.readUTFBytes (length) : "";
	}
	
	/**
	 *
	 *
	 */
	spreadsheet function release () : void
	{
		if (owner)
		{
			owner.removeEventListener (CellEvent.RESIZE, resizeCellHandler);
			
			owner.removeEventListener (ColumnEvent.INSERT, columnInsertHandler);
			owner.removeEventListener (ColumnEvent.REMOVE, columnRemoveHandler);
			
			owner.removeEventListener (RowEvent.INSERT, rowInsertHandler);
			owner.removeEventListener (RowEvent.REMOVE, rowRemoveHandler);
			
			owner.removeEventListener (ColumnEvent.INSERTED, removeTemporaryOldID);
			owner.removeEventListener (ColumnEvent.REMOVED, removeTemporaryOldID);
			
			owner.removeEventListener (RowEvent.INSERTED, removeTemporaryOldID);
			owner.removeEventListener (RowEvent.REMOVED, removeTemporaryOldID);
		}
		
		//_condition.removeEventListener("leftChanged", conditionChanged);
		_condition.removeEventListener ("operatorChanged", conditionChanged);
		_condition.removeEventListener ("rightChanged", conditionChanged);
		
		controlObject.removeEventListener ("expressionChanged", controlObject_expressionChanged);
		
		globalStyles = null;
		globalCondition = null;
	}
	
	/**
	 *
	 * @param amount
	 *
	 */
	protected function resizeHorizontally (amount : uint) : void
	{
		if (amount < 0)
			return;
		
		_bounds.width = amount; //+=
	}
	
	/**
	 *
	 * @param amount
	 *
	 */
	protected function resizeVertically (amount : uint) : void
	{
		if (amount < 0)
			return;
		
		_bounds.height = amount; //+=
	}
	
	/**
	 *
	 * @private
	 * @param value
	 *
	 */
	protected function setBounds (value : Rectangle) : void
	{
		if (!value || _bounds === value)
			return;
		
		_bounds = value;
		
		controlObject.colIndex = value.x;
		controlObject.col = String (Utils.alphabet[value.x]).toLowerCase ();
		
		controlObject.rowIndex = value.y;
		controlObject.row = String (value.y);
		
		controlObject.id = controlObject.col + controlObject.row;
	}
	
	/**
	 *
	 * @private
	 * @param value
	 *
	 */
	protected function setBoundsObject (value : Object) : void
	{
		if (!value)
			return;
		
		setBounds (new Rectangle (value.x, value.y, value.width, value.height));
	}
	
	/**
	 *
	 * @param output
	 *
	 */
	public function writeExternal (output : IDataOutput) : void
	{
		output.writeObject (styles);
		output.writeObject (condition);
		output.writeObject (controlObject);
		output.writeBoolean (contextMenuEnabled);
		output.writeBoolean (enabled);
		output.writeObject (bounds);
		
		if (expression && expression.length > 0)
		{
			output.writeUnsignedInt (expression.length);
			output.writeUTFBytes (expression);
		}
		else
			output.writeUnsignedInt (0);
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
	protected function columnInsertHandler (e : ColumnEvent) : void
	{
		if (e.isDefaultPrevented ())
			return;
		
		var index : uint = e.index;
		
		var amount : int = 1;
		
		if (_bounds.x >= index)
			moveHorizontally (_bounds.x + amount);
		
		moveExpressionHorizontally (amount, index);
		
		if (_bounds.width > 0 && _bounds.right >= index)
			resizeHorizontally (_bounds.width + 1);
	}
	
	/**
	 *
	 * @param e
	 *
	 */
	protected function columnRemoveHandler (e : ColumnEvent) : void
	{
		if (e.isDefaultPrevented ())
			return;
		
		var index : uint = e.index;
		
		var amount : int = -1;
		
		if (_bounds.x > index)
			moveHorizontally (_bounds.x + amount);
		
		moveExpressionHorizontally (amount, index);
		
		if (_bounds.width > 0 && _bounds.right >= index)
			resizeHorizontally (_bounds.width - 1);
	}
	
	/**
	 *
	 * @param e
	 *
	 */
	protected function conditionChanged (e : Event = null) : void
	{
		var left : Number = parseFloat (value);
		
		if (condition.operatorValid && condition.rightValid)
			condition.active = FormulaLogic.compare (left, condition.operator, condition.right);
	}
	
	/**
	 *
	 * @param e
	 *
	 */
	protected function resizeCellHandler (e : CellEvent) : void
	{
		if (e.isDefaultPrevented ())
			return;
		
		var amount : Rectangle = e.amount;
		
		if (amount && _bounds.x == amount.x && _bounds.y == amount.y)
		{
			resizeHorizontally (amount.width);
			resizeVertically (amount.height);
		}
	}
	
	/**
	 *
	 * @param e
	 *
	 */
	protected function rowInsertHandler (e : RowEvent) : void
	{
		if (e.isDefaultPrevented ())
			return;
		
		var index : uint = e.index;
		
		var amount : int = 1;
		
		if (_bounds.y >= index)
			moveVertically (_bounds.y + amount);
		
		moveExpressionVertically (amount, index);
		
		if (_bounds.height > 0 && _bounds.bottom >= index)
			resizeVertically (_bounds.height + 1);
	}
	
	/**
	 *
	 * @param e
	 *
	 */
	protected function rowRemoveHandler (e : RowEvent) : void
	{
		if (e.isDefaultPrevented ())
			return;
		
		var index : uint = e.index;
		
		var amount : int = -1;
		
		if (_bounds.y > index)
			moveVertically (_bounds.y + amount);
		
		moveExpressionVertically (amount, index);
		
		if (_bounds.height > 0 && _bounds.bottom >= index)
			resizeVertically (_bounds.height - 1);
	}
	
	/**
	 *
	 * @param e
	 *
	 */
	protected function removeTemporaryOldID (e : Event) : void
	{
		controlObject.temporaryOldID = null;
	}
	
	/**
	 *
	 * @param e
	 *
	 */
	protected function controlObject_expressionChanged (e : Event) : void
	{
		expression = controlObject.exp;
	}
}
}