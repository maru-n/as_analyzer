package network{
    import flash.display.MovieClip;
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.text.TextField;
	import flash.display.LoaderInfo;
	
	import network.field.NetworkField;
	import network.field.ControlField;
	import network.component.ZoomPanel;
	import network.component.HelpBox;
	import tmbutil.Pie;
	import network.component.GripHandCursor;
	import network.component.ClickMask;
	import network.component.LoadingMark;
	import network.field.ProductItemField;
	import flash.utils.getTimer;

	import network.Main;
	///// ネットワーク図の基本はこれ。あとはパーツに応じて微調整する。
	
    public class MainProduct extends Main {
	
		///// コンストラクタ
        function MainProduct(){
		}
		
		///// メソッド
		
		/*
		* XMLデータの読み込み
		*/
		override public function loadData()
		{
			this._checkMainNode[this._hid] = true;
			var url:String = this._url + "?asin=" + this._hid + "&a=" + getTimer();
			var loader:URLLoader = new URLLoader();			
			var request:URLRequest = new URLRequest(url);
			loader.addEventListener(Event.COMPLETE,startCreate);
			loader.load(request);
		}
		
		override public function loadExtraData(hid:Number)
		{
			if(this._checkMainNode[hid]!=undefined)return;
			this._depthBase = this._nf._maxDepth;
			var loader:URLLoader = new URLLoader();
			var url:String = this._extendUrl + "?asin=" + hid + "&a=" + getTimer();
			var request:URLRequest = new URLRequest(url);
			loader.addEventListener(Event.COMPLETE,startExtend);
			loader.load(request);
			this._checkMainNode[hid]=true;
		}
		
		
		/*
		* XMLデータを変換
		*/
		/*
		override public function startCreate(event:Event)
		{
			var xml:XML = new XML(event.target.data);
			trace(xml);
			this.parseXML(xml);
			this.create();
		}
		*/
		/*
		private function startExtend(event:Event)
		{
			var xml:XML = new XML(event.target.data);
			this.parseXML(xml);
			this._nf.extendStartOpen();
		}
		*/
		override public function parseXML(xml:XML)
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
					obj.amazon_url = nodeList[i].@amazon_url;
					obj.release_date = nodeList[i].@release_date;
					obj.label = nodeList[i].@label;
					obj.amount = nodeList[i].@amount;
					obj.rate = nodeList[i].@rate;
					obj.category = nodeList[i].@tags;
					var tags:String = nodeList[i].@tags;
					var tagArray:Array = tags.split(",");
					obj.tags = tagArray;
					this._humanInfoArray.push(obj);	
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
				link.edge_keyword = nodeList[i].@edge_keyword;
				this._linkInfoArray.push(link);
			}
			//this._debug.text = String(c);
			//this._debug.text = String(this._linkInfoArray.length);
		}
		
		
		
		/**
		* 各フィールドを作る
		*/
		
		override public function create()
		{
			super.create();
			if (this._isMovableOn) {
				this.createHistoryField();
				this.createProductItemField();
				this.createFirstMessage();
			}
		}

		private function createProductItemField()
		{
			if (this._pf == null && this._isRestart) {
				this._pf = new ProductItemField();
				this.addChild(this._pf);
				this._pf.create();
				this._pf.changeItem(this._mainObj);
				//this._pf.x = root.loaderInfo.width - 230;
				this._pf.x = root.loaderInfo.width;
				//this._pf.y = 10;
				this._pf.y = 60;
				this._pf.moveMC(this._pf.x - 230, 60, null, null);
			}
		}
		
		/*
		* ネットワーク表示用フィールドを作成する 
		*/
		/*
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
		*/
		/*
		* 操作用のフィールドを作成する
		*/
		/*
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
				if(count<2){
					otherNum += count;
				}else{
					var t1 = t2;
					t2 += Math.PI * 2 * count / totalNum;
					
					var color:Number = this.makeColor(tmpNum / totalNum);

					tmpNum += count;
					var pie:Pie = new Pie(this._r1,this._r2,t1,t2,color, 0.5);
					pie._defaultX = 110;
					pie._defaultY = 110;
					pie.x = 110;
					pie.y = 110;
					//pie._count = count;
					pie._count = Math.ceil(count / totalNum * 100);
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
			var pie2:Pie = new Pie(this._r1,this._r2,t,t2,color2, 0.5);
			pie2._defaultX = 110;
			pie2._defaultY = 110;
			pie2.x = 110;
			pie2.y = 110;
			//pie2._count = otherNum;
			pie2._count = Math.ceil(otherNum / totalNum * 100);
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
			trace("tagSelect:" + tag);
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
			this._hb.create();
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
		
		private function createLoadingMark()
		{
			this._lm = new LoadingMark();
			this.addChild(this._lm);
			this._lm.x = this.stage.stageWidth / 2;
			this._lm.y = this.stage.stageHeight / 2;
		}
		
		private function deleteLoadingMark()
		{
			this.removeChild(this._lm);
		}
		*/

    }
}