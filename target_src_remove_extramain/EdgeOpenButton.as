package network.component{
    import flash.display.SimpleButton;
    import flash.display.MovieClip;
    import flash.events.MouseEvent;
    import tmbutil.TmbMovieClip;

    public class EdgeOpenButton extends SimpleButton{

        ///// コンストラクタ
        function EdgeOpenButton(){
            this.create();
        }

        public function create()
        {	
            addEventListener(MouseEvent.CLICK, mouseClickHandler);

            // マウスオーバー時に手の形を変更する。面倒！
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
            hnb.edgeOpen();
            //removeEventListener(MouseEvent.CLICK,mouseClickHandler);
        }
    }
}
