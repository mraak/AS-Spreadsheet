package com.flextras.calc
{
import com.flextras.spreadsheet.ISpreadsheet;
import com.flextras.spreadsheet.Spreadsheet;
import com.flextras.spreadsheet.SpreadsheetEvent;

import flash.events.EventDispatcher;

import mx.collections.ArrayCollection;
import mx.core.UIComponent;
import mx.events.CollectionEvent;
import mx.events.FlexEvent;

import spark.components.TextInput;


[Event(name="error", type="com.flextras.spreadsheet.SpreadsheetEvent")]
[Event(name="warning", type="com.flextras.spreadsheet.SpreadsheetEvent")]

/**
 * Calc is the main class for performing all the calculation logic. It can evaluate 
 * mathematical expressions from strings and calculate the result. It can register various
 * objects, Flex controls, or Flash components and use them as operands in the expression.
 * <br/><br/>
 * It supports these operators: ^, *, /, +, -. It uses the following order of precedence:<br/>
 * 1. ^ <br/>
 * 2. *, / <br/>
 * 3. +, - <br/>
 * <br/>
 * It can also solve wide range of formulas, such as SUM, MEDIAN, PI, etc.<br/>
 * @see com.flextras.calc.FormulaBasic
 * @see com.flextras.calc.FormulaLogic
 * @see com.flextras.calc.FormulaConst
 * 
 * */
public class Calc extends EventDispatcher
{
	private var _gridCollection : Object;
	
	private var _ctrlCollection : Object;
	
	private var _collections : Object;
	
	public var ignoreCase : Boolean;
	
	public var currentTarget : ControlObject;
	
	[Bindable]
	public var expressionTree : Array;
	
	private var currentOriginator : ControlObject;
	
	private var dependantsTree : Object;
	
	private var currentDependantsTreeObject : Object;
	
	private var operandError : String = null;
	
	private var repairedExpression : String;
	
	public function Calc ()
	{
		init();
	}
	
	private function init () : void
	{
		_ctrlCollection = new Object();
		_gridCollection = new Object();
		_collections = new Object();
		expressionTree = new Array();
		ignoreCase = false;
	
	}
	
	/**
	 * Call this method to solve the math expression. 
	 * Also supports negative numbers. Supports formulas like SUM(2,3), MAX(a1:d3), etc.
	 *
	 * returns: Number, which is the numerical solution to expression
	 * params: exp (String), math expression in a string, e.g.
	 *
	 * */
	public function solveExpression (exp : String, forget : Boolean = true) : String
	{
		var isValid : String = Utils.checkValidExpression(exp);
		operandError = null;
		
		if (isValid == "ok")
		{
			var res : Number;
			
			// TODO: Delete
			// sheets/grids with labels containing spaces
			//var rxSheetLabel : RegExp = /'[^']+'!/g;
			
			// remove white spaces from expression		
			exp = exp.replace(/\s+/g, "");
			
			// add outer brackets to the expression to enable iterative paren solving
			exp = "(" + exp + ")";
			
			// convert negative values from - to ~. E.g. 5+-3, into 5+~3
			// var rxNeg:RegsExp = /([\(\+\-\*\/])\-/g;
			var rxNeg : RegExp = /([\(\+\-\*\/])\-([A-Za-z0-9\(])/g;
			
			exp = exp.replace(rxNeg, "$1~$2");
			
			exp = Utils.repairOperators(exp);
			
			// remember the expression before it gets modified into result
			if (!forget)
				repairedExpression = Utils.repairExpression(exp);
			
			// find the innermost brackets, also see if brackets are part of formula - SUM(args)
			var rxParen : RegExp = /([A-Za-z]*)\([^()]*\)/g;
			
			// repeat while all the brackets are gone, method called to replace brackets with a value is solveParen
			while (exp.indexOf("(") != -1)
			{
				exp = exp.replace(rxParen, solveParen);
			}
			
			// replace ! back to -, for casting to number, negative if you will
			exp = exp.replace("~", "-");
			
			res = Number(exp);
		}
		else
		{
			exp = isValid;
			
			var errEvt : SpreadsheetEvent = new SpreadsheetEvent(SpreadsheetEvent.ERROR);
			errEvt.message = isValid;
			this.dispatchEvent(errEvt);
		}
		
		if (operandError)
		{
			exp = operandError;
			
			var errEvt1 : SpreadsheetEvent = new SpreadsheetEvent(SpreadsheetEvent.ERROR);
			errEvt1.message = operandError;
				//this.dispatchEvent(errEvt1);
		}
		
		if (Utils.isString(exp))
			exp = Utils.stripStringQuotes(exp);
		
		return exp;
	
	}
	
	/**
	 * Pass individal bracket to this function.
	 * Returns a string that is numeric solution to the expression in brackets
	 *
	 * */
	private function solveParen () : String
	{
		var args : Array = arguments;
		
		var exp : String = arguments[0];
		
		var ops : RegExp = /[\/\*\+\-\^~]+/g;
		var a : Array = exp.match(ops)
		
		if (exp.substr(0, 1) != "(")
		{
			exp = solveFormula(exp);
		}
		else if (a.length == 0)
		{
			exp = exp.replace(/[\(\)]/g, "");
			
			if (!Utils.isString(exp))
				exp = getValueFromOperand(exp).toString();
		}
		else
		{
			// remove enclosing brackets from string
			exp = exp.replace(/[\(\)]/g, "");
			
			// find a simple expression with operator, one operand on the left, and one operand on the right
			// this RegExp takes care of ^ operator
			// example: 4+5*4^3, results in finding first 4^3, then 5*4 in the second while iteration
			var regex : RegExp = /([a-zA-Z0-9~!\.]+)(\^)([a-zA-Z0-9~!\.]+)/g;
			
			// do while there are no more operators.
			// function called to replace this expression with a numeric string is solveSimple
			while (exp.indexOf("^") != -1)
			{
				exp = exp.replace(regex, solveSimple);
			}
			
			
			// find a simple expression with operator, one operand on the left, and one operand on the right
			// this RegExp takes care of * and / operators
			// example: 4+5*4*3, results in finding first 5*4, then 20*3 in the second while iteration
			regex = /([a-zA-Z0-9~!\.]+)([\*\/])([a-zA-Z0-9~!\.]+)/g;
			
			// do while there are no more operators.
			// function called to replace this expression with a numeric string is solveSimple
			while (exp.indexOf("*") != -1 || exp.indexOf("/") != -1)
			{
				exp = exp.replace(regex, solveSimple);
			}
			
			// find a simple expression with operator, one operand on the left, and one operand on the right
			// this RegExp takes care of + and - operators
			// example: 1+2-4, results in finding first 1+2, then 3-4, in the second while iteration  
			regex = /([a-zA-Z0-9~!\.]+)([\+-])([a-zA-Z0-9~!\.]+)/g;
			
			// do while there are no more operators.
			// function called to replace this expression with a numeric string is solveSimple
			while (exp.indexOf("+") != -1 || exp.indexOf("-") != -1)
			{
				exp = exp.replace(regex, solveSimple);
			}
		}
		
		return exp;
	}
	
	private function solveFormula (exp : String) : String
	{
		var regex : RegExp = /[A-Z]*\(([^()]*)\)/g;
		var formula : String = exp.substr(0, exp.indexOf("("));
		
		exp = exp.replace(regex, "$1");
		
		var range : Array = new Array();
		var args : Array = new Array();
		
		
		if (FormulaConst.functions.indexOf(formula.toLowerCase()) > -1)
		{
			exp = FormulaConst.solve(formula);
		}
		
		else if (FormulaBasic.functions.indexOf(formula.toLowerCase()) > -1)
		{
			Utils.calc = this;
			
			range = Utils.resolveFieldsRange(exp);
			
			if (range.length == 0)
			{
				var erev2 : SpreadsheetEvent = new SpreadsheetEvent(SpreadsheetEvent.WARNING);
				erev2.message = "Supplied formula / function range not valid: " + exp;
				this.dispatchEvent(erev2);
			}
			else
			{
				for each (var arg : String in range)
				{
					if (formula == "COUNT")
					{
						args.push(getValueFromOperand(arg, "nan"));
					}
					else
					{
						args.push(getValueFromOperand(arg));
					}
				}
			}
			
			exp = FormulaBasic.solve(formula, args);
			
		}
		
		else if (FormulaLogic.functions.indexOf(formula.toLowerCase()) > -1)
		{
			
			//exp = FormulaLogic.solve(formula, exp.split(","));
			
			var input : Array = exp.split(",");
			
			if (formula.toLowerCase() == FormulaLogic.IF)
			{
				//TODO: report error and return
				if (input.length != 3)
				{
					//throw(new Error("IF function has wrong number of parameters"));
					
					var ifErrEvt : SpreadsheetEvent = new SpreadsheetEvent(SpreadsheetEvent.ERROR);
					ifErrEvt.message = "IF function has wrong number of parameters, reqired 3, found: " + input.length;
					this.dispatchEvent(ifErrEvt);
				}
				
				var logTest : Object = Utils.breakComparisonInput(input[0]);
				
				var arg1 : String = solveExpression(logTest.arg1);
				var arg2 : String = solveExpression(logTest.arg2);
				var op : String = logTest.op;
				
				var val1 : String = Utils.isString(input[1]) ? input[1] : solveExpression(input[1]);
				var val2 : String = Utils.isString(input[2]) ? input[2] : solveExpression(input[2]);
				
				exp = FormulaLogic.solve(formula, [arg1, op, arg2, val1, val2]);
			}
			else if (formula.toLowerCase() == FormulaLogic.COUNTIF)
			{
				//TODO: report error and return
				if (input.length != 2)
				{
					//throw(new Error("IF function has wrong number of parameters"));
					
					var countifErrEvt : SpreadsheetEvent = new SpreadsheetEvent(SpreadsheetEvent.ERROR);
					countifErrEvt.message = "COUNTIF function has wrong number of parameters, reqired 2, found: " + input.length;
					this.dispatchEvent(countifErrEvt);
				}
				
				var countRange : Array = Utils.resolveFieldsRange(input[0]);
				
				var argsCIF : Array = new Array();
				
				for each (var argCIF : String in countRange)
				{
					argsCIF.push(getValueFromOperand(argCIF, "nan"));
				}
				
				var condition : String = input[1];
				
				//condition = condition.replace("'","");
				condition = condition.replace(/'/g, "");
				condition = condition.replace(/\"/g, "");
				var logTestCIF : Object = Utils.breakComparisonInput(condition);
				
				exp = FormulaLogic.solve(formula, [argsCIF, logTestCIF.op, logTestCIF.arg2]);
				
				var p : int = 0;
				
			}
			
		}
		else
		{
			var erev : SpreadsheetEvent = new SpreadsheetEvent(SpreadsheetEvent.ERROR);
			erev.message = "Function or formula not recognized: " + formula;
			this.dispatchEvent(erev);
		}
		
		exp = exp.replace("-", "~");
		
		return exp;
	}
	
	/**
	 * Solves simple expressions with one operator, one operand on the left, and one operand on the right.
	 * Returns a numerical string that is a solution to passed expression.
	 * Parameter: <i>arguments</i> (Array) is automatically passed from String.replace() function in solveParen method.
	 * */
	private function solveSimple () : String
	{
		var op : String = arguments[2];
		
		var sLeft : String = arguments[1];
		sLeft = sLeft.replace("~", "-");
		var left : Number = getValueFromOperand(sLeft);
		
		var sRight : String = arguments[3];
		sRight = sRight.replace("~", "-");
		var right : Number = getValueFromOperand(sRight);
		
		var res : Number;
		
		switch (op)
		{
			case "+":
				res = left + right;
				break;
			
			case "-":
				res = left - right;
				break;
			
			case "*":
				res = left * right;
				break;
			
			case "/":
				res = left / right;
				break;
			
			case "^":
				res = Math.pow(left, right);
				break;
		}
		
		var sRes : String = res.toString();
		
		// convert negative values from - to !. E.g. -2, into !2
		sRes = sRes.replace("-", "~");
		
		return sRes;
	}
	
	/**
	 * This method extracts the value from any operand on the left or right of the operator.
	 * Legal values for operands:
	 * - [fieldId] - Id of any existing field that was assigned to this Calc
	 * - -[fieldId] - negative value in front of a field Id of any existing field that was assigned to this Calc
	 * - N - any number
	 * - -N - negative value of any number
	 * E.G.:
	 *  - a1+4, -field2*-4, 5+6, -b2-8
	 *
	 * */
	public function getValueFromOperand (operand : String, emptyStringPolicy : String = "zero") : Number
	{
		var rn : Number;
		var m : Number = 1;
		
		if (operand.substr(0, 1) == "-")
		{
			m = -1;
			operand = operand.substr(1);
		}
		
		if (isNaN(Number(operand)))
		{
			var co : ControlObject = getCtrlById(operand);
			
			if (co != null)
			{
				if (co.ctrl[co.valueProp] == "" && emptyStringPolicy == "nan")
				{
					rn = NaN;
				}
				else
				{
					rn = Number(co.ctrl[co.valueProp]);
				}
				
				if (currentTarget)
				{
					if (currentTarget.ctrlOperands.indexOf(co) == -1)
					{
						currentTarget.ctrlOperands.push(co);
						currentTarget.children.push(co);
					}
				}
			}
			else
			{
				rn = 0;
				var erev : SpreadsheetEvent = new SpreadsheetEvent(SpreadsheetEvent.WARNING);
				erev.message = "Operand does not exist: " + operand + ". Calculations might not appear as expected.";
				this.dispatchEvent(erev);
				
					//operandError = "!Error: Operand does not exist: " + operand;
			}
		}
		else
		{
			rn = Number(operand);
		}
		
		rn *= m;
		
		return rn;
	}
	
	public function getCtrlById (ctrlId : String) : ControlObject
	{
		var ro : ControlObject;
		
		if (ignoreCase)
			ctrlId = ctrlId.toLowerCase();
		
		var collectionId : String;
		var objectId : String;
		var objectIndex : String;
		
		if (ctrlId.indexOf("!") != -1)
		{
			var arr : Array = ctrlId.split("!");
			collectionId = arr[0];
			objectId = arr[1].toString();
			
			if (arr[2])
			{
				objectIndex = arr[2];
				
				if (_collections[collectionId])
				{
					
					var col : ArrayCollection = _collections[collectionId].collection;
					
					if (currentTarget)
					{
						var arr1 : Array = getDependantsOfCollection(col);
						
						if (arr1.indexOf(currentTarget) == -1)
							arr1.push(currentTarget);
					}
					
					if (int(objectIndex) < col.length)
					{
						ro = new ControlObject();
						ro.collection = col;
						ro.ctrl = col.getItemAt(int(objectIndex));
						ro.valueProp = objectId;
						ro.id = ctrlId;
						
					}
					else
					{
						var erev : SpreadsheetEvent = new SpreadsheetEvent(SpreadsheetEvent.ERROR);
						erev.message = "Operand index out of bounds on collection: " + ctrlId + ". Calculations might not appear as expected.";
							//this.dispatchEvent(erev);
							//return null;
					}
				}
				else
				{
					var erev1 : SpreadsheetEvent = new SpreadsheetEvent(SpreadsheetEvent.ERROR);
					erev1.message = "Collection does not exist: " + collectionId + ". Calculations might not appear as expected.";
						//this.dispatchEvent(erev1);
						//return null;
				}
			}
			else if (_gridCollection[collectionId])
			{
				var gr : ISpreadsheet = _gridCollection[collectionId];
				ro = gr.ctrlObjects[objectId];
				
			}
			
		}
		else
		{
			ro = _ctrlCollection[ctrlId];
		}
		
		if (currentTarget)
			if (currentTarget.grid)
				if (currentTarget.grid.ctrlObjects[ctrlId.toLowerCase()])
					ro = currentTarget.grid.ctrlObjects[ctrlId.toLowerCase()];
		
		return ro;
	}
	
	/**
	 * From either string or ControlObject
	 * */
	public function getCtrl (ctrl : *) : ControlObject
	{
		var co : ControlObject;
		
		if (ctrl is String)
		{
			co = getCtrlById(ctrl);
		}
		else if (ctrl is ControlObject)
		{
			co = ctrl;
		}
		else if (ctrl is UIComponent)
		{
			if (ctrl.id)
			{
				co = getCtrlById(ctrl.id);
			}
			else
			{
				throw("UIComponent has to have 'id' property specified");
				
			}
		}
		else
		{
			throw("Incorect type for ctrl, supported are String, ControlObject, and UIComponent");
		}
		
		return co;
	}
	
	private function updateDependent (objectChanged : ControlObject) : void
	{
		if (objectChanged.grid)
		{
			objectChanged.grid.gridDataProvider.itemUpdated(objectChanged.ctrl);
		}
		
		if (objectChanged.dependants.length > 0)
		{
			for each (var c : ControlObject in objectChanged.dependants)
			{
				if (c != currentOriginator)
				{
					if (c.exp)
						assignControlExpression(c, c.exp, true);
					
					if (c.grid)
						c.grid.updateExpressions();
					/*	if(c.grid)
					   {
					   c.grid.assignExpression(c.id, c.exp);
					   }
					   else
					   {
					   assignControlExpression(c, c.exp, true);
					 }*/
				}
				else
				{
					var e : String = "Cyclic reference detected at: " + currentOriginator.id + "<->" + objectChanged.id + ". Reset this field.";
					
					var errEvt : SpreadsheetEvent = new SpreadsheetEvent(SpreadsheetEvent.ERROR);
					errEvt.message = e;
					this.dispatchEvent(errEvt);
					
					currentOriginator.ctrl[currentOriginator.valueProp] = e;
					currentOriginator.exp = null;
				}
			}
		}
	
	}
	
	/**
	 * Main function for assigning the expressions to the objects.
	 * - ctrl:*, object that you want to assign expression to. You can use the ID:String of the object or a reference to the object typed as ControlObject
	 * - expression:String, expression to be assigned, e.g. "=5+5"
	 * - update:Boolean, internal use
	 * */
	public function assignControlExpression (ctrl : *, expression : String, update : Boolean = false) : void
	{
		var exp : String = expression;
		var co : ControlObject;
		
		currentTarget = null;
		
		co = getCtrl(ctrl);
		currentTarget = co;
		
		trace("exp begin " + co.id + ".ops:" + co.ctrlOperands);
		
		// remove this object as dependant from all of the operands
		if (!update)
		{
			currentOriginator = co;
			
			for each (var op : ControlObject in co.ctrlOperands)
			{
				//trace("\t " + op.id + " " + op.dependants);
				var ind : int = op.dependants.indexOf(co);
				if(ind >= 0)
					op.dependants.splice(ind, 1);
					//trace("\t " + op.id + " " + op.dependants + " " + ind);
			}
			
			co.ctrlOperands = new Array();
			co.children = new Array();
		}
		
		var funcCalc : String;
		var _val : String;
		
		if (exp.substr(0, 1) == "=")
		{
			funcCalc = exp.substr(1);
			_val = solveExpression(funcCalc, false).toString();
			co.exp = "=" + repairedExpression;
			repairedExpression = null;
			
			if (!update && expressionTree.indexOf(co) == -1)
			{
				expressionTree.push(co);
				
				if (co.grid)
				{
					co.grid.expressionTree.push(co);
				}
			}
		}
		else if (exp == "")
		{
			_val = "";
			co.exp = null;
			
			if (!update)
			{
				var coind : int = expressionTree.indexOf(co);
				if(coind >= 0)
					expressionTree.splice(expressionTree.indexOf(co), 1);
				
				if (co.grid)
				{
					coind = co.grid.expressionTree.indexOf(co);
					if(coind >= 0)
						co.grid.expressionTree.splice(coind, 1);	
				}
					
			}
		}
		else
		{
			_val = exp;
			co.exp = null;
			
			if (!update)
			{
				expressionTree.push(co);
				
				if (co.grid)
					co.grid.expressionTree.push(co);
			}
		}
		
		// add this object as dependant to each operand
		if (!update)
		{
			trace("exp end " + co.id + ".ops:" + co.ctrlOperands);
			
			for each (op in co.ctrlOperands)
			{
				//trace("\t\to: "+op.id);
				op.dependants.push(co);
			}
		}
		
		co.ctrl[co.valueProp] = _val;
		
		if (!co.grid)
		{
			//UIComponent(co.ctrl).toolTip =  "id: " + co.id + "\nclass: " + UIComponent(co.ctrl).className + "\nexp: " + co.exp;
			try
			{
				UIComponent(co.ctrl).toolTip = co.toolTipLabel;
			}
			catch (e : Error)
			{
			}
		}
		
		updateDependent(co);
		
		if (co && co.grid && co.grid is ISpreadsheet)
		{
			var dg : ISpreadsheet = co.grid;
			var o : Object = dg.getCell(co.id);
			
			if (o)
			{
				var oldValue : Object = o.value;
				o.value = _val;
				dg.expressions.itemUpdated(o, "value", oldValue, _val);
			}
			
			dg.gridDataProvider.itemUpdated(co.ctrl, co.valueProp, oldValue, _val);
		}
		
		currentTarget = null;
	}
	
	public function assignExpression (target : *, expression : String) : void
	{
	
	}
	
	/**
	 * Cells are moved 'incrementaly', i.e. the expression on the target
	 * changes so that it includes different operands based on the
	 * horizontal and vertical move.
	 * fromField:String - You have to specify sheet id and field id, e.g.Sheet1!a0
	 * toField:String - You have to specify sheet id and field id, e.g.Sheet1!a0
	 * */
	public function moveField (fromField : String, toField : String, copy : Boolean = false) : void
	{
		var coFrom : ControlObject = getCtrlById(fromField);
		
		var dx : Number;
		var dy : Number;
		
		var frCol : Number = Utils.gridFieldToIndexes(fromField)[0];
		var frRow : Number = Utils.gridFieldToIndexes(fromField)[1];
		var frGrid : String = Utils.gridFieldToIndexes(fromField)[2];
		
		var toCol : Number = Utils.gridFieldToIndexes(toField)[0];
		var toRow : Number = Utils.gridFieldToIndexes(toField)[1];
		var toGrid : String = Utils.gridFieldToIndexes(toField)[2];
		
		dx = toCol - frCol;
		dy = toRow - frRow;
		
		var targetExp : String;
		
		if (!coFrom.exp)
		{
			targetExp = coFrom.ctrl[coFrom.valueProp];
		}
		else if (copy && coFrom.exp)
		{
			targetExp = Utils.moveExpression(coFrom, dx, dy);
		}
		else if (!copy && coFrom.exp)
		{
			targetExp = coFrom.exp;
		}
		
		if (!copy)
			assignControlExpression(fromField, "");
		
		assignControlExpression(toField, targetExp);
	
	}
	
	/**
	 * Range can contain only ControlObjects from the same grid. If toGrid is not specified,
	 * move occurs on the same grid as objects in the range Array.
	 * */
	public function moveRange (range : Array, dx : int, dy : int, copy : Boolean = false, toGrid : String = null) : void
	{
		if (!toGrid)
		{
			toGrid = ControlObject(range[0]).grid.id;
		}
		
		var copyArray : Array = new Array();
		var oldCopyArray : Array = new Array();
		var co : ControlObject;
		
		for each (var ctrl : * in range)
		{
			co = getCtrl(ctrl);
			
			if (!co.grid)
				throw(new Error("Only objects within ISpreadsheet can be moved"));
			
			oldCopyArray.push(co);
			
			var nco : ControlObject = new ControlObject();
			
			nco.id = Utils.moveFieldId(co.id, dx, dy);
			nco.grid = co.grid;
			
			if (copy)
			{
				if (co.exp)
				{
					nco.exp = Utils.moveExpression(co, dx, dy);
				}
				else
				{
					nco.exp = co.ctrl[co.valueProp];
				}
			}
			else
			{
				if (co.exp)
				{
					nco.exp = co.exp;
				}
				else
				{
					nco.exp = co.ctrl[co.valueProp];
				}
			}
			copyArray.push(nco);
		}
		
		if (!copy)
		{
			for each (co in oldCopyArray)
			{
				//assignControlExpression(co, "");
				co.grid.assignExpression(co.id, "");
				
			}
		}
		
		for each (co in copyArray)
		{
			//assignControlExpression(toGrid + "!" + co.id, co.exp);
			co.grid.assignExpression(co.id, co.exp);
		}
	
	}
	
	/**
	 * Range can contain only ControlObjects from the same grid. If toGrid is not specified,
	 * move occurs on the same grid as objects in the range Array.
	 * */
	public function moveRangeValues (range : Array, dx : int, dy : int, copy : Boolean = false, toGrid : String = null) : void
	{
		var ss : ISpreadsheet = ControlObject(range[0]).grid;
		
		if (!toGrid)
			toGrid = ss.id;
		
		var copyArray : Array = new Array();
		var oldCopyArray : Array = new Array();
		var co : ControlObject;
		
		for each (var ctrl : * in range)
		{
			co = getCtrl(ctrl);
			
			if (!co.grid)
				throw(new Error("Only objects within ISpreadsheet can be moved"));
			
			oldCopyArray.push(co);
			
			var id : String = Utils.moveFieldId(co.id, dx, dy);
			
			var nco : ControlObject = ss.ctrlObjects[id];
			
			if (!nco)
				continue;
			
			nco.exp = nco.ctrl[nco.valueProp] = co.ctrl[co.valueProp];
			
			copyArray.push(nco);
		}
		
		if (!copy)
		{
			for each (co in oldCopyArray)
			{
				//assignControlExpression(co, "");
				co.grid.assignExpression(co.id, "");
				
			}
		}
		
		for each (co in copyArray)
		{
			//assignControlExpression(toGrid + "!" + co.id, co.exp);
			co.grid.assignExpression(co.id, co.exp);
		}
	
	}
	
	public function getDependantsOfCollection (collection : *) : Array
	{
		var arr : Array;
		
		for each (var ob : Object in _collections)
		{
			if (ob.collection == collection)
			{
				arr = ob.dependants;
			}
			
		}
		return arr;
	}
	
	private function onCtrlChanged (evt : Event) : void
	{
		var co : ControlObject = getCtrlById(evt.currentTarget.id);
		
		if (co.ctrl is TextInput)
		{
			if (evt.type != FlexEvent.ENTER)
			{
				assignControlExpression(co.id, co.ctrl[co.valueProp]);
			}
			else
			{
				co.ctrl.stage.focus = null;
			}
		}
		else
		{
			currentOriginator = co;
			updateDependent(co);
		}
	}
	
	private function onCtrlFocus (evt : Event) : void
	{
		var co : ControlObject = getCtrlById(evt.currentTarget.id);
		
		if (co.ctrl is TextInput)
		{
			if (co.exp != null && co.exp != "")
				co.ctrl[co.valueProp] = co.exp;
		}
	}
	
	protected function onCollectionChange (e : CollectionEvent) : void
	{
		var dependants : Array = getDependantsOfCollection(e.target);
		
		for each (var co : ControlObject in dependants)
		{
			if (co.grid)
			{
				co.grid.assignExpression(co.id, co.exp);
			}
			else
			{
				assignControlExpression(co, co.exp);
			}
			
		}
	}
	
	/**
	 * Adds TextInput control and registers it with the Calc.
	 * This is a shortcut method to addControl if you only want to add TextInput.
	 * */
	public function addTextInput (textInput : TextInput) : void
	{
		addControl(textInput, "text", ["focusIn"], [FlexEvent.ENTER, "focusOut"]);
		//addControl(textInput, "text", ["focusIn"], ["enter", "focusOut"]);
	}
	
	/**
	 * Adds any Flex Control and registers it with the Calc. Calc then performs calculations and expressions
	 * assigned to this component through Calc.assignControlExpression() method.<br/><br/>
	 * <strong>ctrl: UIComponent</strong>, Flex Control you want to register with the Calc<br/>
	 * <strong>valueProp: String</strong>, property that holds a value for the control. It can be "value", "text", or any other you choose<br/>
	 * <strong>editStartEvents: Array</strong>, specifies which events is Calc listening to, to display the expression instead of value in the editor. Used primarily with TextInput compnent where you would specify [FocusEvent.FOCUS_IN]<br/>
	 * <strong>editEndEvents: Array</strong>, specifies which events are assigning are triggered when the ctrl's value has been modified. Example: [Event.CHANGE, FlexEvent.ENTER, FocusEvent.FOCUS_OUT]<br/>
	 * */
	public function addControl (ctrl : UIComponent, valueProp : String, editStartEvents : Array = null, editEndEvents : Array = null) : void
	{
		var ctrlObject : ControlObject = new ControlObject();
		ctrlObject.valueProp = valueProp;
		ctrlObject.ctrl = ctrl;
		ctrlObject.exp = "";
		ctrlObject.id = ctrl.id;
		_ctrlCollection[ctrlObject.id] = ctrlObject;
		
		var evt : String;
		
		UIComponent(ctrlObject.ctrl).toolTip = ctrlObject.toolTipLabel;
		
		if (editStartEvents)
		{
			for each (evt in editStartEvents)
			{
				ctrl.addEventListener(evt, onCtrlFocus);
			}
		}
		
		if (editEndEvents)
		{
			for each (evt in editEndEvents)
			{
				ctrl.addEventListener(evt, onCtrlChanged);
			}
		}
	}
	
	public function addObject (id : String, object : *, valueProp : String) : void
	{
		var ctrlObject : ControlObject = new ControlObject();
		ctrlObject.valueProp = valueProp;
		ctrlObject.ctrl = object;
		ctrlObject.exp = "";
		ctrlObject.id = id;
		_ctrlCollection[ctrlObject.id] = ctrlObject;
	}
	
	public function addSpreadsheet (sheet : ISpreadsheet) : void
	{
		if (sheet.id == "" || sheet.id == null)
		{
			throw(new Error("Sheet must have an ID in order to asociate it with the Calc"));
		}
		
		if (_gridCollection[sheet.id] != null)
		{
			throw(new Error("There is already a sheet with this ID: " + sheet.id));
		}
		
		if (sheet.calc != this)
			sheet.calc = this;
		_gridCollection[sheet.id] = sheet;
	}
	
	/**
	 * Calc currently supports ArrayCollection only
	 *
	 * */
	public function addCollection (id : String, collection : *) : void
	{
		if (collection is ArrayCollection)
		{
			var c : ArrayCollection = collection as ArrayCollection;
			c.addEventListener(CollectionEvent.COLLECTION_CHANGE, onCollectionChange);
			
			_collections[id] = new Object();
			_collections[id].collection = c;
			_collections[id].dependants = new Array();
		}
		else
		{
			throw(new Error("Calc.addCollection currently supports ArrayCollection only"));
		}
	}
	
	public function get gridCollection () : Object
	{
		return _gridCollection;
	}
	
	public function get ctrlCollection () : Object
	{
		return _ctrlCollection;
	}
	
	public function get collections () : Object
	{
		return _collections;
	}

}

}