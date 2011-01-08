package com.flextras.calc
{
/** 
 * This class contains static functions for solving formulas that contain both logical and numerical calculations.
 * This class does not need to be implemented, it relies on static methods.
 * <br/><br/>
 * Supported forumlas are: IF, COUNTIF
 * 
 * @see com.flextras.calc.FormulaConst
 * @see com.flextras.calc.FormulaBasic
 * 
 * */
public class FormulaLogic
{
	
	public static const IF : String = "if";
	
	public static const COUNTIF : String = "countif";
	
	/**
	 * Contains all the formulas supported by this class. 
	 * */
	public static const functions : Array = [IF, COUNTIF];
	
	/**
	 * Constructor. This class does not need to be implemented, it relies on static methods.
	 * */
	public function FormulaLogic ()
	{
	}
	
	
	/**
	 * Main function to solve any formula.
	 * @param formula Formula that you wish to solve. You can use static constants such as FormulaBasic.SUM
	 * @param args Array with arguments to the specific formula. args Array can have complex structure, check the docs for individual formulas.
	 * @return String representing the numeric solution to the formula
	 * 
	 * @example The following code counts how many numbers are supplied AND how many are greater or equal than two.
	 *
	 * <listing version="3.0">
	 * 
	 * var result:String = FormulaLogic.solve(FormulaLogic.COUNTIF, [[1,2,3], ">=", 2);
	 * trace(result); // 2
	 * 
	 * </listing>
	 * */
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
	 * This function compares two values for equality, based on following operators: &lt;, &gt;, =, &lt;=, &gt;=, &lt;&gt;.
	 * @param arg1 First argument
	 * @param op Operator
	 * @param arg2 Second argument
	 * @return Boolean representing if the condition is true
	 * 
	 * @example The following code checks if 1 is greater than 2.
	 *
	 * <listing version="3.0">
	 * 
	 * FormulaLogic.compare(1,">",2);// returns false
	 * 
	 * </listing>
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
	 * Solves the IF formula by evaluating condition and returning appropriate value.
	 * @param args Array has to follow special formation. It has to always contain five elements.
	 * First three elements represent the condition, fourth element is returned if the condition is true, fifth element is returned if condition is false.
	 * <br/>
	 * [0] First argument for the condition 
	 * <br/>
	 * [1] Condition operator, these can be: &lt;, &gt;, =, &lt;=, &gt;=, &lt;&gt;.
	 * <br/>
	 * [2] Second argument for the condition
	 * <br/>
	 * [3] Value that gets returned if the condition is true
	 * <br/>
	 * [4] Value that gets returned if the condition is false
	 * <br/>
	 * @return String representation of the value. It is either [4] or [5] element of the args provided, based on the evaluation of the condition.
	 * 
	 * @example The following code performs IF logic 
	 *
	 * <listing version="3.0">
	 * 
	 * var result:String = FormulaLogic.solveIF(2, "&lt;", 6, "smaller", "bigger");
	 * trace(result); // smaller
	 * 
	 * </listing>
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
	
	/**
	 * Solves COUNTIF formula by counting how many elements are numbers AND match the condition specified.
	 * @param args Array has to follow special formation. It has to always contain three elements:
	 * <br/>
	 * [0] Array of the elements that you want to count, e.g. [12, 3, "d"]
	 * <br/>
	 * [1] String that represents the equality operator, these can be: &lt;, &gt;, =, &lt;=, &gt;=, &lt;&gt;.
	 * <br/>
	 * [2] Number that each element from [0] array is compared against
	 * @return String representing the numeric solution to the formula
	 * 
	 * @example The following code counts how many numbers are supplied AND how many are greater or equal than two.
	 *
	 * <listing version="3.0">
	 * 
	 * var result:String = FormulaLogic.solveCOUNTIF([[1,2,3], ">=", 2);
	 * trace(result); // 2
	 * 
	 * </listing>
	 *  
	 * */
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