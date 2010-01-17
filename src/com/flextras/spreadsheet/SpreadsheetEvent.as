package com.flextras.spreadsheet
{
	import flash.events.Event;
	
	/**
	 * SpreasheetEvent carries various information based on the type. Most important, there are 
	 * ERROR, and WARNING types.
	 * - ERROR: In this case, something has happened that will stop the correct execution
	 * of the requested procedure. 
	 * - WARNING: Something has happened that will result in some loss of data but the procedure will run
	 * normally. 
	 * 
	 * */
	public class SpreadsheetEvent extends Event
	{
		public static const ERROR:String = "error";
		public static const WARNING:String = "warning";
		public static const EXPRESSIONS_INITIALIZED:String = "expressionsInitialized";
		public static const CELL_CLICK:String = "cellClick";
		public static const CELL_DOUBLE_CLICK:String = "cellDoubleClick";
		public static const CELL_ROLL_OVER:String = "cellRollOver";
		public static const CELL_ROLL_OUT:String = "cellRollOut";
		public static const CELL_REGISTER:String = "cellRegister";
		
		
		public var message:String;
		public var data:*;
		
		public function SpreadsheetEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}