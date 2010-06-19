package com.flextras.spreadsheet.vos
{
import com.flextras.calc.ControlObject;
import com.flextras.calc.FormulaLogic;
import com.flextras.calc.Utils;
import com.flextras.spreadsheet.ISpreadsheet;
import com.flextras.spreadsheet.Spreadsheet;
import com.flextras.spreadsheet.context.Menu;
import com.flextras.spreadsheet.core.spreadsheet;
import com.flextras.spreadsheet.events.CellEvent;
import com.flextras.spreadsheet.events.ColumnEvent;
import com.flextras.spreadsheet.events.RowEvent;

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;
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
	public function Cell(owner : IEventDispatcher = null, bounds : Rectangle = null)
	{
		this.owner = owner || Spreadsheet.instance;
		
		controlObject.grid = ISpreadsheet(this.owner);
		controlObject.ctrl = this;
		controlObject.valueProp = "value";
		
		setBounds(bounds);
		
		if (!owner)
			return;
		
		owner.addEventListener(CellEvent.RESIZE, resizeCellHandler, false, 100);
		
		owner.addEventListener(ColumnEvent.INSERTED, columnInserted, false, 100);
		owner.addEventListener(ColumnEvent.REMOVED, columnRemoved, false, 100);
		owner.addEventListener(ColumnEvent.RESIZED, columnResized, false, 100);
		
		owner.addEventListener(RowEvent.INSERTED, rowInserted, false, 100);
		owner.addEventListener(RowEvent.REMOVED, rowRemoved, false, 100);
		owner.addEventListener(RowEvent.RESIZED, rowResized, false, 100);
		
		//_condition.addEventListener("leftChanged", conditionChanged);
		_condition.addEventListener("operatorChanged", conditionChanged);
		_condition.addEventListener("rightChanged", conditionChanged);
	}
	
	//--------------------------------------------------------------------------
	//
	//  Variables
	//
	//--------------------------------------------------------------------------
	
	/**
	 *
	 */
	spreadsheet var owner : IEventDispatcher;
	
	/**
	 *
	 */
	spreadsheet var width : Number, height : Number;
	
	/**
	 *
	 */
	public const menu : Menu = new Menu(Cell(this));
	
	/**
	 *
	 */
	spreadsheet const controlObject : ControlObject = new ControlObject(Cell(this));
	
	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------
	
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
	public function get styles() : CellStyles
	{
		return _styles;
	}
	
	/**
	 *
	 * @param value
	 *
	 */
	public function set styles(value : CellStyles) : void
	{
		if (!value || _styles === value)
			return;
		
		_styles.assign(value);
		
		dispatchEvent(new Event("stylesChanged"));
	}
	
	[Transient]
	/**
	 *
	 * @param value
	 *
	 */
	public function set stylesObject(value : Object) : void
	{
		if (!value)
			return;
		
		if (value is CellStyles)
			styles = CellStyles(value);
		else
		{
			_styles.assignObject(value);
			
			dispatchEvent(new Event("stylesChanged"));
		}
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
	public function get condition() : Condition
	{
		return _condition;
	}
	
	public function set condition(value : Condition) : void
	{
		if (!value || _condition === value)
			return;
		
		_condition.assign(value);
		
		dispatchEvent(new Event("conditionChanged"));
	}
	
	[Transient]
	/**
	 *
	 * @param value
	 *
	 */
	public function set conditionObject(value : Object) : void
	{
		if (!value)
			return;
		
		if (value is Condition)
			condition = Condition(value);
		else
		{
			_condition.assignObject(value);
			
			dispatchEvent(new Event("conditionChanged"));
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
	public function get contextMenuEnabled() : Boolean
	{
		return _contextMenuEnabled;
	}
	
	/**
	 *
	 * @param value
	 *
	 */
	public function set contextMenuEnabled(value : Boolean) : void
	{
		if (_contextMenuEnabled == value)
			return;
		
		_contextMenuEnabled = value;
		
		dispatchEvent(new Event("contextMenuEnabledChanged"));
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
	public function get enabled() : Boolean
	{
		return _enabled;
	}
	
	/**
	 *
	 * @param value
	 *
	 */
	public function set enabled(value : Boolean) : void
	{
		if (_enabled == value)
			return;
		
		_enabled = value;
		
		menu.disable.caption = value ? "Disable Cell" : "Enable Cell";
		
		dispatchEvent(new Event("enabledChanged"));
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
	public function get value() : String
	{
		return _value;
	}
	
	/**
	 *
	 * @param value
	 *
	 */
	public function set value(value : String) : void
	{
		if (_value == value)
			return;
		
		_value = value;
		
		conditionChanged();
		
		dispatchEvent(new Event("valueChanged"));
	}
	
	//----------------------------------
	//  expression
	//----------------------------------
	
	/**
	 *
	 */
	protected var _expression : String;
	
	[Bindable(event="expressionChanged")]
	/**
	 *
	 * @return
	 *
	 */
	public function get expression() : String
	{
		return controlObject.exp || value; //_expression;
	}
	
	/**
	 *
	 * @param value
	 *
	 */
	public function set expression(value : String) : void
	{
		if (_expression == value)
			return;
		
		_expression = value;
		
		controlObject.exp = value;
		
		if (owner)
			ISpreadsheet(owner).assignExpression(controlObject.id, value);
		
		dispatchEvent(new Event("expressionChanged"));
	}
	
	//--------------------------------------------------------------------------
	//
	//  Read-only properties
	//
	//--------------------------------------------------------------------------
	
	//----------------------------------
	//  id
	//----------------------------------
	
	[Transient]
	/**
	 *
	 * @return
	 *
	 */
	public function get id() : String
	{
		return controlObject.id;
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
	public function get columnIndex() : uint
	{
		return _bounds.x;
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
	public function get rowIndex() : uint
	{
		return _bounds.y;
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
	public function get columnSpan() : uint
	{
		return _bounds.width;
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
	public function get rowSpan() : uint
	{
		return _bounds.height;
	}
	
	//--------------------------------------------------------------------------
	//
	//  Private properties
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
	spreadsheet function get bounds() : Rectangle
	{
		return _bounds;
	}
	
	//--------------------------------------------------------------------------
	//
	//  Private methods
	//
	//--------------------------------------------------------------------------
	
	/**
	 *
	 * @private
	 * @param value
	 *
	 */
	protected function setBounds(value : Rectangle) : void
	{
		if (!value || _bounds === value)
			return;
		
		_bounds = value;
		
		controlObject.colIndex = value.x;
		controlObject.col = String(Utils.alphabet[value.x]).toLowerCase();
		
		controlObject.rowIndex = value.y;
		controlObject.row = String(value.y);
		
		controlObject.id = controlObject.col + controlObject.row;
	}
	
	/**
	 *
	 * @private
	 * @param value
	 *
	 */
	protected function setBoundsObject(value : Object) : void
	{
		if (!value)
			return;
		
		setBounds(new Rectangle(value.x, value.y, value.width, value.height));
	}
	
	/**
	 *
	 * @param amount
	 *
	 */
	protected function moveHorizontally(amount : uint) : void
	{
		_bounds.x = amount; //.offset(amount, 0);
		
		controlObject.colIndex = amount;
		controlObject.col = String(Utils.alphabet[amount]).toLowerCase();
		
		controlObject.id = controlObject.col + controlObject.row;
	}
	
	/**
	 *
	 * @param amount
	 *
	 */
	protected function moveVertically(amount : uint) : void
	{
		_bounds.y = amount; //.offset(0, amount);
		
		controlObject.rowIndex = amount;
		controlObject.row = String(amount);
		
		controlObject.id = controlObject.col + controlObject.row;
	}
	
	/**
	 *
	 * @param amount
	 *
	 */
	protected function resizeHorizontally(amount : uint) : void
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
	protected function resizeVertically(amount : uint) : void
	{
		if (amount < 0)
			return;
		
		_bounds.height = amount; //+=
	}
	
	//--------------------------------------------------------------------------
	//
	//  Properties: Global styles
	//
	//--------------------------------------------------------------------------
	
	/**
	 *
	 * @param value
	 *
	 */
	spreadsheet function set globalStyles(value : CellStyles) : void
	{
		_styles.global = value;
	}
	
	/**
	 *
	 * @param value
	 *
	 */
	spreadsheet function set globalCondition(value : Condition) : void
	{
		_condition.global = value;
	}
	
	//--------------------------------------------------------------------------
	//
	//  Methods: Reset
	//
	//--------------------------------------------------------------------------
	
	public function clear() : void
	{
		expression = "";
		value = null;
		enabled = true;
		
		styles = new CellStyles;
		condition = new Condition;
	}
	
	//--------------------------------------------------------------------------
	//
	//  Methods: Cleanup
	//
	//--------------------------------------------------------------------------
	
	/**
	 *
	 *
	 */
	spreadsheet function release() : void
	{
		if (!owner)
			return;
		
		owner.removeEventListener(CellEvent.RESIZE, resizeCellHandler);
		
		owner.removeEventListener(ColumnEvent.INSERTED, columnInserted);
		owner.removeEventListener(ColumnEvent.REMOVED, columnRemoved);
		owner.removeEventListener(ColumnEvent.RESIZED, columnResized);
		
		owner.removeEventListener(RowEvent.INSERTED, rowInserted);
		owner.removeEventListener(RowEvent.REMOVED, rowRemoved);
		owner.removeEventListener(RowEvent.RESIZED, rowResized);
		
		//_condition.removeEventListener("leftChanged", conditionChanged);
		_condition.removeEventListener("operatorChanged", conditionChanged);
		_condition.removeEventListener("rightChanged", conditionChanged);
		
		globalStyles = null;
		globalCondition = null;
	}
	
	//--------------------------------------------------------------------------
	//
	//  Methods: Assignment
	//
	//--------------------------------------------------------------------------
	
	/**
	 *
	 * @param value
	 *
	 */
	public function assign(value : Cell) : void
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
	public function assignObject(value : Object) : void
	{
		if (!value)
			return;
		
		if (value is Cell)
		{
			assign(Cell(value));
			
			return;
		}
		
		if (value.hasOwnProperty("styles"))
			stylesObject = value.styles;
		
		if (value.hasOwnProperty("condition"))
			conditionObject = value.condition;
		
		if (value.hasOwnProperty("contextMenuEnabled"))
			contextMenuEnabled = Boolean(value.contextMenuEnabled);
		
		if (value.hasOwnProperty("enabled"))
			enabled = Boolean(value.enabled);
		
		if (value.hasOwnProperty("value"))
			this.value = String(value.value);
		
		if (value.hasOwnProperty("expression"))
			expression = String(value.expression);
		
		if (value.hasOwnProperty("bounds"))
		{
			if (value.hasOwnProperty("width"))
				bounds.width = uint(value.bounds.width);
			
			if (value.hasOwnProperty("height"))
				bounds.height = uint(value.bounds.height);
		}
		else
		{
			if (value.hasOwnProperty("columnSpan"))
				bounds.width = uint(value.columnSpan);
			
			if (value.hasOwnProperty("rowSpan"))
				bounds.width = uint(value.rowSpan);
		}
	}
	
	//--------------------------------------------------------------------------
	//
	//  Methods: Serialization
	//
	//--------------------------------------------------------------------------
	
	/**
	 *
	 * @param input
	 *
	 */
	public function readExternal(input : IDataInput) : void
	{
		styles = input.readObject();
		condition = input.readObject();
		var co : ControlObject = input.readObject();
		controlObject.children = co.children;
		controlObject.collection = co.collection;
		controlObject.ctrlOperands = co.ctrlOperands;
		controlObject.dependants = co.dependants;
		contextMenuEnabled = input.readBoolean();
		enabled = input.readBoolean();
		setBoundsObject(input.readObject());
		
		var length : uint = input.readUnsignedInt();
		
		expression = length > 0 ? input.readUTFBytes(length) : "";
	}
	
	/**
	 *
	 * @param output
	 *
	 */
	public function writeExternal(output : IDataOutput) : void
	{
		output.writeObject(styles);
		output.writeObject(condition);
		output.writeObject(controlObject);
		output.writeBoolean(contextMenuEnabled);
		output.writeBoolean(enabled);
		output.writeObject(bounds);
		
		if (expression && expression.length > 0)
		{
			output.writeUnsignedInt(expression.length);
			output.writeUTFBytes(expression);
		}
		else
			output.writeUnsignedInt(0);
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
	protected function resizeCellHandler(e : CellEvent) : void
	{
		var amount : Rectangle = e.data.resizeAmount;
		
		if (_bounds.x == amount.x && _bounds.y == amount.y)
		{
			resizeHorizontally(amount.width);
			resizeVertically(amount.height);
		}
	}
	
	/**
	 *
	 * @param e
	 *
	 */
	protected function columnInserted(e : ColumnEvent) : void
	{
		var index : uint = e.index;
		
		if (_bounds.x >= index)
			moveHorizontally(_bounds.x + 1);
		
		if (_bounds.width > 0 && _bounds.right >= index)
			resizeHorizontally(_bounds.width + 1);
	}
	
	/**
	 *
	 * @param e
	 *
	 */
	protected function columnRemoved(e : ColumnEvent) : void
	{
		var index : uint = e.index;
		
		if (_bounds.x > index)
			moveHorizontally(_bounds.x - 1);
		
		if (_bounds.width > 0 && _bounds.right >= index)
			resizeHorizontally(_bounds.width - 1);
	}
	
	/**
	 *
	 * @param e
	 *
	 */
	protected function columnResized(e : ColumnEvent) : void
	{
	
	}
	
	/**
	 *
	 * @param e
	 *
	 */
	protected function rowInserted(e : RowEvent) : void
	{
		var index : uint = e.index;
		
		if (_bounds.y >= index)
			moveVertically(_bounds.y + 1);
		
		if (_bounds.height > 0 && _bounds.bottom >= index)
			resizeVertically(_bounds.height + 1);
	}
	
	/**
	 *
	 * @param e
	 *
	 */
	protected function rowRemoved(e : RowEvent) : void
	{
		var index : uint = e.index;
		
		if (_bounds.y > index)
			moveVertically(_bounds.y - 1);
		
		if (_bounds.height > 0 && _bounds.bottom >= index)
			resizeVertically(_bounds.height - 1);
	}
	
	/**
	 *
	 * @param e
	 *
	 */
	protected function rowResized(e : RowEvent) : void
	{
	
	}
	
	/**
	 *
	 * @param e
	 *
	 */
	protected function conditionChanged(e : Event = null) : void
	{
		var left : Number = parseFloat(value);
		
		if (condition.operatorValid && condition.rightValid)
			condition.active = FormulaLogic.compare(left, condition.operator, condition.right);
	}
}
}