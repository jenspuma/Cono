package
{
	import flash.events.Event;

	public class ConoSong extends Song
	{
		[Embed(source="../bin/assets/conosong.xml")]
		[bindable]
		private var conoSongXml:Class;
		
		private var verses:Array;
		private var verseLines:Array = new Array;
		private var lineCnt:int = 0;
		
		public static const NEW_VERSE:String = "NewVerse" 
		
		public function ConoSong()
		{
			registerAction("ChooseVerse", ChooseVerse);
		}
		
		public function Load():void
		{
			var xml:XML = conoSongXml.data as XML;
			addEventListener(Event.COMPLETE, onLoadComplete);
			loadFromXML(xml);			
		}
		
		public function onLoadComplete(event:Event):void
		{
			verses = chunks.filter(isVerse);
		}

		public function ChooseVerse():void
		{
			if (lineCnt == 0)
				dispatchEvent(new Event(NEW_VERSE));
			
			var choice:int = verseLines[lineCnt];
			lineCnt = (lineCnt+1)%14;
			
			for each (var vrs:SoundChunk in verses)
			{
				vrs.gain = 0;
			}
			
			verses[choice].gain = 1;
		}
		
		public function isVerse(element:*, index:int, arr:Array):Boolean
		{
			var str:String = element.name;
			if (str.search("Verse") != -1)
				return true;

			return false;
		}
		
		public function setVerseLine(verse:int, line:int):void
		{
			verseLines[line] = verse;
		}

	}
}