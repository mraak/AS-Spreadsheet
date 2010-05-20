package com.flextras.spreadsheet
{
import flash.events.Event;

// need to expand on what this stuff means 
//  * - ERROR: In this case, something has happened that will stop the correct execution
// * of the requested procedure.
// 	* - WARNING: Something has happened that will result in some loss of data but the procedure will run
// * normally.
/**
 * The SpreadSheetEvent class defines events dispatched the Flextras Spreadsheet.  
 * 
 * @see com.flextras.spreadsheet.Spreadsheet
 * 
 *
 */
public class SpreadsheetEvent extends Event
{

	
	/**
	 *  The SpreadsheetEvent.ERROR constant defines the value of the 
	 *  <code>type</code> property of the SpreadsheetEvent object for a
	 *  <code>error</code> event.   
	 *
	 *  <p>The properties of the event object have the following values:</p>
	 * 
	 *  <table class="innertable">
	 *     <tr><th>Property</th><th>Value</th></tr>
	 *     <tr><td><code>bubbles</code></td><td>false</td></tr>
	 *     <tr><td><code>cancelable</code></td><td>false</td></tr>
	 *     <tr><td><code>currentTarget</code></td><td>The Object that defines the 
	 *       event listener that handles the event. For example, if you use 
	 *       <code>myButton.addEventListener()</code> to register an event listener, 
	 *       myButton is the value of the <code>currentTarget</code>. </td></tr>
	 *     <tr><td><code>data</code></td><td></td></tr>
	 *     <tr><td><code>message</code></td><td></td></tr>
	 *     <tr><td><code>target</code></td><td>The Object that dispatched the event; 
	 *       it is not always the Object listening for the event. 
	 *       Use the <code>currentTarget</code> property to always access the 
	 *       Object listening for the event.</td></tr>
	 *     <tr><td><code>Type</code></td><td>SpreadsheetEvent.ERROR</td></tr>
	 *  </table>
	 *
	 *  @eventType error
	 */
	public static const ERROR : String = "error";
	
	/**
	 *  The SpreadsheetEvent.WARNING constant defines the value of the 
	 *  <code>type</code> property of the SpreadsheetEvent object for a
	 *  <code>warning</code> event.
	 *
	 *  <p>The properties of the event object have the following values:</p>
	 * 
	 *  <table class="innertable">
	 *     <tr><th>Property</th><th>Value</th></tr>
	 *     <tr><td><code>bubbles</code></td><td>false</td></tr>
	 *     <tr><td><code>cancelable</code></td><td>false</td></tr>
	 *     <tr><td><code>currentTarget</code></td><td>The Object that defines the 
	 *       event listener that handles the event. For example, if you use 
	 *       <code>myButton.addEventListener()</code> to register an event listener, 
	 *       myButton is the value of the <code>currentTarget</code>. </td></tr>
	 *     <tr><td><code>data</code></td><td></td></tr>
	 *     <tr><td><code>message</code></td><td></td></tr>
	 *     <tr><td><code>target</code></td><td>The Object that dispatched the event; 
	 *       it is not always the Object listening for the event. 
	 *       Use the <code>currentTarget</code> property to always access the 
	 *       Object listening for the event.</td></tr>
	 *     <tr><td><code>Type</code></td><td>SpreadsheetEvent.WARNING</td></tr>
	 *  </table>
	 *
	 *  @eventType warning
	 */
	public static const WARNING : String = "warning";
	
	/**
	 *  The SpreadsheetEvent.EXPRESSIONS_INITIALIZED constant defines the value of the 
	 *  <code>type</code> property of the SpreadsheetEvent object for a
	 *  <code>expressionsInitialized</code> event.
	 *
	 *  <p>The properties of the event object have the following values:</p>
	 * 
	 *  <table class="innertable">
	 *     <tr><th>Property</th><th>Value</th></tr>
	 *     <tr><td><code>bubbles</code></td><td>false</td></tr>
	 *     <tr><td><code>cancelable</code></td><td>false</td></tr>
	 *     <tr><td><code>currentTarget</code></td><td>The Object that defines the 
	 *       event listener that handles the event. For example, if you use 
	 *       <code>myButton.addEventListener()</code> to register an event listener, 
	 *       myButton is the value of the <code>currentTarget</code>. </td></tr>
	 *     <tr><td><code>data</code></td><td></td></tr>
	 *     <tr><td><code>message</code></td><td></td></tr>
	 *     <tr><td><code>target</code></td><td>The Object that dispatched the event; 
	 *       it is not always the Object listening for the event. 
	 *       Use the <code>currentTarget</code> property to always access the 
	 *       Object listening for the event.</td></tr>
	 *     <tr><td><code>Type</code></td><td>SpreadsheetEvent.EXPRESSIONS_INITIALIZED</td></tr>
	 *  </table>
	 *
	 *  @eventType expressionsInitialized
	 */
	public static const EXPRESSIONS_INITIALIZED : String = "expressionsInitialized";
	
	/**
	 *  The SpreadsheetEvent.CELL_CLICK constant defines the value of the 
	 *  <code>type</code> property of the SpreadsheetEvent object for a
	 *  <code>cellClick</code> event.
	 *
	 *  <p>The properties of the event object have the following values:</p>
	 * 
	 *  <table class="innertable">
	 *     <tr><th>Property</th><th>Value</th></tr>
	 *     <tr><td><code>bubbles</code></td><td>false</td></tr>
	 *     <tr><td><code>cancelable</code></td><td>false</td></tr>
	 *     <tr><td><code>currentTarget</code></td><td>The Object that defines the 
	 *       event listener that handles the event. For example, if you use 
	 *       <code>myButton.addEventListener()</code> to register an event listener, 
	 *       myButton is the value of the <code>currentTarget</code>. </td></tr>
	 *     <tr><td><code>data</code></td><td></td></tr>
	 *     <tr><td><code>message</code></td><td></td></tr>
	 *     <tr><td><code>target</code></td><td>The Object that dispatched the event; 
	 *       it is not always the Object listening for the event. 
	 *       Use the <code>currentTarget</code> property to always access the 
	 *       Object listening for the event.</td></tr>
	 *     <tr><td><code>Type</code></td><td>SpreadsheetEvent.CELL_CLICK</td></tr>
	 *  </table>
	 *
	 *  @eventType cellClick
	 */
	public static const CELL_CLICK : String = "cellClick";
	
	/**
	 *  The SpreadsheetEvent.CELL_DOUBLE_CLICK constant defines the value of the 
	 *  <code>type</code> property of the SpreadsheetEvent object for a
	 *  <code>cellDoubleClick</code> event.
	 *
	 *  <p>The properties of the event object have the following values:</p>
	 * 
	 *  <table class="innertable">
	 *     <tr><th>Property</th><th>Value</th></tr>
	 *     <tr><td><code>bubbles</code></td><td>false</td></tr>
	 *     <tr><td><code>cancelable</code></td><td>false</td></tr>
	 *     <tr><td><code>currentTarget</code></td><td>The Object that defines the 
	 *       event listener that handles the event. For example, if you use 
	 *       <code>myButton.addEventListener()</code> to register an event listener, 
	 *       myButton is the value of the <code>currentTarget</code>. </td></tr>
	 *     <tr><td><code>data</code></td><td></td></tr>
	 *     <tr><td><code>message</code></td><td></td></tr>
	 *     <tr><td><code>target</code></td><td>The Object that dispatched the event; 
	 *       it is not always the Object listening for the event. 
	 *       Use the <code>currentTarget</code> property to always access the 
	 *       Object listening for the event.</td></tr>
	 *     <tr><td><code>Type</code></td><td>SpreadsheetEvent.CELL_DOUBLE_CLICK</td></tr>
	 *  </table>
	 *
	 *  @eventType cellDoubleClick
	 */
	public static const CELL_DOUBLE_CLICK : String = "cellDoubleClick";
	
	/**
	 *  The SpreadsheetEvent.CELL_ROLL_OVER constant defines the value of the 
	 *  <code>type</code> property of the SpreadsheetEvent object for a
	 *  <code>cellRollOver</code> event.
	 *
	 *  <p>The properties of the event object have the following values:</p>
	 * 
	 *  <table class="innertable">
	 *     <tr><th>Property</th><th>Value</th></tr>
	 *     <tr><td><code>bubbles</code></td><td>false</td></tr>
	 *     <tr><td><code>cancelable</code></td><td>false</td></tr>
	 *     <tr><td><code>currentTarget</code></td><td>The Object that defines the 
	 *       event listener that handles the event. For example, if you use 
	 *       <code>myButton.addEventListener()</code> to register an event listener, 
	 *       myButton is the value of the <code>currentTarget</code>. </td></tr>
	 *     <tr><td><code>data</code></td><td></td></tr>
	 *     <tr><td><code>message</code></td><td></td></tr>
	 *     <tr><td><code>target</code></td><td>The Object that dispatched the event; 
	 *       it is not always the Object listening for the event. 
	 *       Use the <code>currentTarget</code> property to always access the 
	 *       Object listening for the event.</td></tr>
	 *     <tr><td><code>Type</code></td><td>SpreadsheetEvent.CELL_ROLL_OVER</td></tr>
	 *  </table>
	 *
	 *  @eventType cellRollOver
	 */
	public static const CELL_ROLL_OVER : String = "cellRollOver";
	
	/**
	 *  The SpreadsheetEvent.CELL_ROLL_OUT constant defines the value of the 
	 *  <code>type</code> property of the SpreadsheetEvent object for a
	 *  <code>cellRollOut</code> event.
	 *
	 *  <p>The properties of the event object have the following values:</p>
	 * 
	 *  <table class="innertable">
	 *     <tr><th>Property</th><th>Value</th></tr>
	 *     <tr><td><code>bubbles</code></td><td>false</td></tr>
	 *     <tr><td><code>cancelable</code></td><td>false</td></tr>
	 *     <tr><td><code>currentTarget</code></td><td>The Object that defines the 
	 *       event listener that handles the event. For example, if you use 
	 *       <code>myButton.addEventListener()</code> to register an event listener, 
	 *       myButton is the value of the <code>currentTarget</code>. </td></tr>
	 *     <tr><td><code>data</code></td><td></td></tr>
	 *     <tr><td><code>message</code></td><td></td></tr>
	 *     <tr><td><code>target</code></td><td>The Object that dispatched the event; 
	 *       it is not always the Object listening for the event. 
	 *       Use the <code>currentTarget</code> property to always access the 
	 *       Object listening for the event.</td></tr>
	 *     <tr><td><code>Type</code></td><td>SpreadsheetEvent.CELL_ROLL_OUT</td></tr>
	 *  </table>
	 *
	 *  @eventType cellRollOut
	 */
	public static const CELL_ROLL_OUT : String = "cellRollOut";
	
	/**
	 *  The SpreadsheetEvent.CELL_REGISTER constant defines the value of the 
	 *  <code>type</code> property of the SpreadsheetEvent object for a
	 *  <code>cellRegister</code> event.
	 *
	 *  <p>The properties of the event object have the following values:</p>
	 * 
	 *  <table class="innertable">
	 *     <tr><th>Property</th><th>Value</th></tr>
	 *     <tr><td><code>bubbles</code></td><td>false</td></tr>
	 *     <tr><td><code>cancelable</code></td><td>false</td></tr>
	 *     <tr><td><code>currentTarget</code></td><td>The Object that defines the 
	 *       event listener that handles the event. For example, if you use 
	 *       <code>myButton.addEventListener()</code> to register an event listener, 
	 *       myButton is the value of the <code>currentTarget</code>. </td></tr>
	 *     <tr><td><code>data</code></td><td></td></tr>
	 *     <tr><td><code>message</code></td><td></td></tr>
	 *     <tr><td><code>target</code></td><td>The Object that dispatched the event; 
	 *       it is not always the Object listening for the event. 
	 *       Use the <code>currentTarget</code> property to always access the 
	 *       Object listening for the event.</td></tr>
	 *     <tr><td><code>Type</code></td><td>SpreadsheetEvent.CELL_REGISTER</td></tr>
	 *  </table>
	 *
	 *  @eventType cellRegister
	 */
	public static const CELL_REGISTER : String = "cellRegister";
	
	/**
	 * 
	 */
	public var message : String;
	
	/**
	 * 
	 */
	public var data : *;
	
	/**
	 * constructor
	 */
	public function SpreadsheetEvent (type : String, bubbles : Boolean = false, cancelable : Boolean = false)
	{
		super(type, bubbles, cancelable);
	}
	
	override public function clone () : Event
	{
		var e : SpreadsheetEvent = new SpreadsheetEvent(type, bubbles, cancelable);
		e.message = message;
		e.data = data;
		
		return e;
	}
}
}