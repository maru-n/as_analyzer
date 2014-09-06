package network.field{
	import flash.display.MovieClip;
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.geom.Point;
	import flash.utils.*;
	import tmbutil.TmbField;
	import network.component.HumanNodeBase;
	import network.component.HumanNodeBackLight;
	import network.component.GrabMask;
	import network.component.DebugMesBox;
	import network.component.heart;
	import network.component.Circle;
	import network.component.Fukidashi;
	import tmbutil.TmbMovieClip;
    import flash.text.TextFormat;
    import flash.external.ExternalInterface;
    public class NetworkField extends TmbField{

		private const _RANDOM:Number = 2;
		private var _currentOpenDepth:Number = 0;
		public var x_min:Number = 100000;
		public var y_min:Number = 100000;
		public var x_max:Number = -100000;
		public var y_max:Number = -100000;
		public var _gap:Number = 200;
        public var _focused:HumanNodeBase;
        public var _fromHumanID = 0;
		public var _edgeMin:Number = 99;
		public var _focusedNode:Number = 0;
		private var _gapTime:Number = 500;
		private var _queueGapTime:Number = 500;
		private var _defaultGapTime:Number = 500;
		public var _maxStep:Number;
		private var _startTime:Number = 0;
		private var _moveStartTime:Number = 0;
		public var _maxDepth:Number = 0;
		public var _isExtendOn:Boolean;
		public var _isCenterMoveOn:Boolean;
		public var _isNodeHighLightOn:Boolean;
		public var _parent:MovieClip;
		public var _posArray:Object;
		public var _nodeArray:Array;
		public var _nodeObject:Object;
		private var _ngap:Number = 1;
		private var _status:String = "stop";
		public var _mainMC:MovieClip;
		public var _defaultK:Number = 1/50; // 1/100
		public var _defaultF:Number = 3000;  // 1/3000
		public var _paramK:Number = _defaultK; // 1/50
		public var _paramF:Number = _defaultF; // 3000
		public var _paramW:Number = 1000;
		public var _dragMC:MovieClip;
		public var _w:Number;
		public var _h:Number;
		public var _openNodeArray:Array;
		public var _queue:Array;
		public var _isQueueGo:Boolean = false;
		public var _isTouched:Boolean = false;
		private var _queueStartTime:Number = 0;
		private var _gravX:Number = 0;
		private var _gravY:Number = 0;
		// デバッグ眼セージ
		public var _dmb:MovieClip;
		private var _queueOutNodeArray:Array;
		private var _linkProcessCount:Number = 0;
		
		private var _rans:Array;
		private var _lc:MovieClip;
		
		private var _hts:Array;
		private var _openNode;
		
		public var _isMovableOn:Boolean = false;

		public var _isProductOn:Boolean = false;
		
		public var _isLove = false;
		public var _loveCount = 0;
		
		private var _gm;
		// ノードが力学運動するか？
		public var _isForceOn:Boolean = true;
		
		public var _isGraduallyOn:Boolean = true;
		
		private var _test_count = 0;

                private var _pokopoko:Boolean = false;
                private var _poko_cnt:Number = 0;
                private var _poko_int:Number;

                private var _pull_famous:Boolean = false;

                public var _defaultColor = 0xD6F0F2;
                public var _mainScale:Number = -1;
                public var _mainColor = null;

		///// コンストラクタ
        function NetworkField(){
		}
		
		///// メソッド
		/*
		* フィールドの作成
		*/
		public function create()
		{
			
			if (!this._isGraduallyOn) {
				this._gapTime = 500;
				this._queueGapTime = 10;
			}
            trace("NetworkField width: "+this.width);
            trace("NetworkField height: "+this.height);
			this._hts = new Array();
			this._rans = new Array();
			this._parent = parent as MovieClip;
			this._isProductOn = this._parent._isProductOn;
			this._nodeArray = new Array();
			this._nodeObject = new Object();
			this._queueOutNodeArray = new Array();
			this._maxStep = this._parent._maxStep;
			this._mainScale = this._parent._mainScale;
			this._mainColor = this._parent._mainColor;
			this._edgeMin = this._parent._edgeMin;
			this._isExtendOn = this._parent._isExtendOn;
			this._isCenterMoveOn = this._parent._isCenterMoveOn;
			this._maxDepth = this._parent._depthBase + this._maxStep;
			this._w = root.loaderInfo.width;
			this._h = root.loaderInfo.height;
			this._gravX = this._w / 2;
			this._gravY = this._h / 2;
			this._defaultK = this._parent._forceK;
			this._defaultF = this._parent._forceF;
			this._paramK = this._defaultK;
			this._paramF = this._defaultF;
			this._paramW = this._parent._forceW;
			this._openNodeArray = new Array();
			this._queue = new Array();

			if (this._isExtendOn) {
				this.createCircle();
			}
			this.createPosArray();
			this.createGrabMask();
			this.createLinkCanvas();
			this.startOpen();
			this.createDebugMesBox();
			if(!this._isProductOn)this.setChildIndex(this._gm, 1);
			this.addEventListener(Event.REMOVED_FROM_STAGE,removeFunc);

                        if (this._pokopoko) {
                            this._poko_int = setInterval(openEdgeOfOuterNodes, 3000);
                        }
		}
		
		private function removeFunc(e:Event) {
			this.removeEventListener(Event.ENTER_FRAME, moveProcess);
		}
		
		private function createCircle()
		{
			var circle = new Circle();
			this.addChild(circle);
			circle.x = (this._w - 1000) / 2 + _parent._defaultNetworkX;
			circle.y = (this._h - 1000) / 2;
		}
		
		private function getNodePosition()
		{
			var gx:Number = 0;
			var gy:Number = 0;
			this.createPosArray();
			for(var i=0;i<this._nodeArray.length;i++){
				var node:MovieClip = this._nodeArray[i];
				var xPos:Number = Math.floor(node.x / this._gap);
				var yPos:Number = Math.floor(node.y / this._gap);
				this._posArray[xPos][yPos].push(node);
				gx += node.x;
				gy += node.y;
			}
			if(this._nodeArray.length==0)return;
			this._gravX = gx / this._nodeArray.length;
			this._gravY = gy / this._nodeArray.length;
		}
		
		private function createPosArray()
		{
			var xNum:Number = Math.ceil(root.loaderInfo.width / this._gap);
			var yNum:Number = Math.ceil(root.loaderInfo.height / this._gap);
			var n:Number = 2;
			this._posArray = new Object();
			for(var i=-1*n*xNum-1; i<xNum * (n+1)+1; i++){
				var a:Object = new Object();
				this._posArray[i]=a;
				for(var j=-1*n*yNum-1;j < yNum*(n+1)+1; j++){
					var b:Array = new Array();
					this._posArray[i][j]=b;
				}
			}
		}
		
		public function getNeighbors(xPos:Number, yPos:Number):Array
		{
			var res:Array = new Array();
			for(var i=xPos-this._ngap;i<=xPos+this._ngap;i++){
				for(var j=yPos-this._ngap;j<=yPos+this._ngap;j++){
					res = res.concat(this._posArray[i][j]);
				}
			}
			return res;
		}
		
		private function createGrabMask()
		{
			if (this._isProductOn) return;
			this._gm = new GrabMask();
			this.addChild(this._gm);
			
			var w:Number = root.loaderInfo.width;
			var h:Number = root.loaderInfo.height;
			this._gm.width = w * 23;
			this._gm.height = h * 23;
			this._gm.x = (-11) * w;
			this._gm.y = (-11) * h;
			this._gm.create();
		}
		
		/*
		* ステップでオープンする
		*/ 
		private function startOpen()
		{
			this.openNetwork();
			this._startTime = getTimer();
			this.addEventListener( Event.ENTER_FRAME, openProcess);
		}
		
		public function extendStartOpen()
		{
			this._maxDepth = this._parent._depthBase + 1;
			this._startTime = getTimer();
			this._openNode.removeLoadMark();
			this._openNode.createEdgeOpenButton();
			this._gapTime = this._defaultGapTime;
			this.addEventListener( Event.ENTER_FRAME, openProcess);
		}
		
		/**
		* ステップでオープンの処理
		*/
		private function openProcess(e:Event)
		{
			var c:Number = getTimer();
			if(this._currentOpenDepth >= this._maxDepth){
				this.removeEventListener(Event.ENTER_FRAME, openProcess);
			}
			if(c - this._startTime > this._gapTime){
				this.openNext();
				this._startTime = c;
			}
		}
		
		/*
		* 次のDepthをオープン
		*/
		public function openNext()
		{
			this._currentOpenDepth++;
			this.updateLink();
			this.openNetwork();
			this.moveAll();
		}
		
		/*
		* 実際のノードオープンなどはここでやる
		*/
		private function openNetwork()
		{
			// バックをクリア
			for(var n=0;n<this._nodeArray.length;n++){
				//this._nodeArray[n].clearBack();
			}
			for(var i=0;i<this._parent._humanInfoArray.length;i++){
				var obj:Object = this._parent._humanInfoArray[i];
				if(obj.depth==this._currentOpenDepth){	
					//trace(obj.depth);
					if(obj == null){
						trace("null");
					}
					else{
						trace("not null");
					}
					this.createNodeQueue(obj);
					var c:Number = getTimer();
				}
			}
			this.getNodePosition();
			// 開いたことをルートノードに伝える。けど、depth 0のものには影響なしで
			//if(this._currentOpenDepth > this._maxStep){
				//_parent._debug.text = String(this._openNodeArray[this._currentOpenDepth-1].name);
				//if (_parent._isExtendOn && this._openNodeArray[this._currentOpenDepth-this._maxStep] != null){
					//this._openNodeArray[this._currentOpenDepth-this._maxStep].extendEnd();
				//}
			//}
			// 開いたら、円グラフを集計
			if (_parent._isPieOn) _parent.drawPie();

                        // hit 件数が多い人を中心に近づける
                        if (_pull_famous) {
                            var centerX = 363
                                var centerY = 233
                                var famousThres = 10000
                                var doCount = 0
                                for (var i = 1; i < this._nodeArray.length; i++) {
                                    if (this._nodeArray[i]._obj.hit > famousThres &&
                                            this._nodeArray[i]._obj.face_url != "http://spysee.jp/assets/img/noimage_60.jpg" &&
                                            doCount < 3) {
                                        this._nodeArray[i].x = this._nodeArray[i].x - (this._nodeArray[i].x - centerX)/2
                                            this._nodeArray[i].y = this._nodeArray[i].y - (this._nodeArray[i].y - centerY)/2
                                            doCount++;
                                    }
                                    trace("index: "+i+" name: "+this._nodeArray[i]._obj.name+" hit: "+this._nodeArray[i]._obj.hit+" x: "+this._nodeArray[i].x+" y: "+this._nodeArray[i].y);
                                }
                        }

		}
		
		/*
		* ノードキューを作成
		*/
		private function createNodeQueue(obj:Object)
		{
			var hn = this.createNode(obj);
			if (obj.depth == 0) {
				this.setChildIndex(hn, 1);
			}else {
				this.setChildIndex(hn, 3);
			}
            if(obj._isNew == 0) {
                trace("new_node: "+obj.name);
                var tmp_a:Array = new Array();
                var tmp_name:String = obj.name;
                var tmp_face_url:String = obj.face_url;
                var tmp_profile:String = obj.profile;
                var tmp_tags:String = obj.tags;
                tmp_a.push(obj._id);
                tmp_a.push(tmp_name);
                tmp_a.push(tmp_face_url);
                tmp_a.push(tmp_profile);
                tmp_a.push(tmp_tags);
                tmp_a.push(0);
                tmp_a.push(0);
                tmp_a.push(this._fromHumanID);
                this._fromHumanID = 0;
                //tmp_a.push(this._obj.face_url);
                //tmp_a.push(this._obj.name);
                //tmp_a.push(this._obj.face_url);
                //tmp_a.push(this._obj.profile);
                trace(tmp_a);
                var dx = (this._w / 2 + _parent._defaultNetworkX - (hn.x * this.scaleX + this.x)) / 10;
                var dy = (this._h / 2 - 50- (hn.y * this.scaleY + this.y - hn.height/ 2)) / 10;
                for (var i = 1; i < 11; i++) {
                    setTimeout(this.em_move_all, i * 30, dx, dy);
                }
                this.changeFocused(hn);
                var info_pos = "left";
                if (!_parent._isDebugOn) {
                    ExternalInterface.call("toggle_infobox", tmp_a);
                }
            }
			this._queue.push(hn);
			if(!this._isQueueGo){
				this._isQueueGo = true;
				this._queueStartTime = getTimer();
				this.addEventListener( Event.ENTER_FRAME, queueProcess);
			}
		}
		
        public function changeFocused(hnb) {
            if (this._parent._bl) {
                if (this._focused && this._focused._bl) {
                    this._focused.removeChild(this._focused._bl);
                    this._focused._bl =null;
                }
            }
            for (var i = 0; i < this._nodeArray.length; i++) {
                this._nodeArray[i]._isFocused = false;
            }
            hnb._isFocused = true;
            hnb.loadImages();
            this._focused = hnb;
            if (this._parent._bl) {
                if (!this._focused._bl) {
                    this._focused._bl = new HumanNodeBackLight();
                    this._focused.addChild(this._focused._bl);
                    this._focused._bl.x = -32;
                    this._focused._bl.y = -32;
                    this._focused.setChildIndex(this._focused._bl,0);
                    if (this._focused._myColor) {
                        this._focused.setBackLightColor(this._focused._myColor);
                    }
                }
            }
        }

        public function em_move_all(dx, dy)
        {
            this.x += dx;
            this.y += dy;
        }

		private function queueProcess(e:Event)
		{
			var c:Number = getTimer();
				if(this._queue.length == 0){
					this._isQueueGo = false;
					this.removeEventListener(Event.ENTER_FRAME, queueProcess);
				}
				if(c - this._queueStartTime > this._queueGapTime){
					var hn = this._queue.shift();
					if(hn!=null){
						hn.alpha = 0;
						hn.changeAlpha(1,null,null);
						this.moveAll();
						this._queueStartTime = c;
						this._queueOutNodeArray.push(hn);
                        this._nodeObject[hn._obj._id] = hn;
						hn.createName();
					}
				}
		}
		
		/*
		* ノードを作成
		*/
		private function createNode(obj:Object)
		{	
			var links:Array = new Array();
			for (var i=0;i<_parent._linkInfoArray.length;i++){
				var linkObj:Object = _parent._linkInfoArray[i];
				if(linkObj.from == obj._id){
					var tmpObj:Object = new Object();
					tmpObj.link = linkObj.to;
					tmpObj.to = linkObj.to;
					tmpObj.type = linkObj.type;
					tmpObj.edge_type = linkObj.edge_type;
					tmpObj.edge_multi = linkObj.edge_multi;
					tmpObj.edge_keyword = linkObj.edge_keyword;
					links.push(tmpObj);
				}
				if(linkObj.to == obj._id){
					var tmpObj2:Object = new Object();
					tmpObj2.link = linkObj.from;
					tmpObj2.type = linkObj.type;
					tmpObj2.edge_type = linkObj.edge_type;
					tmpObj2.edge_multi = linkObj.edge_multi;
					tmpObj2.edge_keyword = linkObj.edge_keyword;
					links.push(tmpObj2);
				}
			}
			var hn:HumanNodeBase = new HumanNodeBase();
			hn.name = "hnb-" + obj._id;
			hn._obj = obj;
			hn._link = links;
			hn._isProductOn = this._isProductOn;
            if (hn._obj.depth == 0 && this._mainScale > 0) {
                hn.scaleX = this._mainScale;
                hn.scaleY = this._mainScale;
            }
			if (this._isMovableOn) {
				if (hn._obj.depth == 0) {
					hn.scaleX = 1.2;
					hn.scaleY = 1.2;
				}else if (hn._obj.depth == 1) {
					hn.scaleX = 1.2;
					hn.scaleY = 1.2;
				}else if (hn._obj.depth >= 2){
					hn.scaleX = 0.8;
					hn.scaleY = 0.8;
				}
			}
			// タグの処理
			if(obj.tags!=null){
				for (var j = 0; j < obj.tags.length; j++) {
					if (j > 0) break;
					var tag:String = obj.tags[j];
					if(_parent._tagNode[tag] == undefined){
						var tagArray:Array = new Array();
						tagArray.push(hn);
						_parent._tagNode[tag] = tagArray;
					}else{
						_parent._tagNode[tag].push(hn);
					}
				}
			}
			//
			this.addChild(hn);
			hn.create();
			// ここに背景をいれるコマンドを。
			if (this._isNodeHighLightOn && obj.tags!=null) {
				var p = parent as MovieClip;
				var color = p._colorInfo[obj.tags[0]];
				if (color != undefined){
					hn.setBack(color);
					trace("色",color);
                    hn._myColor = color;
				}
				else{
					hn.setBack(this._defaultColor);
                    hn._myColor = this._defaultColor;
				}
			}
            if (hn._obj.depth == 0 && this._mainColor) {
					hn.setBack(this._mainColor);
                    hn._myColor = this._mainColor;
					trace("main色",this._mainColor);
            }
			
			this._nodeArray.push(hn);	
			var px:Number = root.loaderInfo.width / 2;
			var py:Number = root.loaderInfo.height / 2;
			if (this._isProductOn) {
				py = root.loaderInfo.height * 3 /4;
			}
			if(hn._obj.depth==0){
                px += _parent._defaultNetworkX; 
				this._mainMC = hn;
				this._openNodeArray.push(hn);
				p = parent as MovieClip;
				if (p._isLove) {
					if (this._loveCount == 0) {
						px -= 50;
						this._loveCount++;
					}else {
						px += 50;
					}
				}
			}
			if (hn._obj.depth != 0) {
				if(this._isForceOn && this._isGraduallyOn){
				//if (0){
					this.getNodePosition();
					var parentMC:DisplayObject = this.getChildByName("hnb-"+hn._obj.parent);
					// 重心と親の位置に応じて、どの象限にだすか決めてしまう
					var sx:Number = 1;
					var sy:Number = 1;
					if(parentMC.x - this._gravX > 0) sx = -1;
					if(parentMC.y - this._gravY < 0) sy = -1;
		
					px = parentMC.x  + sx * this._gap / 2 * Math.random();
					py = parentMC.y  + sy * this._gap / 2 * Math.random();
	
					if (px < -this._w) px = -this._h;
					if (px > this._w * 2) px = this._h * 2;
					if (py < -this._h) py = -this._h;
					if (py > this._h * 2) py = this._h * 2;
				}else {
					var n = 5;
					this.getNodePosition();
					var parentMC2:DisplayObject = this.getChildByName("hnb-" + hn._obj.parent);
					var rad = Math.PI * 2 * (this._test_count * 2 % n) / n - Math.PI / 5;
					if (p._isLove) {
						rad = Math.PI * 2 * (this._test_count % 8) / 8 + Math.PI * (1/2 + 1/8);
					}
					if (this._isProductOn) rad = Math.PI * (this._test_count % n) / n + Math.PI * (1 + 1 / 10);
					var r = this._gap;
					if (hn._obj.depth > 1) r = this._gap * 3 / 8; 
					px = parentMC2.x + r * Math.cos(rad);
					py = parentMC2.y + r * Math.sin(rad);
					this._test_count++;
				}
			}
			hn.x = px;
			trace(py);
			hn.y = py;
			hn.alpha = 0;
			return hn;
		}
		
		private function updateLink()
		{
			for (var n=0;n<this._nodeArray.length;n++){
				var node:MovieClip = this._nodeArray[n];
				var links:Array = new Array();
				for (var i=0;i<_parent._linkInfoArray.length;i++){
					var linkObj:Object = _parent._linkInfoArray[i];
					if(linkObj.from == node._obj._id){
						var tmpObj:Object = new Object();
						tmpObj.link = linkObj.to;
						tmpObj.to = linkObj.to;
						tmpObj.type = linkObj.type;
						tmpObj.edge_type = linkObj.edge_type;
						tmpObj.edge_multi = linkObj.edge_multi;
						tmpObj.edge_keyword = linkObj.edge_keyword;
						links.push(tmpObj);
					}
					if(linkObj.to == node._obj._id){
						var tmpObj2:Object = new Object();
						tmpObj2.link = linkObj.from;
						tmpObj2.type = linkObj.type;
						tmpObj2.edge_type = linkObj.edge_type;
						tmpObj2.edge_multi = linkObj.edge_multi;
						tmpObj2.edge_keyword = linkObj.edge_keyword;
						links.push(tmpObj2);
					}
				}
				node._link = links;
			}
		}
		
		public function zoomAll(currentR:Number)
		{
            if (!currentR) currentR = this._parent._defaultR_Zoom;
			for(var i=0;i<this._nodeArray.length;i++){
				var human:MovieClip = this._nodeArray[i];
                var tf:TextFormat = new TextFormat(); 
                tf.size = Math.round(16 / currentR); 
                human._hname._name_text.setTextFormat(tf);
			}
		}
		
		public function moveAll()
		{
			for(var i=0;i<this._nodeArray.length;i++){
				var human:MovieClip = this._nodeArray[i];
				human.moveStart();
			}
			this.moveProcessCall();
		}
		
		public function stopAll()
		{
			for(var i=0;i<this._nodeArray.length;i++){
				var human:MovieClip = this._nodeArray[i];
				human.moveStop();
			}
			this._status = "stop";
		}
		
		public function checkMove()
		{
			var flag:Boolean = true;
			var count:Number = 0;
			for (var i = 0; i < this._nodeArray.length; i++) {
				var human:MovieClip = this._nodeArray[i];
				if (human == this._mainMC)continue;
				if(human._isMoving){
					flag=false;
					count++;
				}
			}
			//this._dmb._debugMes._message.text = count;
			if(flag)this._status="stop";
		}
		
		private function moveProcessCall()
		{
			if(this._status=="move")return;
			this._status = "move";
			var sTime:Number = getTimer();
			this.getNodePosition();
			this._moveStartTime = getTimer();
			this.addEventListener( Event.ENTER_FRAME, moveProcess);
		}
		
		private function moveProcess(e:Event)
		{
			var c:Number = getTimer();
			this._lc.graphics.clear();
			for (var i = 0; i < this._hts.length; i++) {
				this.removeChild(this._hts[i]);
			}
			this._hts = new Array();
			this.drawLinkProcess();
			if(c - this._moveStartTime > 1000){
				this.getNodePosition();
				this.checkMove();
			}
			if(this._status == "stop" && this._dragMC == null){
				trace("finished");
				this.removeEventListener(Event.ENTER_FRAME,moveProcess)
			}
		}
		
		private function createLinkCanvas()
		{
			this._lc = new MovieClip();
			this.addChild(this._lc);
		}
		
		private function drawLinkProcess()
		{
			this._linkProcessCount++;
			if (this._linkProcessCount == 1) {
				this._rans = new Array();
				for (var l = 0; l < 10; l++) {
					this._rans.push(Math.random() * this._RANDOM);
				}
			}
			for (var i=0;i<this._queueOutNodeArray.length;i++){
				var humanNode:MovieClip = this._queueOutNodeArray[i];
				for (var j=0;j<humanNode._link.length;j++){
					var tmpObj:Object = humanNode._link[j];
					var toNode:DisplayObject = this.getChildByName("hnb-"+tmpObj.to);
					var type:String = tmpObj.type;
					var edge_type:String = tmpObj.edge_type;
					var edge_multi:Number = tmpObj.edge_multi;
					if (!toNode) continue;
					var flag:Boolean = false;
					for (var k=0;k<this._queueOutNodeArray.length;k++){
						if(this._queueOutNodeArray[k]==toNode)flag=true;
					}
					if(!flag) continue;
					if(this._dragMC==humanNode || this._dragMC==toNode || edge_multi > 0){
						this._lc.graphics.lineStyle(3, 0xFF0000, 100);
					}else{
						var f:Number = 3;
						//var c:Number = 0x9acc35;
						var c:Number = 0xffcc99;
						// 折居くんリンク
						if (edge_type == 'topics') {
							c = 0xff6666;
							var fukiChild = this.getChildByName("fukidashi-" + humanNode._obj._id + "-" + tmpObj.to);
							if (!fukiChild) {
								fukiChild = this.createFukiChild(tmpObj.edge_keyword, humanNode._obj._id, tmpObj.to);
							
							}
							
							if(fukiChild != null){
								fukiChild.x = (humanNode.x + toNode.x) / 2;
								fukiChild.y = (humanNode.y + toNode.y) / 2;
							}	
							//this.createFukidashi((humanNode.x + toNode.x) / 2, (humanNode.y + toNode.y) / 2,tmpObj.edge_keyword);
						}
						var mc:MovieClip = toNode as MovieClip;
						//if (mc._obj.depth == 1) {
						if(humanNode._obj.depth==0){
							//this.createHeart((humanNode.x + toNode.x) / 2, (humanNode.y + toNode.y) / 2);
						}
						//if(mc._obj.depth >= 2){
						if(humanNode._obj.depth>=1){
							c = 0xcccccc;
							//c = 0x9acc35;
							f = 3;
						}
						
						//0728 矢印の色統一, deep edge color
						c = 0xcccccc;
						//c = 0x777777;
						this._lc.graphics.lineStyle(f,c,80);
					}
					if (this._isProductOn) this._lc.graphics.lineStyle(3, 0xffcc99, 50);
					///// ラインの描画
					//this.graphics.moveTo(humanNode.x,humanNode.y+10);
					//this.graphics.lineTo(toNode.x, toNode.y + 10);
					var x1 = humanNode.x;
					var y1 = humanNode.y;
					var x2 = toNode.x;
					var y2 = toNode.y;
					var r = 30;
					var th = Math.atan((y2 - y1) / (x2 - x1));
					if (x2 - x1 > 0) th = th + Math.PI;
					x1 = x1 - r * Math.cos(th);
					y1 = y1 - r * Math.sin(th);
					x2 = x2 + r * Math.cos(th);
					y2 = y2 + r * Math.sin(th);
					this.drawUneLine(x1, y1, x2, y2);
					
					// タイプの表示
					/*
					if (type != "") {
						var linkChild = this.getChildByName("linktype-" + humanNode._obj._id + "-" + tmpObj.to);
						if (!linkChild) {
							linkChild = this.createLinkChild(type, humanNode._obj._id, tmpObj.to);
						}
						if(linkChild != null){
							linkChild.x = (x1 + x2 ) / 2;
							linkChild.y = (y1 + y2) / 2;
						}
					}
					*/
					
					//this.drawUneLine(humanNode.x, humanNode.y + 10, toNode.x, toNode.y + 10);
				}
			}
			this.setChildIndex(_lc,0);
		}
		
		private function createLinkChild(type:String, id1:Number, id2:Number)
		{
			var mode = "";
			if (type.indexOf("破局") >= 0 || type.indexOf("離婚") >= 0) {
				mode = "break";
			}else if (type.indexOf("結婚")>=0 || type.indexOf("妻")>=0 || type.indexOf("夫")>=0 || type.indexOf("配偶者")>=0 || type.indexOf("熱愛")>=0){
				mode = "love";
			}else if (type.indexOf("母")>=0 || type.indexOf("父")>=0 || type.indexOf("娘")>=0 || type.indexOf("息子")>=0 || type.indexOf("親")>=0 || type.indexOf("兄")>=0 || type.indexOf("弟")>=0){
				mode = "family";
			}else if (type.indexOf("姉")>=0 || type.indexOf("妹")>=0){
				mode = "family";
			}else if (type.indexOf("友達")>=0 || type.indexOf("同僚")>=0 || type.indexOf("同級生")>=0){
				mode = "friend";
			}
			if(mode != ""){
				var linkChild = new Fukidashi();
				this.addChild(linkChild);
				linkChild.name = "linktype-" + id1 + "-" + id2;
				linkChild.gotoAndPlay(mode);
				return linkChild;
			}
			return null;
			
		}
		
		
		private function createFukiChild(keywords:String, id1:Number, id2:Number)
		{
			if(keywords != ""){
				var fukiChild = new Fukidashi();
				this.addChild(fukiChild);
				fukiChild.name = "fukidashi-" + id1 + "-" + id2;
				//trace(fukiChild.name);
				fukiChild._edge_keyword = keywords;
				fukiChild.create();
				return fukiChild;
			}
			return null;
			
		}
		
		private function createFukidashi(x,y,keywords)
		{
			var ht = new Fukidashi();
			this._hts.push(ht);
			this.addChild(ht);
			ht._edge_keyword = keywords;
			ht.x = x;
			ht.y = y;
			ht.create();
		}
		
		private function createHeart(x,y)
		{
			var ht = new heart();
			this._hts.push(ht);
			this.addChild(ht);
			ht.x = x;
			ht.y = y;
			ht.scaleX = 0.3;
			ht.scaleY = 0.3;
		}
		
		private function drawUneLine(x1, y1, x2, y2) {
			var cps:Array = new Array();
			var aps:Array = new Array();
			var numP:Number = 5;
			
			// コントロールポイントを作る
			for (var i = 1; i <= numP * 2; i++) {
				var p:Point = new Point();
				p.x = (x1 * (numP * 2 - i ) + x2 * i) / (numP * 2);
				p.y = (y1 * (numP * 2 - i ) + y2 * i) / (numP * 2);
				if(i % 2 == 0){
					cps.push(p);
				}else {
					aps.push(p);
				}
			}
			this._lc.graphics.moveTo(x1, y1);
			// ベジエさん
			/*
			for (i = 0; i < cps.length; i++) {
				this._lc.graphics.curveTo(
					//aps[i].x + Math.random() * this._RANDOM - this._RANDOM / 2,
					//aps[i].y + Math.random() * this._RANDOM - this._RANDOM / 2,
					//cps[i].x + Math.random() * this._RANDOM - this._RANDOM / 2,
					//cps[i].y + Math.random() * this._RANDOM - this._RANDOM / 2
					aps[i].x + this._rans[i] - this._RANDOM / 2,
					aps[i].y + this._rans[i] - this._RANDOM / 2,
					cps[i].x + this._rans[i] - this._RANDOM / 2,
					cps[i].y + this._rans[i] - this._RANDOM / 2
				);
			}
			*/
			this._lc.graphics.lineTo(x2, y2);
			
			var cx:Number = cps[cps.length-1].x + this._rans[cps.length-1]-this._RANDOM/2;
			var cy:Number = cps[cps.length-1].y + this._rans[cps.length-1] - this._RANDOM / 2;
			var r:Number = 10;
			
			var th:Number = Math.atan((y2 - y1) / (x2 - x1));
			if (x2 - x1 > 0) th = th + Math.PI;
			
			//0728修正
			var th1 = th + Math.PI / 6;
			var th2 = th - Math.PI / 6;
			var hx1 = r * Math.cos(th1) + cx;
			var hy1 = r * Math.sin(th1) + cy;
			var hx2 = r * Math.cos(th2) + cx;
			var hy2 = r * Math.sin(th2) + cy;
			if(!this._isProductOn){
				this._lc.graphics.moveTo(cx, cy);
				this._lc.graphics.lineTo(hx1, hy1);
				this._lc.graphics.moveTo(cx, cy);
				this._lc.graphics.lineTo(hx2, hy2);
			}
		}
		
		public function openEdge(hid:String,node)
		{
			this._openNode = node;
            this._fromHumanID = hid;
            //var dx = (this._w / 2 + 100+ _parent._defaultNetworkX -stage.mouseX) / 10;
            /*
            if (!(stage.mouseX > this._w / 2 && stage.mouseX < this._w - 50 && stage.mouseY > 50 && stage.mouseY < this._h - 50)) {
                var dx = (this._w / 2 + 140 -stage.mouseX) / 10;
                var dy = (this._h / 2 -stage.mouseY) / 10;
                for (var i = 1; i < 11; i++) {
                    setTimeout(em_move_all, i * 30, dx, dy);
                }
            }
            */
			_parent.loadExtraData(hid, node);
		}
		
		public function closeEdge(hid:String)
		{
			_parent._checkMainNode[hid]=null;
			// 全体のリンク情報の更新
			var tmpArray:Array = new Array();
			for (var i=0;i<this._parent._linkInfoArray.length;i++){
				var linkObj:Object = this._parent._linkInfoArray[i];
				if(linkObj.from != hid){
					tmpArray.push(linkObj);
				}
			}
			this._parent._linkInfoArray = tmpArray;
			this.moveAll();
		}
		
		public function deleteEdge(hid:String)
		{
			_parent._checkMainNode[hid]=null;
			// 全体のリンク情報の更新
			var tmpArray:Array = new Array();
			for (var i=0;i<this._parent._linkInfoArray.length;i++){
				var linkObj:Object = this._parent._linkInfoArray[i];
				//trace("[" + hid + "]" + linkObj.from + ":" + linkObj.to);
				if(linkObj.from != hid && linkObj.to != hid){
					tmpArray.push(linkObj);
				}
			}
			this._parent._linkInfoArray = tmpArray;
			this.moveAll();
		}
		
		public function deleteNode(hid:String)
		{
			this.stopAll();
			var tmpArray:Array = new Array();
			for (var i=0;i<this._nodeArray.length;i++){
				var hnObj:Object = this._nodeArray[i];
				//trace("delete:" + hnObj._obj._id + ":" + hid);
				if(hnObj._obj._id != hid)tmpArray.push(hnObj);
			}
			this._nodeArray = tmpArray;
			var tmpArray2:Array = new Array();
			for (var j=0;j<this._parent._humanInfoArray.length;j++){
				var infoObj:Object = this._parent._humanInfoArray[j];
				if(infoObj._id != hid){tmpArray2.push(infoObj);}else{trace(hid);}
			}
			this._parent._humanInfoArray = tmpArray2;
			this._parent._checkNode[hid]=undefined;
			this.getNodePosition();
			this.moveAll();
		}
		
		/**
		* なぜかCPU使用量が減る。
		*/
		private function createDebugMesBox()
		{
			this._dmb = new DebugMesBox();
			this.addChild(this._dmb);
			this._dmb._debugMes._message.text = "";
			this._dmb.x = 10;
			this._dmb.y = 10;
			//this._dmb.alpha = 0;
			this._dmb.width = 0;
			this._dmb.height = 0;
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
		
		public function moveCenter(nb:HumanNodeBase)
		{
			this.stopAll();
			var hid = nb._obj._id;
			var mainHid = this._mainMC._obj.id;
			for (var i = 0; i < this._nodeArray.length; i++) {
				var node = this._nodeArray[i];
				if (node._obj._id != hid && node._obj._id != mainHid)
					this.removeChild(node);
			}
			var p = parent as MovieClip;
			this._lc.graphics.clear();
			p.mainRestart(nb,this._mainMC);
		}


                public function openEdgeOfOuterNodes()
                {
                    var targetNodes = new Array();
                    this._nodeArray[this._nodeArray.length - 20].edgeOpen();
                    if (this._pokopoko) {
                        if (this._poko_cnt > 5) {
                            clearInterval(this._poko_int);
                        } else {
                            this._poko_cnt++;
                        }
                    }
                }
	}
}
