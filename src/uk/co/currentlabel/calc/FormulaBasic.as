package uk.co.currentlabel.calc
{
	/**
	 * This class contains static functions for solving wide range of formulas, as 
	 * found in other popular spreadsheet applications. 
	 * This class contains set of basic formulas, other formulas can be found in 
	 * other classes like FormulaConst and FormulaLogic.
	 * This class does not need to be implemented, it relies on static methods.
	 * <br/><br/>
	 * Supported forumlas are: SUM, AVERAGE, MAX, MIN, ROUND, FLOOR, CEIL, COUNT, MEDIAN
	 * 
	 * @see uk.co.currentlabel.calc.FormulaConst
	 * @see uk.co.currentlabel.calc.FormulaLogic
	 * 
	 * */
	public class FormulaBasic
	{
		public static const SUM:String 		= "sum";
		public static const AVERAGE:String 	= "average";
		public static const MAX:String 		= "max";
		public static const MIN:String 		= "min";
		public static const ROUND:String 	= "round";
		public static const FLOOR:String 	= "floor";
		public static const CEIL:String 	= "ceil";
		public static const COUNT:String 	= "count";
		public static const MEDIAN:String 	= "median";
		
		
		//----------------------------------
		//  functions
		//----------------------------------
		/**
		 * Contains all the formulas supported by this class. 
		 * */
		public static const functions:Array = [SUM, AVERAGE, MAX, MIN, ROUND, FLOOR, CEIL,
												COUNT, MEDIAN];
		
		
		//----------------------------------
		//  FormulaBasic
		//----------------------------------
		/**
		 * Constructor. This class does not need to be implemented, it relies on static methods.
		 * */
		public function FormulaBasic()
		{
			//TODO: implement function
		}
		
		//----------------------------------
		//  solve
		//----------------------------------
		/**
		 * Main function to solve any formula.
		 * @param formula Formula that you wish to solve. You can use static constants such as FormulaBasic.SUM
		 * @param args Array with arguments to the specific formula
		 * @return String representing the numeric solution to the formula
		 * 
		 * @example The following code calculates the sum of numbers 1, 2, and 3.
		 *
		 * <listing version="3.0">
		 * 
		 * var result:String = FormulaBasic.solve(FormulaBasic.SUM, [1,2,3]);
		 * trace(result); // 6
		 * 
		 * </listing>
		 * */
		public static function solve(formula:String, args:Array):String
		{
			var res:String;
			
			formula = formula.toLowerCase();
			
			if(formula == SUM) res = solveSUM(args);
			if(formula == AVERAGE) res = solveAVERAGE(args);
			if(formula == MAX) res = solveMAX(args);
			if(formula == MIN) res = solveMIN(args);
			if(formula == ROUND) res = solveROUND(args);
			if(formula == FLOOR) res = solveFLOOR(args);
			if(formula == CEIL) res = solveCEIL(args);
			if(formula == COUNT) res = solveCOUNT(args);
			if(formula == MEDIAN) res = solveMEDIAN(args);
			
			
			
			return res;
		}
		
		//----------------------------------
		//  solveSUM
		//----------------------------------
		/**
		 * Solves the SUM formula by adding all the numbers in the array.
		 * @param args Array that contains the numbers you wish to add. Function will attempt to cast the elements of the args to Number.
		 * @return String representing the numeric solution to the formula
		 * */
		public static function solveSUM(args:Array):String
		{
			var res:Number = 0;
			
			for each(var arg:String in args)
			{
				res += Number(arg);
			}
			//res = String(res);
			
			return res.toString();
		}
		
		//----------------------------------
		//  solveAVERAGE
		//----------------------------------
		/**
		 * Solves AVERAGE formula by calculating the average value of all the numbers in the array.
		 * @param args Array that contains the numbers you wish to calculate the average from. Function will attempt to cast the elements of the args to Number.
		 * @return String representing the numeric solution to the formula
		 * */
		public static function solveAVERAGE(args:Array):String
		{
			var res:Number = 0;
			res = Number(solveSUM(args)) / args.length;
			return res.toString();
		}
		
		//----------------------------------
		//  solveMIN
		//----------------------------------
		/**
		 * Solves MIN formula by returning the smallest number of those provided in the array.
		 * @param args Array that contains the numbers you wish to calculate the smallest number from. Function will attempt to cast the elements of the args to Number.
		 * @return String representing the numeric solution to the formula
		 * */
		public static function solveMIN(args:Array):String
		{
			var res:Number = args[0];
			
			for each(var arg:Number in args)
			{
				if(arg < res) res = arg;
			}
			
			return res.toString();
		}
		
		//----------------------------------
		//  solveMAX
		//----------------------------------
		/**
		 * Solves MAX formula by returning the smallest number of those provided in the array.
		 * @param args Array that contains the numbers you wish to calculate the smallest number from. Function will attempt to cast the elements of the args to Number.
		 * @return String representing the numeric solution to the formula
		 * */
		public static function solveMAX(args:Array):String
		{
			var res:Number = args[0];
			
			for each(var arg:Number in args)
			{
				if(arg > res) res = arg;
			}
			
			return res.toString();
		}
		
		//----------------------------------
		//  solveROUND
		//----------------------------------
		/**
		 * Rounds the number to the nearest integer. 
		 * @param args Function only takes the first element of the array and rounds it, other elements are ignored. Function will attempt to cast the elements of the args to Number.
		 * @return String representing the numeric solution to the formula
		 * */
		public static function solveROUND(args:Array):String
		{
			var res:Number = args[0];
			return Math.round(res).toString();
		}
		
		//----------------------------------
		//  solveFLOOR
		//----------------------------------
		/**
		 * Rounds the number down to the nearest integer.
		 * @param args Function only takes the first element of the array and rounds it, other elements are ignored. Function will attempt to cast the elements of the args to Number.
		 * @return String representing the numeric solution to the formula
		 * */		
		public static function solveFLOOR(args:Array):String
		{
			var res:Number = args[0];
			return Math.floor(res).toString();
		}
		
		//----------------------------------
		//  solveCEIL
		//----------------------------------
		/**
		 * Rounds the number up to the nearest integer.
		 * @param args Function only takes the first element of the array and rounds it, other elements are ignored. Function will attempt to cast the elements of the args to Number.
		 * @return String representing the numeric solution to the formula
		 * */	
		public static function solveCEIL(args:Array):String
		{
			var res:Number = args[0];
			return Math.ceil(res).toString();
			
		}
		
		//----------------------------------
		//  solveCOUNT
		//----------------------------------
		/**
		 * Solves COUNT formula by counting how many elements in the array are numeric values. E.g. [1, "15", "abc"] returns "2".
		 * @param args Array of values you wish to count. Function will attempt to cast the elements of the args to Number.
		 * @return String representing the numeric solution to the formula
		 * */			
		public static function solveCOUNT(args:Array):String
		{
			var c:int = 0;
			
			for each(var arg:* in args)
			{
				if(!isNaN(Number(arg)))
				{
					c++;
				}

			}
			
			return c.toString();		
		}
		
		//----------------------------------
		//  solveMEDIAN
		//----------------------------------
		/**
		 * Solves MEDIAN formula by calculating the median value of the numbers provided in the array.
		 * @param args Array of values you wish to calculate median from. Function will attempt to cast the elements of the args to Number.
		 * @return String representing the numeric solution to the formula
		 * */	
		public static function solveMEDIAN(args:Array):String
		{
			args.sort();
			var len:int = args.length;
			trace(args);
			var med:Number;
			
			if(len % 2 == 0)
			{
				var s:int = len / 2 - 1;
				
				med = (args[s] + args[s + 1]) / 2;
			}
			else
			{
				med = args[Math.floor(len / 2)];
			}

			return med.toString();
		}
		
	}
}