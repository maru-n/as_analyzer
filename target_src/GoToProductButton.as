package network.component{
	import flash.display.MovieClip;
	import flash.display.SimpleButton;
	import flash.events.MouseEvent;
	
    public class GoToProductButton extends SimpleButton{
	
		///// コンストラクタ
        function GoToProductButton() {
			this.create();
		}
		
		private function create()
		{
			//this.buttonMode = true;
			this.addEventListener(MouseEvent.CLICK, clickAction);
		}
		
		private function clickAction(event:MouseEvent){
			//クリック時の動作
			var p = parent as MovieClip;
			p.gotoProduct();
		}
	}
}