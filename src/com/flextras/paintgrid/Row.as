package com.flextras.paintgrid
{

public class Row
{
	public var height : Number;
	
	[ArrayInstanceType("com.flextras.paintgrid.CellProperties")]
	public const cells : Array = [];
	
	public function Row (value : Number)
	{
		this.height = value;
	}
}
}