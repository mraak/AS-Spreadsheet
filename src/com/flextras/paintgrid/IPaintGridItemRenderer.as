package com.flextras.paintgrid
{
	public interface IPaintGridItemRenderer
	{
		function get dataGrid():PaintGrid;
		function set dataGrid(value:PaintGrid):void;
		
		function get cell():CellProperties;
		function set cell(value:CellProperties):void;
		
		function get globalCell():CellProperties;
		function set globalCell(value:CellProperties):void;
		
		function get info():Row;
		function set info(value:Row):void;
	}
}