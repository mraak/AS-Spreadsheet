package com.flextras.spreadsheet
{
  import com.flextras.calc.Calc;
  import com.flextras.calc.ControlObject;
  import com.flextras.calc.Utils;
  
  import mx.controls.TextInput;
  import mx.core.IDataRenderer;
 
  public class SpreadsheetItemEditor extends TextInput implements IDataRenderer {
 	
 	private var _val:String;
 	private var calc:Calc = new Calc();
 	
    public function get actualValue():String
    {
    	var returnVal:String;
    	if(ISpreadsheet(this.owner).calc)
    	{
			var sheet:ISpreadsheet = ISpreadsheet(this.owner);
			
			var col:String 	= Utils.alphabet[this.listData.columnIndex].toString().toLowerCase();
			var oid:String 	= col + this.listData.rowIndex.toString();
			
			var co:ControlObject = sheet.ctrlObjects[oid];
			var v:String = co.ctrl[col];
			var e:String = co.exp;
			var t:String = text;
			
			//trace("item editor");
			if(v != t && e != t)
			{
				//sheet.calc.assignControlExpression(co, text);
				sheet.assignExpression(oid, text);
				
			}
			
			returnVal = co.ctrl[col];
    	}
    	else
    	{
    		returnVal = text;
    	}
        return returnVal ;
    }
    

  }
}
