package network.component{
    import flash.display.MovieClip;

    public class HelpBox extends MovieClip{

        private var _isOpen:Boolean = false;
        ///// コンストラクタ
        function HelpBox(){
        }

        public function create()
        {
            this._isOpen = false;
            this.gotoAndPlay("close");
        }

        public function deleteHelpBox()
        {
            var p = parent as MovieClip;
            p.deleteHelpBox();
        }

        public function changeHelpBox()
        {
            if (this._isOpen) {
                this.closeHelpBox();
            }else {
                this.openHelpBox();
            }
        }

        public function closeHelpBox()
        {
            this._isOpen = false;
            this.gotoAndPlay("close");
            var p = parent as MovieClip;
            if (p._optionPosition == "right") {
                this.x = root.loaderInfo.width - 240;
                this.y = root.loaderInfo.height - 30;
            }else {
                this.x = -120;
                this.y = root.loaderInfo.height - 30
            }
        }

        public function openHelpBox()
        {
            this._isOpen = true;
            this.gotoAndPlay("open");
            var p = parent as MovieClip;
            if (p._optionPosition == "right") {
                this.x = root.loaderInfo.width - 240;
                this.y = root.loaderInfo.height - 250;
            }else{
                this.x = 10;
                this.y = root.loaderInfo.height - 250;
            }
            var lastIndex:int = p.numChildren - 1;
            p.setChildIndex(this, lastIndex);
        }
    }
}
