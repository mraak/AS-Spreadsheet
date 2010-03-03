package com.flextras.spreadsheet
{
import com.flextras.calc.Calc;

import mx.collections.ArrayCollection;

public interface ISpreadsheet
{
	function set id (value : String) : void;
	function get id () : String;
	
	//function set ctrlObjects(value:Object):void;
	function get ctrlObjects () : Object;
	
	function set calc (value : Calc) : void;
	function get calc () : Calc;
	
	function get gridDataProvider () : ArrayCollection;
	
	function get expressionTree () : Array;
	
	function get renderers () : Object;
	
	function set expressions (value : ArrayCollection) : void;
	function get expressions () : ArrayCollection;
	
	function assignExpression (cellId : String, expression : String) : void;
	
	function updateExpressions () : void;
}

}