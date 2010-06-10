package com.flextras.spreadsheet.vos
{

public class CellSize
{
	protected var _value : Number;
	
	public function get value() : Number
	{
		return _value;
	}
	
	protected var _min : Number;
	
	public function get min() : Number
	{
		return _min;
	}
	
	protected function setMin(value : Number) : void
	{
		if (_min == value)
			return;
		
		_min = value;
		
		update();
	}
	
	protected var _measured : Number;
	
	public function get measured() : Number
	{
		return _measured;
	}
	
	public function set measured(value : Number) : void
	{
		if (_measured == value)
			return;
		
		_measured = value;
		
		update();
	}
	
	protected var _preferred : Number;
	
	public function get preferred() : Number
	{
		return _preferred;
	}
	
	public function set preferred(value : Number) : void
	{
		if (_preferred == value)
			return;
		
		_preferred = value;
		
		update();
	}
	
	protected function update() : void
	{
		if (isNaN(_value) || _min > _value)
			_value = _min;
		
		if (!isNaN(_measured) && _measured > _value)
			_value = _measured;
		
		if (!isNaN(_preferred) && _preferred > _value)
			_value = _preferred;
	}
}
}