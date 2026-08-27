package
{
    import flash.utils.*;
    import flash.events.SampleDataEvent;
    import flash.media.Sound;


    public class Engine
    {
        private var dynamicSound:Sound      = new Sound;        
        private var EngineCursor:int        = 0;
        private var sixteenthCount:int      = 0;
        private var barCount:int            = 0;
        private var sixteenthLength:int     = 5513; // default to 120bpm     

        private var stopFlag:Boolean        = false;
		
				private var song:Song               = null;

        public function Engine()
        {
            dynamicSound.addEventListener("sampleData",sampleData);
        }

        public function get bar():int       {return barCount;}
        public function get sixteenth():int {return sixteenthCount;}
        
        public function setTempo(bpm:int):Boolean
        {
					var smppr16th:int = 44100/((bpm*4)/60);

					if (smppr16th<2048 || smppr16th>8192)
					{
						return false;
					}
					
					sixteenthLength = smppr16th;
			
          return true;
        }

        private function sampleData(event:SampleDataEvent):void 
        {
            if(stopFlag) 
            {
                stopFlag = false;
                return; //without filling the buffer --> stop the sound
            }
            
						//trace("Position "+barCount+":"+sixteenthCount);
			
            var n:int   = 0;
            var len:int = sixteenthLength;
            
						while ((song.cues[0].bar == barCount) && (song.cues[n].sixteenth == sixteenthCount))
						{
							song.cues[0].callBack.call();
							song.cues.shift();
						}

						var playingChunks:Array = new Array;
						
						for each(var chunk:SoundChunk in song.chunks)
						{
							if (chunk.IsPlaying())
							{
								chunk.ExtractSamples(len);
								if(chunk.gain > 0)
									playingChunks.push(chunk);
							}
						}
						
            var left:Number = 0;
            var right:Number = 0;

            for ( var c:int=0; c < len; c++ ) 
            {
              left  = 0;
              right = 0;

							for each(var chk:SoundChunk in playingChunks)
							{
								left  += chk.samples.readFloat() * chk.gain;
								right += chk.samples.readFloat() * chk.gain;								
							}
              
              event.data.writeFloat(left);
              event.data.writeFloat(right); 
            }
            
            EngineCursor += len;
            sixteenthCount++;
            if(sixteenthCount == 16)
            {
                barCount++;
                sixteenthCount = 0;
            }
        }
        
        public function Play():void
        {
					if (song == null)
						return;	 //If there is no content to play, don't bother
				
					if(!song.loadCompleted())
						return; //Content must be ready
				
            dynamicSound.play();
        }

        public function Stop():void
        {
            stopFlag = true;
        }

        public function AddSong(s:Song):void
        {
            song = s;
        }


    }

}
