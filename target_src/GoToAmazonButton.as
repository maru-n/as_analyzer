package network.component{
	import flash.display.SimpleButton;
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	
    public class GoToAmazonButton extends SimpleButton{
	
		///// コンストラクタ
        function GoToAmazonButton() {
			this.create();
			trace("oh!amazon");
		}
		
		private function create()
		{
			//this.buttonMode = true;
			this.addEventListener(MouseEvent.CLICK, clickAction);
		}
		
		private function clickAction(event:MouseEvent) {
			trace("amazon");
			//クリック時の動作
			var p = parent as MovieClip;
			p.gotoAmazon();
		}
	}
}