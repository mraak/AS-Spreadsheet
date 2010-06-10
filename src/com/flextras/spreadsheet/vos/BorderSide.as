package com.flextras.spreadsheet.vos
{
import flash.events.Event;
import flash.events.EventDispatcher;

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
	/**
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
	
	/**
	 *
	 */
	protected var _color : uint;
	
	[Bindable(event="colorChanged")]
	/**
	 *
	 * @return
	 *
	 */
	public function get color() : uint
	{
		return _color;
	}
	
	/**
	 *
	 * @param value
	 *
	 */
	public function set color(value : uint) : void
	{
		if (_color == value)
			return;
		
		_color = value;
		
		dispatchEvent(new Event("colorChanged"));
	}
	
	/**
	 *
	 */
	protected var _alpha : Number = 1;
	
	[Bindable(event="alphaChanged")]
	/**
	 *
	 * @return
	 *
	 */
	public function get alpha() : Number
	{
		return _alpha;
	}
	
	/**
	 *
	 * @param value
	 *
	 */
	public function set alpha(value : Number) : void
	{
		if (_alpha == value)
			return;
		
		_alpha = value;
		
		dispatchEvent(new Event("alphaChanged"));
	}
	
	/**
	 *
	 */
	protected var _weight : Number = 1;
	
	[Bindable(event="weightChanged")]
	/**
	 *
	 * @return
	 *
	 */
	public function get weight() : Number
	{
		return _weight;
	}
	
	/**
	 *
	 * @param value
	 *
	 */
	public function set weight(value : Number) : void
	{
		if (_weight == value)
			return;
		
		_weight = value;
		
		dispatchEvent(new Event("weightChanged"));
		
		if (value > 0)
		{
			visibleWeight = value;
			visible = true;
		}
		else
			visible = false;
	}
	
	/**
	 * @private
	 */
	protected var visibleWeight : Number;
	
	/**
	 *
	 */
	protected var _visible : Boolean = true;
	
	[Bindable(event="visibleChanged")]
	/**
	 *
	 * @return
	 *
	 */
	public function get visible() : Boolean
	{
		return _visible;
	}
	
	/**
	 *
	 * @param value
	 *
	 */
	public function set visible(value : Boolean) : void
	{
		if (_visible == value)
			return;
		
		_visible = value;
		
		if (!value)
		{
			visibleWeight = weight;
			weight = 0;
		}
		else
			weight = visibleWeight;
		
		dispatchEvent(new Event("visibleChanged"));
	}
	
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
}
}