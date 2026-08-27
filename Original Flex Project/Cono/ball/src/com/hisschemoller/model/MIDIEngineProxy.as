package com.hisschemoller.model 
{
	import com.hisschemoller.AppFacade;
	import com.hisschemoller.model.vo.AlertVO;
	import com.hisschemoller.model.vo.MIDIEngineInfoVO;
	import com.hisschemoller.utils.audio.enum.AudioProcessorType;
	import com.hisschemoller.utils.audio.processors.PitchedSampleProcessor;
	import com.hisschemoller.utils.audio.vo.AudioEventVO;
	import com.hisschemoller.utils.audio.vo.InstrumentVO;
	import com.hisschemoller.utils.audio.vo.PitchedSampleProgramVO;
	import com.hisschemoller.utils.audio.vo.ProgramVO;
	import com.hisschemoller.utils.midi.MidiEventType;
	import com.hisschemoller.utils.midi.MidiEventVO;
	import com.hisschemoller.utils.midi.MidiNoteOffVO;
	import com.hisschemoller.utils.midi.MidiNoteOnVO;
	import com.hisschemoller.utils.midi.MidiProgramChangeVO;
	import com.hisschemoller.utils.midi.MidiSpecification;
	
	import org.puremvc.as3.interfaces.IProxy;
	import org.puremvc.as3.patterns.proxy.Proxy;	
	/**
	 * @author Wouter Hisschemoller
	 * (c) Jan 31, 2010
	 */
	public class MIDIEngineProxy extends Proxy implements IProxy 
	{
		public static const NAME : String = "MIDIEngineProxy";
		private var _audioEngine : AudioEngineProxy;
		private var _instruments : Vector.<InstrumentVO> = new Vector.<InstrumentVO>();
		private var _channels : Vector.<InstrumentVO> = new Vector.<InstrumentVO>(MidiSpecification.NUM_CHANNELS, true);
		private var _selectedChannel : uint;
		private var _infoVO : MIDIEngineInfoVO = new MIDIEngineInfoVO();
		
		public function MIDIEngineProxy()
		{
			super(NAME);
		}
		
		/**
		 * 
		 */
		override public function onRegister() : void
		{
			 _audioEngine = AudioEngineProxy(facade.retrieveProxy(AudioEngineProxy.NAME));
		}
		
		/**
		 * Pass a MIDI event on to a specific instrument.
		 */
		public function midiIn(midiEventVO : MidiEventVO) : void
		{
			var instrumentVO : InstrumentVO = _channels[midiEventVO.channel];
			
			switch(midiEventVO.type)
			{
				case MidiEventType.PROGRAM_CHANGE:
					var programChangeVO : MidiProgramChangeVO = MidiProgramChangeVO(midiEventVO);
					instrumentVO.selectedProgramIndex = programChangeVO.number;
					instrumentVO.selectedProgram = instrumentVO.programs[programChangeVO.number];
					_infoVO.channel = midiEventVO.channel;
					_infoVO.programID = instrumentVO.selectedProgram.id;
					_infoVO.programType = instrumentVO.selectedProgram.type;
					facade.sendNotification(AppFacade.CHANNEL_CHANGE_PROGRAM, _infoVO);
					break;
					
				case MidiEventType.NOTE_ON:
					var noteOnVO : MidiNoteOnVO = MidiNoteOnVO(midiEventVO);
					if(noteOnVO.velocity == 0)
					{
						var noteOff : MidiNoteOffVO = new MidiNoteOffVO();
						noteOff.channel = noteOnVO.channel;
						noteOff.pitch = noteOnVO.pitch;
						noteOff.deltaTime = noteOnVO.deltaTime;
						facade.sendNotification(AppFacade.MIDI_IN, noteOff);
						return;
					}
					var audioEventVO : AudioEventVO = new AudioEventVO();
					switch(instrumentVO.type)
					{
						case AudioProcessorType.PITCHED_SAMPLE_PROCESSOR:
							var processor : PitchedSampleProcessor = new PitchedSampleProcessor(PitchedSampleProgramVO(instrumentVO.selectedProgram), midiEventVO.deltaTime, noteOnVO.pitch, noteOnVO.velocity);
							break;
						default:
							return;
					}
					audioEventVO.audioProcessor = processor;
					audioEventVO.instrument = instrumentVO;
					_audioEngine.addAudioEvent(audioEventVO);
					break;
					
				case MidiEventType.NOTE_OFF:
					var noteOffVO : MidiNoteOffVO = MidiNoteOffVO(midiEventVO);
					var n : int = instrumentVO.audioProcessors.length;
					while(--n > -1)
					{
						if(instrumentVO.audioProcessors[n].pitch == noteOffVO.pitch) instrumentVO.audioProcessors[n].stop();
					}
					break;
					
				case MidiEventType.CONTROL_CHANGE:
					
					break;
					
				case MidiEventType.SYS_EX:
					
					break;
				default:
					return;
			}
		}
		
		/**
		 * 
		 */
		public function addInstrumentToChannel(instrumentID : String, channel : uint) : void
		{
			var n : uint = _instruments.length;
			while(--n > -1)
			{
				if(_instruments[n].id == instrumentID)
				{
					/** If the channel is occupied by an instrument, remove it. */
					if(_channels[channel]) removeInstrumentFromChannel(channel);
					
					_channels[channel] = _instruments[n];
					
					//_infoVO.channel = channel;
					//_infoVO.programID = _channels[channel].selectedProgram.id;
					//_infoVO.programType = _channels[channel].selectedProgram.type;
					facade.sendNotification(AppFacade.CHANNEL_CHANGE_INSTRUMENT, _infoVO);
					
					log("Instrument with ID '" + instrumentID + "' added to channel #" + channel);
				}
			}
		}
		
		/**
		 * Remove the instrument from the requested channel.
		 */
		public function removeInstrumentFromChannel(channel : uint) : void
		{
			/** If the channel is occupied, stop all running processes. */
			if(_channels[channel])
			{
				// TODO: Clean up of removed instrument.
			}
			
			_channels[channel] = null;
			
			_infoVO.channel = channel;
			_infoVO.programID = null;
			_infoVO.programType = null;
			facade.sendNotification(AppFacade.CHANNEL_REMOVE_INSTRUMENT, _infoVO);
		}
		
		/**
		 * Add a program to the next available free slot in and instrument's program list.
		 */
		public function addProgramToChannel(programVO : ProgramVO, channel : uint) : void
		{
			/** If the program is the wrong type for the instrument alert and quit. */
			if(programVO.type  != _channels[channel].type)
			{
				facade.sendNotification(AppFacade.ALERT, new AlertVO("Wrong program type", "The program can't be played by the instrument on the selected channel."));
				return;
			}
			
			/** Search for the first free program slot. */
			var programIndex : int = -1;
			for(var i : uint = 0; i < _channels[channel].programs.length; i++)
			{
				if(_channels[channel].programs[i] == null)
				{
					programIndex = i;
					break;
				}
			}
			
			/** If there are no unused program slots alert and quit. */
			if(programIndex == -1)
			{
				facade.sendNotification(AppFacade.ALERT, new AlertVO("No free program slot", "All program slots in this instrument are in use. The new program couldn't be added."));
				return;
			}
			
			/** Add the program to the instrument. */
			_channels[channel].programs[programIndex] = programVO;
			
			/** Select the new program. */
			var programChange : MidiProgramChangeVO = new MidiProgramChangeVO();
			programChange.channel = channel;
			programChange.deltaTime = 0;
			programChange.number = programIndex;
			
			/** Note to self. */
			facade.sendNotification(AppFacade.MIDI_IN, programChange);
			
			log("Program with ID '" + programVO.id + "' added to instrument with ID '" + _channels[channel].id + "' in program slot #" + programIndex + " on channel #" + channel + ".");
		}
		
		/**
		 * Add an instrument to the _instruments list (without adding it to a channel).
		 * @param instrumentVO: The instrument to add.
		 */
		public function addInstrument(instrumentVO : InstrumentVO) : void
		{
			/** Quit if the instrument already exists. */
			var n : int = _instruments.length;
			while(--n > -1)
			{
				if(_instruments[n] == instrumentVO) return;
			}
			
			_instruments.push(instrumentVO);
			
			log("Instrument with ID '" + instrumentVO.id + "' added.");
		}
		
		/**
		 * 
		 */
		public function getSelectedProgramByChannel(channel : uint) : ProgramVO
		{
			if(_channels[channel]) return _channels[channel].selectedProgram;
			
			return null;
		}
		
		/**
		 * 
		 */
		public function _getInstrumentTypeByChannel(channel : uint) : String
		{
			if(_channels[channel]) return _channels[channel].type;
			
			return null;
		}
		
		/**
		 * 
		 */
		public function getSelectedChannel() : uint
		{
			return _selectedChannel;
		}
		
		public function selectChannel(selectedChannel : uint) : void
		{
			_selectedChannel = selectedChannel;
			
			_infoVO.selectedChannel = _selectedChannel;
			_infoVO.channel = _selectedChannel;
			_infoVO.programID = _channels[_selectedChannel].selectedProgram.id;
			_infoVO.programType = _channels[_selectedChannel].selectedProgram.type;
			facade.sendNotification(AppFacade.CHANNEL_SELECT, _infoVO);
		}
	}
}
