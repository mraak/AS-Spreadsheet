package com.flextras.spreadsheet
{
	import com.flextras.calc.Calc;
	import com.flextras.calc.ControlObject;
	import com.flextras.calc.Utils;
	
	import mx.collections.ArrayCollection;
	import mx.controls.DataGrid;
	import mx.controls.dataGridClasses.DataGridColumn;
	import mx.core.ClassFactory;

	public class Spreadsheet1 extends DataGrid implements ISpreadsheet
	{
		
		private var _calc:Calc;
		private var _dataProvider:Object;
		private var _rowCount:int = 15;
		private var _columnCount:int = 10;
		private var _ctrlObjects:Object;
		private var _gridDataProvider:ArrayCollection;
		private var _expressionTree:Array = new Array();
		private var _renderers:Object = new Object();
		private var dataProviderChanged:Boolean;
		
		public function Spreadsheet1()
		{
			super();
			init();
		}
		
		protected function init():void
		{
			//this.allowMultipleSelection = true;
			
			this.editable = true;
			this.sortableColumns = false;
			this.draggableColumns = false;
			/**/
			//this.itemRenderer = new ClassFactory(SpreadsheetItemRenderer);

			
			_ctrlObjects = new Object();
			_gridDataProvider = new ArrayCollection();
			
			
		
		}
		
		
		
		override protected function commitProperties() : void
		{
			super.commitProperties();
			if(!_calc)
			{
				calc = new Calc();
			}
			
			
			if(this.dataProviderChanged)
			{
				for each(var dpo:Object in _dataProvider)
				{
					//calc.assignControlExpression(dpo.cell, dpo.expression);
				}
			}
			
		}
		
		override protected function createChildren() : void
		{
			super.createChildren();
			build();
		}
		
		
		override protected function measure() : void
		{
			super.measure();
			
			//this.measuredHeight = _rowCount * (this.rowHeight + 0.5);
			//this.measuredMinHeight =  _rowCount * (this.rowHeight + 0.5);
			
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number) : void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			//this.setActualSize(unscaledWidth, this.measuredHeight);
			
			//this.height = this.measuredHeight;
		}
		
		protected function build():void
		{
			var dataSource:Array = new Array();
			var c:int = _columnCount;
			var r:int = this.rowCount == -1 ? _rowCount : this.rowCount;

			for (var i:int = 0; i < r; i++)
			{
				var rowObject:Object = new Object();
				
				for (var j:int = 0; j < c; j++)
				{
					var prop:String = String(Utils.alphabet[j]).toLowerCase();
					rowObject[prop] = i.toString();
					
					var co:ControlObject = new ControlObject();
					co.id = prop + i;
					co.exp = "";
					co.ctrl = rowObject;
					co.valueProp = prop;
					co.row = i.toString();
					co.rowIndex = i;	
					co.col = prop;
					co.colIndex = j;	
					co.grid = this;	
					
					_ctrlObjects[co.id] = co;	
				}
				dataSource.push(rowObject);
			}
			
			_gridDataProvider = new ArrayCollection(dataSource);
			
			var cols:Array = new Array();
			
			for (j = 0; j < c; j++)
			{
				var dc:DataGridColumn = new DataGridColumn(Utils.alphabet[j]);
				dc.headerText = Utils.alphabet[j];
				dc.dataField = String(Utils.alphabet[j]).toLowerCase();
				dc.itemEditor = new ClassFactory(SpreadsheetItemEditor);
				dc.editorDataField = "actualValue" ;
				cols.push(dc);
			}
			
			this.columns = cols;
			
			
			//this.addEventListener(DataGridEvent.ITEM_FOCUS_IN, onItemFocusIn);
			//this.addEventListener(MouseEvent.DOUBLE_CLICK, onDblClick);
			//this.addEventListener(DataGridEvent.ITEM_FOCUS_OUT, onItemFocusOut);
			//this.addEventListener(DataGridEvent.ITEM_EDIT_BEGIN, onEditBegin);
			//this.addEventListener(DataGridEvent.ITEM_EDIT_BEGINNING, onEditBegin);
			//this.addEventListener(DataGridEvent.ITEM_EDIT_END, onEditEnd);
			
			super.dataProvider = _gridDataProvider;

		}
		
		public function assignExpression(cellId:String, expression:String):void
		{
			
		}
		
		//------------------------------
		// GETTERS / SETTERS
		//------------------------------
		
		override public function set dataProvider(value:Object) : void
		{
			dataProviderChanged = true;
			_dataProvider = value;
			this.invalidateProperties();
		}
		
		override public function get dataProvider() : Object
		{
			return _dataProvider;
		}
		
		
		override public function set rowCount(value:int) : void
		{
			_rowCount = value;
			//super.rowCount = value;
		}
		
		override public function get rowCount() : int
		{
			return _rowCount;	
		}
		/**/
		
		public function set colCount(count:int):void
		{
			this.columnCount = count;
			_columnCount = count;
		}
		
		public function get colCount():int
		{
			return this.columnCount;	
		}
		
		/*
		override public function set columnCount(value:int):void
		{
			_columnCount = value;
			//super.columnCount = value;
			
		}
		
		override public function get columnCount():int
		{
			return _columnCount;
		}
		*/
		
		public function set calc(value:Calc):void
		{
			_calc = value;
			_calc.addSpreadsheet(this);
		}
		
		public function get calc():Calc
		{
			return _calc;
		}
		

		
		/*
		public function set ctrlObjects(value:Object):void
		{
		_ctrlObjects = value;
		}
		*/		
		public function get ctrlObjects():Object
		{
			return _ctrlObjects;
		}
		
		public function get gridDataProvider():ArrayCollection
		{
			return _gridDataProvider;
		}
		
		public function get expressionTree():Array
		{
			return _expressionTree;
		}
		
		public function get renderers():Object
		{
			return _renderers;
		}
			
		
	}
}