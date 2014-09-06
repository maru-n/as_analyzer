package network.component{
	import flash.display.MovieClip;
	import tmbutil.TmbMovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.URLVariables;
	
    public class ZoomPanel extends TmbMovieClip{
	
		private var _parent:MovieClip;
		public var _currentR:Number = 1;
                private var _pokopoko = false;

		///// コンストラクタ
        function ZoomPanel(){
		}
		
		public function create()
		{
			this._step = 3;
			this._parent = parent as MovieClip;
			this.buttonMode = true;
			this._zoomIn.addEventListener(MouseEvent.MOUSE_DOWN, zoomIn);
			this._zoomOut.addEventListener(MouseEvent.MOUSE_DOWN, zoomOut);
			if (_parent._defaultR_Zoom > 0) {
				this._currentR = _parent._defaultR_Zoom;
                var base_x:Number = root.loaderInfo.width / 2 + _parent._defaultNetworkX;
                var base_y:Number = root.loaderInfo.height / 2;
				_parent._nf.zoomField(this._currentR, base_x, base_y, onEnable, null);
			}
		}
		
        public function zoomInOut(zoomD:Number)
        {
            this._currentR = zoomD;
            if (this._currentR < 4.0 && this._currentR > 0.49) {
                //_parent._nf.stopAll();
                //this._zoomIn.mouseEnabled = false;
                //this._zoomOut.mouseEnabled = false;
                trace("zpR1: "+this._currentR);
                var base_x:Number = root.loaderInfo.width / 2 + _parent._defaultNetworkX;
                var base_y:Number = root.loaderInfo.height / 2;
				_parent._nf.zoomField1(this._currentR, base_x, base_y);
                _parent._nf.zoomAll(this._currentR);
            }
        }
        private function zoomIn(event:MouseEvent)
        {
            if (_parent._nb.y >= 40) {
                _parent._nb.y -= 10;
            }
            else {
                _parent._nb.y = 30;
            }
            if (this._currentR < 4.0) {
                //_parent._nf.stopAll();
                //this._zoomIn.mouseEnabled = false;
                //this._zoomOut.mouseEnabled = false;
                this._currentR = this._currentR + 0.5;
                trace("zpR1: "+this._currentR);
                var base_x:Number = root.loaderInfo.width / 2 + _parent._defaultNetworkX;
                var base_y:Number = root.loaderInfo.height / 2;
				_parent._nf.zoomField1(this._currentR, base_x, base_y);
                _parent._nf.zoomAll(this._currentR);
            }
            if (this._pokopoko) {
                _parent._nf.openEdgeOfOuterNodes();
            }
            var variables:URLVariables = new URLVariables();  
            variables.action = "zoomin";
            variables.data = "x:"+stage.mouseX+",y:"+stage.mouseY;
            _parent.sendLog(variables);
        }
		
        public function zoomOut1()
        {
            if (this._currentR > 0.4) {
                //_parent._nf.stopAll();
                //this._zoomOut.mouseEnabled = false;
                //this._zoomIn.mouseEnabled = false;
                //this._currentR = this._currentR / 2;
                trace("zpR2: "+this._currentR);
                var base_x:Number = root.loaderInfo.width / 2 + _parent._defaultNetworkX;
                var base_y:Number = root.loaderInfo.height / 2;
				_parent._nf.zoomField1(this._currentR, base_x, base_y);
                _parent._nf.zoomAll(this._currentR);
            }
            if (this._pokopoko) {
                _parent._nf.openEdgeOfOuterNodes();
            }
            var variables:URLVariables = new URLVariables();  
            variables.action = "zoomout";
            variables.data = "x:"+stage.mouseX+",y:"+stage.mouseY;
            _parent.sendLog(variables);
        }
        private function zoomOut(event:MouseEvent)
        {
            if (_parent._nb.y <= 80) {
                _parent._nb.y += 10;
            }
            else {
                _parent._nb.y = 90;
            }
            if (this._currentR > 0.99999) {
                //_parent._nf.stopAll();
                //this._zoomOut.mouseEnabled = false;
                //this._zoomIn.mouseEnabled = false;
                this._currentR = this._currentR - 0.5;
                trace("zpR2: "+this._currentR);
                var base_x:Number = root.loaderInfo.width / 2 + _parent._defaultNetworkX;
                var base_y:Number = root.loaderInfo.height / 2;
				_parent._nf.zoomField1(this._currentR, base_x, base_y);
                _parent._nf.zoomAll(this._currentR);
            }
            if (this._pokopoko) {
                _parent._nf.openEdgeOfOuterNodes();
            }
            var variables:URLVariables = new URLVariables();  
            variables.action = "zoomout";
            variables.data = "x:"+stage.mouseX+",y:"+stage.mouseY;
            _parent.sendLog(variables);
        }

		public function onEnable()
		{
			this._zoomOut.mouseEnabled = true;
			this._zoomIn.mouseEnabled = true;
			_parent._nf.moveAll();
            trace("nf_scale2: "+_parent._nf.scaleX +" "+_parent._nf.scaleY);
            _parent._nf.zoomAll(this._currentR);
		}
	}
}
