package com.flextras.paintgrid
{
import mx.events.PropertyChangeEvent;

public class CellEvent extends PropertyChangeEvent
{
	public static const STYLES_CHANGED : String = "stylesChanged";
	
	public static const ROLLOVER_STYLES_CHANGED : String = "rollOverStylesChanged";
	
	public static const SELECTED_STYLES_CHANGED : String = "selectedStylesChanged";
	
	public static const DISABLED_STYLES_CHANGED : String = "disabledStylesChanged";
	
	public static const CONDITION_CHANGED : String = "conditionChanged";
	
	public function CellEvent (type : String, bubbles : Boolean = false, cancelable : Boolean = false, kind : String = null, property : Object = null, oldValue : Object = null, newValue : Object = null, source : Object = null)
	{
		super(type, bubbles, cancelable, kind, property, oldValue, newValue, source);
	}
}
}