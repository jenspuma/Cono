
package
{
	public class Cue
	{
		public var tick:int;
		public var bar:int;
		public var sixteenth:int;
		public var callBack:Function;
		
		public function Cue(t:int, c:Function)
		{
			tick 		= t;
			bar 		= t / 16;
			sixteenth 	= t % 16;
			callBack 	= c;
		}
	}
}