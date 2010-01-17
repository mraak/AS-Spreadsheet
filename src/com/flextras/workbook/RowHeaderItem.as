package com.flextras.workbook
{
	import flash.events.MouseEvent;
	
	import mx.controls.Button;
	import com.flextras.workbook.RowHeader;

	public class RowHeaderItem extends Button
	{
		private var divide:Number;
		private var dragable:Boolean;
		private var dragging:Boolean;
		public var index:int;
		
		public function RowHeaderItem()
		{
			super();
			init();
		}
		
		private function init():void
		{
			//validateNow();
			divide = 4;
			callLater(configListeners);

		}
		
		private function configListeners():void
		{
			this.stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandlerer);
			this.owner.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandlerer);
			this.stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandlerer);			
		}
		
		private function mouseMoveHandlerer(evt:MouseEvent):void
		{
			//trace("yooo " + this.mouseY + " | " + (this.height - 3) + " | " + dragging);
			if(this.mouseY > (this.height - divide) && this.mouseY < (this.height + divide + 2))
			{
				showResizeCursor(true);
				dragable = true;
			}
			else
			{
				showResizeCursor(false);
				dragable = false;
			}
			
			if(dragging)
			{
				this.height = this.mouseY;
				RowHeader(this.owner).setRowHeightAt(index, (this.height-4));
			}
		}
		
		private function mouseDownHandlerer(evt:MouseEvent):void
		{
			if(dragable) dragging = true;	
		}
		
		private function mouseUpHandlerer(evt:MouseEvent):void
		{
			dragging = false;	
		}
		
		private function showResizeCursor(show:Boolean):void
		{
			
		}
	}
}