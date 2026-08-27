package com.hisschemoller.controller 
{
	import com.hisschemoller.App;
	import com.hisschemoller.AppFacade;
	import com.hisschemoller.model.AudioDriverProxy;
	import com.hisschemoller.model.AudioEngineProxy;
	import com.hisschemoller.model.MIDIEngineProxy;
	import com.hisschemoller.model.SoundBankProxy;
	import com.hisschemoller.model.enum.FileDataType;
	import com.hisschemoller.view.AlertMediator;
	import com.hisschemoller.view.BallPanelMediator;

	import org.puremvc.as3.interfaces.ICommand;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;

	/**
	 * @author wouter.hisschemoller
	 * (c) Lost Boys Feb 9, 2010
	 */
	public class StartupCommand extends SimpleCommand implements ICommand 
	{
		override public function execute(notification : INotification) : void
		{
			var app : App = notification.getBody() as App;
			
			/** Create and register proxies. */
			facade.registerProxy(new AudioEngineProxy());
			facade.registerProxy(new AudioDriverProxy(app.stage));
			facade.registerProxy(new MIDIEngineProxy());
			facade.registerProxy(new SoundBankProxy());
			
			/** Create and register mediators. */
			facade.registerMediator(new AlertMediator(app._alert));
			facade.registerMediator(new BallPanelMediator(app._panel));
			
			/** Start the application. */
			facade.sendNotification(AppFacade.FILE_DATA, "../xml/programs.xml", FileDataType.STARTUP_XML_FILE);
		}
	}
}
