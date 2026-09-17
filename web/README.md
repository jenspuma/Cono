# Cono web MVP

First modern browser prototype of the original Flash/Flex Cono project.

## Goal

Validate the core experience before doing a visual redesign:

- render the 14 combinatorial poem lines
- choose one of 12 source poems independently for each line
- randomize the poem
- load the original backing track and all 12 synchronized vocal performances
- switch the audible vocal performance every 6.4 seconds
- preserve the original 5.6 second vocal entry point and the old 2256-sample MP3 lead-silence compensation as a starting hypothesis

This first version intentionally plays one 14-line cycle and then stops. Once sync is verified in current browsers we can add the original continuous/repeating behavior.

## Run locally

```bash
npm install
npm run dev
```

Then open the local URL printed by Vite.

## Build

```bash
npm run build
npm run preview
```

## Source assets

The files under `static/assets` are copied by Git blob reference from the original project so the prototype tests the exact same media files.

## Verification

Use Node 22.18+ or Node 24+ for the dependency-free TypeScript tests.

```bash
npm run test
npm run check
npm run build
```

All 14 gain changes and the 95.2-second cycle end are scheduled on the Web Audio
clock. A 25ms timer updates the highlight only. Editing the current line changes
its audible voice immediately; editing future lines replaces their scheduled
choices. Stop also cancels a pending AudioContext resume.

For the real-browser diagnostic with the original media:

```bash
cp tests/audio.html static/__audio-test.html
npm run dev
```

Open `/__audio-test.html` on the printed local URL, click Run audio verification,
and wait for COMPLETE. Remove the temporary `static/__audio-test.html` before
building or committing; the diagnostic imports source TS and is development-only.

### Laptop validation

- npm install, six audio regression tests, Svelte check and static build passed.
- All original assets match the legacy files byte-for-byte.
- Browser diagnostic: all 13 MP3s decoded at 48 kHz. Vocal sources share an exact
  5.6-second entry offset relative to Music; the next gain boundary is at 12.0s.
- Observed highlight callbacks: 5.607s and 12.007s (display timer only).
- Current-line edits, upcoming-line edits and Stop during intro passed in-browser.
- The original XML uses Windows-1252; decoding now preserves accented characters
  and curly apostrophes. The book background resolves correctly in built CSS.

The 2256/44100-second MP3 offset remains a compatibility hypothesis from Flash.
Decoded voice signals first exceed -60dB around 25ms, while the retained offset
is about 51ms. Signal onset alone does not establish musical alignment, so this
is not proof that 2256 samples is ideal for modern decoding. A listening comparison
is still needed before approving perceptual sync; no offset has been retuned.
