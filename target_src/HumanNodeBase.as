package network.component{
    /*
     * ノードのベース。この上に、実際の画像やボタンが乗ります。
     */

    import flash.display.MovieClip;
    import flash.display.DisplayObject;
    import flash.display.SimpleButton;
    import flash.display.DisplayObject;
    import flash.display.Sprite;
    import flash.events.Event;
    import tmbutil.TmbMovieClip;
    import flash.utils.escapeMultiByte;
    import flash.net.URLRequest;
    import flash.net.navigateToURL;
    import flash.utils.getTimer;
	import flash.utils.setTimeout;
    import flash.text.TextFieldAutoSize;
    import flash.net.URLVariables;
    import flash.external.ExternalInterface;
    import flash.text.TextFormat;
	import network.component.NodeInfoButton;
	import network.component.HumanNodeBackLight;
	import network.component.HumanName;


    import flash.geom.ColorTransform;
    import flash.geom.Transform;
    import flash.geom.Matrix;

    public class HumanNodeBase extends TmbMovieClip{

        ///// インスタンス関連の変数
        // 親のムービークリップ
        public var _nf:MovieClip;
        public var _myColor;
        public var maxEdge:Number = 3;
        // エッジのオープン＆クローズボタン
        public var _eob:SimpleButton;
        public var _preb:SimpleButton;
        public var _nexb:SimpleButton;
        public var _ecb:SimpleButton;
        // ノード情報ボタン
        public var _nib:SimpleButton;
        // ノードブックマークボタン
        public var _nbb:SimpleButton;
        // ノードクローズボタン
        public var _ncb:SimpleButton;
        public var _bl:HumanNodeBackLight;
        // デバッグ眼セージ
        public var _dmb:MovieClip;
        public var _hname:MovieClip;

        ///// データ関連の変数
        // ノードデータ
        public var _obj:Object;
        // リンクデータ
        public var _link:Array;
        public var _isFocused = false;

        ///// ノードの設定関連の変数
        // 拡張モードであるか否か
        private var _isExtendOn:Boolean = true;
        // 動かすか否か
        public var _isMoveOn:Boolean = true;
        // ノードが力学運動するか？
        public var _isForceOn:Boolean = true;
		public var _edgeMin:Number = 99;
		public var _edgeCurrent:Number;
		public var _edgeMax:Number = 200;

        ///// ノードの状態を表す変数
        // 今動いているか否か
        public var _isMoving:Boolean = false;
        // ドラッグされているか否か
        public var _isDrag:Boolean = false;

        public var _hn;
        //public var _pb;

        private var _lm;

        public var _isHistory:Boolean = false;

        public var _isOnMouse:Boolean = false;

        public var _isProductOn:Boolean = false;

        private var _nm:NodeMenu;

        private var _hnback_color;
        private var _hn_matrix;

        private var _kenka = false;
        private var _yura = false;
        private var _triangleForce = true;
        private var _runOut = false;
        private var _run_cnt = 0;
        private var _time;
        public var images:Array;
        public var firstImage:Number;
        public var _imagesLoaded:Boolean = false;

        // explosion paramater
        const PARTICLE_MULT = 200;
        const PARTICLE_MAX_SIZE = 5;
        const PARTICLE_SPEED = 20;

        ///// コンストラクタ
        function HumanNodeBase(){
        }

        /**
         * ノードの作成時に初期設定を行う
         */
        public function create()
        {
            this.addEventListener(Event.REMOVED_FROM_STAGE,removeFunc);
            this.firstImage = 0;
            this.images = new Array();
            this._nf = parent as MovieClip;
			this._edgeMin = this._nf._edgeMin;
			this._edgeCurrent = this._edgeMin;
            // これは親で設定に変更
            if(!this._nf._isExtendOn) this._isExtendOn = false;
            if(!this._nf._isCenterMoveOn && this._obj.depth==0) this._isMoveOn = false;
            if(this._obj.depth == 0) this._nf.changeFocused(this);
            if(this._nf._parent._yura) this._yura = true;
            if(!this._nf._parent._triangleForce) this._triangleForce = false;
            if(this._nf._parent._runOut) this._runOut = true;
            if(this._obj.depth != 0) this._edgeMax *= 0.7;
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
            hn._profile = this._obj.profile;
            hn._hid = this._obj._id;
            hn._nid = this._obj._nid;
            hn._pnid = this._obj.pnid;
            hn._depth = this._obj.depth;
            if (this._obj.hit != undefined) {
                hn._hit = this._obj.hit;
            }
            if (this._obj.depth > 0) this.maxEdge = this._obj._maxEdge;
            hn.create();
            // 操作系を作る
            this.createButton();

            // ぐわーんとでる
            this.alpha = 0;
            //this.changeAlpha(1,null,null);
            this._hn = hn;
            if (this._isFocused) {
			//this._hn.loadImage("http://dic.nicovideo.jp/oekaki/21619.png", 0, 0, 0, 0, 1, true);
			//this._hn.loadImage("http://xn--n8jwkwbp8eddq8unc0dvfp365ciu7b8de.jp/wp-content/uploads/2014/02/kahun3.jpg", 0, 0, 0, 0, 1, true);
            //this.loadImages();
                this.loadImages();
            }
        }

        public function createName()
        {
            //this._hn._head._name_text.text = this._obj.name;
        }

        private function createButton()
        {
            // エッジオープンボタン
            if(this._isExtendOn){
                    this.createEdgeOpenButton();
            }else{
                //this.createEdgeCloseButton();
            }
            this.createPrevButton();
            this._nib = new NodeInfoButton();
            this.addChild(this._nib);
            this._nib.x = -30;
            this._nib.y = 25;

            this._hname= new HumanName();
            this.addChild(this._hname);
            this._hname.x = 0;
            this._hname.y = 57;
            this._hname._name_text.text = this._obj.name;
            this._hname._name_text.autoSize = TextFieldAutoSize.CENTER;
            var tf:TextFormat = new TextFormat(); 
            tf.size = int(16 / this._nf._parent._defaultR_Zoom); 
            this._hname._name_text.setTextFormat(tf);
            //format = this._hname._name_text.defaultTextFormat;
            //format.size = 12;
            //this._pb = new ProfileBox();
            //this._pb._profile.text = this._obj.profile;
            //this._pb.visible = false;
            //this._pb._isOpen = false;
            /*
            if (this._obj.depth == 0 ) {
                this._pb.visible = true;
                this._pb._isOpen = true;
            }
            */
            //this.addChild(this._pb);
            //this._pb.x = 0;
            //this._pb.y = -100;


            /*
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

        public function createEdgeOpenButton(){
            if (this._eob ==null) {
                this._eob = new EdgeOpenButton();
                this.addChild(this._eob);
                this._eob.x = 24;
                this._eob.y = 24;
            }
        }
        public function createPrevButton(){
             if (this._preb ==null) {
                 this._preb = new PrevButton();
                 this.addChild(this._preb);
                 this._preb.x = -24;
                 this._preb.y = 0;
                 this._preb.scaleX = 0.05;
                 this._preb.scaleY = 0.05;
             }
             if (this._nexb ==null) {
                 this._nexb = new NextButton();
                 this.addChild(this._nexb);
                 this._nexb.x = 24;
                 this._nexb.y = 0;
                 this._nexb.scaleX = 0.05;
                 this._nexb.scaleY = 0.05;
             }
            //this._preb.alpha = 0;
            //this._nexb.alpha = 0;
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
                if (_kenka == true) {
                    this.x += Math.random()*100-50;
                    this.y += Math.random()*100-50;
                } else {
                    this.removeEventListener(Event.ENTER_FRAME, moveStartProcess);
                    this._isMoving = false;
                }
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

        public function loadImages()
        {
            var u;
            if (this._hn && !this._imagesLoaded) { 
                for each (u in this._obj.faces) {
                    if (u != this._obj.face_url) {
                        this._hn.loadImage(u, 0, 0, 0, 0, 1, true);
                    }
                    this._imagesLoaded = true;
                }
            }
            if (this._preb && this._nexb) {
                this._preb.alpha = 100;
                this._nexb.alpha = 100;
            }
            if (this._obj.faces.length == 0) {
                this._preb.alpha = 0;
                this._nexb.alpha = 0;
            }
        }

        /**
         * 力の計算。引力と斥力を計算する
         */
        private function getForce():Object
        {
            //if (!this._nf._isTouched && this._obj.depth == 0 && this._edgeCurrent < this._edgeMax) {
            if (this._runOut) {
                if (!this._nf._isTouched ) {
                    if (this._run_cnt % 3 == 0) {
                        if (this._edgeCurrent < this._edgeMax) this._edgeCurrent ++;
                    }
                    this._run_cnt ++;
                    this._run_cnt = this._run_cnt % 3;
                }
                else {
                    if (this._obj.depth != 0 )this._edgeCurrent = this._edgeMin;
                }
            }
            // 返り値用のオブジェクト
            var f:Object = new Object();
            // 変数設定
            var k:Number = this._nf._paramK / 3;
            var fw:Number = this._nf._paramW;
            var gap:Number  = this._nf._gap;
            f.x = 0;
            f.y = 0;
            if  (this._isFocused) return f;
            // 現在のポジションを得る 
            var posX = Math.floor(this.x / gap);
            var posY = Math.floor(this.y / gap);
            // ステージサイズを取得
            var w:Number = root.loaderInfo.width * 23;
            var h:Number = root.loaderInfo.height * 23;
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
                dist -= this._edgeCurrent;
                if(dist <= 0)dist = - dist / 10 + 1;
                var force:Number = this._nf._paramF / dist / dist;
                var dy:Number = detY1;
                f.x += force * detX1 / dist;
                f.y += force * detY1/ dist;
            }

            // リンクの処理

            for (var j=0;j<this._link.length;j++){
                var tmpObj:Object = this._link[j];
                if (!this._triangleForce && tmpObj.type == "triangle") continue;
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

            //浮遊力
            if (this._yura) {
                f.x += Math.cos(this._obj._id)*0.5;
                f.y += Math.sin(this._obj._id)*0.5;
            }

            return f;
        }

        /**
         * マウスいべんと関連
         */
        public function clickAction()
        {

            //this.clearBack();
//            var r = root as MovieClip;
//            var main = r.getChildByName("main");
//            if (!main._isProductOn) return;
//

//            if(!this._isHistory){
//                if (this._obj.depth == 0) return;
//                if(!p._isQueueGo)
//                    p.moveCenter(this);
//            }else {
//                p.mainOpen(this);
//            }
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

            var p = parent as MovieClip;
            var variables:URLVariables = new URLVariables();  
            variables.action = "doubleclick";
            variables.data = "human_id:"+this._obj._id+",x:"+stage.mouseX+",y:"+stage.mouseY;
            p._parent.sendLog(variables);

            var url:URLRequest = new URLRequest( "/" + name + "/" + this._obj._id + "/network?ref=large_flash");
            if(this._obj.depth != 0 || this._nf._mode == "top") navigateToURL( url , "_parent");
        }

        public function getMain() {
            var p = parent as MovieClip;
            return p._parent;
        }

        public function dragAction(){
            if(!this._isMoveOn) return;
            
            this._nf.moveAll();
            this._isDrag = true;
            this._nf._dragMC = this;
            var p = parent as MovieClip;
            p._parent._mouseX = stage.mouseX;
            p._parent._mouseY = stage.mouseY;
            this._time = getTimer();
            var lastIndex:Number = this._nf.numChildren - 1;
            this._nf.setChildIndex(this,lastIndex);
            if (!p._parent._isDebugOn) {
                var tmp_a:Array = new Array();
                tmp_a.push(this._obj._id);
                ExternalInterface.call("toggle_close_with", tmp_a);
            }
            this.startDrag();
        }

        public function releaseAction()
        {
            
            if (this._isDrag == true) {
                var p = parent as MovieClip;
                var variables:URLVariables = new URLVariables();  
                variables.action = "dragend";
                variables.data = this._obj._id;
                variables.data = "human_id:"+this._obj._id+",x0:"+p._parent._mouseX+",y0:"+p._parent._mouseY+",x:"+stage.mouseX+",y:"+stage.mouseY+",start:"+this._time;
                if (Math.abs(p._parent._mouseX - stage.mouseX) < 4 && Math.abs(p._parent._mouseY - stage.mouseY) < 4) {
                    variables.action = "click";
                }
                var tmp_dx:Number=0;
                var tmp_dy:Number=0;
                if (variables.action == "click") {
                    var dx = (p._w / 2 + p._parent._defaultNetworkX - (this.x * p.scaleX + p.x)) / 10;
                    var dy = (p._h / 2 - 50- (this.y * p.scaleY + p.y - this.height/ 2)) / 10;
                    tmp_dx = dx * 10;
                    tmp_dy = dy * 10;
                    for (var i = 1; i < 11; i++) {
                        setTimeout(p.em_move_all, i * 30, dx, dy);
                    }
                    this._nf.changeFocused(this);
                }
                var info_pos = "left";
                //if (stage.mouseX < root.loaderInfo.width / 2) info_pos = "right";
                //trace(this._obj._id);
                //trace(this._obj.name);
                //trace(this._obj.pic);
                //trace(this._obj.profile);
                var tmp_a:Array = new Array();
                var tmp_name:String = this._obj.name;
                var tmp_face_url:String = this._obj.face_url;
                var tmp_profile:String = this._obj.profile;
                var tmp_tags:String = this._obj.tags;
                var tmp_x:Number = this.x * p.scaleX + p.x - this.width / 2 + tmp_dx;
                var tmp_y:Number = this.y * p.scaleY + p.y - this.height/ 2 + tmp_dy;
                tmp_a.push(this._obj._id);
                tmp_a.push(tmp_name);
                tmp_a.push(tmp_face_url);
                tmp_a.push(tmp_profile);
                tmp_a.push(tmp_tags);
                tmp_a.push(tmp_x);
                tmp_a.push(tmp_y);
                tmp_a.push(0);
                //tmp_a.push(this._obj.face_url);
                //tmp_a.push(this._obj.name);
                //tmp_a.push(this._obj.face_url);
                //tmp_a.push(this._obj.profile);
                if (!p._parent._isDebugOn && variables.action == 'click') {
                    ExternalInterface.call("toggle_infobox", tmp_a);
                }
                if (!p._parent._isDebugOn && variables.action == 'dragend') {
                    ExternalInterface.call("toggle_close");
                }
                p._focusedNode = this._obj._id;
                p._parent.sendLog(variables);
            }

            if(!this._isHistory){
                this._isDrag = false;
                this._nf._dragMC = null;
                this.stopDrag();
                this.moveStart();
            }
        }

        public function changeProfileBox()
        {
            //this._pb.changeProfileBox();
            //setChildIndex(this._pb, this.numChildren-1);
        }

        /**
         * エッジオープン
         */
        public function edgeOpen()
        {
            this.maxEdge ++;
            this._nf.openEdge(this._obj._id,this);
            this.createLoadMark();
            //if (this._eob !=null) this.removeChild(this._eob);
            //this.createEdgeCloseButton();
            var p = parent as MovieClip;
            var variables:URLVariables = new URLVariables();  
            variables.action = "edgeopen";
            variables.data = "human_id:"+this._obj._id+",x:"+stage.mouseX+",y:"+stage.mouseY;
            p._parent.sendLog(variables);
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
            this._eob.visible=false;
        }


        public function removeLoadMark()
        {
            if(this._lm!=null) this.removeChild(this._lm);
            this._eob.visible=true;
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

        public function setBackLightColor(color:Number) {
            if (this._bl) {
                var mc = this._bl;
                var trans:Transform = new Transform( mc);

                var colorTrans:ColorTransform = new ColorTransform( 1, 1, 1, 1.0, 0, 0, 0, 0);
                colorTrans.color = color;
                trans.colorTransform = colorTrans;
            }

        }

        public function setBack(color:Number) {
            var mc = this._hn._hnback;
            var trans:Transform = new Transform( mc);

            var colorTrans:ColorTransform = new ColorTransform( 1, 1, 1, 1.0, 0, 0, 0, 0);
            colorTrans.color = color;
            trans.colorTransform = colorTrans;
            this.setBackLightColor(color);

        }

        public function clearBack() {
            explosion(0,0);
            var mc = this._hn._hnback;
            var trans:Transform = new Transform( mc);
            var colorTrans:ColorTransform = new ColorTransform( 0, 0, 0, 0, 0, 0, 0, 0);
            trans.colorTransform = colorTrans;
            this.nodeClose();
        }

        public function rollOverAction()
        {
            var p = parent as MovieClip;
            if (p._parent._isChangeBackColor) {
                this._hnback_color = this._hn._hnback.transform.colorTransform;
                this.setBack(p._parent._isChangeBackColor);
            }
            if (p._parent._isScale == true) {
                this._hn_matrix = this._hn.transform.matrix;
                var m:Matrix = this._hn.transform.matrix;
                m.a = 1.25;
                m.d = 1.25;
                m.tx -= 4;
                m.ty -= 4;
                this._hn.transform.matrix = m;
            }
            /*
               var p = parent as MovieClip;
               var variables:URLVariables = new URLVariables();  
               variables.action = "rollover";
               variables.data = "human_id:"+this._obj._id+",x:"+stage.mouseX+",y:"+stage.mouseY;
             */
            /*
               var r = root as MovieClip;
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
            var p = parent as MovieClip;
            if (p._parent._isChangeBackColor) {
                this.setBack(this._hnback_color.color);
            }
            if (p._parent._isScale == true) {
                this._hn.transform.matrix = this._hn_matrix;
            }
            this._isOnMouse = false;
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
        public function explosion(x1:Number, y1:Number):void{
            var particle_qty:Number = Math.random() * (PARTICLE_MULT/2) + (PARTICLE_MULT/2);
            for(var i:int=0; i<particle_qty; i++){
                var pSize:Number = Math.random() * (PARTICLE_MAX_SIZE-1) + 1;
                var pAlpha:Number = Math.random();

                // draw the particle
                var p:Sprite = new Sprite();
                p.graphics.beginFill(0xFFAA00);
                p.graphics.drawCircle(0,0,pSize);

                // create a movieclip so we can add properties to it
                var particle:MovieClip = new MovieClip();
                particle.addChild(p);
                particle.x = x1;
                particle.y = y1;
                particle.alpha = pAlpha;

                // choose a direction and speed to send the particle
                var pFast:int = Math.round(Math.random() * 0.75);
                particle.pathX = (Math.random() * PARTICLE_SPEED - PARTICLE_SPEED/2) + 
                    pFast * (Math.random() * 10 - 5);
                particle.pathY = (Math.random() * PARTICLE_SPEED - PARTICLE_SPEED/2) + 
                    pFast * (Math.random() * 10 - 5);

                // this event gets triggered every frame
                particle.addEventListener(Event.ENTER_FRAME, particlePath);
                addChild(particle);
            }
        }

        // moves the particle
        public function particlePath(e:Event):void{
            e.target.x += e.target.pathX;
            e.target.y += e.target.pathY;
            e.target.alpha -= 0.005;

            // removes the particle from stage when its alpha reaches zero
            if(e.target.alpha <= 0){
                e.target.removeEventListener('enterFrame', particlePath);
                e.target.parent.removeChild(e.target);
            }
        }
    }
}
