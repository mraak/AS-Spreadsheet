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
 *
 *
 */
public class ColumnLayout extends LayoutBase
{
	/**
	 *
	 *
	 */
	public function ColumnLayout()
	{
		super();
	}
	
	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------
	
	/**
	 *
	 */
	public var host : Spreadsheet;
	
	override public function updateDisplayList(width : Number, height : Number) : void
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
			w = widths[i].value;
			
			element = target.getVirtualElementAt(i);
			element.setLayoutBoundsPosition(x, 0);
			element.setLayoutBoundsSize(w, target.height);
			
			if(element is ColumnHeaderItemRenderer)
				ColumnHeaderItemRenderer(element).host = host;
			
			x += w;
		}
		
		target.setContentSize(x, target.height);
	}
}
}
