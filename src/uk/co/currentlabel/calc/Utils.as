
////////////////////////////////////////////////////////////////////////////////
//  
//  Copyright 2012 Alen Balja
//  All Rights Reserved.
//
//  See the file license.txt for copying permission.
//
////////////////////////////////////////////////////////////////////////////////


package uk.co.currentlabel.calc
{

/**
 * Utils class contains helper methods for various operations regarding Spreadsheet, mathematical and logical operations.
 * User of Spreadsheet SDK does not need to directly use these functions, however some advanced users might find them very useful in wide variety of applications.
 * */
public class Utils
{
	//----------------------------------
	//  _calc
	//----------------------------------
	/**
	 * @private
	 * */
	private static var _calc : Calc;
	
	//----------------------------------
	//  orepl
	//----------------------------------
	/**
	 * Part of the frepl/orepl replacement mechanism
	 * */
	private static var orepl : Object;
	
	//----------------------------------
	//  rxValidOperand
	//----------------------------------
	/**
	 * @private not in use
	 * */
	public static var rxValidOperand : RegExp = new RegExp("f");
	
	//----------------------------------
	//  alphabet
	//----------------------------------
	/**
	 * Alphabet simbols from A up to BZ, mostly used for column naming
	 * */
	public static var alphabet : Array = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z",
										  "AA", "AB", "AC", "AD", "AE", "AF", "AG", "AH", "AI", "AJ", "AK", "AL", "AM", "AN", "AO", "AP", "AQ", "AR", "AS", "AT", "AU", "AV", "AW", "AX", "AY", "AZ",
										  "BA", "BB", "BC", "BD", "BE", "BF", "BG", "BH", "BI", "BJ", "BK", "BL", "BM", "BN", "BO", "BP", "BQ", "BR", "BS", "BT", "BU", "BV", "BW", "BX", "BY", "BZ"];
	
	//----------------------------------
	//  rgxNotAllowed
	//----------------------------------
	/**
	 * Regular Expression that matches characters not allowed in the expression for Calc or Spreadsheet, e.g. '~'
	 * */
	public static var rgxNotAllowed : RegExp = /[^a-zA-Z0-9!\s\+\-\*\/\^\.\(\)\:\,=<>"']/g;
	
	//----------------------------------
	//  Utils
	//----------------------------------
	/**
	 * Constructor. This class contains mostly static methods.
	 * */
	public function Utils()
	{
	}
	
	//----------------------------------
	//  checkValidExpression
	//----------------------------------
	/**
	 * Checks if the string is a valid expression to be accepted by Calc or Spreadsheet and returns an error String.
	 * @param exp String that you want to check if it is a valid expression.
	 * @return String 'ok' if exp is valid expression, error string if not.
	 * */
	public static function checkValidExpression(exp : String) : String
	{
		var err : String = "ok";
		
		var na : Array = exp.match(rgxNotAllowed);
		
		if (na.length > 0)
		{
			err = "!Error: Illegal characters detected:";
			
			for each (var s : String in na)
			{
				err += " " + s;
			}
		}
		
		var leftPars : Array = exp.match(/\(/g);
		var rightPars : Array = exp.match(/\)/g);
		
		if (leftPars.length != rightPars.length)
		{
			err = "!Error: Opening and closing brackets do not match.";
		}
		
		//TODO: Only allow = in the beginning and in IF
		if (exp.indexOf("=") != -1)
		{
			//err = "!Error: '=' can only be used once in the beginning to indicate expression.";
		}
		
		return err;
	}
	
	//----------------------------------
	//  gridFieldToIndexes
	//----------------------------------
	/**
	 * Resolves column names and row numbers to indexes. E.g. from "a0" to [0, 0, null, "A", "0"], from "f6" to [5, 6, null, "F", "6"], from "sheet1!a0 to [0, 0, "sheet1", "A", "0"]"
	 * @param fieldId String that represents the ID of the field or cell in the Spreadsheet.
	 * @return Array with info, [0] int column index, [1] int row index, [2] String sheet id, [3] String column id, [4] String row id
	 *
	 * */
	public static function gridFieldToIndexes(fieldId : String) : Array
	{
		var sheet : String;
		
		if (fieldId.indexOf("!") != -1)
		{
			sheet = fieldId.substr(0, fieldId.indexOf("!"));
			fieldId = fieldId.substr(fieldId.indexOf("!") + 1);
			
		}
		
		var regexps : RegExp = /([a-zA-Z])/g;
		var regexpn : RegExp = /(\d)/g;
		
		var col : String = String(fieldId).replace(regexpn, "").toUpperCase();
		var row : String = String(fieldId).replace(regexps, "");
		
		var intCol : int = col == "" ? -1 : Utils.alphabet.indexOf(col);
		var intRow : int = row == "" ? -1 : int(row);
		
		return [intCol, intRow, sheet, col, row, (col + row)]
	}
	
	//----------------------------------
	//  moveFieldId
	//----------------------------------
	/**
	 * Moves the id of the field for specific dx and dy.
	 * @param fieldId String representing the id of the field or cell
	 * @param dx movement on the x axis
	 * @param dy movement on the y axis
	 * @return new field id, based on the movement
	 * 
	 * @example The following moves filed id from a0 to c1
	 *
	 * <listing version="3.0">
	 * 
	 * var result:String = Utils.moveFieldId("a0", 2, 1);
	 * trace(result); // c1
	 * 
	 * </listing>
	 * */
	public static function moveFieldId(fieldId : String, dx : int, dy : int) : String
	{
		var origOp : String = fieldId;
		
		var colInd : Number = gridFieldToIndexes(origOp)[0];
		var rowInd : Number = gridFieldToIndexes(origOp)[1];
		
		colInd += dx;
		rowInd += dy;
		
		var colErr : String;
		
		if (colInd < 0)
			return null; //colErr = "ColRef"
		
		var rowErr : String;
		
		if (rowInd < 0)
			return null; //rowErr = "RowRef"
		
		var col : String = String(alphabet[colInd]).toLowerCase();
		var row : String = rowInd.toString();
		
		if (colErr)
			col = colErr;
		
		if (rowErr)
			row = rowErr;
		
		var moveOp : String = col + row;
		
		return moveOp;
	}
	
	//----------------------------------
	//  moveExpression
	//----------------------------------
	/**
	 * Moves entire expression of ControlObject by dx and dy.
	 * @param co ControlObject which ContorlObject.exp property you want to move.
	 * @param dx movement on the x axis
	 * @param dy movement on the y axis
	 * @param toGrid if you want to move the expression onto different sheet
	 * @param excludeRule masks the areas of the grid, where you want the movement to appear, in the form of [fromColumn:int, toColumn:int, fromRow:int, toRow:int]
	 * @return String representing an expression that moved
	 * 
	 * */
	public static function moveExpression(co : ControlObject, dx : int, dy : int, toGrid : String = null, excludeRule : Array = null) : String
	{
		var exp : String = co.exp;
		var srx : String = "";
		
		var fc : int = -1;
		var tc : int = -1;
		var fr : int = -1;
		var tr : int = -1;
		
		if (excludeRule)
		{
			fc = excludeRule[0] ? excludeRule[0] : -1;
			tc = excludeRule[1] ? excludeRule[1] : -1;
			fr = excludeRule[2] ? excludeRule[2] : -1;
			tr = excludeRule[3] ? excludeRule[3] : -1;
		}
		
		orepl = new Object();
		
		for each (var op : ControlObject in co.ctrlOperands)
		{
			if (co.grid)
			{
				if ((fc == -1 || op.colIndex >= fc) && (tc == -1 || op.colIndex <= tc) &&
					(fr == -1 || op.rowIndex >= fr) && (tr == -1 || op.colIndex <= tr))
				{
					var origOp : String = op.id;
					var moveOp : String = moveFieldId(origOp, dx, dy);
					orepl[origOp] = moveOp ? moveOp : origOp;
					srx += "(" + origOp + ")";
				}
			}
		}
		
		if (srx != "")
		{
			srx = srx.replace(/\)\(/g, ")|(");
			
			var rx : RegExp = new RegExp(srx, "g");
			exp = exp.replace(rx, frepl);
		}
		return exp;
	}
	
	//----------------------------------
	//  moveExpression2
	//----------------------------------
	/**
	 * Moves entire expression of ControlObject by dx and dy. It calculates the transformations based on temporaryOldID of ControlObject.
	 * @param co ControlObject which ContorlObject.exp property you want to move.
	 * @param dx movement on the x axis
	 * @param dy movement on the y axis
	 * @param toGrid if you want to move the expression onto different sheet
	 * @param excludeRule masks the areas of the grid, where you want the movement to appear, in the form of [fromColumn:int, toColumn:int, fromRow:int, toRow:int]
	 * @return String representing an expression that moved
	 * 
	 * */
	public static function moveExpression2(co : ControlObject, dx : int, dy : int, toGrid : String = null, excludeRule : Array = null) : String
	{
		var exp : String = co.exp;
		var srx : String = "";
		
		var fc : int = -1;
		var tc : int = -1;
		var fr : int = -1;
		var tr : int = -1;
		
		if (excludeRule)
		{
			fc = excludeRule[0] ? excludeRule[0] : -1;
			tc = excludeRule[1] ? excludeRule[1] : -1;
			fr = excludeRule[2] ? excludeRule[2] : -1;
			tr = excludeRule[3] ? excludeRule[3] : -1;
		}
		
		orepl = new Object();
		var origOp : String, moveOp : String;
		
		for each (var op : ControlObject in co.ctrlOperands)
		{
			if ((fc == -1 || op.colIndex >= fc) && (tc == -1 || op.colIndex <= tc) &&
				(fr == -1 || op.rowIndex >= fr) && (tr == -1 || op.colIndex <= tr))
			{
				if (op.temporaryOldID)
				{
					origOp = op.temporaryOldID;
					moveOp = op.id;
				}
				else
				{
					origOp = op.id;
					moveOp = moveFieldId(origOp, dx, dy);
				}
				
				orepl[origOp] = moveOp;
				srx += "(" + origOp + ")";
			}
		}
		
		if (srx != "")
		{
			srx = srx.replace(/\)\(/g, ")|(");
			
			var rx : RegExp = new RegExp(srx, "g");
			exp = exp.replace(rx, frepl);
		}
		
		return exp;
	}
	
	//----------------------------------
	//  resolveFieldsRange
	//----------------------------------
	/**
	 * Resolves range specified as string into array of field id's. 
	 * It works on cell id's such as a1, a2, b1,.. as well as on collections registered by Calc.
	 * 
	 * @param fields String representing the range of fields/cells to resolve.
	 * @return Array containing the ID's of fields/cells in the range.
	 * 
	 * @example The following resolves range on one column specified by collon
	 *
	 * <listing version="3.0">
	 * 
	 * var range:Array = Utils.resolveFieldsRange("a1:a4");
	 * trace(range); // ["a1", "a2", "a3", "a4"]
	 * 
	 * </listing>
	 * 
	 * @example The following resolves range on one row specified by collon
	 *
	 * <listing version="3.0">
	 * 
	 * var range:Array = Utils.resolveFieldsRange("a1:c1");
	 * trace(range); // ["a1", "b1", "c1"]
	 * 
	 * </listing>
	 * 
	 * @example The following resolves range on one row specified by comma
	 *
	 * <listing version="3.0">
	 * 
	 * var range:Array = Utils.resolveFieldsRange("a1,b1,c1");
	 * trace(range); // ["a1", "b1", "c1"]
	 * 
	 * </listing>
	 * 
	 * @example The following resolves square range on multiple rows and columns specified by collon
	 *
	 * <listing version="3.0">
	 * 
	 * var range:Array = Utils.resolveFieldsRange("a1:c2");
	 * trace(range); // ["a1", "a2", "b1", "b2", "c1", "c2"]
	 * 
	 * </listing>
	 * 
	 * */
	public static function resolveFieldsRange(fields : String) : Array
	{
		var range : Array = new Array();
		
		if (fields.indexOf(":") != -1)
		{
			range = fields.split(":");
			
			range = resolveRange(range);
		}
		else if (fields.indexOf(",") != -1)
		{
			range = fields.split(",");
		}
		else
		{
			if (fields.indexOf("*") != -1)
			{
				range = resolveWildCardRange(fields);
			}
			else
			{
				range.push(fields);
			}
			
		}
		
		return range;
	}
	
	//----------------------------------
	//  resolveWildCardRange
	//----------------------------------
	/**
	 * Resolves the range with wildcard * into array of ControlObject id's. 
	 * Works on collections registered with Calc through Calc.addCollection
	 * E.g.: resolveWildCardRange("arrayCol!users!*") // ["arrayCol!users!0", "arrayCol!users!1", "arrayCol!users!2", ... arrayCol!users!N]
	 * @param fields String representing the range of objects to resolve. 
	 * @return Array containing the ID's of objects in the range. This is in the form of CollectionName!ObjectName!IndexInCollection
	 * */
	public static function resolveWildCardRange(fields : String) : Array
	{
		var arr : Array = new Array();
		
		// if we have 3 ! symbols it's collection, if 2 then it's Spreadsheet cell
		var input : Array = fields.split("!");
		
		if (input.length == 3)
		{
			var col : String = input[0];
			var prop : String = input[1];
			var row : String = input[2];
			var length : int = 0;
			
			if (_calc.collections[col])
			{
				length = _calc.collections[col].collection.length;
				
				if (_calc.currentTarget)
				{
					if (_calc.getDependantsOfCollection(_calc.collections[col].collection).indexOf(_calc.currentTarget) == -1)
					{
						_calc.collections[col].dependants.push(_calc.currentTarget);
					}
				}
				
				for (var i : int = 0; i < length; i++)
				{
					var f : String = col + "!" + prop + "!" + i;
					arr.push(f);
				}
				
			}
		}
		
		return arr;
	}
	
	//----------------------------------
	//  resolveRange
	//----------------------------------
	/**
	 * Resolves range specified as string into array of field id's.
	 * @param range Array containing field/cell ID's from which to resolve all the ID's in the range.
	 * @return Array containing all the resolved field/cell ID's  
	 * @example The following resolves square range on multiple rows and columns specified by collon
	 *
	 * <listing version="3.0">
	 * 
	 * var range:Array = Utils.resolveFieldsRange("a1:c2");
	 * trace(range); // ["a1", "a2", "b1", "b2", "c1", "c2"]
	 * 
	 * </listing> 
	 * */
	public static function resolveRange(range : Array) : Array
	{
		
		var ra : Array = new Array();
		var sampleFieldArray : Array = String(range[0]).split("!");
		
		// length of collection args is 3, grid is 2 or 1
		if (sampleFieldArray.length == 3)
		{
			ra = resolveCollectionRange(range);
			return ra;
		}
		
		var f1ColInd : int = gridFieldToIndexes(range[0])[0];
		var f1RowInd : int = gridFieldToIndexes(range[0])[1];
		var f1Grid : String = gridFieldToIndexes(range[0])[2];
		
		var f2ColInd : int = gridFieldToIndexes(range[1])[0];
		var f2RowInd : int = gridFieldToIndexes(range[1])[1];
		var f2Grid : String = gridFieldToIndexes(range[1])[2];
		
		var fr : int; //  from row
		var tr : int; // to row
		var fc : int; // from column
		var tc : int; // to column
		
		if (f1RowInd < f2RowInd)
		{
			fr = f1RowInd;
			tr = f2RowInd;
		}
		else
		{
			fr = f2RowInd;
			tr = f1RowInd;
		}
		
		if (f1ColInd < f2ColInd)
		{
			fc = f1ColInd;
			tc = f2ColInd;
		}
		else
		{
			fc = f2ColInd;
			tc = f1ColInd;
		}
		
		if (fr < 0)
			fr = 0;
		
		if (fc < 0)
			fc = 0;
		
		for (var i : int = fr; i <= tr; i++)
		{
			for (var j : int = fc; j <= tc; j++)
			{
				var cellId : String = Utils.alphabet[j].toLowerCase() + i.toString();
				var f : String = f1Grid ? f1Grid + "!" + cellId : cellId;
				ra.push(f);
			}
		}
		
		return ra;
	}
	
	//----------------------------------
	//  resolveCollectionRange
	//----------------------------------
	/**
	 * Resolves the range of ControlObject ID's in a collection that is specified by a range.
	 * @param range Array containing two ID's specifying the range.
	 * @return Array with all the ControlObject ID's that fall into range.
	 * */
	public static function resolveCollectionRange(range : Array) : Array
	{
		var arr : Array = new Array();
		
		if (range.length == 2)
		{
			arr.push(range[0]);
			
			var f1Col : String = String(range[0]).split("!")[0];
			var f1Prop : String = String(range[0]).split("!")[1];
			var f1RowInd : String = String(range[0]).split("!")[2];
			
			var f2Col : String = String(range[1]).split("!")[0];
			var f2Prop : String = String(range[1]).split("!")[1];
			var f2RowInd : String = String(range[1]).split("!")[2];
			
			var r1 : int = int(f1RowInd);
			var r2 : int = int(f2RowInd);
			
			for (var i : int = r1 + 1; i < r2; i++)
			{
				var field : String = f1Col + "!" + f1Prop + "!" + i;
				arr.push(field);
			}
			
			arr.push(range[1]);
		}
		
		return arr;
	
	}
	
	//----------------------------------
	//  frepl
	//----------------------------------
	/**
	 * Part of the frepl/orepl replacement mechanism
	 * */
	private static function frepl() : String
	{
		return orepl[arguments[0]];
	}
	
	//----------------------------------
	//  repairOperators
	//----------------------------------
	/**
	 * This function attempts to repair the misstyped and redundant operators,
	 * by returning only the first valid operator.
	 * e.g.: -+5+*!+/3+, result: -5+3.
	 * Secondly, it attempts to repair redundant operators in parenthesis,
	 * e.g.: (*5+6/), result: (5+6).
	 * @param exp String of expression to attempt to repair.
	 * @return String repaired expression.
	 * */
	public static function repairOperators(exp : String) : String
	{
		
		var rx : RegExp = /([\^\*\+\/\-]{2,})/g;
		
		exp = exp.replace(rx, useFirstOp);
		
		rx = /(\()([\^\*\+\/\-!]+)([A-Za-z0-9~])/g;
		
		exp = exp.replace(rx, "$1$3");
		
		//maybeTODO: temporarily removed * and !
		rx = /([A-Za-z0-9~])([\^\+\/\-!]+)(\))/g;
		
		exp = exp.replace(rx, "$1$3");
		
		return exp;
	}
	
	//----------------------------------
	//  useFirstOp
	//----------------------------------
	/**
	 * Regex replacement function that returns first operator if multiple are given in the expression. Used by repairOperators()
	 * @args Passed in by RegExp.replace.
	 * */
	private static function useFirstOp(... args) : String
	{
		var ops : String = args[0];
		ops = ops.replace(/!/g, "");
		
		ops = ops.substr(0, 1);
		
		return ops;
	}
	
	//----------------------------------
	//  repairExpression
	//----------------------------------
	/**
	 * Replaces ~ by - and removes outer brackets. Eg: "(5 * ~3)", to "5 * -3".
	 * @param exp String represating the expression that needs to be repaired
	 * @return String repaired expression.
	 * */
	public static function repairExpression(exp : String) : String
	{
		exp = exp.replace(/~/g, "-");
		
		exp = exp.replace("(", "");
		exp = exp.substr(0, exp.lastIndexOf(")"));
		
		return exp;
	}
	
	//----------------------------------
	//  breakComparisonInput
	//----------------------------------
	/**
	 * Breaks the comparison string into an object containg arguments and operator.
	 * Eg: "4 >= 6", returns {arg1: 4, arg2: 6, op:">="}.
	 * @param input String Input string that needs to be broken into arguments and operator.
	 * @return Object with the following properties set: arg1, arg2, op.  
	 * */
	public static function breakComparisonInput(input : String) : Object
	{
		var ro : Object = new Object();
		
		var regex : RegExp = /([^<>=]+)([<>=]+)([^<>=]+)/g;
		
		var regex1 : RegExp = /[<>=]+/g;
		
		var opArr : Array = input.match(regex1);
		var op : String = opArr[0];
		var arr : Array = input.split(op);
		
		//var rs:String = input.replace(regex, doBreakCompInput);
		//var rs:String = input.replace(regex, "$1_$2_$3");
		//var arr:Array = rs.split("_");
		
		/*ro.arg1 = arr[0];
		   ro.op = arr[1];
		   ro.arg2 = arr[2];
		 */
		
		ro.arg1 = arr[0] == "" ? null : arr[0];
		ro.op = op;
		ro.arg2 = arr[1];
		
		return ro;
	}
	
	//----------------------------------
	//  isString
	//----------------------------------
	/**
	 * Recognizes if supplied <i>input</i> is supposed to be treated as string within calculation expressions. 
	 * That means it checks wheather it is enclosed in double quotes.
	 * This is not to be confused with ActionScript String class, it is a separate construct that is used in Calc.
	 * <br/><br/>
	 * <b>Example:</b><br/> isString("s"), returns <i>false</i><br/> isString(""s""), returns <i>true</i>
	 * @param input String that needs to be checked if it is a valid string representation for Calc.
	 * @return Boolean true if the specified string is a valid string representation for Calc.
	 * */
	public static function isString(input : String) : Boolean
	{
		var b : Boolean;
		var len : int = input.length;
		
		if (input.substr(0, 1) == "\"" && input.substr(len - 1, 1) == "\"")
		{
			b = true;
		}
		
		if (input.substr(0, 1) == "'" && input.substr(len - 1, 1) == "'")
		{
			b = true;
		}
		
		return b;
	}
	
	//----------------------------------
	//  stripStringQuotes
	//----------------------------------
	/**
	 * Removes quotes from beginning and end of the input String.
	 * @param input String to remove the quotes from.
	 * @return String with removed quotes characters from the beginning and end of input String. 
	 * */
	public static function stripStringQuotes(input : String) : String
	{
		var rs : String;
		var len : int = input.length;
		
		if ((input.substr(0, 1) == "'" && input.substr(len - 1, 1) == "'")
			|| (input.substr(0, 1) == "\"" && input.substr(len - 1, 1) == "\""))
		{
			rs = input.substring(1, len - 1);
		}
		
		return rs;
	}
	
	//----------------------------------
	//  repl
	//----------------------------------
	/**
	 * NOT USED
	 * */
	public static function repl() : void
	{
		var str : String = "my bicycle and my house are better than your bicycle and your house";
		//var str:String = "your bicycle and your house are better than his bicycle and his house";
		
		orepl = new Object();
		orepl.my = "your";
		orepl.your = "his";
		
		var res : Array = new Array();
		var srx : String = "";
		
		for (var repo : Object in orepl)
		{
			srx += "(" + repo + ")";
		}
		
		srx = srx.replace(/\)\(/g, ")|(");
		
		var rx : RegExp = new RegExp(srx, "g");
		str = str.replace(rx, frepl);
	}
	
	//----------------------------------
	//  calc
	//----------------------------------
	/**
	 * Occasionally Utils need reference to Calc to perform some magic.
	 * This is where you set it.
	 * @param calc Instance of Calc that you want Utils to have reference to.
	 * */
	public static function set calc(value : Calc) : void
	{
		_calc = value;
	
	}

}
}