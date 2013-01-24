
////////////////////////////////////////////////////////////////////////////////
//  
//  Copyright 2012 Alen Balja
//  All Rights Reserved.
//
//  See the file license.txt for copying permission.
//
////////////////////////////////////////////////////////////////////////////////


package uk.co.currentlabel.spreadsheet.vos
{
import uk.co.currentlabel.spreadsheet.core.spreadsheet;

import flash.events.Event;
import flash.events.EventDispatcher;

use namespace spreadsheet;

//----------------------------------
//  Events
//----------------------------------

/**
 * Dispatched when normal property gets changed.
 */
[Event(name="normalChanged", type="flash.events.Event")]

/**
 * Dispatched when hovered property gets changed.
 */
[Event(name="hoveredChanged", type="flash.events.Event")]

/**
 * Dispatched when selected property gets changed.
 */
[Event(name="selectedChanged", type="flash.events.Event")]

/**
 * Dispatched when disabled property gets changed.
 */
[Event(name="disabledChanged", type="flash.events.Event")]

/**
 * Dispatched when cellGradientLevel property gets changed.
 */
[Event(name="cellGradientLevelChanged", type="flash.events.Event")]

/**
 * Dispatched when rollOutDuration property gets changed.
 */
[Event(name="rollOutDurationChanged", type="flash.events.Event")]

[RemoteClass]
/**
 * CellStyles class provides common api for setting the styles on all states. It also contains references to individual state.
 *
 * @example
 * <listing version="3.0">
 * var cellStyles:CellStyles = grid.getCellAt(0, 0).styles;
 * cellStyles.color = 0x333333;
 * cellStyles.backgroundColor = 0xEEEEEE;
 * cellStyles.bold = true;
 * cellStyles.hovered.color = 0x666666;
 * cellStyles.border = new Border(0xFF0000, 1, 2);
 * cellStyles.normal.top = new BorderSide(0xFF0000, .75, 1);
 * cellStyles.normal.bottom.assignObject({visible:false});
 * cellStyles.hovered.color = 0x00FF00;
 * </listing>
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
	 * @param font
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
	public function CellStyles (color : uint = 0,
		alpha : Number = 1,
		backgroundColor : uint = 0xFFFFFF,
		backgroundAlpha : Number = 1,
		bold : Boolean = false,
		italic : Boolean = false,
		underline : Boolean = false,
		font : String = "arial",
		horizontalAlign : String = "center",
		verticalAlign : String = "middle",
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
		this.font = font;
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
	 * Sets alpha style on all states.
	 *
	 * @param value
	 *
	 */
	public function set alpha (value : Number) : void
	{
		normal.alpha = hovered.alpha = selected.alpha = disabled.alpha = value;
	}
	
	//----------------------------------
	//  backgroundAlpha
	//----------------------------------
	
	[Transient]
	/**
	 * Sets backgroundAlpha style on all states.
	 *
	 * @param value
	 *
	 */
	public function set backgroundAlpha (value : Number) : void
	{
		normal.backgroundAlpha = hovered.backgroundAlpha = selected.backgroundAlpha = disabled.backgroundAlpha = value;
	}
	
	//----------------------------------
	//  backgroundColor
	//----------------------------------
	
	[Transient]
	/**
	 * Sets backgroundColor style on all states.
	 *
	 * @param value
	 *
	 */
	public function set backgroundColor (value : uint) : void
	{
		normal.backgroundColor = hovered.backgroundColor = selected.backgroundColor = disabled.backgroundColor = value;
	}
	
	//----------------------------------
	//  bold
	//----------------------------------
	
	[Transient]
	/**
	 * Sets bold style on all states.
	 *
	 * @param value
	 *
	 */
	public function set bold (value : Boolean) : void
	{
		normal.bold = hovered.bold = selected.bold = disabled.bold = value;
	}
	
	//----------------------------------
	//  border
	//----------------------------------
	
	[Transient]
	/**
	 * Replaces current border styles with new ones.
	 * It also dispathes an event.
	 *
	 * @param value
	 *
	 */
	public function set border (value : Border) : void
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
	 * Accepts either Object or Border.
	 * If value is typed as Border then this setter behaves the same as regular setter otherwise it changes only the provided styles.
	 * It also dispathes an event.
	 *
	 * @param value
	 *
	 */
	public function set borderObject (value : Object) : void
	{
		if (!value)
			return;
		
		normal.borderObject = value;
		hovered.borderObject = value;
		selected.borderObject = value;
		disabled.borderObject = value;
	}
	
	//----------------------------------
	//  cellGradientLevel
	//----------------------------------
	
	/**
	 * @private
	 */
	private var _cellGradientLevel : int = 50;
	
	/**
	 * @private
	 */
	protected var cellGradientLevelChanged : Boolean;
	
	[Bindable(event="cellGradientLevelChanged")]
	/**
	 * Sets rollOutDuration style for all states.
	 * It also dispathes an event.
	 *
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
	public function get cellGradientLevel () : int
	{
		return cellGradientLevelChanged || !global ? _cellGradientLevel : global.cellGradientLevel;
	}
	
	/**
	 * @private
	 */
	public function set cellGradientLevel (value : int) : void
	{
		if (cellGradientLevel == value)
			return;
		
		_cellGradientLevel = value;
		
		cellGradientLevelChanged = true;
		
		dispatchCellGradientLevelChangedEvent ();
	}
	
	//----------------------------------
	//  color
	//----------------------------------
	
	[Transient]
	/**
	 * Sets color style on all states.
	 *
	 * @param value
	 *
	 */
	public function set color (value : uint) : void
	{
		normal.color = hovered.color = selected.color = disabled.color = value;
	}
	
	//----------------------------------
	//  disabled
	//----------------------------------
	
	/**
	 * @private
	 */
	private var _disabled : StylesState = new StylesState;
	
	[Bindable(event="disabledChanged")]
	/**
	 * Replaces current styles for disabled state with new ones.
	 * It also dispathes an event.
	 */
	public function get disabled () : StylesState
	{
		return _disabled;
	}
	
	/**
	 * @private
	 */
	public function set disabled (value : StylesState) : void
	{
		if (disabled === value)
			return;
		
		disabled.assign (value);
		
		dispatchEvent (new Event ("disabledChanged"));
	}
	
	[Transient]
	/**
	 * Accepts either Object or StylesState.
	 * If value is typed as StylesState then this setter behaves the same as regular setter otherwise it changes only the provided styles.
	 * It also dispathes an event.
	 *
	 * @param value
	 *
	 */
	public function set disabledObject (value : Object) : void
	{
		if (!value)
			return;
		
		if (value is StylesState)
			disabled = StylesState (value);
		else
		{
			disabled.assignObject (value);
			
			dispatchEvent (new Event ("disabledChanged"));
		}
	}
	
	//----------------------------------
	//  font
	//----------------------------------
	
	[Transient]
	/**
	 * Sets font style on all states.
	 *
	 * @param value
	 *
	 */
	public function set font (value : String) : void
	{
		normal.font = hovered.font = selected.font = disabled.font = value;
	}
	
	//----------------------------------
	//  global
	//----------------------------------
	
	/**
	 * @private
	 */
	private var _global : CellStyles;
	
	/**
	 * @private
	 */
	spreadsheet function get global () : CellStyles
	{
		return _global;
	}
	
	/**
	 * Sets global styles on all states.
	 *
	 * @param value
	 * @private
	 */
	spreadsheet function set global (value : CellStyles) : void
	{
		if (global === value)
			return;
		
		if (global)
		{
			global.removeEventListener ("cellGradientLevelChanged", global_cellGradientLevelChangedHandler);
			global.removeEventListener ("rollOutDurationChanged", global_rollOutDurationChangedHandler);
		}
		
		_global = value;
		
		if (value)
		{
			normal.global = value.normal;
			hovered.global = value.hovered;
			selected.global = value.selected;
			disabled.global = value.disabled;
			
			value.addEventListener ("cellGradientLevelChanged", global_cellGradientLevelChangedHandler);
			value.addEventListener ("rollOutDurationChanged", global_rollOutDurationChangedHandler);
		}
		else
		{
			normal.global = null;
			hovered.global = null;
			selected.global = null;
			disabled.global = null;
		}
	}
	
	//----------------------------------
	//  horizontalAlign
	//----------------------------------
	
	[Transient]
	/**
	 * Sets horizontalAlign style on all states.
	 *
	 * @param value
	 *
	 */
	public function set horizontalAlign (value : String) : void
	{
		normal.horizontalAlign = hovered.horizontalAlign = selected.horizontalAlign = disabled.horizontalAlign = value;
	}
	
	//----------------------------------
	//  hovered
	//----------------------------------
	
	/**
	 * @private
	 */
	private var _hovered : StylesState = new StylesState;
	
	[Bindable(event="hoveredChanged")]
	/**
	 * Replaces current styles for hovered state with new ones.
	 * It also dispathes an event.
	 */
	public function get hovered () : StylesState
	{
		return _hovered;
	}
	
	/**
	 * @private
	 */
	public function set hovered (value : StylesState) : void
	{
		if (hovered === value)
			return;
		
		hovered.assign (value);
		
		dispatchEvent (new Event ("hoveredChanged"));
	}
	
	[Transient]
	/**
	 * Accepts either Object or StylesState.
	 * If value is typed as StylesState then this setter behaves the same as regular setter otherwise it changes only the provided styles.
	 * It also dispathes an event.
	 *
	 * @param value
	 *
	 */
	public function set hoveredObject (value : Object) : void
	{
		if (!value)
			return;
		
		if (value is StylesState)
			hovered = StylesState (value);
		else
		{
			hovered.assignObject (value);
			
			dispatchEvent (new Event ("hoveredChanged"));
		}
	}
	
	//----------------------------------
	//  italic
	//----------------------------------
	
	[Transient]
	/**
	 * Sets italic style on all states.
	 *
	 * @param value
	 *
	 */
	public function set italic (value : Boolean) : void
	{
		normal.italic = hovered.italic = selected.italic = disabled.italic = value;
	}
	
	//----------------------------------
	//  normal
	//----------------------------------
	
	/**
	 * @private
	 */
	private var _normal : StylesState = new StylesState;
	
	[Bindable(event="normalChanged")]
	/**
	 * Replaces current styles for normal state with new ones.
	 * It also dispathes an event.
	 */
	public function get normal () : StylesState
	{
		return _normal;
	}
	
	/**
	 * @private
	 */
	public function set normal (value : StylesState) : void
	{
		if (normal === value)
			return;
		
		normal.assign (value);
		
		dispatchEvent (new Event ("normalChanged"));
	}
	
	[Transient]
	/**
	 * Accepts either Object or StylesState.
	 * If value is typed as StylesState then this setter behaves the same as regular setter otherwise it changes only the provided styles.
	 * It also dispathes an event.
	 *
	 * @param value
	 *
	 */
	public function set normalObject (value : Object) : void
	{
		if (!value)
			return;
		
		if (value is StylesState)
			normal = StylesState (value);
		else
		{
			normal.assignObject (value);
			
			dispatchEvent (new Event ("normalChanged"));
		}
	}
	
	//----------------------------------
	//  rollOutDuration
	//----------------------------------
	
	/**
	 * @private
	 */
	private var _rollOutDuration : int = 500;
	
	/**
	 * @private
	 */
	protected var rollOutDurationChanged : Boolean;
	
	[Bindable(event="rollOutDurationChanged")]
	/**
	 * Sets rollOutDuration style for all states.
	 * It also dispathes an event.
	 */
	public function get rollOutDuration () : int
	{
		return rollOutDurationChanged || !global ? _rollOutDuration : global.rollOutDuration;
	}
	
	/**
	 * @private
	 */
	public function set rollOutDuration (value : int) : void
	{
		if (rollOutDuration == value)
			return;
		
		_rollOutDuration = value;
		
		rollOutDurationChanged = true;
		
		dispatchRollOutDurationChangedEvent ();
	}
	
	//----------------------------------
	//  selected
	//----------------------------------
	
	/**
	 * @private
	 */
	private var _selected : StylesState = new StylesState;
	
	[Bindable(event="selectedChanged")]
	/**
	 * Replaces current styles for selected state with new ones.
	 * It also dispathes an event.
	 */
	public function get selected () : StylesState
	{
		return _selected;
	}
	
	/**
	 * @private
	 */
	public function set selected (value : StylesState) : void
	{
		if (selected === value)
			return;
		
		selected.assign (value);
		
		dispatchEvent (new Event ("selectedChanged"));
	}
	
	[Transient]
	/**
	 * Accepts either Object or StylesState.
	 * If value is typed as StylesState then this setter behaves the same as regular setter otherwise it changes only the provided styles.
	 * It also dispathes an event.
	 *
	 * @param value
	 *
	 */
	public function set selectedObject (value : Object) : void
	{
		if (!value)
			return;
		
		if (value is StylesState)
			selected = StylesState (value);
		else
		{
			selected.assignObject (value);
			
			dispatchEvent (new Event ("selectedChanged"));
		}
	}
	
	//----------------------------------
	//  size
	//----------------------------------
	
	[Transient]
	/**
	 * Sets size style on all states.
	 *
	 * @param value
	 *
	 */
	public function set size (value : uint) : void
	{
		normal.size = hovered.size = selected.size = disabled.size = value;
	}
	
	//----------------------------------
	//  underline
	//----------------------------------
	
	[Transient]
	/**
	 * Sets underline style on all states.
	 *
	 * @param value
	 *
	 */
	public function set underline (value : Boolean) : void
	{
		normal.underline = hovered.underline = selected.underline = disabled.underline = value;
	}
	
	//----------------------------------
	//  verticalAlign
	//----------------------------------
	
	[Transient]
	/**
	 * Sets verticalAlign style on all states.
	 *
	 * @param value
	 *
	 */
	public function set verticalAlign (value : String) : void
	{
		normal.verticalAlign = hovered.verticalAlign = selected.verticalAlign = disabled.verticalAlign = value;
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
	public function assign (value : CellStyles) : void
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
	 * Accepts either Object or CellStyles.
	 * If value is typed as CellStyles then this setter behaves the same as regular assign otherwise it changes only the provided styles.
	 *
	 * @param value
	 *
	 */
	public function assignObject (value : Object) : void
	{
		if (!value)
			return;
		
		if (value is CellStyles)
		{
			assign (CellStyles (value));
			
			return;
		}
		
		if (value.hasOwnProperty ("color"))
			color = uint (value.color);
		
		if (value.hasOwnProperty ("alpha"))
			alpha = Number (value.alpha);
		
		if (value.hasOwnProperty ("backgroundColor"))
			backgroundColor = uint (value.backgroundColor);
		
		if (value.hasOwnProperty ("backgroundAlpha"))
			backgroundAlpha = Number (value.backgroundAlpha);
		
		if (value.hasOwnProperty ("bold"))
			bold = Boolean (value.bold);
		
		if (value.hasOwnProperty ("italic"))
			italic = Boolean (value.italic);
		
		if (value.hasOwnProperty ("underline"))
			underline = Boolean (value.underline);
		
		if (value.hasOwnProperty ("font"))
			font = String (value.font);
		
		if (value.hasOwnProperty ("horizontalAlign"))
			horizontalAlign = String (value.horizontalAlign);
		
		if (value.hasOwnProperty ("verticalAlign"))
			verticalAlign = String (value.verticalAlign);
		
		if (value.hasOwnProperty ("size"))
			size = uint (value.size);
		
		if (value.hasOwnProperty ("rollOutDuration"))
			rollOutDuration = int (value.rollOutDuration);
		
		if (value.hasOwnProperty ("cellGradientLevel"))
			cellGradientLevel = int (value.cellGradientLevel);
		
		if (value.hasOwnProperty ("border"))
			borderObject = value.border;
		
		if (value.hasOwnProperty ("normal"))
			normalObject = value.normal;
		
		if (value.hasOwnProperty ("hovered"))
			hoveredObject = value.hovered;
		
		if (value.hasOwnProperty ("selected"))
			selectedObject = value.selected;
		
		if (value.hasOwnProperty ("disabled"))
			disabledObject = value.disabled;
	}
	
	/**
	 * @private
	 */
	protected function dispatchCellGradientLevelChangedEvent () : void
	{
		dispatchEvent (new Event ("cellGradientLevelChanged"));
	}
	
	/**
	 * @private
	 */
	protected function dispatchRollOutDurationChangedEvent () : void
	{
		dispatchEvent (new Event ("rollOutDurationChanged"));
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
	protected function global_cellGradientLevelChangedHandler (e : Event) : void
	{
		dispatchCellGradientLevelChangedEvent ();
	}
	
	/**
	 * @private
	 */
	protected function global_rollOutDurationChangedHandler (e : Event) : void
	{
		dispatchRollOutDurationChangedEvent ();
	}

}
}