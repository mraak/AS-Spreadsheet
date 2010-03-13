package com.flextras.paintgrid
{
import flash.events.Event;
import flash.events.EventDispatcher;

public class Condition extends EventDispatcher
{
	protected var _operator : String;
	
	[Bindable(event="operatorChanged")]
	public function get operator () : String
	{
		return _operator;
	}
	
	public function set operator (value : String) : void
	{
		_operator = value;
		
		dispatchEvent(new Event("operatorChanged"));
	}
	
	protected var _value : int;
	
	[Bindable(event="valueChanged")]
	public function get value () : int
	{
		return _value;
	}
	
	public function set value (value : int) : void
	{
		_value = value;
		
		dispatchEvent(new Event("valueChanged"));
	}
	
	public function Condition (operator : String = null, value : int = 0)
	{
		this.operator = operator;
		this.value = value;
	}
	
	public function get valid () : Boolean
	{
		return operator && operator.length > 0;
	}
}
}