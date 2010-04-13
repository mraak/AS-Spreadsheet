package com.flextras.spreadsheet
{
	import com.flextras.paintgrid.IPaintGridItemRenderer;

	public interface ISpreadsheetItemRenderer extends IPaintGridItemRenderer
	{
		function get showSeparators():Boolean;
		function set showSeparators(value:Boolean):void;
	}
}