package com.flextras.paintgrid
{
	
	public class Range
	{
		public var start : Location;
		
		public var end : Location;
		
		public function Range (start : Location, end : Location)
		{
			this.start = start;
			this.end = end;
		}
		
		public function equal (range : Range) : Boolean
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