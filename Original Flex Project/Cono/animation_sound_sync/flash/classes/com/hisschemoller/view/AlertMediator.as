package com.hisschemoller.view 
{
	import com.hisschemoller.AppFacade;
	import com.hisschemoller.model.vo.AlertVO;
	import com.hisschemoller.view.components.Alert;

	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;

	/**
	 * @author Wouter Hisschemoller
	 * (c) Jan 23, 2010
	 */
	public class AlertMediator extends Mediator implements IMediator 
	{
		public static const NAME : String = "AlertMediator";

		public function AlertMediator(viewComponent : Object = null)
		{
			super(NAME, viewComponent);
		}

		/**
		 * 
		 */
		override public function listNotificationInterests() : Array
		{
			return [ AppFacade.ALERT ];
		}

		/**
		 * 
		 */
		override public function handleNotification(notification : INotification) : void
		{
			switch(notification.getName())
			{
				case AppFacade.ALERT:
					if(!(notification.getBody() is AlertVO))
					{
						alert.show("Error", "Illegal alert call.");
					}
					else
					{
						var alertVO : AlertVO = notification.getBody() as AlertVO;
						alert.show(alertVO.header, alertVO.message);
					}
					break;
			}
		}

		/**
		 * 
		 */
		private function get alert() : Alert
		{
			return viewComponent as Alert;
		}
	}
}
