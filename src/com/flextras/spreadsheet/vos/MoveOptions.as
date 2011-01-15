package com.flextras.spreadsheet.vos
{

/**
 * Used in Spreadsheet.moveCells method. It tells the method what should be moved.
 *
 * @see com.flextras.spreadsheet.Spreadsheet#moveCells
 */
public class MoveOptions
{
	/**
	 * Tells moveCells method to move everything - expressions, styles, conditions, values.
	 */
	public static const ALL : String = "all";
	
	/**
	 * Tells moveCells method to move expressions.
	 */
	public static const EXPRESSIONS : String = "expressions";
	
	/**
	 * Tells moveCells method to move styles.
	 */
	public static const STYLES : String = "styles";
	
	/**
	 * Tells moveCells method to move conditions.
	 */
	public static const CONDITIONS : String = "conditions";
	
	/**
	 * Tells moveCells method to move values.
	 */
	public static const VALUES : String = "values";
}
}