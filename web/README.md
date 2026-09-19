# Cono web edition

SvelteKit/Web Audio version of the original Flash/Flex project, with an Editorial / Literary
interface and the original lyrics, backing track and 12 vocal recordings.

## Run and verify

Use Node 22.18+ or Node 24+.

```bash
npm install
npm run dev
npm run test
npm run check
npm run build
npm run preview
```

## Playback

Play starts the intro once. Vocals enter after 5.6s, with a new line every 6.4s.
After all 14 lines (89.6s), the next verse begins immediately. Playback continues
until Stop. Each new verse normally gets a random combination of source poems.
If the user edits any choices (including Randomize), those choices are retained
into the following verse; automatic randomization resumes one verse later.
Current-line edits switch the voice at its current playback position.

Native looping AudioBufferSourceNodes keep every voice on an exact 89.6s cycle.
Shorter vocal recordings are padded with silence; longer recordings are trimmed
to the cycle. MP3 compensation is applied once while preparing these buffers.
An AudioWorklet selects the audible voice and generates new verse choices on the
audio thread, so background-tab timer throttling cannot postpone a boundary.
The page receives line/choice notifications for display only.

The backing follows `conosong.xml`: 96s intro followed by a repeating 537.6s
music section. The backing is not restarted at each vocal verse. The historical
2256/44100-second MP3 compensation is preserved; the user approved the sound of
the preceding prototype by listening. Browsers require HTTPS or localhost for
the AudioWorklet.

## Tests

Seven dependency-free tests cover native loop bounds, short recording padding,
Stop/restart, pending resume cancellation, live selections, sample-clock line and
verse transitions, simulated long playback, and automatic/manual verse choices.

For the actual browser diagnostic:

```bash
cp tests/audio.html static/__audio-test.html
npm run dev
```

Open `/__audio-test.html` on the printed local URL and click Run audio verification.
Allow about 110 seconds: it decodes all media, plays across a full verse boundary,
checks loop timing and retained edits, then checks Stop and immediate restart.
Remove `static/__audio-test.html` before building or committing. This diagnostic
imports source TypeScript and is development-only.

Original media, XML and image files remain byte-for-byte identical to the legacy
assets. Lyrics are decoded as Windows-1252. npm audit currently reports three
low-severity entries through SvelteKit's cookie dependency.

## Release validation

On 2026-09-19 the owner tested the local edition and approved it as releasable.
The release candidate includes the continuous audio-loop implementation, editorial
assets, source poem numbers (01–12), and About / Credits disclosure. Svelte check,
all seven audio tests, and the static production build pass. Automated browser
review was unavailable; visual acceptance is based on the owner’s manual testing.
