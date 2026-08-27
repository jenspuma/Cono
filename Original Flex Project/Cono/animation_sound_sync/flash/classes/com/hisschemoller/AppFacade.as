package com.hisschemoller 
{
	import com.hisschemoller.controller.AddSoundCommand;
	import com.hisschemoller.controller.ControlsCommand;
	import com.hisschemoller.controller.FileDataCommand;
	import com.hisschemoller.controller.MIDICommand;
	import com.hisschemoller.controller.MIDISetupCommand;
	import com.hisschemoller.controller.StartupCommand;
	import com.hisschemoller.controller.StartupDoneCommand;

	import org.puremvc.as3.interfaces.IFacade;
	import org.puremvc.as3.patterns.facade.Facade;
	import org.puremvc.as3.patterns.observer.Notification;

	/**
	 * (c) Copyright LBi Lost Boys 2009
	 * @author wouter.hisschemoller
	 */
	public class AppFacade extends Facade implements IFacade 
	{
		/** Notification name constants. */
		public static const STARTUP : String = "startup";
		public static const STARTUP_DONE : String = "startupDone";
		public static const FILE_DATA : String = "fileData";
		public static const ADD_SOUND : String = "addSound";
		public static const MIDI_IN : String = "midiIn";
		public static const CHANNEL_SELECT : String = "channelSelect";
		public static const CHANNEL_CHANGE_INSTRUMENT : String = "channelChangeInstrument";
		public static const CHANNEL_REMOVE_INSTRUMENT : String = "channelRemoveInstrument";
		public static const CHANNEL_CHANGE_PROGRAM : String = "channelChangeProgram";
		public static const ALERT : String = "alert";
		public static const PLAY : String = "play";
		public static const STOP : String = "stop";

		/**
		 * Singleton ApplicationFacade Factory Method
		 */
		public static function getInstance() : AppFacade 
		{
			if(instance == null) instance = new AppFacade();
			
			return instance as AppFacade;
		}

		/**
		 * Broadcast the STARTUP Notification
		 */
		public function startup(app : Object) : void 
		{
			notifyObservers(new Notification(AppFacade.STARTUP, app));
		}

		/**
		 * Register Commands with the Controller
		 */
		override protected function initializeController() : void 
		{
			super.initializeController();
			
			registerCommand(AppFacade.STARTUP, StartupCommand);
			registerCommand(AppFacade.STARTUP_DONE, StartupDoneCommand);
			registerCommand(AppFacade.FILE_DATA, FileDataCommand);
			registerCommand(AppFacade.ADD_SOUND, AddSoundCommand);
			registerCommand(AppFacade.CHANNEL_SELECT, MIDISetupCommand);
			registerCommand(AppFacade.CHANNEL_CHANGE_INSTRUMENT, MIDISetupCommand);
			registerCommand(AppFacade.CHANNEL_REMOVE_INSTRUMENT, MIDISetupCommand);
			registerCommand(AppFacade.CHANNEL_CHANGE_PROGRAM, MIDISetupCommand);
			registerCommand(AppFacade.MIDI_IN, MIDICommand);
			registerCommand(AppFacade.PLAY, ControlsCommand);
			registerCommand(AppFacade.STOP, ControlsCommand);
		}
	}
}
