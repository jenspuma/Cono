// Runs on the audio rendering thread: loops and verse changes do not depend on
// timers in the page (which browsers throttle in background tabs).
class ConoMixer extends AudioWorkletProcessor {
  constructor(options) {
    super();
    const { startTime, selections, lineDuration = 6.4 } = options.processorOptions;
    this.startTime = startTime;
    this.lineDuration = lineDuration;
    this.selections = selections.slice();
    this.lastLine = -1;
    this.edited = false;
    this.running = true;
    this.port.onmessage = ({ data }) => {
      if (data.type === 'stop') this.running = false;
      if (data.type === 'selections') {
        this.selections = data.selections.slice();
        this.edited = true;
      }
    };
  }

  process(inputs, outputs) {
    if (!this.running) return false;
    const output = outputs[0];
    for (let frame = 0; frame < output[0].length; frame++) {
      const elapsed = (currentFrame + frame) / sampleRate - this.startTime;
      if (elapsed < 0) continue;
      const absoluteLine = Math.floor((elapsed + 1e-9) / this.lineDuration);
      const line = absoluteLine % 14;
      if (absoluteLine !== this.lastLine) {
        if (line === 0 && absoluteLine > 0) {
          if (!this.edited) this.selections = Array.from({ length: 14 }, () => Math.floor(Math.random() * 12));
          this.edited = false;
        }
        this.lastLine = absoluteLine;
        this.port.postMessage({ line, cycle: Math.floor(absoluteLine / 14), selections: this.selections.slice() });
      }
      const input = inputs[this.selections[line] ?? 0];
      for (let channel = 0; channel < output.length; channel++) {
        output[channel][frame] = input?.[channel]?.[frame] ?? input?.[0]?.[frame] ?? 0;
      }
    }
    return true;
  }
}
registerProcessor('cono-mixer', ConoMixer);
