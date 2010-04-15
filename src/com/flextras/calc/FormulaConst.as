package com.flextras.calc
{
	/**
	 * This class contains static functions that only return a value and do not
	 * perform any calculation or logical decisions. For example PI, #NA, etc. <br/><br/>
	 * 
	 * 
	 * */
	public class FormulaConst
	{
		public static const NA:String 		= "na";
		public static const PI:String 		= "pi";
		
		public static const functions:Array = [NA, PI];
		
		public function FormulaConst()
		{
			
		}
		
		public static function solve(formula:String):String
		{
			
			var res:String;
			
			formula = formula.toLowerCase();
			
			if(formula == NA) res = solveNA();
			if(formula == PI) res = solvePI();
			
			return res;
		
		}
		
		public static function solveNA():String
		{
			return "'#NA'";
		}
		
		public static function solvePI():String
		{
			var pi : Number = Math.PI;
			return pi.toString();
		}
		

	}
}