package com.flextras.paintgrid
{
	
	public class Row
	{
		public var height : Number;
		
		public var index : int;
		
		public function Row (index : int, value : Number)
		{
			this.index = index;
			this.height = value;
		}
	}
}