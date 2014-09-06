package network.field{
	import tmbutil.TmbField;
	import network.component.ProductItem;
	import flash.events.Event;
	
    public class ProductItemField extends TmbField{

		private var _pi:ProductItem;
		///// コンストラクタ
        function ProductItemField(){
		}
		
		public function create() {
			this.addEventListener(Event.REMOVED_FROM_STAGE, removeFunc);
		}
		
		private function removeFunc(e:Event) {
			this.removeEventListener(Event.ENTER_FRAME, moveMC);
		}
		
		public function changeItem(obj:Object)
		{
			if (this._pi != null) {
				this.removeChild(this._pi);
			}
			this._pi = new ProductItem;
			this.addChild(this._pi);
			this._pi._hid = obj._id;
			this._pi._name = obj.name;
			this._pi._url = obj.face_url;
			this._pi._amazon_url = obj.amazon_url;
			//this._pi._release_date = obj.release_date;
			//this._pi._label = obj.label;
			//this._pi._amount = obj.amount;
			//this._pi._category = obj.category;
			//this._pi.x = 100;
			//this._pi.y = 100;
			this._pi._rate = obj.rate;
			this._pi.create();
			
		}
		
    }
}