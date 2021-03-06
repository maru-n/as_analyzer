package network.component{
	/*
	* ノードのベース。この上に、実際の画像やボタンが乗ります。
	*/
	
	import flash.display.MovieClip;
	import flash.display.DisplayObject;
	import flash.display.SimpleButton;
	import flash.display.DisplayObject;
	import flash.events.Event;
	import tmbutil.TmbMovieClip;
	import flash.utils.escapeMultiByte;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.utils.getTimer;
    
	import flash.geom.ColorTransform;
	import flash.geom.Transform;
	
	public class HumanNodeBase_twitter extends TmbMovieClip{
		
		///// インスタンス関連の変数
		// 親のムービークリップ
		public var _nf:MovieClip;
		// エッジのオープン＆クローズボタン
		public var _eob:SimpleButton;
		public var _ecb:SimpleButton;
		// ノード情報ボタン
		public var _nib:SimpleButton;
		// ノードブックマークボタン
		public var _nbb:SimpleButton;
		// ノードクローズボタン
		public var _ncb:SimpleButton;
		// デバッグ眼セージ
		public var _dmb:MovieClip;
		
		///// データ関連の変数
		// ノードデータ
		public var _obj:Object;
		// リンクデータ
		public var _link:Array;
		
		///// ノードの設定関連の変数
		// 拡張モードであるか否か
		private var _isExtendOn:Boolean = true;
		// 動かすか否か
		public var _isMoveOn:Boolean = true;
		// ノードが力学運動するか？
		public var _isForceOn:Boolean = true;
		
		///// ノードの状態を表す変数
		// 今動いているか否か
		public var _isMoving:Boolean = false;
		// ドラッグされているか否か
		public var _isDrag:Boolean = false;
		
		public var _hn;
		
		private var _lm;
		
		public var _isHistory:Boolean = false;
		
		public var _isOnMouse:Boolean = false;
		
		public var _isProductOn:Boolean = false;
		
		private var _nm:NodeMenu;
		
		private var _tf:tweet_frame = null;
		
		///// コンストラクタ
        function HumanNodeBase_twitter(){
		}
		
		/**
		* ノードの作成時に初期設定を行う
		*/
		public function create()
		{
			this.addEventListener(Event.REMOVED_FROM_STAGE,removeFunc);
			this._nf = parent as MovieClip;
			// これは親で設定に変更
			if(!this._nf._isExtendOn || _obj.depth ==0) this._isExtendOn = false;
			if(!this._nf._isCenterMoveOn && this._obj.depth==0) this._isMoveOn = false;
			this.createNode();
			//this.moveStart();
			//this.createDebugMesBox();
		}
		
		private function removeFunc(e:Event) {
			this.removeEventListener(Event.ENTER_FRAME, moveStartProcess);
		}
		
		/**
		* ノードを作成する
		*/
		private function createNode()
		{
			// ノードを作る
			var hn:HumanNode = new HumanNode();
			this.addChild(hn);
			hn._url = this._obj.face_url;
			hn._name = this._obj.name;
			hn._keyword = this._obj.keyword;
			hn._hid = this._obj._id;
			hn._nid = this._obj._nid;
			hn._pnid = this._obj.pnid;
			hn._depth = this._obj.depth;
			hn.create();
			// 操作系を作る
			this.createButton();
			
			// ぐわーんとでる
			this.alpha = 0;
			//this.changeAlpha(1,null,null);
			this._hn = hn;
			
			//ツイート系準備
  		 	this._tf = new tweet_frame();
			this._tf.visible = false;
			if(this._obj._tweetPlace != null){
				if(this._obj._tweetPlace == "node"){
					_tf.x = 0;
					_tf.y = 0;
					this.addChild(this._tf);
				}
				else{
					var r = root as MovieClip;
					r.main._nf.addChild(this._tf)
					r.main._nf.setChildIndex(this._tf, r.main._nf.numChildren - 1)
				}
				this._tf.tweetText.text = this._obj._tweetText;
			}
		}
		
		public function createName()
		{
			this._hn._head._name_text.text = this._obj.name;
		}
		
		private function createButton()
		{
			// エッジオープンボタン
			if(this._isExtendOn){
				if(this._obj.depth < this._nf._maxDepth){
					//this.createEdgeCloseButton();
				}else{
					this.createEdgeOpenButton();
				}
			}else{
				//this.createEdgeCloseButton();
			}
			/*
			// ノード情報ボタン
			this._nib = new NodeInfoButton();
			this.addChild(this._nib);
			this._nib.x = 35;
			this._nib.y = -25;
			
			// ノードブックマークボタン
			this._nbb = new NodeBookButton();
			this.addChild(this._nbb);
			this._nbb.x = 35;
			this._nbb.y = -10;
			
			// ノードクローズボタン
			this._ncb = new NodeCloseButton();
			this.addChild(this._ncb);
			this._ncb.x = 35;
			this._ncb.y = 5;
			*/
			
		}
		
		private function createEdgeOpenButton(){
			if (this._eob !=null) this.removeChild(this._eob);
			this._eob = new EdgeOpenButton();
			this.addChild(this._eob);
			this._eob.x = 24;
			this._eob.y = 24;
		}
		
		private function createEdgeCloseButton(){
			if (this._eob !=null) this.removeChild(this._eob);
			this._eob = new EdgeCloseButton();
			this.addChild(this._eob);
			this._eob.x = 24;
			this._eob.y = 24;
		}
		
		private function createDebugMesBox()
		{
			this._dmb = new DebugMesBox();
			this.addChild(this._dmb);
			//this._dmb._debugMes._message.text = "hogehoge";
			this._dmb.x = -30;
			this._dmb.y = 40;
			//this.addEventListener( Event.ENTER_FRAME, debugProcess);
		}
		
		private function debugProcess(e:Event)
		{
			//this._dmb._debugMes._message.text = this._isMoving;
		}
		
		/**
		* ノードの動作させる
		*/
		public function moveStart()
		{
			//　以下の条件では動かさない
			if (this._isMoving) return;
			if (!this._isMoveOn) return;
			// 動作開始
			this._isMoving = true;
			this.addEventListener( Event.ENTER_FRAME, moveStartProcess);
		}
		
		/**
		* ノードの動作を（強制）終了する
		*/
		public function moveStop()
		{
			this._isMoving = false;
		}
		
		/**
		* 動作の開始
		*/
		private function moveStartProcess(e:Event)
		{
			// 現在の位置から力を計算する
			var force:Object = this.getForce();
			// 力の調整
			if (force.x>10) force.x = 10;
			if (force.y>10) force.y = 10;
			if (force.x<-10) force.x = -10;
			if (force.y<-10) force.y = -10;
			// 位置の移動
			this.x += force.x;
			this.y += force.y;
			//// 動作の終了
			// 力がなくなった、かつどれもドラッグされていない
			if (force.x == 0 && force.y == 0 && this._obj.depth != 0 && this._nf._dragMC == null) {
				this.removeEventListener(Event.ENTER_FRAME, moveStartProcess);
				this._isMoving = false;
			}
			// ドラッグされているノードである
			if(this._isDrag){
				this.removeEventListener(Event.ENTER_FRAME, moveStartProcess);
				this._isMoving = false;
			}
			// 強制的に止められた
			if(!this._isMoving){
				this.removeEventListener(Event.ENTER_FRAME, moveStartProcess);
			}
			// リンクがなくなった
			if(this._link.length==0){
				this.removeEventListener(Event.ENTER_FRAME, moveStartProcess);
				//this.changeAlpha(0,removeProcess,null);
				this.nodeClose();
			}
			//this._dmb._debugMes._message.text = this._link.length;
		}
		
		private function removeProcess()
		{
			this._nf.removeChild(this);
		}
		
		/**
		* 力の計算。引力と斥力を計算する
		*/
		private function getForce():Object
		{
			// 返り値用のオブジェクト
			var f:Object = new Object();
			// 変数設定
			var k:Number = this._nf._paramK;
			var fw:Number = this._nf._paramW;
			var gap:Number  = this._nf._gap;
			f.x = 0;
			f.y = 0;
			// 現在のポジションを得る 
			var posX = Math.floor(this.x / gap);
			var posY = Math.floor(this.y / gap);
			// ステージサイズを取得
			var w:Number = root.loaderInfo.width;
			var h:Number = root.loaderInfo.height;
			// 隣接するノードを得る
			var neighbors:Array = this._nf.getNeighbors(posX,posY);
			if (neighbors==null) return f;
			
			// 力の計算
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
				var force:Number = this._nf._paramF / dist / dist;
				var dy:Number = detY1;
				f.x += force * detX1 / dist;
				f.y += force * detY1/ dist;
			}
			
			// リンクの処理
			
			for (var j=0;j<this._link.length;j++){
				var tmpObj:Object = this._link[j];
				var human2:DisplayObject = this._nf.getChildByName("hnb-"+tmpObj.link);
				if (!human2) continue;
				var detX:Number = this.x - human2.x;
				var detY:Number = this.y - human2.y;
				f.x += (-1) * k * detX;
				f.y += (-1) * k * detY;
			}
			
			//　かべ重力を計算
			// うえからの重力
			var upperF:Number = this.y + h;
			if(upperF < 0) upperF = 1;
			var upperForce:Number = fw / upperF / upperF;
			f.y += upperForce;
			// 下から。商品版の場合は、この力が強くなる。
			
			var bottomF:Number = this.y - h * 2;
			if (this._isProductOn) bottomF = (this.y - h) / 2;
			if(bottomF > 0) bottomF = -1;
			var bottomForce:Number = fw / bottomF / bottomF;
			f.y -= bottomForce;
		
			var leftF:Number = this.x + w;
			if(leftF < 0) leftF = 1
			var leftForce:Number = fw / leftF /leftF;
			f.x += leftForce;
		
			var rightF:Number = this.x - w * 2;
			if(rightF > 0) rightF = -1;
			var rightForce:Number = fw / rightF / rightF;
			f.x -= rightForce;
			
			var force2 = Math.sqrt(f.x * f.x + f.y * f.y);
			if(force2<0.07){ // 0.07
				f.x = 0;
				f.y = 0;
			}
			return f;
		}
		
		/**
		* マウスいべんと関連
		*/
		public function clickAction()
		{
			var r = root as MovieClip;
			var main = r.getChildByName("main");
			//if (!main._isProductOn) return;
			var p = parent as MovieClip;
			
			if(this._obj.spysee_id == "null"){
				return;
			}
			return;
			
			if(!this._isHistory){
				if (this._obj.depth == 0) return;
				if(!p._isQueueGo)
					p.moveCenter(this);
			}else {
				p.mainOpen(this);
			}
		}
				
		public function doubleClickAction() {
			var r = root as MovieClip;
			var main = r.getChildByName("main");
			if (main._isProductOn) return;
			//ダブルクリック時の動作
			var name:String = escapeMultiByte(this._obj.name);
			//if(this._obj.keyword!=""){
			//	name = name + "/" + escapeMultiByte(this._obj.keyword);
			//}
			
			//0727追加 例外処理
			if(this._hn._hid == "null"){
				return;
			}
			//trace(this._obj.spysee_id);
			//0920追加 例外処理2
			if(this._obj.spysee_id == "null"){
				return;
			}
			
			var url:URLRequest = new URLRequest( "/" + name + "/" + this._obj.spysee_id + "/ref_network");
			if(this._obj.depth != 0 || this._nf._mode == "top") navigateToURL( url , "_parent");
		}
		
		public function dragAction(){
			if(this._obj.depth == 0) return;
			this._nf.moveAll();
			this._isDrag = true;
			this._nf._dragMC = this;
			var lastIndex:Number = this._nf.numChildren - 1;
			this._nf.setChildIndex(this,lastIndex);
			this.startDrag();
		}
		
		public function releaseAction()
		{
			if(!this._isHistory){
				this._isDrag = false;
				this._nf._dragMC = null;
				this.stopDrag();
				this.moveStart();
			}
		}
		
		/**
		* エッジオープン
		*/
		public function edgeOpen()
		{
			//trace("open");
			this._nf.openEdge(this._obj._id,this);
			this.createLoadMark();
			if (this._eob !=null) this.removeChild(this._eob);
			//this.createEdgeCloseButton();
		}
		/**
		* エッジクローズ
		*/
		public function edgeClose()
		{
			this._nf.closeEdge(this._obj._id);
			this.createEdgeOpenButton();
			// ノード自身のリンク情報の更新
			var newArray:Array = new Array();
			for(var i=0;i<this._link.length;i++){
				var tmpObj:Object = this._link[i];
				if (tmpObj.to==undefined){
					newArray.push(tmpObj);
				}else{
					// 相手方のエッジを消してあげる
					var toNode:MovieClip = this._nf.getChildByName("hnb-"+tmpObj.to) as MovieClip;
					toNode.edgeDelete(this._obj._id);
				}
				
			}
			this._link = newArray;
		}
		/**
		* 指定した相手のエッジの削除
		*/
		public function edgeDelete(hid:Number){
			var newArray:Array = new Array();
			for(var i=0;i<this._link.length;i++){
				var tmpObj:Object = this._link[i];
				if (tmpObj.link!=hid) newArray.push(tmpObj);
			}
			this._link = newArray;
		}
		
		/**
		* ノードのクローズ
		*/ 
		public function nodeClose()
		{
			this._nf.deleteEdge(this._obj._id);
			this.edgeClose();
			// エッジ情報を消す
			for(var i=0;i<this._link.length;i++){
				var tmpObj:Object = this._link[i];
				// 相手方のエッジを消してあげる
				var linkNode:MovieClip = this._nf.getChildByName("hnb-"+tmpObj.link) as MovieClip;
				linkNode.edgeDelete(this._obj._id);
			}
			this._nf.deleteNode(this._obj._id);
			this.removeEventListener(Event.ENTER_FRAME, moveStartProcess);
			this.changeAlpha(0,removeProcess,null);
		}
		
		public function createLoadMark()
		{
			this._lm = new LoadingMark();
			this.addChild(this._lm);
			this._lm.scaleX = 0.2;
			this._lm.scaleY = 0.2;
			this._lm.x = 25;
			this._lm.y = 25;
		}
		
		
		public function removeLoadMark()
		{
			if(this._lm!=null) this.removeChild(this._lm);
		}
		
		public function changeMouseCursorClick()
		{
			var p = parent as MovieClip;
			p.changeMouseCursorClick();
		}
		
		public function changeMouseCursorHand()
		{
			var p = parent as MovieClip;
			p.changeMouseCursorHand();
		}
		
		public function setBack(color:Number) {
			var mc = this._hn._hnback;
			var trans:Transform = new Transform( mc);
			
			var colorTrans:ColorTransform = new ColorTransform( 1, 1, 1, 1.0, 0, 0, 0, 0);
			colorTrans.color = color;
			trans.colorTransform = colorTrans;
			
		}
		
		public function clearBack() {
			var mc = this._hn._hnback;
			var trans:Transform = new Transform( mc);
			var colorTrans:ColorTransform = new ColorTransform( 1, 1, 1, 1, 0, 0, 0, 0);
			trans.colorTransform = colorTrans;
		}
		
		public function rollOverAction()
		{
			//2011/12/23追記:ツイートを表示
			if(this._obj._tweetPlace ==null){
				return;
			}
			
			if(this._obj._tweetPlace == "root"){
				var r = root as MovieClip;
				var tmp_mainMC = r.main._nf._mainMC;
				_tf.x = tmp_mainMC.x;
				_tf.y = tmp_mainMC.y;
			}
			
			this._tf.visible = true;
			/*
			var main = r.getChildByName("instance1");
			if(main._nf!=null){
				var lastIndex:Number = this._nf.numChildren - 1;
				this._nf.setChildIndex(this,lastIndex);
			}
			this._isOnMouse = true;
			if (main._isProductOn) {
				//if(main._pf!=null)main._pf.changeItem(this._obj);
				//if (!this._isHistory) this.createNodeMenu();
			}
			*/
		}
		
		public function rollOutAction()
		{
			// 判定はNodeMenuにさせる。こちら側では、ターゲットが外れたことだけ持っておく。
			this._isOnMouse = false;
			this._tf.visible = false;

			//if(this._nm!=null)
			//this._nm.deleteNodeMenu();
		}
		
		public function createNodeMenu()
		{
			this._nm = new NodeMenu();
			this.addChild(this._nm);
			this._nm.scaleX = 0.8;
			this._nm.scaleY = 0.8;
			this._nm.x = 20;
			this._nm.y = -30;
		}
		
		public function deleteNodeMenu()
		{
			if (this._nm != null) {
				this.removeChild(this._nm);
				this._nm = null;
				
			}
		}
		
		public function gotoCenter()
		{
			var p = parent as TmbMovieClip;
			p.moveCenter(this);
		}
		
		public function gotoInfo()
		{
			var r = root as MovieClip;
			var main = r.getChildByName("instance1");
			if (main._isProductOn) {
				if (main._pf != null) main._pf.changeItem(this._obj);
			}
		}
	}
}