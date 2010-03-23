package com.flextras.calc
{
import com.flextras.spreadsheet.ISpreadsheet;

import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;

import mx.core.UIComponent;

public class ControlObject
{
	private var _rowIndex : int;
	
	public function get rowIndex () : int
	{
		return _rowIndex;
	}
	
	public function set rowIndex (value : int) : void
	{
		_rowIndex = value;
		
		_id = String(Utils.alphabet[_colIndex]).toLowerCase() + _rowIndex;
	}
	
	private var _colIndex : int;
	
	public function get colIndex () : int
	{
		return _colIndex;
	}
	
	public function set colIndex (value : int) : void
	{
		_colIndex = value;
		
		_id = String(Utils.alphabet[_colIndex]).toLowerCase() + _rowIndex;
	}
	
	private var _exp : String = "";
	
	public function get exp () : String
	{
		return _exp;
	}
	
	public function set exp (value : String) : void
	{
		_exp = value;
	}
	
	private var _id : String;
	
	public function get id () : String
	{
		return _id;
	}
	
	public function set id (value : String) : void
	{
		_id = value;
		
		var l : Array = Utils.gridFieldToIndexes(value);
		colIndex = l[0];
		rowIndex = l[1];
	}
	
	public var valueProp : String;
	
	public var ctrl : Object;
	
	public var dependants : Array = [];
	
	public var ctrlOperands : Array = [];
	
	public var grid : ISpreadsheet;
	
	public var collection : *;
	
	public var children : Array = [];
	
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