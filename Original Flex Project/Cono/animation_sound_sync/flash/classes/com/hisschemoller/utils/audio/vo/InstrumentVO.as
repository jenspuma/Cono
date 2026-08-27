package com.hisschemoller.utils.audio.vo 
{
	import com.hisschemoller.utils.audio.processors.IAudioProcessor;
	import com.hisschemoller.utils.midi.MidiSpecification;

	/**
	 * @author wouter.hisschemoller
	 * (c) Lost Boys Feb 2, 2010
	 */
	public class InstrumentVO 
	{
		public var id : String;
		public var type : String;
		public var audioProcessors : Vector.<IAudioProcessor> = new Vector.<IAudioProcessor>();
		public var programs : Vector.<ProgramVO> = new Vector.<ProgramVO>(MidiSpecification.MAX_VALUE_7BIT, true);
		public var selectedProgram : ProgramVO;
		public var selectedProgramIndex : uint;
		
		public function parseXML(o : XML) : Boolean
		{
			id = o.@id;
			type = o.@type;
			
			return true;
		}
	}
}
