package com.flextras.paintgrid
{
import flash.events.EventDispatcher;

public class CellLocation extends EventDispatcher
{
	
	[Bindable]
	public var row : int;
	
	[Bindable]
	public var column : int;
	
	public function CellLocation (row : int = 0, column : int = 0)
	{
		this.row = row;
		this.column = column;
	}
	
	public function equal (cell : CellLocation) : Boolean
	{
		if (!cell)
			return false;
		
		return cell.row == row && cell.column == column;
	}
	
	public function inRange (range : CellRange) : Boolean
	{
		return column >= range.start.column && column <= range.end.column && row >= range.start.row && row <= range.end.row;
	}
	
	public function get valid () : Boolean
	{
		return row > -1 && column > -1;
	}
}
}