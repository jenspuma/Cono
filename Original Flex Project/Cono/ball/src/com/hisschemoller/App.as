package com.hisschemoller 
{
	import com.hisschemoller.view.components.Alert;
	import com.hisschemoller.view.components.BallPanel;

	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageQuality;
	import flash.display.StageScaleMode;

	/**
	 * @author Wouter Hisschemoller
	 * (c) Jan 20, 2010
	 */
	public class App extends Sprite 
	{
		public var _panel : BallPanel;
		public var _alert : Alert;

		public function App()
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.quality = StageQuality.BEST;
			stage.showDefaultContextMenu = false;
			
			initUI();
			initPureMVC();
		}

		/**
		 * 
		 */
		private function initUI() : void
		{
			_panel = new BallPanel(this);
			_panel.setSize(400, 400);
			
			_alert = new Alert(this);
		}

		/**
		 * 
		 */
		private function initPureMVC() : void
		{
			AppFacade.getInstance().startup(this);
		}
	}
}
