package com.flextras.context
{
import com.flextras.paintgrid.PaintGrid2;

import flash.events.Event;

import mx.containers.TitleWindow;
import mx.events.CloseEvent;
import mx.managers.PopUpManager;

public class BasePopup extends TitleWindow
{
	protected var _grid : PaintGrid2;
	
	[Bindable]
	public function get grid () : PaintGrid2
	{
		return _grid;
	}
	
	public function set grid (value : PaintGrid2) : void
	{
		if (_grid === value)
			return;
		
		if (_grid)
			_grid.removeEventListener("selectedCellsChanged", selectedCellsChangedHandler);
		
		_grid = value;
		
		if (value)
			value.addEventListener("selectedCellsChanged", selectedCellsChangedHandler);
	}
	
	public function BasePopup ()
	{
		super();
		
		showCloseButton = true;
		addEventListener(CloseEvent.CLOSE, closeHandler);
	}
	
	protected function closeHandler (e : CloseEvent) : void
	{
		PopUpManager.removePopUp(this);
	}
	
	protected function selectedCellsChangedHandler (e : Event) : void
	{
	
	}
}
}