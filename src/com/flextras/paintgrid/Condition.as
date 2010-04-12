package com.flextras.paintgrid
{
import flash.events.Event;

public class Condition extends StylesProxy
{
	protected var _left : String;
	
	[Bindable(event="leftChanged")]
	public function get left () : String
	{
		return _left;
	}
	
	public function set left (value : String) : void
	{
		_left = value;
		
		dispatchEvent(new Event("leftChanged"));
	}
	
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
	
	protected var _right : String;
	
	[Bindable(event="rightChanged")]
	public function get right () : String
	{
		return _right;
	}
	
	public function set right (value : String) : void
	{
		_right = value;
		
		dispatchEvent(new Event("rightChanged"));
	}
	
	public function Condition (left : String = null, operator : String = null, right : String = null, styles : Object = null, rollOverStyles : Object = null, selectedStyles : Object = null, disabledStyles : Object = null)
	{
		super(styles, rollOverStyles, selectedStyles, disabledStyles);
		
		this.left = left;
		this.operator = operator;
		this.right = right;
	}
	
	[Bindable(event="leftChanged")]
	[Bindable(event="operatorChanged")]
	[Bindable(event="rightChanged")]
	override public function get valid():Boolean
	{
		return super.valid && leftValid && operatorValid && rightValid;
	}
	
	[Bindable(event="leftChanged")]
	public function get leftValid () : Boolean
	{
		return left && left.length > 0;
	}
	
	[Bindable(event="operatorChanged")]
	public function get operatorValid () : Boolean
	{
		return operator && operator.length > 0;
	}
	
	[Bindable(event="rightChanged")]
	public function get rightValid () : Boolean
	{
		return right && right.length > 0;
	}
	
	public function clear():void
	{
		left = null;
		operator = null;
		right = null;
	}
	
	override public function assign(value:StylesProxy):void
	{
		super.assign(value);
		
		if(value is Condition)
		{
			var c:Condition = Condition(value);
			
			left = c.left;
			operator = c.operator;
			right = c.right;
		}
	}
	
	override public function fromXML(value:XML):void
	{
		super.fromXML(value.styles);
		
		left = value.@left;
		operator = value.@operator;
		right = value.@right;
	}
	
	override public function toXML():XML
	{
		var result:XML = <Condition left={left} operator={operator} right={right}/>;
		
		var styles:XML = super.toXML();
		
		if(styles.children().length())
			result.styles.* += styles;
		
		return result;
	}
}
}