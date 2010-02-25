package com.flextras.paintgrid
{
import flash.events.Event;
import flash.events.EventDispatcher;

[Event(name="heightChanged")]
public class Row extends EventDispatcher
{
	public var uid : String;
	
	private var _height : Number;
	
	[Bindable(event="heightChanged")]
	public function get height () : Number
	{
		return _height;
	}
	
	public function set height (value : Number) : void
	{
		if (_height == value)
			return;
		
		_height = value;
		
		dispatchEvent(new Event("heightChanged"));
	}
	
	[ArrayInstanceType("com.flextras.paintgrid.CellProperties")]
	public const cells : Array = [];
	
	public function Row (value : Number = NaN)
	{
		this.height = value;
	}
}
}