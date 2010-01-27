package com.flextras.paintgrid
{
	import flash.events.EventDispatcher;
	
	public class Location extends EventDispatcher
	{
		
		[Bindable]
		public var row : int;
		
		[Bindable]
		public var column : int;
		
		public function Location (row : int, column : int)
		{
			this.row = row;
			this.column = column;
		}
		
		public function equal (cell : Location) : Boolean
		{
			if (!cell)
				return false;
			
			return cell.row == row && cell.column == column;
		}
		
		public function inRange (range : Range) : Boolean
		{
			return column >= range.start.column && column <= range.end.column && row >= range.start.row && row <= range.end.row;
		}
		
		public function get valid () : Boolean
		{
			return row > -1 && column > -1;
		}
	}
}