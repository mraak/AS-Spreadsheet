
package com.flextras.spreadsheet.events
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
	
	public static const EXPRESSIONS_CHANGE : String = "expressionsChange";
	
	public static const EXPRESSIONS_CHANGED : String = "expressionsChanged";
	
	public static const EXPRESSIONS_CLEARED : String = "expressionsCleared";
	
	/**
	 * Message contains actual warning or error message.
	 */
	public var message : String;
	
	/**
	 * Constructor.
	 */
	public function SpreadsheetEvent (type : String, bubbles : Boolean = false, cancelable : Boolean = false)
	{
		super (type, bubbles, cancelable);
	}
	
	/**
	 * @private
	 */
	override public function clone () : Event
	{
		var e : SpreadsheetEvent = new SpreadsheetEvent (type, bubbles, cancelable);
		e.message = message;
		
		return e;
	}
}
}