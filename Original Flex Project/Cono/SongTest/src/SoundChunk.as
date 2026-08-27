package
{
    import flash.utils.*;
    import flash.events.Event;
    import flash.media.Sound;
    import flash.net.URLRequest;

    public class SoundChunk
    {
        private var srcSound:Sound      = new Sound;
        private var loadCompl:Boolean   = false;
        private var total:int           = 0;
        
        private var isPlaying:Boolean   = false;
        private var loopBegin:int       = 0;
        private var loopEnd:int         = int.MAX_VALUE;
        private var loopIt:Boolean      = false;
        
        private var m_gain:Number		= 1;  

        public  var samples:ByteArray   = new ByteArray();
              
        // Leading silence due to mp3 file encoding, 
        // this number is depending on the encoder used
        private var leadSilence:Number  = 1105; 

        private var dummy:ByteArray = new ByteArray();
       
        public function SoundChunk(src:String, lpBgn:int=0, lpEnd:int=int.MAX_VALUE, lpIt:Boolean = false)
        {
            srcSound.addEventListener(Event.COMPLETE, loadComplete);
            srcSound.load(new URLRequest(src));
            
            loopBegin = lpBgn;
            loopEnd   = lpEnd;
            loopIt    = lpIt;		
        }
        
        private function loadComplete(event:Event):void 
        {
            loadCompl = true;         
            Reset();
        }

        public function Play():void
        {
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
            srcSound.extract(dummy, 1, leadSilence+loopBegin-1);
            total = 0;
        }
        
        public function ExtractSamples(nSamples:int):void
        {
            //loop length must not be shorter than nSamples
            
            var len:int=0;
            samples.position = 0;
            
            if(loopIt && (total+nSamples >= loopEnd))
                len = srcSound.extract(samples, loopEnd-total);
            else
                len = srcSound.extract(samples, nSamples);
            
            total += len;
            
            if (len<nSamples)
            {
                if (loopIt)
                {
                    Reset();
                    total += srcSound.extract(samples, nSamples - len);
                }  
                else
                {
                     // fill the rest of the array with zeros
                    for(var i:Number = samples.position; i < samples.length; i++)
                        samples[i]=0;
                    
                    isPlaying = false;
                    Reset();
                }
            }

            samples.position = 0;
        }
                
    }


    

}