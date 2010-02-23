package com.flextras.paintgrid
{
import mx.controls.dataGridClasses.DataGridListData;
import mx.core.IUIComponent;

public class PaintGridListData extends DataGridListData
{
	public function PaintGridListData (cell : CellProperties, text : String, dataField : String, columnIndex : int, uid : String, owner : IUIComponent, rowIndex : int = 0)
	{
		super(text, dataField, columnIndex, uid, owner, rowIndex);
		
		this.cell = cell;
	}
	
	public var cell : CellProperties;
}
}