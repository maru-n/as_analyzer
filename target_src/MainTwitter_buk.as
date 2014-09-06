package network{
    import flash.display.MovieClip;
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.display.LoaderInfo;
	import flash.utils.escapeMultiByte;
	
	import network.field.NetworkField;
	import network.field.ControlField;
	import network.component.ZoomPanel;
	import network.component.HelpBox;
	import tmbutil.Pie;
	import network.component.GripHandCursor;
	import network.component.ClickMask;
	// twitter関連のAPI
	import twitter.api.Twitter;
	import twitter.api.TwitterSearch;
	import twitter.api.data.TwitterStatus;
	import twitter.api.events.TwitterEvent;
	
	
	import flash.utils.getTimer;

	///// ネットワーク図の基本はこれ。あとはパーツに応じて微調整する。

    public class MainTwitter extends MovieClip{
		///// ネットワーク図の設定関係
		//　円グラフの表示
		public var _isPieOn:Boolean;
		// 拡張モードのりよう
		public var _isExtendOn:Boolean;
		// ズームモードのON/OFF
		public var _isZoomOn:Boolean;
		// デバグモード
		public var _isDebugOn:Boolean;
		// センターの動き
		public var _isCenterMoveOn:Boolean = true;
		// メインのhumanID
		public var _hid;
		public var _main_name;
		
		///// 各種フィールド変数
		// ネットワークを表示するフィールド
		public var _nf:NetworkField;
		private var _cf:ControlField;
		private var _zp:ZoomPanel;
		private var _hb:HelpBox;
		
		private var _hand;
		///// ネットワーク図のデータ
		// ひとの情報
		public var _humanInfoArray:Array;
		// リンクの情報
		public var _linkInfoArray:Array;
		// すでにネットワーク図上にあるノードのチェック用
		public var _checkNode:Object;
		// すでにメインノードとして読み込まれたかどうか
		public var _checkMainNode:Object;
		
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
		
		public var _isClickMaskOn:Boolean = false;
		
		public var _isForceOn:Boolean = true;
		
		public var _isGraduallyOn:Boolean = true;
		
		private var atom:Namespace = new Namespace("http://www.w3.org/2005/Atom"); 
		
		///// コンストラクタ
        function Main(){
		}
		
		public function mainStart(){
			// デバッガーのクリア
			this._debug.text = "";
			// データの初期化
			this._humanInfoArray = new Array();
			this._linkInfoArray = new Array();
			this._checkNode = new Object();
			this._checkMainNode = new Object();
			this._tag = new Object();
			this._tagNode = new Object();
			this.loadData();
			//this.getTweet("松尾豊");
        }
			
		///// メソッド
		
		/*
		* XMLデータの読み込み
		*/
		private function loadData()
		{
			var loader:URLLoader = new URLLoader();			
			var url:String = this._url;
			if (!this._isDebugOn) url = this._url + "?hid=" + this._hid + "&a=" + getTimer();
			this._debug.text = url;
			var request:URLRequest = new URLRequest(url);
			loader.addEventListener(Event.COMPLETE,startCreate);
			loader.load(request);
			this._checkMainNode[this._hid]=true;
		}
		
		public function loadExtraData(hid:Number)
		{
			if(this._checkMainNode[hid]!=undefined)return;
			this._depthBase = this._nf._maxDepth;
			var loader:URLLoader = new URLLoader();
			var url:String = this._extendUrl;
			if(!this._isDebugOn) url = this._extendUrl + "?hid=" + hid + "&a=" + getTimer();
			var request:URLRequest = new URLRequest(url);
			loader.addEventListener(Event.COMPLETE,startExtend);
			loader.load(request);
			this._checkMainNode[hid]=true;
		}
		
		/*
		* XMLデータを変換
		*/
		private function startCreate(event:Event)
		{
			var xml:XML = new XML(event.target.data);
			this.parseXML(xml);
			this.create();
		}
		
		private function startExtend(event:Event)
		{
			var xml:XML = new XML(event.target.data);
			this.parseXML(xml);
			this._nf.extendStartOpen();
		}
		
		private function parseXML(xml:XML)
		{
			var nodeList:XMLList = xml.human;
			var maxDepth:Number = 0;
			for(var i=0;i<nodeList.length();i++){
				if(nodeList[i].@depth>this._maxStep)continue;
				var d:Number = Number(nodeList[i].@depth) + this._depthBase;
				var obj:Object = new Object();
				obj._id = nodeList[i].@id;
				obj._nid = nodeList[i].@nid;
				// チェック済みじゃないものは、ノードを登録
				if (this._checkNode[obj._id]==undefined){
					this._checkNode[obj._id] = true;
					obj.depth  = d;
					obj.name   = nodeList[i].@name;
					obj.keyword = nodeList[i].@keyword;
					obj.parent = nodeList[i].@from;
					obj.pnid = nodeList[i].@pnid;
					obj.face_url = nodeList[i].@url;
					var tags:String = nodeList[i].@tag;
					var tagArray:Array = tags.split(",");
					obj.tags = tagArray;
					this._humanInfoArray.push(obj);	
					if (d == 0) {
						this._main_name = obj.name;
					}
					
					// タグ情報の追加
					for(var j=0;j<tagArray.length;j++){
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
				this._linkInfoArray.push(link);
			}
			//this._debug.text = String(c);
			//this._debug.text = String(this._linkInfoArray.length);
		}
		
		
		
		/**
		* 各フィールドを作る
		*/
		private function create()
		{
			this.createNetworkField();
			//this.createControlField();
			if (this._isZoomOn) this.createZoomPanel();
			if (this._isExtendOn) this.createHelpBox();
			if (this._isClickMaskOn) this.createClickMask();
		}
		
		/*
		* ネットワーク表示用フィールドを作成する 
		*/
		private function createNetworkField()
		{
			this._nf = new NetworkField();
			this.addChild(this._nf);
			this._nf._isForceOn = this._isForceOn;
			this._nf._isGraduallyOn = this._isGraduallyOn;
			trace("gradually" + this._isGraduallyOn);
			this._nf.create();
			
			var hand:GripHandCursor = new GripHandCursor();  
			this.addChild(hand);  
			hand.setHandTarget(this._nf);  
			this._hand = hand;
		}
		
		/*
		* 操作用のフィールドを作成する
		*/
		private function createControlField()
		{
			this._cf = new ControlField();
			this.addChild(this._cf);
		}
		
		private function createZoomPanel()
		{
			this._zp = new ZoomPanel();
			this.addChild(this._zp);
			this._zp.create();
			this._zp.x = 10;
			this._zp.y = 10;
		}
		
		public function drawPie()
		{
			if(!this._isPieOn)return;
			if(this._pieArray!=null)this.deletePie();
			this._pieArray = new Array();
			var totalNum:Number = 0;
			var t2:Number = -Math.PI / 2;
			var tmpArray:Array = new Array();
			for (var tag in this._tag){
				totalNum += this._tag[tag].count;
				tmpArray.push(this._tag[tag]);
			}
			tmpArray.sortOn("count", Array.DESCENDING | Array.NUMERIC);
			var otherNum:Number = 0;
			var tmpNum:Number = 0;
			for(var i=0;i<tmpArray.length;i++)
			{
				var count:Number = tmpArray[i].count;
				if(count<2){
					otherNum += count;
				}else{
					var t1 = t2;
					t2 += Math.PI * 2 * count / totalNum;
					
					var color:Number = this.makeColor(tmpNum / totalNum);

					tmpNum += count;
					var pie:Pie = new Pie(this._r1,this._r2,t1,t2,color, 0.2);
					pie._defaultX = 100;
					pie._defaultY = 150;
					pie.x = 100;
					pie.y = 150;
					pie._count = count;
					pie._tag   = tmpArray[i].tag;
					var r:Number = count / totalNum;
					addChild(pie);
					if(r >= 1/20){
						pie.createInfo();
					}
					this._pieArray.push(pie);
				}
			}
			var t:Number = t2;
			t2 += Math.PI * 2 * otherNum / totalNum;
			var color2 = int(tmpNum / totalNum *  0xCC) * 0x10100 + 0x0000CC;
			var pie2:Pie = new Pie(this._r1,this._r2,t,t2,color2, 0.2);
			pie2._defaultX = 100;
			pie2._defaultY = 150;
			pie2.x = 100;
			pie2.y = 150;
			pie2._count = otherNum;
			pie2._tag = "その他";
			addChild(pie2);
			pie2.createInfo();
			this._pieArray.push(pie2);
			pie2.mouseEnabled = false;
		}
		
		public function deletePie()
		{
			for (var i=0;i<this._pieArray.length;i++){
				this.removeChild(this._pieArray[i]);
			}
			
		}
		
		public function makeColor(r:Number)
		{
			var base:Number = 0xFF;
			var color:Number = base * 0x010101;
			if(r <= 1/6) // 赤→赤緑
			{
				color = base * 0x010000 + int(base * r / (1/6)) * 0x000100;
				return color;
			}
			else if(r <= 2/6) // 赤緑→緑
			{
				color = base * 0x000100 - int(base * (r-1/6) / (1/6)) * 0x010000;
				return color;
			}
			else if(r <= 3/6) // 緑→緑青
			{
				color = base * 0x000100 + int(base * (r-2/6) / (1/6)) * 0x000001;
				return color;
			}
			else if(r <= 4/6) // 緑青→青
			{
				color = base * 0x000101 - int(base * (r-3/6) / (1/6)) * 0x000100;
				return color;
			}
			else if(r <= 5/6) // 青→青赤
			{
				color = base * 0x000001 + int(base * (r-4/6) / (1/6)) * 0x010000;
				return color;
			}
			else// 青赤→赤
			{
				color = base * 0x010001 - int(base * (r-5/6) / (1/6)) * 0x000001;
				return color;
			}
			
		}
		
		public function tagSelect(tag:String,color:Number)
		{
			var nodes:Array = this._tagNode[tag];
			for(var i=0;i<nodes.length;i++){
				nodes[i].setBack(color);
			}
		}
		
		public function tagUnselect(tag:String){
			var nodes:Array = this._tagNode[tag];
			for(var i=0;i<nodes.length;i++){
				nodes[i].clearBack();
			}
		}
		
		private function createHelpBox()
		{
			this._hb = new HelpBox();
			this.addChild(this._hb);
			this._hb.x = root.loaderInfo.width - 240;
			//hb.y = root.loaderInfo.height - 240;
			//this._hb.x = 10;
			this._hb.y = 10;
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
		}
		
		private function getTweet(name:String)
		{
			//this.init("obama");
			var query:String = escapeMultiByte(name);
			var xmlURL:String = "http://bosho3-ohma.ddo.jp/crossdomain-proxy.php?a=" + getTimer() + "&url=http://search.twitter.com/search.atom?q=" + query;
			var xmlLoader = new URLLoader();
			xmlLoader.addEventListener(Event.COMPLETE,parseTwitter);
			xmlLoader.load(new URLRequest(xmlURL));
		}
		
		private function parseTwitter(event:Event)
		{
			default xml namespace = atom; 
			var xml:XML = new XML(event.target.data);
			trace(xml);
			var nodeList:XMLList = xml.entry;
			for (var i = 0; i < nodeList.length(); i++) {
				var node = nodeList[i];
				var tweet = node.title;
				trace(tweet);
			/*	
				if(nodeList[i].@depth>this._maxStep)continue;
				var d:Number = Number(nodeList[i].@depth) + this._depthBase;
				var obj:Object = new Object();
				obj._id = nodeList[i].@id;
				obj._nid = nodeList[i].@nid;
				// チェック済みじゃないものは、ノードを登録
				if (this._checkNode[obj._id]==undefined){
					this._checkNode[obj._id] = true;
					obj.depth  = d;
					obj.name   = nodeList[i].@name;
					obj.keyword = nodeList[i].@keyword;
					obj.parent = nodeList[i].@from;
					obj.pnid = nodeList[i].@pnid;
				}
			*/	
			}
		}
		
    }
}