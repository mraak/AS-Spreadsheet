package com.flextras.spreadsheet.utils
{
import flash.display.DisplayObject;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.MouseEvent;
import flash.geom.Point;

import mx.core.mx_internal;
import mx.events.SandboxMouseEvent;
import mx.managers.CursorManager;
import mx.managers.CursorManagerPriority;
import mx.managers.ICursorManager;
import mx.managers.ISystemManager;

import spark.components.supportClasses.ItemRenderer;

use namespace mx_internal;

public class ResizeManager extends EventDispatcher
{
	public static const dispatcher : EventDispatcher = new EventDispatcher;
	
	public static const SHOW_HANDLERS : String = "showHandlers";
	public static const HIDE_HANDLERS : String = "hideHandlers";
	
	[Embed(source="../assets/stretchCursor.png")]
	protected const stretchCursor : Class;
	
	public function ResizeManager()
	{
		autoHide = true;
	}
	
	protected var _autoHide : Boolean;
	
	public function get autoHide() : Boolean
	{
		return _autoHide;
	}
	
	public function set autoHide(value : Boolean) : void
	{
		if (_autoHide)
		{
			dispatcher.removeEventListener(SHOW_HANDLERS, showHandlersHandler);
			dispatcher.removeEventListener(HIDE_HANDLERS, hideHandlersHandler);
		}
		
		_autoHide = value;
		
		_handlersVisible = !value;
		
		if (value)
		{
			dispatcher.addEventListener(SHOW_HANDLERS, showHandlersHandler);
			dispatcher.addEventListener(HIDE_HANDLERS, hideHandlersHandler);
		}
	}
	
	
	public function set target(value : ItemRenderer) : void
	{
		systemManager = value.getNonNullSystemManager();
		cursorManager = value.cursorManager;
		
		root = systemManager.getSandboxRoot();
	}
	
	public var rotation : int;
	public var offset : Point;
	
	protected var systemManager : ISystemManager;
	protected var root : DisplayObject;
	protected var cursorManager : ICursorManager;
	
	public var mouseMoveHandler : Function;
	
	/**
	 * @private
	 */
	protected var resizeCursorID : int = CursorManager.NO_CURSOR;
	
	public function mouseOverHandler(event : MouseEvent) : void
	{
		event.stopImmediatePropagation();
		
		resizeCursorID = cursorManager.setCursor(stretchCursor, CursorManagerPriority.HIGH, offset.x, offset.y);
		
		var cursorHolder : DisplayObject = systemManager.cursorChildren.getChildByName("cursorHolder");
		
		if (cursorHolder)
			cursorHolder.rotation = rotation;
	}
	
	public function mouseOutHandler(event : MouseEvent) : void
	{
		cursorManager.removeCursor(resizeCursorID);
	}
	
	public function mouseDownHandler(event : MouseEvent) : void
	{
		event.stopImmediatePropagation();
		
		root.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler, true);
		root.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler, true);
		root.addEventListener(SandboxMouseEvent.MOUSE_UP_SOMEWHERE, mouseUpHandler);
		
		systemManager.deployMouseShields(true);
	}
	
	public function mouseUpHandler(event : Event) : void
	{
		root.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler, true);
		root.removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler, true);
		root.removeEventListener(SandboxMouseEvent.MOUSE_UP_SOMEWHERE, mouseUpHandler);
		
		systemManager.deployMouseShields(false);
	}
	
	protected var _handlersVisible : Boolean = true;
	
	[Bindable(event="handlersVisibleChanged")]
	public function get handlersVisible() : Boolean
	{
		return _handlersVisible;
	}
	
	protected function showHandlersHandler(e : Event) : void
	{
		_handlersVisible = true;
		
		dispatchEvent(new Event("handlersVisibleChanged"));
	}
	
	protected function hideHandlersHandler(e : Event) : void
	{
		_handlersVisible = false;
		
		dispatchEvent(new Event("handlersVisibleChanged"));
	}
}
}