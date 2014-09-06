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
	
	import flash.net.navigateToURL;
    public class ProductItem extends TmbMovieClip{
		
		///// ムービークリップ関連
		//public var _base:MovieClip;
		
		
		///// ノードの情報
		// 氏名
		public var _name:String;
		// キーワード
		public var _keyword:String;
		// 顔画像のURL
		public var _url:String = "";
		// ノードのID
		public var _hid;
		
		public var _nid;
		
		public var _pnid;
		//　バックの色
		public var _bgColor:Number;
		
		private var _endFlag:Boolean;
		
		public var _depth;
		
		public var _amazon_url:String = "";
		public var _release_date:String = "";
		public var _label:String = "";
		public var _amount:String = "";
		public var _category:String = "";
		
		public var _rate;
		
		private var _lm:LoadingMark;
		
		///// コンストラクタ
        function ProductItem(){
		}
		
		public function create()
		{
			this.createLoadingMark();
			this.createBody();
			//this.buttonMode = true;
			//this.createListener();
			trace("RATE:" + this._rate);
		}
		
		private function createLoadingMark()
		{
			this._lm = new LoadingMark();
			this.addChild(this._lm);
			this._lm.x = 220 / 2;
			this._lm.y = 220 / 2;
		}
				
		private function createBody()
		{
			var pat:RegExp = new RegExp("SL75");
			this._url = this._url.replace(pat, "SL200");

			//this._body.alpha = 0;
			//var url = "http://s3.amazonaws.com/topface/" + this._nid + "/main.60.jpg" + "?a=" + getTimer();
			//this.loadImage(this._url,0,0,0,0,1,false);
			this.loadImage(this._url, 0, 0, 0, 0, 1, true);
			this._title.text = this._name;//this._name;
			//this._label_box.text = this._label;
			//this._release_date_box.text = this._release_date;
			if (this._amount != "") {
				//this._amount_box.text = "\\" + this._amount;
			}
			else {
				//this._amount_box.text = "";
			}
			//this._category_box.text = this._category;
			this.createRate();
		}
		
		private function createRate()
		{
			var half = (this._rate) % 10 / 5;
			var full = (this._rate - (this._rate % 10)) / 10;
			for (var i = 0; i < full; i++) {
				var ringo = new RingoFull();
				this.addChild(ringo);
				ringo.x = 30 * i;
				ringo.y = 300;
			}
			if (half) {
				var halfringo = new RingoHalf();
				this.addChild(halfringo);
				halfringo.x = 30 * full;
				halfringo.y = 300;
			}
			//trace("half:" + half + " full:" + full);
		}
		
		private function loadImage(url:String,x:Number,y:Number,w:Number,h:Number,z:Number,endflag:Boolean)
		{
			this._endFlag = endflag;
			if (url == "" && this._endFlag) {
				//this._body.alpha = 100;
				return;
			}
			var imgRequest:URLRequest = new URLRequest(url);
			var imgLoader:Loader = new Loader();
			this._endFlag = endflag;
			var mc = this;
			imgLoader.contentLoaderInfo.addEventListener(Event.COMPLETE,function(){
				//z = z * 0.8;
				//imgLoader.x = x + (w - imgLoader.width * z) / 2;
				//imgLoader.y = y + (h - imgLoader.height * z) / 2;
				imgLoader.x = (220 - imgLoader.width * z) / 2;
				imgLoader.y = (220 - imgLoader.height * z) / 2;
				trace("IMGLOAD" + imgLoader.width);
				imgLoader.scaleX = z;
				imgLoader.scaleY = z;
				addChild(imgLoader);
				setChildIndex(imgLoader, 1);
				mc.removeChild(mc._lm);
				//imgLoader.contentLoaderInfo.buttonMode = true;
				// 読み込んだ画像をボタンぽくみせるため、上に透明の四角をはってそれをボタンにする。
				//
				//imgLoader.addEventListener(MouseEvent.CLICK, clickAction);
				mc.createButtonMask();
				imgLoader.contentLoaderInfo.removeEventListener(Event.COMPLETE, arguments.callee);
			});
			imgLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, errorAction);
			try {
				imgLoader.load(imgRequest);
			} catch (error:Error) {
				trace("Unable to load requested document.");
			}
		}
		
		private function createButtonMask() {
			var square:Sprite = new Sprite();
			square.graphics.beginFill(0xFFFFFF);
			square.graphics.drawRect(10, 10, 200, 200);
			square.graphics.endFill();
			square.alpha = 0;
			this.addChild(square);	
			
			square.buttonMode = true;
			square.addEventListener(MouseEvent.CLICK, clickAction);
		}
		
		private function errorAction(e:IOErrorEvent){
			if(this._endFlag){
				//this._body.alpha = 100;
				return;
			}
			if(this._pnid != ""){
				//this._body.alpha = 100;
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
			this.loadImage(url,0,0,0,0,1,true);
		}
		
		
		

		
		// 以下、動作に関して
		public function createListener()
		{
			this.doubleClickEnabled = true;
			this.mouseChildren = false;
			this.buttonMode = true;
			this.addEventListener(MouseEvent.DOUBLE_CLICK, doubleClickAction);
			this.addEventListener(MouseEvent.MOUSE_DOWN, dragAction);
			this.addEventListener(MouseEvent.CLICK, clickAction);
			this.addEventListener(MouseEvent.MOUSE_UP, mouseUpAction);
			//this.addEventListener(MouseEvent.ROLL_OVER, mouseRollOverAction);
		}
		
		private function mouseRollOverAction(event:MouseEvent)
		{
			trace(this);
		}
		
		private function clickAction(event:MouseEvent) {
			//this._base.clickAction();
			trace("click");
			this.gotoAmazon();
		}
		
		private function doubleClickAction(event:MouseEvent){
			//ダブルクリック時の動作
			//this._base.doubleClickAction();
			
		}
		
		private function dragAction(event:MouseEvent){
			// マウスを押した時点での判定
			//this._base.dragAction();
			this.addEventListener(MouseEvent.MOUSE_UP, releaseOutsideAction);
			this.addEventListener(MouseEvent.MOUSE_OUT, releaseOutsideAction);
		}
		
		private function releaseOutsideAction(event:MouseEvent){
			this.removeEventListener(MouseEvent.MOUSE_UP, releaseOutsideAction);
			this.removeEventListener(MouseEvent.MOUSE_OUT, releaseOutsideAction);
			this.releaseAction();
		}
		
		private function mouseUpAction(event:MouseEvent)
		{
			this.releaseAction();
		}
		
		
		private function releaseAction()
		{
			//this._base.releaseAction();
		}
		
		public function setBack(color:Number) {
		}
		
		public function clearBack(){
		}
		
		public function gotoAmazon()
		{
			//var url:URLRequest = new URLRequest( "http://www.amazon.co.jp/gp/product/"+ this._hid + "?ie=UTF8&tag=spysee-kaimono-22&linkCode=as2&camp=247&creative=1211");
			var url:URLRequest = new URLRequest( "http://www.amazon.co.jp/gp/product/"+ this._hid + "?ie=UTF8&tag=mononoki-22&linkCode=as2&camp=247&creative=1211");
			navigateToURL( url , "_blank");
		}
		
		public function gotoProduct()
		{
			var url:URLRequest = new URLRequest( "/item/amz"+this._hid + "/" + this._name + "/ref_product_network" );
			navigateToURL( url , "_parent");
		}
		
	}
}