package com.flextras.workbook
{
	import com.flextras.calc.Utils;
	
	import mx.containers.HBox;
	
	public class ColumnHeader extends HBox
	{
		private var columnCount:int;
		private var sheet:CalcSheet;
		public var items:Array;
		private var _columnWidths:Array;
		
		public function ColumnHeader(columnCount:int, sheet:CalcSheet)
		{
			super();
			this.columnCount = columnCount;
			this.sheet = sheet;
			init();
		}
		
		private function init():void
		{
			items = new Array();
			_columnWidths = new Array();
			this.setStyle("horizontalGap", 0);
			
			for(var i:int = 0; i < columnCount; i++)
			{
				var chi:ColumnHeaderItem = new ColumnHeaderItem();
				chi.id = "column" + i;
				chi.index = i;
				chi.label = com.flextras.calc.Utils.alphabet[i];
				chi.width = CalcSheet.DEF_COL_WIDTH;
				chi.height = CalcSheet.DEF_COLHEADER_HEIGHT;
				addChild(chi);
				items.push(chi);
				chi.validateNow();
				//trace("chi width: " + chi.width + " / " + sheet.grid.columns[0].width)
			}
			//this.validateNow();
		}
		
		public function setAllWidths(width:Number):void
		{
			for (var i:int = 0; i < sheet.grid.colCount; i++)
			{
				sheet.grid.setColumnWidthAt(i, width);	
			}
		}
		
		public function setColumnWidthAt(index:int, width:Number):void
		{
			sheet.grid.setColumnWidthAt(index, width);
			
			var c:Boolean;
			for each(var o:Object in _columnWidths)
			{
				if(o.i == index)
				{
					o.w = width;
					c = true;
					break;
				}
			}
			if(!c) _columnWidths.push( {i:index, w:width} );
		}
		
		public function setHeaderAndGridWidth(index:int, width:Number):void
		{
			setColumnWidthAt(index, width);
			getChildAt(index).width = width;
		}
		
		
		public function insertColumn(index:int):void
		{
			for (var i:int = 0; i < items.length; i++)
			{
				if (items[i].index >= index)
				{ 
					items[i].index ++;
					items[i].label = Utils.alphabet[items[i].index];
					items[i].id = "column" + items[i].index;				
				}	
			}
			
			var chi:ColumnHeaderItem = new ColumnHeaderItem();
			chi.id = "column" + index;
			chi.index = index;
			chi.label =  Utils.alphabet[index];
			chi.width = CalcSheet.DEF_COL_WIDTH;
			chi.height = CalcSheet.DEF_COLHEADER_HEIGHT;
			addChildAt(chi,index);
			items.push(chi);

		}
		
		public function deleteColumn(index:int):void
		{

			for each(var o:Object in _columnWidths)
			{
				if(o.i == index)
				{
					sheet.grid.setColumnWidthAt(o.i, CalcSheet.DEF_COL_WIDTH);
					getChildAt(o.i).width = CalcSheet.DEF_COL_WIDTH;
					_columnWidths.splice(_columnWidths.indexOf(o),1); 
					break;
				} 
			}
			
			for each(o in _columnWidths)
			{
				if(int(o.i) > index)
				{
					sheet.grid.setColumnWidthAt(o.i, CalcSheet.DEF_COL_WIDTH);
					getChildAt(o.i).width = CalcSheet.DEF_COL_WIDTH;
					o.i --;
					setHeaderAndGridWidth(o.i, o.w)
				} 
			}
			
		}
		
		public function get columnsInfo():Object
		{
			return _columnWidths;	
		}

	}
}