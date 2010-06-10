package com.flextras.spreadsheet.components
{
import com.flextras.spreadsheet.layout.SpreadsheetLayout;

import spark.components.DataGroup;

public class GridDataGroup extends DataGroup
{
	public function GridDataGroup()
	{
		super();
	}
	
	override protected function createChildren() : void
	{
		if (!layout)
			layout = new SpreadsheetLayout;
		
		super.createChildren();
	}
}
}