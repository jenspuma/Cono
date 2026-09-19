export type PlaybackState = 'idle' | 'loading' | 'ready' | 'playing' | 'stopped' | 'error';

const SAMPLE_RATE = 44_100;
const INTRO_TICK = 56;
const TICK_SECONDS = 0.1; // 150 BPM, one tick = one sixteenth note
const VOCAL_START_SECONDS = INTRO_TICK * TICK_SECONDS; // 5.6s
const LINE_DURATION_SECONDS = 64 * TICK_SECONDS; // 6.4s
const LINE_COUNT = 14;
const CYCLE_SECONDS = LINE_COUNT * LINE_DURATION_SECONDS;
const MUSIC_LOOP_START_SECONDS = 96;
const MUSIC_LOOP_SECONDS = 537.6;
const MP3_LEAD_SILENCE_SAMPLES = 2256;
const MP3_LEAD_SILENCE_SECONDS = MP3_LEAD_SILENCE_SAMPLES / SAMPLE_RATE;

export class ConoAudioEngine {
  private context: AudioContext | null = null;
  private musicBuffer: AudioBuffer | null = null;
  private voiceBuffers: AudioBuffer[] = [];
  private musicSource: AudioBufferSourceNode | null = null;
  private voiceSources: AudioBufferSourceNode[] = [];
  private mixer: AudioWorkletNode | null = null;
  private generation = 0;
  private getSelections: (() => number[]) | null = null;
  private startTime = 0;


  async load(onProgress?: (loaded: number, total: number) => void): Promise<void> {
    if (!this.context) this.context = new AudioContext();
    const context = this.context;

    const urls = [
      './assets/Music.mp3',
      ...Array.from({ length: 12 }, (_, i) => `./assets/Verse${i + 1}.mp3`)
    ];

    let loaded = 0;
    const buffers = await Promise.all(
      urls.map(async (url) => {
        const response = await fetch(url);
        if (!response.ok) throw new Error(`Could not load ${url}`);
        const data = await response.arrayBuffer();
        const buffer = await context.decodeAudioData(data);
        loaded += 1;
        onProgress?.(loaded, urls.length);
        return buffer;
      })
    );

    if (this.context !== context) return;
    await context.audioWorklet.addModule('./assets/cono-mixer.js');
    if (this.context !== context) return;
    this.musicBuffer = buffers[0];
    // Some recordings end slightly before 89.6s. Pad with silence rather than
    // looping at their file length, which would progressively lose sync.
    this.voiceBuffers = buffers.slice(1).map((buffer) => {
      const loop = context.createBuffer(buffer.numberOfChannels,
        Math.round(CYCLE_SECONDS * buffer.sampleRate), buffer.sampleRate);
      const offset = Math.round(MP3_LEAD_SILENCE_SECONDS * buffer.sampleRate);
      for (let channel = 0; channel < buffer.numberOfChannels; channel++) {
        loop.copyToChannel(buffer.getChannelData(channel).subarray(offset, offset + loop.length), channel);
      }
      return loop;
    });
  }

  async play(
    getSelections: () => number[],
    onLineChange?: (line: number) => void,
    onVerseChange?: (selections: number[]) => void
  ): Promise<void> {
    if (!this.context || !this.musicBuffer || this.voiceBuffers.length !== 12) {
      throw new Error('Audio has not been loaded');
    }

    this.stop();
    const generation = this.generation;
    await this.context.resume();
    if (generation !== this.generation) return;

    const ctx = this.context;
    this.startTime = ctx.currentTime + 0.1;
    this.getSelections = getSelections;

    this.mixer = new AudioWorkletNode(ctx, 'cono-mixer', {
      numberOfInputs: 12,
      numberOfOutputs: 1,
      outputChannelCount: [2],
      processorOptions: {
        startTime: this.startTime + VOCAL_START_SECONDS,
        selections: getSelections(),
        lineDuration: LINE_DURATION_SECONDS
      }
    });
    this.mixer.port.onmessage = ({ data }) => {
      if (generation !== this.generation) return;
      onVerseChange?.(data.selections);
      onLineChange?.(data.line);
    };
    this.mixer.connect(ctx.destination);

    this.musicSource = ctx.createBufferSource();
    this.musicSource.buffer = this.musicBuffer;
    this.musicSource.loop = true;
    // Original XML: play the intro once, then repeat ticks 960..6336.
    this.musicSource.loopStart = MUSIC_LOOP_START_SECONDS + MP3_LEAD_SILENCE_SECONDS;
    this.musicSource.loopEnd = this.musicSource.loopStart + MUSIC_LOOP_SECONDS;
    this.musicSource.connect(ctx.destination);
    this.musicSource.start(this.startTime, MP3_LEAD_SILENCE_SECONDS);

    this.voiceSources = this.voiceBuffers.map((buffer, index) => {
      const source = ctx.createBufferSource();
      source.buffer = buffer;
      source.loop = true;
      source.loopStart = 0;
      source.loopEnd = CYCLE_SECONDS;
      source.connect(this.mixer!, 0, index);
      source.start(this.startTime + VOCAL_START_SECONDS);
      return source;
    });
  }

  updateSelections(): void {
    if (!this.getSelections) return;
    this.mixer?.port.postMessage({ type: 'selections', selections: this.getSelections() });
  }

  stop(): void {
    this.generation += 1;
    this.getSelections = null;
    if (this.mixer) {
      this.mixer.port.onmessage = null;
      this.mixer.port.postMessage({ type: 'stop' });
      this.mixer.disconnect();
      this.mixer = null;
    }
    try {
      this.musicSource?.stop();
    } catch {}
    this.voiceSources.forEach((source) => {
      try {
        source.stop();
      } catch {}
    });

    this.musicSource?.disconnect();
    this.voiceSources.forEach((source) => source.disconnect());
    this.musicSource = null;
    this.voiceSources = [];
  }

  dispose(): void {
    this.stop();
    void this.context?.close();
    this.context = null;
    this.musicBuffer = null;
    this.voiceBuffers = [];
  }
}

export const conoTiming = {
  bpm: 150,
  vocalStartSeconds: VOCAL_START_SECONDS,
  lineDurationSeconds: LINE_DURATION_SECONDS,
  lineCount: LINE_COUNT,
  cycleSeconds: CYCLE_SECONDS,
  musicLoopStartSeconds: MUSIC_LOOP_START_SECONDS,
  musicLoopSeconds: MUSIC_LOOP_SECONDS,
  mp3LeadSilenceSeconds: MP3_LEAD_SILENCE_SECONDS
};
