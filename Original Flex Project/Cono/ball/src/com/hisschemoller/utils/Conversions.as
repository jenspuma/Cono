package com.hisschemoller.utils 
{
	/**
	 * @author Wouter Hisschemoller
	 * (c) Jan 16, 2010
	 */
	public class Conversions 
	{
		/**
		 * Covert semitone shift to playback speed multiplier.
		 * For example: -12 returns 0.5, 12 returns 2, 0 returns 1.
		 */
		public static function semitoneToRate(semitone : Number) : Number
		{
			return Math.pow(2, semitone / 12);
		}
		
		/**
         * From: http://www.sengpielaudio.com/calculator-db-volt.htm
         * @param value: amplitude.
         * @return: decibel.
         */
        public static function amplitudeToDecibel(value : Number) : Number
        {
            return Math.round(1000000000 * 20 * (Math.log(value / 1) / Math.log(10))) / 1000000000;
        }

        /**
         * From: http://www.sengpielaudio.com/calculator-db-volt.htm
         * @param value: decibel.
         * @return: amplitude.
         */
        public static function decibelToAmplitude(value : Number) : Number
        {
            return Math.round(1000000000 * 20 * (Math.log((Math.pow(10, value / 20) / 0.774596669)) / Math.log(10))) / 1000000000;
        }
	}
}
