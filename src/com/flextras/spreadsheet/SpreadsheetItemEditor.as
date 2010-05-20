package com.flextras.spreadsheet
{
import com.flextras.calc.ControlObject;
import com.flextras.calc.Utils;

import mx.controls.TextInput;

/**
 * This the default itemEditor for the Flextras Spreadsheet class.
 * 
 * @see com.flextras.calendar.Spreadsheet  
 */
public class SpreadsheetItemEditor extends TextInput
{
	/**
	 * Constructor. 
	 */
	public function SpreadsheetItemEditor ()
	{
		super();
	}
	
	/**
	 * 
	 */
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
			
			if (co.exp != t)
				sheet.assignExpression(oid, t);
			
			return v;
		}
		
		return t;
	}
}
}