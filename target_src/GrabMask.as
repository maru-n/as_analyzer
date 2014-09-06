package network.component{
	import flash.display.MovieClip;
	import flash.display.DisplayObject;
	import flash.ui.Mouse;
    import flash.external.ExternalInterface;
	
	import tmbutil.TmbMovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.URLVariables;
	import flash.utils.getTimer;
	
    public class GrabMask extends TmbMovieClip{
	
		private var _isDrag:Boolean = false;
		private var _parent:MovieClip;
		private var _sx:Number;
		private var _sy:Number;
		private var _px:Number;
		private var _py:Number;
		private var _sw:Number;
		private var _sh:Number;
        private var _time;
		///// コンストラクタ
        function GrabMask(){
		}
		
		public function create()
		{
			this._parent = parent as MovieClip;
			this.createListener();
			this._sw = root.loaderInfo.width * 10;
			this._sh = root.loaderInfo.height * 10;
		}
		
		private function createListener()
		{
			this.buttonMode = true;

			this.addEventListener(MouseEvent.MOUSE_DOWN, dragAction);
			this.addEventListener(MouseEvent.MOUSE_UP, mouseUpAction);
		}
		
		private function dragAction(event:MouseEvent){
			this._isDrag = true;
            _parent.stopAll();
			this._sx = stage.mouseX;
			this._sy = stage.mouseY;
			this._px = _parent.x;
			this._py = _parent.y;
            _parent._parent._mouseX = stage.mouseX;
            _parent._parent._mouseY = stage.mouseY;
            _parent.x_min= 100000;
            _parent.y_min= 100000;
            _parent.x_max= -100000;
            _parent.y_max= -100000;
			for(var i=0;i<_parent._nodeArray.length;i++){
                if (_parent._nodeArray[i].x > _parent.x_max) _parent.x_max = _parent._nodeArray[i].x;
                if (_parent._nodeArray[i].y > _parent.y_max) _parent.y_max = _parent._nodeArray[i].y;
                if (_parent._nodeArray[i].x < _parent.x_min) _parent.x_min = _parent._nodeArray[i].x;
                if (_parent._nodeArray[i].y < _parent.y_min) _parent.y_min = _parent._nodeArray[i].y;
            }
            
            this._time = getTimer();
            if (!_parent._parent._isDebugOn) {
                ExternalInterface.call("toggle_close");
            }
			this.addEventListener(MouseEvent.MOUSE_MOVE, moveAction);
			stage.addEventListener(MouseEvent.MOUSE_UP, releaseOutsideAction);
			//stage.addEventListener(MouseEvent.MOUSE_OUT, releaseOutsideAction1);
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
            if(cx >= - _parent.x_min * _parent.scaleX + 600) cx = - _parent.x_min * _parent.scaleX + 600;
            if(cy >= - _parent.y_min * _parent.scaleY + 200) cy = - _parent.y_min * _parent.scaleY + 200;
            if(cx <= - _parent.x_max * _parent.scaleX - 600 + root.loaderInfo.width) cx = - _parent.x_max * _parent.scaleX - 600 + root.loaderInfo.width;
            if(cy <= - _parent.y_max * _parent.scaleY - 200 + root.loaderInfo.height) cy = - _parent.y_max * _parent.scaleY - 200 + root.loaderInfo.height;
            trace("parent.x:  "+_parent.x);
            trace("parent.y:  "+_parent.y);
            trace("x_max:  "+_parent.x_max * _parent.scaleX);
            trace("x_min:  "+_parent.x_min * _parent.scaleX);
            trace("y_max:  "+_parent.y_max * _parent.scaleY);
            trace("y_min:  "+_parent.y_min * _parent.scaleY);
			_parent.x = cx;
			_parent.y = cy;
			
			
		}
		
		private function releaseOutsideAction(event:MouseEvent){
			stage.removeEventListener(MouseEvent.MOUSE_UP, releaseOutsideAction);
			//stage.removeEventListener(MouseEvent.MOUSE_OUT, releaseOutsideAction);
			this.removeEventListener(MouseEvent.MOUSE_MOVE, moveAction);
			this.releaseAction();
		}
		
		private function releaseOutsideAction1(event:MouseEvent){
			stage.removeEventListener(MouseEvent.MOUSE_UP, releaseOutsideAction);
			//stage.removeEventListener(MouseEvent.MOUSE_OUT, releaseOutsideAction);
			this.removeEventListener(MouseEvent.MOUSE_MOVE, moveAction);
			this.releaseAction1();
		}
		
		private function mouseUpAction(event:MouseEvent)
		{
			this.releaseAction1();
		}
		
		
		private function releaseAction()
		{
			this._isDrag = false;
			var variables:URLVariables = new URLVariables();  
			variables.action = "dragend_field";
			variables.data = "x0:"+_parent._parent._mouseX+",y0:"+_parent._parent._mouseY+",x:"+stage.mouseX+",y:"+stage.mouseY+",start:"+this._time;
            if (Math.abs(_parent._parent._mouseX - stage.mouseX) < 4 && Math.abs(_parent._parent._mouseY - stage.mouseY) < 4) {
                variables.action = "click_field";
            }
            _parent._parent.sendLog(variables);
		}

		private function releaseAction1()
		{
			this._isDrag = false;
            _parent.moveAll();
		}
	}
}
