package com.hisschemoller.controller {
	import com.hisschemoller.model.SoundBankProxy;	import com.hisschemoller.utils.audio.vo.SoundVO;	import org.puremvc.as3.interfaces.ICommand;	import org.puremvc.as3.interfaces.INotification;	import org.puremvc.as3.patterns.command.SimpleCommand;	/**
	 * (c) Copyright LBi Lost Boys 2009
	 * @author wouter.hisschemoller
	 */
	public class AddSoundCommand extends SimpleCommand implements ICommand 	{
		override public function execute(notification : INotification) : void		{			var soundVO : SoundVO = notification.getBody() as SoundVO;						/** Add the new sound to the SoundBankProxy. */			var soundBankProxy : SoundBankProxy = facade.retrieveProxy(SoundBankProxy.NAME) as SoundBankProxy;			soundBankProxy.addSound(soundVO);		}	}
}
