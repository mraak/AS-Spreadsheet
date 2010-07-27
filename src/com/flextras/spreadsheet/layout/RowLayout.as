package com.flextras.spreadsheet.layout
{
import com.flextras.spreadsheet.Spreadsheet;
import com.flextras.spreadsheet.core.spreadsheet;
import com.flextras.spreadsheet.itemRenderers.RowHeaderItemRenderer;

import mx.core.ILayoutElement;

import spark.components.supportClasses.GroupBase;
import spark.layouts.supportClasses.LayoutBase;

use namespace spreadsheet;

/**
 *
 *
 */
public class RowLayout extends LayoutBase
{
	/**
	 *
	 *
	 */
	public function RowLayout()
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
		
		var heights : Array = host.rowHeights;
		
		if (!heights)
			return;
		
		var target : GroupBase = this.target;
		var element : ILayoutElement;
		var y : Number = 0, h : Number;
		
		for (var i : int, n : int = heights.length; i < n; ++i)
		{
			h = heights[i].value;
			
			element = target.getVirtualElementAt(i);
			element.setLayoutBoundsPosition(0, y);
			element.setLayoutBoundsSize(target.width, h);
			
			if(element is RowHeaderItemRenderer)
				RowHeaderItemRenderer(element).host = host;
			
			y += h;
		}
		
		target.setContentSize(target.width, y);
	}
}
}
