
private var DrumChoChk:SoundChunk;
private var StopVoxChk:SoundChunk;


private var theSong:Song;

private function EndLoopClickHandler(event:Event):void
{
    myTA.text+= "End Loop Clicked\n";
    
    //DrumChoChk.Loop(false);
}

private function rocketClickHandler(event:Event):void
{
    myTA.text+= "Rocket!  Clicked\n";
    
    var nextbar:int = theSong.bar;
    var nextbeat:int = (theSong.sixteenth/4) + 1;
    
    if(nextbeat>3)
    {
      nextbeat = 0;
      nextbar++;
    }
    
    theSong.AddCue(nextbar,nextbeat*4,PlayRocket);
}

private function initApp():void 
{
    myTA.text += "initApp called\n";
    
    DrumChoChk = new SoundChunk("assets/drums.mp3", 1303475, 208559, true);
    StopVoxChk = new SoundChunk("assets/voc - crowd + more.mp3", 2524096, 2556544);

    theSong = new Song();
			
    theSong.AddChunk(DrumChoChk);
    theSong.AddChunk(StopVoxChk);
    
    DrumChoChk.gain = 0.5;
    
    theSong.AddCue(-1,0,BarCount);
 
    theSong.AddCue(1,0,PlayEnding);
  
    theSong.Play();

}

public function PlayEnding():void
{
    myTA.text += "PlayEnding callback called\n";
    DrumChoChk.Play();
}


public function PlayRocket():void
{
    myTA.text += "PlayRocket callback called\n";
    StopVoxChk.Play();
}

private var barCnt:int = 0;
public function BarCount():void
{
    barCnt++;
    myTA.text += "BarCount: " + barCnt + "\n";
}