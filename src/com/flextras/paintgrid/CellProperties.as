package com.flextras.paintgrid
{
import flash.events.Event;

import mx.events.PropertyChangeEvent;
import mx.events.PropertyChangeEventKind;
import mx.utils.ObjectProxy;

[Event(name="enabledChanged", type="flash.events.Event")]
[Event(name="selectedChanged", type="flash.events.Event")]
[Event(name="stylesChanged", type="com.flextras.paintgrid.CellEvent")]
[Event(name="rollOverStylesChanged", type="com.flextras.paintgrid.CellEvent")]
[Event(name="selectedStylesChanged", type="com.flextras.paintgrid.CellEvent")]
[Event(name="disabledStylesChanged", type="com.flextras.paintgrid.CellEvent")]
public class CellProperties extends CellLocation
{
	public var owner : PaintGridColumnItemRenderer;
	
	public var state : String = "normal";
	
	public var oldState : String;
	
	protected var _styles : ObjectProxy = new ObjectProxy;
	
	protected var _rollOverStyles : ObjectProxy = new ObjectProxy;
	
	protected var _selectedStyles : ObjectProxy = new ObjectProxy;
	
	protected var _disabledStyles : ObjectProxy = new ObjectProxy;
	
	public function CellProperties (row : int, column : int, styles : Object = null, rollOverStyles : Object = null, selectedStyles : Object = null, disabledStyles : Object = null)
	{
		super(row, column);
		
		this.styles = new ObjectProxy(styles);
		this.rollOverStyles = new ObjectProxy(rollOverStyles);
		this.selectedStyles = new ObjectProxy(selectedStyles);
		this.disabledStyles = new ObjectProxy(disabledStyles);
		
		_styles.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE, styles_changeHandler);
		_rollOverStyles.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE, rollOverStyles_changeHandler);
		_selectedStyles.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE, selectedStyles_changeHandler);
		_disabledStyles.addEventListener(PropertyChangeEvent.PROPERTY_CHANGE, disabledStyles_changeHandler);
	}
	
	protected var _enabled : Boolean = true;
	
	[Bindable(event="enabledChanged")]
	public function get enabled () : Boolean
	{
		return _enabled;
	}
	
	public function set enabled (value : Boolean) : void
	{
		if (_enabled == value)
			return;
		
		_enabled = value;
		
		dispatchEvent(new Event("enabledChanged"));
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
	
	[Bindable(event="stylesChanged")]
	public function get styles () : ObjectProxy
	{
		return _styles;
	}
	
	public function set styles (value : ObjectProxy) : void
	{
		if (!value)
			return;
		
		for (var style : String in value)
			_styles[style] = value[style];
	}
	
	[Bindable(event="rollOverStylesChanged")]
	public function get rollOverStyles () : ObjectProxy
	{
		return _rollOverStyles;
	}
	
	public function set rollOverStyles (value : ObjectProxy) : void
	{
		if (!value)
			return;
		
		for (var rollOverStyle : String in value)
			_rollOverStyles[rollOverStyle] = value[rollOverStyle];
	}
	
	[Bindable(event="selectedStylesChanged")]
	public function get selectedStyles () : ObjectProxy
	{
		return _selectedStyles;
	}
	
	public function set selectedStyles (value : ObjectProxy) : void
	{
		if (!value)
			return;
		
		for (var selectedStyle : String in value)
			_selectedStyles[selectedStyle] = value[selectedStyle];
	}
	
	[Bindable(event="disabledStylesChanged")]
	public function get disabledStyles () : ObjectProxy
	{
		return _disabledStyles;
	}
	
	public function set disabledStyles (value : ObjectProxy) : void
	{
		if (!value)
			return;
		
		for (var disabledStyle : String in value)
			_disabledStyles[disabledStyle] = value[disabledStyle];
	}
	
	public function equalLocation (cell : CellLocation) : Boolean
	{
		if (!cell)
			return false;
		
		return super.equal(cell);
	}
	
	override public function get valid () : Boolean
	{
		return super.valid && styles && typeof(styles) == "object" && rollOverStyles && typeof(rollOverStyles) == "object" && selectedStyles && typeof(selectedStyles) == "object" && disabledStyles && typeof(disabledStyles) == "object";
	}
	
	protected function styles_changeHandler (e : PropertyChangeEvent) : void
	{
		dispatchEvent(getEvent(CellEvent.STYLES_CHANGED, e));
	}
	
	protected function rollOverStyles_changeHandler (e : PropertyChangeEvent) : void
	{
		dispatchEvent(getEvent(CellEvent.ROLLOVER_STYLES_CHANGED, e));
	}
	
	protected function selectedStyles_changeHandler (e : PropertyChangeEvent) : void
	{
		dispatchEvent(getEvent(CellEvent.SELECTED_STYLES_CHANGED, e));
	}
	
	protected function disabledStyles_changeHandler (e : PropertyChangeEvent) : void
	{
		dispatchEvent(getEvent(CellEvent.DISABLED_STYLES_CHANGED, e));
	}
	
	protected function getEvent (type : String, e : PropertyChangeEvent) : CellEvent
	{
		return new CellEvent(type, false, false, PropertyChangeEventKind.UPDATE, e.property, e.oldValue, e.newValue, this);
	}
}
}