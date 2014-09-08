package network.field{
	import tmbutil.TmbField;
	import network.component.HumanNodeBase;
	import network.component.GrabMask;
	import network.component.HistoryArrows;
	import flash.geom.Rectangle;
	import flash.display.Sprite;
	import flash.display.MovieClip;
	import tmbutil.TmbMovieClip;
	
    public class HistoryField extends TmbField{

		public var _isExtendOn:Boolean = false;
		public var _isCenterMoveOn:Boolean = false;
		private var _historyMax:Number = 0;
		
		private var _nodeArray:Array;
		private var _arrowArray:Array;
		
		///// コンストラクタ
        function HistoryField(){
		}
		
		public function create()
		{
			this._historyMax = Math.floor(root.loaderInfo.width / 75);
			this._nodeArray = new Array();
			this._arrowArray = new Array();
			//this.createGrabMask();
		}
		
		private function createGrabMask(){
			/*
			var w = root.loaderInfo.width;
			var h = 95;
			*/
			var w = 95;
			var h = root.loaderInfo.height;
			
			var square:Sprite = new Sprite();
			square.graphics.beginFill(0xFFFFFF);
			square.graphics.drawRect(0, 0, w, h);
			square.graphics.endFill();
			square.alpha = 1;
			square.graphics.beginFill(0xFF9900);
			square.graphics.drawRect(0, 0, w, h);
			square.graphics.endFill();
			square.alpha = 0.7;
			this.addChild(square);	
		}
			
		public function addHistory(obj:Object) {
			var hn:HumanNodeBase = new HumanNodeBase();
			this._nodeArray.push(hn);
			hn._obj = obj;
			this.addChild(hn);
			hn.create();
			hn.alpha = 1;
			hn._isHistory = true;
			hn.createName();
			hn.x = 45;
			hn.y = -160;
			hn._hn._hnback.alpha = 1;
			
			this.slideHistory();
		}
		
		private function slideHistory()
		{
			for (var i = 0; i < this._nodeArray.length; i++) {
				var hn = this._nodeArray[i];
				hn._step = 2;
				hn.moveMC(hn.x, hn.y + 101, null, null);
				//hn.y = hn.y + 100;
			}
			if(this._nodeArray.length > 7){
				var mc = this._nodeArray.shift();
				this.removeChild(mc);
			}
		}
		
		
		
		public function addHistory2(obj:Object) {
			// 矢印の追加
			if (this._nodeArray.length > 0 && this._arrowArray.length < this._historyMax - 1){
				var ha:HistoryArrows = new HistoryArrows();
				this._arrowArray.push(ha);
				this.addChild(ha);
				ha.x = this._arrowArray.length * 75 + 2;
				ha.y = 25;
			}
			
			var hn:HumanNodeBase = new HumanNodeBase();
			this._nodeArray.push(hn);
			hn._obj = obj;
			this.addChild(hn);
			hn.create();
			hn.alpha = 1;
			hn._isHistory = true;
			hn.createName();
			hn.x = this._nodeArray.length * 75 - 30;
			hn.y = 35;
			

			if (this._nodeArray.length > this._historyMax) this.slideHistory2();
		}
		
		private function slideHistory2()
		{
			for (var i = 0; i < this._nodeArray.length; i++) {
				var hn = this._nodeArray[i];
				//hn.moveMC(hn.x - 75, hn.y, null, null);
				hn.x = hn.x - 75;
			}
			var mc = this._nodeArray.shift();
			this.removeChild(mc);
		}
		
		public function mainOpen(hn:HumanNodeBase) 
		{
			var p = parent as MovieClip;
			p.historyRestart(hn);
		}
    }
}