package com.hisschemoller.controller 
{
	import de.popforge.audio.output.Sample;
	import de.popforge.format.wav.WavFormat;
	
	import com.hisschemoller.AppFacade;
	import com.hisschemoller.model.MIDIEngineProxy;
	import com.hisschemoller.model.enum.FileDataType;
	import com.hisschemoller.model.vo.AlertVO;
	import com.hisschemoller.utils.audio.enum.AudioProcessorType;
	import com.hisschemoller.utils.audio.vo.InstrumentVO;
	import com.hisschemoller.utils.audio.vo.PitchedSampleProgramVO;
	import com.hisschemoller.utils.audio.vo.SoundVO;
	
	import org.audiofx.mp3.MP3FileReferenceLoader;
	import org.audiofx.mp3.MP3SoundEvent;
	import org.puremvc.as3.interfaces.ICommand;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;
	
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.FileReference;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;	
	/**
	 * @author wouter.hisschemoller
	 * (c) Lost Boys Feb 2, 2010
	 */
	public class FileDataCommand extends SimpleCommand implements ICommand 
	{
		private var _fileDataType : String;
		private var _xml : XML;
		private var _waitingStack : Vector.<AudioLoadData> = new Vector.<AudioLoadData>();
		private var _loadingStack : Vector.<AudioLoadData> = new Vector.<AudioLoadData>();
		private var _loadedStack : Vector.<AudioLoadData> = new Vector.<AudioLoadData>();
		private var _decodingStack : Vector.<AudioLoadData> = new Vector.<AudioLoadData>();
		private var _decodedStack : Vector.<AudioLoadData> = new Vector.<AudioLoadData>();
		private var _loaderCount : uint = 2; /** The maximum number of simultaneous loading MP3 files. */
		
		override public function execute(notification : INotification) : void
		{
			_fileDataType = notification.getType();
			
			switch(_fileDataType)
			{
				case FileDataType.STARTUP_XML_FILE:
					loadXML(String(notification.getBody()));
					break;
					
				case FileDataType.SINGLE_LOCAL_AUDIO_FILE:
					log(FileReference(notification.getBody()).name);
					injectSingleLocalAudioFile(FileReference(notification.getBody()));
					break;
					
				case FileDataType.INSTRUMENT_XML_FILE:
					// TODO: Add more file data types later (local stored sample banks?).
					break;
			}
		}
			
		/**
		 * Load the XML with startup data for the application.
		 */
		private function loadXML(url : String) : void
		{
			/** Load the initial data xml named programs.xml as default. */
			var urlLoader : URLLoader = new URLLoader();
			urlLoader.addEventListener(Event.COMPLETE, xmlLoaderHandler);
			urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, xmlLoaderHandler);
			urlLoader.addEventListener(IOErrorEvent.IO_ERROR, xmlLoaderHandler);
			urlLoader.load(new URLRequest(url));
		}

		/**
		 * Data xml file loaded.
		 */
		private function xmlLoaderHandler(event : Event) : void
		{
			var urlLoader : URLLoader = URLLoader(event.target);
			urlLoader.removeEventListener(Event.COMPLETE, xmlLoaderHandler);
			urlLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, xmlLoaderHandler);
			urlLoader.removeEventListener(IOErrorEvent.IO_ERROR, xmlLoaderHandler);
			
			switch(event.type)
			{
				case Event.COMPLETE:
					_xml = new XML(urlLoader.data);
					XML.ignoreWhitespace = true;
					parseFileURLsFromXML(_xml);
					break;
				case SecurityErrorEvent.SECURITY_ERROR:
					facade.sendNotification(AppFacade.ALERT, new AlertVO("Security Error", "The setup XML file could not be loaded because of a security error. System error message: " + SecurityErrorEvent(event).text));
					break;
				case IOErrorEvent.IO_ERROR:
					facade.sendNotification(AppFacade.ALERT, new AlertVO("IO Error", "The setup XML file could not be loaded because of an IO error. Maybe the file was deleted on the server or the connection to the server failed. System error message: " + IOErrorEvent(event).text));
					break;
			}
		}
		
		/**
		 * Get all the audio file urls from the XML.
		 */
		private function parseFileURLsFromXML(xml : XML) : void
		{
			var xmlList : XMLList = xml..sound;
			var fileUrls : Vector.<String> = new Vector.<String>();
			
			for(var i : uint = 0; i < xmlList.length(); i++)
			{
				fileUrls.push(xmlList[i].@url);
			}
			
			loadAudioFiles(fileUrls);
		}
		
		/**
		 * Load a series of audio files.
		 * @param fileUrls: A list of audio file URLs.
		 */
		private function loadAudioFiles(fileUrls : Vector.<String>) : void
		{
			for(var i : uint = 0; i < fileUrls.length; i++)
			{
				var url : String = fileUrls[i];
				
				/** If the URL is not valid continue. */
				if(url == null || url == "") continue;
					
				/** If the file's not an MP3 or WAV skip it. */
				var fileExtention : String = url.substr(url.length - 3).toLowerCase();
				if(fileExtention != "wav" && fileExtention != "mp3") continue;
				
				/** If the URL is already in the list continue (double entry). */
				for(var j : uint = 0; j < fileUrls.length; j++)
				{
					if(url == fileUrls[j]) continue;
				}
				
				var audioLoadData : AudioLoadData = new AudioLoadData(url);
				audioLoadData.fileExtention = fileExtention;
				
				_waitingStack.push(audioLoadData);
				
				loadNextAudioFile();
			}
		}

		/**
		 * Load next sound if the waiting stack is not empty.
		 * @sends SoundLoaderEvent#ALL_LOADED
		 */
		private function loadNextAudioFile() : void 
		{
			/** Quit if all loaders taken. */
			if(_loadingStack.length == _loaderCount) return;

			/** Quit if no waiting data. */
			if(_waitingStack.length == 0) 
			{
				if(_loadingStack.length == 0)
				{
					/** All done. */
					decodeAudioFile();
				}
				return;
			}
			
			/** Get next object to load. */
			var audioLoadData : AudioLoadData = _waitingStack.shift();
			
			/** Store object in loading list. */
			_loadingStack.push(audioLoadData);
			
			/** Create listeners. */
			audioLoadData.urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
			audioLoadData.urlLoader.addEventListener(Event.COMPLETE, urlLoaderEventHandler);
			audioLoadData.urlLoader.addEventListener(Event.OPEN, urlLoaderStartedHandler);
			audioLoadData.urlLoader.addEventListener(ProgressEvent.PROGRESS, urlLoaderProgressEventHandler);
			audioLoadData.urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, urlLoaderEventHandler);
			audioLoadData.urlLoader.addEventListener(IOErrorEvent.IO_ERROR, urlLoaderEventHandler);
			audioLoadData.urlLoader.load(new URLRequest(audioLoadData.url));
		}

		/**
		 * A sound file started download.
		 */
		private function urlLoaderStartedHandler(event : Event) : void 
		{
			var audioLoadData : AudioLoadData = getAudioDataByLoader(URLLoader(event.target), _loadingStack);
			
			if(audioLoadData == null) 
			{
				facade.sendNotification(AppFacade.ALERT, new AlertVO("Error", "No data found for external loaded MP3 file. The audio file will not be loaded."));
				return;
			}

			audioLoadData.isLoading = true;
		}

		/**
		 * The URLLoader dispatched an event while loading an audio file.
		 */
		private function urlLoaderEventHandler(event : Event) : void 
		{
			var audioLoadData : AudioLoadData = getAudioDataByLoader(URLLoader(event.target), _loadingStack);
			audioLoadData.isLoading = false;
			
			/** Remove listeners. */
			audioLoadData.urlLoader.removeEventListener(Event.COMPLETE, urlLoaderEventHandler);
			audioLoadData.urlLoader.removeEventListener(Event.OPEN, urlLoaderStartedHandler);
			audioLoadData.urlLoader.removeEventListener(ProgressEvent.PROGRESS, urlLoaderProgressEventHandler);
			audioLoadData.urlLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, urlLoaderEventHandler);
			audioLoadData.urlLoader.removeEventListener(IOErrorEvent.IO_ERROR, urlLoaderEventHandler);
			
			if(audioLoadData == null) 
			{
				facade.sendNotification(AppFacade.ALERT, new AlertVO("Error", "Data for the sound loader not found. An audio file will not be loaded."));
			}
			else if(event is ErrorEvent) 
			{
				facade.sendNotification(AppFacade.ALERT, new AlertVO("Error", "An audio file could not be loaded. Error message: " + ErrorEvent(event).text));
			} 
			else 
			{
				/** Success. */
				audioLoadData.byteArray = URLLoader(event.target).data;
				
				/** Transfer data from loadingStack to loadedStack. */
				_loadedStack.push(_loadingStack.splice(_loadingStack.indexOf(audioLoadData), 1)[0]);
			}
			
			loadNextAudioFile();
		}

		/**
		 * Handle ProgressEvent from loading audio file.
		 * @param event: ProgressEvent
		 */
		private function urlLoaderProgressEventHandler(event : ProgressEvent) : void 
		{
			var audioLoadData : AudioLoadData = getAudioDataByLoader(URLLoader(event.target), _loadingStack);
			
			if(audioLoadData == null) 
			{
				facade.sendNotification(AppFacade.ALERT, new AlertVO("Error", "Data for sound loader not found."));
				return;
			}
			
			/** Load progress code to be inserted here. */
		}
		
		/**
		 * 
		 */
		private function injectSingleLocalAudioFile(fileReference : FileReference) : void
		{
			/** Create an AudioLoadData object for the injected file. */
			var audioLoadData : AudioLoadData = new AudioLoadData(fileReference.name);
			audioLoadData.byteArray = fileReference.data;
			audioLoadData.fileExtention = fileReference.name.substr(fileReference.name.length - 3).toLowerCase();
			
			/** Recreate _loadedStack so it's nice and clean and empty. */
			_loadedStack = new Vector.<AudioLoadData>();
			_loadedStack.push(audioLoadData);
			
			decodeAudioFile();
		}

		/**
		 * All audio loading is done, now decode the byteArrays.
		 */
		private function decodeAudioFile() : void
		{
			if(_loadedStack.length == 0 && _decodingStack.length == 0)
			{
				/** All done. */
				decodingAudioDone();
				return;
			}
			
			/** Get next object to decode. */
			var audioLoadData : AudioLoadData = _loadedStack.shift();
			
			/** Store object in loading list. */
			_decodingStack.push(audioLoadData);
			
			switch(audioLoadData.fileExtention)
			{
				case "mp3":
					var fileReference : MP3FileReferenceLoader = new MP3FileReferenceLoader();
					fileReference.addEventListener(Event.COMPLETE, mp3DecodeCompleteHandler);
					fileReference.parseMP3ByteArray(audioLoadData.byteArray, audioLoadData.url);
					break;
					
				case "wav":
					var wavFormat : WavFormat = WavFormat.decode(audioLoadData.byteArray);
					/** Rewrite the WAV byteArray. */
					var byteArray: ByteArray = new ByteArray();
					var n : int = wavFormat.numSamples;
					for(var i : uint = 0; i < n; i++)
					{
						var sample : Sample = Sample(wavFormat.samples[i]);
						byteArray.writeFloat(sample.left);
						byteArray.writeFloat(sample.right);
					}
					audioLoadData.byteArray = byteArray;
					audioLoadData.channels = wavFormat.channels;
					audioLoadData.numSamplesTotal = wavFormat.numSamples;
					_decodedStack.push(_decodingStack.splice(_decodingStack.indexOf(audioLoadData), 1)[0]);
					decodeAudioFile();
					break;
			}
		}

		/**
		 * @param event : MP3SoundEvent width Sound object as property sound.
		 */
		private function mp3DecodeCompleteHandler(event : MP3SoundEvent) : void
		{
			MP3FileReferenceLoader(event.target).removeEventListener(Event.COMPLETE, mp3DecodeCompleteHandler);
			
			var audioLoadData : AudioLoadData = getAudioDataByURL(event.id, _decodingStack);
			audioLoadData.byteArray = new ByteArray();
			audioLoadData.channels = event.channels;
			audioLoadData.numSamplesTotal = event.sound.extract(audioLoadData.byteArray, (44100 * 60 * 60), 0);
			
			_decodedStack.push(_decodingStack.splice(_decodingStack.indexOf(audioLoadData), 1)[0]);
			decodeAudioFile();
		}
		
		/**
		 * All audio loading is done.
		 */
		private function decodingAudioDone() : void
		{
			switch(_fileDataType)
			{
				case FileDataType.STARTUP_XML_FILE:
					parseXMLtoObjects(_xml);
					break;
					
				case FileDataType.SINGLE_LOCAL_AUDIO_FILE:
					addNewAudioFile();
					break;
			}
		}
		
		/**
		 * Parse the XML, create objects and store them in the proxy.
		 */
		private function parseXMLtoObjects(xml : XML) : void
		{
			var midiToAudioProxy : MIDIEngineProxy = MIDIEngineProxy(facade.retrieveProxy(MIDIEngineProxy.NAME));
			
			/** Parse the sounds. */
			var xmlList : XMLList = xml..sound;
			var sounds : Vector.<SoundVO> = new Vector.<SoundVO>();
			
			for(var i : uint = 0; i < xmlList.length(); i++)
			{
				var audioLoadData : AudioLoadData = getAudioDataByURL(xmlList[i].@url, _decodedStack);
				_decodedStack.splice(_decodedStack.indexOf(audioLoadData), 1);
				
				var soundVO : SoundVO = new SoundVO();
				soundVO.parseXML(xmlList[i]);
				soundVO.byteArray = audioLoadData.byteArray;
				soundVO.channels = audioLoadData.channels;
				soundVO.numSamplesTotal = audioLoadData.numSamplesTotal;
				sounds.push(soundVO);
				
				facade.sendNotification(AppFacade.ADD_SOUND, soundVO);
			}
			
			/** Parse the instruments. */
			xmlList = xml..instrument;
			
			for(i = 0; i < xmlList.length(); i++)
			{
				var type : String = xmlList[i].@type;
				var instrumentVO : InstrumentVO = new InstrumentVO();
				instrumentVO.parseXML(xmlList[i]);
				var programXMLList : XMLList = xmlList[i]..program;
				
				switch(type)
				{
					case AudioProcessorType.PITCHED_SAMPLE_PROCESSOR:
						for(var j : uint = 0; j < programXMLList.length(); j++)
						{
							var programVO : PitchedSampleProgramVO = new PitchedSampleProgramVO();
							programVO.id = programXMLList[j].@id;
							programVO.type = programXMLList[j].@type;
							programVO.reverse = programXMLList[j].@reverse;
							programVO.transpose = programXMLList[j].@transpose;
							programVO.tune = programXMLList[j].@tune;
							programVO.soundData = getSoundByID(programXMLList[j].@soundid, sounds);
							programVO.start = (String(programXMLList[j].@start).length != 0) ? int(programXMLList[j].@start) : 0;
							programVO.end = (String(programXMLList[j].@end).length != 0) ? int(programXMLList[j].@end) : programVO.soundData.numSamplesTotal;
							instrumentVO.programs[programXMLList[j].@index] = programVO;
						}
						midiToAudioProxy.addInstrument(instrumentVO);
						break;
						
					case AudioProcessorType.SIMPLE_SAMPLE_PROCESSOR:
						// FIXME:  I'll add it when I need it.
						break;
				}
			}
			
			/** Parse the channels. */
			xmlList = xml..channel;
			
			for(i = 0; i < xmlList.length(); i++)
			{
				midiToAudioProxy.addInstrumentToChannel(xmlList[i].@instrumentid, xmlList[i].@index);
			}
			
			/** Tell the system we're done here. */
			if(_fileDataType == FileDataType.STARTUP_XML_FILE) facade.sendNotification(AppFacade.STARTUP_DONE);
		}
		
		/**
		 * Put the audio ByteArray in a SoundVO object and send away to store in sound bank.
		 */
		public function addNewAudioFile() : void
		{
			if(_decodedStack.length == 0)
			{
				facade.sendNotification(AppFacade.ALERT, new AlertVO("Error", "No audio was decoded."));
				return;
			}
			else if(_decodedStack.length > 1)
			{
				facade.sendNotification(AppFacade.ALERT, new AlertVO("Warning", "Unused Audio remains in the decoded stack."));
			}
			
			var audioLoadData : AudioLoadData = _decodedStack.splice(0, 1)[0];
			
			var soundVO : SoundVO = new SoundVO();
			soundVO.id = audioLoadData.url;
			soundVO.url = audioLoadData.url;
			soundVO.byteArray = audioLoadData.byteArray;
			soundVO.channels = audioLoadData.channels;
			soundVO.numSamplesTotal = audioLoadData.numSamplesTotal;
			
			facade.sendNotification(AppFacade.ADD_SOUND, soundVO);
			
			/**
			 * TODO: Nu, als het geselecteerde kanaal een sampler kanaal is (en dat is waarschijnlijk):
			 * - Maak dan een nieuwe program voor het instrument met deze sound.
			 * - Voeg het program toe aan het instrument.
			 * - Selecteer de nieuwe program.
			 */
		}
		
		/**
		 * 
		 */
		public function getSoundByID(id : String, stack : Vector.<SoundVO>) : SoundVO
		{
			for each (var soundVO : SoundVO in stack)
			{
				if(soundVO.id == id) return soundVO;
			}

			return null;
		}

		/**
		 * Get sound data for specified sound
		 */
		private function getAudioDataByLoader(loader : Object, stack : Vector.<AudioLoadData>) : AudioLoadData 
		{
			for each (var soundLoadData : AudioLoadData in stack)
			{
				if(loader is URLLoader && soundLoadData.urlLoader == loader) return soundLoadData;
			}

			return null;
		}

		/**
		 * Get sound data for specified sound
		 */
		private function getAudioDataByURL(url : String, stack : Vector.<AudioLoadData>) : AudioLoadData 
		{
			for each (var audioLoadData : AudioLoadData in stack)
			{
				if(audioLoadData.url == url) return audioLoadData;
			}

			return null;
		}
	}
}

import flash.net.URLLoader;
import flash.utils.ByteArray;

/**
 * 
 */
class AudioLoadData
{
	public var url : String;
	public var urlLoader : URLLoader;
	public var byteArray : ByteArray;
	public var fileExtention : String;
	public var channels : uint;
	public var numSamplesTotal : int;
	public var isLoading : Boolean;
	public var isLoaded : Boolean;
	
	public function AudioLoadData(url : String)
	{
		this.url = url;
		urlLoader = new URLLoader();
	}
}
