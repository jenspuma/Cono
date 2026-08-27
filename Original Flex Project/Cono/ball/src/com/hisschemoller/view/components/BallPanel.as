package com.hisschemoller.view.components 
{
	import com.bit101.components.Label;
	import com.bit101.components.Meter;
	import com.bit101.components.Panel;
	import com.bit101.components.PushButton;
	import com.hisschemoller.model.vo.AudioStreamInfoVO;

	import flash.display.DisplayObjectContainer;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.MouseEvent;

	/**
	 * @author wouter.hisschemoller
	 * (c) Lost Boys Feb 9, 2010
	 */
	public class BallPanel extends Panel 
	{
		public static const PLAY_ON : String = "playOn";
		public static const PLAY_OFF : String = "playOff";
		public static const GRAVITY_SLIDER : String = "gravitySlider";
		private var _playButton : PushButton;
		private var _latencyLabel : Label;
		private var _meterL : Meter;
		private var _meterR : Meter;
		private var _floor : Shape;
		private var _floorY : Number = 380;

		public function BallPanel(parent : DisplayObjectContainer = null, xpos : Number = 0, ypos : Number = 0)
		{
			super(parent, xpos, ypos);
		}

		/**
		 * 
		 */
		public function addBall(x : Number, y : Number, radius : Number, floorY : Number, midiChannel : int) : Ball
		{
			var ball : Ball = new Ball(this);
			ball.setProperties(x, y, radius, floorY, midiChannel);
			
			return ball;
		}
		
		/**
		 * 
		 */
		public function start() : void
		{
			visible = true;
		}

		/**
		 * Display audio info.
		 */
		public function enterFrame(infoVO : AudioStreamInfoVO) : void
		{
			_latencyLabel.text = "Latency: " + infoVO.latencyInMS.toFixed(2) + " ms.";
			_meterL.value = infoVO.peakLevelLeft * 10;
			_meterR.value = infoVO.peakLevelRight * 10;
		}

		/**
		 * Creates and adds the child display objects of this component.
		 */
		override protected function addChildren() : void
		{
			super.addChildren();
			
			_playButton = new PushButton(this, 320, 20, "Play", playButtonHandler);
			_playButton.width = 50;
			_playButton.toggle = true;
			
			_latencyLabel = new Label(this, 20, 250);
			
			_meterL = new Meter(this, 20, 20, "left channel");
			_meterR = new Meter(this, 20, 140, "right channel");
			
			_floor = new Shape();
			_floor.graphics.lineStyle(2, 0xFFFFFF);
			_floor.graphics.moveTo(20, _floorY);
			_floor.graphics.lineTo(380, _floorY);
			addChild(_floor);
			
			visible = false;
		}

		/**
		 * 
		 */
		private function playButtonHandler(event : MouseEvent) : void
		{
			if(_playButton.selected) dispatchEvent(new Event(BallPanel.PLAY_ON));
			else dispatchEvent(new Event(BallPanel.PLAY_OFF));
		}
	}
}
