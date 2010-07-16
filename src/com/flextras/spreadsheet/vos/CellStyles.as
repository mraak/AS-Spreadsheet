package com.flextras.spreadsheet.vos
{
import com.flextras.spreadsheet.core.spreadsheet;

import flash.events.Event;
import flash.events.EventDispatcher;

import flashx.textLayout.formats.TextAlign;
import flashx.textLayout.formats.VerticalAlign;

use namespace spreadsheet;

//----------------------------------
//  Events
//----------------------------------

/**
 *
 */
[Event(name="normalChanged", type="flash.events.Event")]

/**
 *
 */
[Event(name="hoveredChanged", type="flash.events.Event")]

/**
 *
 */
[Event(name="selectedChanged", type="flash.events.Event")]

/**
 *
 */
[Event(name="disabledChanged", type="flash.events.Event")]

/**
 *
 */
[Event(name="cellGradientLevelChanged", type="flash.events.Event")]

/**
 *
 */
[Event(name="rollOutDurationChanged", type="flash.events.Event")]

[RemoteClass]
/**
 *
 *
 */
public class CellStyles extends EventDispatcher
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
	 * @param backgroundColor
	 * @param backgroundAlpha
	 * @param bold
	 * @param italic
	 * @param underline
	 * @param horizontalAlign
	 * @param verticalAlign
	 * @param size
	 * @param border
	 * @param normal
	 * @param hovered
	 * @param selected
	 * @param disabled
	 *
	 */
	public function CellStyles(color : uint = 0,
							   alpha : Number = 1,
							   backgroundColor : uint = 0xFFFFFF,
							   backgroundAlpha : Number = 1,
							   bold : Boolean = false,
							   italic : Boolean = false,
							   underline : Boolean = false,
							   horizontalAlign : String = TextAlign.CENTER,
							   verticalAlign : String = VerticalAlign.MIDDLE,
							   size : Number = 14,
							   rollOutDuration : int = 500,
							   cellGradientLevel : int = 50,
							   border : Border = null,
							   normal : StylesState = null,
							   hovered : StylesState = null,
							   selected : StylesState = null,
							   disabled : StylesState = null)
	{
		this.color = color;
		this.alpha = alpha;
		this.backgroundColor = backgroundColor;
		this.backgroundAlpha = backgroundAlpha;
		this.bold = bold;
		this.italic = italic;
		this.underline = underline;
		this.horizontalAlign = horizontalAlign;
		this.verticalAlign = verticalAlign;
		this.size = size;
		
		this.rollOutDuration = rollOutDuration;
		this.cellGradientLevel = cellGradientLevel;
		
		this.border = border;
		
		this.normal = normal;
		this.hovered = hovered;
		this.selected = selected;
		this.disabled = disabled;
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
	public function set alpha(value : Number) : void
	{
		normal.alpha = hovered.alpha = selected.alpha = disabled.alpha = value;
	}
	
	//----------------------------------
	//  backgroundAlpha
	//----------------------------------
	
	[Transient]
	/**
	 *
	 * @param value
	 *
	 */
	public function set backgroundAlpha(value : Number) : void
	{
		normal.backgroundAlpha = hovered.backgroundAlpha = selected.backgroundAlpha = disabled.backgroundAlpha = value;
	}
	
	//----------------------------------
	//  backgroundColor
	//----------------------------------
	
	[Transient]
	/**
	 *
	 * @param value
	 *
	 */
	public function set backgroundColor(value : uint) : void
	{
		normal.backgroundColor = hovered.backgroundColor = selected.backgroundColor = disabled.backgroundColor = value;
	}
	
	//----------------------------------
	//  bold
	//----------------------------------
	
	[Transient]
	/**
	 *
	 * @param value
	 *
	 */
	public function set bold(value : Boolean) : void
	{
		normal.bold = hovered.bold = selected.bold = disabled.bold = value;
	}
	
	//----------------------------------
	//  border
	//----------------------------------
	
	[Transient]
	/**
	 *
	 * @param value
	 *
	 */
	public function set border(value : Border) : void
	{
		if (!value)
			return;
		
		normal.border = value;
		hovered.border = value;
		selected.border = value;
		disabled.border = value;
	}
	
	[Transient]
	/**
	 *
	 * @param value
	 *
	 */
	public function set borderObject(value : Object) : void
	{
		if (!value)
			return;
		
		_normal.borderObject = value;
		_hovered.borderObject = value;
		_selected.borderObject = value;
		_disabled.borderObject = value;
	}
	
	//----------------------------------
	//  cellGradientLevel
	//----------------------------------
	
	/**
	 *
	 */
	protected var _cellGradientLevel : int = 50;
	
	protected var cellGradientLevelChanged : Boolean;
	
	[Bindable(event="cellGradientLevelChanged")]
	/**
	 * 
	 * @return 
	 * 
	 */	
	public function get cellGradientLevel() : int
	{
		return cellGradientLevelChanged || !_global ? _cellGradientLevel : _global._cellGradientLevel;
	}
	
	/**
	 *  Performs a scaled brightness adjustment of an RGB color.
	 *
	 *  @param value The percentage to brighten or darken the original color.
	 *  If positive, the original color is brightened toward white
	 *  by this percentage. If negative, it is darkened toward black
	 *  by this percentage.
	 *  The range for this parameter is -100 to 100;
	 *  -100 produces black while 100 produces white.
	 *  If this parameter is 0, the RGB color returned
	 *  is the same as the original color.
	 */
	public function set cellGradientLevel(value : int) : void
	{
		if (_cellGradientLevel == value)
			return;
		
		_cellGradientLevel = value;
		
		cellGradientLevelChanged = true;
		
		dispatchCellGradientLevelChangedEvent();
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
	public function set color(value : uint) : void
	{
		normal.color = hovered.color = selected.color = disabled.color = value;
	}
	
	//----------------------------------
	//  disabled
	//----------------------------------
	
	/**
	 *
	 */
	protected const _disabled : StylesState = new StylesState;
	
	[Bindable(event="disabledChanged")]
	/**
	 *
	 * @return
	 *
	 */
	public function get disabled() : StylesState
	{
		return _disabled;
	}
	
	/**
	 *
	 * @param value
	 *
	 */
	public function set disabled(value : StylesState) : void
	{
		if (!value || _disabled === value)
			return;
		
		_disabled.assign(value);
		
		dispatchEvent(new Event("disabledChanged"));
	}
	
	[Transient]
	/**
	 *
	 * @param value
	 *
	 */
	public function set disabledObject(value : Object) : void
	{
		if (!value)
			return;
		
		if (value is StylesState)
			disabled = StylesState(value);
		else
		{
			_disabled.assignObject(value);
			
			dispatchEvent(new Event("disabledChanged"));
		}
	}
	
	//----------------------------------
	//  global
	//----------------------------------
	
	/**
	 *
	 */
	protected var _global : CellStyles;
	
	/**
	 *
	 * @return
	 *
	 */
	spreadsheet function get global() : CellStyles
	{
		return _global;
	}
	
	/**
	 *
	 * @param value
	 *
	 */
	spreadsheet function set global(value : CellStyles) : void
	{
		if (_global === value)
			return;
		
		if(_global)
		{
			_global.removeEventListener("cellGradientLevelChanged", global_cellGradientLevelChangedHandler);
			_global.removeEventListener("rollOutDurationChanged", global_rollOutDurationChangedHandler);
		}
		
		_global = value;
		
		if (value)
		{
			_normal.global = value._normal;
			_hovered.global = value._hovered;
			_selected.global = value._selected;
			_disabled.global = value._disabled;
			
			value.addEventListener("cellGradientLevelChanged", global_cellGradientLevelChangedHandler);
			value.addEventListener("rollOutDurationChanged", global_rollOutDurationChangedHandler);
		}
		else
		{
			_normal.global = null;
			_hovered.global = null;
			_selected.global = null;
			_disabled.global = null;
		}
	}
	
	//----------------------------------
	//  horizontalAlign
	//----------------------------------
	
	[Transient]
	/**
	 *
	 * @param value
	 *
	 */
	public function set horizontalAlign(value : String) : void
	{
		normal.horizontalAlign = hovered.horizontalAlign = selected.horizontalAlign = disabled.horizontalAlign = value;
	}
	
	//----------------------------------
	//  hovered
	//----------------------------------
	
	/**
	 *
	 */
	protected const _hovered : StylesState = new StylesState;
	
	[Bindable(event="hoveredChanged")]
	/**
	 *
	 * @return
	 *
	 */
	public function get hovered() : StylesState
	{
		return _hovered;
	}
	
	/**
	 *
	 * @param value
	 *
	 */
	public function set hovered(value : StylesState) : void
	{
		if (!value || _hovered === value)
			return;
		
		_hovered.assign(value);
		
		dispatchEvent(new Event("hoveredChanged"));
	}
	
	[Transient]
	/**
	 *
	 * @param value
	 *
	 */
	public function set hoveredObject(value : Object) : void
	{
		if (!value)
			return;
		
		if (value is StylesState)
			hovered = StylesState(value);
		else
		{
			_hovered.assignObject(value);
			
			dispatchEvent(new Event("hoveredChanged"));
		}
	}
	
	//----------------------------------
	//  italic
	//----------------------------------
	
	[Transient]
	/**
	 *
	 * @param value
	 *
	 */
	public function set italic(value : Boolean) : void
	{
		normal.italic = hovered.italic = selected.italic = disabled.italic = value;
	}
	
	//----------------------------------
	//  normal
	//----------------------------------
	
	/**
	 *
	 */
	protected const _normal : StylesState = new StylesState;
	
	[Bindable(event="normalChanged")]
	/**
	 *
	 * @return
	 *
	 */
	public function get normal() : StylesState
	{
		return _normal;
	}
	
	/**
	 *
	 * @param value
	 *
	 */
	public function set normal(value : StylesState) : void
	{
		if (!value || _normal === value)
			return;
		
		_normal.assign(value);
		
		dispatchEvent(new Event("normalChanged"));
	}
	
	[Transient]
	/**
	 *
	 * @param value
	 *
	 */
	public function set normalObject(value : Object) : void
	{
		if (!value)
			return;
		
		if (value is StylesState)
			normal = StylesState(value);
		else
		{
			_normal.assignObject(value);
			
			dispatchEvent(new Event("normalChanged"));
		}
	}
	
	//----------------------------------
	//  rollOutDuration
	//----------------------------------
	
	/**
	 *
	 */
	protected var _rollOutDuration : int = 500;
	
	protected var rollOutDurationChanged : Boolean;
	
	[Bindable(event="rollOutDurationChanged")]
	/**
	 *
	 * @return
	 *
	 */
	public function get rollOutDuration() : int
	{
		return rollOutDurationChanged || !_global ? _rollOutDuration : _global._rollOutDuration;
	}
	
	/**
	 *
	 * @param value
	 *
	 */
	public function set rollOutDuration(value : int) : void
	{
		if (_rollOutDuration == value)
			return;
		
		_rollOutDuration = value;
		
		rollOutDurationChanged = true;
		
		dispatchRollOutDurationChangedEvent();
	}
	
	//----------------------------------
	//  selected
	//----------------------------------
	
	/**
	 *
	 */
	protected const _selected : StylesState = new StylesState;
	
	[Bindable(event="selectedChanged")]
	/**
	 *
	 * @return
	 *
	 */
	public function get selected() : StylesState
	{
		return _selected;
	}
	
	/**
	 *
	 * @param value
	 *
	 */
	public function set selected(value : StylesState) : void
	{
		if (!value || _selected === value)
			return;
		
		_selected.assign(value);
		
		dispatchEvent(new Event("selectedChanged"));
	}
	
	[Transient]
	/**
	 *
	 * @param value
	 *
	 */
	public function set selectedObject(value : Object) : void
	{
		if (!value)
			return;
		
		if (value is StylesState)
			selected = StylesState(value);
		else
		{
			_selected.assignObject(value);
			
			dispatchEvent(new Event("selectedChanged"));
		}
	}
	
	//----------------------------------
	//  size
	//----------------------------------
	
	[Transient]
	/**
	 *
	 * @param value
	 *
	 */
	public function set size(value : uint) : void
	{
		normal.size = hovered.size = selected.size = disabled.size = value;
	}
	
	//----------------------------------
	//  underline
	//----------------------------------
	
	[Transient]
	/**
	 *
	 * @param value
	 *
	 */
	public function set underline(value : Boolean) : void
	{
		normal.underline = hovered.underline = selected.underline = disabled.underline = value;
	}
	
	//----------------------------------
	//  verticalAlign
	//----------------------------------
	
	[Transient]
	/**
	 *
	 * @param value
	 *
	 */
	public function set verticalAlign(value : String) : void
	{
		normal.verticalAlign = hovered.verticalAlign = selected.verticalAlign = disabled.verticalAlign = value;
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
	public function assign(value : CellStyles) : void
	{
		if (!value)
			return;
		
		normal = value.normal;
		hovered = value.hovered;
		selected = value.selected;
		disabled = value.disabled;
		
		rollOutDuration = value.rollOutDuration;
		cellGradientLevel = value.cellGradientLevel;
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
		
		if (value is CellStyles)
		{
			assign(CellStyles(value));
			
			return;
		}
		
		if (value.hasOwnProperty("color"))
			color = uint(value.color);
		
		if (value.hasOwnProperty("alpha"))
			alpha = Number(value.alpha);
		
		if (value.hasOwnProperty("backgroundColor"))
			backgroundColor = uint(value.backgroundColor);
		
		if (value.hasOwnProperty("backgroundAlpha"))
			backgroundAlpha = Number(value.backgroundAlpha);
		
		if (value.hasOwnProperty("bold"))
			bold = Boolean(value.bold);
		
		if (value.hasOwnProperty("italic"))
			italic = Boolean(value.italic);
		
		if (value.hasOwnProperty("underline"))
			underline = Boolean(value.underline);
		
		if (value.hasOwnProperty("horizontalAlign"))
			horizontalAlign = String(value.horizontalAlign);
		
		if (value.hasOwnProperty("verticalAlign"))
			verticalAlign = String(value.verticalAlign);
		
		if (value.hasOwnProperty("size"))
			size = uint(value.size);
		
		if (value.hasOwnProperty("rollOutDuration"))
			rollOutDuration = int(value.rollOutDuration);
		
		if (value.hasOwnProperty("cellGradientLevel"))
			cellGradientLevel = int(value.cellGradientLevel);
		
		if (value.hasOwnProperty("border"))
			borderObject = value.border;
		
		if (value.hasOwnProperty("normal"))
			normalObject = value.normal;
		
		if (value.hasOwnProperty("hovered"))
			hoveredObject = value.hovered;
		
		if (value.hasOwnProperty("selected"))
			selectedObject = value.selected;
		
		if (value.hasOwnProperty("disabled"))
			disabledObject = value.disabled;
	}
	
	/**
	 *
	 *
	 */
	protected function dispatchCellGradientLevelChangedEvent() : void
	{
		dispatchEvent(new Event("cellGradientLevelChanged"));
	}
	
	/**
	 *
	 *
	 */
	protected function dispatchRollOutDurationChangedEvent() : void
	{
		dispatchEvent(new Event("rollOutDurationChanged"));
	}
	
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
	//  Event handlers
	//
	//--------------------------------------------------------------------------
	
	/**
	 *
	 * @param e
	 *
	 */
	protected function global_cellGradientLevelChangedHandler(e : Event) : void
	{
		dispatchCellGradientLevelChangedEvent();
	}
	
	/**
	 *
	 * @param e
	 *
	 */
	protected function global_rollOutDurationChangedHandler(e : Event) : void
	{
		dispatchRollOutDurationChangedEvent();
	}
	
}
}