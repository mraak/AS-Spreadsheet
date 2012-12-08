
////////////////////////////////////////////////////////////////////////////////
//  
//  Copyright 2012 Alen Balja
//  All Rights Reserved.
//
//  See the file license.txt for copying permission.
//
////////////////////////////////////////////////////////////////////////////////


package uk.co.currentlabel.spreadsheet.utils
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

//----------------------------------
//  Events
//----------------------------------

/**
 * Dispatched when handlersVisible property gets changed.
 */
[Event(name="handlersVisibleChanged", type="flash.events.Event")]

/**
 * ResizeManager adds ability to resize provided target.
 * It also uses custom mouse cursor.
 */
public class ResizeManager extends EventDispatcher
{
	//--------------------------------------------------------------------------
	//
	//  Constants
	//
	//--------------------------------------------------------------------------
	
	/**
	 * Every cell uses same dispatcher for toggling the visibility of resize handlers.
	 */
	public static const dispatcher : EventDispatcher = new EventDispatcher;
	
	/**
	 * Event type is used when resize handler should be shown.
	 */
	public static const SHOW_HANDLERS : String = "showHandlers";
	
	/**
	 * Event type is used when resize handler should be hidden.
	 */
	public static const HIDE_HANDLERS : String = "hideHandlers";
	
	[Embed(source="../assets/stretchCursor.png")]
	/**
	 * @private
	 */
	protected const stretchCursor : Class;
	
	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------
	
	/**
	 * Constructor.
	 */
	public function ResizeManager ()
	{
		autoHide = true;
	}
	
	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------
	
	//----------------------------------
	//  autoHide
	//----------------------------------
	
	/**
	 * @private
	 */
	private var _autoHide : Boolean;
	
	/**
	 * If true user can toggle visibility of resize handlers by lets say keystroke.
	 *
	 * @default true
	 */
	public function get autoHide () : Boolean
	{
		return _autoHide;
	}
	
	/**
	 * @private
	 */
	public function set autoHide (value : Boolean) : void
	{
		if (autoHide)
		{
			dispatcher.removeEventListener (SHOW_HANDLERS, showHandlersHandler);
			dispatcher.removeEventListener (HIDE_HANDLERS, hideHandlersHandler);
		}
		
		_autoHide = value;
		
		_handlersVisible = !value;
		
		if (value)
		{
			dispatcher.addEventListener (SHOW_HANDLERS, showHandlersHandler);
			dispatcher.addEventListener (HIDE_HANDLERS, hideHandlersHandler);
		}
	}
	
	//----------------------------------
	//  target
	//----------------------------------
	
	/**
	 * Target object which should be resized.
	 */
	public function set target (value : ItemRenderer) : void
	{
		systemManager = value.getNonNullSystemManager ();
		cursorManager = value.cursorManager;
		
		root = systemManager.getSandboxRoot ();
	}
	
	/**
	 * Custom cursors rotation.
	 */
	public var rotation : int;
	
	/**
	 * Custom cursors offset position.
	 */
	public var offset : Point;
	
	/**
	 * @private
	 */
	protected var systemManager : ISystemManager;
	
	/**
	 * @private
	 */
	protected var root : DisplayObject;
	
	/**
	 * @private
	 */
	protected var cursorManager : ICursorManager;
	
	/**
	 * Callback function which gets called when user resizes column or row.
	 */
	public var mouseMoveHandler : Function;
	
	/**
	 * @private
	 */
	protected var resizeCursorID : int = CursorManager.NO_CURSOR;
	
	//----------------------------------
	//  handlersVisible
	//----------------------------------
	
	/**
	 * @private
	 */
	private var _handlersVisible : Boolean = true;
	
	[Bindable(event="handlersVisibleChanged")]
	/**
	 *
	 */
	public function get handlersVisible () : Boolean
	{
		return _handlersVisible;
	}
	
	//--------------------------------------------------------------------------
	//
	//  Event handlers
	//
	//--------------------------------------------------------------------------
	
	//----------------------------------
	//  mouseOverHandler
	//----------------------------------
	
	/**
	 * @private
	 */
	public function mouseOverHandler (event : MouseEvent) : void
	{
		event.stopImmediatePropagation ();
		
		resizeCursorID = cursorManager.setCursor (stretchCursor, CursorManagerPriority.HIGH, offset.x, offset.y);
		
		var cursorHolder : DisplayObject = systemManager.cursorChildren.getChildByName ("cursorHolder");
		
		if (cursorHolder)
			cursorHolder.rotation = rotation;
	}
	
	//----------------------------------
	//  mouseOutHandler
	//----------------------------------
	
	/**
	 * @private
	 */
	public function mouseOutHandler (event : MouseEvent) : void
	{
		cursorManager.removeCursor (resizeCursorID);
	}
	
	//----------------------------------
	//  mouseDownHandler
	//----------------------------------
	
	/**
	 * @private
	 */
	public function mouseDownHandler (event : MouseEvent) : void
	{
		event.stopImmediatePropagation ();
		
		root.addEventListener (MouseEvent.MOUSE_MOVE, mouseMoveHandler, true);
		root.addEventListener (MouseEvent.MOUSE_UP, mouseUpHandler, true);
		root.addEventListener (SandboxMouseEvent.MOUSE_UP_SOMEWHERE, mouseUpHandler);
		
		systemManager.deployMouseShields (true);
	}
	
	//----------------------------------
	//  mouseUpHandler
	//----------------------------------
	
	/**
	 * @private
	 */
	public function mouseUpHandler (event : Event) : void
	{
		root.removeEventListener (MouseEvent.MOUSE_MOVE, mouseMoveHandler, true);
		root.removeEventListener (MouseEvent.MOUSE_UP, mouseUpHandler, true);
		root.removeEventListener (SandboxMouseEvent.MOUSE_UP_SOMEWHERE, mouseUpHandler);
		
		systemManager.deployMouseShields (false);
	}
	
	//----------------------------------
	//  showHandlersHandler
	//----------------------------------
	
	/**
	 * @private
	 */
	protected function showHandlersHandler (e : Event) : void
	{
		_handlersVisible = true;
		
		dispatchEvent (new Event ("handlersVisibleChanged"));
	}
	
	//----------------------------------
	//  hideHandlersHandler
	//----------------------------------
	
	/**
	 * @private
	 */
	protected function hideHandlersHandler (e : Event) : void
	{
		_handlersVisible = false;
		
		dispatchEvent (new Event ("handlersVisibleChanged"));
	}
}
}