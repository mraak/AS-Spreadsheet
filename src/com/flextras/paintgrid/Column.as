package com.flextras.paintgrid
{
	
	public class Column
	{
		public var width : Number;
		
		public var index : int;
		
		public function Column (index : int, value : Number)
		{
			this.index = index;
			this.width = value;
		}
	}
}