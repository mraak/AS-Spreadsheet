package com.flextras.paintgrid
{
import flash.display.DisplayObject;
import flash.display.Shape;

import mx.controls.dataGridClasses.DataGridColumn;
import mx.controls.dataGridClasses.DataGridListData;
import mx.controls.listClasses.IDropInListItemRenderer;
import mx.controls.listClasses.IListItemRenderer;
import mx.core.EdgeMetrics;
import mx.core.UIComponent;
import mx.skins.Border;
import mx.skins.spark.BorderSkin;

public class PaintGridBorder extends UIComponent
{
	public function PaintGridBorder ()
	{
		super();
	}
	
	protected var border : BorderSkin;
	
	protected var overlay : Shape;
	
	protected var dataGrid : PaintGrid;
	
	override protected function createChildren () : void
	{
		dataGrid = parent as PaintGrid;
		
		if (!border)
		{
			var borderClass : Class = dataGrid.getStyle("borderSkin");
			
			border = new borderClass() as BorderSkin;
			border.styleName = styleName;
			
			addChild(border);
		}
		
		if (!overlay)
		{
			overlay = new Shape();
			
			addChild(overlay);
		}
	}
	
	override protected function updateDisplayList (w : Number, h : Number) : void
	{
		overlay.graphics.clear();
		
		border.setActualSize(w, h);
		
		var bm : EdgeMetrics = border.borderMetrics;
		
		while (numChildren > 2)
			removeChildAt(2);
		
		var cols : Array = dataGrid.columns;
		var firstCol : int = dataGrid.horizontalScrollPosition;
		
		var colIndex : int = 0;
		var n : int = cols.length;
		var i : int = 0;
		
		while (colIndex < firstCol)
		{
			if (cols[i++].visible)
				colIndex++;
		}
		
		var vm : EdgeMetrics = dataGrid.viewMetrics;
		var lineCol : uint = dataGrid.getStyle("verticalGridLineColor");
		var vlines : Boolean = dataGrid.getStyle("verticalGridLines");
		
		overlay.graphics.lineStyle(1, lineCol);
		
		var xx : Number = vm.left;
		var yy : Number = h - bm.bottom - dataGrid.rowHeight;
		
		while (xx < w - vm.right)
		{
			var col : DataGridColumn = cols[i++];
			
			var renderer : IListItemRenderer = dataGrid.itemRenderer.newInstance();
			renderer.styleName = col;
			
			if (renderer is IDropInListItemRenderer)
				IDropInListItemRenderer(renderer).listData = new DataGridListData(col.headerText, col.dataField, i - 1, null, dataGrid, -1);
			
			renderer.data = col;
			addChild(DisplayObject(renderer));
			
			renderer.x = xx;
			renderer.y = yy;
			renderer.setActualSize(col.width - 1, dataGrid.rowHeight);
			
			if (vlines)
			{
				overlay.graphics.moveTo(xx + col.width, yy);
				overlay.graphics.lineTo(xx + col.width, h - bm.bottom);
			}
			
			xx += col.width;
		}
		
		lineCol = dataGrid.getStyle("horizontalGridLineColor");
		
		if (dataGrid.getStyle("horizontalGridLines"))
		{
			overlay.graphics.lineStyle(1, lineCol);
			overlay.graphics.moveTo(vm.left, yy);
			overlay.graphics.lineTo(w - vm.right, yy);
		}
	}
	
	/**
	 *  factor in the footer
	 */
	public function get borderMetrics () : EdgeMetrics
	{
		var em : EdgeMetrics = border.borderMetrics.clone();
		em.bottom += dataGrid.rowHeight;
		return em;
	}
}
}