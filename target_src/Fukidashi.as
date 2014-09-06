package network.component {

	import flash.display.MovieClip;
	import flash.utils.getTimer;
	import flash.events.Event;
	
	public class Fukidashi extends MovieClip{
	
		private var _type:String;
		public var _edge_keyword:String;
		private var _kwds:Array;
		public function Fukidashi()
		{
		}
	
		public function create()
		{
			this._kwds = this._edge_keyword.split(",");
			this.addEventListener( Event.ENTER_FRAME, keywordProcess);
		}
		
		private function keywordProcess(e:Event)
		{
			var c:Number = getTimer();
			var mode:int = Math.ceil(c / 1000) % this._kwds.length;
			this._keyword.text = this._kwds[mode];
		}
	}
}