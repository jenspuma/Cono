package com.hisschemoller.controller 
{
	import com.hisschemoller.AppFacade;
	import com.hisschemoller.model.AudioDriverProxy;

	import org.puremvc.as3.interfaces.ICommand;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;

	/**
	 * @author wouter.hisschemoller
	 * (c) Lost Boys Feb 10, 2010
	 */
	public class ControlsCommand extends SimpleCommand implements ICommand 
	{
		override public function execute(notification : INotification) : void
		{
			switch(notification.getName())
			{
				case AppFacade.PLAY:
					AudioDriverProxy(facade.retrieveProxy(AudioDriverProxy.NAME)).play();
					break;
				case AppFacade.STOP:
					AudioDriverProxy(facade.retrieveProxy(AudioDriverProxy.NAME)).stop();
					break;
			}
		}
	}
}
