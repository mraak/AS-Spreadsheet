package com.flextras.spreadsheet
{
	import com.flextras.paintgrid.IPaintGridItemRenderer;

	/**
	 * This defines the interface for any class intended to be used as an itemRenderer within the Flextras spreadsheet.
	 * 
	 * @see SpreadsheetItemRenderer 
	 */
	public interface ISpreadsheetItemRenderer extends IPaintGridItemRenderer
	{
		/**
		 * 
		 */
		function get showSeparators():Boolean;
		/**
		 * @private 
		 */
		function set showSeparators(value:Boolean):void;
	}
}