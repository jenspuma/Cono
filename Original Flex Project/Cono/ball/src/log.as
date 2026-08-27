package
{
	import log;
	import com.nesium.logging.TrazzleLogger;
	
	public function log(...rest):void
	{
		com.nesium.logging.TrazzleLogger.instance().log(rest.toString());
	}
}