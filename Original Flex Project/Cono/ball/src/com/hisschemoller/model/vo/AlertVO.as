package com.hisschemoller.model.vo 
{
	/**
	 * @author Wouter Hisschemoller
	 * (c) Feb 5, 2010
	 */
	public class AlertVO 
	{
		public var header : String;
		public var message : String;
		
		public function AlertVO(header : String, message : String)
		{
			this.header = header;
			this.message = message;
		}
	}
}
