package com.hisschemoller.controller 
{
	import com.hisschemoller.AppFacade;
	import com.hisschemoller.model.MIDIEngineProxy;
	import com.hisschemoller.utils.midi.MidiProgramChangeVO;

	import org.puremvc.as3.interfaces.ICommand;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;

	/**
	 * @author wouter.hisschemoller
	 * (c) Lost Boys Feb 3, 2010
	 */
	public class StartupDoneCommand extends SimpleCommand implements ICommand 
	{
		override public function execute(notification : INotification) : void
		{
			var programChange : MidiProgramChangeVO = new MidiProgramChangeVO();
			programChange.deltaTime = 0;
			programChange.number = 0;
			
			/** Select the first program on all instruments. */
			programChange.channel = 0;
			facade.sendNotification(AppFacade.MIDI_IN, programChange);
			programChange.channel = 1;
			facade.sendNotification(AppFacade.MIDI_IN, programChange);
			programChange.channel = 2;
			facade.sendNotification(AppFacade.MIDI_IN, programChange);
			programChange.channel = 3;
			facade.sendNotification(AppFacade.MIDI_IN, programChange);
			
			/** Select a channel (with instrument and program) to edit. */
			MIDIEngineProxy(facade.retrieveProxy(MIDIEngineProxy.NAME)).selectChannel(0);
		}
	}
}
