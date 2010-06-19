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
	public function BorderSide(color : uint = 0, alpha : Number = 1, weight : Number = 1, visible : Boolean = true)
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
	//  Properties: Styles
	//
	//--------------------------------------------------------------------------
	
	//----------------------------------
	//  color
	//----------------------------------
	
	/**
	 *
	 */
	protected var _color : uint;
	
	protected var colorChanged : Boolean;
	
	[Bindable(event="colorChanged")]
	/**
	 *
	 * @return
	 *
	 */
	public function get color() : uint
	{
		return colorChanged || !_global ? _color : _global._color;
	}
	
	/**
	 *
	 * @param value
	 *
	 */
	public function set color(value : uint) : void
	{
		if (color == value)
			return;
		
		_color = value;
		
		colorChanged = true;
		
		dispatchColorChangedEvent();
	}
	
	//----------------------------------
	//  alpha
	//----------------------------------
	
	/**
	 *
	 */
	protected var _alpha : Number = 1;
	
	protected var alphaChanged : Boolean;
	
	[Bindable(event="alphaChanged")]
	/**
	 *
	 * @return
	 *
	 */
	public function get alpha() : Number
	{
		return alphaChanged || !_global ? _alpha : _global._alpha;
	}
	
	/**
	 *
	 * @param value
	 *
	 */
	public function set alpha(value : Number) : void
	{
		if (alpha == value)
			return;
		
		_alpha = value;
		
		alphaChanged = true;
		
		dispatchAlphaChangedEvent();
	}
	
	//----------------------------------
	//  weight
	//----------------------------------
	
	/**
	 *
	 */
	protected var _weight : Number = 1;
	
	protected var weightChanged : Boolean;
	
	[Bindable(event="weightChanged")]
	/**
	 *
	 * @return
	 *
	 */
	public function get weight() : Number
	{
		return weightChanged || !_global ? _weight : _global._weight;
	}
	
	/**
	 *
	 * @param value
	 *
	 */
	public function set weight(value : Number) : void
	{
		if (weight == value)
			return;
		
		_weight = value;
		
		weightChanged = true;
		
		dispatchWeightChangedEvent();
		
		if (value > 0)
		{
			visibleWeight = value;
			visible = true;
		}
		else
			visible = false;
	}
	
	//----------------------------------
	//  visible
	//----------------------------------
	
	/**
	 *
	 */
	protected var _visible : Boolean = true;
	
	protected var visibleChanged : Boolean;
	
	[Bindable(event="visibleChanged")]
	/**
	 *
	 * @return
	 *
	 */
	public function get visible() : Boolean
	{
		return visibleChanged || !_global ? _visible : _global._weight;
	}
	
	/**
	 *
	 * @param value
	 *
	 */
	public function set visible(value : Boolean) : void
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
		
		dispatchVisibleChangedEvent();
	}
	
	//--------------------------------------------------------------------------
	//
	//  Properties: Global styles
	//
	//--------------------------------------------------------------------------
	
	/**
	 *
	 */
	protected var _global : BorderSide;
	
	/**
	 *
	 * @return
	 *
	 */
	spreadsheet function get global() : BorderSide
	{
		return _global;
	}
	
	/**
	 *
	 * @param value
	 *
	 */
	spreadsheet function set global(value : BorderSide) : void
	{
		if (_global === value)
			return;
		
		if (_global)
		{
			_global.removeEventListener("colorChanged", global_colorChangedHandler);
			_global.removeEventListener("alphaChanged", global_alphaChangedHandler);
			_global.removeEventListener("weightChanged", global_weightChangedHandler);
			_global.removeEventListener("visibleChanged", global_visibleChangedHandler);
		}
		
		_global = value;
		
		if (value)
		{
			value.addEventListener("colorChanged", global_colorChangedHandler);
			value.addEventListener("alphaChanged", global_alphaChangedHandler);
			value.addEventListener("weightChanged", global_weightChangedHandler);
			value.addEventListener("visibleChanged", global_visibleChangedHandler);
		}
	}
	
	//--------------------------------------------------------------------------
	//
	//  Methods: Event dispatchers
	//
	//--------------------------------------------------------------------------
	
	/**
	 *
	 *
	 */
	protected function dispatchColorChangedEvent() : void
	{
		dispatchEvent(new Event("colorChanged"));
	}
	
	/**
	 *
	 *
	 */
	protected function dispatchAlphaChangedEvent() : void
	{
		dispatchEvent(new Event("alphaChanged"));
	}
	
	/**
	 *
	 *
	 */
	protected function dispatchWeightChangedEvent() : void
	{
		dispatchEvent(new Event("weightChanged"));
	}
	
	/**
	 *
	 *
	 */
	protected function dispatchVisibleChangedEvent() : void
	{
		dispatchEvent(new Event("visibleChanged"));
	}
	
	//--------------------------------------------------------------------------
	//
	//  Methods: Cleanup
	//
	//--------------------------------------------------------------------------
	
	/**
	 *
	 *
	 */
	spreadsheet function release() : void
	{
		global = null;
	}
	
	//--------------------------------------------------------------------------
	//
	//  Methods: Assignment
	//
	//--------------------------------------------------------------------------
	
	/**
	 *
	 * @param value
	 *
	 */
	public function assign(value : BorderSide) : void
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
	public function assignObject(value : Object) : void
	{
		if (!value)
			return;
		
		if (value is BorderSide)
		{
			assign(BorderSide(value));
			
			return;
		}
		
		if (value.hasOwnProperty("color"))
			color = uint(value.color);
		
		if (value.hasOwnProperty("alpha"))
			alpha = Number(value.alpha);
		
		if (value.hasOwnProperty("weight"))
			weight = Number(value.weight);
		
		if (value.hasOwnProperty("visible"))
			visible = Boolean(value.visible);
	}
	
	//--------------------------------------------------------------------------
	//
	//  Event handlers: Global styles
	//
	//--------------------------------------------------------------------------
	
	/**
	 *
	 * @param e
	 *
	 */
	protected function global_colorChangedHandler(e : Event) : void
	{
		dispatchColorChangedEvent();
	}
	
	/**
	 *
	 * @param e
	 *
	 */
	protected function global_alphaChangedHandler(e : Event) : void
	{
		dispatchAlphaChangedEvent();
	}
	
	/**
	 *
	 * @param e
	 *
	 */
	protected function global_weightChangedHandler(e : Event) : void
	{
		dispatchWeightChangedEvent();
	}
	
	/**
	 *
	 * @param e
	 *
	 */
	protected function global_visibleChangedHandler(e : Event) : void
	{
		dispatchVisibleChangedEvent();
	}
}
}