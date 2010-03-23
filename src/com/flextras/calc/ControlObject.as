package com.flextras.calc
{
import com.flextras.spreadsheet.ISpreadsheet;

import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;

import mx.core.UIComponent;

[RemoteClass]
public class ControlObject extends EventDispatcher
{
	
	public var row : String;
	
	public var rowIndex : int;
	
	public var col : String;
	
	public var colIndex : int;
	
	private var _exp : String = "";
	
	public var id : String;
	
	public var valueProp : String;
	
	public var ctrl : Object;
	
	public var dependants : Array = new Array();
	
	public var ctrlOperands : Array = new Array();
	
	public var grid : ISpreadsheet;
	
	public var collection : *;
	
	public var children : Array = new Array();
	
	// PaintGrid helper
	//public var info : Row;
	
	public function ControlObject (target : IEventDispatcher = null)
	{
		//TODO: implement function
		super(target);
	}
	
	public function set exp (val : String) : void
	{
		_exp = val;
	}
	
	public function get exp () : String
	{
		return _exp;
	}
	
	public function get toolTipLabelTree () : String
	{
		var se : String = (_exp) ? _exp : "";
		var sv : String = ctrl[valueProp];
		
		var a : Array = sv.match(/[^0-9\-]/g);
		
		sv = (a.length > 0) ? "'" + sv + "'" : sv;
		
		var gr : String = grid ? grid.id + "!" : "";
		
		return gr + id + ":  " + sv + se;
	}
	
	public function get toolTipLabel () : String
	{
		var c : String = "class: " + UIComponent(ctrl).className;
		return c + "\nid: " + id + "\n" + toolTipLabelTree;
	}
}
}