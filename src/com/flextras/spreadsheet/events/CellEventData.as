package com.flextras.spreadsheet.events
{
import flash.geom.Rectangle;

public class CellEventData
{
	public var resizeAmount : Rectangle;
	
	public function CellEventData(resizeAmount : Rectangle)
	{
		this.resizeAmount = resizeAmount;
	}
}
}