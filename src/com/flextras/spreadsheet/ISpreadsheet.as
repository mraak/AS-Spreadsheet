package com.flextras.spreadsheet
{
import com.flextras.calc.Calc;

import mx.collections.ArrayCollection;

/**
 * This defines the interface for a spreadsheet class.  It is used by the Calc class for managing expressions.  
 *  
 * @author DotComIt / Flextras
 * 
 * @see com.flextras.calc.Calc
 * @see com.flextras.spreadsheet.Spreadsheet
 */
public interface ISpreadsheet
{

	/**
	 * @copy mx.core.UIComponent#id
	 */
	function get id () : String;
	/**
	 * @private 
	 */
	function set id (value : String) : void;
	
	//function set ctrlObjects(value:Object):void;
	/**
	 * IThis property contains the control objects for each cell.  
	 * A control object is a value object that contains information about the cell, formulas, and other information.  
	 * Each Control Object is created as a property on the ctrlObjects object, and the id is used an identifier.  
	 * 
	 * @see com.flextras.calc.ControlObject
	 */
	function get ctrlObjects () : Object;
	
	/**
	 * This property contains a reference to the calc object instance which performs all calculation logic for cell expressions.
	 * 
	 * @see com.flextras.calc.Calc
	 */	
	function get calc () : Calc;
	/**
	 * @private 
	 */
	function set calc (value : Calc) : void;
	
	/**
	 * This property exposes all cell of the Spreadsheet.
	 */
	function get gridDataProvider () : ArrayCollection;
	
	/**
	 * 
	 */
	function get expressionTree () : Array;
	
	/**
	 * The expressions property is similar to a dataProvider.  It is used to populate the spreadsheet with your data.
	 * 
	 * Each object in the spreadsheet should have a cell location property, an expression property, and a value.
	 * 
	 * The cell location property is named cell by default, but you can change that using either the cellField or cellFunction properties.  
	 * The format for this property is "[column index in alphabetical form][row index in numerical form]".  
	 * "a1" for example points to column 0 and row 1.
	 * 
	 * The expression property is named expression by default and should include a valid expression.  
	 * This can be a number, text, or a formula.  
	 * If your expression dataProvider does not have a property named expression property you can specify an alternate one using the 
	 * expressionField or expressionFunction. 
	 * 
	 * The value property specifies the value of the expression.  
	 * If your expression dataProvider does not have a property named value you can specify an alternate property using the valueField or 
	 * valueFunction.  
	 */	
	function get expressions () : ArrayCollection;
	/**
	 * @private 
	 */
	function set expressions (value : ArrayCollection) : void;
	
	/**
	 * This method will return the object representing the cell based on the location that you specify.  
	 * 
	 * @param cellId The format for this property is "[column index in alphabetical form][row index in numerical form]".  "a1" for example points to column 0 and row 1.
	 * @return This method returns the object from your dataProvider that represents the requested cell location.
	 * 
	 */
	function getExpressionObject (cellId : String) : Object;
	
	/**
	 * This method will add a single expression to the specified location.  If an expression already exists at the specified cell location, then it will be replaced.  
	 * 
	 * @param cellId This argument  specifies the cell location for the new expression.  
	 * The format for this property is "[column index in alphabetical form][row index in numerical form]".  
	 * "a1" for example points to column 0 and row 1.
	 * 
	 * @param expression This argument specifies the newexpression to put at the target cell’s location.  
	 * The results of the expression will be seen in the target sell.  
	 * If you specify null or an empty string, the expression at the cell location will be removed.
	 * 
	 * 
	 */
	function assignExpression (cellId : String, expression : String) : void;
	
	/**
	 * This method will force all expressions to invalidate during the next render event.
	 */
	function updateExpressions () : void;
}

}