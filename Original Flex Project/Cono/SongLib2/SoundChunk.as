package
{
    import flash.utils.*;
    import flash.events.Event;
    import flash.media.Sound;
    import flash.net.URLRequest;

    public class SoundChunk
    {
		public  var name:String;
		
        private var srcSound:Sound;
        private var total:int           = 0;
        private var extractPos:int      = 0;
        
        private var isPlaying:Boolean   = false;
        private var loopBegin:int       = 0;
        private var loopEnd:int         = int.MAX_VALUE;
        private var loopIt:Boolean      = false;
        
        private var m_gain:Number		= 1;  

        public  var samples:ByteArray   = new ByteArray();

        // Leading silence due to mp3 file encoding, 
        // this number is depending on the encoder used
        private var leadSilence:Number  = 2256;//1105; 

        private var dummy:ByteArray = new ByteArray();
       
        public function SoundChunk(src:Sound, nm:String, lpBgn:int=0, lpEnd:int=int.MAX_VALUE, lpIt:Boolean = false)
        {
            name     = nm;
            srcSound = src;
            
            loopBegin = lpBgn;
            loopEnd   = lpEnd;
            loopIt    = lpIt;		
        }
        

        public function Play():void
        {
			Reset();
            isPlaying = true;
        }

        public function get gain():Number       { return this.m_gain; }
        public function set gain(g:Number):void { this.m_gain=g; }
        
        public function Stop():void
        {
            isPlaying = false;
        }
	
        public function IsPlaying():Boolean
        {
            return isPlaying;
        }

        public function Loop(lpIt:Boolean):void
        {
            loopIt = lpIt;
        }
        
        public function Reset():void
        {
            //Remove leading silence
            //srcSound.extract(dummy, 1, leadSilence+loopBegin-1);
            extractPos = leadSilence + loopBegin;
						total = 0;
        }
        
        public function ExtractSamples(nSamples:int):void
        {
            //loop length must not be shorter than nSamples
            
            var len:int=0;
            samples.position = 0;
            
            if((total+nSamples >= loopEnd))
                len = srcSound.extract(samples, loopEnd-total, extractPos);
            else
                len = srcSound.extract(samples, nSamples, extractPos);
            
            total 			+= len;
						extractPos 	+= len;
            
            if (len<nSamples)
            {
                if (loopIt)
                {
                    Reset();
										len = srcSound.extract(samples, nSamples - len);
										total 			+= len;
										extractPos 	+= len;
                }  
                else
                {
                     // fill the rest of the array with zeros
                    for(var i:Number = samples.position; i < samples.length; i++)
                        samples[i]=0;
                    
                    isPlaying = false;
                    //Reset();
                }
            }

            samples.position = 0;
        }
                
    }


    

}