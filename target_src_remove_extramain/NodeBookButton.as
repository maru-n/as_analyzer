package network.component{
    import flash.display.MovieClip;
	import tmbutil.TmbMovieClip;
    import flash.events.MouseEvent;
    import flash.events.Event;
    import flash.geom.Rectangle;
    public class NodeBookButton extends TmbMovieClip{
        private var _CurrentR:Number;
        private var _parent:MovieClip;

		///// コンストラクタ
        function NodeBookButton(){
            this.create();
		}

        public function create() { 
			this._parent = parent as MovieClip;
            this._CurrentR = 40;
            this.scaleX = 2;
            this.scaleY = 2;
            this.addEventListener(MouseEvent.MOUSE_DOWN, startdrag);
            this.addEventListener(MouseEvent.ROLL_OUT, stopdrag);
            this.addEventListener(MouseEvent.MOUSE_UP, stopdrag);
        }

        public function startdrag(e:MouseEvent){
            this.addEventListener(Event.ENTER_FRAME, btnlevel);
            this.startDrag(false, new Rectangle(8, 30, 0, 60));
        }

        public function stopdrag(e:MouseEvent){
            //this.removeEventListener(Event.ENTER_FRAME, btnlevel);
			this._parent._zp._zoomOut.mouseEnabled = true;
			this._parent._zp._zoomIn.mouseEnabled = true;
			this._parent._nf.moveAll();
            trace("nf_scale_in_node: "+this._parent._nf.scaleX +" "+this._parent._nf.scaleY);
            this.stopDrag();
        }

        public function btnlevel(e:Event) {
            if (int(90 - this.y) != int(this._CurrentR)) {
                var zoomD = 0.05 * (90 - this.y) + 0.5;
                this._parent.zoomSlide(zoomD);
            }
        }
	}
}
