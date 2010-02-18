package com.flextras.spreadsheet
{
import com.flextras.calc.Utils;
import com.flextras.paintgrid.PaintGridColumnItemRenderer;

import flash.events.Event;
import flash.events.MouseEvent;

import mx.binding.utils.BindingUtils;
import mx.controls.dataGridClasses.DataGridListData;
import mx.core.IDataRenderer;

[Event(name="cellClick", type="com.flextras.spreadsheet.SpreadsheetEvent")]
[Event(name="cellDoubleClick", type="com.flextras.spreadsheet.SpreadsheetEvent")]

public class SpreadsheetItemRendererBase extends PaintGridColumnItemRenderer /*Text*/implements IDataRenderer
{
	
	private var _rowIndex : int;
	
	private var _columnIndex : int;
	
	private var _cellId : String;
	
	public function SpreadsheetItemRendererBase ()
	{
		super();
		init();
	}
	
	private function init () : void
	{
		this.height = 18;
		this.doubleClickEnabled = true;
		this.addEventListener("dataChange", dataChangeHandler);
		this.addEventListener(MouseEvent.CLICK, clickHandler);
		this.addEventListener(MouseEvent.DOUBLE_CLICK, dblClickHandler)
	
	}
	
	protected function dataChangeHandler (evt : Event) : void
	{
		this.owner.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
		this.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
		this.owner.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
		
		var myListData : DataGridListData = DataGridListData(listData);
		
		//_rowIndex = myListData.rowIndex;
		_rowIndex = data.rowIndex;
		_columnIndex = myListData.columnIndex;
		_cellId = String(Utils.alphabet[_columnIndex]).toLowerCase() + _rowIndex;
		
		//this.text =_cellId + " h: " + data.rowHeight;
		
		//BindingUtils.bindSetter(setHeight, data, "rowHeight");
	
	}
	
	protected function mouseMoveHandler (e : MouseEvent) : void
	{
	
	}
	
	protected function mouseDownHandler (e : MouseEvent) : void
	{
	
	}
	
	protected function mouseUpHandler (e : MouseEvent) : void
	{
	
	}
	
	protected function clickHandler (evt : MouseEvent) : void
	{
	/*	var cevt : SpreadsheetEvent = new SpreadsheetEvent(SpreadsheetEvent.CELL_CLICK, true);
		this.dispatchEvent(cevt);*/
	}
	
	protected function dblClickHandler (evt : MouseEvent) : void
	{
	/*	var cevt : SpreadsheetEvent = new SpreadsheetEvent(SpreadsheetEvent.CELL_DOUBLE_CLICK, true);
		cevt.data = evt;
		this.dispatchEvent(cevt);*/
	}
	
/*	private function setHeight (value : Object) : void
	{
		this.height = value as Number;
	}*/
	
	//////////////////////////////////////////////
	//  GETTERS && SETTERS
	//////////////////////////////////////////////
	
	public function get rowIndex () : int
	{
		return _rowIndex;
	}
	
	public function get columnIndex () : int
	{
		return _columnIndex;
	}
	
	public function get cellId () : String
	{
		return _cellId;
	}

}
}