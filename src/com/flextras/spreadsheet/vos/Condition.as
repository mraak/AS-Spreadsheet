package com.flextras.spreadsheet.vos
{
import flash.events.Event;
import flash.events.EventDispatcher;

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
	public function Condition(left : Number = NaN, operator : String = null, right : Number = NaN, styles : Styles = null)
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
	//  styles
	//----------------------------------
	
	/**
	 *
	 */
	protected const _styles : Styles = new Styles;
	
	[Bindable(event="stylesChanged")]
	/**
	 *
	 * @return
	 *
	 */
	public function get styles() : Styles
	{
		return _styles;
	}
	
	/**
	 *
	 * @param value
	 *
	 */
	public function set styles(value : Styles) : void
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
		
		if (value is Styles)
			styles = Styles(value);
		else
		{
			_styles.assignObject(value);
			
			dispatchEvent(new Event("stylesChanged"));
		}
	}
	
	//----------------------------------
	//  left
	//----------------------------------
	
	/**
	 *
	 */
	protected var _left : Number;
	
	[Bindable(event="leftChanged")]
	/**
	 *
	 * @return
	 *
	 */
	public function get left() : Number
	{
		return _left;
	}
	
	/**
	 *
	 * @param value
	 *
	 */
	public function set left(value : Number) : void
	{
		if (_left == value)
			return;
		
		_left = value;
		
		dispatchEvent(new Event("leftChanged"));
	}
	
	//----------------------------------
	//  operator
	//----------------------------------
	
	/**
	 *
	 */
	protected var _operator : String;
	
	[Bindable(event="operatorChanged")]
	/**
	 *
	 * @return
	 *
	 */
	public function get operator() : String
	{
		return _operator;
	}
	
	/**
	 *
	 * @param value
	 *
	 */
	public function set operator(value : String) : void
	{
		if (_operator == value)
			return;
		
		_operator = value;
		
		dispatchEvent(new Event("operatorChanged"));
	}
	
	//----------------------------------
	//  right
	//----------------------------------
	
	/**
	 *
	 */
	protected var _right : Number;
	
	[Bindable(event="rightChanged")]
	/**
	 *
	 * @return
	 *
	 */
	public function get right() : Number
	{
		return _right;
	}
	
	/**
	 *
	 * @param value
	 *
	 */
	public function set right(value : Number) : void
	{
		if (_right == value)
			return;
		
		_right = value;
		
		dispatchEvent(new Event("rightChanged"));
	}
	
	//--------------------------------------------------------------------------
	//
	//  Read-only properties
	//
	//--------------------------------------------------------------------------
	
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
	public function get leftValid() : Boolean
	{
		return !isNaN(_left);
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
	public function get operatorValid() : Boolean
	{
		return _operator && _operator.length > 0;
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
	public function get rightValid() : Boolean
	{
		return !isNaN(_right);
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
	public function get valid() : Boolean
	{
		return leftValid && operatorValid && rightValid;
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
	public function assign(value : Condition) : void
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
	public function assignObject(value : Object) : void
	{
		if (!value)
			return;
		
		if (value is Condition)
		{
			assign(Condition(value));
			
			return;
		}
		
		if (value.hasOwnProperty("left"))
			left = Number(value.left);
		
		if (value.hasOwnProperty("operator"))
			operator = String(value.operator);
		
		if (value.hasOwnProperty("right"))
			right = Number(value.right);
		
		if (value.hasOwnProperty("styles"))
			stylesObject = value.styles;
	}
}
}