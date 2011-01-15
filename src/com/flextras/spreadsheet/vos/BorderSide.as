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
 * Dispatched when color property gets changed.
 */
[Event(name="colorChanged", type="flash.events.Event")]

/**
 * Dispatched when alpha property gets changed.
 */
[Event(name="alphaChanged", type="flash.events.Event")]

/**
 * Dispatched when weight property gets changed.
 */
[Event(name="weightChanged", type="flash.events.Event")]

/**
 * Dispatched when visible property gets changed.
 */
[Event(name="visibleChanged", type="flash.events.Event")]

[RemoteClass]
/**
 * BorderSide class provides common api for setting the styles on individual side.
 *
 * @see com.flextras.spreadsheet.vos.CellStyles
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
	 * @private
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
	 * @private
	 */
	private var _alpha : Number = 1;
	
	/**
	 * @private
	 */
	protected var alphaChanged : Boolean;
	
	[Bindable(event="alphaChanged")]
	/**
	 * Sets alpha style on current side.
	 */
	public function get alpha () : Number
	{
		return alphaChanged || !global ? _alpha : global.alpha;
	}
	
	/**
	 * @private
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
	 * @private
	 */
	private var _color : uint;
	
	/**
	 * @private
	 */
	protected var colorChanged : Boolean;
	
	[Bindable(event="colorChanged")]
	/**
	 * Sets color style on current side.
	 */
	public function get color () : uint
	{
		return colorChanged || !global ? _color : global.color;
	}
	
	/**
	 * @private
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
	 * @private
	 */
	private var _global : BorderSide;
	
	/**
	 * @private
	 */
	spreadsheet function get global () : BorderSide
	{
		return _global;
	}
	
	/**
	 * Sets global styles on current side.
	 *
	 * @param value
	 * @private
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
	 * @private
	 */
	private var _visible : Boolean = true;
	
	/**
	 * @private
	 */
	protected var visibleChanged : Boolean;
	
	[Bindable(event="visibleChanged")]
	/**
	 * Sets visible style on current side.
	 */
	public function get visible () : Boolean
	{
		return visibleChanged || !global ? _visible : global.visible;
	}
	
	/**
	 * @private
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
	 * @private
	 */
	private var _weight : Number = 1;
	
	/**
	 * @private
	 */
	protected var weightChanged : Boolean;
	
	[Bindable(event="weightChanged")]
	/**
	 * Sets weight style on current side.
	 */
	public function get weight () : Number
	{
		return weightChanged || !global ? _weight : global.weight;
	}
	
	/**
	 * @private
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
	 * Provides convenient way to replace all current styles with new ones.
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
	 * Accepts either Object or BorderSide.
	 * If value is typed as BorderSide then this setter behaves the same as regular assign otherwise it changes only the provided styles.
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
	 * @private
	 */
	protected function dispatchAlphaChangedEvent () : void
	{
		dispatchEvent (new Event ("alphaChanged"));
	}
	
	/**
	 * @private
	 */
	protected function dispatchColorChangedEvent () : void
	{
		dispatchEvent (new Event ("colorChanged"));
	}
	
	/**
	 * @private
	 */
	protected function dispatchVisibleChangedEvent () : void
	{
		dispatchEvent (new Event ("visibleChanged"));
	}
	
	/**
	 * @private
	 */
	protected function dispatchWeightChangedEvent () : void
	{
		dispatchEvent (new Event ("weightChanged"));
	}
	
	/**
	 * @private
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
	 * @private
	 */
	protected function global_colorChangedHandler (e : Event) : void
	{
		dispatchColorChangedEvent ();
	}
	
	/**
	 * @private
	 */
	protected function global_alphaChangedHandler (e : Event) : void
	{
		dispatchAlphaChangedEvent ();
	}
	
	/**
	 * @private
	 */
	protected function global_weightChangedHandler (e : Event) : void
	{
		dispatchWeightChangedEvent ();
	}
	
	/**
	 * @private
	 */
	protected function global_visibleChangedHandler (e : Event) : void
	{
		dispatchVisibleChangedEvent ();
	}
}
}