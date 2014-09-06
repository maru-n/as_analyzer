package network{
    import flash.display.MovieClip;
	import flash.events.Event;
    import flash.events.MouseEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLVariables;
	import flash.net.URLRequestMethod;
	import flash.net.URLLoaderDataFormat;
	import flash.text.TextField;
	import flash.display.LoaderInfo;
    import flash.system.Security;
	
	import network.field.NetworkField;
	import network.field.ControlField;
	import network.field.HistoryField;
	import network.component.ZoomPanel;
	import network.component.NodeBookButton;
	import network.component.HelpBox;
	import tmbutil.Pie;
	import network.component.GripHandCursor;
	import network.component.ClickMask;
	import network.component.LoadingMark;
	import network.component.FirstMessage;
    import flash.external.ExternalInterface;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;

	///// ネットワーク図の基本はこれ。あとはパーツに応じて微調整する。
	
    public class Main extends MovieClip{
		///// ネットワーク図の設定関係
		//　円グラフの表示
		public var _isPieOn:Boolean;
		public var _isHelpboxOn:Boolean = true;
		public var _bl:Boolean = false;
		public var _noOverrun:Boolean = false;
		public var _loadtext:Boolean = false;
		public var _isHelpOpen:Boolean;
		// 拡張モードのりよう
		public var _isExtendOn:Boolean;
		// ズームモードのON/OFF
		public var _isZoomOn:Boolean;
		// デバグモード
		public var _isDebugOn:Boolean;
		// センターの動き
		public var _isCenterMoveOn:Boolean = true;
		// ノードのハイライトをするか
		public var _isNodeHighLightOn:Boolean = false;
		
		public var _isLove:Boolean;
		
		public var _isMovableOn:Boolean = false;
		
		public var _defaultR;
		public var _defaultR_Zoom;
		public var _uniqueID;
		public var _actionCnt:Number = 0;
		public var _loadingMarkScale:Number = 1.0;
		public var _yura:Boolean = false;
		public var _triangleForce:Boolean = true;
		public var _runOut:Boolean = false;
		public var _edgeMin:Number = 99;
		public var _zoomPanelScale:Number = 1;
		// メインのhumanID
		public var _hid;
		public var _hid1;
		public var _hid2;
		public var _main_name;
		
		private var _lm;
		public var _defaultNetworkX:Number = 0;
		///// 各種フィールド変数
		// ネットワークを表示するフィールド
		public var _nf:NetworkField;
		private var _cf:ControlField;
		public var _zp:ZoomPanel;
		public var _nb:NodeBookButton;
        public var _zpx = null;
		private var _hb:HelpBox;
		private var _cm:ClickMask;
		private var _hf:HistoryField;
		private var _fm:FirstMessage;
		public var _pf;
		
		private var _hand;
		///// ネットワーク図のデータ
		// ひとの情報
		public var _humanInfoArray:Array;
		public var _humanInfoObject:Object;
		// リンクの情報
		public var _linkInfoArray:Array;
		// すでにネットワーク図上にあるノードのチェック用
		public var _checkNode:Object;
		// すでにメインノードとして読み込まれたかどうか
		public var _checkMainNode:Object;
		public var _colorInfo:Object;
		
		///// ネットワーク図の動作に関する変数
		// ベースとなる木の深さ
		public var _depthBase:Number = 0;
		// ベースからいくつ木を掘り下げるか
		public var _maxStep:Number;
		
		///// タグ円グラフ関係
		// タグデータ
		public var _tag:Object;
		// あるタグに該当するタグ
		public var _tagNode:Object;
		// パイのデータ
		private var _pieArray:Array;
		// 円グラフの値
		private var _r1:Number = 20; // 内径
		private var _r2:Number = 100; // 外形
		
		///// ネットワークURL
		// ベースのXMLを取得するURL
		public var _url:String;
		// 拡張時に読みに行くURL
		public var _extendUrl:String;

		///// ネットワークの力加減
		public var _forceF:Number;
		public var _forceK:Number;
		public var _forceW:Number;
		
		public var _isClickMaskOn:Boolean = false;
		
		public var _isForceOn:Boolean = true;
		
		public var _isGraduallyOn:Boolean = true;
		
		public var _isHistoryOpening:Boolean = false;
		
		public var _isProductOn:Boolean = false;
		
		public var _isRestart:Boolean = false;
		
		private var _pieX:Number = 110;
		//private var _pieY:Number = 160;
		private var _pieY:Number = 110;
		
		private var _hn;
		
		private var _mainHn;
		
		public var _mainObj:Object;
		
		public var _optionPosition:String = "right";

                private var _defaultColor = 0xD6F0F2;

        public var _mouseX:Number;
        public var _mouseY:Number;
        public var _isChangeBackColor;
        public var _isScale = false;
        public var _mainScale:Number = -1;
        public var _mainColor = null;
		
		///// コンストラクタ
        function Main(){
            /*
            ExternalInterface.addCallback("receive_log", this.sendLogFromInfobox);
            for (var i = 0; i < 10; i ++) {
                    setTimeout(this.flash_loaded, i * 500);
            }
            Security.allowDomain("www2.spysee.jp");  
            Security.allowDomain("www3.spysee.jp");  
            Security.allowDomain("www.spysee.jp");  
            Security.allowDomain("spysee.jp");  
            */
		}
		
		public function mainStart(){
			var variables:URLVariables = new URLVariables();  
			variables.action = "start";
			variables.data = "x:"+stage.mouseX+",y:"+stage.mouseY;
            if(!this._isPieOn) {
                variables.data += ",pie_off:yes";
            }
            if(this._defaultR_Zoom) {
                variables.data += ",scale:"+this._defaultR_Zoom;
            }
            if(this._defaultNetworkX) {
                variables.data += ",defx:"+this._defaultNetworkX;
            }
            if(this._zpx) {
                variables.data += ",zpx:"+this._zpx;
            }
            if(this._optionPosition == 'right') {
                variables.data += ",opt_pos:right";
            }
            this.sendLog(variables);
			// デバッガーのクリア
			this._debug.text = "";
			// データの初期化
			this._humanInfoArray = new Array();
			this._humanInfoObject = new Object();
			this._linkInfoArray = new Array();
			this._colorInfo = new Object();
			this._checkNode = new Object();
			this._checkMainNode = new Object();
			this._tag = new Object();
			this._tagNode = new Object();
			if(this._hn==null)this.createLoadingMark();
			this.loadData();
        }
			
		///// メソッド
		
		/*
		* XMLデータの読み込み
		*/
		public function loadData()
		{
			var loader:URLLoader = new URLLoader();			
			var url:String = this._url + this._hid + "/3"
			//if(!this._isDebugOn) url = this._url + "?hid=" + this._hid + "&a=" + getTimer();
			//if(!this._isDebugOn) url = this._url + this._hid + "/" + getTimer();
			var request:URLRequest = new URLRequest(url);
			loader.addEventListener(Event.COMPLETE,startCreate);
			loader.load(request);
			//this._checkMainNode[this._hid]=true;
		}
		
		public function loadExtraData(hid:Number, nn)
		{
			if(this._checkMainNode[hid]!=undefined)return;
			this._depthBase = this._nf._maxDepth;
			var loader:URLLoader = new URLLoader();
			var url:String = this._extendUrl + hid + "/1";
            var black_list:String = ',';
			for(var i=0;i<this._humanInfoArray.length;i++){
                black_list += this._humanInfoArray[i]._id+",";
            }
            url += "/" + black_list;
            trace(url);
			//if (!this._isDebugOn) url = this._extendUrl + "?hid=" + hid + "&a=" + getTimer();
			//if(!this._isDebugOn) url = this._extendUrl + hid + "/" + getTimer();
			var request:URLRequest = new URLRequest(url);
			loader.addEventListener(Event.COMPLETE,startExtend);
			loader.load(request);
			//this._checkMainNode[hid]=true;
		}
		
		/*
		* XMLデータを変換
		*/
		public function startCreate(event:Event)
		{
			if (this._hn != null) this.removeChild(this._hn);
			if (this._mainHn != null) this.removeChild(this._mainHn);
			if (this._pf != null) {
				this.removeChild(this._pf);
				this._pf = null;
			}
			var xml:XML = new XML(event.target.data);
			this.parseXML(xml, false);
			this.create();
            if (this._isHelpOpen && this._isHelpboxOn) this._hb.openHelpBox();
			var variables:URLVariables = new URLVariables();  
			variables.action = "ready";
			variables.data = "x:"+stage.mouseX+",y:"+stage.mouseY;
            this.sendLog(variables);
            setTimeout(this.open_infobox, 1000);
		}

        public function open_infobox() {
            if (!this._isDebugOn) {
                ExternalInterface.call("open_infobox");
            }
        }
		
		public function startExtend(event:Event)
		{
			var xml:XML = new XML(event.target.data);
			this.parseXML(xml, true);
			this._nf.extendStartOpen();
		}
		
		public function parseXML(xml:XML, is_extend:Boolean)
		{
			for(var i=0;i<this._humanInfoArray.length;i++){
                this._humanInfoArray[i]._isNew ++;
            }
			var nodeList:XMLList = xml.human;
			var maxDepth:Number = 0;
			for(var i=0;i<nodeList.length();i++){
				if(nodeList[i].@depth>this._maxStep)continue;
                if (nodeList[i].@no_more_edge && nodeList[i].@no_more_edge > 0 ) {
                    this._checkMainNode[nodeList[i].@id]=true;
                    if (this._humanInfoObject[nodeList[i].@id]) {
                        trace(this._nf._nodeObject[nodeList[i].@id]);
                        this._nf._nodeObject[nodeList[i].@id].removeChild(this._nf._nodeObject[nodeList[i].@id]._eob);
                    }
                }
                if (nodeList[i].@row_type && nodeList[i].@row_type =='link' ) {
                    var link:Object = new Object();
                    link.from = nodeList[i].@from;
                    link.to   = nodeList[i].@to;
                    link.type = 'triangle';
                    link.edge_type = '';
                    link.edge_keyword = '';
                    this._linkInfoArray.push(link);
                    continue;
                }
				var d:Number = Number(nodeList[i].@depth) + this._depthBase;
				var obj:Object = new Object();
				obj._id = nodeList[i].@id;
				obj._nid = nodeList[i].@nid;
				obj._maxEdge = 0;
                if (!this._humanInfoObject[obj._id]) obj._isNew = 0;
                if(!is_extend) obj._isNew ++;
				// チェック済みじゃないものは、ノードを登録
				if (this._checkNode[obj._id]==undefined){
					this._checkNode[obj._id] = true;
					obj.depth  = d;
					obj.name   = nodeList[i].@name;
					obj.keyword = nodeList[i].@keyword;
					obj.profile = nodeList[i].@profile;
					obj.parent = nodeList[i].@from;
					obj.pnid = nodeList[i].@pnid;
					obj.face_url = nodeList[i].@url;
                                        if ( nodeList[i].@hit != undefined) {
                                            obj.hit = nodeList[i].@hit;
                                        }
					var tags:String = nodeList[i].@tags;
					var tagArray:Array = tags.split(",");
					obj.tags = tagArray;
					var faces:String = nodeList[i].@faces;
					var faceArray:Array = faces.split(",");
					obj.faces = faceArray;
					this._humanInfoArray.push(obj);	
					this._humanInfoObject[obj._id] = obj;	
					if (d == 0) {
						this._main_name = obj.name;
						this._mainObj = obj;
					}
					
					// タグ情報の追加
					for (var j = 0; j < tagArray.length; j++) {
						if (j > 0) break;
						var tag:String = tagArray[j];
						if (tag == "") continue;
						if(this._tag[tag]==undefined){
							var obj2:Object = new Object();
							obj2.tag = tag;
							obj2.count = 1;
							var tmpArray:Array = new Array();
							this._tag[tag] = obj2;
						}else{
							this._tag[tag].count++;
						}
					}
				}
				
				// リンク情報の登録
				if (d==this._depthBase) continue;
				var link:Object = new Object();
				link.from = nodeList[i].@from;
				link.to   = nodeList[i].@to;
				link.type = nodeList[i].@type;
				link.edge_type = nodeList[i].@edge_type;
				link.edge_multi = nodeList[i].@edge_multi;
				link.edge_keyword = nodeList[i].@edge_keyword;
                this._humanInfoObject[link.from]._maxEdge ++;
				this._linkInfoArray.push(link);
			}
			//this._debug.text = String(c);
			//this._debug.text = String(this._linkInfoArray.length);
		}
		
		
		
		/**
		* 各フィールドを作る
		*/
		public function create()
		{
			if(this._lm!=null)this.deleteLoadingMark();
            for (var i = 0; i < 10; i ++) {
                    setTimeout(this.finish_loading, i * 500);
            }
			var variables:URLVariables = new URLVariables();  
			variables.action = "load_done";
			variables.data = "x:"+stage.mouseX+",y:"+stage.mouseY;
            this.sendLog(variables);
			this.drawPie();
			this.createNetworkField();
			this.createControlField();
			if (this._defaultR > 0) {
				this._nf.zoomField(this._defaultR, root.loaderInfo.width / 2 + this._defaultNetworkX, root.loaderInfo.height / 2, null, null);
			}
			if (this._isZoomOn) this.createZoomPanel();
			if (this._isExtendOn && this._isHelpboxOn) this.createHelpBox();
			if (this._isClickMaskOn) this.createClickMask();
		}

        public function finish_loading() {
            if (!this._isDebugOn) {
                ExternalInterface.call("finish_loading");
            }
        }
		
        public function flash_loaded() {
            if (!this._isDebugOn) {
                ExternalInterface.call("flash_loaded");
            }
        }
		
		/*
		* ネットワーク表示用フィールドを作成する 
		*/
		private function createNetworkField()
		{
			this._nf = new NetworkField();
			this._nf._isProductOn = this._isProductOn;
			this.addChild(this._nf);
			this._nf._isForceOn = this._isForceOn;
			this._nf._isGraduallyOn = this._isGraduallyOn;
			this._nf._isNodeHighLightOn = this._isNodeHighLightOn;
			this._nf._isMovableOn = this._isMovableOn;
			trace("gradually" + this._isGraduallyOn);
			this._nf.create();
			//this._nf.x =  - this._defaultNetworkX;
			
			if(!this._isProductOn){
				var hand:GripHandCursor = new GripHandCursor();  
				this.addChild(hand);  
				hand.setHandTarget(this._nf);  
				this._hand = hand;
			}
		}
		
		/*
		* 操作用のフィールドを作成する
		*/
		private function createControlField()
		{
			this._cf = new ControlField();
			this.addChild(this._cf);
		}
		
		public function createHistoryField()
		{
			if (this._hf == null) {
				this._hf = new HistoryField();
				this.addChild(this._hf);
				this._hf.create();
				this._hf.x = -95;
				this._hf.y = 0;
				//this._hf.y = root.loaderInfo.height - 95;
			}
			if (this._hf != null) {
				if (this._isRestart && this._hf.x != 0) this._hf.moveMC(0, 0, null, null);
				this._hf.addHistory(this._mainObj);
				var lastIndex:Number = this.numChildren - 1;
				this.setChildIndex(this._hf, lastIndex);
			}
		}
				
		public function createFirstMessage()
		{
			if (this._isRestart) {
				if (this._fm != null) {
					this.removeChild(this._fm);
					this._fm = null;
				}
			}else {
				this._fm = new FirstMessage();
				this.addChild(this._fm);
				this._fm.scaleX = 0.6;
				this._fm.scaleY = 0.6;
				this._fm.x = root.loaderInfo.width - 250;
				this._fm.y = 150;
			}
		}
		
		private function createZoomPanel()
		{
			this._zp = new ZoomPanel();
			this.addChild(this._zp);
			this._zp.create();
			//this._zp.x = 20;
            if (this._zpx) {
                this._zp.x = this._zpx;
            }
            else {
                this._zp.x = 10;
            }
			this._zp.y = 10;
            this._zp.scaleX = this._zoomPanelScale;
            this._zp.scaleY = this._zoomPanelScale;
			this._nb = new NodeBookButton();
			this.addChild(this._nb);
			this._nb.create();
            this._nb.x = 8;
            this._nb.y = 50;
            this._nb.scaleX = 1.0;
            this._nb.scaleY = 1.0;
		}
		
		public function createColor()
		{
			var totalNum:Number = 0;
			var t2:Number = -Math.PI / 2;
			var tmpArray:Array = new Array();
			for (var tag in this._tag) {	
				totalNum += this._tag[tag].count;
				tmpArray.push(this._tag[tag]);
			}
			tmpArray.sortOn("count", Array.DESCENDING | Array.NUMERIC);
			var otherNum:Number = 0;
			var tmpNum:Number = 0;
			for(var i=0;i<tmpArray.length;i++)
			{
				var count:Number = tmpArray[i].count;
				var ratio = count / totalNum;
				if(ratio<1/20 || i > 5 ){
					otherNum += count;
				}else{
					var t1 = t2;
					t2 += Math.PI * 2 * count / totalNum;
					
					var color:Number = this.makeColor(i);
					this._colorInfo[tmpArray[i].tag] = color;
					
					tmpNum += count;
				}
			}
		}
		
		public function drawPie()
		{
			if(this._optionPosition == "right"){
				this._pieX = root.loaderInfo.width - 110;
			}else {
				this._pieX = 110;
			}
			if (!this._isPieOn) {
				this.createColor();
				return;
			}
			if(this._pieArray!=null)this.deletePie();
			this._pieArray = new Array();
			
			var pie_alpha = 1.0;
			var totalNum:Number = 0;
			var t2:Number = -Math.PI / 2;
			var tmpArray:Array = new Array();
			for (var tag in this._tag) {	
				trace(tag);
				totalNum += this._tag[tag].count;
				tmpArray.push(this._tag[tag]);
			}
			tmpArray.sortOn("count", Array.DESCENDING | Array.NUMERIC);
			var otherNum:Number = 0;
			var tmpNum:Number = 0;
			for(var i=0;i<tmpArray.length;i++)
			{
				var count:Number = tmpArray[i].count;
				var ratio = count / totalNum;
				if(ratio<1/20 || i > 5 ){
					otherNum += count;
					//this.tagUnselect(tmpArray[i].tag);
				}else{
					var t1 = t2;
					t2 += Math.PI * 2 * count / totalNum;
					
					var color:Number = this.makeColor(i);
					this._colorInfo[tmpArray[i].tag] = color;
					
					tmpNum += count;
					var pie:Pie = new Pie(this._r1,this._r2,t1,t2,color, pie_alpha);
					pie._defaultX = this._pieX;
					pie._defaultY = this._pieY;
					pie.x = this._pieX;
					pie.y = this._pieY;
					//pie._count = count;
					pie._count = Math.ceil(count / totalNum * 100);
					pie._tag   = tmpArray[i].tag;
					var r:Number = count / totalNum;
					addChild(pie);
					if(r >= 1/20){
						pie.createInfo();
					}
					this._pieArray.push(pie);
					this.tagSelect(tmpArray[i].tag, color);
				}
			}
			if (otherNum == 0) return;
			var t:Number = t2;
			t2 += Math.PI * 2 * otherNum / totalNum;
			//var color2 = int(tmpNum / totalNum *  0xCC) * 0x10100 + 0x0000CC;
			//0712追記
			var pie2:Pie = new Pie(this._r1,this._r2,t,t2,this._defaultColor, pie_alpha);
			pie2._defaultX = this._pieX;
			pie2._defaultY = this._pieY;
			pie2.x = this._pieX;
			pie2.y = this._pieY;
			//pie2._count = otherNum;
			pie2._count = Math.ceil(otherNum / totalNum * 100);
			pie2._tag = "その他";
			addChild(pie2);
			pie2.createInfo();
			this._pieArray.push(pie2);
			pie2.mouseEnabled = true;
		}
		
		public function deletePie()
		{
			for (var i=0;i<this._pieArray.length;i++){
				this.removeChild(this._pieArray[i]);
			}
			
		}
		
                public function makeColor(r:Number){
                    var color:Number = 0x000000;
                    var pallete = new Array( 0xA6CB50, 0xF5E72D, 0xF99A4B, 0x3695C9, 0xE85B4C, 0x9466DD); //original(vivid)
                    return pallete[r];
                }
		
		public function tagSelect(tag:String,color:Number)
		{
			trace("tagSelect:" + tag);
			if (this._tagNode[tag] == null) return;;
			var nodes:Array = this._tagNode[tag];
			for(var i=0;i<nodes.length;i++){
				nodes[i].setBack(color);
			}
		}
		
		public function tagUnselect(tag:String) {
			if (this._tagNode[tag] == null) return;
			var nodes:Array = this._tagNode[tag];
			for(var i=0;i<nodes.length;i++){
				nodes[i].clearBack();
			}
		}
		
		private function createHelpBox()
		{
			this._hb = new HelpBox();
			this.addChild(this._hb);
			this._hb.create();
			// 右下バージョン
			//this._hb.x = root.loaderInfo.width - 240;
			//this._hb.y = 10;
			// 左下バージョン
			//this._hb.x = -120;
			//this._hb.y = root.loaderInfo.height - 30;
			// 右下バージョン
			if(this._optionPosition == "right"){
				this._hb.x = root.loaderInfo.width - 240;
			}else {
				this._hb.x = -120;
			}
			this._hb.y = root.loaderInfo.height - 30;
			
		}
		
		public function deleteHelpBox()
		{
			this.removeChild(this._hb);
		}
		
		public function changeMouseCursorClick()
		{
			this._hand.hide(); 
		}
		
		public function changeMouseCursorHand()
		{
			this._hand.open();
		}
		
		private function createClickMask()
		{
			var cm = new ClickMask();
			this.addChild(cm);
			//cm.width = root.loaderInfo.width;
			//cm.height = root.loaderInfo.height;
			cm._hid = this._hid;
			cm._name = this._main_name;
			cm.create();
			this._cm = cm;
		}
		
		private function createLoadingMark()
		{
			this._lm = new LoadingMark();
			this.addChild(this._lm);
			this._lm.x = this.stage.stageWidth / 2 + this._defaultNetworkX;
			this._lm.y = this.stage.stageHeight / 2;
            this._lm.scaleX = this._loadingMarkScale;
            this._lm.scaleY = this._loadingMarkScale;
            if (this._loadtext) {
                this._fm = new FirstMessage();
                this.addChild(this._fm);
                this._fm.x = this.stage.stageWidth / 2 + this._defaultNetworkX;
                this._fm.y = this.stage.stageHeight / 2;
                this._fm.scaleX = this._loadingMarkScale;
                this._fm.scaleY = this._loadingMarkScale;
            }
			//this._lm.x = 395 / 2;
			//this._lm.y = 250 / 2;
		}
		
		private function deleteLoadingMark()
		{
			this.removeChild(this._lm);
			this._lm = null;
            if (this._fm) {
                this.removeChild(this._fm);
                this._fm = null;
            }
		}
		
		public function mainRestart(nb,mainNb)
		{
			this._mainHn = mainNb;
			//this._nf.removeChild(mainNb);
			this.addChild(mainNb);
			
			this._hn = nb;
			//this.deletePie();
			this._nf.removeChild(nb);
			this.addChild(nb);
		
			this._isRestart = true;
			
			//nb.x += this._defaultNetworkX;
			this.removeChild(this._nf);
			this.removeChild(this._cf);
			if (this._hb != null) this.removeChild(this._hb);
			if (this._pf != null) {
				//this.removeChild(this._pf);
				this._pf.moveMC(root.loaderInfo.width+500, this._pf.y, null, null);
			}
			if (this._cm != null) this.removeChild(this._cm);
			//this._pf = null;
			this._hid = nb._obj._id;
			this.mainStart();
			var x = root.loaderInfo.width / 2;
			var y = root.loaderInfo.height / 2;
			if (this._isProductOn) y = root.loaderInfo.height * 3 / 4;
			this._hn.moveMC(x, y, null, null);
			this._mainHn.moveMC(0, -120, null, null);
		}
		
		public function historyRestart(nb)
		{
			if (this._nf._isQueueGo) return;
			if (this._nf == null) return ;
			
			this._mainHn = this._nf._mainMC;
			//this._nf.removeChild(mainNb);
			this.addChild(this._mainHn);
			
			this._isRestart = true;
			
			this._hid = nb._obj._id;
			if(this._nf!=null) this.removeChild(this._nf);
			if(this._cf!=null) this.removeChild(this._cf);
			if (this._cm != null) this.removeChild(this._cm);
			if (this._pf != null) {
				this._pf.moveMC(root.loaderInfo.width+500, this._pf.y, null, null);
				//this.removeChild(this._pf);
			}
			//this._pf = null;
			//if (this._hn != null) this.removeChild(this._hn);
			this._hn = null;
			this.mainStart();
			this._mainHn.moveMC(0, -120, null, null);
		}

        public function sendLogFromInfobox(actionName:String, actionData:String) {
			var variables:URLVariables = new URLVariables();  
			variables.action = actionName;
            if (!actionData) actionData = '';
            variables.data = actionData;
            this.sendLog(variables);
        }

        public function sendLog(variables:URLVariables)
        {
            if (this._uniqueID != false) {
                this._mouseX = stage.mouseX;
                this._mouseY = stage.mouseY;
                var url:String = "/network_log";
                if (this._isDebugOn) {
                    url = "http://spysee.jp/network_log";
                }
                var request:URLRequest = new URLRequest(url);
                request.method = URLRequestMethod.POST;  
                variables.id = this._uniqueID;
                variables.hid = this._hid;
                this._actionCnt ++;
                variables.cnt = this._actionCnt;
                if (!variables.data) variables.data = '';
                variables.data = variables.data + ',time:'+getTimer();
                //this._dump(variables,0);
                request.data = variables;  
                if (variables.action != 'start' && variables.action != 'ready' && variables.action != 'load_done') {
                    this._nf._isTouched = true;
                }

                if (!this._isDebugOn) {
                    var loader:URLLoader = new URLLoader();                 
                    loader.dataFormat = URLLoaderDataFormat.VARIABLES;  
                    try {
                        loader.load(request);
                    }
                    catch (err:Error) {
                    }
                }
            }
        }

        function _dump(data,indent:Number)
        {
            if (! indent){indent=0;}
            if (indent==0){ trace('------------------------- ↓'); }
            var space:String = '';

            for (var key:String in data) {
                var value = data[key];
                if ( typeof(value) == "object" ){
                    space = '';
                    for( var i:Number=0; i<indent*8; i++){ space += ' '; }
                    trace( space +key+' : ('+typeof(value)+') : '+value);
                    indent++;
                    this._dump(value,indent);
                    indent --;
                }
                else{
                    space = '';
                    for( var i:Number=0;i<indent*8;i++){ space += ' '; }
                    trace( space +key+' : ('+typeof(value)+') : '+value);
                }
            }
            if ( typeof(data) == 'string' || typeof(data) == 'number' || typeof(data) == 'boolean' || typeof(data) == 'undefined' || typeof(data) == 'null' ){ trace( '名無し'+' : ('+typeof(data)+') : '+data); }
            if (indent==0){ trace('------------------------- ↑'+"\n"); }
        }
        public function zoomSlide(zoomD)
        {
            this._zp.zoomInOut(zoomD);
        }

    }
}
