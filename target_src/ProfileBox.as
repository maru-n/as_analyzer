package network.component{
    import flash.display.MovieClip;

    public class ProfileBox extends MovieClip{

        public var _isOpen:Boolean;
        ///// コンストラクタ
        function ProfileBox(){
        }

        public function create()
        {
            this._isOpen = false;
            this.visible = false;
        }

        public function changeProfileBox()
        {
            if (this._isOpen) {
                this._isOpen = false;
                //this.gotoAndStop("close");
                this.visible = false;
            } else {
                this._isOpen = true;
                //this.gotoAndStop("open");
                this.visible = true;
            }
        }

    }
}
