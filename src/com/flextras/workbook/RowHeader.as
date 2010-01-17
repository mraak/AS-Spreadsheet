package com.flextras.workbook
{
	import mx.containers.VBox;
	import com.flextras.workbook.RowHeaderItem;
	
	public class RowHeader extends VBox
	{
		private var rowCount:int;
		private var sheet:CalcSheet;
		public var items:Array;
		private var _rowHeights:Array;
		
		public function RowHeader(rowCount:int, sheet:CalcSheet)
		{
			super();
			this.rowCount = rowCount;
			this.sheet = sheet;
			init();
		}
		
		private function init():void
		{
			items = new Array();
			_rowHeights = new Array();
			this.setStyle("verticalGap", 0);
			
			for(var i:int = 0; i < rowCount; i++)
			{
				var rhi:RowHeaderItem = new RowHeaderItem();
				rhi.id = "row" + i;
				rhi.index = i;
				rhi.label = i.toString();
				rhi.width = CalcSheet.DEF_ROWHEADER_WIDTH;
				rhi.height = CalcSheet.DEF_ROWHEADER_HEIGHT;
				addChild(rhi);
				items.push(rhi);
				//rhi.validateNow()
			}
			//this.validateNow();
		}
		
		public function setAllHeights(height:Number):void
		{
			for (var i:int = 0; i < sheet.grid.rowCount; i++)
			{
				sheet.grid.setRowHeightAt(i, height);	
			}
		}
		
		public function setRowHeightAt(index:int, height:Number):void
		{
			sheet.grid.setRowHeightAt(index, height);
			
			var c:Boolean;
			for each(var o:Object in _rowHeights)
			{
				if(o.i == index)
				{
					o.h = height;
					c = true;
					break;
				}
			}
			if(!c) _rowHeights.push( {i:index, h:height} );
			
		}
		
		public function setHeaderAndGridHeight(index:int, height:Number):void
		{
			setRowHeightAt(index, height);
			getChildAt(index).height = height + 4;
		}
		
		public function insertRow(index:int):void
		{
			for (var i:int = 0; i < items.length; i++)
			{
				if (items[i].index >= index)
				{ 
					delete _rowHeights["row"+i];
					items[i].index ++;
					items[i].label = items[i].index.toString();
					items[i].id = "row" + items[i].index;				
				}	
			}
			
			for each(var o:Object in _rowHeights)
			{
				if(o.i >= index)
				{
					o.i ++;
				}
			}
			
			var rhi:RowHeaderItem = new RowHeaderItem();
			rhi.id = "row" + index;
			rhi.index = index;
			rhi.label = index.toString();
			rhi.width = CalcSheet.DEF_ROWHEADER_WIDTH;
			rhi.height = CalcSheet.DEF_ROWHEADER_HEIGHT;
			addChildAt(rhi,index);
			items.push(rhi);

		}
		
		public function deleteRow(index:int):void
		{	
			for each(var o:Object in _rowHeights)
			{
				if(o.i == index)
				{
					sheet.grid.setRowHeightAt(o.i, CalcSheet.DEF_ROW_HEIGHT);
					getChildAt(o.i).height = CalcSheet.DEF_ROWHEADER_HEIGHT;
					_rowHeights.splice(_rowHeights.indexOf(o),1); 
					break;
				} 
			}
			
			for each(o in _rowHeights)
			{
				if(int(o.i) > index)
				{
					sheet.grid.setRowHeightAt(o.i, CalcSheet.DEF_ROW_HEIGHT);
					getChildAt(o.i).height = CalcSheet.DEF_ROWHEADER_HEIGHT;
					o.i --;
					setHeaderAndGridHeight(o.i, o.h)
				} 
			}
		}
		
		public function get rowsInfo():Object
		{
			return _rowHeights;	
		}
	}
}