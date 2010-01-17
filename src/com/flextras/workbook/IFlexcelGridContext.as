package com.flextras.workbook
{
	import flash.events.ContextMenuEvent;
	
	public interface IFlexcelGridContext
	{
		function cmSelect(evt:ContextMenuEvent):void;
		
		function cmInsertColumn(evt:ContextMenuEvent):void;
		
		function cmInsertRow(evt:ContextMenuEvent):void;
		
		function cmDeleteColumn(evt:ContextMenuEvent):void;
		
		function cmDeleteRow(evt:ContextMenuEvent):void;
		
		function cmClearColumn(evt:ContextMenuEvent):void;
		
		function cmClearRow(evt:ContextMenuEvent):void;
		
	}
}