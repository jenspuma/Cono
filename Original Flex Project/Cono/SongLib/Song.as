package
{
    import flash.utils.*;
    import flash.events.SampleDataEvent;
    import flash.media.Sound;


    public class Song
    {
        private var dynamicSound:Sound      = new Sound;        
        private var songCursor:int          = 0;
        private var sixteenthCount:int      = 0;
        private var barCount:int            = 0;
        private var sixteenthLength:int     = 5513; // default to 120bpm     
        private var chunks:Array            = new Array();
        private var cues:Array              = new Array();

        private var stopFlag:Boolean        = false;

        public function Song()
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
            
			trace("Position "+barCount+":"+sixteenthCount);
			
            var n:int   = 0;
            var len:int = sixteenthLength;
            
            for ( n=0; n < cues.length; n++ )
            {
                if (cues[n].bar == barCount || cues[n].bar == -1)
                  if(cues[n].sixteenth == sixteenthCount)
                    cues[n].callBack.call();
            }

            for ( n=0; n < chunks.length; n++ )
            {
                if (chunks[n].IsPlaying())
                    chunks[n].ExtractSamples(len);
            }
            
            var left:Number = 0;
            var right:Number = 0;

            for ( var c:int=0; c < len; c++ ) 
            {
              left  = 0;
              right = 0;
              
              for ( n=0; n < chunks.length; n++ )
              {
                if (chunks[n].IsPlaying())
                {
                    left  += chunks[n].samples.readFloat() * chunks[n].gain;
                    right += chunks[n].samples.readFloat() * chunks[n].gain;
                }
              }
              
              event.data.writeFloat(left);
              event.data.writeFloat(right); 
            }
            
            songCursor += len;
            sixteenthCount++;
            if(sixteenthCount == 16)
            {
                barCount++;
                sixteenthCount = 0;
            }
        }
        
        public function AddChunk(newChunk:SoundChunk):void
        {
            chunks.push(newChunk);
        }
        
        public function AddCue(bar:int, sxtnth:int, callBack:Function):void
        {
            cues.push(new Cue(bar, sxtnth, callBack));
        }
        
        
        public function Play():void
        {
            dynamicSound.play();
        }

        public function Stop():void
        {
            stopFlag = true;
        }


    }

}


class Cue
{
    public var bar:int;
    public var sixteenth:int;
    public var callBack:Function;
    
    public function Cue(b:int, s:int, c:Function)
    {
        bar = b;
        sixteenth = s;
        callBack = c;
    }
}