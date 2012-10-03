package uk.co.currentlabel.spreadsheet.vos
{

/**
 * Provides common api for both CellWidth and CellHeight classes.
 * @private For now..
 */
public class CellSize
{
	private var _value : Number;
	
	public function get value () : Number
	{
		return _value;
	}
	
	private var _min : Number;
	
	public function get min () : Number
	{
		return _min;
	}
	
	protected function setMin (value : Number) : void
	{
		if (min == value)
			return;
		
		_min = value;
		
		update ();
	}
	
	private var _measured : Number;
	
	public function get measured () : Number
	{
		return _measured;
	}
	
	public function set measured (value : Number) : void
	{
		if (measured == value)
			return;
		
		_measured = value;
		
		update ();
	}
	
	private var _preferred : Number;
	
	public function get preferred () : Number
	{
		return _preferred;
	}
	
	public function set preferred (value : Number) : void
	{
		if (preferred == value)
			return;
		
		_preferred = value;
		
		update ();
	}
	
	protected function update () : void
	{
		if (isNaN (value) || min > value)
			_value = min;
		
		if (!isNaN (measured) && measured > value)
			_value = measured;
		
		if (!isNaN (preferred) && preferred > value)
			_value = preferred;
	}
}
}