package tmbutil{
	/**
	* 友部用計算基本クラス
	**/
	
    public class TmbUtil{
	
		/**
		* aとbがcの5％以内か調べる
		* 
		* 
		*/
		public static function isNear(a:Number, b:Number, c:Number)
		{
			// 前後１以内になったらtrueを返す
			var bMin:Number = b - c * 0.01;
			var bMax:Number = b + c * 0.01;
			
			if(bMin < a && a < bMax){
				return true;
			}else{
				return false;
			}
		}
		
		
    }
}