package com.hisschemoller.view 
{
	import com.hisschemoller.AppFacade;
	import com.hisschemoller.model.AudioDriverProxy;
	import com.hisschemoller.model.vo.AudioStreamInfoVO;
	import com.hisschemoller.view.components.Ball;
	import com.hisschemoller.view.components.BallPanel;

	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;

	import flash.events.Event;

	/**
	 * @author wouter.hisschemoller
	 * (c) Lost Boys Feb 9, 2010
	 */
	public class BallPanelMediator extends Mediator implements IMediator 
	{
		public static const NAME : String = "TestPanelMediator";

		public function BallPanelMediator(viewComponent : Object = null)
		{
			super(NAME, viewComponent);
		}

		/**
		 * 
		 */
		override public function listNotificationInterests() : Array
		{
			return [ AppFacade.STARTUP_DONE,
					 AudioDriverProxy.ENTER_FRAME ];
		}

		/**
		 * 
		 */
		override public function handleNotification(notification : INotification) : void
		{
			switch(notification.getName())
			{
				case AppFacade.STARTUP_DONE:
					panel.start();
					break;
				case AudioDriverProxy.ENTER_FRAME:
					panel.enterFrame(AudioStreamInfoVO(notification.getBody()));
					break;
			}
		}

		/**
		 * 
		 */
		override public function onRegister() : void
		{
			var ball : Ball = panel.addBall(80, 60, 15, 380, 0);
			facade.registerMediator(new BallMediator("ball0", ball));
			
			ball = panel.addBall(160, 100, 25, 380, 1);
			facade.registerMediator(new BallMediator("ball1", ball));
			
			ball = panel.addBall(240, 320, 40, 380, 2);
			facade.registerMediator(new BallMediator("ball2", ball));
			
			ball = panel.addBall(320, 150, 15, 380, 3);
			facade.registerMediator(new BallMediator("ball3", ball));
			
			panel.addEventListener(BallPanel.PLAY_ON, panelEventHandler);
			panel.addEventListener(BallPanel.PLAY_OFF, panelEventHandler);
		}
		
		/**
		 * 
		 */
		private function panelEventHandler(event : Event) : void
		{
			switch(event.type)
			{
				case BallPanel.PLAY_ON:
					facade.sendNotification(AppFacade.PLAY);
					break;
				case BallPanel.PLAY_OFF:
					facade.sendNotification(AppFacade.STOP);
					break;
			}
		}

		/**
		 * 
		 */
		private function get panel() : BallPanel
		{
			return viewComponent as BallPanel;
		}
	}
}
