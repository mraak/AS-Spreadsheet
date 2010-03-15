package com.flextras.spreadsheet
{
import com.flextras.calc.ControlObject;
import com.flextras.calc.Utils;

import mx.controls.TextInput;

public class SpreadsheetItemEditor extends TextInput
{
	public function SpreadsheetItemEditor ()
	{
		super();
	}
	
	public function get actualValue () : String
	{
		var t : String = text;
		
		if (ISpreadsheet(this.owner).calc)
		{
			var sheet : ISpreadsheet = ISpreadsheet(this.owner);
			
			var col : String = Utils.alphabet[this.listData.columnIndex].toString().toLowerCase();
			var oid : String = col + this.listData.rowIndex.toString();
			
			var co : ControlObject = sheet.ctrlObjects[oid];
			var v : String = co.ctrl[col];
			
			if (v != t && co.exp != t)
				sheet.assignExpression(oid, t);
			
			return v;
		}
		
		return t;
	}
}
}