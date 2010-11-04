package com.flextras.spreadsheet.vos
{
import com.flextras.spreadsheet.core.spreadsheet;

import flash.events.Event;
import flash.events.EventDispatcher;

use namespace spreadsheet;

/**
 *
 */
[Event(name="leftChanged", type="flash.events.Event")]

/**
 *
 */
[Event(name="operatorChanged", type="flash.events.Event")]

/**
 *
 */
[Event(name="rightChanged", type="flash.events.Event")]

[RemoteClass]
/**
 * Condition class represents actual condition on cell.
 */
public class Condition extends EventDispatcher
{
	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------
	
	/**
	 * Constructor.
	 *
	 * @param left
	 * @param operator
	 * @param right
	 * @param styles
	 *
	 */
	public function Condition (left : Number = NaN, operator : String = null, right : Number = NaN, styles : Styles = null)
	{
		this.left = left;
		this.operator = operator;
		this.right = right;
		
		this.styles = styles;
	}
	
	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------
	
	//----------------------------------
	//  active
	//----------------------------------
	
	/**
	 * @private
	 */
	private var _active : Boolean;
	
	[Bindable(event="activeChanged")]
	/**
	 *
	 *
	 * @return
	 *
	 */
	public function get active () : Boolean
	{
		return _active;
	}
	
	/**
	 * If true then styles from this condition will be used instead of the ones defined for matching cell.
	 * It also dispathes an event.
	 *
	 * @param value
	 *
	 */
	public function set active (value : Boolean) : void
	{
		if (active == value)
			return;
		
		_active = value;
		
		dispatchEvent (new Event ("activeChanged"));
	}
	
	//----------------------------------
	//  global
	//----------------------------------
	
	/**
	 * Sets global styles.
	 *
	 * @param value
	 * @private
	 */
	spreadsheet function set global (value : Condition) : void
	{
		if (value)
			styles.global = value.styles;
		else
			styles.global = null;
	}
	
	//----------------------------------
	//  left
	//----------------------------------
	
	/**
	 * @private
	 */
	private var _left : Number;
	
	[Bindable(event="leftChanged")]
	/**
	 * Represents left side operand.
	 *
	 * @return
	 *
	 */
	public function get left () : Number
	{
		return _left;
	}
	
	/**
	 *
	 * @param value
	 *
	 */
	public function set left (value : Number) : void
	{
		if (left == value)
			return;
		
		_left = value;
		
		dispatchEvent (new Event ("leftChanged"));
	}
	
	//----------------------------------
	//  leftValid
	//----------------------------------
	
	[Transient]
	[Bindable(event="leftChanged")]
	/**
	 * Checks correctness of an left operand.
	 *
	 * @return
	 *
	 */
	public function get leftValid () : Boolean
	{
		return !isNaN (left);
	}
	
	//----------------------------------
	//  operator
	//----------------------------------
	
	/**
	 * @private
	 */
	private var _operator : String;
	
	[Bindable(event="operatorChanged")]
	/**
	 * Represents actual operator from equation.
	 *
	 * @return
	 *
	 */
	public function get operator () : String
	{
		return _operator;
	}
	
	/**
	 *
	 * @param value
	 *
	 */
	public function set operator (value : String) : void
	{
		if (operator == value)
			return;
		
		_operator = value;
		
		dispatchEvent (new Event ("operatorChanged"));
	}
	
	//----------------------------------
	//  operatorValid
	//----------------------------------
	
	[Transient]
	[Bindable(event="operatorChanged")]
	/**
	 * Checks correctness of an operator.
	 *
	 * @return
	 *
	 */
	public function get operatorValid () : Boolean
	{
		return operator && operator.length > 0;
	}
	
	//----------------------------------
	//  right
	//----------------------------------
	
	/**
	 * @private
	 */
	private var _right : Number;
	
	[Bindable(event="rightChanged")]
	/**
	 * Represents right side operand.
	 *
	 * @return
	 *
	 */
	public function get right () : Number
	{
		return _right;
	}
	
	/**
	 *
	 * @param value
	 *
	 */
	public function set right (value : Number) : void
	{
		if (right == value)
			return;
		
		_right = value;
		
		dispatchEvent (new Event ("rightChanged"));
	}
	
	//----------------------------------
	//  rightValid
	//----------------------------------
	
	[Transient]
	[Bindable(event="rightChanged")]
	/**
	 * Checks correctness of an right operand.
	 *
	 * @return
	 *
	 */
	public function get rightValid () : Boolean
	{
		return !isNaN (right);
	}
	
	//----------------------------------
	//  Valid
	//----------------------------------
	
	[Transient]
	[Bindable(event="leftChanged")]
	[Bindable(event="operatorChanged")]
	[Bindable(event="rightChanged")]
	/**
	 * Valid only if all properties are valid.
	 *
	 * @return
	 *
	 */
	public function get valid () : Boolean
	{
		return leftValid && operatorValid && rightValid;
	}
	
	//----------------------------------
	//  styles
	//----------------------------------
	
	/**
	 * @private
	 */
	private var _styles : Styles = new Styles;
	
	[Bindable(event="stylesChanged")]
	/**
	 * Provides access to styles which will be used if condition is active.
	 *
	 * @return
	 *
	 */
	public function get styles () : Styles
	{
		return _styles;
	}
	
	/**
	 * Replaces current styles with new ones.
	 * It also dispathes an event.
	 *
	 * @param value
	 *
	 */
	public function set styles (value : Styles) : void
	{
		if (styles === value)
			return;
		
		styles.assign (value);
		
		dispatchEvent (new Event ("stylesChanged"));
	}
	
	[Transient]
	/**
	 * Accepts either Object or Styles.
	 * If value is typed as Styles then this setter behaves the same as regular setter otherwise it changes only the provided styles.
	 * It also dispathes an event.
	 *
	 * @param value
	 *
	 */
	public function set stylesObject (value : Object) : void
	{
		if (!value)
			return;
		
		if (value is Styles)
			styles = Styles (value);
		else
		{
			styles.assignObject (value);
			
			dispatchEvent (new Event ("stylesChanged"));
		}
	}
	
	//--------------------------------------------------------------------------
	//
	//  Methods
	//
	//--------------------------------------------------------------------------
	
	/**
	 * Provides convenient way to replace all properties with new ones.
	 *
	 * @param value
	 *
	 */
	public function assign (value : Condition) : void
	{
		if (!value)
			return;
		
		left = value.left;
		operator = value.operator;
		right = value.right;
		
		styles = value.styles;
	}
	
	/**
	 * Accepts either Object or Condition.
	 * If value is typed as Condition then this setter behaves the same as regular assign otherwise it changes only the provided properties.
	 *
	 * @param value
	 *
	 */
	public function assignObject (value : Object) : void
	{
		if (!value)
			return;
		
		if (value is Condition)
		{
			assign (Condition (value));
			
			return;
		}
		
		if (value.hasOwnProperty ("left"))
			left = Number (value.left);
		
		if (value.hasOwnProperty ("operator"))
			operator = String (value.operator);
		
		if (value.hasOwnProperty ("right"))
			right = Number (value.right);
		
		if (value.hasOwnProperty ("styles"))
			stylesObject = value.styles;
	}
	
	/**
	 * @private
	 */
	spreadsheet function release () : void
	{
		global = null;
	}
}
}