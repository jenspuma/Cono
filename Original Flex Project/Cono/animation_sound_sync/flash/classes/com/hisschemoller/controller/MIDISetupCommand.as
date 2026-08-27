package com.hisschemoller.controller 
{
	import org.puremvc.as3.interfaces.ICommand;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;	
	/**
	 * @author Wouter Hisschemoller
	 * (c) Feb 7, 2010
	 */
	public class MIDISetupCommand extends SimpleCommand implements ICommand 
	{
		override public function execute(notification : INotification) : void
		{
		}
	}
}
