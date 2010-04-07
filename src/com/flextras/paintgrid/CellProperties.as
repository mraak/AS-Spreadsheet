package com.flextras.paintgrid
{
import com.flextras.spreadsheet.context.LocalContextMenu;

import flash.events.Event;

[Event(name="selectedChanged", type="flash.events.Event")]
[Event(name="conditionChanged", type="com.flextras.paintgrid.CellEvent")]

public class CellProperties extends StylesProxy
{
	public const location:CellLocation = new CellLocation;
	
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
	public function get conditionEnabled():Boolean
	{
		return _conditionEnabled;
	}

	public function set conditionEnabled(value:Boolean):void
	{
		_conditionEnabled = value;
		
		condition_changeHandler(null);
	}

	override public function release () : void
	{
		super.release();
		
		if (menu)
			menu.unsetContextMenu(null);
	}
	
	override public function set enabled (value : Boolean) : void
	{
		if (menu)
			menu.enabled = value;
		
		super.enabled = value;
	}
	
	protected var _menu : LocalContextMenu;
	
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
	
	public function equalLocation (cell : CellLocation) : Boolean
	{
		return location.equal(cell);
	}
	
	override public function get valid () : Boolean
	{
		return super.valid;
	}
	
	protected function condition_changeHandler (e : Event) : void
	{
		dispatchEvent(new CellEvent(CellEvent.CONDITION_CHANGED));
	}
	
	override public function fromXML(value:XML):void
	{
		super.fromXML(value.styles);
		
		location.fromXML(value.location);
		condition.fromXML(value.condition);
	}
	
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