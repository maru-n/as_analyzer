package network.component{
	import flash.display.MovieClip;
	import flash.display.DisplayObject;
	import flash.ui.Mouse;
	
	import tmbutil.TmbMovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import flash.utils.escapeMultiByte;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
    public class ClickMask extends TmbMovieClip{
	
		private var _isDrag:Boolean = false;
		private var _parent:MovieClip;
		private var _sx:Number;
		private var _sy:Number;
		private var _px:Number;
		private var _py:Number;
		private var _sw:Number;
		private var _sh:Number;
		
		public var _hid;
		public var _name;
		
		///// コンストラクタ
        function GrabMask(){
		}
		
		public function create()
		{
			//this._name_space.text = this._name + "さんの相関図";
			this._name_space.text = "";
			this.buttonMode = true;
			this._parent = parent as MovieClip;
			this.createListener();
			this._sw = root.loaderInfo.width;
			this._sh = root.loaderInfo.height;
		}
		
		private function createListener()
		{
			//this.buttonMode = false;

			trace("hoge");
			this.addEventListener(MouseEvent.CLICK, clickAction);
			//this.addEventListener(MouseEvent.MOUSE_DOWN, dragAction);
			//this.addEventListener(MouseEvent.MOUSE_UP, mouseUpAction);
			//this.addEventListener(MouseEvent.MOUSE_OVER, mouseOverAction);
			//this.addEventListener(MouseEvent.MOUSE_OUT, mouseOutAction);
		}
		
		private function clickAction(event:MouseEvent) {
			var name:String = escapeMultiByte(this._name);
			//var r = Math.random();
			//var patturn = "a";
			//if (r > 0.5) patturn = "b";
			//var url:URLRequest = new URLRequest( "/" + name + "/" + this._hid + "/network/" + patturn + "/");
			var url:URLRequest = new URLRequest( "/" + name + "/" + this._hid + "/network/");
			navigateToURL( url , "_parent");	
		}
		
		private function mouseOverAction(event:MouseEvent) {
			this.gotoAndPlay("color");
		}
		
		private function mouseOutAction(event:MouseEvent) {
			this.gotoAndPlay("normal");
		}
		
		private function dragAction(event:MouseEvent){
			this._isDrag = true;
			this._sx = stage.mouseX;
			this._sy = stage.mouseY;
			this._px = _parent.x;
			this._py = _parent.y;
			this.addEventListener(MouseEvent.MOUSE_MOVE, moveAction);
			stage.addEventListener(MouseEvent.MOUSE_UP, releaseOutsideAction);
			stage.addEventListener(MouseEvent.MOUSE_OUT, releaseOutsideAction);
		}

		private function moveAction(event:MouseEvent){
			if(!this._isDrag){
				this.removeEventListener(MouseEvent.MOUSE_MOVE, moveAction);
			}
			var cx:Number = stage.mouseX - this._sx + this._px;
			var cy:Number = stage.mouseY - this._sy + this._py;
			if(cx >= this._sw) cx = this._sw;
			if(cy >= this._sh) cy = this._sh;
			if(cx <= -this._sw) cx = -this._sw;
			if(cy <= -this._sh) cy = -this._sh;
			_parent.x = cx;
			_parent.y = cy;
			
			
		}
		
		private function releaseOutsideAction(event:MouseEvent){
			stage.removeEventListener(MouseEvent.MOUSE_UP, releaseOutsideAction);
			stage.removeEventListener(MouseEvent.MOUSE_OUT, releaseOutsideAction);
			this.removeEventListener(MouseEvent.MOUSE_MOVE, moveAction);
			this.releaseAction();
		}
		
		private function mouseUpAction(event:MouseEvent)
		{
			this.releaseAction();
		}
		
		
		private function releaseAction()
		{
			this._isDrag = false;
		}
	}
}