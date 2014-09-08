package network.component{
	import flash.display.SimpleButton;	
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import tmbutil.TmbMovieClip;
	
    public class NodeCloseButton extends SimpleButton{
	
		///// コンストラクタ
        function NodeCloseButton(){
			this.create();
		}
		
		public function create()
		{	
			addEventListener(MouseEvent.CLICK,mouseClickHandler);
		}
		
		public function mouseClickHandler(event:MouseEvent){
			var hnb:MovieClip = parent as MovieClip;
			hnb.nodeClose();
			removeEventListener(MouseEvent.CLICK,mouseClickHandler);
		}
	}
}