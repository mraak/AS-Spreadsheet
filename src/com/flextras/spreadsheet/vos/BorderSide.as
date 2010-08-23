package com.flextras.spreadsheet.vos
{
import com.flextras.spreadsheet.core.spreadsheet;

import flash.events.Event;
import flash.events.EventDispatcher;

use namespace spreadsheet;

/**
 *
 */
[Event(name="colorChanged", type="flash.events.Event")]

/**
 *
 */
[Event(name="alphaChanged", type="flash.events.Event")]

/**
 *
 */
[Event(name="weightChanged", type="flash.events.Event")]

/**
 *
 */
[Event(name="visibleChanged", type="flash.events.Event")]

[RemoteClass]
/**
 *
 *
 */
public class BorderSide extends EventDispatcher
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
	 *
	 */
	public function BorderSide (color : uint = 0, alpha : Number = 1, weight : Number = 1, visible : Boolean = true)
	{
		this.color = color;
		this.alpha = alpha;
		this.weight = weight;
		this.visible = visible;
	}
	
	//--------------------------------------------------------------------------
	//
	//  Variables
	//
	//--------------------------------------------------------------------------
	
	/**
	 *
	 */
	protected var visibleWeight : Number;
	
	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------
	
	//----------------------------------
	//  alpha
	//----------------------------------
	
	/**
	 *
	 */
	private var _alpha : Number = 1;
	
	protected var alphaChanged : Boolean;
	
	[Bindable(event="alphaChanged")]
	/**
	 *
	 * @return
	 *
	 */
	public function get alpha () : Number
	{
		return alphaChanged || !global ? _alpha : global.alpha;
	}
	
	/**
	 *
	 * @param value
	 *
	 */
	public function set alpha (value : Number) : void
	{
		if (alpha == value)
			return;
		
		_alpha = value;
		
		alphaChanged = true;
		
		dispatchAlphaChangedEvent ();
	}
	
	//----------------------------------
	//  color
	//----------------------------------
	
	/**
	 *
	 */
	private var _color : uint;
	
	protected var colorChanged : Boolean;
	
	[Bindable(event="colorChanged")]
	/**
	 *
	 * @return
	 *
	 */
	public function get color () : uint
	{
		return colorChanged || !global ? _color : global.color;
	}
	
	/**
	 *
	 * @param value
	 *
	 */
	public function set color (value : uint) : void
	{
		if (color == value)
			return;
		
		_color = value;
		
		colorChanged = true;
		
		dispatchColorChangedEvent ();
	}
	
	//----------------------------------
	//  global
	//----------------------------------
	
	/**
	 *
	 */
	private var _global : BorderSide;
	
	/**
	 *
	 * @return
	 *
	 */
	spreadsheet function get global () : BorderSide
	{
		return _global;
	}
	
	/**
	 *
	 * @param value
	 *
	 */
	spreadsheet function set global (value : BorderSide) : void
	{
		if (global === value)
			return;
		
		if (global)
		{
			global.removeEventListener ("colorChanged", global_colorChangedHandler);
			global.removeEventListener ("alphaChanged", global_alphaChangedHandler);
			global.removeEventListener ("weightChanged", global_weightChangedHandler);
			global.removeEventListener ("visibleChanged", global_visibleChangedHandler);
		}
		
		_global = value;
		
		if (value)
		{
			value.addEventListener ("colorChanged", global_colorChangedHandler);
			value.addEventListener ("alphaChanged", global_alphaChangedHandler);
			value.addEventListener ("weightChanged", global_weightChangedHandler);
			value.addEventListener ("visibleChanged", global_visibleChangedHandler);
		}
	}
	
	//----------------------------------
	//  visible
	//----------------------------------
	
	/**
	 *
	 */
	private var _visible : Boolean = true;
	
	protected var visibleChanged : Boolean;
	
	[Bindable(event="visibleChanged")]
	/**
	 *
	 * @return
	 *
	 */
	public function get visible () : Boolean
	{
		return visibleChanged || !global ? _visible : global.visible;
	}
	
	/**
	 *
	 * @param value
	 *
	 */
	public function set visible (value : Boolean) : void
	{
		if (visible == value)
			return;
		
		_visible = value;
		
		visibleChanged = true;
		
		if (!value)
		{
			visibleWeight = weight;
			weight = 0;
		}
		else
			weight = visibleWeight;
		
		dispatchVisibleChangedEvent ();
	}
	
	//----------------------------------
	//  weight
	//----------------------------------
	
	/**
	 *
	 */
	private var _weight : Number = 1;
	
	protected var weightChanged : Boolean;
	
	[Bindable(event="weightChanged")]
	/**
	 *
	 * @return
	 *
	 */
	public function get weight () : Number
	{
		return weightChanged || !global ? _weight : global.weight;
	}
	
	/**
	 *
	 * @param value
	 *
	 */
	public function set weight (value : Number) : void
	{
		if (weight == value)
			return;
		
		_weight = value;
		
		weightChanged = true;
		
		dispatchWeightChangedEvent ();
		
		if (value > 0)
		{
			visibleWeight = value;
			visible = true;
		}
		else
			visible = false;
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
	public function assign (value : BorderSide) : void
	{
		if (!value)
			return;
		
		color = value.color;
		alpha = value.alpha;
		weight = value.weight;
		visible = value.visible;
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
		
		if (value is BorderSide)
		{
			assign (BorderSide (value));
			
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
	}
	
	/**
	 *
	 *
	 */
	protected function dispatchAlphaChangedEvent () : void
	{
		dispatchEvent (new Event ("alphaChanged"));
	}
	
	/**
	 *
	 *
	 */
	protected function dispatchColorChangedEvent () : void
	{
		dispatchEvent (new Event ("colorChanged"));
	}
	
	/**
	 *
	 *
	 */
	protected function dispatchVisibleChangedEvent () : void
	{
		dispatchEvent (new Event ("visibleChanged"));
	}
	
	/**
	 *
	 *
	 */
	protected function dispatchWeightChangedEvent () : void
	{
		dispatchEvent (new Event ("weightChanged"));
	}
	
	/**
	 *
	 *
	 */
	spreadsheet function release () : void
	{
		global = null;
	}
	
	//--------------------------------------------------------------------------
	//
	//  Event handlers
	//
	//--------------------------------------------------------------------------
	
	/**
	 *
	 * @param e
	 *
	 */
	protected function global_colorChangedHandler (e : Event) : void
	{
		dispatchColorChangedEvent ();
	}
	
	/**
	 *
	 * @param e
	 *
	 */
	protected function global_alphaChangedHandler (e : Event) : void
	{
		dispatchAlphaChangedEvent ();
	}
	
	/**
	 *
	 * @param e
	 *
	 */
	protected function global_weightChangedHandler (e : Event) : void
	{
		dispatchWeightChangedEvent ();
	}
	
	/**
	 *
	 * @param e
	 *
	 */
	protected function global_visibleChangedHandler (e : Event) : void
	{
		dispatchVisibleChangedEvent ();
	}
}
}