export type PlaybackState = 'idle' | 'loading' | 'ready' | 'playing' | 'stopped' | 'error';

const SAMPLE_RATE = 44_100;
const INTRO_TICK = 56;
const TICK_SECONDS = 0.1; // 150 BPM, one tick = one sixteenth note
const VOCAL_START_SECONDS = INTRO_TICK * TICK_SECONDS; // 5.6s
const LINE_DURATION_SECONDS = 64 * TICK_SECONDS; // 6.4s
const LINE_COUNT = 14;
const MP3_LEAD_SILENCE_SAMPLES = 2256;
const MP3_LEAD_SILENCE_SECONDS = MP3_LEAD_SILENCE_SAMPLES / SAMPLE_RATE;

export class ConoAudioEngine {
  private context: AudioContext | null = null;
  private musicBuffer: AudioBuffer | null = null;
  private voiceBuffers: AudioBuffer[] = [];
  private musicSource: AudioBufferSourceNode | null = null;
  private voiceSources: AudioBufferSourceNode[] = [];
  private voiceGains: GainNode[] = [];
  private lineTimer: number | null = null;
  private stopTimer: number | null = null;
  private startTime = 0;
  private currentLine = 0;

  async load(onProgress?: (loaded: number, total: number) => void): Promise<void> {
    if (!this.context) this.context = new AudioContext();

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
        const buffer = await this.context!.decodeAudioData(data);
        loaded += 1;
        onProgress?.(loaded, urls.length);
        return buffer;
      })
    );

    this.musicBuffer = buffers[0];
    this.voiceBuffers = buffers.slice(1);
  }

  async play(
    getSelections: () => number[],
    onLineChange?: (line: number) => void,
    onStop?: () => void
  ): Promise<void> {
    if (!this.context || !this.musicBuffer || this.voiceBuffers.length !== 12) {
      throw new Error('Audio has not been loaded');
    }

    this.stop();
    await this.context.resume();

    const ctx = this.context;
    this.startTime = ctx.currentTime + 0.1;
    this.currentLine = 0;

    this.musicSource = ctx.createBufferSource();
    this.musicSource.buffer = this.musicBuffer;
    this.musicSource.connect(ctx.destination);
    // The old Flash engine skipped the same encoder delay on every SoundChunk.
    this.musicSource.start(this.startTime, MP3_LEAD_SILENCE_SECONDS);

    this.voiceGains = this.voiceBuffers.map(() => {
      const gain = ctx.createGain();
      gain.gain.value = 0;
      gain.connect(ctx.destination);
      return gain;
    });

    this.voiceSources = this.voiceBuffers.map((buffer, index) => {
      const source = ctx.createBufferSource();
      source.buffer = buffer;
      source.connect(this.voiceGains[index]);
      // Keep the compensation from the old Flash engine as a first approximation.
      source.start(this.startTime + VOCAL_START_SECONDS, MP3_LEAD_SILENCE_SECONDS);
      return source;
    });

    const applyLine = () => {
      if (!this.context || this.currentLine >= LINE_COUNT) return;
      const selections = getSelections();
      const selectedVoice = selections[this.currentLine] ?? 0;
      const when = this.context.currentTime;
      this.voiceGains.forEach((gain, index) => {
        gain.gain.setValueAtTime(index === selectedVoice ? 1 : 0, when);
      });
      onLineChange?.(this.currentLine);
      this.currentLine += 1;
    };

    const firstLineDelay = Math.max(0, (this.startTime + VOCAL_START_SECONDS - ctx.currentTime) * 1000);
    window.setTimeout(() => {
      applyLine();
      this.lineTimer = window.setInterval(applyLine, LINE_DURATION_SECONDS * 1000);
    }, firstLineDelay);

    this.stopTimer = window.setTimeout(() => {
      this.stop(false);
      onStop?.();
    }, firstLineDelay + LINE_COUNT * LINE_DURATION_SECONDS * 1000);
  }

  stop(resetLine = true): void {
    if (this.lineTimer !== null) {
      window.clearInterval(this.lineTimer);
      this.lineTimer = null;
    }
    if (this.stopTimer !== null) {
      window.clearTimeout(this.stopTimer);
      this.stopTimer = null;
    }

    try {
      this.musicSource?.stop();
    } catch {}
    this.voiceSources.forEach((source) => {
      try {
        source.stop();
      } catch {}
    });

    this.musicSource = null;
    this.voiceSources = [];
    this.voiceGains = [];
    if (resetLine) this.currentLine = 0;
  }
}

export const conoTiming = {
  bpm: 150,
  vocalStartSeconds: VOCAL_START_SECONDS,
  lineDurationSeconds: LINE_DURATION_SECONDS,
  lineCount: LINE_COUNT,
  mp3LeadSilenceSeconds: MP3_LEAD_SILENCE_SECONDS
};
