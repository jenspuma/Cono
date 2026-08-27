package com.hisschemoller.utils.audio.vo 
{
	import com.hisschemoller.utils.audio.enum.AudioProcessorType;
	import com.hisschemoller.utils.audio.vo.InstrumentVO;	
	/**
	 * @author wouter.hisschemoller
	 * (c) Lost Boys Feb 2, 2010
	 */
	public class PitchedSampleInstrumentVO extends InstrumentVO 
	{
		//public var audioProcessors : Vector.<PitchedSampleProcessor> = new Vector.<PitchedSampleProcessor>();
		//public var programs : Vector.<PitchedSampleProgramVO> = new Vector.<PitchedSampleProgramVO>(MidiSpecification.MAX_VALUE_7BIT, true);
		//public var selectedProgram : PitchedSampleProgramVO;
		
		public function PitchedSampleInstrumentVO()
		{
			super.type = AudioProcessorType.PITCHED_SAMPLE_PROCESSOR;
		}
		
		override public function parseXML(o : XML) : Boolean
		{
			var result : Boolean = super.parseXML(o);
			
			return result;
		}
	}
}
