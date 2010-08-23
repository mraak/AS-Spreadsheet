package com.flextras.spreadsheet.vos
{
import com.flextras.spreadsheet.core.spreadsheet;

import flash.events.Event;
import flash.events.EventDispatcher;

use namespace spreadsheet;

//----------------------------------
//  Events
//----------------------------------

/**
 *
 */
[Event(name="leftChanged", type="flash.events.Event")]

/**
 *
 */
[Event(name="topChanged", type="flash.events.Event")]

/**
 *
 */
[Event(name="rightChanged", type="flash.events.Event")]

/**
 *
 */
[Event(name="bottomChanged", type="flash.events.Event")]

[RemoteClass]
/**
 *
 *
 */
public class Border extends EventDispatcher
{
	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------
	
	/**
	 * Constructor.
	 *
	 * @param color
	 * @param alpha
	 * @param weight
	 * @param visible
	 * @param left
	 * @param top
	 * @param right
	 * @param bottom
	 *
	 */
	public function Border (color : uint = 0,
		alpha : Number = 1,
		weight : Number = 1,
		visible : Boolean = true,
		left : BorderSide = null,
		top : BorderSide = null,
		right : BorderSide = null,
		bottom : BorderSide = null)
	{
		this.color = color;
		this.alpha = alpha;
		this.weight = weight;
		this.visible = visible;
		
		this.left = left;
		this.top = top;
		this.right = right;
		this.bottom = bottom;
	}
	
	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------
	
	//----------------------------------
	//  alpha
	//----------------------------------
	
	[Transient]
	/**
	 *
	 * @param value
	 *
	 */
	public function set alpha (value : Number) : void
	{
		left.alpha = top.alpha = right.alpha = bottom.alpha = value;
	}
	
	//----------------------------------
	//  bottom
	//----------------------------------
	
	/**
	 *
	 */
	private var _bottom : BorderSide = new BorderSide;
	
	[Bindable(event="bottomChanged")]
	/**
	 *
	 * @return
	 *
	 */
	public function get bottom () : BorderSide
	{
		return _bottom;
	}
	
	/**
	 *
	 * @param value
	 *
	 */
	public function set bottom (value : BorderSide) : void
	{
		if (bottom === value)
			return;
		
		bottom.assign (value);
		
		dispatchEvent (new Event ("bottomChanged"));
	}
	
	[Transient]
	/**
	 *
	 * @param value
	 *
	 */
	public function set bottomObject (value : Object) : void
	{
		if (!value)
			return;
		
		if (value is BorderSide)
			bottom = BorderSide (value);
		else
		{
			bottom.assignObject (value);
			
			dispatchEvent (new Event ("bottomChanged"));
		}
	}
	
	//----------------------------------
	//  color
	//----------------------------------
	
	[Transient]
	/**
	 *
	 * @param value
	 *
	 */
	public function set color (value : uint) : void
	{
		left.color = top.color = right.color = bottom.color = value;
	}
	
	//----------------------------------
	//  global
	//----------------------------------
	
	/**
	 *
	 * @param value
	 *
	 */
	spreadsheet function set global (value : Border) : void
	{
		if (value)
		{
			left.global = value.left;
			top.global = value.top;
			right.global = value.right;
			bottom.global = value.bottom;
		}
		else
		{
			left.global = null;
			top.global = null;
			right.global = null;
			bottom.global = null;
		}
	}
	
	//----------------------------------
	//  left
	//----------------------------------
	
	/**
	 *
	 */
	private var _left : BorderSide = new BorderSide;
	
	[Bindable(event="leftChanged")]
	/**
	 *
	 * @return
	 *
	 */
	public function get left () : BorderSide
	{
		return _left;
	}
	
	/**
	 *
	 * @param value
	 *
	 */
	public function set left (value : BorderSide) : void
	{
		if (left === value)
			return;
		
		left.assign (value);
		
		dispatchEvent (new Event ("leftChanged"));
	}
	
	[Transient]
	/**
	 *
	 * @param value
	 *
	 */
	public function set leftObject (value : Object) : void
	{
		if (!value)
			return;
		
		if (value is BorderSide)
			left = BorderSide (value);
		else
		{
			left.assignObject (value);
			
			dispatchEvent (new Event ("leftChanged"));
		}
	}
	
	//----------------------------------
	//  right
	//----------------------------------
	
	/**
	 *
	 */
	private var _right : BorderSide = new BorderSide;
	
	[Bindable(event="rightChanged")]
	/**
	 *
	 * @return
	 *
	 */
	public function get right () : BorderSide
	{
		return _right;
	}
	
	/**
	 *
	 * @param value
	 *
	 */
	public function set right (value : BorderSide) : void
	{
		if (right === value)
			return;
		
		right.assign (value);
		
		dispatchEvent (new Event ("rightChanged"));
	}
	
	[Transient]
	/**
	 *
	 * @param value
	 *
	 */
	public function set rightObject (value : Object) : void
	{
		if (!value)
			return;
		
		if (value is BorderSide)
			right = BorderSide (value);
		else
		{
			right.assignObject (value);
			
			dispatchEvent (new Event ("rightChanged"));
		}
	}
	
	//----------------------------------
	//  top
	//----------------------------------
	
	/**
	 *
	 */
	private var _top : BorderSide = new BorderSide;
	
	[Bindable(event="topChanged")]
	/**
	 *
	 * @return
	 *
	 */
	public function get top () : BorderSide
	{
		return _top;
	}
	
	/**
	 *
	 * @param value
	 *
	 */
	public function set top (value : BorderSide) : void
	{
		if (top === value)
			return;
		
		top.assign (value);
		
		dispatchEvent (new Event ("topChanged"));
	}
	
	[Transient]
	/**
	 *
	 * @param value
	 *
	 */
	public function set topObject (value : Object) : void
	{
		if (!value)
			return;
		
		if (value is BorderSide)
			top = BorderSide (value);
		else
		{
			top.assignObject (value);
			
			dispatchEvent (new Event ("topChanged"));
		}
	}
	
	//----------------------------------
	//  visible
	//----------------------------------
	
	[Transient]
	/**
	 *
	 * @param value
	 *
	 */
	public function set visible (value : Boolean) : void
	{
		left.visible = top.visible = right.visible = bottom.visible = value;
	}
	
	//----------------------------------
	//  weight
	//----------------------------------
	
	[Transient]
	/**
	 *
	 * @param value
	 *
	 */
	public function set weight (value : Number) : void
	{
		left.weight = top.weight = right.weight = bottom.weight = value;
	}
	
	//--------------------------------------------------------------------------
	//
	//  Methods
	//
	//--------------------------------------------------------------------------
	
	/**
	 *
	 * @param value
	 *
	 */
	public function assign (value : Border) : void
	{
		if (!value)
			return;
		
		left = value.left;
		top = value.top;
		right = value.right;
		bottom = value.bottom;
	}
	
	/**
	 *
	 * @param value
	 *
	 */
	public function assignObject (value : Object) : void
	{
		if (!value)
			return;
		
		if (value is Border)
		{
			assign (Border (value));
			
			return;
		}
		
		if (value.hasOwnProperty ("color"))
			color = uint (value.color);
		
		if (value.hasOwnProperty ("alpha"))
			alpha = Number (value.alpha);
		
		if (value.hasOwnProperty ("weight"))
			weight = Number (value.weight);
		
		if (value.hasOwnProperty ("visible"))
			visible = Boolean (value.visible);
		
		if (value.hasOwnProperty ("left"))
			leftObject = value.left;
		
		if (value.hasOwnProperty ("top"))
			topObject = value.top;
		
		if (value.hasOwnProperty ("right"))
			rightObject = value.right;
		
		if (value.hasOwnProperty ("bottom"))
			bottomObject = value.bottom;
	}
	
	/**
	 *
	 *
	 */
	spreadsheet function release () : void
	{
		global = null;
	}
}
}