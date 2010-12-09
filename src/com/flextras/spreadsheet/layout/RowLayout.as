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
 * Custom layout which lays its children vertically.
 */
public class RowLayout extends LayoutBase
{
	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------
	
	/**
	 * Constructor.
	 */
	public function RowLayout ()
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
		
		var heights : Array = host.rowHeights;
		
		if (!heights)
			return;
		
		var target : GroupBase = this.target;
		var element : ILayoutElement;
		var y : Number = 0, h : Number;
		
		for (var i : int, n : int = heights.length; i < n; ++i)
		{
			if (!heights[i])
				continue;
			
			h = heights[i].value;
			
			element = target.getVirtualElementAt (i);
			element.setLayoutBoundsPosition (0, y);
			element.setLayoutBoundsSize (target.width, h);
			
			if (element is RowHeaderItemRenderer)
				RowHeaderItemRenderer (element).host = host;
			
			y += h;
		}
		
		target.setContentSize (target.width, y);
	}
}
}
