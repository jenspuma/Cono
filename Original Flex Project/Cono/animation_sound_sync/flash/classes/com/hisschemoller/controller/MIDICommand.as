package com.hisschemoller.controller 
{
	import com.hisschemoller.model.MIDIEngineProxy;
	import com.hisschemoller.utils.midi.MidiEventVO;

	import org.puremvc.as3.interfaces.ICommand;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;

	/**
	 * @author Wouter Hisschemoller
	 * (c) Feb 5, 2010
	 */
	public class MIDICommand extends SimpleCommand implements ICommand 
	{
		override public function execute(notification : INotification) : void
		{
			var midiEventVO : MidiEventVO = MidiEventVO(notification.getBody());
			
			MIDIEngineProxy(facade.retrieveProxy(MIDIEngineProxy.NAME)).midiIn(midiEventVO);
		}
	}
}
