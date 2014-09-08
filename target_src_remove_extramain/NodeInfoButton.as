package network.component{
    import flash.display.SimpleButton;
    import flash.display.MovieClip;
    import flash.events.MouseEvent;
    import tmbutil.TmbMovieClip;
	import flash.net.URLVariables;
    import flash.external.ExternalInterface;

    public class NodeInfoButton extends SimpleButton{

        ///// コンストラクタ
        function NodeInfoButton(){
            this.create();
        }

        public function create()
        {	
            addEventListener(MouseEvent.CLICK, mouseClickHandler);
            addEventListener(MouseEvent.MOUSE_OVER, mouseRollOverHandler);
            addEventListener(MouseEvent.MOUSE_OUT, mouseRollOutHandler);
        }

        public function mouseRollOverHandler(event:MouseEvent)
        {
            var hnb:MovieClip = parent as MovieClip;
            hnb.changeMouseCursorClick();
        }

        public function mouseRollOutHandler(event:MouseEvent)
        {
            var hnb:MovieClip = parent as MovieClip;
            hnb.changeMouseCursorHand();
        }

        public function mouseClickHandler(event:MouseEvent){
            var hnb:MovieClip = parent as MovieClip;
            var main = hnb.getMain();
            if (!main._isDebugOn) {
                ExternalInterface.call("toggle_chart", hnb._obj._id);
                var variables:URLVariables = new URLVariables();  
                variables.action = "click_nib";
                variables.data = "human_id:"+hnb._obj._id+",x:"+stage.mouseX+",y:"+stage.mouseY;
                hnb._nf._parent.sendLog(variables);
            }
        }
    }
}
