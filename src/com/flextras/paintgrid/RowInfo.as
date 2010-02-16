package com.flextras.paintgrid
{
import mx.controls.listClasses.ListRowInfo;

public class RowInfo extends ListRowInfo
{
	
	[ArrayInstanceType("com.flextras.paintgrid.CellProperties")]
	public const cells : Array = [];
	
	public function RowInfo (y : Number, height : Number, uid : String, data : Object = null)
	{
		super(y, height, uid, data);
	}
}
}