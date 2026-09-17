import test from 'node:test';
import assert from 'node:assert/strict';
import { ConoAudioEngine, conoTiming } from '../src/lib/audio/ConoAudioEngine.ts';
let ctx, timers, nextTimer;
class Param {
  value = 0; events = [];
  setValueAtTime(value,time) { this.events.push({value,time}); }
  cancelScheduledValues(time) { this.events = this.events.filter(e=>e.time<time); }
}
class Source {
  starts=[]; stops=[]; onended=null;
  connect() {} disconnect() {}
  start(...args) { this.starts.push(args); }
  stop(time) { this.stops.push(time); }
}
class Context {
  currentTime=10; destination={}; sources=[]; gains=[];
  constructor() { ctx=this; }
  async resume() {} async close() {}
  async decodeAudioData() { return {}; }
  createBufferSource() { const s=new Source();this.sources.push(s);return s; }
  createGain() { const g={gain:new Param(),connect(){},disconnect(){}};this.gains.push(g);return g; }
}
async function setup() {
  timers=new Map();nextTimer=0;
  globalThis.window={setInterval(fn){timers.set(++nextTimer,fn);return nextTimer;},clearInterval(id){timers.delete(id);}};
  globalThis.AudioContext=Context;
  globalThis.fetch=async()=>({ok:true,arrayBuffer:async()=>new ArrayBuffer(0)});
  const engine=new ConoAudioEngine();await engine.load();return engine;
}
const near=(a,b)=>assert.ok(Math.abs(a-b)<1e-9,`${a} != ${b}`);
test('13 sources share offsets; vocals enter at 5.6s; all 14 boundaries are audio-clock events',async()=>{
  const e=await setup();await e.play(()=>Array.from({length:14},(_,i)=>i%12));
  const start=ctx.sources[0].starts[0][0];assert.equal(ctx.sources.length,13);
  for(const s of ctx.sources.slice(1)){near(s.starts[0][0]-start,5.6);near(s.starts[0][1],2256/44100);}
  near(ctx.sources[0].starts[0][1],2256/44100);
  for(let line=0;line<14;line++)for(let voice=0;voice<12;voice++){
    const event=ctx.gains[voice].gain.events[line+1];near(event.time,start+5.6+line*6.4);assert.equal(event.value,voice===line%12?1:0);
  }
  for(const s of ctx.sources)near(s.stops[0]-start,95.2);
});
test('Stop during intro cancels callbacks and restart has just one timer',async()=>{
  const e=await setup();let lines=[];await e.play(()=>[],l=>lines.push(l));
  const stale=[...timers.values()][0];e.stop();assert.equal(timers.size,0);
  await e.play(()=>[],l=>lines.push(l));ctx.currentTime=100;stale();assert.deepEqual(lines,[]);assert.equal(timers.size,1);
});
test('Stop while resume is pending cannot restart audio',async()=>{
  const e=await setup();let resume;ctx.resume=()=>new Promise(resolve=>resume=resolve);
  const pending=e.play(()=>[]);e.stop();resume();await pending;assert.equal(ctx.sources.length,0);assert.equal(timers.size,0);
});
test('live edits replace current voice and future scheduled choices',async()=>{
  const e=await setup();let selections=Array(14).fill(0);await e.play(()=>selections);
  ctx.currentTime=17;selections[0]=4;selections[1]=11;e.updateSelections();
  assert.equal(ctx.gains[0].gain.events.find(e=>e.time===17).value,0);
  assert.equal(ctx.gains[4].gain.events.find(e=>e.time===17).value,1);
  assert.equal(ctx.gains[11].gain.events.find(e=>Math.abs(e.time-22.1)<1e-9).value,1);
});
test('delayed UI tick catches up from audio clock; natural end runs once',async()=>{
  const e=await setup();let lines=[],stops=0;await e.play(()=>[],l=>lines.push(l),()=>stops++);
  ctx.currentTime=42;[...timers.values()][0]();assert.deepEqual(lines,[4]);
  const end=ctx.sources[0].onended;end();end();assert.equal(stops,1);assert.equal(timers.size,0);
});
test('asset failure rejects load with filename',async()=>{
  const e=await setup();globalThis.fetch=async()=>({ok:false});await assert.rejects(e.load(),/Music.mp3/);
});
