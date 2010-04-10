package com.flextras.paintgrid
{
import com.flextras.spreadsheet.context.LocalContextMenu;

import flash.events.Event;

[Event(name="selectedChanged", type="flash.events.Event")]
[Event(name="conditionChanged", type="com.flextras.paintgrid.CellEvent")]

/**
 * Whenever you want to apply some cell specific properties this is the right place to do it.
 * You can modify almost any style supported by older Flash Text Engine or modify background related styles
 * and thats true for all four states (normal, over, selected, disabled), but there's a catch:
 * font related styles (kerning, spacing, ...) can only be set in "styles" property - which is for "normal" state
 * every other state will be ignored.
 */
public class CellProperties extends StylesProxy
{
	/**
	 * Location (row, column) of target cell
	 */	
	public const location:CellLocation = new CellLocation;
	
	/**
	 * Condition of target cell
	 * 
	 * Operator and right side of expression are required
	 * (example '= 1 + 2' -
	 * '1' is left side of expression,
	 * '+' is an operator,
	 * '2' is right side of expression)
	 * 
	 * left side of expression is optional (if provided condition will take its value instead of cell's)
	 */	
	//[Bindable(event="conditionChanged")]
	public const condition:Condition = new Condition;
	//public var hasCondition:Boolean;
	
	public function CellProperties (row : int = 0, column : int = 0, styles : Object = null, rollOverStyles : Object = null, selectedStyles : Object = null, disabledStyles : Object = null, condition:Condition = null)
	{
		super(styles, rollOverStyles, selectedStyles, disabledStyles);
		
		location.row = row;
		location.column = column;
		
		this.condition.addEventListener("leftChanged", condition_changeHandler);
		this.condition.addEventListener("operatorChanged", condition_changeHandler);
		this.condition.addEventListener("rightChanged", condition_changeHandler);
		
		this.condition.assign(condition);
	}
	
	protected var _conditionEnabled:Boolean;
	
	[Bindable(event="conditionsChanged")]
	/**
	 * This property must be set to true if you want to use conditions
	 * or false if you don't want to.
	 * @return 
	 */	
	public function get conditionEnabled():Boolean
	{
		return _conditionEnabled;
	}

	public function set conditionEnabled(value:Boolean):void
	{
		_conditionEnabled = value;
		
		condition_changeHandler(null);
	}

	/**
	 * @private
	 */	
	override public function release () : void
	{
		super.release();
		
		if (menu)
			menu.unsetContextMenu(null);
	}
	
	/**
	 * Modify it if you want to enable / disable target cell
	 * @param value
	 */	
	override public function set enabled (value : Boolean) : void
	{
		if (menu)
			menu.enabled = value;
		
		super.enabled = value;
	}
	
	protected var _menu : LocalContextMenu;
	
	/**
	 * @private
	 */	
	public function get menu () : LocalContextMenu
	{
		return _menu;
	}
	
	public function set menu (value : LocalContextMenu) : void
	{
		if (_menu === value)
			return;
		
		_menu = value;
		
		if (value)
			value.enabled = enabled;
	}
	
	protected var _selected : Boolean;
	
	[Bindable(event="selectedChanged")]
	/**
	 * true if selected otherwise false
	 * @return 
	 */	
	public function get selected () : Boolean
	{
		return _selected;
	}
	
	public function set selected (value : Boolean) : void
	{
		if (_selected == value)
			return;
		
		_selected = value;
		
		dispatchEvent(new Event("selectedChanged"));
	}
	
	/**
	 * @private
	 * @param cell
	 * @return 
	 */	
	public function equalLocation (cell : CellLocation) : Boolean
	{
		return location.equal(cell);
	}
	
	/**
	 * @private
	 * @return 
	 */	
	override public function get valid () : Boolean
	{
		return super.valid;
	}
	
	protected function condition_changeHandler (e : Event) : void
	{
		dispatchEvent(new CellEvent(CellEvent.CONDITION_CHANGED));
	}
	
	/**
	 * @private
	 * @param value
	 */	
	override public function fromXML(value:XML):void
	{
		super.fromXML(value.styles);
		
		location.fromXML(value.location);
		condition.fromXML(value.condition);
	}
	
	/**
	 * @private
	 * @return 
	 */	
	override public function toXML():XML
	{
		var result:XML = <CellProperties/>;
		
		var location:XML = this.location.toXML();
		var condition:XML = this.condition.toXML();
		var styles:XML = super.toXML();
		
		if(location.attributes().length())
			result.location.* += location;
		
		if(condition.children().length())
			result.condition.* += condition;
		
		if(styles.children().length())
			result.styles.* += styles;
		
		return result;
	}
}
}