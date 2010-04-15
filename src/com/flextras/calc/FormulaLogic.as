package com.flextras.calc
{
/**
 * This class contains static functions for solving formulas that contain some 
 * form of boolean logic.
 * 
 * */
public class FormulaLogic
{
	
	public static const IF : String = "if";
	
	public static const COUNTIF : String = "countif";
	
	public static const functions : Array = [IF, COUNTIF];
	
	public function FormulaLogic ()
	{
	}
	
	public static function solve (formula : String, args : Array) : String
	{
		var res : String;
		
		formula = formula.toLowerCase();
		
		if (formula == IF)
			res = solveIF(args);
		
		if (formula == COUNTIF)
			res = solveCOUNTIF(args);
		
		return res;
	}
	
	/**
	 * Supports following ops: &lt;, &gt;, =, &lt;=, &gt;=
	 * <b>Example:</b> FormulaLogic.compare(1,">",2), returns <i>false</i>
	 * */
	public static function compare (arg1 : Number, op : String, arg2 : Number) : Boolean
	{
		var b : Boolean;
		
		if (op == ">")
		{
			if (arg1 > arg2)
				b = true;
		}
		else if (op == "<")
		{
			if (arg1 < arg2)
				b = true;
		}
		else if (op == "=")
		{
			if (arg1 == arg2)
				b = true;
		}
		else if (op == ">=")
		{
			if (arg1 >= arg2)
				b = true;
		}
		else if (op == "<=")
		{
			if (arg1 <= arg2)
				b = true;
		}
		else if (op == "<>")
		{
			if (arg1 != arg2)
				b = true;
		}
		else
		{
			throw(new Error("Unknown comparison operator: " + op));
		}
		
		return b;
	}
	
	/**
	 * arg1 = args[0] <br/>
	 * op 	= args[1] <br/>
	 * arg2 = args[2] <br/>
	 * val1 = args[3] <br/>
	 * val2 = args[4] <br/>
	 * <br/>
	 * IF(arg1 op arg2, val1, val2)
	 *
	 * */
	public static function solveIF (args : Array) : String
	{
		var arg1 : Number = Number(args[0]);
		var op : String = args[1];
		var arg2 : Number = Number(args[2]);
		var val1 : String = args[3];
		var val2 : String = args[4];
		
		var res : String = val1;
		
		if (!compare(arg1, op, arg2))
			res = val2;
		
		return res;
	}
	
	public static function solveCOUNTIF (args : Array) : String
	{
		var range : Array = args[0];
		var op : String = args[1];
		var arg2 : Number = Number(args[2]);
		
		var c : int = 0;
		
		for each (var val : Number in range)
		{
			if (compare(val, op, arg2))
			{
				c++;
			}
		}
		
		return c.toString();
	}

}
}