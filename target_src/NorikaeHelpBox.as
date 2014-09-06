package network.component{
	import flash.display.MovieClip;
	
    public class NorikaeHelpBox extends MovieClip{
	
		///// コンストラクタ
        function NorikaeHelpBox(){
		}
		
		public function deleteHelpBox()
		{
			var p = parent as MovieClip;
			p.deleteNorikaeHelpBox();
		}
	}
}