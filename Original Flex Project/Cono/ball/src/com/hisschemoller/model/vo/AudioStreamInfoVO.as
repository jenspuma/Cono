package com.hisschemoller.model.vo {
	/**
	 * @author Wouter Hisschemoller
	 * (c) Jan 27, 2010
	 */
	public class AudioStreamInfoVO 	{		public var latencyInMS : Number;		public var positionWithLatency : int; /** Latency corrected position within buffer (in samples). */		public var peakLevelLeft : Number;		public var peakLevelRight : Number;
	}
}
