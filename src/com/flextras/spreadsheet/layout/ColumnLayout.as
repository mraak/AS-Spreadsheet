package com.flextras.spreadsheet.layout
{
import com.flextras.spreadsheet.Spreadsheet;
import com.flextras.spreadsheet.core.spreadsheet;
import com.flextras.spreadsheet.itemRenderers.ColumnHeaderItemRenderer;

import mx.core.ILayoutElement;

import spark.components.supportClasses.GroupBase;
import spark.layouts.supportClasses.LayoutBase;

use namespace spreadsheet;

/**
 * Custom layout which lays its children horizontally.
 */
public class ColumnLayout extends LayoutBase
{
	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------
	
	/**
	 * Constructor.
	 */
	public function ColumnLayout ()
	{
		super ();
	}
	
	//--------------------------------------------------------------------------
	//
	//  Variables
	//
	//--------------------------------------------------------------------------
	
	/**
	 * @private
	 */
	public var host : Spreadsheet;
	
	//--------------------------------------------------------------------------
	//
	//  Overridden methods
	//
	//--------------------------------------------------------------------------
	
	/**
	 * inheritDoc
	 */
	override public function updateDisplayList (width : Number, height : Number) : void
	{
		if (!host)
			return;
		
		var widths : Array = host.columnWidths;
		
		if (!widths)
			return;
		
		var target : GroupBase = this.target;
		var element : ILayoutElement;
		var x : Number = 0, w : Number;
		
		for (var i : int, n : int = widths.length; i < n; ++i)
		{
			if (!widths[i])
				continue;
			
			w = widths[i].value;
			
			element = target.getVirtualElementAt (i);
			element.setLayoutBoundsPosition (x, 0);
			element.setLayoutBoundsSize (w, target.height);
			
			if (element is ColumnHeaderItemRenderer)
				ColumnHeaderItemRenderer (element).host = host;
			
			x += w;
		}
		
		target.setContentSize (x, target.height);
	}
}
}
