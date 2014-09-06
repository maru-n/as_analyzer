package tmbutil{
	/**
	* 友部用フィールド基本クラス
	* ズームインとか、ズームアウトとかの機能も付ける予定。
	**/
    import flash.display.MovieClip;
	import flash.events.Event;
	import tmbutil.TmbUtil;
	
    public class TmbMovieClip extends MovieClip{
		public var _stageHeight:Number;
		public var _stageWidth :Number;
		
		public var _step:Number = 5;
		// コンストラクタ？
        function TmbMovieClip(){
		}
		
		/**
		* アルファを変更する
		*/
		public function changeAlpha(a:Number,func:Function,param:Array)
		{
			var mc:TmbMovieClip = this;
			this.addEventListener( Event.ENTER_FRAME, function(){
				mc.alpha += (a - mc.alpha) / mc._step;
				if(TmbUtil.isNear(mc.alpha,a,2)){
					mc.alpha = a;
					if(func!=null) if(param!=null){func.apply(null,a);}else{func.call();}
					mc.removeEventListener(Event.ENTER_FRAME, arguments.callee);
				}
			});
		}
		
		public function moveMC(x:Number,y:Number,func:Function,param:Array)
		{
			var mc:TmbMovieClip = this;
			mc.mouseChildren = false;
			var preX = mc.x;
			var preY = mc.y;
			this.addEventListener( Event.ENTER_FRAME, function(){
				var gapX = (x - mc.x) / mc._step;
				var gapY = (y - mc.y) / mc._step;
				mc.x += gapX;
				mc.y += gapY;
				if(TmbUtil.isNear(mc.x,x,20) && TmbUtil.isNear(mc.y,y,20)){
					mc.x = x;
					mc.y = y;
					if (func != null) func.apply(null, param);
					mc.mouseChildren = true;
					mc.removeEventListener(Event.ENTER_FRAME, arguments.callee);
				}
				if(mc.x == preX && mc.y == preY){
					mc.x = x;
					mc.y = y;
					if (func != null) func.apply(null, param);
					mc.mouseChildren = true;
					mc.removeEventListener(Event.ENTER_FRAME, arguments.callee);
				}
				preX = mc.x;
				preY = mc.y;
				//trace(mc.x + ":" + mc.y);
			});
		}
    }
}