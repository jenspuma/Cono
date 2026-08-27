
private var BeatChk:SoundChunk;
private var DingChk:SoundChunk;


private var theSong:Song;

private function DingClickHandler():void
{
    myTA.text+= "End Loop Clicked\n";
  
    var nextbar:int = theSong.bar;
    var next16th:int = (theSong.sixteenth);
    
/*    if(next16th>15)
    {
      next16th = 0;
      nextbar++;
    }
 */   
    theSong.AddCue(nextbar, next16th, PlayDing);
	trace("Cue added at: " + nextbar + ":" + next16th);

}

private function initApp():void 
{
    myTA.text += "initApp called\n";
    
    BeatChk = new SoundChunk("assets/beat.mp3");
	BeatChk.Loop(true);
    
	DingChk = new SoundChunk("assets/Ding.mp3");

    theSong = new Song();

    theSong.AddChunk(BeatChk);
    theSong.AddChunk(DingChk);
	
	//if (theSong.setTempo(184) == false)
	if (theSong.setTempo(92) == false)
	{
		myTA.text += "Invalid tempo\n";
	}
	    
	theSong.Play();
	
	BeatChk.Play();
	
}

public function PlayDing():void
{
	if (DingChk.IsPlaying())
		DingChk.Reset();
	else
		DingChk.Play();
		
	trace("Ding ", theSong.bar, ":", theSong.sixteenth);
		
    myTA.text += "PlayDing callback called\n";
}


private var barCnt:int = 0;
public function BarCount():void
{
    barCnt++;
    myTA.text += "BarCount: " + barCnt + "\n";
}