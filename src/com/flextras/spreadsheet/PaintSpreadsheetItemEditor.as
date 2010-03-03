package com.flextras.spreadsheet
{
import com.flextras.calc.ControlObject;
import com.flextras.calc.Utils;

import mx.controls.TextInput;
import mx.controls.listClasses.BaseListData;

public class PaintSpreadsheetItemEditor extends TextInput
{
	/*protected var listDataChanged : Boolean;
	
	   override public function set listData (value : BaseListData) : void
	   {
	   if (listData === value)
	   return;
	
	   super.listData = value;
	
	   listDataChanged = true;
	   invalidateProperties();
	 }*/
	
	public function PaintSpreadsheetItemEditor ()
	{
		super();
	}
	
	/*override public function set text (value : String) : void
	   {
	
	 }*/
	
	public function get actualValue () : String
	{
		var value : String = listData.label;
		
		if (owner is ISpreadsheet && ISpreadsheet(owner).calc)
		{
			var sheet : ISpreadsheet = ISpreadsheet(owner);
			
			var col : String = String(Utils.alphabet[listData.columnIndex]).toLowerCase();
			var oid : String = col + listData.rowIndex;
			
			var co : ControlObject = sheet.ctrlObjects[oid];
			
			if (co)
				value = co.exp;
		}
		
		return value;
	}

/*override protected function commitProperties () : void
   {
   super.commitProperties();

   if (listDataChanged && listData)
   {
   super.text = actualValue;

   listDataChanged = false;
   }
 }*/
}
}