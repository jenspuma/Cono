package com.hisschemoller.utils.audio.instruments {
	import com.hisschemoller.utils.audio.processors.IAudioProcessor;
	import com.hisschemoller.utils.audio.vo.ProgramVO;
	import com.hisschemoller.utils.midi.MidiNoteOnVO;			/**
	 * @author Wouter Hisschemoller
	 * (c) Jan 29, 2010
	 */
	public interface IAudioInstrument 	{		function addProcessor(noteOnVO : MidiNoteOnVO) : IAudioProcessor;				function removeProcessor(audioProcessor : IAudioProcessor) : void;				function addProgram(number : uint, programVO : ProgramVO) : void;				function selectProgram(number : uint) : void;				function get selectedProgram() : ProgramVO;				function dispose() : void;
	}
}
