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
  private generation = 0;
  private getSelections: (() => number[]) | null = null;
  private startTime = 0;
  private currentLine = -1;

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
    const generation = this.generation;
    await this.context.resume();
    if (generation !== this.generation) return;

    const ctx = this.context;
    this.startTime = ctx.currentTime + 0.1;
    this.currentLine = -1;
    this.getSelections = getSelections;

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

    // Audio events are scheduled once on the shared audio clock, so a busy or
    // background tab cannot delay a vocal boundary. UI timers only paint state.
    this.updateSelections();
    const endTime = this.startTime + VOCAL_START_SECONDS + LINE_COUNT * LINE_DURATION_SECONDS;
    this.musicSource.stop(endTime);
    this.voiceSources.forEach((source) => source.stop(endTime));
    const finish = () => {
      if (generation !== this.generation) return;
      this.stop();
      onStop?.();
    };
    // The backing recording is longer than this one-cycle MVP.
    this.musicSource.onended = finish;
    const updateLine = () => {
      if (generation !== this.generation) return;
      const elapsed = ctx.currentTime - this.startTime - VOCAL_START_SECONDS;
      const line = Math.min(LINE_COUNT - 1, Math.floor(elapsed / LINE_DURATION_SECONDS));
      if (elapsed >= LINE_COUNT * LINE_DURATION_SECONDS) { finish(); return; }
      if (line >= 0 && line !== this.currentLine) {
        this.currentLine = line;
        onLineChange?.(line);
      }
    };
    this.lineTimer = window.setInterval(updateLine, 25);
  }

  updateSelections(): void {
    if (!this.context || !this.getSelections || !this.voiceGains.length) return;
    const now = this.context.currentTime;
    const vocalStart = this.startTime + VOCAL_START_SECONDS;
    const activeLine = Math.floor((now - vocalStart) / LINE_DURATION_SECONDS);
    const selections = this.getSelections();
    this.voiceGains.forEach((gain, voice) => {
      gain.gain.cancelScheduledValues(now);
      // Editing the current line changes its voice immediately at the same
      // playback position; future lines retain sample-timed boundaries.
      gain.gain.setValueAtTime(
        activeLine >= 0 && activeLine < LINE_COUNT && (selections[activeLine] ?? 0) === voice ? 1 : 0,
        now
      );
      for (let line = Math.max(0, activeLine + 1); line < LINE_COUNT; line++) {
        gain.gain.setValueAtTime((selections[line] ?? 0) === voice ? 1 : 0,
          vocalStart + line * LINE_DURATION_SECONDS);
      }
    });
  }

  stop(): void {
    this.generation += 1;
    this.getSelections = null;
    if (this.lineTimer !== null) {
      window.clearInterval(this.lineTimer);
      this.lineTimer = null;
    }
    if (this.musicSource) this.musicSource.onended = null;
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
    this.voiceGains.forEach((gain) => gain.disconnect());
    this.musicSource = null;
    this.voiceSources = [];
    this.voiceGains = [];
    this.currentLine = -1;
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
  mp3LeadSilenceSeconds: MP3_LEAD_SILENCE_SECONDS
};
