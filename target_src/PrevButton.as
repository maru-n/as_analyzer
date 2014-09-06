package network.component{
    import flash.display.SimpleButton;
    import flash.display.MovieClip;
    import flash.events.MouseEvent;
    import tmbutil.TmbMovieClip;

    public class PrevButton extends SimpleButton{

        ///// コンストラクタ
        function PrevButton(){
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
            hnb.loadImages();
            hnb.changeMouseCursorClick();
        }

        public function mouseRollOutHandler(event:MouseEvent)
        {
            var hnb:MovieClip = parent as MovieClip;
            hnb.changeMouseCursorHand();
        }

        public function mouseClickHandler(event:MouseEvent){
            var hnb:MovieClip = parent as MovieClip;
            //trace("firstImage: "+hnb.firstImage);
            if (hnb.images.length > 0) {
                hnb.images[hnb.firstImage].alpha = 0;
                hnb.firstImage = (hnb.firstImage + 1 + hnb.images.length) % hnb.images.length;
                hnb.images[hnb.firstImage].alpha = 100;
            }
            
            //trace("firstImage: "+this.firstImage);
            //removeEventListener(MouseEvent.CLICK,mouseClickHandler);
        }
    }
}
