package com.flextras.calc
{

import com.flextras.spreadsheet.ISpreadsheet;

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;

//----------------------------------
//  Events
//----------------------------------

/**
 * Dispatched when exp property gets changed.
 */
[Event(name="expressionChanged", type="flash.events.Event")]

/**
 * ControlObject is an essential class when working with Calc.
 * You don't need to access it directly but Calc uses it internally extensivelly.
 * Each ControlObject 'controls' one element of the calculation logic, like TextField or Spreadsheet cell.
 * This element that is under control is referenced by ControlObject.ctrl property.
 *
 * */
[RemoteClass]
public class ControlObject extends EventDispatcher
{
	/**
	 * If this ControlOBject controls a cell in ISpreadsheet this propery specifies a row of the ISpreadsheet where the cell is located
	 * */
	public var row : String;
	
	/**
	 * If this ControlOBject controls a cell in ISpreadsheet this propery specifies an index of the row in the ISpreadsheet where the cell is located
	 * */
	public var rowIndex : int;
	
	/**
	 * If this ControlOBject controls a cell in ISpreadsheet this propery specifies a column of the ISpreadsheet where the cell is located, e.g. "A"
	 * */
	public var col : String;
	
	/**
	 * If this ControlOBject controls a cell in ISpreadsheet this propery specifies an index of the cell in the ISpreadsheet where the cell is located
	 * */
	public var colIndex : int;
	
	/**
	 * Used occasinally for the purpose of ISpreadsheet relocation of cells
	 * */
	public var oldID : String;
	
	/**
	 * Used occasinally for the purpose of ISpreadsheet relocation of cells
	 * */
	public var temporaryOldID : String;
	
	/**
	 * Property of ControlObject.ctrl that holds a value that will be used for calculation, e.g. "text" for TextInput
	 * */
	public var valueProp : String;
	
	/**
	 * Object that this ControlObject controls.
	 * It can be anything you register to Calc, like Cell, TextInput, Slider, Object, etc...
	 * */
	public var ctrl : Object;
	
	/**
	 * All ControlObjects that are dependent on this ControlObject by having it as an operand in its exp properties
	 * */
	public var dependants : Array = new Array ();
	
	/**
	 * All ControlObjects that are used as operands in the exp property of this ControlObject
	 * */
	public var ctrlOperands : Array = new Array ();
	
	/**
	 * References the ISpreadsheet that this object belongs to (if it belongs to one).
	 * For example every Cell within ISpreadsheet has one ControlObject that controls it.
	 *
	 * */
	[Transient]
	public var grid : ISpreadsheet;
	
	/**
	 * References the collection that this object belongs to (if it belongs to one).
	 * For example if you add ArrayCollection to Calc.addCollection() for every
	 * element in the ArrayCollection one ControlObject is created with this property referencing an ArrayCollection.
	 * */
	public var collection : *;
	
	/**
	 *
	 * */
	[Deprecated]
	public var children : Array = new Array ();
	
	/**
	 * Contructor.
	 * */
	public function ControlObject (target : IEventDispatcher = null)
	{
		super (target);
	}
	
	//-------------------------------------
	// id
	//-------------------------------------
	private var _id : String;
	
	/**
	 * Id of the ControlObject is used to retrieve it from various collections.
	 * Sometimes it is the same as of the object it controls - ControlObject.ctrl.id
	 * */
	public function get id () : String
	{
		return _id;
	}
	
	public function set id (value : String) : void
	{
		temporaryOldID = oldID = _id;
		
		_id = value;
	}
	
	//-------------------------------------
	// exp
	//-------------------------------------
	private var _exp : String = "";
	
	/**
	 * Sets / gets the expression to this object, e.g. "= 3 + 5"
	 * */
	[Bindable(event="expressionChanged")]
	public function get exp () : String
	{
		return _exp;
	}
	
	public function set exp (val : String) : void
	{
		if (_exp == val)
			return;
		
		_exp = val;
		
		dispatchEvent (new Event ("expressionChanged"));
	}
	
	//-------------------------------------
	// toolTipLabelTree
	//-------------------------------------
	
	/**
	 * Returns a string that represents object info that can be used for tooltip or other purpose
	 * */
	public function get toolTipLabelTree () : String
	{
		var se : String = (_exp) ? _exp : "";
		var sv : String = ctrl[valueProp];
		
		var a : Array = sv.match (/[^0-9\-]/g);
		
		sv = (a.length > 0) ? "'" + sv + "'" : sv;
		
		var gr : String = grid ? grid.id + "!" : "";
		
		return gr + id + ":  " + sv + se;
	}
	
	//-------------------------------------
	// toolTipLabel
	//-------------------------------------
	/**
	 * Returns a string that represents object info that can be used for tooltip or other purpose
	 * */
	public function get toolTipLabel () : String
	{
		return "id: " + id + "\n" + toolTipLabelTree;
	}
}
}