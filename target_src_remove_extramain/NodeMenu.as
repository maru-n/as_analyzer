package network.component{
	import flash.display.MovieClip;
	import flash.events.Event;	
	import flash.events.MouseEvent;
	import tmbutil.TmbMovieClip;

    public class NodeMenu extends TmbMovieClip{
		
		///// ムービークリップ関連
		public var _isOnMouse:Boolean = false;
		///// コンストラクタ
        function NodeMenu(){
			this.create();
		}
		
		
		public function create()
		{
			trace("nodeMenu");
			this.addEventListener(MouseEvent.ROLL_OVER, mouseRollOverAction);
			this.addEventListener(MouseEvent.ROLL_OUT, mouseRollOutAction);
		}
		
		private function mouseRollOverAction(event:MouseEvent) {
			trace("RollOver");
			this._isOnMouse = true;
		}
		
		private function mouseRollOutAction(event:MouseEvent) {
			this._isOnMouse = false;
			this.deleteNodeMenu();
			
		}
		
		public function deleteNodeMenu()
		{
			var p = parent as MovieClip;
			trace(this._isOnMouse  + ":" + p._isOnMouse);
			if (!this._isOnMouse && !p._isOnMouse) {
				p.deleteNodeMenu();
			}
		}
		
		public function gotoCenter()
		{
			var p = parent as TmbMovieClip;
			p.gotoCenter();
		}
		
		public function gotoInfo()
		{
			var p = parent as TmbMovieClip;
			p.gotoInfo();
		}
	}
}