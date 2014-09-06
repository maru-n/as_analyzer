package tmbutil{

    import flash.display.Graphics;
    import flash.display.Sprite;
    import flash.display.MovieClip;
    import flash.events.MouseEvent;
    import flash.text.TextField;
    import tmbutil.GraphicsLib;
    import tmbutil.TmbMovieClip;

    public class Pie extends TmbMovieClip {
        public var _count:Number = 0;
        public var _tag:String;

        private var _r1:Number;
        private var _r2:Number;
        private var _t1:Number;
        private var _t2:Number;
        private var _color:Number;
        public var _defaultX:Number;
        public var _defaultY:Number;

        private var _isMoving:Boolean = false;
        private var _isOnMouse:Boolean = false;
        private var _isClicked:Boolean = false;
        private var _parent:MovieClip;

        private var _click_bomb:Boolean = false;

        public function Pie(r1 : Number, r2 : Number, t1 : Number, t2 : Number, color : uint = 0x000000, alpha : Number = 1.0) {
            var g:Graphics = graphics;
            g.beginFill(color, alpha);
            GraphicsLib.drawPie(g, 0, 0, r1, t1, t2, false);
            GraphicsLib.drawPie(g, 0, 0, r2, t2, t1, true);
            g.endFill();
            //this.addEventListener(MouseEvent.ROLL_OVER, pieRollOver);
            //this.addEventListener(MouseEvent.ROLL_OUT, pieRollOut);
            this.addEventListener(MouseEvent.CLICK, pieClick);
            //this.buttonMode = true;

            var r:Number = r2 * 3 /4;
            var t:Number = (t1 + t2) / 2;
            this._tagInfo.x = Math.cos(t) * r;
            this._tagInfo.y = Math.sin(t) * r;
            this._tagInfo.alpha = 0;
            this._tagInfo._tagText.text = "";
            this._tagInfo._tagNum.text = "";
            this._r1 = r1;
            this._r2 = r2;
            this._t1 = t1;
            this._t2 = t2;
            this._color = color;
            this._step = 2;
        }

        public function createInfo()
        {
            this._tagInfo.alpha = 1;
            this.mouseChildren = false;
            this._tagInfo._tagText.text = this._tag;
            this._tagInfo._tagNum.text = this._count + " %";
        }

        private function pieRollOver(event:MouseEvent)
        {
            this._isOnMouse = true;
            if(this._isMoving)return;
            this.rollOverAction();
        }

        private function rollOverAction(){
            this._isMoving = true;
            var r:Number = this._r1;
            var t:Number = (this._t1 + this._t2) / 2;
            var x:Number = Math.cos(t) * r + this._defaultX;
            var y:Number = Math.sin(t) * r + this._defaultY;
            var p = parent as MovieClip;
            p.tagSelect(this._tag,this._color);
            this.moveMC(x,y,MoveFinish1,null);
        }

        private function pieRollOut(event:MouseEvent)
        {
            this._isOnMouse = false;
            if(this._isMoving)return;
            this.rollOutAction()
        }

        private function rollOutAction(){
            this._isMoving = true;
            this.moveMC(this._defaultX, this._defaultY, MoveFinish2, null);
            var p = parent as MovieClip;
            p.tagUnselect(this._tag);
        }

        private function MoveFinish1()
        {
            this._isMoving = false;
            if(!this._isOnMouse ){
                this.rollOutAction();
            }
        }

        private function MoveFinish2()
        {
            this._isMoving = false;
            if(this._isOnMouse ){
                this.rollOverAction();
            }
        }

        private function pieClick(event:MouseEvent)
        {
            if (_click_bomb) {
                this._parent = parent as MovieClip;
                this._parent.tagUnselect(this._tag);
                this.graphics.clear();
            }
        }
    }
}
