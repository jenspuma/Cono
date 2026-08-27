package com.hisschemoller.model {
	import com.hisschemoller.utils.audio.vo.SoundVO;	import org.puremvc.as3.interfaces.IProxy;	import org.puremvc.as3.patterns.proxy.Proxy;	/**
	 * (c) Copyright LBi Lost Boys 2009
	 * @author wouter.hisschemoller
	 */
	public class SoundBankProxy extends Proxy implements IProxy 	{		public static const NAME : String = "SoundBankProxy";		private var _sounds : Vector.<SoundVO> = new Vector.<SoundVO>();		
		public function SoundBankProxy()		{
			super(NAME);
		}				/**		 * 		 */		public function addSound(soundVO : SoundVO) : void		{			log("Sound added: " + soundVO.url);						/** Don't add if the sound already exists. */			if(soundExists(soundVO)) return;						/** Add the sound. */			_sounds.push(soundVO);		}				/**		 * Checks if a SoundVO exists.		 */		public function soundExists(soundVO : SoundVO) : Boolean		{			var n : int = _sounds.length;			while(--n > -1)			{				if(soundVO == _sounds[n]) return true;			}						return false;		}				/**		 * 		 */		public function _getSoundByID(id : String) : SoundVO		{			var n : int = _sounds.length;			while(--n > -1)			{				if(_sounds[n].id == id) return _sounds[n];			}						return null;		}	}}
