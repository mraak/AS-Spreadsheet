package com.flextras.calc
{
	
	/**
	 * This class contains static functions that only return a value and do not
	 * perform any calculation or logical decisions. For example PI, #NA, etc.
	 * This class does not need to be implemented, it relies on static methods. 
	 * <br/><br/>
	 * Supported forumlas are: NA, PI
	 * 
	 * @see com.flextras.calc.FormulaBasic
	 * @see com.flextras.calc.FormulaLogic
	 * */
	public class FormulaConst
	{
		public static const NA:String 		= "na";
		public static const PI:String 		= "pi";
		
		//----------------------------------
		//  functions
		//----------------------------------
		/**
		 * Contains all the formulas supported by this class. 
		 * */
		public static const functions:Array = [NA, PI];
		
		//----------------------------------
		//  FormulaConst
		//----------------------------------
		public function FormulaConst()
		{
			
		}
		
		//----------------------------------
		//  solve
		//----------------------------------
		/**
		 * Main function to solve any formula.
		 * @param formula Formula that you wish to solve. You can use static constants such as FormulaConst.PI
		 * @return String representing the numeric solution to the formula
		 * 
		 * @example PI
		 *
		 * <listing version="3.0">
		 * 
		 * var result:String = FormulaConst.solve(FormulaConst.PI);
		 * trace(result); // 6
		 * 
		 * </listing>
		 * */
		public static function solve(formula:String):String
		{
			
			var res:String;
			
			formula = formula.toLowerCase();
			
			if(formula == NA) res = solveNA();
			if(formula == PI) res = solvePI();
			
			return res;
		
		}
		
		//----------------------------------
		//  solveNA
		//----------------------------------
		/**
		 * Returns '#NA'
		 * */
		public static function solveNA():String
		{
			return "'#NA'";
		}
		
		//----------------------------------
		//  solvePI
		//----------------------------------
		/**
		 * Returns '3.141592653589793'
		 * */
		public static function solvePI():String
		{
			var pi : Number = Math.PI;
			return pi.toString();
		}
		

	}
}