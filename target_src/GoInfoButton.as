package network.component{
	import flash.display.SimpleButton;
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	
    public class GoInfoButton extends SimpleButton{
	
		///// コンストラクタ
        function GoInfoButton() {
			this.create();
			trace("oh!center");
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
			p.gotoInfo();
		}
	}
}