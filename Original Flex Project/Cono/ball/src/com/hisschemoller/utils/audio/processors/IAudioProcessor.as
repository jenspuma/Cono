package com.hisschemoller.utils.audio.processors
{
	/**
	 * @author Wouter Hisschemöller
	 * (c) Apr 24, 2009
	 */
	public interface IAudioProcessor 
	{
		function process(buffer : Vector.<Vector.<Number>>, bufferStartIndex : uint) : Boolean;
		
		function stop() : void
		
		function get pitch() : int;
	}
}
