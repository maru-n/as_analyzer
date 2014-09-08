package network.component{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.display.Loader;
	import flash.events.Event;	
	import flash.events.MouseEvent;
	import tmbutil.TmbMovieClip;
	import flash.geom.ColorTransform;
	import flash.geom.Point;
	import flash.display.Shape;
	import flash.utils.getTimer;
	import flash.utils.escapeMultiByte;
	import flash.events.IOErrorEvent;
	import flash.net.URLVariables;

    public class HumanNode extends TmbMovieClip{
		
		///// ムービークリップ関連
		public var _base:MovieClip;
		public var _hnback;
		
		///// ノードの情報
		// 氏名
		public var _name:String;
		// キーワード
		public var _keyword:String;
		// プロフィール
		public var _profile:String;
		// 顔画像のURL
		public var _url:String = "";
		// ノードのID
		public var _hid;
		
		public var _nid;
		
		public var _pnid;
		//　バックの色
		public var _bgColor:Number;
		
		private var _endFlag:Boolean;
		
		private var _startTime:Number;
		
		public var _depth;
		
		private var _isRollOver:Boolean = false;

                // hit 件数
                public var _hit:Number;

                // noimage thumbnail
                //public var _thumb = "http://spysee.jp/assets/img/noimage_60.jpg";
                public var _thumb = "http://spysee.jp/assets/img/noimage_60-1_green.png";
		
		///// コンストラクタ
        function HumanNode(){
		}
		
		public function create()
		{
			this._base = parent as MovieClip;
			this._hnback.alpha = 0;
			this.createBody();
			this.createListener();
		}
				
		private function createBody()
		{
			this._body.alpha = 0;
			//var url = "http://s3.amazonaws.com/topface/" + this._nid + "/main.60.jpg" + "?a=" + getTimer();
			//this.loadImage(this._url,0,0,0,0,1,false);
			this.loadImage(this._url, 0, 0, 0, 0, 1, true);
			//this._head._name_text.text = "";//this._name;
		}
		
		
		public function loadImage(url:String,x:Number,y:Number,w:Number,h:Number,z:Number,endflag:Boolean)
		{
            if (!url) return false;
                trace("image start: "+url+"here");
                    if (_thumb) {
                        if (url.match("noimage_60.jpg")) {
                            url = _thumb
                        }
                    }

			this._endFlag = endflag;
			if (url == "" && this._endFlag) {
				this._body.alpha = 100;
				return;
			}
			var imgRequest:URLRequest = new URLRequest(url);
			var imgLoader:Loader = new Loader();
			this._endFlag = endflag;
            this._base.images.push(imgLoader);
            imgLoader.alpha = 0;
            if (this._base.images.length == 1) imgLoader.alpha = 100;
			imgLoader.contentLoaderInfo.addEventListener(Event.COMPLETE,function(){
                trace("image success: "+url);
				z = z * 0.8;
                var max_xy = imgLoader.width;
                if (max_xy < imgLoader.height) max_xy = imgLoader.height;
                if (max_xy > 60) z = z * 60 / max_xy;
				imgLoader.x = x + (w - imgLoader.width * z) / 2;
				imgLoader.y = y + (h - imgLoader.height * z) / 2;
				imgLoader.scaleX = z;
				imgLoader.scaleY = z;
				addChild(imgLoader);
				setChildIndex(imgLoader,1);
				imgLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, arguments.callee);
			});
			imgLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, errorAction);
			try {
				imgLoader.load(imgRequest);
			} catch (error:Error) {
				trace("Unable to load requested document.");
			}
		}
		
		private function errorAction(e:IOErrorEvent){
                trace("image fail: ");
            /*
			if(this._endFlag){
				this._body.alpha = 100;
				return;
			}
			if(this._pnid != ""){
				this._body.alpha = 100;
				return;
			}
			var url:String = "";
			var name:String = escapeMultiByte(this._name);
			var keyword:String = escapeMultiByte(this._keyword);
			if(keyword != ""){
				url = "http://s3.amazonaws.com/cogolo_faces/" + name + " " + keyword + "/main.60.jpg" + "?a=" + getTimer();
			}else{
				url = "http://s3.amazonaws.com/cogolo_faces/" + name + "/main.60.jpg" + "?a=" + getTimer();
			}
            */
		//	this.loadImage(url,0,0,0,0,1,true);
		}
		
		
		
		public function changeColor(r:Number,g:Number,b:Number)
		{
			trace(this._hnback);
			var colorTrans:ColorTransform = new ColorTransform( 1, 1, 1, 1, 0, 0, 0, 0);

			colorTrans.redOffset = r;
			colorTrans.greenOffset = g;
			colorTrans.blueOffset = b;
			this._hnback.transform.colorTransform = colorTrans;
		}
		
		// 以下、動作に関して
		public function createListener()
		{
			this.doubleClickEnabled = true;
			this.mouseChildren = false;
			this.buttonMode = true;
			this.addEventListener(MouseEvent.DOUBLE_CLICK, doubleClickAction);
			this.addEventListener(MouseEvent.CLICK, clickAction);
			this.addEventListener(MouseEvent.MOUSE_DOWN, dragAction);
			this.addEventListener(MouseEvent.MOUSE_UP, mouseUpAction);
			this.addEventListener(MouseEvent.ROLL_OVER, mouseRollOverAction);
			this.addEventListener(MouseEvent.ROLL_OUT, mouseRollOutAction);
		}
		
		private function clickAction(event:MouseEvent) {
			this._base.clickAction();
		}
		
		private function doubleClickAction(event:MouseEvent){
			//ダブルクリック時の動作
			this._base.doubleClickAction();
			
		}
		
		private function dragAction(event:MouseEvent){
			// マウスを押した時点での判定
			this._base.dragAction();
			this.addEventListener(MouseEvent.MOUSE_UP, releaseOutsideAction);
			//this.addEventListener(MouseEvent.MOUSE_OUT, releaseOutsideAction);
		}
		
		private function releaseOutsideAction(event:MouseEvent){
			this.removeEventListener(MouseEvent.MOUSE_UP, releaseOutsideAction);
			//this.removeEventListener(MouseEvent.MOUSE_OUT, releaseOutsideAction);
			this.releaseAction();
		}
		
		/*
		private function mouseUpAction(event:MouseEvent)
		{
			this.releaseAction();
		}
		*/
		
		private function mouseUpAction(event:MouseEvent)
		{
			this.releaseAction();
		}
		
		private function mouseRollOverAction(event:MouseEvent)
		{
			var mc = this;
			var p = parent as MovieClip;
            p.loadImages();
			this._isRollOver = true;
			this._startTime = getTimer();
			this.addEventListener( Event.ENTER_FRAME, function() {
				if (getTimer() - mc._startTime > 50) {
					p.rollOverAction();
					mc.removeEventListener(Event.ENTER_FRAME, arguments.callee);
				}
				if(!mc._isRollOver)mc.removeEventListener(Event.ENTER_FRAME, arguments.callee);
			});
		}
		
		private function mouseRollOutAction(event:MouseEvent)
		{
			this._isRollOver = false;
			var mc = this;
			var p = parent as MovieClip;
			mc._startTime = getTimer();
			this.addEventListener( Event.ENTER_FRAME, function() {
				if (getTimer() - mc._startTime > 50) { // メニューに移動したあとも表示判定できるように。
					mc.removeEventListener(Event.ENTER_FRAME, arguments.callee);
					p.rollOutAction();
				}
			});
			
		}
		
		private function releaseAction()
		{
			this._base.releaseAction();
		}
		
		public function setBack(color:Number) {
		}
		
		public function clearBack(){
		}
	}
}
