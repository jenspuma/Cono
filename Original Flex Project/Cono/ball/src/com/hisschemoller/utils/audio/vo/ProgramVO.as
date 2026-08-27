package com.hisschemoller.utils.audio.vo 
{
	import com.hisschemoller.utils.audio.enum.AudioProcessorType;	
	/**
	 * @author Wouter Hisschemoller
	 * (c) Jan 30, 2010
	 */
	public class ProgramVO 
	{
		public var id : String;
		public var type : String;
		
		public function ProgramVO()
		{
			type = AudioProcessorType.PROCESSOR;
		}
		
		public function parseXML(o : XML) : Boolean
		{
			id = o.@id;
			type = o.@type;
			
			return true;
		}
	}
}
