package com.hisschemoller.view.components 
{
	import assets.AlertAsset;

	import com.bit101.components.Component;
	import com.bit101.components.PushButton;

	import flash.display.DisplayObjectContainer;
	import flash.events.MouseEvent;
	import flash.text.TextField;

	/**
	 * @author Wouter Hisschemoller
	 * (c) Jan 23, 2010
	 */
	public class Alert extends Component 
	{
		private var _asset : AlertAsset;
		private var _closeButton : PushButton;
		private var _header : TextField;
		private var _body : TextField;

		public function Alert(container : DisplayObjectContainer = null)
		{
			super(container);
		}

		/**
		 * 
		 */
		public function show(header : String, message : String) : void
		{
			_asset.visible = true;
			_header.text = header;
			_body.htmlText = "<font size='13'>" + message + "</font>";
		}

		/**
		 * 
		 */
		public function hide() : void
		{
			_asset.visible = false;
		}

		/**
		 * 
		 */
		override protected function init() : void
		{
			super.init();
			hide();
		}

		/**
		 * 
		 */
		override protected function addChildren() : void
		{
			super.addChildren();
			
			_asset = new AlertAsset();
			
			_closeButton = new PushButton(_asset, 20, 200, "Close");
			_closeButton.addEventListener(MouseEvent.CLICK, handleCloseClick);
			
			_header = _asset.tHeader;
			_body = _asset.tBody;
		}

		/**
		 * 
		 */
		private function handleCloseClick(inEvent : MouseEvent) : void
		{
			hide();
		}
	}
}
