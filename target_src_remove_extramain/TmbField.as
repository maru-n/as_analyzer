package tmbutil{
	/**
	* 友部用フィールド基本クラス
	* ズームインとか、ズームアウトとかの機能も付ける予定。
	**/
	import flash.events.Event;
	import tmbutil.TmbUtil;
	import tmbutil.TmbMovieClip;
	
    public class TmbField extends TmbMovieClip{
		
		// コンストラクタ？
        function TmbField(){
		}
				
		/**
		* 中心点を維持してズームする。
		* z: 倍率（scaleX,scaleY）、(x,y)座標
		**/
		public function zoomField1(z:Number,x:Number,y:Number){
			var mc:TmbMovieClip = this;
			var gx:Number = x + (mc.x - x) * z / mc.scaleX;
			var gy:Number = y + (mc.y - y) * z / mc.scaleY;
            mc.scaleX = z;
            mc.scaleY = z;
            mc.x = gx;
            mc.y = gy;
		}
		public function zoomField(z:Number,x:Number,y:Number,func:Function,param:Array,no_overrun:Boolean = false){
			var mc:TmbMovieClip = this;
                        var overrun = 0.1; // if you don't want to overrun, put 1.0.
                        if (no_overrun) overrun = 1.0;
                        var z = z * overrun;
			var gx:Number = x + (mc.x - x) * z / mc.scaleX;
			var gy:Number = y + (mc.y - y) * z / mc.scaleY;
			var step = this._step;
                        var stop_flag = false;
			this.addEventListener( Event.ENTER_FRAME, function(){
				mc.scaleX += (z - mc.scaleX) / step;
				mc.scaleY += (z - mc.scaleY) / step;
				mc.x += (gx - mc.x) / step;
				mc.y += (gy - mc.y) / step;
				if(TmbUtil.isNear(mc.scaleX,z,1) && TmbUtil.isNear(mc.scaleY,z,1)){
                                    if (stop_flag) {
					mc.scaleX = z;
					mc.scaleY = z;
					mc.x = gx;
					mc.y = gy;
					if(func!=null)func.apply(null,param);
					mc.removeEventListener(Event.ENTER_FRAME, arguments.callee);
                                    } else {
                                        z = z / overrun;
                                        gx = x + (gx - x) / overrun;
                                        gy = y + (gy - y) / overrun;
                                        stop_flag = true;
                                    }
				}
			});
		}
		public function slideField(xStep:Number, yStep:Number, func:Function, param:Array)
		{
			var x:Number = this._stageWidth * xStep + this.x;
			var y:Number = this._stageHeight * yStep + this.y;
			super.moveMC(x,y,func,param);
		}
		
		
		/**
		* 以下、テスト用
		* 
		*/
		private function test()
		{
			this._step = 10;
			this._stageHeight = 400;
			this._stageWidth  = 550;
			this.zoomField(2,100,100,super.moveMC,[100,100,zoomField,[1,100,100,null,null]]);
		}
    }
}
