package com.hisschemoller.utils.midi {
	import flash.events.Event;	import flash.utils.getQualifiedClassName;		/**	 * @author Wouter Hisschemöller	 * (c) May 8, 2009	 */
	public class MidiManagerEvent extends Event 
	{
		/** Event type. */
		public static const _EVENT : String = "midiManagerEvent";
		/** Event subtype sent when a single object starts being loaded. */
		public static const COMPLETE : String = "midiLoadComplete";
		/** Event subtype  sent when there's an error. */
		public static const LOAD_ERROR : String = "loadError";		public static const FORMAT_ERROR : String = "formatError";		public static const TIMESTAMP_ERROR : String = "timestampError";		public static const PARSE_ERROR : String = "parseError";
		public var subtype : String;
		public var error : String;		public var name : String;
		/**
		 * Creates a new MidiManagerEvent.
		 * @param inSubtype: either subtype; see above
		 * @param inName: identifier of the loading action
		 */
		public function MidiManagerEvent(inSubtype : String, inName : String) 
		{
			super(_EVENT);
			
			subtype = inSubtype;			name = inName;
		}
		/**
		 * Creates a copy of an existing MidiManagerEvent.
		 */
		override public function clone() : Event 
		{
			return new MidiManagerEvent(subtype, name);
		} 		override public function toString() : String 		{			return getQualifiedClassName(this) + "; name=" + name + "; subtype=" + subtype + "; error=" + error;		}
	}
}