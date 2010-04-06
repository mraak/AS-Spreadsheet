package com.flextras.paintgrid
{
public class CellLocation
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
		var minC : int = range.start.column < range.end.column ? range.start.column : range.end.column;
		var maxC : int = range.start.column > range.end.column ? range.start.column : range.end.column;
		var minR : int = range.start.row < range.end.row ? range.start.row : range.end.row;
		var maxR : int = range.start.row > range.end.row ? range.start.row : range.end.row;
		
		return column >= minC && column <= maxC && row >= minR && row <= maxR;
	}
	
	public function get valid () : Boolean
	{
		return row > -1 && column > -1;
	}
}
}