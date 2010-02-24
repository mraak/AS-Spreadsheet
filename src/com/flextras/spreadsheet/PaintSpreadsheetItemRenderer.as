package com.flextras.spreadsheet
{
import com.flextras.paintgrid.PaintGrid2ColumnItemRenderer;
import com.flextras.paintgrid.PaintGridRowResizeSkin;

import flash.display.DisplayObject;
import flash.display.Graphics;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Point;

import mx.core.IFlexDisplayObject;
import mx.core.mx_internal;
import mx.events.SandboxMouseEvent;
import mx.managers.CursorManager;
import mx.managers.CursorManagerPriority;
import mx.skins.halo.DataGridColumnResizeSkin;

use namespace mx_internal;

public class PaintSpreadsheetItemRenderer extends PaintGrid2ColumnItemRenderer
{
	
	private var resizeCursorID : int = CursorManager.NO_CURSOR;
	
	private var start : Point = new Point();
	
	private var min : Point = new Point();
	
	private var last : Point;
	
	private var resizeGraphic : IFlexDisplayObject;
	
	protected var verticalSeparator : Sprite;
	
	protected var horizontalSeparator : Sprite;
	
	public function PaintSpreadsheetItemRenderer ()
	{
		super();
		
		minHeight = 20;
	}
	
	public function set showSeparators (value : Boolean) : void
	{
		verticalSeparator.visible = horizontalSeparator.visible = value;
	}
	
	override protected function createChildren () : void
	{
		super.createChildren();
		
		if (!verticalSeparator)
		{
			verticalSeparator = new Sprite();
			verticalSeparator.addEventListener(MouseEvent.MOUSE_OVER, verticalSeparator_mouseOverHandler);
			verticalSeparator.addEventListener(MouseEvent.MOUSE_OUT, separator_mouseOutHandler);
			verticalSeparator.addEventListener(MouseEvent.MOUSE_DOWN, verticalSeparator_mouseDownHandler);
			verticalSeparator.visible = false;
			
			addChild(verticalSeparator);
		}
		
		if (!horizontalSeparator)
		{
			horizontalSeparator = new Sprite();
			horizontalSeparator.addEventListener(MouseEvent.MOUSE_OVER, horizontalSeparator_mouseOverHandler);
			horizontalSeparator.addEventListener(MouseEvent.MOUSE_OUT, separator_mouseOutHandler);
			horizontalSeparator.addEventListener(MouseEvent.MOUSE_DOWN, horizontalSeparator_mouseDownHandler);
			horizontalSeparator.visible = false;
			
			addChild(horizontalSeparator);
		}
	}
	
	override protected function updateDisplayList (w : Number, h : Number) : void
	{
		super.updateDisplayList(w, h);
		
		verticalSeparator.x = w - 2;
		horizontalSeparator.y = h - 2;
		
		showSeparators = dataGrid is PaintSpreadsheet && PaintSpreadsheet(dataGrid).isCtrl && cell && cell.selected;
		
		drawSeparator(verticalSeparator, 0, 0, 2, h);
		drawSeparator(horizontalSeparator, 0, 0, w - 2, 2);
	}
	
	protected function drawSeparator (s : Sprite, x : Number, y : Number, w : Number, h : Number) : void
	{
		var g : Graphics = s.graphics;
		
		g.clear();
		g.beginFill(0, 0.4);
		g.drawRect(x, y, w, h);
		g.endFill();
	}
	
	protected function drawResizeGraphic (x : Number, y : Number, w : Number, h : Number, resizeSkinClass : Class) : void
	{
		resizeGraphic = new resizeSkinClass();
		
		if (resizeGraphic is Sprite)
			Sprite(resizeGraphic).mouseEnabled = false;
		
		dataGrid.addChild(DisplayObject(resizeGraphic));
		
		resizeGraphic.move(x, y);
		resizeGraphic.setActualSize(isNaN(w) ? resizeGraphic.measuredWidth : w, isNaN(h) ? resizeGraphic.measuredHeight : h);
	}
	
	protected function clearResizeGraphic () : void
	{
		dataGrid.removeChild(DisplayObject(resizeGraphic));
		resizeGraphic = null;
	}
	
	//--------------------------------------------------------------------------
	//
	//  Event handlers
	//
	//--------------------------------------------------------------------------
	
	private function verticalSeparator_mouseOverHandler (event : MouseEvent) : void
	{
		dataGrid.preventFromEditing = true;
		
		var stretchCursorClass : Class = getStyle("stretchCursor");
		resizeCursorID = cursorManager.setCursor(stretchCursorClass, CursorManagerPriority.HIGH, 0, 0);
		
		var cursorHolder : DisplayObject = systemManager.cursorChildren.getChildByName("cursorHolder");
		
		if (cursorHolder)
			cursorHolder.rotation = 0;
	}
	
	private function horizontalSeparator_mouseOverHandler (event : MouseEvent) : void
	{
		dataGrid.preventFromEditing = true;
		
		var stretchCursorClass : Class = getStyle("stretchCursor");
		resizeCursorID = cursorManager.setCursor(stretchCursorClass, CursorManagerPriority.HIGH, 0, 0);
		
		var cursorHolder : DisplayObject = systemManager.cursorChildren.getChildByName("cursorHolder");
		
		if (cursorHolder)
			cursorHolder.rotation = 90;
	}
	
	private function separator_mouseOutHandler (event : MouseEvent) : void
	{
		dataGrid.preventFromEditing = false;
		
		cursorManager.removeCursor(resizeCursorID);
	}
	
	private function verticalSeparator_mouseDownHandler (event : MouseEvent) : void
	{
		start.x = DisplayObject(event.target).x + x;
		last = dataGrid.globalToLocal(new Point(event.stageX, event.stageY));
		
		min.x = x + minWidth;
		
		var sbRoot : DisplayObject = systemManager.getSandboxRoot();
		sbRoot.addEventListener(MouseEvent.MOUSE_MOVE, columnResizingHandler, true);
		sbRoot.addEventListener(MouseEvent.MOUSE_UP, verticalSeparator_mouseUpHandler, true);
		sbRoot.addEventListener(SandboxMouseEvent.MOUSE_UP_SOMEWHERE, verticalSeparator_mouseUpHandler);
		systemManager.deployMouseShields(true);
		
		drawResizeGraphic(start.x, 0, NaN, dataGrid.height / dataGrid.scaleY, DataGridColumnResizeSkin);
	}
	
	private function horizontalSeparator_mouseDownHandler (event : MouseEvent) : void
	{
		start.y = DisplayObject(event.target).y + y;
		last = dataGrid.globalToLocal(new Point(event.stageX, event.stageY));
		
		min.y = y + minHeight;
		
		var sbRoot : DisplayObject = systemManager.getSandboxRoot();
		sbRoot.addEventListener(MouseEvent.MOUSE_MOVE, rowResizingHandler, true);
		sbRoot.addEventListener(MouseEvent.MOUSE_UP, horizontalSeparator_mouseUpHandler, true);
		sbRoot.addEventListener(SandboxMouseEvent.MOUSE_UP_SOMEWHERE, horizontalSeparator_mouseUpHandler);
		systemManager.deployMouseShields(true);
		
		drawResizeGraphic(0, start.y, dataGrid.width / dataGrid.scaleX, NaN, PaintGridRowResizeSkin);
	}
	
	private function columnResizingHandler (event : MouseEvent) : void
	{
		if (!event.buttonDown)
		{
			verticalSeparator_mouseUpHandler(event);
			return;
		}
		
		var vsw : int = dataGrid.vScrollBar ? dataGrid.vScrollBar.width : 0;
		
		last = dataGrid.globalToLocal(new Point(event.stageX, event.stageY));
		resizeGraphic.move(Math.min(Math.max(min.x, last.x), (dataGrid.width / dataGrid.scaleX) - vsw), 0);
	}
	
	private function rowResizingHandler (event : MouseEvent) : void
	{
		if (!event.buttonDown)
		{
			horizontalSeparator_mouseUpHandler(event);
			return;
		}
		
		var hsw : int = dataGrid.hScrollBar ? dataGrid.hScrollBar.height : 0;
		
		last = dataGrid.globalToLocal(new Point(event.stageX, event.stageY));
		resizeGraphic.move(0, Math.min(Math.max(min.y, last.y), (dataGrid.height / dataGrid.scaleY) - hsw));
	}
	
	private function verticalSeparator_mouseUpHandler (event : Event) : void
	{
		if (!enabled || !dataGrid.resizableColumns)
			return;
		
		var sbRoot : DisplayObject = systemManager.getSandboxRoot();
		sbRoot.removeEventListener(MouseEvent.MOUSE_MOVE, columnResizingHandler, true);
		sbRoot.removeEventListener(MouseEvent.MOUSE_UP, verticalSeparator_mouseUpHandler, true);
		sbRoot.removeEventListener(SandboxMouseEvent.MOUSE_UP_SOMEWHERE, verticalSeparator_mouseUpHandler);
		systemManager.deployMouseShields(false);
		
		clearResizeGraphic();
		
		var vsw : int = dataGrid.vScrollBar ? dataGrid.vScrollBar.width : 0;
		
		var pt : Point = event is MouseEvent ? dataGrid.globalToLocal(new Point(MouseEvent(event).stageX, MouseEvent(event).stageY)) : last;
		
		var widthChange : Number = Math.min(Math.max(min.x, pt.x), (dataGrid.width / dataGrid.scaleX) - vsw) - start.x;
		dataGrid.setColumnWidthAt(cell.column, Math.floor(width + widthChange));
		
		invalidateDisplayList();
	}
	
	private function horizontalSeparator_mouseUpHandler (event : Event) : void
	{
		if (!enabled || !dataGrid.resizableColumns)
			return;
		
		var sbRoot : DisplayObject = systemManager.getSandboxRoot();
		sbRoot.removeEventListener(MouseEvent.MOUSE_MOVE, rowResizingHandler, true);
		sbRoot.removeEventListener(MouseEvent.MOUSE_UP, horizontalSeparator_mouseUpHandler, true);
		sbRoot.removeEventListener(SandboxMouseEvent.MOUSE_UP_SOMEWHERE, horizontalSeparator_mouseUpHandler);
		systemManager.deployMouseShields(false);
		
		clearResizeGraphic();
		
		var hsw : int = dataGrid.hScrollBar ? dataGrid.hScrollBar.height : 0;
		
		var pt : Point = event is MouseEvent ? dataGrid.globalToLocal(new Point(MouseEvent(event).stageX, MouseEvent(event).stageY)) : last;
		
		var heightChange : Number = Math.min(Math.max(min.y, pt.y), (dataGrid.height / dataGrid.scaleY) - hsw) - start.y;
		dataGrid.setRowHeightAt(cell.row, Math.floor(height + heightChange));
		
		invalidateDisplayList();
	}
}
}