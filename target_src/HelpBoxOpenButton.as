package network.component{
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	
    public class HelpBoxOpenButton extends MovieClip{
	
		///// コンストラクタ
        function HelpBoxOpenButton() {
			this.create();
		}
		
		private function create()
		{
			this.buttonMode = true;
			this.addEventListener(MouseEvent.CLICK, clickAction);
		}
		
		private function clickAction(event:MouseEvent){
			//クリック時の動作
			var p = parent as MovieClip;
			//p.deleteHelpBox();
			p.changeHelpBox();
		}
	}
}