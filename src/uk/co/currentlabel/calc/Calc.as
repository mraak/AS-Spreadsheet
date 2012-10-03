package uk.co.currentlabel.calc
{
import uk.co.currentlabel.spreadsheet.ISpreadsheet;
import uk.co.currentlabel.spreadsheet.Spreadsheet;
import uk.co.currentlabel.spreadsheet.events.SpreadsheetEvent;

import flash.events.EventDispatcher;

import mx.collections.ArrayCollection;
import mx.core.UIComponent;
import mx.events.CollectionEvent;
import mx.events.FlexEvent;

import spark.components.TextInput;


[Event(name="error", type="uk.co.currentlabel.spreadsheet.events.SpreadsheetEvent")]
[Event(name="warning", type="uk.co.currentlabel.spreadsheet.events.SpreadsheetEvent")]

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
 * @see uk.co.currentlabel.calc.FormulaBasic
 * @see uk.co.currentlabel.calc.FormulaLogic
 * @see uk.co.currentlabel.calc.FormulaConst
 *
 * */
public class Calc extends EventDispatcher
{
	
	// dictionary referencing all ISpreadsheet instances registered with Calc through addSpreadsheet()
	private var _gridCollection : Object;
	
	// dictionary referencing all ControlObject instances registered with Calc through addControl()
	private var _ctrlCollection : Object;
	
	// dictionary referencing all collections (ArrayCollection) registered with Calc through addCollection()
	private var _collections : Object;
	
	// used in some functions that do recursive calculations, this sets the ControlObject that triggered recursive chain of calculations
	private var _currentOriginator : ControlObject;
	
	// stores the exression repair attempt by Utils.repairExpression()
	private var _repairedExpression : String;
	
	/**
	 * Control Object that is currently being processed, used in update cycles.
	 * */
	public var currentTarget : ControlObject;
	
	
	/**
	 * Contains all ControlObject instances that have either expression or a value applied to it
	 * */
	[Bindable]
	public var expressionTree : Array;
	
	//----------------------------------
	//  Calc
	//----------------------------------
	/**
	 * Constructor. Creates a new instance of the Calc.
	 * */
	public function Calc()
	{
		init();
	}
	
	//----------------------------------
	//  init
	//----------------------------------
	/**
	 * @private
	 * Sets initial values
	 * */
	private function init() : void
	{
		_ctrlCollection = new Object();
		_gridCollection = new Object();
		_collections = new Object();
		expressionTree = new Array();
	}
	
	//----------------------------------
	//  solveExpression
	//----------------------------------
	/**
	 * Solves the mathemathical expression and supports formulas like SUM(2,3), MAX(a1:d3), etc.
	 *
	 * @param exp Expression that needs to be solved
	 * @param forget Internal, you never need to set this param
	 * @return A string that is numeric solution to the expression
	 *
	 * */
	public function solveExpression(exp : String, forget : Boolean = true) : String
	{
		var isValid : String = Utils.checkValidExpression(exp);
		
		if (isValid == "ok")
		{
			var res : Number;
			
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
				_repairedExpression = Utils.repairExpression(exp);
			
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
		
		
		if (Utils.isString(exp))
			exp = Utils.stripStringQuotes(exp);
		
		return exp;
	
	}
	
	//----------------------------------
	//  solveParen
	//----------------------------------
	/**
	 * @private 
	 * Solves an individual expression contained within parenthesis. 
	 * Used internaly by solveExpression().
	 * 
	 * @param: arguments is automatically passed from String.replace() function in solveExpression() method.
	 * @return A string that is numeric solution to the expression in parenthesis
	 *
	 * */
	private function solveParen() : String
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
	
	//----------------------------------
	//  solveFormula
	//----------------------------------
	/**
	 * @private
	 * Solves expression that contains a formula formula, i.e. SUM(a2:a5)
	 * 
	 * @param exp Expression that you want to solve
	 * @returns A string that is numeric solution to the expression
	 * 
	 * */
	private function solveFormula(exp : String) : String
	{
		var regex : RegExp = /[A-Za-z]*\(([^()]*)\)/g;
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
			
			var input : Array = exp.split(",");
			
			if (formula.toLowerCase() == FormulaLogic.IF)
			{
				if (input.length != 3)
				{
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
				if (input.length != 2)
				{
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
	
	//----------------------------------
	//  solveSimple
	//----------------------------------
	/**
	 * @private
	 * Solves simple expressions with one operator, one operand on the left, and one operand on the right.
	 * @return A numerical string that is a solution to passed expression.
	 * @param: arguments is automatically passed from String.replace() function in solveParen() method.
	 * */
	private function solveSimple() : String
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
	
	//----------------------------------
	//  getValueFromOperand
	//----------------------------------
	/**
	 * This method extracts the value from a Control specified as String.
	 * Calc uses this when solving expressions, if the expression is '=A1 + 5', it will attempt to find a ControlObject with the id="a1", and return its value.
	 * 
	 * @param operand String identifying the control (for example operand in the expression)
	 * @param emptyStringPolicy Can be "zero" or "nan", specifies what the function will return if the operand is not found. 
	 * @return A Number that is the value of the control specified. If not found and emptyStringPolicy=="nan", return value is NaN. If not found and emptyStringPolicy=="zero", return value is 0. 
	 *
	 * */
	public function getValueFromOperand(operand : String, emptyStringPolicy : String = "zero") : Number
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
				
			}
		}
		else
		{
			rn = Number(operand);
		}
		
		rn *= m;
		
		return rn;
	}
	
	//----------------------------------
	//  getCtrlById
	//----------------------------------
	/**
	 * Gets a ControlObject from a String.
	 * 
	 * @param ctrlId Id of a ControlObject you wish to get, e.g. "a1"
	 * @return Returns a ControlObject associated with the string provided
	 * */
	public function getCtrlById(ctrlId : String) : ControlObject
	{
		var ro : ControlObject;
		
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
	
	//----------------------------------
	//  getCtrl
	//----------------------------------
	/**
	 * Gets a ControlObject
	 * @param ctrl Specify either a String, ControlObject or UIComponent that you wish to resolve to a ControlObject 
	 * */
	public function getCtrl(ctrl : *) : ControlObject
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
	
	//----------------------------------
	//  updateDependent
	//----------------------------------
	/**
	 * @private
	 * Loops recursively through the dependent objects of objectChanged until all dependants are resolved.
	 * */
	private function updateDependent(objectChanged : ControlObject) : void
	{
		if (objectChanged.dependants.length > 0)
		{
			for each (var c : ControlObject in objectChanged.dependants)
			{
				if (c != _currentOriginator)
				{
					if (c.exp)
						assignControlExpression(c, c.exp, true);
				}
				else
				{
					var e : String = "Cyclic reference detected at: " + _currentOriginator.id + "<->" + objectChanged.id + ". Reset this field.";
					
					var errEvt : SpreadsheetEvent = new SpreadsheetEvent(SpreadsheetEvent.ERROR);
					errEvt.message = e;
					this.dispatchEvent(errEvt);
					
					_currentOriginator.ctrl[_currentOriginator.valueProp] = e;
					_currentOriginator.exp = null;
				}
			}
		}
	
	}
	
	//----------------------------------
	//  assignControlExpression
	//----------------------------------
	/**
	 * Assigns expressions to the objects registered with the Calc.
	 * @param Object that you want to assign expression to. You can use the ID:String of the object or a reference to the object typed as ControlObject
	 * @expression Expression to be assigned, e.g. "=5+5"
	 * @update Internal use, you don't ever need to specify this
	 * */
	public function assignControlExpression(ctrl : *, expression : String, update : Boolean = false) : void
	{
		var exp : String = expression;
		var co : ControlObject;
		
		currentTarget = null;
		
		co = getCtrl(ctrl);
		currentTarget = co;
		
		// remove this object as dependant from all of the operands
		if (!update)
		{
			_currentOriginator = co;
			
			for each (var op : ControlObject in co.ctrlOperands)
			{
				var ind : int = op.dependants.indexOf(co);
				
				if (ind >= 0)
					op.dependants.splice(ind, 1);
			}
			
			co.ctrlOperands = new Array();
			co.children = new Array();
		}
		
		var funcCalc : String;
		var _val : String;
		var coind : int;
		
		if (exp.substr(0, 1) == "=")
		{
			funcCalc = exp.substr(1);
			_val = solveExpression(funcCalc, false).toString();
			co.exp = "=" + _repairedExpression;
			_repairedExpression = null;
			
			coind = expressionTree.indexOf(co);
			
			if (!update && coind == -1)
			{
				expressionTree.push(co);
				
				if (co.grid)
				{
					coind = co.grid.expressionTree.indexOf(co);
					
					if (coind == -1)
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
				coind = expressionTree.indexOf(co);
				
				if (coind >= 0)
					expressionTree.splice(expressionTree.indexOf(co), 1);
				
				if (co.grid)
				{
					coind = co.grid.expressionTree.indexOf(co);
					
					if (coind >= 0)
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
				coind = expressionTree.indexOf(co);
				
				if (coind == -1)
					expressionTree.push(co);
				
				if (co.grid)
				{
					coind = co.grid.expressionTree.indexOf(co);
					
					if (coind == -1)
						co.grid.expressionTree.push(co);
				}
			}
		}
		
		// add this object as dependant to each operand
		if (!update)
		{
			for each (op in co.ctrlOperands)
			{
				op.dependants.push(co);
			}
		}
		
		co.ctrl[co.valueProp] = _val;
		
		if (!co.grid)
		{
			try
			{
				UIComponent(co.ctrl).toolTip = co.toolTipLabel;
			}
			catch (e : Error)
			{
			}
		}
		
		updateDependent(co);

		
		currentTarget = null;
	}
	
	//----------------------------------
	//  getDependantsOfCollection
	//----------------------------------
	/**
	 * Gets the dependants of a certain collection added through addCollection.
	 * Dependants are all the objects that use this collection in its expressions as operands.
	 * 
	 * @param collection Collection that we want to retreive the dependants for.
	 * 
	 * @return array of ControlObject references that are dependent on the collection specified.
	 * 
	 * */
	public function getDependantsOfCollection(collection : *) : Array
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
	
	//----------------------------------
	//  onCtrlChanged
	//----------------------------------
	/**
	 * This function gets executed when a control registered with addControl() changes its value.
	 * For example when the TextInput receives a new value.
	 * 
	 * @param Corresponding Event
	 * */
	protected function onCtrlChanged(evt : Event) : void
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
			_currentOriginator = co;
			updateDependent(co);
		}
	}
	
	//----------------------------------
	//  onCtrlFocus
	//----------------------------------
	/**
	 * This function gets executed when a control registered with addControl() receives focus. 
	 * For example TextInput is clicked on.
	 * 
	 * @param evt Corresponding Event.
	 * */
	protected function onCtrlFocus(evt : Event) : void
	{
		var co : ControlObject = getCtrlById(evt.currentTarget.id);
		
		if (co.ctrl is TextInput)
		{
			if (co.exp != null && co.exp != "")
				co.ctrl[co.valueProp] = co.exp;
		}
	}
	
	//----------------------------------
	//  onCollectionChange
	//----------------------------------
	/**
	 * This function gets executed when a collection added through Calc.addCollection gets changed.
	 * This is typically when value changes and this function requests recalculation of all the objects that use this value as its operand.
	 * 
	 * @param evt Corresponding CollectionEvent.
	 * */
	protected function onCollectionChange(evt : CollectionEvent) : void
	{
		var dependants : Array = getDependantsOfCollection(evt.target);
		
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
	
	//----------------------------------
	//  addTextInput
	//----------------------------------
	/**
	 * Adds TextInput control and registers it with the Calc.
	 * This is a shortcut method to addControl if you only want to add TextInput.
	 * @param textInput A TextInput control you want to register with Calc
	 * */
	public function addTextInput(textInput : TextInput) : void
	{
		addControl(textInput, "text", ["focusIn"], [FlexEvent.ENTER, "focusOut"]);
	}
	
	//----------------------------------
	//  addControl
	//----------------------------------
	/**
	 * Adds any Flex Control and registers it with the Calc. Calc then performs calculations and expressions
	 * assigned to this component through Calc.assignControlExpression() method.
	 * @param ctrl Flex Control you want to register with the Calc
	 * @param valuePro Property that holds a value for the control. It can be "value", "text", or any other you choose
	 * @param editStartEvents Specifies which events is Calc listening to, to display the expression instead of value in the editor. Used primarily with TextInput compnent where you would specify [FocusEvent.FOCUS_IN]
	 * @param editEndEvents Specifies which events are assigning are triggered when the ctrl's value has been modified. Example: [Event.CHANGE, FlexEvent.ENTER, FocusEvent.FOCUS_OUT]
	 * */
	public function addControl(ctrl : UIComponent, valueProp : String, editStartEvents : Array = null, editEndEvents : Array = null) : void
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
	
	//----------------------------------
	//  addObject
	//----------------------------------
	/**
	 * Registered any Object with the Calc and you can later use specified property on this Object as the operand in the expression.
	 * 
	 * @param id Id of the Object, you will use this id to access the Object in expressions
	 * @param object The reference to the actual Object you want to register
	 * @param valueProp Teh value property of the Object you want to use as the value
	 * 
	 * @example The following code adds ArrayCollection and uses it in expression:
	 *
	 * <listing version="3.0">
	 * 
	 * var calc:Calc = new Calc();
	 * var myCol:ArrayCollection = new ArrayCollection([{name:"Python", age:20}, {name:"Ruby", age:15}]);
	 * calc.addCollection("names", myCol);
	 * var ages:String = calc.solveExpression("names!age!0 + names!age!1);
	 * trace(ages); // output: 35
	 * 
	 * </listing>
	 * 
	 * */
	public function addObject(id : String, object : *, valueProp : String) : void
	{
		var ctrlObject : ControlObject = new ControlObject();
		ctrlObject.valueProp = valueProp;
		ctrlObject.ctrl = object;
		ctrlObject.exp = "";
		ctrlObject.id = id;
		_ctrlCollection[ctrlObject.id] = ctrlObject;
	}
	
	//----------------------------------
	//  addSpreadsheet
	//----------------------------------
	/**
	 * Registers an ISpreadsheet object with this Calc.
	 * <br/><br/> 
	 * <strong>NOTE:</strong> Spreadsheet, when you instanciate it, does not need to be added to separate Calc as it already has internal Calc object.
	 * @param sheet ISpreadsheet instance to be registered
	 * 
	 * 
	 * */	
	public function addSpreadsheet(sheet : ISpreadsheet) : void
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
	
	//----------------------------------
	//  addCollection
	//----------------------------------
	/**
	 * Calc currently supports ArrayCollection only. 
	 * By registering a collection with the Calc you can use it in the expressions.
	 * This is a feature not found in other standard Spreadsheet programs and is unique to AS.
	 * 
	 * @param id Id with which you want to identify this collection when used in expressions
	 * @param collection The actual collection you want to register with this Calc
	 * 
	 * @example The following code adds ArrayCollection and uses it in expression:
	 *
	 * <listing version="3.0">
	 * 
	 * var calc:Calc = new Calc();
	 * var myCol:ArrayCollection = new ArrayCollection([{name:"Python", age:20}, {name:"Ruby", age:15}]);
	 * calc.addCollection("names", myCol);
	 * var ages:String = calc.solveExpression("names!age!0 + names!age!1);
	 * trace(ages); // output: 35
	 * 
	 * </listing>
	 * 
	 *
	 * */
	public function addCollection(id : String, collection : *) : void
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
	
	
	//----------------------------------
	//  gridCollection
	//----------------------------------
	/**
	 * Returns the dictionary collection of all the ISpreadsheet objects registered with this Calc.
	 * */
	public function get gridCollection() : Object
	{
		return _gridCollection;
	}
	
	//----------------------------------
	//  ctrlCollection
	//----------------------------------
	/**
	 * Returns the dictionary collection of all the Objecs or Flex Controls registered with this Calc, excepts collections and ISpreadsheets.
	 * */
	public function get ctrlCollection() : Object
	{
		return _ctrlCollection;
	}
	
	//----------------------------------
	//  collections
	//----------------------------------
	/**
	 * Returns the dictionary collection of all the collections (ArrayCollection objects) registered with this Calc.
	 * */
	public function get collections() : Object
	{
		return _collections;
	}

}

}