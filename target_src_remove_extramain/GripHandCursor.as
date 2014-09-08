package network.component{
	import flash.display.Bitmap;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.ui.Mouse;

	/**
	 * 握るハンドカーソル
	 * @author yuu
	 * @url http://air-life.info
	 */
	public class GripHandCursor extends Sprite
	{
		[Embed(source = 'image/openHand.png')]
		private var OpenHand:Class;
		[Embed(source = 'image/gripHand.png')]
		private var GripHand:Class;

		private var container:Sprite = new Sprite();
		private var openhand:Bitmap;
		private var griphand:Bitmap;

		public function GripHandCursor():void {
			this.mouseEnabled = container.mouseEnabled = false;
			addChild(container);

			openhand = new OpenHand();
			griphand = new GripHand();

			openhand.x = - openhand.width / 2;
			openhand.y = - openhand.height / 2;
			griphand.x = - griphand.width / 2;
			griphand.y = - griphand.height / 2;

			container.addChild(openhand);
			container.addChild(griphand);
			openhand.visible = false;
			griphand.visible = false;

			addEventListener(Event.ADDED , onAdded);
		}
		private function onAdded(e:Event):void {
			removeEventListener(Event.ADDED , onAdded);
			addEventListener(Event.ENTER_FRAME, chase);
		}
		private function chase(e:Event):void {
			if (stage) {
				this.x = stage.mouseX;
				this.y = stage.mouseY;
			}
		}
		public function open(e:MouseEvent=null):void {
			Mouse.hide();
			highestDepth(this);
			openhand.visible = true;
			griphand.visible = false;
		}
		public function grip(e:MouseEvent=null):void {
			openhand.visible = false;
			griphand.visible = true;
		}
		public function hide(e:MouseEvent=null):void {
			Mouse.show();
			openhand.visible = false;
			griphand.visible = false;
		}
		public function setHandTarget(target:DisplayObject):void {
			target.addEventListener(MouseEvent.ROLL_OVER, open);
			target.addEventListener(MouseEvent.ROLL_OUT, hide);
			target.addEventListener(MouseEvent.MOUSE_DOWN, grip);
			target.addEventListener(MouseEvent.MOUSE_UP, open);
		}
		public function removeHandTarget(target:DisplayObject):void {
			target.removeEventListener(MouseEvent.ROLL_OVER, open);
			target.removeEventListener(MouseEvent.ROLL_OUT, hide);
			target.removeEventListener(MouseEvent.MOUSE_DOWN, grip);
			target.removeEventListener(MouseEvent.MOUSE_UP, open);
		}
		private function highestDepth(target:DisplayObject):void {
			try {
				target.parent.setChildIndex(target,target.parent.numChildren-1);
			}catch(e:RangeError) {
				trace(e);
			}
		}
	}
}
