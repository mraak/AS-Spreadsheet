package com.flextras.paintgrid
{

public class CellRange
{
	public var start : CellLocation;
	
	public var end : CellLocation;
	
	public function CellRange (start : CellLocation = null, end : CellLocation = null)
	{
		this.start = start || new CellLocation;
		this.end = end || new CellLocation;
	}
	
	public function equal (range : CellRange) : Boolean
	{
		if (!range || !range.start || !range.end)
			return false;
		
		return range.start.equal(start) && range.end.equal(end);
	}
	
	public function get valid () : Boolean
	{
		if (!start || !end)
			return false;
		
		return start.valid && end.valid;
	}
}
}