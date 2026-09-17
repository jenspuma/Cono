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
