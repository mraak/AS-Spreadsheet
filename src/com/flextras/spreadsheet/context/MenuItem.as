package com.flextras.spreadsheet.context
{

public class MenuItem
{
	protected var _label : String;
	
	public function get label () : String
	{
		return _label;
	}
	
	protected var _state : uint;
	
	public function get state () : uint
	{
		return _state;
	}
	
	public function set state (value : uint) : void
	{
		if (_state == value)
			return;
		
		_state = value;
		
		reset();
	}
	
	protected var _labels : Array;
	
	public function set labels (value : Array) : void
	{
		if (!value || _labels === value)
			return;
		
		_labels = value;
		
		reset();
	}
	
	public function MenuItem (labels : Array, state : uint = 0)
	{
		this.labels = labels;
		this.state = state;
	}
	
	public function reset () : void
	{
		_label = _labels[_state];
	}
}
}