package com.flextras.calc
{
	
	
	public class Utils
	{
		
		private static var _calc:Calc;
		
		private static var orepl:Object;
		
		public static var rxValidOperand:RegExp = new RegExp("f");
		
		public static var alphabet:Array = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z",
										"AA", "AB", "AC", "AD", "AE", "AF", "AG", "AH", "AI", "AJ", "AK", "AL", "AM", "AN", "AO", "AP", "AQ", "AR", "AS", "AT", "AU", "AV", "AW", "AX", "AY", "AZ",
										"BA", "BB", "BC", "BD", "BE", "BF", "BG", "BH", "BI", "BJ", "BK", "BL", "BM", "BN", "BO", "BP", "BQ", "BR", "BS", "BT", "BU", "BV", "BW", "BX", "BY", "BZ"];
			
		public static var rgxNotAllowed:RegExp = /[^a-zA-Z0-9!\s\+\-\*\/\.\(\)\:\,=<>"']/g;
		
		public function Utils()
		{
			//TODO: implement function
		}
		
		public static function checkValidExpression(exp:String):String
		{
			var err:String = "ok";
			
			var na:Array = exp.match(rgxNotAllowed);
			
			if (na.length > 0)
			{
				err = "!Error: Illegal characters detected:";
				
				for each(var s:String in na)
				{
					err += " " + s;
				}
			}
			
			var leftPars:Array = exp.match(/\(/g);
			var rightPars:Array = exp.match(/\)/g);
			
			if(leftPars.length != rightPars.length)
			{
				err = "!Error: Opening and closing brackets do not match.";
			}
			
			//TODO: Only allow = in the beginning and in IF
			if(exp.indexOf("=") != -1)
			{
				//err = "!Error: '=' can only be used once in the beginning to indicate expression.";
			}
			
			return err;
		}
		
		/**
		 * From "a0" to [0,0], from "f6" to [5,6]
		 *  
		 * */
		public static function gridFieldToIndexes(fieldId:String):Array
		{
			var sheet:String;
			if (fieldId.indexOf("!") != -1)
			{
				sheet = fieldId.substr(0, fieldId.indexOf("!"));
				fieldId = fieldId.substr(fieldId.indexOf("!") + 1);
				
			}
			
			var regexps:RegExp = /([a-zA-Z])/g;
			var regexpn:RegExp = /(\d)/g;
			
			
			var col:String = String(fieldId).replace(regexpn,"").toUpperCase();
			var row:String = String(fieldId).replace(regexps,"");
			
			var intCol:int = col == "" ? -1 : Utils.alphabet.indexOf(col);
			var intRow:int = row == "" ? -1 : int(row);
			
			return [intCol, intRow, sheet, col, row, (col+row)]
		}
		
		
		
		public static function moveFieldId(fieldId:String, dx:int, dy:int):String
		{
			var origOp:String = fieldId;
			
			var colInd:Number = gridFieldToIndexes(origOp)[0];
			var rowInd:Number = gridFieldToIndexes(origOp)[1];
			
			colInd += dx;
			rowInd += dy;
			
			var colErr:String;
			if (colInd < 0 ) colErr = "ColRef"
			
			var rowErr:String;
			if (rowInd < 0 ) rowErr = "RowRef"
			
			var col:String = String(alphabet[colInd]).toLowerCase();
			var row:String = rowInd.toString();
			
			if(colErr) col = colErr;
			if(rowErr) row = rowErr;
			
			var moveOp:String = col+row;
					
			return moveOp;
		}
		
		public static function moveExpression(co:ControlObject, dx:int, dy:int, toGrid:String = null, excludeRule:Array = null):String
		{
			var exp:String = co.exp;
			var srx:String = "";
			
			var fc:int = -1; var tc:int = -1; var fr:int = -1; var tr:int = -1;
			if(excludeRule)
			{
				fc = excludeRule[0] ? excludeRule[0] : -1;
				tc = excludeRule[1] ? excludeRule[1] : -1;
				fr = excludeRule[2] ? excludeRule[2] : -1;
				tr = excludeRule[3] ? excludeRule[3] : -1;	
			}
			
			orepl = new Object();
			
			for each(var op:ControlObject in co.ctrlOperands)
			{
				if(co.grid)
				{
					if((fc == -1 || op.colIndex >= fc) && (tc == -1 || op.colIndex <= tc) &&
						(fr == -1 || op.rowIndex >= fr) && (tr == -1 || op.colIndex <= tr))
						{
							var origOp:String = op.id;
							var moveOp:String = moveFieldId(origOp, dx, dy);
							orepl[origOp] = moveOp;
							srx += "(" + origOp + ")";
						}
				}
			}
			
			if(srx != "")
			{
				srx = srx.replace(/\)\(/g, ")|(");
				
				var rx:RegExp = new RegExp(srx, "g");
				exp = exp.replace(rx, frepl);
			}
			return exp;
		}
		
		
		
		public static function resolveFieldsRange(fields:String):Array
		{
			var range:Array = new Array();
			
			if(fields.indexOf(":") != -1)
			{
				range = fields.split(":");

				range = resolveRange(range);
			}
			else if(fields.indexOf(",") != -1)
			{
				range = fields.split(",");
			}
			else
			{
				if(fields.indexOf("*") != -1)
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
		
		public static function resolveWildCardRange(fields:String):Array
		{
			var arr:Array = new Array();
			
			// if we have 3 ! symbols it's collection, if 2 then it's Spreadsheet cell
			var input:Array = fields.split("!");
			
			
			if(input.length == 3)
			{
				var col:String = input[0];
				var prop:String = input[1];
				var row:String = input[2];
				var length:int = 0;
				
				if(_calc.collections[col])
				{
					length = _calc.collections[col].collection.length;
					
					
					if(_calc.currentTarget)
					{
						if(_calc.getDependantsOfCollection(_calc.collections[col].collection).indexOf(_calc.currentTarget) == -1)
						{
							_calc.collections[col].dependants.push(_calc.currentTarget);
						}
					}
					
					for(var i:int = 0; i < length; i++)
					{
						var f:String = col + "!" + prop + "!" + i;
						arr.push(f);
					}
					
				}
			}
			
			return arr;
		}
		
		
		
		public static function resolveRange(range:Array):Array
		{
			
			var ra:Array = new Array();
			var sampleFieldArray:Array = String(range[0]).split("!");
		
			// length of collection args is 3, grid is 2 or 1
			if(sampleFieldArray.length == 3)
			{
				ra = resolveCollectionRange(range);
				return ra;
			}
			
			
			
			var f1ColInd:int = gridFieldToIndexes(range[0])[0];
			var f1RowInd:int = gridFieldToIndexes(range[0])[1];
			var f1Grid:String = gridFieldToIndexes(range[0])[2];
			
			var f2ColInd:int = gridFieldToIndexes(range[1])[0];
			var f2RowInd:int = gridFieldToIndexes(range[1])[1];
			var f2Grid:String = gridFieldToIndexes(range[1])[2];
			
			
			var fr:int; //  from row
			var tr:int; // to row
			var fc:int; // from column
			var tc:int; // to column
			
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
			
			
			for (var i:int = fr; i <= tr; i++)
			{
				for (var j:int = fc; j <= tc; j++)
				{
					var cellId:String = Utils.alphabet[j].toLowerCase() + i.toString();
					var f:String = f1Grid ? f1Grid + "!" + cellId : cellId;
					ra.push(f);
				}
			}

			return ra;	
		}
		
		public static function resolveCollectionRange(range:Array):Array
		{
			var arr:Array = new Array();
			
			if(range.length == 2)
			{
				arr.push(range[0]);
				
				var f1Col:String 	= String(range[0]).split("!")[0];
				var f1Prop:String 	= String(range[0]).split("!")[1];
				var f1RowInd:String = String(range[0]).split("!")[2];
				
				var f2Col:String 	= String(range[1]).split("!")[0];
				var f2Prop:String 	= String(range[1]).split("!")[1];
				var f2RowInd:String = String(range[1]).split("!")[2];
				
				
				var r1:int = int(f1RowInd);
				var r2:int = int(f2RowInd);
				
				for (var i:int = r1 + 1; i < r2; i++)
				{
					var field:String = f1Col + "!" + f1Prop + "!" + i;
					arr.push(field);
				}
				
				arr.push(range[1]);
			}


			
			return arr;
	
		}
		
		private static function frepl():String
		{
			return orepl[arguments[0]];
		}


		/**
		 * This function attempts to repair the misstyped and redundant operators,
		 * by returning only the first valid operator
		 * e.g.: -+5+*!+/3+, result: -5+3
		 * Secondly, it attempts to repair redundant operators in parenthesis,
		 * e.g.: (*5+6/), result: (5+6)
		 * */
		public static function repairOperators(exp:String):String
		{
			
			var rx:RegExp = /([\*\+\/\-]{2,})/g;
			
			exp = exp.replace(rx, useFirstOp);
			
			rx = /(\()([\*\+\/\-!]+)([A-Za-z0-9~])/g;
			
			exp = exp.replace(rx, "$1$3");

			//TODO: temporarily removed * and !
			rx = /([A-Za-z0-9~])([\+\/\-!]+)(\))/g;
			
			exp = exp.replace(rx, "$1$3");			
			
			return exp;	
		}

		private static function useFirstOp(...args):String
		{
			var ops:String = args[0];
			ops = ops.replace(/!/g,"");
			
			ops = ops.substr(0,1);
			
			return ops;
		}
		
		public static function repairExpression(exp:String):String
		{
			exp = exp.replace(/~/g, "-");
			
			exp = exp.replace("(", "");
			exp = exp.substr(0, exp.lastIndexOf(")"));
			
			return exp;
		}
		
		public static function breakComparisonInput(input:String):Object
		{
			var ro:Object = new Object();
			
			var regex:RegExp = /([^<>=]+)([<>=]+)([^<>=]+)/g;
			
			var regex1:RegExp = /[<>=]+/g;
			
			var opArr:Array = input.match(regex1);
			var op:String = opArr[0];
			var arr:Array = input.split(op);
			
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
		private static function doBreakCompInput():String
		{
			var args:Array = arguments;

			
			var s:String = args[1] + "_" + args[2] + "_" + args[3];
			
			return s;
		}
		
		/**
		 * Recognizes if supplied <i>input</i> is supposed to be treated as string. That means
		 * it checks wheather it is enclosed in double quotes.<br/><br/>
		 * <b>Example:</b><br/> isString("s"), returns <i>false</i><br/> isString(""s""), returns <i>true</i>
		 * 
		 * */
		public static function isString(input:String):Boolean
		{
			var b:Boolean;
			var len:int = input.length;
			
			if(input.substr(0,1) == "\"" && input.substr(len-1,1) == "\"")
			{
				b = true;
			}
			
			if(input.substr(0,1) == "'" && input.substr(len-1,1) == "'")
			{
				b = true;
			}
			
			return b;
		}
		
		
		public static function stripStringQuotes(input:String):String
		{
			var rs:String;
			var len:int = input.length;
			
			if((input.substr(0,1) == "'" && input.substr(len-1,1) == "'")
				|| (input.substr(0,1) == "\"" && input.substr(len-1,1) == "\""))
			{
				rs = input.substring(1, len - 1);
			}


			return rs;
		}
		
		public static function repl():void
		{
			var str:String = "my bicycle and my house are better than your bicycle and your house";
				//var str:String = "your bicycle and your house are better than his bicycle and his house";
				
			orepl = new Object();
			orepl.my = "your";
			orepl.your = "his";
			
			var res:Array = new Array();
			var srx:String = "";
			
			for (var repo:Object in orepl)
			{
				srx += "(" + repo + ")";
			}
			
			srx = srx.replace(/\)\(/g, ")|(");
			
			var rx:RegExp = new RegExp(srx, "g");
			str = str.replace(rx, frepl);
		}
		
		
		public static function set calc(value:Calc):void
		{
			_calc = value;
			
		}
		

	}
}