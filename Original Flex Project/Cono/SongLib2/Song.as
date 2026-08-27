package
{
	import flash.display.InteractiveObject;
	import flash.events.EventDispatcher;
    import flash.utils.*;
    import flash.events.Event;
    import flash.media.Sound;
    import flash.net.URLRequest;

    public class Song extends EventDispatcher
    {
		public var sounds:Array	 = new Array();
        public var chunks:Array  = new Array();
		public var cues:Array    = new Array();
		public var actions:Array = new Array();
		
		
		public var tempo:int 	 = 120;
		
		protected   var loadIdx:int = 0;
		protected   var songXml:XML;
		
		protected var loadComplete:Boolean = false;
	
		public function Song()
		{
			
		}
		
		public function loadFromXML(newSongXml:XML):void
		{
			songXml = newSongXml;
			loadSounds();
		}
		
		protected function loadSounds():void
		{
			var files:XMLList = songXml.file;
			
			for each(var f:XML in files)
			{
				var s:namedSound = new namedSound;
				sounds.push(s);
				s.name  = f.@name;
				s.sound = new Sound();
				s.sound.addEventListener(Event.COMPLETE, loadSoundComplete);
				s.sound.load(new URLRequest(f.@path));
			}
		}

		protected function loadSoundComplete(event:Event):void 
		{
			loadIdx++;
			
			if (loadIdx < sounds.length)
			{
				return; //wait for all sound files to load before proceeding
			}
			
			loadChunks();
			
			loadTimeLine();
			
			loadComplete = true;
			dispatchEvent(new Event(Event.COMPLETE));
			
		}

		public function loadCompleted():Boolean
		{
			return loadComplete;
		}

		protected function loadChunks():void
		{			
			for each(var chk:XML in songXml.chunk)
			{
				var snd:Sound = findSound(chk.filename);

				if (snd != null)
				{
					if (chk.hasOwnProperty("end"))
					{
						chunks.push(new SoundChunk(snd, chk.@name, chk.begin, chk.end));	
					}
					else
					{
						chunks.push(new SoundChunk(snd, chk.@name, chk.begin));
					}
				}
			}
		}
		
		protected function loadTimeLine():void
		{	
			tempo = songXml.timeline.@tempo;
			
			for each(var marker:XML in songXml.timeline.marker)
			{
				addMarker(marker);
			}
		}
		
		
		public function registerAction(n:String, cb:Function):void
		{
			var action:Object = new Object;
			action.name = n;
			action.callback = cb;
			
			actions.push(action);
		}
		
		public function addMarker(marker:XML):void
		{
			var tick:int = marker.@tick;
			
			//Handle repeat entries
			for each(var r:XML in marker.repeat)
			{
				var rt:int = r.@tick;
				rt += tick;
				marker.@tick = rt;
				
				var rcue:RepeatCue = new RepeatCue(marker, this);
				insertCueSorted(new Cue(tick, rcue.Insert));
				//trace("Repeat cue added at tick:", tick);

			}
			
			//Handle playchunk entries
			for each(var p:String in marker.playchunk)
			{
				var chk:SoundChunk  = findChunk(p);
				if(chk != null)
					insertCueSorted(new Cue(tick, chk.Play));
				
			}

			//Handle action entries
			for each(var a:String in marker.action)
			{
				var act:Object = findAction(a);
				if(act != null)
					insertCueSorted(new Cue(tick, act.callback));
			}
		}
		
		protected function findSound(nameToLookFor:String):Sound
		{
			for each (var snd:namedSound in sounds)
			{
				if (snd.name == nameToLookFor)
					return snd.sound;
			}
			
			return null;
		}

		protected function findChunk(nameToLookFor:String):SoundChunk
		{
			for each (var chk:SoundChunk in chunks)
			{
				if (chk.name == nameToLookFor)
					return chk;
			}
			
			return null;
		}

		protected function findAction(nameToLookFor:String):Object
		{
			for each (var act:Object in actions)
			{
				if (act.name == nameToLookFor)
					return act;
			}
			
			return null;
		}
		
		protected function insertCueSorted(cue:Cue):void
		{
			for (var i:int = 0; i < cues.length; i++ )
			{
				if (cues[i].tick >= cue.tick)
				{
					cues.splice(i, 0, cue);
					return;
				}	
			}
			
			cues.push(cue);
		}

	}
}


internal class namedSound
{
    import flash.media.Sound;

	public var sound:Sound;
	public var name:String;	
}

internal class RepeatCue
{
	private var markerXml:XML;
	private var song:Song;
	
	public function RepeatCue(x:XML, s:Song)
	{
		markerXml = x;
		song = s;
	}
	
	public function Insert():void
	{
		song.addMarker(markerXml);
	}
}
	