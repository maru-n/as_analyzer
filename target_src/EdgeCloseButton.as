package network.component{
	import flash.display.SimpleButton;
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import tmbutil.TmbMovieClip;
	
    public class EdgeCloseButton extends SimpleButton{
	
		///// コンストラクタ
        function EdgeCloseButton(){
			this.create();
		}
		
		public function create()
		{	
			addEventListener(MouseEvent.CLICK,mouseClickHandler);
		}
		
		public function mouseClickHandler(event:MouseEvent){
			var hnb:MovieClip = parent as MovieClip;
			hnb.edgeClose();
		}
	}
}