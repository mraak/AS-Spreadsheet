package com.flextras.spreadsheet.layout
{
import com.flextras.spreadsheet.Spreadsheet;
import com.flextras.spreadsheet.core.spreadsheet;
import com.flextras.spreadsheet.vos.Cell;
import com.flextras.spreadsheet.vos.CellHeight;
import com.flextras.spreadsheet.vos.CellWidth;

import mx.core.ILayoutElement;

import spark.components.IItemRenderer;
import spark.components.supportClasses.GroupBase;
import spark.core.NavigationUnit;
import spark.layouts.supportClasses.LayoutBase;

use namespace spreadsheet;

public class GridLayout extends LayoutBase
{
	protected var xs : Array;
	protected var ys : Array;
	
	protected var widths : Array;
	protected var heights : Array;
	
	protected var columns : Array;
	protected var rows : Array;
	
	protected var columnCount : int, rowCount : int;
	
	public var host : Spreadsheet;
	
	public function GridLayout()
	{
		super();
	}
	
	protected var width : Number, height : Number;
	
	override public function updateDisplayList(width : Number, height : Number) : void
	{
		super.updateDisplayList(width, height);
		
		this.width = width;
		this.height = height;
		
		if (useVirtualLayout)
			updateDisplayListVirtual();
		else
			updateDisplayListReal();
	}
	
	protected function updateDisplayListVirtual() : void
	{
		//trace("virtual");
	}
	
	protected function updateDisplayListReal() : void
	{
		columnCount = host.columnCount;
		rowCount = host.rowCount;
		
		if (columnCount < 1 || rowCount < 1)
			return;
		
		var preferredWidths : Array = host.preferredColumnWidths;
		var preferredHeights : Array = host.preferredRowHeights;
		
		var target : GroupBase = this.target;
		var element : ILayoutElement;
		var cell : Cell;
		var column : Array;
		var row : Array;
		var x : Number, y : Number;
		var cs : uint, rs : uint;
		var width : CellWidth, height : CellHeight;
		var w : CellWidth, h : CellHeight;
		var mw : Number, mh : Number;
		var spans : Array = [];
		var hasSpan : Boolean;
		
		xs = [], ys = [], widths = [], heights = [], columns = [], rows = [];
		
		for (var i : int, n : int = target.numElements; i < n; ++i)
		{
			element = target.getElementAt(i);
			cell = Cell(IItemRenderer(element).data);
			
			column = columns[cell.columnIndex] || [];
			row = rows[cell.rowIndex] || [];
			
			column[cell.rowIndex] = cell;
			row[cell.columnIndex] = cell;
			
			columns[cell.columnIndex] = column;
			rows[cell.rowIndex] = row;
			
			width = widths[cell.columnIndex] || new CellWidth;
			height = heights[cell.rowIndex] || new CellHeight;
			
			cell.width = element.getPreferredBoundsWidth();
			cell.height = element.getPreferredBoundsHeight();
			
			if (cell.columnSpan > 0)
				hasSpan = true;
			else
			{
				width.measured = cell.width;
				width.preferred = preferredWidths[cell.columnIndex];
			}
			
			if (cell.rowSpan > 0)
				hasSpan = true;
			else
			{
				height.measured = cell.height;
				height.preferred = preferredHeights[cell.rowIndex];
			}
			
			if (hasSpan)
			{
				spans.push(cell);
				
				hasSpan = false;
			}
			
			widths[cell.columnIndex] = width;
			heights[cell.rowIndex] = height;
		}
		
		var ns : int = spans.length;
		var j : int;
		
		for (i = 0; i < ns; ++i)
		{
			cell = spans[i];
			
			if (cell.columnSpan)
			{
				cs = cell.bounds.right;
				
				mw = cell.width;
				cell.width = 0;
				
				for (j = cell.columnIndex; j < cs; ++j)
				{
					w = widths[j] || new CellWidth;
					
					cell.width += w.value;
					
					widths[j] = w;
				}
				
				w = widths[cs] || new CellWidth;
				
				w.measured = mw - cell.width;
				cell.width += w.value;
				
				widths[cs] = w;
			}
			
			if (cell.rowSpan)
			{
				rs = cell.bounds.bottom;
				
				mh = cell.height;
				cell.height = 0;
				
				for (j = cell.rowIndex; j < rs; ++j)
				{
					h = heights[j] || new CellHeight;
					
					cell.height += h.value;
					
					heights[j] = h;
				}
				
				h = heights[rs] || new CellHeight;
				
				h.measured = mh - cell.height;
				cell.height += h.value;
				
				heights[rs] = h;
			}
		}
		
		host.columnWidths = widths;
		host.rowHeights = heights;
		
		mw = 0;
		
		for (i = 0; i < columnCount; ++i)
			if (widths[i])
				mw += widths[i].value; // + 1;
		
		mh = 0;
		
		for (i = 0; i < rowCount; ++i)
			if (heights[i])
				mh += heights[i].value; // + 1;
		
		target.setContentSize(mw, mh);
		target.measuredWidth = mw;
		target.measuredHeight = mh;
		
		for (i = 0; i < n; ++i)
		{
			element = target.getElementAt(i);
			cell = Cell(IItemRenderer(element).data);
			
			x = xs[cell.columnIndex];
			y = ys[cell.rowIndex];
			
			if (isNaN(x))
			{
				x = 0;
				
				for (j = 0; j < cell.columnIndex; ++j)
					if (widths[j])
						x += widths[j].value; // + 1;
				
				xs[cell.columnIndex] = x;
			}
			
			if (isNaN(y))
			{
				y = 0;
				
				for (j = 0; j < cell.rowIndex; ++j)
					if (heights[j])
						y += heights[j].value; // + 1;
				
				ys[cell.rowIndex] = y;
			}
			
			width = widths[cell.columnIndex];
			height = heights[cell.rowIndex];
			
			element.setLayoutBoundsPosition(x, y);
			element.setLayoutBoundsSize(cell.columnSpan ? cell.width : width.value, cell.rowSpan ? cell.height : height.value);
		}
	
	/*var handler : Sprite;
	
	   for (i = 1, n = xs.length; i < n; ++i)
	   {
	   handler = new Sprite;
	   handler.x = xs[i];
	   handler.width = 1;
	   handler.height = mh;
	   handler.graphics.beginFill(0xff0000);
	   handler.graphics.drawRect(0, 0, 1, mh);
	   handler.graphics.endFill();
	
	   target.addChild(handler);
	 }*/
	}
	
	protected var elementsChanged : Boolean;
	
	override public function elementAdded(index : int) : void
	{
		elementsChanged = true;
	}
	
	override public function elementRemoved(index : int) : void
	{
		elementsChanged = true;
	}
	
	override public function clearVirtualLayoutCache() : void
	{
	
	}
	
	override public function getNavigationDestinationIndex(currentIndex : int, navigationUnit : uint, arrowKeysWrapFocus : Boolean) : int
	{
		if (currentIndex < 0)
			return 0;
		
		var result : int = super.getNavigationDestinationIndex(currentIndex, navigationUnit, arrowKeysWrapFocus);
		
		if (result > -1)
			return result;
		
		var cell : Cell = host.indexedCells[host.getIdByIndex(currentIndex)];
		
		if (!cell)
			return -1;
		
		var target : GroupBase = this.target;
		
		if (!target || target.numElements < 1)
			return -1;
		
		var lastElementIndex : int = target.numElements - 1;
		
		var column : int = cell.columnIndex;
		var row : int = cell.rowIndex;
		
		switch (navigationUnit)
		{
			case NavigationUnit.LEFT:
				column = Math.max(0, column - 1);
				break;
			
			case NavigationUnit.RIGHT:
				column = Math.min(columnCount - 1, column + cell.columnSpan + 1);
				break;
			case NavigationUnit.UP:
				row = Math.max(0, row - 1);
				break;
			
			case NavigationUnit.DOWN:
				row = Math.min(rowCount - 1, row + cell.rowSpan + 1);
				break;
			
			default:
				return -1;
		}
		
		return host.getElementIndex(column, row);
	}
}
}