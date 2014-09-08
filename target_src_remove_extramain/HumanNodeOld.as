package network.component{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.DisplayObject;
	import tmbutil.TmbMovieClip;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.net.navigateToURL;
	import flash.events.MouseEvent;
	import flash.display.Shape;
	import flash.utils.escapeMultiByte;
    public class HumanNode extends TmbMovieClip{

		public var _obj:Object;
		public var _link:Array;
		
		public var _rcolor:Number;
		public var _gcolor:Number;
		public var _bcolor:Number;
		
		public var _isMoving:Boolean = false;
		public var _isDrag:Boolean = false;
		private var _parent:MovieClip;
		
		private var _posX:Number;
		private var _posY:Number;
		
		private var _w:Number;
		private var _h:Number;
		
		private var _wallF:Number = 1000;
		
		private var _back:Sprite;
		
		///// コンストラクタ
        function HumanNode(){
		}
		
		public function create()
		{
			this._parent = parent as MovieClip;
			if(_obj.depth< _parent._maxStep)this._extendButton.alpha = 0;
			if(!this._parent._isExtendOn)this._extendButton.alpha = 0;
			this._w = root.loaderInfo.width;
			this._h = root.loaderInfo.height;
			this.setPos();
			this.createHead();
			this.moveStart();
			this.createListener();
		}
		
		private function setPos()
		{
			this._posX = Math.floor(this.x / this._parent._gap);
			this._posY = Math.floor(this.y / this._parent._gap);
		}
		
		private function createHead()
		{
			if(this._obj.face_url!="" && this._obj.face_url!=undefined){
				this._body.alpha = 0;
				this.loadImage(this._obj.face_url,0,0,0,0,1);
			}
			this._head._head_text.text = this._obj.name;
			var len:Number = this._head._head_text.text.length;
			if(len > 8){
				len = 8;
			}
			this._head._hb.width = len * 11 + 10;
			this._head._head_text.x = (this._head._hb.width - this._head._head_text.width - 5) / 2;
			this._head.x = (-1) * this._head._hb.width / 2;
			this._head.y += 20;
			this.changeColor();
			this.alpha = 0;
			this.changeAlpha(1,null,null);
		}
		
		private function loadImage(url:String,x:Number,y:Number,w:Number,h:Number,z:Number)
		{
			var imgRequest:URLRequest = new URLRequest(url);
			var imgLoader:Loader = new Loader();
			imgLoader.contentLoaderInfo.addEventListener(Event.COMPLETE,function(){
				imgLoader.x = x + (w - imgLoader.width * z) / 2;
				imgLoader.y = y + (h - imgLoader.height * z) / 2;
				imgLoader.scaleX = z;
				imgLoader.scaleY = z;
				addChild(imgLoader);
				setChildIndex(imgLoader,1);
			});
			imgLoader.load(imgRequest);
		}
		
		private function changeColor()
		{
			var colorTrans:ColorTransform = new ColorTransform( 1, 1, 1, 1, 0, 0, 0, 0);

			colorTrans.redOffset = this._rcolor;
			colorTrans.greenOffset = this._gcolor;
			colorTrans.blueOffset = this._bcolor;
			this._head._hb.transform.colorTransform = colorTrans;
		}
		
		public function moveStart()
		{
			if (this._isMoving) return;
			//中心のものをうごかさないならつかう
			if (!this._parent._isCenterMoveOn && this._obj.depth==0) return;
			this._isMoving = true;
			this.addEventListener( Event.ENTER_FRAME, moveStartProcess);
		}
		
		public function moveStop()
		{
			this._isMoving = false;
		}
		
		private function moveStartProcess(e:Event)
		{
			var force:Object = this.getForce();
			if (force.x>10) force.x = 10;
			if (force.y>10) force.y = 10;
			if (force.x<-10) force.x = -10;
			if (force.y<-10) force.y = -10;
			this.x += force.x;
			this.y += force.y;

			this._head._hb.alpha = 80;
			if(force.x==0 && force.y==0 && this._obj.depth != 0 && _parent._dragMC == null){
				this.removeEventListener(Event.ENTER_FRAME, moveStartProcess);
				this._isMoving = false;
			}
			if(this._isDrag){
				this.removeEventListener(Event.ENTER_FRAME, moveStartProcess);
				this._isMoving = false;
			}
			if(!this._isMoving){
				this.removeEventListener(Event.ENTER_FRAME, moveStartProcess);
			}
		}
		
		private function getForce():Object
		{
			var f:Object = new Object();
			var k:Number = _parent._paramK;
			f.x = 0;
			f.y = 0;
			// 現在のポジションを得る 
			var posX = Math.floor(this.x / this._parent._gap);
			var posY = Math.floor(this.y / this._parent._gap);
			// 隣接するノードを得る
			var neighbors:Array = this._parent.getNeighbors(posX,posY);
			if(neighbors==null)return f;
			
			for(var i=0;i<neighbors.length;i++){
				var human:MovieClip = neighbors[i];
				if (human == this) continue;
				// 斥力
				var detX1:Number = this.x - human.x;
				var detY1:Number = this.y - human.y;
				var dist:Number = Math.sqrt(detX1*detX1+detY1*detY1);
				//一定の距離以下は、すごいつよい！
				dist -= 49;
				if(dist <= 0)dist = 1;
				var force:Number = _parent._paramF / dist / dist;
				var dy:Number = detY1;
				f.x += force * detX1 / dist;
				f.y += force * detY1/ dist;
			}
			
			// リンクの処理
			
			for (var j=0;j<this._link.length;j++){
				var tmpObj:Object = this._link[j];
				var human2:DisplayObject = _parent.getChildByName("hn-"+tmpObj.link);
				if (!human2) continue;
				var detX:Number = this.x - human2.x;
				var detY:Number = this.y - human2.y;
				f.x += (-1) * _parent._paramK * detX;
				f.y += (-1) * _parent._paramK * detY;
			}
			
			//　かべ重力を計算
			// うえからの重力
			
			var upperF:Number = this.y + this._h;
			if(upperF < 0) upperF = 1;
			var upperForce:Number = this._wallF / upperF / upperF;
			f.y += upperForce;
			// したから
			var bottomF:Number = this.y - this._h * 2;
			if(bottomF > 0) bottomF = -1;
			var bottomForce:Number = this._wallF / bottomF / bottomF;
			f.y -= bottomForce;
		
			var leftF:Number = this.x +this._w;
			if(leftF < 0) leftF = 1
			var leftForce:Number = this._wallF / leftF /leftF;
			f.x += leftForce;
		
			var rightF:Number = this.x - this._w * 2;
			if(rightF > 0) rightF = -1;
			var rightForce:Number = this._wallF / rightF / rightF;
			f.x -= rightForce;
			
			var force2 = Math.sqrt(f.x * f.x + f.y * f.y);
			if(force2<0.07){ // 0.07
				f.x = 0;
				f.y = 0;
			}
			return f;
		}
	
		// 以下、動作に関して
		private function createListener()
		{
			this.doubleClickEnabled = true;
			this.mouseChildren = false;
			this.buttonMode = true;
			this.addEventListener(MouseEvent.DOUBLE_CLICK, doubleClickAction);
			this.addEventListener(MouseEvent.MOUSE_DOWN, dragAction);
			this.addEventListener(MouseEvent.MOUSE_UP, mouseUpAction);
		}
		
		private function doubleClickAction(event:MouseEvent){
			//ダブルクリック時の動作
			var name:String = escapeMultiByte(this._obj.name);
			var url:URLRequest = new URLRequest( "/" + name );
			//var url:URLRequest = new URLRequest( "/_tmb/asahi/ozawa.html");
			if(this._obj.depth != 0 || _parent._mode == "top") navigateToURL( url , "_parent");
		}
		
		private function dragAction(event:MouseEvent){
			// マウスを押した時点での判定
			var pos = new Point(stage.mouseX, stage.mouseY);
			var list : Array = stage.getObjectsUnderPoint(pos);
			var isExtendMode:Boolean = false;
			for(var i=0;i<list.length;i++){
				var obj : DisplayObject = list[i].parent;
				if(obj.name=="_extendButton") isExtendMode = true;
			}
			
			if(isExtendMode){
				_parent._openNodeArray.push(this);
				_parent.ExtendNode(this._obj._id);
				this.extendBarProcess();
				return;
			}
			_parent.moveAll();
			this._isDrag = true;
			_parent._dragMC = this;
			var lastIndex:Number = _parent.numChildren - 1;
			_parent.setChildIndex(this,lastIndex);
			this.startDrag();
			stage.addEventListener(MouseEvent.MOUSE_UP, releaseOutsideAction);
			stage.addEventListener(MouseEvent.MOUSE_OUT, releaseOutsideAction);
		}
		
		private function releaseOutsideAction(event:MouseEvent){
			stage.removeEventListener(MouseEvent.MOUSE_UP, releaseOutsideAction);
			stage.removeEventListener(MouseEvent.MOUSE_OUT, releaseOutsideAction);
			this.releaseAction();
		}
		
		private function mouseUpAction(event:MouseEvent)
		{
			this.releaseAction();
		}
		
		
		private function releaseAction()
		{
			this._isDrag = false;
			_parent._dragMC = null;
			this.stopDrag();
			this.moveStart();
		}
		
		public function extendBarProcess()
		{
			this._extendButton.gotoAndPlay("bar");
		}

		public function extendEnd()
		{
			this._extendButton.alpha = 0;
		}
		
		public function setBack(color:Number){
			if(this._back!=null)this.clearBack();
			this._back = new Sprite();
			this._back.graphics.beginFill(color);
			this._back.graphics.drawRect(0, 0, 70, 70);
			this._back.graphics.endFill();
			this._back.alpha = 0.5;
			addChild(this._back);
			this._back.x = -35;
			this._back.y = -35;
			this.setChildIndex(this._back,0);

		}
		
		public function clearBack(){
			if(this._back==null)return;
			removeChild(this._back);
			this._back=null;
		}
	}
}