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
	
    public class MainLove extends Main {
	
		public var _isLove = true;

		///// コンストラクタ
        function MainLove(){
		}
		
		///// メソッド
		
		/*
		* XMLデータの読み込み
		*/
		override public function loadData()
		{
			var loader:URLLoader = new URLLoader();			
			var url:String = this._url + this._hid1 + "/" + this._hid2 + "/" + getTimer();
			if (this._isDebugOn) url = this._url;
			//if(!this._isDebugOn) url = this._url + "?hid=" + this._hid + "&a=" + getTimer();
			//if(!this._isDebugOn) url = this._url + this._hid + "/" + getTimer();
			var request:URLRequest = new URLRequest(url);
			loader.addEventListener(Event.COMPLETE,startCreate);
			loader.load(request);
			this._checkMainNode[this._hid]=true;	
		}
		
		override public function loadExtraData(hid:Number)
		{
			
		}
		
    }
}