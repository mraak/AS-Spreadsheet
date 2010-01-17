package com.flextras.calc
{
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
		public static const NA:String 		= "na";
		
		
		public static const functions:Array = [SUM, AVERAGE, MAX, MIN, ROUND, FLOOR, CEIL,
											COUNT, MEDIAN, NA];
		
		public function FormulaBasic()
		{
			//TODO: implement function
		}
		
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
			if(formula == NA) res = solveNA();
			
			
			return res;
		}
		
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
		
		public static function solveAVERAGE(args:Array):String
		{
			var res:Number = 0;
			res = Number(solveSUM(args)) / args.length;
			return res.toString();
		}
		
		public static function solveMIN(args:Array):String
		{
			var res:Number = args[0];
			
			for each(var arg:Number in args)
			{
				if(arg < res) res = arg;
			}
			
			return res.toString();
		}
		
		public static function solveMAX(args:Array):String
		{
			var res:Number = args[0];
			
			for each(var arg:Number in args)
			{
				if(arg > res) res = arg;
			}
			
			return res.toString();
		}
		
		public static function solveROUND(args:Array):String
		{
			var res:Number = args[0];
			return Math.round(res).toString();
		}
		
		public static function solveFLOOR(args:Array):String
		{
			var res:Number = args[0];
			return Math.floor(res).toString();
		}
		
		public static function solveCEIL(args:Array):String
		{
			var res:Number = args[0];
			return Math.ceil(res).toString();
			
		}
		
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
		
		public static function solveNA():String
		{
			return "#NA";
		}

	}
}