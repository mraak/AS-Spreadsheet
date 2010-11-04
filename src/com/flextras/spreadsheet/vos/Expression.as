package com.flextras.spreadsheet.vos
{

[Bindable]
/**
 * @private For now.
 */
public class Expression
{
	public var cell : String,
		expression : String,
		columnSpan : uint,
		rowSpan : uint,
		styles : CellStyles,
		stylesObject : Object,
		condition : Condition,
		conditionObject : Object,
		enabled : Boolean;
}
}