package com.hisschemoller.utils.audio.vo 
{
	import com.hisschemoller.utils.audio.enum.AudioProcessorType;	import com.hisschemoller.utils.audio.vo.ProgramVO;	
	/**
	 * @author Wouter Hisschemoller
	 * (c) Feb 5, 2010
	 */
	public class SampleProgramVO extends ProgramVO 
	{
		public var soundData : SoundVO = new SoundVO();
		
		public function SampleProgramVO()
		{
			super();
			
			super.type = AudioProcessorType.SAMPLE_PROCESSOR;
		}
		
		override public function parseXML(o : XML) : Boolean
		{
			var success : Boolean = super.parseXML(o);
			
			soundData.url = o.@url;
			
			return success;
		}
	}
}
