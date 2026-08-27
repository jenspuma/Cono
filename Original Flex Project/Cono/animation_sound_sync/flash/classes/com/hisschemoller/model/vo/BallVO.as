package com.hisschemoller.model.vo 
{

	/**
	 * @author wouter.hisschemoller
	 * (c) Lost Boys Feb 9, 2010
	 */
	public class BallVO 
	{
		public var time : Number = new Date().getTime();
		public var x : Number;
		public var y : Number;
		public var vx : Number;
		public var vy : Number;
		public var hit : Boolean;
		
		public function BallVO(x : Number, y : Number, vx : Number, vy : Number, hit : Boolean)
		{
			this.x = x;
			this.y = y;
			this.vx = vx;
			this.vy = vy;
			this.hit = hit;
		}
	}
}
