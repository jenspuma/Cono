import test from 'node:test';
import assert from 'node:assert/strict';
import vm from 'node:vm';
import { readFileSync } from 'node:fs';
import { ConoAudioEngine } from '../src/lib/audio/ConoAudioEngine.ts';
let ctx;
class Buffer {
  sampleRate=100; numberOfChannels=1; length=8930;
  data=new Float32Array(this.length).fill(0.5);
  getChannelData(){return this.data;}
  copyToChannel(data){this.data.set(data);}
}
class Source {
  starts=[]; stops=[];
  connect(){} disconnect(){}
  start(...a){this.starts.push(a);} stop(...a){this.stops.push(a);}
}
class Mixer {
  messages=[];
  constructor(context,name,options){this.options=options;this.port={postMessage:m=>this.messages.push(m)};context.mixer=this;}
  connect(){} disconnect(){}
}
class Context {
  currentTime=10;destination={};sources=[];
  audioWorklet={addModule:async()=>{}};
  constructor(){ctx=this;}
  async resume(){} async close(){} async decodeAudioData(){return new Buffer();}
  createBuffer(channels,length,rate){const b=new Buffer();b.length=length;b.sampleRate=rate;b.data=new Float32Array(length);return b;}
  createBufferSource(){const s=new Source();this.sources.push(s);return s;}
}
async function setup(){
  globalThis.AudioContext=Context;globalThis.AudioWorkletNode=Mixer;
  globalThis.fetch=async()=>({ok:true,arrayBuffer:async()=>new ArrayBuffer(0)});
  const engine=new ConoAudioEngine();await engine.load();return engine;
}
const near=(a,b)=>assert.ok(Math.abs(a-b)<1e-8,`${a} != ${b}`);
test('native sources loop indefinitely with exact vocal and original backing periods',async()=>{
  const e=await setup();await e.play(()=>Array(14).fill(0));
  const [music,...voices]=ctx.sources;assert.equal(voices.length,12);
  near(music.loopStart,96+2256/44100);near(music.loopEnd-music.loopStart,537.6);
  for(const s of ctx.sources){assert.equal(s.loop,true);assert.equal(s.stops.length,0);}
  for(const s of voices){near(s.starts[0][0]-music.starts[0][0],5.6);near(s.loopEnd,89.6);assert.equal(s.buffer.length,8960);assert.equal(s.buffer.data.at(-1),0);}
});
test('Stop stops all sources and ignores old mixer messages after restart',async()=>{
  const e=await setup();let lines=[];await e.play(()=>[],l=>lines.push(l));
  const sources=ctx.sources.slice(),mixer=ctx.mixer,stale=mixer.port.onmessage;
  e.stop();for(const s of sources)assert.equal(s.stops.length,1);
  assert.equal(mixer.messages.at(-1).type,'stop');await e.play(()=>[],l=>lines.push(l));
  stale({data:{line:3,selections:[]}});assert.deepEqual(lines,[]);
});
test('Stop during pending resume prevents playback',async()=>{
  const e=await setup();let resume;ctx.resume=()=>new Promise(r=>resume=r);
  const p=e.play(()=>[]);e.stop();resume();await p;assert.equal(ctx.sources.length,0);
});
test('live selections are sent to the audio thread',async()=>{
  const e=await setup();let choices=Array(14).fill(0);await e.play(()=>choices);
  choices[0]=11;e.updateSelections();assert.equal(ctx.mixer.messages.at(-1).selections[0],11);
});
function processor(){
  const scope={sampleRate:100,currentFrame:0,Math:Object.create(Math),AudioWorkletProcessor:class{port={messages:[],postMessage(m){this.messages.push(m);}};},registerProcessor(name,cls){scope.Processor=cls;}};
  scope.Math.random=()=>0.55;vm.createContext(scope);
  vm.runInContext(readFileSync(new URL('../static/assets/cono-mixer.js',import.meta.url),'utf8'),scope);
  const p=new scope.Processor({processorOptions:{startTime:5.6,selections:Array.from({length:14},(_,i)=>i%12)}});
  const inputs=Array.from({length:12},(_,i)=>[new Float32Array(1).fill(i+1)]);
  const tick=(time)=>{scope.currentFrame=Math.round(time*100);const outputs=[[new Float32Array(1),new Float32Array(1)]];p.process(inputs,outputs);return outputs[0][0][0];};
  return {p,tick};
}
test('audio thread switches every 6.4 seconds, wraps at 95.2s and continues for hours without page timers',()=>{
  const {p,tick}=processor();assert.equal(tick(5.59),0);
  for(let line=0;line<14;line++)assert.equal(tick(5.6+line*6.4),line%12+1);
  assert.equal(tick(95.19),2);assert.equal(tick(95.2),7);
  assert.equal(p.port.messages.at(-1).line,0);assert.equal(p.port.messages.at(-1).cycle,1);
  assert.equal(tick(5.6+89.6*100),7);assert.equal(p.port.messages.at(-1).cycle,100);
});
test('manual edits persist into next verse then automatic randomization resumes',()=>{
  const {p,tick}=processor();tick(5.6);
  p.port.onmessage({data:{type:'selections',selections:Array(14).fill(11)}});
  assert.equal(tick(6),12);assert.equal(tick(95.2),12);assert.equal(tick(184.8),7);
  p.port.onmessage({data:{type:'stop'}});assert.equal(p.process([],[[new Float32Array(1)]]),false);
});
test('asset failure rejects load with filename',async()=>{
  const e=await setup();globalThis.fetch=async()=>({ok:false});await assert.rejects(e.load(),/Music.mp3/);
});
