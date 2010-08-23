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
 *
 *
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
	
	[Bindable]
	/**
	 *
	 * @return
	 *
	 */
	public var active : Boolean;
	
	//----------------------------------
	//  global
	//----------------------------------
	
	/**
	 *
	 * @param value
	 *
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
	 *
	 */
	private var _left : Number;
	
	[Bindable(event="leftChanged")]
	/**
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
	 *
	 */
	private var _operator : String;
	
	[Bindable(event="operatorChanged")]
	/**
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
	 *
	 */
	private var _right : Number;
	
	[Bindable(event="rightChanged")]
	/**
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
	 *
	 */
	private var _styles : Styles = new Styles;
	
	[Bindable(event="stylesChanged")]
	/**
	 *
	 * @return
	 *
	 */
	public function get styles () : Styles
	{
		return _styles;
	}
	
	/**
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
	 *
	 *
	 */
	spreadsheet function release () : void
	{
		global = null;
	}
}
}