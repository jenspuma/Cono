import flash.events.Event;
import mx.core.ClassFactory;
import com.*
	
[Embed(source="../bin/assets/lyrics.xml")]
[bindable]
private var lyrXml:Class;

private var theSong:ConoSong = new ConoSong();
private var theEngine:Engine = new Engine();

private var userActivity:Boolean = true;


public function initApp():void 
{	
	theEngine.AddSong(theSong);
	theSong.addEventListener(Event.COMPLETE, songLoaded);
	theSong.addEventListener(ConoSong.NEW_VERSE, newVerse);
	theSong.Load();
	
	var xml:XML = lyrXml.data as XML;
	
	var classRef:Class;
	var factory:ClassFactory
                
	classRef = getDefinitionByName("com.VerseLine") as Class;
	
	var i:int = 0;
	for (i = 0; i < 14; i++ )
	{
		factory = new ClassFactory(classRef);
		var inst:VerseLine = factory.newInstance();
		inst.xml = xml;
		inst.verseNumber = Math.floor(12 * Math.random());
		inst.lineNumber = i;
		inst.onVerseChange = verseLineChanged;
		vb.addChild(inst);
	}
}

public function verseLineChanged(line:VerseLine):void
{
	userActivity = true;
	theSong.setVerseLine(line.verseNumber, line.lineNumber);
}

public function RandomizeVerses():void
{
	var i:int = 0;
	for (i = 0; i < 14; i++ )
	{
		var inst:VerseLine = vb.getChildAt(i) as VerseLine;
		inst.verseNumber = Math.floor(12 * Math.random());
		inst.init();
	}

}

public function songLoaded(event:Event):void
{
	removeElement(status);
	theEngine.setTempo(theSong.tempo);
	theEngine.Play();
}

public function newVerse(event:Event):void
{
	if (!userActivity)
	{
		RandomizeVerses();
	}
	
	userActivity = false;
}

public function onClickHandler(event:Event, idx:Number):void
{
	var xml:XML = lyrXml.data as XML;
}


private var barCnt:int = 0;
public function BarCount():void
{
	barCnt++;
}

