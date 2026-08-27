package com.hisschemoller.view 
{
	import com.hisschemoller.AppFacade;
	import com.hisschemoller.model.AudioDriverProxy;
	import com.hisschemoller.model.vo.AudioStreamInfoVO;
	import com.hisschemoller.utils.midi.MidiNoteOnVO;
	import com.hisschemoller.view.components.Ball;

	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;

	import flash.events.Event;

	/**
	 * @author wouter.hisschemoller
	 * (c) Lost Boys Feb 9, 2010
	 */
	public class BallMediator extends Mediator implements IMediator 
	{
		public function BallMediator(mediatorName : String = null, viewComponent : Object = null)
		{
			super(mediatorName, viewComponent);
		}

		/**
		 * 
		 */
		override public function listNotificationInterests() : Array
		{
			return [ AudioDriverProxy.ENTER_BUFFER, 
					 AudioDriverProxy.ENTER_FRAME];
		}

		/**
		 * 
		 */
		override public function handleNotification(notification : INotification) : void
		{
			switch(notification.getName())
			{
				case AudioDriverProxy.ENTER_BUFFER:
					ball.enterBuffer();
					break;
				case AudioDriverProxy.ENTER_FRAME:
					ball.enterFrame(AudioStreamInfoVO(notification.getBody()));
					break;
			}
		}

		/**
		 * 
		 */
		override public function onRegister() : void
		{
			ball.addEventListener(Ball.BOUNCE, ballBounceHandler);
		}
		
		/**
		 * 
		 */
		private function ballBounceHandler(event : Event) : void
		{
			var noteOnVO : MidiNoteOnVO = new MidiNoteOnVO();
			noteOnVO.channel = ball.midiChannel;
			noteOnVO.pitch = 84;//60;
			noteOnVO.velocity = 100;
			noteOnVO.deltaTime = ball.hitAlpha * AudioDriverProxy.BUFFER_DURATION_MS;
			
			facade.sendNotification(AppFacade.MIDI_IN, noteOnVO);
		}

		/**
		 * 
		 */
		private function get ball() : Ball
		{
			return viewComponent as Ball;
		}
	}
}
