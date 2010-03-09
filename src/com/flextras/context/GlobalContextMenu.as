package com.flextras.context
{
import com.flextras.paintgrid.PaintGrid2;

import flash.events.ContextMenuEvent;

public class GlobalContextMenu extends Menu
{
	public function GlobalContextMenu (owner : PaintGrid2 = null)
	{
		super(owner);
		
		addItem("Set global styles", setGlobalStylesHandler);
	}
	
	protected function setGlobalStylesHandler (e : ContextMenuEvent) : void
	{
		trace(e);
	}
}
}